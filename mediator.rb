

# The Mediator interface declares a method used by components to notify the mediator about various events.
# The Mediator may react to these events and pass the execution to other components

# mediator pattern lets you have one object (the mediator) control the flow of actions between groups of 'related' components
class Mediator
  def notify(_sender, _event)
    raise NotImplementedError, "#{self.class} has not implemented method'#{__method__}'"
  end
end

class AnonymousMediator < Mediator
  def initialize(*args)
    @components = *args
    @components.each { _1.mediators << self }
  end
  
  def notify(sender, event)
    @components.each do |component|
      if component.respond_to?(:call) && event == 'A'
        component.call
      end
    end
  end
end

class ConcreteMediator < Mediator
  def initialize(component1, component2)
    @component1 = component1
    @component1.mediators << self
    
    @component2 = component2
    @component2.mediators << self 
  end
  
  def notify(_sender, event)
    if event == 'A'
      puts 'Mediator reacts on A and triggers the following operations:'
      @component2.do_c
    elsif event == 'D'
      puts 'Mediator reacts on D and triggers the following operations:'
      @component1.do_b
      @component2.do_c
    end
  end
end


# the Base Component just provides the basic functionality of storing a mediator's instance inside component objects
class BaseComponent
  attr_accessor :mediators
  
  def initialize
    @mediators = []
  end
end

class Component1 < BaseComponent
  def call
    puts "#{self.class} has been called"
  end
  
  def do_a
    puts 'Component 1 does A'
    @mediators.each { _1.notify self, 'A' }
  end
  
  def do_b
    puts 'Component 1 does B'
    @mediators.each { _1.notify self, 'B' }
  end
end

class Component2 < BaseComponent
  def do_c
    puts 'Component 2 does C'
    @mediators.each { _1.notify self, 'C' }
  end
  
  def do_d
    puts 'Component 2 does D'
    @mediators.each { _1.notify self, 'D' }
  end
end

class ALogger < BaseComponent
  def call
    puts 'A Event Logged'
    @mediators.each { _1.notify self, 'Log' }
  end
end

# Client code:
c1 = Component1.new
c2 = Component2.new
a_logger = ALogger.new
ConcreteMediator.new(c1, c2)
AnonymousMediator.new(c1, c2, a_logger)

puts 'Client triggers operation A.'
c1.do_a

puts;

puts 'Client triggers operation D.'
c2.do_d
