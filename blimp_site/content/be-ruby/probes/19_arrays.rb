# frozen_string_literal: true

# Where a Ruby Array is not a Temper List or ListBuilder.
def show(label, &blk)
  value = begin
    blk.call.inspect
  rescue => e
    "#{e.class}: #{e.message}"
  end
  puts format("%-44s %s", label, value)
end

a = [10, 20, 30]
show("a[-1]  (Temper: panic)") { a[-1] }
show("a[3]   (Temper: panic)") { a[3] }
show("a.fetch(-1)") { a.fetch(-1) }
show("a.fetch(3)") { a.fetch(3) }
show("b = a.dup; b[5] = 1; b  (Temper: panic)") { b = a.dup; b[5] = 1; b }
show("[].pop  (Temper: panic)") { [].pop }
show("a.insert(5, 1)  (Temper: panic)") { a.dup.insert(5, 1) }
show("a.insert(-1, 1)  (Temper: panic)") { a.dup.insert(-1, 1) }
show("a[1...-1]  (slice with a negative end)") { a[1...-1] }
show("a[5...6]") { a[5...6] }
show("a[3...6]") { a[3...6] }
show("[[1, 2], 3].join(\",\")") { [[1, 2], 3].join(",") }

# Stability: sort on the first letter only. A stable sort keeps the b's in
# their original order. Ruby's sort is a quicksort; small inputs fall to an
# insertion sort, which happens to be stable, so try a few sizes.
[8, 40, 100, 1000].each do |n|
  words = (0...n).map { |i| "#{%w[b a c][i % 3]}#{i}" }
  bs = words.select { _1.start_with?("b") }
  show("sort stable for #{n} items") { words.sort { |x, y| x[0] <=> y[0] }.select { _1.start_with?("b") } == bs }
  show("sort_by stable for #{n} items") { words.sort_by { _1[0] }.select { _1.start_with?("b") } == bs }
end

# Lambdas handed to block methods with &
twice = ->(x) { x * 2 }
add = ->(x, y) { x + y }
show("a.map(&twice)") { a.map(&twice) }
show("a.inject(&add)") { a.inject(&add) }
show("a.each_with_index.map(&twice)  (2 yielded)") { a.each_with_index.map(&twice) }
show("[].inject(&add)  (Temper reduce: panic)") { [].inject(&add) }

# Frozen arrays
f = [1, 2].freeze
show("f << 3") { f << 3 }
show("f.dup.frozen?") { f.dup.frozen? }
show("f.map { _1 }.frozen?") { f.map { _1 }.frozen? }
