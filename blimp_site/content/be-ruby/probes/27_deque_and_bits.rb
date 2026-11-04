# frozen_string_literal: true

# Is Array#shift cheap enough to be a deque's removeFirst, and what should
# hold a bit vector's bits?
require "benchmark"

def secs(&blk) = Benchmark.realtime(&blk).round(3)

[100_000, 1_000_000].each do |n|
  a = []
  t = secs do
    n.times { |i| a.push(i) }
    n.times { a.shift }
  end
  puts format("%-46s %s", "push #{n}, then shift #{n}, seconds", t)
  a = []
  t = secs do
    n.times do |i|
      a.push(i)
      a.push(i)
      a.shift
    end
  end
  puts format("%-46s %s", "interleaved, #{n} rounds, seconds", t)
end
puts format("%-46s %s", "[].shift", [].shift.inspect)

n = 1_000_000
bools = Array.new(n, false)
bytes = "\0".b * (n / 8)
big = 0
puts format("%-46s %s", "set #{n} bits, Array of booleans, seconds", secs { n.times { |i| bools[i] = i.odd? } })
puts format("%-46s %s", "set #{n} bits, binary String, seconds", secs {
  n.times { |i| bytes.setbyte(i >> 3, i.odd? ? bytes.getbyte(i >> 3) | (1 << (i & 7)) : bytes.getbyte(i >> 3) & ~(1 << (i & 7))) }
})
puts format("%-46s %s", "set 20000 bits, Integer (immutable), seconds", secs { 20_000.times { |i| big |= (1 << i) if i.odd? } })
puts format("%-46s %s", "Integer bit 5 of 0b100000", 0b100000[5])
