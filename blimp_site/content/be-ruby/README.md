# be-ruby: a journal

This is the running record of writing a Temper backend for Ruby. Temper
is a language for writing a library once and compiling it into other
people's languages. Ruby is one of those languages now, or will be, with
types.

## The story so far

The pitch for Ruby was that it would be the easy one. The previous
backend in this series targeted Elixir, which has no classes, no loops,
no mutation and no `return`, so its journal is fifty-odd entries of
building those things out of recursion. Ruby has all of them. A Temper
class can be a Ruby class, a `while` can be a `while`, and a `return` can
be a `return`. Ruby even has real coroutines, which is where Temper's
generators were going to hurt and probably now will not. So you would
expect a transcription job.

Mostly it is one. The entries so far are about the places where it is
not, and those all have the same shape. You write the obvious Ruby,
because you know what the obvious Ruby is, and it runs and prints
something slightly different. Nothing crashes. That is the problem.

**The grammar** ([entry 1](2026-10-10-the-easy-one.md)). Before
translating anything, the backend needed a way to print Ruby, and the
printing turned out to have opinions. Ruby puts `&` above `==`, the
opposite of C, so a precedence table borrowed from another backend would
silently change what bitwise code means. Unary minus is looser than `**`
even on a variable, so `-x ** 2` is `-(x ** 2)`. A string containing `#@`
interpolates an instance variable into itself unless you escape it. And
because a Ruby newline ends a statement, a formatter that wrapped a long
line before a `+` would drop the second half of an addition without a
word. So the backend's formatter is not allowed to break lines at all.

**The scaffold** ([entry 2](2026-10-10-hello-whatever-you-say.md)). A
backend that printed Hello, World! whatever you gave it, to prove the
plumbing. Its first version crashed, because `module Temper::Lib` needs
`Temper` to exist already, and the fix uncovered the quieter problem
that the compact spelling looks up constants differently from the
nested one. Every library lives under `Temper::`, because a Temper
library called `set` would otherwise reopen Ruby's own `Set` and add
itself to it, and Ruby would let it.

**The runtime and the types**
([entry 3](2026-10-10-the-runtime-and-the-receipts.md)). `temper-core`
is a small gem holding the arithmetic Ruby does its own way. Ruby
integers never overflow and Temper's wrap at 32 bits. Ruby's division
floors (`-7 / 2` is -4) and Temper's truncates (-3). Ruby happily
divides a float by zero and gets `Infinity`, while Temper's docs say
that is a bubble. The gem has RBS signatures checked by Steep. Steep
catches real type errors, treats a method with no signature at all as a
mere warning, and still fails the build on that warning. That's fine,
but you have to check, which is what the probes are for.

**The first real translation**
([entry 4](2026-10-10-console-log-is-not-puts.md)). `console.log`
became `TemperCore.console_log`, and not `puts`. `puts` quietly skips
its newline when the string already ends in one, and prints an array
one element per line, both helpful to a person at a terminal and wrong
for a compiler. One of Temper's sixty-six functional tests passes. The
other sixty-five each stop the build at the first construct the
translator has not learned, with that construct named in the error. Fifty
of them stop at the same place: a plain top-level `let`.

**Variables, functions and loops**
([entry 5](2026-10-10-where-a-variable-lives.md)). Eleven of sixty-six,
including Fibonacci. The real question was where a Temper module's
top-level variable should live, given that a Ruby `def` cannot see the
locals around it. The tempting answer, the module's own `@ivar`, works
everywhere except inside a class's method, where `@calls` means the
instance's `@calls` and is quietly `nil`. So a `let` that never changes is
a constant and the rest are `@ivars`, and the translator refuses to read
one from anywhere it would come back nil. Along the way: a negative number
to a fractional power is a *complex number* in Ruby, `round` rounds ties
the other way and returns an Integer, `min` of a NaN raises, and a Hash
treats `0.0` and `-0.0` as one key, which I learned when my own test lost
a row. Steep caught its first real bug. Ruby has no labelled `break`, so
labelled blocks become one-shot `while true` loops or `catch`/`throw`,
and not `loop do`, which swallows StopIteration.

**Where it stands.** Eleven of sixty-six. Classes are next, which is
where twenty of the remaining tests stop, and where Temper's types have
the most to say to RBS.

## What is here

- [guide.md](guide.md) -- how the backend works as it stands, as a
  reference you can use without reading the diary.
- [probes/](probes/) -- the Ruby scripts every claim about the target was
  checked with, because "I'm pretty sure Ruby does X" has a poor track
  record. Run any of them with `ruby probes/<file>.rb`, or the `run.sh` or
  `run.rb` in a probe that is a directory. They were written against ruby
  4.0.7.

## Entries

1. [2026-10-10: the easy one, and the four ways it is not](2026-10-10-the-easy-one.md)
2. [2026-10-10: a backend that says hello whatever you tell it](2026-10-10-hello-whatever-you-say.md)
3. [2026-10-10: temper-core, and a type checker you have to talk into it](2026-10-10-the-runtime-and-the-receipts.md)
4. [2026-10-10: `console.log` is not `puts`, and one test of sixty-six](2026-10-10-console-log-is-not-puts.md)
5. [2026-10-10: where a variable lives, and eleven of sixty-six](2026-10-10-where-a-variable-lives.md)
