# 2026-10-10: types, and six times Steep was right

Every library be-ruby writes now ships its own RBS signature and a
Steepfile, and the functional tests run `steep check` on the output after
they run the output itself. Still twenty-eight of sixty-six, which
sounds like a chapter with nothing to show for it. But "passes" means more
now. Each of those twenty-eight prints the right thing *and* is checked
by a type checker against types nobody wrote by hand. Here is the
signature for `InterfacesPropertyMembers`, as generated:

```rbs
module Temper
  module T
    module I
      def x: () -> String
    end
    module J
      include I
    end
    module SI[T < I]
      def thing: () -> T
    end
    class C
      include J
      attr_reader x: String
      def initialize: (String x) -> void
      def x=: (String new_x) -> void
    end
    class D[T < I]
      attr_reader thing: T
      def initialize: (T thing) -> void
    end
    def self.least_x: [IT < I] (IT a, IT b) -> IT
    A: C
    DI: D[I]
    self.@t: I
    ...
  end
end
```

The signature is written in the same pass that writes the Ruby, from the
same Temper types, so the two cannot drift apart. That is the point of
generating it. A hand-maintained `.rbs` beside generated code is a second
source of truth, and the usual fate of a second source of truth is to be
wrong on a Tuesday with nobody noticing. Bounded generics come through as
RBS bounds (`[T < I]`), the module's `@t` is declared as the module's own
(`self.@t`), and a Temper interface is an RBS module because it is a Ruby
module.

The interesting part of the chapter is what happened when the checker
first ran. Steep rejected six of the twenty-eight. In every case the
generated Ruby ran fine and printed the right thing, and in every case
Steep was right anyway. That's a good week for a type checker. It is also
the strongest argument for doing this at all: a program that runs fine and
type-checks badly is one where nothing has gone wrong *yet*.

## The Steepfile, and a path that does nothing

```ruby
target :lib do
  signature "sig", "../temper-core/sig"
  check "lib"
  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)
end
```

That second signature path is relative because it has to be. My first
version named temper-core's signatures by absolute path, which Steep 2.1
accepts without complaint and then does not load:

```
== /Users/bg/code/temper-be-ruby/be-ruby/journal/probes/18_steep_signature_path/core/sig
lib/use.rb:2:16: [error] Cannot find the declaration of constant: `Core`
== ../core/sig
No type error detected. 🫖
```

(`probes/18_steep_signature_path/`.) Same directory, two spellings, and
one of them is silently ignored. A backend lays its gems out side by side
anyway, so relative is free. It is just the kind of thing you would like a
tool to mention.

## 1. A local that was nil forever

A Temper local declared without a value (`let x: String;`, assigned later
in both arms of an `if`) used to come out as `x = nil` up front, on the
theory that declaring things is tidy. Steep fixes a local's type at its
first assignment, so `x` was a local of type `nil`, and the real
assignment two lines down failed:

```
Cannot assign a value of type `::String` to a variable of type `nil`
```

Ruby does not need the declaration. A local exists from its first
assignment in the text, whichever branch runs. So the `x = nil` is now a
placeholder that the translator drops unless Ruby's scoping actually
needs it. That happens in two places: when a lambda reads the local (a
name a lambda has not seen assigned is a method call), and when the local
is first assigned inside a `catch` block, where it would otherwise belong
to the block.

## 2. Steep thinks a lambda's `return` is the method's

A Temper closure that returns early was a Ruby lambda with `return` in
it. In a lambda, `return` leaves the lambda; that is the documented
difference between lambdas and procs. Steep 2.1 checks it against the
*enclosing method's* return type instead:

```
3
3
lib/l.rb:11:6: [error] The method cannot return a value of type `::Integer` because declared as type `^(::Integer) -> ::Integer`
```

(`probes/16_steep_lambda_return/`.) The two 3s are Ruby agreeing that
`return` and `next` do the same thing at runtime. The error is Steep
disagreeing. Steep is wrong about this one, technically. But `next` means
the same thing, Steep reads it correctly, and arguing with your type
checker is a hobby rather than a strategy. So a `return` inside a lambda is
written `next`, and a `next` that is a lambda's last statement is dropped,
since the lambda returns its last value anyway.

## 3. The early return was a loop

This is the one where the type error was really a style complaint, and
the style complaint was right. Temper's frontend lowers a function with
an early return into a labelled block plus a variable holding the result.
The translator dutifully turned that into Ruby, and here is
`ControlFlowIfReturn`'s `explicit`, before:

```ruby
def self.explicit(b)
  return_ = nil
  while true
    if b
      return_ = "true"
      break
    end
    return "false"
    break
  end
  return return_
end
```

That is correct Ruby, and it is the kind of correct that makes a reviewer
put down their coffee. Steep's objection was the first problem again
(`return_` is typed `nil` forever, so `return return_` cannot be a
String), but the real problem was that nobody would write this. Ruby has
`return`. So the translator now recognizes the pattern, a labelled block
whose breaks all carry the result straight out, and writes the return the
frontend lowered away:

```ruby
def self.explicit(b)
  if b
    return "true"
  end
  return "false"
end
```

Fewer lines, no loop, and Steep is happy. I would like to say I set out to
fix the style and the types came along. It was the other way round.

## 4. Casts, and `not_null`

Some casts, `x as Fuji` among them, came out as a type test that
bubbled if it failed, followed by the plain `x`. Ruby got the right answer. Steep saw the value of `x` (an
`Apple?`) being stored where a `Fuji` was declared:

```
Cannot assign a value of type `(::Temper::T::Apple | nil)` to a variable of type `::Temper::T::Fuji`
```

Steep could not know that the test three lines up had made sure. So a cast
to a class is always `TemperCore.cast(x, Fuji)`, which tests, bubbles,
and is declared to return `untyped`, which is RBS for "trust me". That is
an honest signature: the frontend has already checked the static type, and
the runtime test is where it gets enforced.

Then the frontend's other promise, "this is not null", which Temper
spells `UncheckedNotNull`, became `TemperCore.not_null(x)` with the
signature `[T] (T? value) -> T`. Writing the body was the hard part.
Here are the two obvious ways to write it, checked against that
signature:

```
lib/n.rb:3:26: [error] Type `(T | nil)` does not have method `nil?`
lib/n.rb:7:26: [error] Type `(T | nil)` does not have method `==`
lib/n.rb:6:11: [error] Cannot allow method body have type `(T | nil)` because declared as type `T`
```

(`probes/17_steep_not_null/`.) A bare type parameter `T` could be
anything, including a BasicObject, which has neither `nil?` nor `==`, so
Steep will not let you call either on it. And even if it would, `== nil`
narrows nothing. This version passes:

```ruby
def self.not_null(value)
  case value
  when nil then panic
  else value
  end
end
```

`case`/`when nil` is a pattern Steep narrows on without calling anything
on `value`. In the `else` arm it is a `T`. I would not have guessed that,
and there was no reason to: the probe guessed for me.

## 5. A constant called T inside a module called T

The functional tests compile everything as a library named `t`, so every
library is `Temper::T`. `InterfacesEmpty` casts at the top level, and the
frontend keeps the cast's result in a temporary called `t`, which became
the constant `T`. Ruby resolved `T.greet()` to the inner constant, the
greeter, and printed `Hi!`. Steep resolved it to the module:

```
Type `singleton(::Temper::T)` does not have method `greet`
```

You could call this a test-harness artefact, since a real library is
rarely named after a temporary. But "rarely" is a bad thing to rely on in
a compiler, and if Ruby and Steep can read the same constant two ways, a
human reading the code can too. A module-level name may no longer take
the library module's own name, or `Temper`, or `TemperCore`:

```ruby
GREETER = HiGreeter.new()
T_2 = TemperCore.cast(GREETER, HiGreeter)
T_2.greet()
```

## 6. The test that is supposed to fail

`SemanticsTypeCheckedLocals` exists to check what a backend does with a
program Temper has already called wrong. The frontend reports
`i("0")`, a String passed where an Int is declared, as a type error and
compiles it anyway, and the test checks the runtime behaviour. Ruby runs
it and prints the expected output. Steep, correctly, does not accept it:

```
lib/temper/t.rb:69:8: [error] Cannot pass a value of type `::String` as an argument of type `::Integer`
│   ::String <: ::Integer
...
└       i("0")
          ~~~

Detected 4 problems from 1 file
```

So that one test is now *required* to fail Steep. The harness asserts it,
and if a change to the backend ever made the type error go away, that
would be a bug. Without this, a regression that typed everything as
`untyped` would pass every test. With it, at least one test notices.

## What RBS cannot say

Temper's private properties are Ruby `protected` readers (last entry),
and RBS has no `protected`. The signature lists them as ordinary
`attr_reader`s, which is looser than the Ruby: Steep would let outside code
call one, and Ruby would then raise. I could leave them out of the
signature, but then Steep would reject the class's own `other.backing`.
So the signature errs toward permissive, and the runtime holds the line.

## Where it stands

Twenty-eight of sixty-six, all of them typed. temper-core passes Steep and
its 24 minitest runs. The two new probes (17 and 18) are in `probes/`.

**Not done:** everything from last entry's list is still not done. The
standard library is next: String's methods, List and ListBuilder, Map,
StringBuilder. That is where most of the other thirty-eight stop, and it
is where the types get interesting, since `Array[String]` is a type Steep
has opinions about.
