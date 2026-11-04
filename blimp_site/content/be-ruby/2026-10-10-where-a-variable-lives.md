# 2026-10-10: where a variable lives, and eleven of sixty-six

Eleven of Temper's sixty-six functional tests pass now, up from one.
Fibonacci is one of them, and here is all of it, as be-ruby writes it:

```ruby
# frozen_string_literal: true
require("temper_core")
module Temper
  module Fib
    def self.fib(i)
      a = 0
      b = 1
      while i > 0
        c = TemperCore.int32(a + b)
        a = b
        b = c
        i = TemperCore.int32(i - 1)
      end
      return a
    end
    @zero = 0
    @zero = @zero
    TemperCore.console_log("fib(1)=" + TemperCore.int_to_string(fib(TemperCore.int32(@zero + 1))))
    ...
  end
end
```

That is roughly what you would write by hand, if you were the kind of
person who wraps every addition in a call to make sure it overflows
correctly. (The `@zero = @zero` is in the Temper source. The test does it
on purpose, to stop the compiler from folding the arithmetic away.) Getting
here meant answering one real question and finding about half a dozen
small lies, which is about the ratio you would expect.

## The real question: where does `zero` live?

Temper lets a module have top-level variables that its functions read and
write. Ruby has a module body, which is where top-level statements run, and
module functions, which are `def self.fib`. The obvious move is to make
`zero` a local of the module body. It does not work, and the reason is the
single most important fact about Ruby for this backend: `def` is a scope
gate. A method sees its parameters, `self`, and nothing around it. So the
question is which of Ruby's *other* places to put a variable is visible
from the places Temper needs, and the answer is that each one is visible
from a different set of places:

```
def self.f sees a module-body local          "NameError"
def self.f sees a constant                   "constant"
def self.f sees @ivar                        0
def self.f sees @@class_var                  0
class method sees the constant               "constant"
class method's @calls is                     nil
class method sees Lib's @@count              "NameError"
class method via Lib.calls accessor          0
lambda made in module body                   ["constant", 0]
```

(`probes/09_module_state.rb`.) Read the sixth line again. The module's own
instance variable, `@calls`, is the natural home for module state, and
module functions see it fine. But inside a method of a class defined in
that module, `@calls` means the *instance's* `@calls`, which does not
exist, which in Ruby is not an error. It is `nil`. So a translator that
used `@ivars` everywhere would compile, run, and have every class quietly
read nil where the module's value should be. Nothing would crash. It
would just be wrong, which is worse.

So: a `let` with an initializer that is never reassigned becomes a
constant, `GREETING`, which every scope in the module can see. Anything
else becomes the module's `@ivar`, and the translator refuses (with a
TODO naming the variable) to read one from anywhere `self` is not the
module. Classes are not translated yet. When they are, that TODO is where
the accessor goes.

## Names, from Ruby's own mouth

Ruby decides what a name *is* by its first letter (`Foo` is a constant,
`foo` a local or method, `@foo` an instance variable), so the translator
asks for a name *of a kind*, and gets `fib_number` for a local or method
and `GREETING` for a constant. Snake case, because that is how Ruby is
written and a library that exported `fibNumber` to Ruby callers would be
a small daily irritation for them.

There is a second hazard. A module function is a singleton method on the
library's module, so a Temper function called `name` would override
`Module#name`, one called `hash` would override the module's hash, and one
called `raise` would capture the backend's own `raise TemperCore::Bubble`
inside that module, which is the kind of bug you find on a Friday. Rather
than guess at the dangerous names, `probes/10_taken_names.rb` asks Ruby:
every method a fresh module answers to, public, private and protected.
There are 177. A Temper function by any of those names gets a trailing
underscore.

## The small lies

Each of these is a place where the obvious Ruby is not Temper:

**A negative number to a fractional power is a complex number.**

```
(-8.0) ** (1.0 / 3)            (1.0+1.7320508075688772i)
```

Temper, like C's `pow`, says NaN. Ruby says it is `1.0 + 1.73i`, and
honestly Ruby has a point, but a translated program would print that.
`TemperCore.float_pow` returns NaN for a negative base and a finite
non-integer exponent.

**`round` rounds the other way, and returns the wrong type.** `-2.5.round`
is -3 in Ruby (halves go away from zero) and -2 in Temper (halves go up,
as in JavaScript). Also `2.5.round` is the Integer 3, which prints as `3`,
not `3.0`, and `-0.4.round` is the Integer 0, which has no sign. `floor`
and `ceil` return Integers too.

**`min` of a NaN is an exception.**

```
[1.0, Float::NAN].min      "ArgumentError: comparison of Float with 1.0 failed"
```

Temper says the result is NaN.

**`sqrt` of a negative number is an exception**, `Math::DomainError`,
where Temper says NaN. So are `acos(2.0)` and `log(-1.0)`. `log(0.0)` is
`-Infinity`, as IEEE says, so it is not that Ruby dislikes edge cases; it
dislikes some of them.

**Float equality.** Temper says NaN equals NaN and 0.0 does not equal
-0.0, a total order you can sort by. Ruby's `==` says the opposite on both
counts, and so does `eql?`. Which leads to my favourite bug of the day,
one I wrote myself, in a *test*: the test table for float formatting was
a Ruby Hash keyed by floats, with entries for `0.0` and `-0.0`. Since
`0.0.eql?(-0.0)` is true, those are the same key, and the second entry
silently replaced the first. The test reported that `0.0` printed as
`"-0.0"`. It did not; the test had lost a row. That fact will matter
again, for real, when Temper maps with Float64 keys arrive.

**Float printing.** Ruby finds the same shortest digits JavaScript does,
then switches to exponent form at 1e16 and pads the exponent:
`1e20.to_s` is `"1.0e+20"` and `0.00001.to_s` is `"1.0e-05"`. Temper
prints `100000000000000000000.0` and `0.00001`. temper-core takes Ruby's
digits and lays them out JavaScript's way.

## A type checker earning its keep

`TemperCore.float_cmp` handles NaN first and then, for ordinary numbers,
returned `left <=> right`. Steep refused it:

```
[error] Cannot allow method body have type `(::Integer | nil)` because declared as type `::Integer`
```

`Float#<=>` is typed `Integer | nil`, nil being what it returns for NaN.
I had handled NaN three lines up, so the code was right, but Steep cannot
see that, and the next person to move those lines around would not have
had Steep to tell them. It is now an explicit `if`. This is the first
time the types caught something, and it was something real.

## Ruby has no labelled `break`

Temper's frontend makes labelled blocks constantly: around every loop
body that uses `continue`, and around an `if` with an early exit. A
labelled `break` out of a block is ordinary Temper and impossible Ruby. So
each labelled statement gets the cheapest lowering that is right:

- If every jump to the label is direct (it crosses no loop or other label
  inside it), a labelled block becomes a one-shot `while true ... break
  end`, and `break label` becomes `break`.
- Otherwise it becomes `catch(:label) do ... end` with `throw :label`.
  `catch`/`throw` is Ruby's non-local exit, it crosses any number of
  loops, and it costs about six times what `break` does.

The one-shot loop is `while true`, not the tidier `loop do`, because:

```
loop do: StopIteration inside                  [1]
while true: StopIteration inside               :raised
```

(`probes/12_labels.rb`.) `loop` rescues StopIteration. An exhausted
enumerator inside a `loop do` block does not raise; it ends the loop,
quietly, with whatever had happened so far. Temper's generators are going
to be built on Ruby enumerators, so that is not a hypothetical.

Every plain `break` and `next` the translator writes is checked against
what is between it and its target, and if a `while true` or a `catch`
block would intercept it first, the build stops. That check fired on its
first day, on `ControlFlowLoops`:

```
TODO a plain jump would stop short of its target: break;
```

It was an unlabelled `break` for the outer loop, sitting inside the
frontend's labelled `continue` block. Translated as a plain `break`, it
would have left the block and kept looping. Now a loop that has jumps
reaching it from inside a labelled block or an inner loop uses
`catch`/`throw` itself, for just the tags it needs. Here is the shape it
produces, from that test:

```ruby
while @i_4 < 25
  catch(:continue) do
    ...
          if t_3
            throw(:loop_break)
          end
```

## And comparisons read like comparisons

The frontend writes `a < b` as `(a <=> b) < 0` for every type but Int32,
and lets a backend turn it back where it can. Ruby's own `<` is Temper's
order for Int64 and for String (UTF-8 bytes compare in code point order),
so those go back to `a < b`. Booleans cannot: `true < false` is a
NoMethodError in Ruby, because booleans have no order at all. And floats
cannot, because Temper puts NaN above everything and -0.0 below 0.0, so
`1.0 < NaN` is true in Temper and false in Ruby.

## Where it stands

Eleven of sixty-six: hello world, Fibonacci, the locals tests, constness,
top-level order, the three loop tests, `if` with an early return, integer
basics, and non-ASCII names. With the skip list off, the other fifty-five
stop at:

```
20 a class or interface
20 an expression the translator has not met (lists, strings, properties)
12 a call it has not met (constructors, methods on lists)
 3 a reference it cannot place
```

**Not done:** classes, lists, maps, strings beyond literals and
concatenation, closures as values, generators, tests. Generated libraries
still ship no RBS; only temper-core is typed. Classes are next, and types
for generated code are right behind them, since a class is where
Temper's types have the most to say.
