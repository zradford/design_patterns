
# Interface to declare set of methods for managing subscriber
class Subject
  def attach(observer)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
  
  def detach(observer)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
  
  def notify
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

# The Observer interface declares the Update method used by subjects
class Observer
  def update(_subject)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
  
  def class_name
    self.class.to_s[-1]
  end
end

# The Subject owns some important state and notifies observers when the state changes
class ConcreteSubject < Subject
  # this is a simplified form of reality
  attr_accessor :state
  
  # List of subscribers. In real life, the list of subscribers can be stored
  # more comprehensively (categorized by event type, etc.).
  def initialize
    @observers = []
  end
  
  def attach(observer)
    puts "Subject: Attached an observer of type: #{observer.class_name}"
    @observers << observer
  end
  
  def detach(observer)
    puts; puts "Subject: Removing observer of type: #{observer.class_name}"
    @observers.delete observer
  end
  
  def notify
    puts 'Subject: Notifying observers...'
    @observers.each { _1.update(self) }
  end
  
  # Usually, the subscription logic is only a fraction of what a Subject can really do.
  # Subjects commonly hold some important business logic, that triggers
  #   a notification method whenever something important is about to happen (or after it).
  def some_business_logic
    puts; puts "Subject: I'm doing something important."
    @state = rand 0..10
    
    puts "Subject: My state has just changed to: #{@state}"
    notify
  end
end

class ConcreteObserverA < Observer
  def update(subject)
    puts 'ConcreteObserverA: Reacted to the event' if subject.state < 3
  end
end

class ConcreteObserverB < Observer
  def update(subject)
    return unless subject.state.zero? || subject.state >= 2

    puts 'ConcreteObserverB: Reacted to the event'
  end
end

class ConcreteObserverC < Observer
  def update(subject)
    puts 'ConcreteObserverC: Reacted to the event' if subject.state > 6
  end
end


# client code

subject = ConcreteSubject.new

observer_a = ConcreteObserverA.new
subject.attach(observer_a)

observer_b = ConcreteObserverB.new
subject.attach(observer_b)

observer_c = ConcreteObserverC.new
subject.attach(observer_c)

5.times { subject.some_business_logic }

subject.detach(observer_a)
subject.detach(observer_c)

3.times { subject.some_business_logic }
