# Ruby has no labelled break. Two stand-ins for a Temper labelled block, and
# one that looks like a stand-in and is a trap. Run: ruby 12_labels.rb
def show(label, value) = puts("#{label.ljust(46)} #{value.inspect}")

# `loop do` rescues StopIteration, so an exhausted enumerator inside the
# block ends the loop quietly instead of failing.
def with_loop
  e = [1].each
  out = []
  loop do
    out << e.next
    out << e.next   # raises StopIteration...
    out << :unreachable
    break
  end
  out             # ...which loop swallowed
end
show "loop do: StopIteration inside", with_loop

def with_while
  e = [1].each
  while true
    e.next
    e.next
    break
  end
  :not_reached
rescue StopIteration
  :raised
end
show "while true: StopIteration inside", with_while

# A one-shot `while true ... break end` is a labelled block whose label
# is only broken directly. `return` inside it returns from the method.
def early(flag)
  while true
    return "returned" if flag
    break
  end
  "fell through"
end
show "return inside while true", [early(true), early(false)]

# catch/throw crosses inner loops, which `break` cannot, and `return`
# inside a catch block still returns from the method.
def nested
  catch(:outer) do
    [1, 2, 3].each do |a|
      while true
        throw :outer, a if a == 2
        break
      end
    end
    :none
  end
end
show "throw :outer from inside two loops", nested

def return_in_catch = catch(:x) { return :from_method; :caught }
show "return inside catch", return_in_catch

# Cost, roughly: a million direct breaks against a million throws.
t = Process.clock_gettime(Process::CLOCK_MONOTONIC)
1_000_000.times { while true; break; end }
b = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t
t = Process.clock_gettime(Process::CLOCK_MONOTONIC)
1_000_000.times { catch(:l) { throw :l } }
c = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t
show "throw is slower than break by about", "#{(c / b).round}x"
