# Ruby's own float methods against what Temper's Float64 methods mean.
# Run: ruby 13_float_methods.rb
def show(label, value) = puts("#{label.ljust(26)} #{value.inspect}")
def try = yield rescue "#{$!.class}: #{$!.message}"

show "2.5.round", 2.5.round
show "2.5.round.class", 2.5.round.class          # an Integer, so it prints "3", not "3.0"
show "-2.5.round", -2.5.round                     # away from zero; JS and Temper say -2
show "-0.4.round", -0.4.round                     # Integer 0, so the sign of zero is gone
show "1.5.floor", 1.5.floor                       # Integer again
show "Float::NAN.round", try { Float::NAN.round }
show "Math.sqrt(-1.0)", try { Math.sqrt(-1.0) }
show "Math.log(-1.0)", try { Math.log(-1.0) }
show "Math.log(0.0)", Math.log(0.0)
show "Math.acos(2.0)", try { Math.acos(2.0) }
show "[1.0, Float::NAN].min", try { [1.0, Float::NAN].min }
show "[Float::NAN, 1.0].min", try { [Float::NAN, 1.0].min }
show "-0.0.abs", -0.0.abs
show "1e20.to_s", 1e20.to_s
show "1e16.to_s", 1e16.to_s
show "123456789012345680.0.to_s", 123456789012345680.0.to_s
show "0.0001.to_s", 0.0001.to_s
show "0.00001.to_s", 0.00001.to_s
show "-255.to_s(16)", -255.to_s(16)
show "Float::NAN.to_i", try { Float::NAN.to_i }
show "1e10.to_i", 1e10.to_i                       # no width, so no overflow either
