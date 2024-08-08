# The Component interface declares an `accept` method that should take the base
# visitor interface as an argument.
class Component
  def accept(_visitor)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

# The Visitor Interface declares a set of visiting methods that correspond to
# component classes. The signature of a visiting method allows the visitor to
# identify the exact class of the component that it's dealing with.
class Visitor
  def visit_concrete_component_a(_element)
    raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
  end
  
  def visit_concrete_component_b(_element)
    raise NotImplementedError, "#{self.class} has not implemented method: '#{__method__}'"
  end
end

class ConcreteComponentA < Component
  def accept(visitor)
    visitor.visit_concrete_component_a(self)
  end
  
  def exclusive_method_of_concrete_component_a
    'A'
  end
end

class ConcreteComponentB < Component
  def accept(visitor)
    visitor.visit_concrete_component_b(self)
  end
  
  def exclusive_method_of_concrete_component_b
    'B'
  end
end

module Visitable
  def self.included(_base)
    # receives a Visitor instance and calls 'visit' passing itself in
    # as the class to be visited
    # this can be overwritten to modify funcionality, as long as
    # visitor.visit_classname(self) is called
    def accept(visitor)
      required_method_name = "visit_#{self.class.to_s.downcase}"

      unless visitor.respond_to?(required_method_name)
        raise NotImplementedError, "#{visitor.class} must implement method: '#{required_method_name}'"
      end
      visitor.before! if visitor.respond_to? :before!
      visitor.send(required_method_name, self)
      visitor.after! if visitor.respond_to? :after!
    end
  end
end

class Concrete
  include Visitable
end

class ConcreteVisitor
  def before!
    (13..20).each do |t|
      puts t ** 2
    end
  end
  
  def visit_concrete(element)
    puts "doing some work as #{self.class.to_s} for #{element.class.to_s.upcase}"
  end
  
  def after!
    puts "concrete visited"
  end
end

class ConcreteVisitor1 < Visitor
  def visit_concrete_component_a(element)
    puts "#{element.exclusive_method_of_concrete_component_a} from #{self.class}"
  end
  
  def visit_concrete_component_b(element)
    puts "#{element.exclusive_method_of_concrete_component_b} from #{self.class}"
  end
end

class ConcreteVisitor2 < Visitor
  def visit_concrete_component_a(element)
    puts "#{element.exclusive_method_of_concrete_component_a} from #{self.class}"
  end
  
  def visit_concrete_component_b(element)
    puts "#{element.exclusive_method_of_concrete_component_b} from #{self.class}"
  end
end

def client_code(components, visitor)
  components.each do |component|
    component.accept(visitor)
  end
end

components = Component.subclasses.map(&:new)

puts "\nthe client code works with all visitors via the base Visitor interface:\n\n"
visitor1 = ConcreteVisitor1.new
client_code(components, visitor1)

puts "\nIt allows the same client codee to work with different types of visitors\n\n"
visitor2 = ConcreteVisitor2.new
client_code(components, visitor2)

puts "\nIt allows the same client codee to work with different types of visitors\n\n"
v = ConcreteVisitor.new
client_code([Concrete.new], v)