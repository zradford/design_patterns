require 'csv'

# Parent sets up Interface and defines the process by which the other templates will be executed
class CsvImporter
  attr_reader :file

  def initialize(filename, *kwargs)
    @file = File.new(filename)
  end

  def import
    CSV::foreach(file, :headers => :first_row) do |row|
      before
      @row = parse_data(row)
      next if filter?
      manipulate_data
      store
      after
    end
  end
  
  def parse_data(row)
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
end

class PersonImporter < CsvImporter
  def parse_data(row)
    Person.from_row(row)
  end
  
  def manipulate_data
    @row.company = "Applebee's"
  end
  
  def store
    puts @row.to_s
  end
end

class SpecializedPersonImporter < PersonImporter
  def initialize(filename, letter: 'm')
    super
    @letter = letter
  end

  def parse_data(row)
    puts "Is #{@letter.upcase} the letter #{row["first_name"][0]}?"
    super
  end
  
  def filter?
    !@row.first_name.downcase.start_with? @letter
  end
end

class AddressImporter < CsvImporter
  def parse_data(row)
    Address.from_row(row)
  end
  
  def store
    puts @row.to_s
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
  importer.import
end

# import_runner(PersonImporter.new(csv_file))
# import_runner(AddressImporter.new(csv_file))
import_runner(SpecializedPersonImporter.new(csv_file, letter: 'a'))