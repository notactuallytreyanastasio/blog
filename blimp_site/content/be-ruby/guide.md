# How be-ruby works

be-ruby compiles Temper to Ruby. This is the guide to it as it stands
today, which means it is short, and gets longer every time something
works. The dated entries tell you how each piece came to be the way it
is; this tells you what the pieces are, so you can use them without
reading a week of diary.

One thing to know up front: Ruby is, in principle, the friendliest target
Temper has. It has classes, loops, `return`, exceptions and real
coroutines, so a lot of this backend is just writing down the obvious
thing. The parts worth reading about are the places where the obvious
thing is quietly wrong, and this guide flags them as it goes.

## 1. What you need

Ruby 4.0 or later. It was built against 4.0.7, which was the newest
release on the day it started, and nobody has tried it on anything
older. You also need JDK 21 to build Temper itself, and Steep (the type
checker) if you want the types checked:

```bash
gem install --user-install steep rbs
```

On a Mac there is a trap waiting. The system Ruby lives at
`/usr/bin/ruby`, it is version 2.6, and it will happily try to run
everything and fail in confusing ways. Homebrew's Ruby is keg-only,
which means Homebrew installs it and then politely declines to put it on
your PATH. So:

```bash
export PATH=/opt/homebrew/opt/ruby/bin:$HOME/.gem/ruby/4.0.0/bin:$PATH
```

## 2. Running it

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
./gradlew :cli:installDist                      # a `temper` that knows -b ruby
cli/build/install/temper/bin/temper build -b ruby -w path/to/my-lib
cd path/to/my-lib/temper.out/ruby/my-lib
ruby -I ../temper-core/lib -I lib -e 'require "temper/my_lib"'
```

or just `temper run -b ruby --library my-lib`, which does the last two
lines for you. What lands on disk:

```
temper.out/ruby/
  temper-core/                the runtime, its own gem, with tests and types
  my-lib/
    temper-my_lib.gemspec
    lib/temper/my_lib.rb
```

A few choices in there that look arbitrary and are not:

- **Everything lives under `Temper::`.** A library called `set` would
  otherwise be `module Set`, which is not a new module. It is Ruby's own
  `Set`, reopened, with your functions added to it, and Ruby will let you
  do that without saying a word.
- **The modules are nested, never compact.** The generated file says
  `module Temper` and then `module MyLib`, never `module Temper::MyLib`.
  The compact spelling raises NameError if `Temper` does not exist yet,
  and, worse, looks up constants differently when it does: inside it, a
  constant defined directly in `Temper` is not found. So the same file
  would crash or not depending on which gem happened to load first.
- **Gem names use underscores.** By RubyGems convention a dash means a
  namespace (`net-http` is required as `net/http`), so `my-lib` becomes
  `temper-my_lib`.
- **There is no Bundler.** A library's dependencies are sibling
  directories, a load path is all they need, and `bundle exec` would add
  real time to every run of a sixty-program test suite.
- **Requiring the library runs it.** A Temper module's top-level
  statements run when the module loads, and in Ruby that is exactly what
  `require` does, so there is no `main` to call.

## 3. The runtime: temper-core

Translated code calls into `TemperCore` for the handful of things Ruby
does differently from Temper. Ruby is not wrong about any of them, in
the sense that a lot of mathematicians would take its side. It is just
not Temper.

| Temper says | Ruby does | So temper-core has |
|-------------|-----------|--------------------|
| `Int` is 32 bits and wraps | integers never overflow | `int32`, `int64` |
| `-7 / 2` is -3 (truncate) | `-7 / 2` is -4 (floor) | `int_div`, `int64_div` |
| `-7 % 2` is -1 | `-7 % 2` is 1 | `int_rem` (which is `Integer#remainder`) |
| `1.0 / 0.0` bubbles | it is `Infinity` | `float_div`, `float_rem` |
| integer division by zero bubbles | it raises ZeroDivisionError | a zero check, raising `Bubble` |

A bubble is `TemperCore::Bubble`, a StandardError, so a bare `rescue`
catches it.

`console.log` is `TemperCore.console_log`, not `puts`. `puts` skips its
newline when the string already ends in one, and prints an array one
element per line, both of which are helpful to a person at a terminal and
wrong for a translation.

There is one temper-core in an output directory, not one copied into each
library. Two copies would each reopen `TemperCore`, and whichever loaded
last would quietly win for everybody.

## 4. Types

The runtime has an RBS signature, `temper-core/sig/temper_core.rbs`, and
a Steepfile, and `steep check` passes. Generated libraries do not have
signatures yet; that is coming, and the idea is that the backend writes
the signature from Temper's types at the same moment it writes the code.

The Steepfile uses Steep's strict profile:

```ruby
target :lib do
  signature "sig"
  check "lib"
  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)
end
```

Two things about Steep 2.1 you would otherwise find out the annoying way
(`probes/06_steep/` shows both). A method with no signature at all is
only a *warning*, even under strict, which matters because a forgotten
signature is the likeliest bug in generated code. And `steep check` exits
1 on a warning alone, so the build still fails. Also, if you copy a
Steepfile from older docs, the `D::Ruby.strict` shorthand is gone: it is
`Steep::Diagnostic::Ruby.strict` now.

## 5. How the backend is put together

A Temper backend never prints target code as strings. It builds a tree
of the target language and lets Temper's formatter print the tree. Here
the tree is described in `ruby.out-grammar`, and `./gradlew
kcodegen:updateGeneratedCode` turns that into `Ruby.kt`, one class per
kind of node.

| File | What it does |
|------|--------------|
| `ruby.out-grammar` | the Ruby syntax tree. Every statement writes its own newline |
| `RubyOperatorDefinition.kt` | the precedence ladder, which decides every parenthesis |
| `RubyOperator.kt` | the operators, minus `and`, `or` and `not` |
| `RubyFormattingHints.kt` | spaces, and only spaces |
| `RubyHelpers.kt` | literals: strings, floats, symbols, comments |
| `RubyBackend.kt` | one gem per library, and temper-core beside them |
| `RubyTranslator.kt` | TmpL to Ruby, one module at a time. Anything it does not handle is a `TODO()` carrying the node |
| `RubySupportCode.kt` | each builtin and `@connected` member, as Ruby |
| `RubySupportNetwork.kt` | how this target differs: bubbles are exceptions, coroutines generators, void is `nil` |
| `RubySpecifics.kt` | running the output with `ruby -I` |
| `temper-core/` | the runtime gem |

The precedence ladder is where copying from another backend would have
gone wrong without anyone noticing. Ruby puts `&` above `==`, so
`6 & 3 == 2` is `(6 & 3) == 2`, the opposite of C. And unary minus is
looser than `**`, even on a variable: `-x ** 2` is `-(x ** 2)`. So a
negative literal is treated as a unary minus when parentheses are
decided, and the square of negative two prints as `(-2) ** 2`.

The formatting hints never break a line, which sounds fussy until you
remember that a Ruby newline ends a statement unless the line visibly
cannot end there. A formatter that wrapped `a + b` before the `+` would
leave `+ b` on a line by itself, where Ruby reads it as a separate,
pointless expression and throws it away.

Strings escape every `#`, because `#{x}`, `#@x` and `#$x` all
interpolate, and the second and third are the ones people forget.

## 6. Checking it

```bash
./gradlew :be-ruby:jvmTest :be-ruby:ktlintCheck
ruby be-ruby/journal/probes/04_grammar_samples.rb
```

`jvmTest` runs the grammar tests, the functional tests that are switched
on (the `onlyPasses(ruby(), ...)` list in `FunctionalTestStatus.kt`),
temper-core's minitest suite and `steep check`. It goes looking for a Ruby 4 itself, because a Gradle
daemon remembers whatever PATH it started with, and on a Mac that is
probably the 2.6. The probe evaluates every rendering the grammar test
pins and checks its value, so the expected strings are known to mean
what the tree says, not just to look plausible.

## 7. What does not work

Nearly everything, still. The translator knows literals and
`console.log`, and that is the complete list. One functional test of
sixty-six passes. A top-level `let`, a function, a class: each stops the
build with a TODO naming the node. Generated code has no signatures yet.
Strings, lists and maps have no runtime support. The next entries are
about making those stop being true.
