# How names are scoped, which decides what a Temper module, function and
# closure become. Run: ruby 03_scope.rb

def show(label, value) = puts("#{label.ljust(36)} #{value.inspect}")

show "1.0E10 (Kotlin's spelling)", 1.0E10

# `def` is a scope gate: a method cannot see the locals around it.
counter = 0
def sees_counter = defined?(counter) ? "sees it" : "does not"
show "def sees outer local?", sees_counter

# A lambda can, and assigns to the outer variable rather than shadowing it.
bump = -> { counter += 1 }
bump.(); bump.call
show "lambda bumped outer local", counter

# Module state: inside `module M`, self is M, so @x is M's own ivar, and a
# `def self.f` sees it too.
module M
  @calls = 0
  def self.tick = @calls += 1
  tick; tick
  def self.calls = @calls
end
show "module ivar via def self.", M.calls

# return inside a lambda returns from the lambda; inside a proc it returns
# from the enclosing method.
def lambda_return = [1, 2, 3].map(&->(x) { return x * 10 })
show "return in lambda", lambda_return
def proc_return = [1, 2, 3].each { |x| return x * 10 }
show "return in block", proc_return

# A lambda checks its arity; a proc does not.
begin
  ->(a, b) { a }.(1)
rescue ArgumentError => e
  show "lambda arity", e.message
end

# while/break/next work, but there are no labels: break leaves one loop.
i = 0
out = []
while i < 3
  j = 0
  while true
    break if j == 2
    out << [i, j]
    j += 1
  end
  i += 1
end
show "nested while", out.length

# catch/throw is Ruby's non-local exit, and it is not an exception.
r = catch(:outer) do
  3.times { |a| 3.times { |b| throw :outer, [a, b] if a + b == 3 } }
  :never
end
show "catch/throw", r

# A while loop is an expression whose value is nil, and creates no scope:
# a variable first assigned inside one is visible after it.
while (k = 1) && false; end
show "var from while cond after loop", k

# Classes: == is identity unless defined; instance_variable_get reaches in.
class P; def initialize(x) = @x = x; attr_reader :x; end
show "P.new(1) == P.new(1)", P.new(1) == P.new(1)
show "P.new(1).x", P.new(1).x
show "P.new(1).frozen?", P.new(1).frozen?

# Struct-like immutable values: Data.define (3.2+).
Pt = Data.define(:x, :y)
show "Data == by value", Pt.new(x: 1, y: 2) == Pt.new(1, 2)
show "Data frozen?", Pt.new(1, 2).frozen?
