# Ruby's float equality, ordering and power, against what Temper says:
# NaN == NaN, 0.0 != -0.0, NaN sorts above everything, -0.0 below 0.0,
# and a negative base to a fractional power is NaN.
# Run: ruby 11_floats.rb
def show(label, value) = puts("#{label.ljust(30)} #{value.inspect}")
nan = Float::NAN
show "NaN == NaN", nan == nan
show "NaN.eql?(NaN)", nan.eql?(nan)
show "0.0 == -0.0", 0.0 == -0.0
show "0.0.eql?(-0.0)", 0.0.eql?(-0.0)
show "0.0.equal?(-0.0)", 0.0.equal?(-0.0)
show "NaN <=> 1.0", nan <=> 1.0
show "-0.0 <=> 0.0", -0.0 <=> 0.0
show "(-8.0) ** (1.0 / 3)", (-8.0) ** (1.0 / 3)
show "(-8.0) ** 2.0", (-8.0) ** 2.0
show "0.0 ** -1.0", 0.0 ** -1.0
show "(-0.0) ** -1.0", (-0.0) ** -1.0
show "2.0 ** 1024.0", 2.0 ** 1024.0
show "true <=> false", true <=> false
show "\"a\" <=> \"b\"", "a" <=> "b"
show "\"é\" <=> \"z\" (bytes)", "é" <=> "z"
