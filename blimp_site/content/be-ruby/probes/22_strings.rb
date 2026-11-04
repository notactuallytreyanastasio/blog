# frozen_string_literal: true

# Ruby strings against Temper's: indices, code points, splitting, parsing.
def show(label, &blk)
  value = begin
    blk.call.inspect
  rescue => e
    "#{e.class}: #{e.message}"
  end
  puts format("%-46s %s", label, value)
end

s = "añ🌍b"
show("s.length, s.bytesize") { [s.length, s.bytesize] }
show("s.bytes") { s.bytes.map { _1.to_s(16) } }
show("s.byteslice(1, 4).unpack1(\"U\")  (ñ)") { s.byteslice(1, 4).unpack1("U").to_s(16) }
show("s.byteslice(2, 4).unpack1(\"U\")  (mid-char)") { s.byteslice(2, 4).unpack1("U") }
show("s.byteslice(3, 4).unpack1(\"U\")  (🌍)") { s.byteslice(3, 4).unpack1("U").to_s(16) }
show("s.byteindex(\"b\")") { s.byteindex("b") }
show("s.byteindex(\"b\", 2)  (mid-char start)") { s.byteindex("b", 2) }
show("s.byteindex(\"z\")") { s.byteindex("z") }
show("s.byteslice(1, 6)") { s.byteslice(1, 6) }
show("s.byteslice(9, 1)  (past the end)") { s.byteslice(9, 1) }
show("s.byteslice(8, 1)  (at the end)") { s.byteslice(8, 1) }

# Code points to strings
show("[0x1F30D].pack(\"U\")") { [0x1F30D].pack("U") }
show("[0xD800].pack(\"U\")  (surrogate)") { [0xD800].pack("U") }
show("[0x110000].pack(\"U\")") { [0x110000].pack("U") }
show("0xD800.chr(Encoding::UTF_8)") { 0xD800.chr(Encoding::UTF_8) }
show("(+\"\") << 0xD800") { (+"") << 0xD800 }
show("(+\"\") << 0x1F30D") { (+"") << 0x1F30D }
show("String.new.encoding") { String.new.encoding }
show("(+\"\").encoding") { (+"").encoding }
show("String.new << \"ñ\"; encoding") { b = String.new; b << "ñ"; b.encoding }

# Splitting
show("\" g  h i\".split(\" \", -1)") { " g  h i".split(" ", -1) }
show("\"a,b,,\".split(\",\", -1)") { "a,b,,".split(",", -1) }
show("\"\".split(\",\", -1)") { "".split(",", -1) }
show("\"def\".split(\"\", -1)") { "def".split("", -1) }
show("\"🌍\".split(\"\")") { "🌍".split("") }

# Parsing
show("Integer(\"1_000\")") { Integer("1_000") }
show("\"1_000\".to_i") { "1_000".to_i }
show("\"12abc\".to_i") { "12abc".to_i }
show("Integer(\"0x1A\", 16)") { Integer("0x1A", 16) }
show("Float(\"1_0.5\")") { Float("1_0.5") }
show("Float(\".5\")") { Float(".5") }
show("Float(\"Infinity\")") { Float("Infinity") }
show("Float(\"1e400\")") { Float("1e400") }

# Iterating code points
show("\"a🌍\".each_codepoint.to_a") { "a🌍".each_codepoint.to_a }
show("\"a🌍\".each_codepoint { }  (returns)") { "a🌍".each_codepoint { } }

# Character indexing cost: s[i] near the end of a long string, ASCII vs not.
require "benchmark"
ascii = "a" * 1_000_000
multi = "é" * 1_000_000
reps = 200
show("ascii s[999_999] x#{reps}, seconds") { Benchmark.realtime { reps.times { ascii[999_999] } }.round(4) }
show("é s[999_999] x#{reps}, seconds") { Benchmark.realtime { reps.times { multi[999_999] } }.round(4) }
show("é s.byteslice(1_999_998, 2) x#{reps}, seconds") { Benchmark.realtime { reps.times { multi.byteslice(1_999_998, 2) } }.round(4) }
