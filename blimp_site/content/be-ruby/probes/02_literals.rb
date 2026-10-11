# String, number and comment literal facts the helpers depend on.
# Run: ruby 02_literals.rb

def show(label, value) = puts("#{label.ljust(30)} #{value.inspect}")

@ivar = "IVAR"
$gvar = "GVAR"
# `#` interpolates three ways in a double-quoted string, not one.
show '"#{1 + 1}"', "#{1 + 1}"
show '"#@ivar"', "#@ivar"
show '"#$gvar"', "#$gvar"
show '"\#@ivar"', "\#@ivar"
show '"\#{x}"', "\#{x}"
show '"a#b"', "a#b"

# \u{...} takes any code point; \e and \s are escapes too.
show '"\u{1F43B}"', "\u{1F43B}"
show '"\u{0}".bytesize', "\u{0}".bytesize
show '"\s"', "\s"

# Is a string literal frozen in Ruby 4.0 without the magic comment?
lit = "abc"
show "literal frozen?", lit.frozen?
begin
  lit << "d"
  show "literal << \"d\"", lit
rescue FrozenError => e
  show "literal << \"d\"", "FrozenError"
end

# Encoding of literals and what a byte offset index looks like.
s = "κόσμε🐻‍❄️"
show "encoding", s.encoding
show "bytesize", s.bytesize
show "length (code points)", s.length
show "grapheme_clusters", s.grapheme_clusters.length
show "byteslice(0, 2)", s.byteslice(0, 2)
show "getbyte(0)", s.getbyte(0)

# Number literals.
show "1e10", 1e10
show "1.0e10", 1.0e10
show "1e10 class", 1e10.class
show "1_000", 1_000
show "1.0.to_s", 1.0.to_s
show "1e20.to_s", 1e20.to_s
show "1e16.to_s", 1e16.to_s
show "1e15.to_s", 1e15.to_s
show "-0.0", -0.0
show "-0.0 == 0.0", -0.0 == 0.0
show "Float::NAN", Float::NAN
show "Float::INFINITY", Float::INFINITY
show "0.1 + 0.2", 0.1 + 0.2
%w[1. .5 1.e3 0x1F 0b101 1r 2i].each do |src|
  begin
    show src, eval(src)
  rescue SyntaxError, NoMethodError => e
    show src, e.class.name
  end
end
