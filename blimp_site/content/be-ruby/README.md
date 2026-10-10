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

**Classes** ([entry 6](2026-10-10-classes-and-the-diamond.md)).
Twenty-eight of sixty-six. Temper classes extend only interfaces, so an
interface is a Ruby module and a class includes it, and most classes come
out looking hand-written. The exception is the diamond. When two of a
class's interfaces inherit the same default method, Temper picks the
nearest one breadth-first and Ruby's include chain picks something else.
Temper's suite has a test built to catch exactly this, and it caught the
first draft. So where (and only where) two interfaces define a method,
the class gets a one-line forwarder naming Temper's winner. Also: a
static method called `new` would have replaced the constructor, which
Ruby would have allowed.

**Types** ([entry 7](2026-10-10-steep-was-right.md)). Every library
now ships an RBS signature, generated from Temper's types in the same pass
that writes the Ruby, and the tests run Steep on it. When the checker
first ran, it rejected six programs that ran correctly, and it was right
all six times. A local declared as `x = nil` was typed nil forever. A
constant called `T` inside the module called `T` meant one thing to Ruby
and another to Steep. And an early return had come out as a `while true`
loop with a variable in it, which Steep disliked for a type reason and any
reader would dislike for every reason; it is a plain `return` now. Steep
misreads `return` inside a lambda as the method's, so lambdas say `next`.
Steep ignores an absolute path in a Steepfile without a word. And one
test, the one that deliberately passes a String where an Int goes, is now
required to fail the type check, so a backend that typed everything
`untyped` would get caught.

**Lists** ([entry 8](2026-10-10-a-sort-that-is-stable-at-forty.md)).
Thirty-four of sixty-six. A List is a frozen Array and a ListBuilder an
unfrozen one, which is also what JavaScript's runtime does. Ruby's
indexing had to be fenced off: `a[-1]` is the last element, reading past
the end is nil, and writing past it pads with nils. The probe for sort
stability said Ruby's sort was stable at forty items, which was lucky, and
unstable at 8, 100 and 1000, which was the truth. A function used as a
value is a constant holding a lambda, because Steep will not accept
`method(:f)` as a proc and cannot type a lambda handed straight to a
generic method. And the best find was a quiet one. Any Temper builtin the
backend had not mapped was falling through to whichever Ruby method had
the same name, so Temper's `split` was running as Ruby's `split`, which
drops trailing empty strings. It printed nearly the right answer. Unmapped
builtins now stop the build by name.

**Strings** ([entry 9](2026-10-10-strings-by-the-byte.md)). Forty-six
of sixty-six. Temper never indexes a string by integer. It hands out
opaque string indices, and in Ruby they are byte offsets into the UTF-8,
because Ruby's own `s[i]` scans from the start of any string that is not
ASCII. Ruby turned out to be lenient in all the wrong places: `pack("U")`
encodes surrogates into broken UTF-8, `Integer("1_000")` is a thousand,
`"12abc".to_i` is twelve, and an empty `String.new` is binary. Steep
splatted a lambda's array parameter, a rule Ruby does not have even for
blocks, so every lambda is now `lambda do |a|`. Then I wrote a fresh
string program, not from the suite, and ran it on JavaScript, Python and
Ruby. Ruby disagreed with JavaScript on one line of forty-two, a `0x`
prefix both references accept. JavaScript and Python disagreed with each
other on two.

**Where it stands.** Forty-six of sixty-six, all typed. Maps are next.

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
6. [2026-10-10: classes, and who wins the diamond](2026-10-10-classes-and-the-diamond.md)
7. [2026-10-10: types, and six times Steep was right](2026-10-10-steep-was-right.md)
8. [2026-10-10: lists, and a sort that is stable at forty](2026-10-10-a-sort-that-is-stable-at-forty.md)
9. [2026-10-10: strings, by the byte](2026-10-10-strings-by-the-byte.md)
