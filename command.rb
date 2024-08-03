require 'retest'
require 'debug'

class Command
  def execute
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
  
  def skip?
    false
  end
end

class SimpleCommand < Command
  def initialize(payload)
    @payload = payload
  end

  def execute
    puts "SimpleCommand: See, I can do simple things like printing (#{@payload})"
  end
  
  def skip?
    @payload == 'skip me'
  end
end

class ComplexCommand < Command
  def initialize(receiver, a, b)
    @receiver = receiver
    @a = a
    @b = b
  end

  def execute
    print 'ComplexCommand: Complex stuff should be done by a receiver object'
    @receiver.do_something(@a)
    @receiver.do_something_else(@b)
  end
end

class NilCommand < Command
  def execute
  end
end

# The Receiver classes contain some important business logic. They know how to
# perform all kinds of operations, associated with carrying out a request. In
# fact, any class may serve as a Receiver.
class Receiver
  def do_something(a)
    print "\nReceiver: Working on (#{a}.)"
  end

  def do_something_else(b)
    print "\nReceiver: Also working on (#{b}.)"
  end
end

class Invoker
  def initialize(*args, **_args)
    @on_start = NilCommand.new
    @on_finish = NilCommand.new
  end

  def on_start=(command)
    @on_start = command
  end

  def on_finish=(command)
    @on_finish = command
  end
  
  def list=(commands = [])
    @commands = commands
  end
  
  def invoke!
    return 'No Commands to run?' if @commands.nil?

    @on_start.execute
    @commands.each do |command|
      command.execute unless command.skip?
    end
    @on_finish.execute
  end

  # The Invoker does not depend on concrete command or receiver classes. The
  # Invoker passes a request to a receiver indirectly, by executing a command.
  def do_something_important
    puts 'Invoker: Does anybody want something done before I begin?'
    @on_start.execute

    puts 'Invoker: ...doing something really important...'

    puts 'Invoker: Does anybody want something done after I finish?'
    @on_finish.execute
  end
end

class ImportantService
  def self.call!
    invoker = Invoker.new
    invoker.on_start = SimpleCommand.new('Say Hi!')
    receiver = Receiver.new
    invoker.on_finish = ComplexCommand.new(receiver, 'Send email', 'Save report')

    invoker.do_something_important
  end
end

ImportantService.call!

puts "\n\n"

class LongService
  def initialize(*commands, invoker: Invoker.new)
    @invoker = invoker
    @invoker.list = commands
  end

  def call!
    @invoker.invoke!
  end
end

LongService.new(SimpleCommand.new('test,123'),
                SimpleCommand.new('skip me'),
                SimpleCommand.new('test,abc')).call!

puts "\n______________________________________________________________________\n"

class Character
  class ValidateCommand < Command; end
  class ExportCommand < Command; end
  class Invoker < Invoker
    def initialize(character:)
      super
      @character = @character
    end
    
    def do_something_important
      puts @character
    end
  end
end

class StatefulService
  def initialize(character, invoker: Character::Invoker)
    @character = character
    @invoker = invoker.new(character: @character)
    @invoker.on_start = Character::ValidateCommand.new 
    @invoker.on_finish = Character::ExportCommand.new 
  end
end

StatefulService.new("hello")