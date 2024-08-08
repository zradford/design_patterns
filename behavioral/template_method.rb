require 'csv'

# Parent sets up Interface and defines the process by which the other templates will be executed
class CsvImporter
  attr_reader :file

  def initialize(filename, *kwargs)
    @file = File.new(filename)
  end

  def import
    before

    CSV::foreach(file, :headers => :first_row) do |row|
      @row = row
      next if filter?
      
      @data = parse_data
      manipulate_data
      store
      after
    end

    return result if @result
  end
  
  def parse_data
    raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
  end
  
  def store
    raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
  end
  
  def filter?
    false
  end
  
  def before; end
  def after; end
  def manipulate_data; end
  def result; @result end
end

module Storable
  def before
    @result = []
  end

  def store
    @result << @data
  end
end

class PersonImporter < CsvImporter
  prepend Storable

  def parse_data
    Person.from_row(@row)
  end
end

class ApplebeesImporter < PersonImporter
  def manipulate_data
    @data.company = "Applebee's"
  end
end

class SpecializedPersonImporter < PersonImporter
  def initialize(filename, letter: 'm')
    super
    @letter = letter
  end

  def parse_data
    puts "Is #{@letter.upcase} the letter #{@row["first_name"][0]}?"
    super
  end
  
  def filter?
    !@row["first_name"].downcase.start_with? @letter
  end
end

class AddressImporter < CsvImporter
  prepend Storable
  
  def parse_data
    Address.from_row(@row)
  end
end


class Person
  attr_accessor :first_name, :surname, :telephone, :email, :company
  
  def initialize(first_name:, surname:, telephone:, email:, company:)
    @first_name = first_name
    @surname    = surname
    @telephone  = telephone
    @email      = email
    @company    = company
  end
  
  def self.from_row(row)
    new(first_name: row["first_name"],
        surname:    row["surname"],
        telephone:  row["telephone"],
        email:      row["email"],
        company:    row["company"])
  end
  
  def to_s
    "#{first_name} #{surname} (#{company})
     #{telephone}
     #{email}
     \n"
  end
end

class Address
  attr_accessor :address, :city, :state, :zipcode, :country, :person_name

  def initialize(address:, city:, state:, zipcode:, country:, person_name:)
    @address   = address
    @city      = city
    @state     = state
    @zipcode   = zipcode
    @country   = country
    @person_name = person_name
  end
  
  def self.from_row(row)
    new( address:     row["address"],
         city:        row["city"],
         state:       row["state"],
         zipcode:     row["zipcode"],
         country:     row["country"],
         person_name: row["first_name"] + " " + row["surname"])
  end
  
  def to_s
    "#{person_name}
     #{address}
     #{city}, #{state} #{country}
     #{zipcode}"
  end
end

csv_file = File.new('./test.csv')
def import_runner(importer)
  puts Time.now
  sleep 1
  puts importer.import
  puts Time.now
end

puts "\n----------------------------------------------------------\n"
import_runner(PersonImporter.new(csv_file))
puts "\n----------------------------------------------------------\n"
import_runner(ApplebeesImporter.new(csv_file))
puts "\n----------------------------------------------------------\n"
import_runner(AddressImporter.new(csv_file))
puts "\n----------------------------------------------------------\n"
import_runner(SpecializedPersonImporter.new(csv_file, letter: 'a'))