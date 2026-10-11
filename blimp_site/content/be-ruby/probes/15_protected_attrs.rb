# A private Temper property is read as `other.backing` inside its class's
# methods, so its reader must be callable on another instance there and
# not from outside: Ruby's `protected`. Does a bare `protected()` make the
# attr_reader after it protected? Run: ruby 15_protected_attrs.rb
class Foo
  def initialize(backing) = @backing = backing
  def same?(other) = other.backing == backing
  protected()
  attr_reader(:backing)
end
a = Foo.new(1)
puts "other.backing inside the class: #{a.same?(Foo.new(1))}"
begin
  a.backing
  puts "a.backing outside: allowed"
rescue NoMethodError => e
  puts "a.backing outside: #{e.message[/protected method '[^']+'/]}"
end
