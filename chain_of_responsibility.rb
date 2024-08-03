require 'retest'
require 'debug'

class Handler
  def next_handler=(handler)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def handle(request)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end


class AbstractHandler < Handler
  attr_writer :next_handler

  def next_handler(handler)
    @next_handler = handler
    # Returning a handler from here will let us link handlers in a convenient way like this:
    # monkey.next_handler(squirrel).next_handler(dog)
    handler
  end

  def handle(request)
		return @next_handler.handle(request) if @next_handler

    nil
  end
	
	def unhandled? = @status.nil?

	def handled? = !unhandled?
		
	def handled! = @status = "Handled"

	def self.priority(number)
		raise ArgumentError, "Number must be Numeric" unless number.is_a? Numeric
		
		define_method :priority do number end 
	end
end

class MonkeyHandler < AbstractHandler
	priority 20

  def handle(request)
    if request == 'Banana'
      "Monkey: I'll eat the #{request}"
    else
      super(request)
    end
  end
end

class SquirrelHandler < AbstractHandler
	priority 20
	
  def handle(request)
    if request == 'Nut'
      "Squirrel: I'll eat the #{request}"
    else
      super(request)
    end
  end
end

class DogHandler < AbstractHandler
	priority 20

  def handle(request)
    if request == 'MeatBall'
      "Dog: I'll eat the #{request}"
    else
      super(request)
    end
  end
end

class AHandler < AbstractHandler
	priority 0
	
	def handle(request)
		request.tr! 'a', ''
		super(request)
	end
end
class BHandler < AbstractHandler
	priority 3

	def handle(request)
		request.tr! 'b', ''
		super(request)
	end
end
class CHandler < AbstractHandler
	priority 2

	def handle(request)
		request.tr! 'c', ''
		super(request)
	end
end
class DHandler < AbstractHandler
	priority 0

	def handle(request)
		request.tr! 'd', ''
		super(request)
	end
end
class EHandler < AbstractHandler
	priority -99

	def handle(request)
		request.tr! 'e', ''
		super(request)
	end
end

# TODO: add logging, who did what and when
# if this was a production process that took in a request
# and modified it, it would be a nightmare to debug
class HandlerHandler
	def self.handle(*handlers, request:)
		handlers = sorted(handlers)
		handlers.each do |handler|
			puts request
			handler.handle(request) unless handler.handled?
			handler.handled!
		end
	end

	private

	def self.sorted(handlers)
		handlers.sort_by { |h| h.priority }
	end
end



# The client code is usually suited to work with a single handler. In most
# cases, it is not even aware that the handler is part of a chain.
# def client_code(handler)
#   ['Nut', 'Banana', 'Cup of coffee'].each do |food|
#     puts "\nClient: Who wants a #{food}?"
#     result = handler.handle(food)
#     if result
#       print "  #{result}"
#     else
#       print "  #{food} was left untouched."
#     end
#   end
# end
def client_code(handler)
	my_string = 'abcd'
	puts my_string
	handler.handle(my_string)
	puts my_string
end

handlers = AbstractHandler.subclasses.map(&:new)

HandlerHandler.handle(*handlers,
											request: "abcdefg")
# monkey = MonkeyHandler.new
# squirrel = SquirrelHandler.new
# dog = DogHandler.new


# monkey.next_handler(squirrel).next_handler(dog)
# dog.next_handler(squirrel)
# 	 .next_handler(monkey)

# # The client should be able to send a request to any handler, not just the first
# # one in the chain.
# puts 'Chain: Monkey > Squirrel > Dog'
# client_code(monkey)
# puts "\n\n"

# puts 'Subchain: Squirrel > Dog'
# client_code(squirrel)