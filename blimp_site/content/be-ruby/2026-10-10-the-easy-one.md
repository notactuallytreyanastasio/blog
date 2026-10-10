# 2026-10-10: the easy one, and the four ways it is not

The first thing be-ruby can do is print Ruby. It cannot yet translate any
Temper; that is the next few entries. What exists today is a syntax tree
for the Ruby this backend will emit, a precedence table that decides every
parenthesis, and 42 rendered snippets that Ruby 4.0.7 evaluated and agreed
with.

## Why this should be easy

The last backend in this series targeted Elixir, which has no classes, no
loops, no mutation and no `return`, and so every chapter of that journal is
a story about building one of those things out of recursion and spite. Ruby
has all of them. A Temper class can be a Ruby class. A `while` can be a
`while`. A `return` can be a `return`. Ruby even has real coroutines
(`Fiber`), which is where Temper's generators were going to hurt on the
BEAM, and where here they will probably just be a `Fiber`.

So you would expect the output grammar to be a transcription exercise, and
mostly it is. The interesting part of this entry is the four places where
transcribing what you know from other languages produces Ruby that parses,
runs, and computes something else. Those are the bugs that do not crash.

## One: unary minus is looser than `**`, even on a variable

```
-2 ** 2                      -4
-two ** 2                    -4
(-two) ** 2                  4
```

(That is `probes/01_precedence.rb`, run on ruby 4.0.7, as is everything
below.)

The first line is famous, and lots of languages agree with it: math
notation says -2² is -4. The second line is the one that matters. Some
languages special-case a negative *literal*, so you might hope Ruby's rule
is about how `-2` lexes. It is not. Unary minus sits below `**` on the
ladder, period. So a tree that means "negate x, then square it" has to
print as `(-x) ** 2`, and a tree that means "the number negative two,
squared" has to print as `(-2) ** 2`. The grammar gives a negative integer
or float literal unary minus's precedence for exactly this reason:

```kotlin
// A negative literal is a unary minus as far as parentheses go: `-2 ** 2`
// is -4 in Ruby, so (-2) squared must be written `(-2) ** 2`.
IntLit.operatorDefinition = `if (value < 0) RubyOperatorDefinition.Negate else RubyOperatorDefinition.Atom`;
```

The float version checks `1.0 / value < 0` too, because `-0.0 < 0` is
false and `-0.0` is still a thing you can raise to a power, if you are
the kind of person who does that.

## Two: `&` binds tighter than `==`

```
6 & 3 == 2                   true
```

In C, Java, JavaScript and Python this is `6 & (3 == 2)`, which is a type
error or zero depending on how much the language likes you. In Ruby the
bitwise operators sit *above* the comparisons, which is what C's designers
have said for fifty years they wish they had done. Good for Ruby! But it
means the obvious move, copying the operator table from be-js or be-py and
renaming things, would put parentheses in the wrong places, and the code
would still run. The table in `RubyOperatorDefinition.kt` comes from Ruby's
own precedence reference, rung by rung, and the probe checks the rungs that
differ.

## Three: `#` interpolates three ways

Everyone who has written a string escaper for Ruby knows to escape `#{`.
Fewer people know that `"#@x"` and `"#$x"` interpolate too: an instance
variable and a global, no braces needed.

```
"#@ivar"                       "IVAR"
"#$gvar"                       "GVAR"
```

A Temper string containing `#@` (an email-ish thing, a CSS selector, a
tweet) would come out of a careless escaper with someone's instance
variable spliced into the middle of it, or `nil` if there is no such
variable, which prints as nothing at all. So `rubyStringText` escapes every
`#`, the way be-elixir does for a related reason. `\#` is a valid escape
for `#` anywhere, so escaping all of them costs a backslash and needs no
lookahead.

## Four: `1.e3` is a method call

```
1.                             "SyntaxError"
.5                             "SyntaxError"
1.e3                           "NoMethodError"
```

The first two fail loudly, which is fine. The third is Ruby reading "call
the method `e3` on the integer 1", which fails loudly only because `e3`
does not exist. Kotlin's `Double.toString` always puts a digit after the
point (`1.0E10`), Ruby accepts the capital `E`, and so the helper is
`value.toString()` plus constants for the three values Ruby has and the
BEAM does not:

```kotlin
internal fun rubyFloatText(value: Double): String = when {
    value.isNaN() -> "Float::NAN"
    value == Double.POSITIVE_INFINITY -> "Float::INFINITY"
    value == Double.NEGATIVE_INFINITY -> "-Float::INFINITY"
    else -> value.toString()
}
```

(Ruby divides floats by zero without complaint: `1.0 / 0` is `Infinity`.
Integer division by zero raises. Temper's rules will need checking
against both, later.)

## The formatter is not allowed to break lines

Ruby ends a statement at a newline unless the line visibly cannot end
there. So this is one expression:

```ruby
total = a +
  b
```

and this is two, the second of which is a unary plus applied to `b` and
then thrown away:

```ruby
total = a
  + b
```

A pretty-printer that wraps long lines in the second style produces Ruby
that silently drops half of an addition. Temper's shared formatter is
happy to wrap lines when the hints let it, so `RubyFormattingHints`
doesn't let it: every newline in the output is written by the grammar,
and the hints only decide spaces. Spaces matter too, since `f(a)` is a
call and `f (a)` is a call with a parenthesised argument, which you
discover the day there is a second argument. A `(` after a name never gets
a space.

## The other thing Ruby 4.0 has not done yet

String literals are still mutable in Ruby 4.0. They are "chilled": mutating
one works and, under `-w`, warns you that it will not work forever.

```
$ ruby -w -e 'a = "x"; a << "y"; p a'
-e:1: warning: literal string will be frozen in the future (run with --debug-frozen-string-literal for more information)
"xy"
```

Temper strings are values, so every generated file starts with
`# frozen_string_literal: true` and gets the future now.

## What the tree has, and what it does not

`ruby.out-grammar` has modules, classes with a superclass, `def` and
`def self.`, lambdas, `if`/`elsif`/`else`, `while`/`break`/`next`,
`begin`/`rescue`/`ensure`, ternaries, calls, indexing, hashes, arrays,
symbols and the literals above. It has no `case`, no `yield`, no blocks
other than lambda bodies, and no `for`, because nothing needs them yet.

One more fact, from `probes/03_scope.rb`, that the next entries are built
on: `def` is a scope gate. A method cannot see the local variables around
it.

```
def sees outer local?                "does not"
lambda bumped outer local            2
```

So a Temper function that closes over a local becomes a lambda, and a
top-level Temper `var` that functions read and write becomes the module's
own instance variable, `@calls`, which every `def self.` in that module
can see. That is the plan, anyway. Plans are free.

**Not done:** everything that is not printing. No backend, no runtime, no
types. `RubyGrammarTest` has 17 tests and `probes/04_grammar_samples.rb`
evaluates the 42 renderings they pin; both pass.
