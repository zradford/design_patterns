# refactorinng guru source at bottom
class CharacterBuilder
  def initialize
    reset
  end
  
  def reset
    @character = Character.new
  end
  
  def character
    character = @character
    # refactoring guru had this pattern of resetting like this:
    # reset
    # character
    # but I think the resetting should probably go somewhere else, probably left for the
    # director to do, since resetting like this ^^ led to inconsistency
  end
  
  def roll_attack
    raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
  end

  def roll_defense
    raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
  end
  
end

class GoodCharacterBuilder < CharacterBuilder
  def roll_attack
    puts "rolling for attack"
    @character.attack = rand(5..10)
    puts self.inspect
  end

  def roll_defense
    puts "rolling for defense"
    @character.defense = rand(3..12)
  end
end

class BadCharacterBuilder < CharacterBuilder
  def roll_attack
    puts "rolled badly for attack"
    @character.attack = 1
  end

  def roll_defense
    puts "rolled badly for defense"
    @character.defense = 1
  end
end

class Character
  attr_accessor :attack, :defense
  def initialize
    @hp = 30
    @attack  = 0
    @defense = 0
  end
  
  def display
    puts({ hp: @hp, attack: attack, defense: defense })
  end
end

class Director
  attr_accessor :builder

  def initialize
    @builder = nil
  end

  def build_minimal_viable_product
    @builder.reset
    @builder.roll_attack
  end

  def build_full_featured_product
    # a better reset is probably at the beginning of building, so the builder's product is 
    # available until you nneed a new one?
    @builder.reset
    @builder.roll_attack
    @builder.roll_defense
  end
  
  def show_results
    puts @builder.character
  end
end

director = Director.new
g_builder = GoodCharacterBuilder.new
director.builder = g_builder

puts "building good mvp"
director.build_minimal_viable_product
director.show_results

puts; puts "fully featured"
director.build_full_featured_product
director.show_results

puts; puts "Now a bad one: "
bad_builder = BadCharacterBuilder.new
director.builder = bad_builder

puts; puts "building bad mvp"
director.build_minimal_viable_product
director.show_results

puts; puts "fully featured"
director.build_full_featured_product
director.show_results


puts; puts "Now another good one: "
director.builder = g_builder

puts; puts "building bad mvp"
director.build_minimal_viable_product
director.show_results

puts; puts "fully featured"
director.build_full_featured_product
director.show_results


# # Interface
# class Builder
#   def produce_part_a
#     raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
#   end
  
#   def produce_part_b
#     raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
#   end
  
#   def produce_part_c
#     raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
#   end
# end

# # specific implementations of building steps
# class ConcreteBuilder1 < Builder
#   # A fresh builder instance should contain a blank product object, which is
#   # used in further assembly.
#   def initialize
#     reset
#   end
  
#   def reset
#     @product = Product1.new
#   end
  
#   # Concrete Builders are supposed to provide their own methods for retrieving
#   # results. That's because various types of builders may create entirely
#   # different products that don't follow the same interface. Therefore, such
#   # methods cannot be declared in the base Builder interface (at least in a
#   # statically typed programming language).
#   #
#   # Usually, after returning the end result to the client, a builder instance is
#   # expected to be ready to start producing another product. That's why it's a
#   # usual practice to call the reset method at the end of the `getProduct`
#   # method body. However, this behavior is not mandatory, and you can make your
#   # builders wait for an explicit reset call from the client code before
#   # disposing of the previous result.
#   def product
#     product = @product
#     reset
#     product
#   end

#   def produce_part_a
#     @product.add('PartA1')
#   end

#   def produce_part_b
#     @product.add('PartB1')
#   end

#   def produce_part_c
#     @product.add('PartC1')
#   end
# end

# # It makes sense to use the Builder pattern only when your products are quite
# # complex and require extensive configuration.
# #
# # Unlike in other creational patterns, different concrete builders can produce
# # unrelated products. In other words, results of various builders may not always
# # follow the same interface.
# class Product1
#   def initialize
#     @parts = []
#   end
  
#   def add(part)
#     @parts << part
#   end
  
#   def list_parts
#     print "Product parts: #{@parts.join(', ')}"
#   end
# end

# # The Director is only responsible for executing the building steps in a
# # particular sequence. It is helpful when producing products according to a
# # specific order or configuration. Strictly speaking, the Director class is
# # optional, since the client can control builders directly.
# class Director
#   # The Director works with any builder instance that the client code passes to
#   # it. This way, the client code may alter the final type of the newly
#   # assembled product.
#   attr_accessor :builder

#   def initialize
#     @builder = nil
#   end

#   # The Director can construct several product variations using the same
#   # building steps.

#   def build_minimal_viable_product
#     @builder.produce_part_a
#   end

#   def build_full_featured_product
#     @builder.produce_part_a
#     @builder.produce_part_b
#     @builder.produce_part_c
#   end
  
#   def show_results
#     @builder.product.list_parts
#   end
# end

# director = Director.new
# builder = ConcreteBuilder1.new
# director.builder = builder

# puts 'Standard basic product: '
# director.build_minimal_viable_product
# director.show_results

# puts "\n\n"

# puts 'Standard full featured product: '
# director.build_full_featured_product
# director.show_results

# puts "\n\n"

# # Remember, the Builder pattern can be used without a Director class.
# puts 'Custom product: '
# builder.produce_part_a
# builder.produce_part_b
# builder.product.list_parts