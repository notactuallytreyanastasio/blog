# 2026-10-10: sixty-seven of sixty-seven

Every functional test passes on Ruby, and every library those tests make
parses and passes Steep in strict mode. be-ruby no longer has a list of
the tests it is allowed to run: the `onlyPasses(ruby(), ...)` entry in
`FunctionalTestStatus.kt`, which has been the scoreboard since entry 4,
is deleted, so Ruby runs every test, including whatever test is added
next. Here is how the last three went, and what passing all of them does
not mean.

## `@test`, run by Temper's own test runner

A Temper library can carry its own tests:

```temper
test("a failing test") { test =>
  assert(false) { "because it's wrong" }
  ...
}
```

The harness wants JUnit XML back. Ruby's minitest does not write JUnit
XML without another gem, and it turned out not to matter, because
std/testing already has a function that runs a list of test cases and
writes JUnit XML, `runTestCases`, in Temper. Since last chapter std
translates to Ruby, so the backend only has to hand it the tests. Each
`test` block becomes a module function taking std/testing's `Test`, in a
separate file the library does not load, with a list for the runner:

```ruby
def self.a_failing_test(test)
  fn = lambda do
    "because it's wrong"
  end
  test.assert(false, fn)
  ...
end
TEST_CASES = [TemperCore::Pair.new("a test case", lambda do |test| a_test_case(test) end), ...].freeze
```

and a test run is `File.write("test-results.xml",
Temper::Std.run_test_cases(Temper::Work::TEST_CASES))`:

```xml
<testcase name='a failing test' classname='a failing test' time='0.0'>
  <failure message='because it&#39;s wrong, expected helper.i == (2) not (3), expected s == (hi) not (bye)' />
</testcase>
```

That is the expected failure message, character for character, and the
code that ran the tests and wrote the XML is std/testing's Temper,
translated, not anything written for Ruby.

Steep had one objection. A test function returns `Void | Bubble`, which
had come out in RBS as `nil | bot`, and the body's last call returns
`void`. `bot` adds nothing to a union, since it is part of every type, so
it is dropped now, and `Void | Bubble` as a result is just `void`. That
touched the signature of every function in every library that can bubble,
and none of them minded.

## Connected functions the user writes

`@connected` means "the backend supplies this". For a builtin, be-ruby
supplies it. A user library can also declare connected functions and
supply them itself, one file per backend, beside the Temper source:
`_connected.js`, `__connected__.py`, `_connected.ex`, and now
`_connected.rb`:

```ruby
module Temper
  module Work
    module Connected
      def self.sum(i, j, bonus) = Temper::Work.sum_of3(i, j, bonus)
      def self.prod(hidden, j) = TemperCore.int32(hidden.i * j)
      def self.length(string) = string.nil? ? -1 : string.length
    end
  end
end
```

The backend copies it into the gem, gives each connected function a body
that applies Temper's defaults and calls `Connected`, and writes RBS for
`Connected` from the Temper declarations. So Steep checks the user's
hand-written Ruby against the Temper signatures, and it found a mistake on
the first run, though the mistake was mine: the signature said `bonus` was
`Integer?`, the type of an optional parameter, when by the time it reaches
`Connected` the default has been applied and it is an `Integer`.

Getting there turned up a real bug. `length` is declared with a null
default:

```temper
@connected
export let length(string: String? = null): Int;
```

and the test calls `length()`. The Ruby was:

```
'Temper::Work.length': wrong number of arguments (given 0, expected 1) (ArgumentError)
```

The translator made a parameter optional in Ruby when Temper marked it
optional with state TRUE. A parameter whose default is null is marked
OTHER, which the frontend's own `optional` property also counts as
optional, and the translator had checked the state instead of the
property. So every Temper function with a `= null` parameter had been a
function with a required parameter in Ruby, for as long as the translator
has handled optional parameters, and no test had called one without the
argument. `FunctionsConnected` now does.

## `SemanticsBroken`, which must break

The last test is Temper with errors in it, which the frontend reports and
sends to the backend anyway. The test expects the program to fail when
run, and the backend not to crash while translating. TmpL's documentation
asks backends to "make a good effort, for production builds, to turn
these into something that allows some tests to proceed but spike the ones
that depend on garbage."

That sounds like it contradicts this journal's first rule, unhandled
cases stop the build, and it does not. A `TODO()` in the translator marks
something the backend does not know how to do yet. A garbage node is
something the frontend has already said is an error, with a message. So
garbage becomes a call that raises a panic carrying that message, exactly
where the garbage was:

```ruby
TemperCore.garbage("Cannot export non-parsed name!")
TemperCore.garbage("doesntExist not available from core")
```

and the program dies at the first one, with the frontend's words. Then
Steep, run on the broken program, rejects it, correctly:

```
lib/temper/work.rb:6:49: [error] Type `bot` does not have method `+`
lib/temper/work.rb:13:8: [error] The method cannot return a value of type `nil` because declared as type `::String`
```

The first is `missing + 1`, with `missing` undeclared. The second is a
function that does not return a String on every path. Like
`SemanticsTypeCheckedLocals` in entry 7, this test is now *required* to
fail Steep, which also guards against a future change that types
everything `untyped` and fails nothing.

## What sixty-seven of sixty-seven does not mean

It means the suite passes. Entry 10 already showed what the suite misses:
the placeholder bug lived for three chapters, and today's `= null` bug
for longer than that. The fresh programs written along the way are the better
evidence, and they all give the same Ruby output as before this chapter.
Here is what they found, and what is still open.

Places where the backends disagree, and Ruby picked a side:

- `getOr` for a key whose value is null: JavaScript answers the
  fallback; Temper's documentation, Python and Ruby answer null.
- Arabic-Indic digits in `toInt32`: JavaScript and Ruby refuse them,
  Python and the interpreter accept them.
- When an async block runs: Ruby at once, up to its first unsettled
  `await`; JavaScript after the top level; Python on a thread pool. I ran
  the same program on Python twice today and got two different orders.
  The second run starts `second waiter` after `top level after
  completing`, where the first started it before `top level after
  launching both`.

Bugs found in JavaScript's runtime along the way: `getOr` above;
`DenseBitVector.set` dropping a bit set far past the end; dates rolling
31 April into 1 May and reading `"96-03-31"` as 1996; a crash on `is
ValueResult`. I have written them down here and reported them nowhere.

Things that still stop the build with a `TODO`, because no test reaches
them: a generic module function used as a value, and another library's
function used as a value. And things nobody has measured: how fast any of
this is, beyond the few loops the probes timed, and how it behaves outside
a test harness, as a gem installed with `gem install`.

## Where it stands

Sixty-seven of sixty-seven, all typed, every library checked. temper-core
has 66 minitest runs and passes Steep. Fourteen entries and thirty-nine
numbered probes.
