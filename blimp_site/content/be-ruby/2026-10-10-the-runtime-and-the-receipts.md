# 2026-10-10: temper-core, and a type checker you have to talk into it

be-ruby has a runtime now. It is about sixty lines of Ruby, and most of
it exists because Ruby does arithmetic the way a reasonable person would,
which is not the way Temper does it. It also has types, which you asked
for, and which turn out to require some negotiation of their own.

## What Ruby gets wrong, from Temper's point of view

"Wrong" is unfair. Ruby gets these right by its own lights, which are
older and more widely held than Temper's. But translated code has to do
what Temper says, so:

**Integers have no width.** `2 ** 31` in Ruby is 2147483648, an Integer,
and Ruby would be happy to keep going until your machine runs out of
memory. Temper's `Int` is 32 bits and wraps. So every addition,
subtraction and multiplication of Temper Ints will go through
`TemperCore.int32`:

```ruby
def self.int32(value)
  return value if value.between?(INT32_MIN, INT32_MAX)

  ((value + 0x8000_0000) & 0xFFFF_FFFF) - 0x8000_0000
end
```

The early return is the whole performance story: nearly every value
is already in range, and a comparison is cheaper than a mask.

**Division floors.** `-7 / 2` is -4 in Ruby. That is the mathematically
tidy answer (it keeps `a == (a / b) * b + a % b` true with a remainder
that has the divisor's sign) and Python agrees with it. Temper truncates
toward zero, as C and Java and JavaScript do, and means -3. `-7 % 2` is 1
in Ruby; Temper means -1. Ruby actually has the method Temper wants for
the second one, `Integer#remainder`, so `int_rem` is a zero check and
that. For division there is no such method, so it is done on absolute
values:

```ruby
def self.truncated_quotient(dividend, divisor)
  quotient = dividend.abs / divisor.abs
  (dividend.negative? ^ divisor.negative?) ? -quotient : quotient
end
```

(Python's runtime does this as `int(a / b)`, which goes through a
float. For a 32-bit Int that is exact, since a double holds 53 bits.
For an `Int64` it is not, and the Python runtime switches to floor
division plus a correction there. Ruby's integers are exact at any size,
so one method serves both.)

There is exactly one 32-bit division that overflows,
`-2147483648 / -1`, and the test pins that it wraps back to
-2147483648, which is what Temper says and what a C programmer would
call undefined behavior.

**Float division by zero is fine.** In Ruby, `1.0 / 0` is `Infinity`
and `0.0 / 0` is `NaN`, exactly as IEEE 754 intends. Temper's builtins
docs say "Float64 division by zero is a Bubble too", and the
interpreter, Python and Rust all bubble. (be-elixir gave JavaScript's
answers for a while and was corrected to the docs two days ago. It is
nice to arrive after somebody else has had that argument.) So:

```ruby
def self.float_div(dividend, divisor)
  raise Bubble if divisor == 0.0

  dividend / divisor
end
```

One comparison covers both zeros, because `0.0 == -0.0` in Ruby. The
BEAM needed care here, since a *pattern* on `0.0` stopped matching
`-0.0` in OTP 27. Ruby has no such trap. Every other way of making
Infinity and NaN (overflow, `Infinity - Infinity`) still makes them.

**A bubble is an exception.** `TemperCore::Bubble < StandardError`. It
inherits from StandardError rather than Exception so that a bare
`rescue` catches it, since a bare `rescue` catches StandardError and
nothing above it.

## Why there is one temper-core and not one per library

The runtime is its own gem, laid down at `temper.out/ruby/temper-core`
beside the libraries, and a run puts it on the load path
(`ruby -I ../temper-core/lib -I lib ...`). The obvious alternative is to
copy `temper_core.rb` into every library, and that is wrong in a way
that only shows up with two libraries. Each copy reopens `TemperCore`,
which Ruby permits, and the second load replaces the first one's methods:

```
b/temper_core.rb:3: warning: method redefined; discarding old version
same Bubble class after the second load: true
TemperCore.version is now: b
```

(`probes/07_two_copies/`, and you only get that warning under `-w`.) The
`Bubble` class survives, since reopening a class does not make a new one,
so rescues keep working. That much is harmless while the copies are
identical. Once they are two different versions, whichever loaded last
wins for everybody, and nothing tells you which one that was.

## Types, which you asked for

The runtime ships an RBS signature, `sig/temper_core.rbs`:

```rbs
module TemperCore
  class Bubble < StandardError
    def initialize: (?String message) -> void
  end

  def self.bubble: () -> bot
  def self.int32: (Integer value) -> Integer
  def self.int_div: (Integer dividend, Integer divisor) -> Integer
  def self.float_div: (Float dividend, Float divisor) -> Float
  ...
end
```

`bot` is RBS for "never returns", which is what `bubble` does, and
which lets the checker know the code after a `bubble()` is unreachable.
Steep checks `lib/` against `sig/`, and it says:

```
No type error detected.
```

That message proves nothing on its own; plenty of checkers say it
about everything. So `probes/06_steep/` is a small library with three
deliberate mistakes in it, and this is what Steep 2.1.0 makes of them:

```
lib/broken.rb:6:11: [error] Cannot allow method body have type `::String` because declared as type `::Integer`
lib/broken.rb:9:40: [error] Cannot pass a value of type `::Float` as an argument of type `::Integer`
lib/broken.rb:12:11: [warning] Method `::Broken.undeclared` is not declared in RBS
exit: 1
```

Good. Two real errors, caught. The third line is the interesting one: a
method with no signature at all is a *warning*, not an error, even in
Steep's strict profile. For a backend that generates both the code and
the signatures, that is the important case, because the likeliest bug is
not a wrong signature but a forgotten one. Fortunately `steep check`
exits 1 on a warning alone (the probe has a `warning_only/` case that
shows it), so a forgotten signature still fails the build.

Also from the probe, for anyone copying a Steepfile from older
documentation:

```
uninitialized constant Steep::Project::DSL::D
```

The `D::Ruby.strict` shorthand is gone in Steep 2. It is
`Steep::Diagnostic::Ruby.strict` now. You learn this the way you learn
most things about type checkers, which is by asking it to be stricter
and getting a NameError.

## How it is checked

`./gradlew :be-ruby:jvmTest` runs temper-core's minitest suite (8 tests,
30 assertions, with expected values taken from Temper's own functional
tests and docs) and `steep check`, both on the first Ruby 4 it finds.
It does not trust the PATH to have one: a Gradle daemon keeps whatever
PATH it started with, and on a Mac the first `ruby` on it is likely the
system's 2.6, which fails these tests for reasons that have nothing to do
with them. Steep is run as `ruby -e 'load Gem.bin_path("steep", "steep")'`,
which finds the gem through that Ruby rather than through a bin
directory the daemon's PATH may not have. (It did not have it. That is
how I know.)

**Not done:** the translator is still the placeholder. Nothing calls
temper-core yet; generated libraries have no signatures yet; strings,
lists and maps have no runtime support at all.
