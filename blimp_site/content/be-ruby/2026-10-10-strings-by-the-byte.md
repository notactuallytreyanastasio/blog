# 2026-10-10: strings, by the byte

Forty-six of sixty-six, up from thirty-four. Last entry's guard, the one
that stops the build on any Temper builtin without a Ruby mapping, had
already written the shopping list: `split`, `isEmpty`, `toInt32`,
`toFloat64`, string indices, StringBuilder. This entry is that list, plus
one Steep bug, plus a test I wrote myself to check whether the suite
going green means anything.

## What a string index is

Temper does not let you index a string by integer. You get a
`StringIndex`, which you can only obtain from the string (`String.begin`,
`s.end`, `s.next(i)`, `s.indexOf(...)`), and each backend picks what it
really is. That is a nice piece of design, and it exists because
languages disagree about what a character is. JavaScript counts UTF-16
code units, Python counts code points, and Ruby, like Go and Rust,
stores UTF-8.

Ruby will happily index by character, `s[i]`, and on an ASCII string
that is instant. On anything else it is a scan from the start:

```
ascii s[999_999] x200, seconds                 0.0
é s[999_999] x200, seconds                     0.0301
é s.byteslice(1_999_998, 2) x200, seconds      0.0
```

(`probes/22_strings.rb`.) That is 150 microseconds per character on a
million-character string. A loop that walks a string with `next` would
be quadratic, and you would find out in production, from a user with a
long string and an accent. So a StringIndex is a **byte offset**:
`String.begin` is `0`, `s.end` is `s.bytesize`, and `StringIndex.none`
is `-1`, which conveniently sorts before every real index, as Temper
requires. `next` reads the lead byte to learn how long the character is.
`prev` steps back over continuation bytes, which all look like
`0b10xxxxxx`. Here is a loop from my test program, as generated:

```ruby
def self.walk(s)
  i = 0
  out = +""
  while TemperCore.string_has_index(s, i)
    out << TemperCore.int_to_string(TemperCore.string_get(s, i), 16)
    out << " "
    i = TemperCore.string_next(s, i)
  end
  back = s.bytesize
  n = 0
  while back > 0
    back = TemperCore.string_prev(s, back)
```

`while back > 0` is a StringIndex comparison. The frontend writes it as
`compareTo(...) > 0`, and since an index is just an Integer, the backend
turns it back into `>`.

## A StringBuilder is a String you are allowed to change

Ruby strings are mutable unless frozen, and with `# frozen_string_literal:
true` at the top of every file, every literal is frozen. So a
StringBuilder is an unfrozen String, `append` is `<<`, and the
constructor is `+""`, which is Ruby for "a thawed copy of this literal".
It is not `String.new`, the more obvious spelling:

```
String.new.encoding                            #<Encoding:BINARY (ASCII-8BIT)>
(+"").encoding                                 #<Encoding:UTF-8>
```

An empty `String.new` is binary, not UTF-8. Appending UTF-8 to it does
switch it over, so you could get away with it most of the time. But the
whole point of this exercise is to avoid "most of the time".

## Code points: Ruby will encode anything

`String.fromCodePoint` must bubble for a surrogate or anything past
0x10FFFF, because those are not Unicode scalar values. The idiomatic
Ruby way to turn a code point into a string encodes them anyway:

```
[0xD800].pack("U")  (surrogate)                "\xED\xA0\x80"
[0x110000].pack("U")                           "\xF4\x90\x80\x80"
0xD800.chr(Encoding::UTF_8)                    RangeError: invalid codepoint 0xD800 in UTF-8
```

That `pack` output is invalid UTF-8, a string that will blow up later,
somewhere else, in someone else's code. temper-core checks the range
itself and then uses `chr`, which would have refused anyway.

## Parsing numbers: everyone is lenient differently

Temper's `toInt32` takes "integer JSON format, plus any radix 2 through
36" and bubbles on anything else. Ruby has three ways to parse an
integer, and all of them say yes to things Temper says no to:

```
Integer("1_000")                               1000
"1_000".to_i                                   1000
"12abc".to_i                                   12
Integer("0x1A", 16)                            26
Float("1_0.5")                                 10.5
Float(".5")                                    0.5
Float("Infinity")                              ArgumentError: invalid value for Float(): "Infinity"
```

Underscores are Ruby's digit separators, which is lovely in source code
and alarming in a parser fed user input. `to_i` takes as much of a number
as it can find and ignores the rest. And `Float` rejects "Infinity",
which Temper accepts. So temper-core matches the syntax with a regular
expression first and only then hands the digits to Ruby.

## split, properly this time

Last entry found that Temper's `split` had been running as Ruby's.
Ruby's has no mode that is Temper's: `" "` means any run of whitespace
even with `-1`, `"".split(",", -1)` is `[]` where Temper wants `[""]`,
and `"def".split("", -1)` adds a trailing `""`. So temper-core writes it
out with `byteindex`, and `TypesListOperations` passes.

## Steep splats a lambda's Array

The other new failure was a type error in code that ran correctly. A
module function taking an `Array[String]`, used as a value, became

```ruby
FN_11 = ->(a) do
  fn_11(a)
end
```

declared `FN_11: ^(Array[String]) -> Array[String]`, and Steep said:

```
Cannot pass a value of type `(::String | nil)` as an argument of type `::Array[::String]`
```

`String | nil` is what you get from *splatting* the array, unpacking it
into its elements. Ruby does that for a block written `|a, b|` or `|a,|`.
It does not do it for a single `|a|`, which gets the whole array, and a
lambda never splats at all. Ruby agrees with itself:

```
[2, 2, 2, 2, 2, 2, 2]
lib/s.rb:4:10: [error] Cannot pass a value of type `(::String | nil)` as an argument of type `::Array[::String]`
lib/s.rb:8:4: [error] Type annotation about `a` is incompatible since (::String | nil) <: ::Array[::String] doesn't hold
```

(`probes/23_steep_lambda_splat/`.) The numbers are seven spellings of
the lambda, each counting both elements at runtime. The errors are Steep
insisting the first two would get one element. Steep 2.1 splats `->(a)`'s single parameter, which is a rule
Ruby does not have even for blocks, and it does so only for that
spelling: `lambda do |a|`, `_1` and `it` all type correctly. The probe
also checks that "correctly" means the parameter really is
`Array[String]` and not a silent `untyped`, by passing it somewhere it
does not fit and getting the error. A `@type var` annotation cannot
override it, either. So every lambda the backend writes is now `lambda do
|a, b| ... end`, which Ruby treats identically, and which no Array can
trip.

This is the third time a Steep limitation has shaped the output, after
`return` in a lambda and inference through generic methods. I keep the
probe for each, so when Steep fixes one, the workaround can go.

## nil means "the default", again

`float_near` crashed on `nil * 1e-9`. Temper passes `null` for an
optional argument the caller left out, and the backend's support
functions receive it as `nil`. This happened with `splice` last entry. So
it is a rule now, not a bug: every temper-core function with an optional
parameter treats nil as its default.

Also: the unsigned 64-bit shift used to mask with `2 ** 64 - 1`, which
RBS types as Numeric, because `Integer#**` with a negative exponent
returns a Rational. It is `(1 << 64) - 1` now, which is just an Integer.

## A test the suite did not write

Forty-six green tests are evidence. They are not proof, because they are
the tests every backend is tuned against. So I wrote a fresh program of
about sixty lines, all string edge cases: splitting on separators at the
ends, walking "κόσμε𐆊" forwards and back, `indexOf` with empty needles,
twenty-odd number parses, a builder, and sorting accented words. Then I
ran it on the JavaScript, Python and Ruby backends and diffed the
results (`probes/24_fresh_strings/`). Ruby disagreed with JavaScript on
exactly one line of forty-two:

```
< toInt32 0x10 radix 16: [16]
---
> toInt32 0x10 radix 16: [bubble]
```

JavaScript's `parseInt` and Python's `int` both accept a `0x` prefix at
radix 16. Temper's docs do not mention it, but two reference backends
agreeing is about as close to a spec as this gets, so temper-core accepts
it too, at radix 16 only.

The more interesting result is that JavaScript and Python disagree with
*each other* on two lines:

```
< toInt32 ٣: [bubble]          (JavaScript)
> toInt32 ٣: [3]               (Python)
< toFloat64 1e400: [Infinity]  (JavaScript)
> toFloat64 1e400: [bubble]    (Python)
```

Python's `int` accepts Arabic-Indic digits, and Python's runtime
deliberately rejects any infinity not spelled "Infinity", so an
overflowing `1e400` bubbles. Ruby sides with JavaScript on both, since
JavaScript's runtime is the reference implementation. It means Temper's
string parsing is not quite the same language on every target, which is
worth knowing before you parse user input with it. The generated Ruby for
the program passes Steep too.

## Where it stands

Forty-six of sixty-six, all typed. temper-core is up to 40 minitest runs.

**Not done:** maps are next, then `Deque`, `DenseBitVector` and `Date`.
After those: generators and async, `@test` blocks, and imports between
libraries. Ruby's `[[:space:]]`, which the number parsers trim, is close
to JavaScript's `\s` but not identical (it leaves out U+FEFF). I have not
written a test for that.
