# Which default method a class gets when two of its interfaces' ancestors
# define it: Ruby's answer against Temper's, from Temper's functional test
# classes/call-override-from-subtype. Run: ruby 14_include_order.rb
module ADeep; def a = "A wins!"; end
module B1Deep; include ADeep; def a = "B1 wins!"; end
module B2Deep; include B1Deep; end
module CDeep; include ADeep; end

class DDeep; include B2Deep, CDeep; end     # Temper: B1 wins!
class EDeep; include CDeep, B2Deep; end     # Temper: A wins!
class EDeepOneAtATime; include CDeep; include B2Deep; end

puts "DDeep  #{DDeep.new.a.ljust(10)} #{DDeep.ancestors.take(5).inspect}"
puts "EDeep  #{EDeep.new.a.ljust(10)} #{EDeep.ancestors.take(5).inspect}"
puts "EDeep, one include at a time: #{EDeepOneAtATime.new.a}"

# A forwarder names the winner explicitly, and `...` passes every argument on.
class EDeepFixed
  include CDeep, B2Deep
  def a(...) = ADeep.instance_method(:a).bind_call(self, ...)
end
puts "EDeep with a forwarder: #{EDeepFixed.new.a}"
