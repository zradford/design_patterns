module Mediatable
  attr_accessor :mediator
  
  def initialize
    @mediator = nil
  end
  
  def self.included(base) base.extend(ClassMethods) end
    
  module ClassMethods
    def notify(event)
      @mediators.each { _1.notify self, 'A' }
    end
  end
end

module Observable
  def initialize
    @observers = []
  end

  def attach(observer)
    @observers << observer
  end
  
  def detach(observer)
    @observers.delete observer
  end
  
  def notify_observer
    @observers.each { _1.update_observer(self) }
  end
end

class Observer
  def update_observer(subject)
    puts "#{subject.class} has been observed"
  end
end

class Mediator
  def notify_mediator(sender, event)
    puts "#{sender.class} is performing #{event}"
  end
end

class TestActor
  include Mediatable
  include Observable

  def important_business
    3.times do |i|
      puts; puts 'IMPORTANT BUSINESS' 
      
      @mediator.notify_mediator(self, "~~#{i}~~")
      notify_observer
    end
  end
end


puts "------ begin ------"

actor = TestActor.new

observer = Observer.new
mediator = Mediator.new

actor.mediator = mediator
actor.attach(observer)

actor.important_business


puts; puts "------ end ------"