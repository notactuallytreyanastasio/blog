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

**Maps, and a nil that equalled another nil**
([entry 10](2026-10-10-a-nil-that-equalled-another-nil.md)). Fifty-one
of sixty-seven. A Map is a frozen Hash, a Deque is an Array, because
CRuby's `shift` is constant time where node's moves the whole array, and
a DenseBitVector is bits in a binary String. Fresh programs found two
places where JavaScript's runtime contradicts Temper's documentation:
`getOr` answers the fallback for a key that is present with a null value,
and `DenseBitVector.set` drops a bit set far enough out. Then the real
find. Since entry 7, the translator had been deleting `x = nil`
statements it thought were its own placeholders, and because the syntax
tree compares nodes structurally, a real `x = nil` from an `else { null }`
looked identical and went too. Inside a loop, a Ruby local keeps its old
value, so a three-line program printed 5, 5, 5 where every other backend
prints 5, -1, -1. No test had a loop, a second pass and a null in a place
that mattered. There is one in the shared suite now.

**A date, and everything it imports**
([entry 11](2026-10-10-a-date-and-everything-it-imports.md)).
Fifty-two of sixty-seven. Importing `Date` from `std/temporal` compiles all
of Temper's standard library, so one date test needed networking, regular
expressions and JSON to translate too: 2,361 lines of Ruby, which I said
passed Steep, and which did not even parse (entry 12 has the correction). Ruby's own Date turns Julian before 1582, which the functional test
cannot see because every weekday it checks is later; temper-core makes
every Date Gregorian. A fresh calendar program found JavaScript's runtime
rolling 31 April over into 1 May and reading `"96-03-31"` as 1996, the
exact bug the test warns about. Ruby agrees with Temper's interpreter on
26 lines of 27. Networking runs on a thread and hands results back to the
main thread, which is the start of an event loop. Ruby's regex dialect
anchors `^` and `$` at every line break, so temper-core rewrites the
JavaScript-dialect patterns std/regex produces before Ruby compiles them.

**Twelve errors Steep did not mention**
([entry 12](2026-10-10-twelve-errors-steep-did-not-mention.md)).
Fifty-eight of sixty-seven. One library can now use another's names: in a
sibling module an import is an alias, and across libraries exported names
are chosen from their text alone, so both sides agree, and every exported
value gets a reader method. The first regex test to run found that std/regex's
`Begin` had become the constant `BEGIN`, a Ruby keyword, so std had never
parsed, and that Steep 2.1 says "No type error detected" about a file it
cannot parse, which is how entry 11 came to claim otherwise. The harness
now compiles every file and checks every library. That turned up twelve
real problems in std, among them `return return_` lines the translator
had left after code that always returned. Also: a property named `hash`
would have replaced Object#hash, and local functions that call each other
need forward declarations Steep will accept.

**Coroutines Ruby already had**
([entry 13](2026-10-10-coroutines-ruby-already-had.md)). Sixty-four of
sixty-seven. A Temper generator runs its body in a Ruby Fiber, so nothing
inside it needs rewriting: `yield()` is `Fiber.yield`, and `await` hands
the promise to an event loop that resumes the block once it settles. A
real HTTP request from inside an async block now works end to end. A fresh
ordering program found the backends disagreeing about when an async block
runs: Ruby at once, JavaScript only after the top level, and Python on a
thread pool, in whatever order the threads choose. (Entry 16: the
interpreter, never asked here, sides with JavaScript.) It also crashed
JavaScript's generated code on `is ValueResult`. A type used as a value is
the Ruby class that stands for it, `::NilClass` for Void.

**Sixty-seven of sixty-seven**
([entry 14](2026-10-10-sixty-seven-of-sixty-seven.md)). Every functional
test passes, every library the tests make parses and passes Steep, and
be-ruby's list of tests it may run is deleted, so it runs them all. A
Temper library's `test` blocks run under std/testing's own runner,
translated from Temper, which writes the JUnit XML the harness reads. A
library's hand-written `_connected.rb` is copied into its gem and checked
by Steep against signatures generated from the Temper declarations.
Getting there found that every parameter with a `= null` default had been
required in Ruby. Code the frontend reports as broken becomes a panic
carrying the frontend's message, and that test is required to fail Steep.

**Functions as values, and a value the frontend threw away**
([entry 15](2026-10-11-a-value-the-frontend-threw-away.md)). Sixty-eight
of sixty-eight. A generic function used as a value, `identity<Int>`,
reaches the backend as a call to a builtin `<>` that JavaScript and
Python replace with a placeholder that fails; Ruby gives each
instantiation its own lambda constant, typed `^(Integer) -> Integer`.
Another library's function works as a value too. Steep accepts a lambda
with two required parameters as a proc type whose second is optional, so
function values now spell out `b = nil`. Then Steep found a `return` of a
temporary nobody assigned. The frontend had been dropping a function's
last expression when the loop before it held both a `return` and a
`continue` or `break`, and Temper's own interpreter answered with the
loop counter instead. The fix is one line in the frontend, with a unit
test and a new shared functional test.

**The reference nobody asked**
([entry 16](2026-10-11-the-reference-nobody-asked.md)). Checking the
journal's findings against our open upstream issues turned up three
mistakes. Two bugs entry 14 said were "reported nowhere" had been reported
by us two days earlier: #556 (Arabic-Indic digits) and #579 (generators on
js and Python). And entry 13 chose Ruby's async order without ever running
Temper's interpreter, which starts blocks after the top level, in launch
order, as JavaScript and rust do. Ruby does too now: `async_launch` queues
the block, and probe 39 matches the interpreter on all nineteen lines.
Entries 13 and 14 carry visible corrections.

**Where it stands.** Sixty-eight of sixty-eight, all typed. Another
library's generic function used as a value stops the build. The five findings
that had no upstream issue are now filed as #618 to #622, with
reproductions in temper-issue-repros: the frontend's dropped trailing
value, generic function values, `getOr`, `DenseBitVector` and `Date`.

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
10. [2026-10-10: maps, and a nil that equalled another nil](2026-10-10-a-nil-that-equalled-another-nil.md)
11. [2026-10-10: a date, and everything it imports](2026-10-10-a-date-and-everything-it-imports.md)
12. [2026-10-10: twelve errors Steep did not mention](2026-10-10-twelve-errors-steep-did-not-mention.md)
13. [2026-10-10: coroutines Ruby already had](2026-10-10-coroutines-ruby-already-had.md)
14. [2026-10-10: sixty-seven of sixty-seven](2026-10-10-sixty-seven-of-sixty-seven.md)
15. [2026-10-11: functions as values, and a value the frontend threw away](2026-10-11-a-value-the-frontend-threw-away.md)
16. [2026-10-11: the reference nobody asked](2026-10-11-the-reference-nobody-asked.md)
