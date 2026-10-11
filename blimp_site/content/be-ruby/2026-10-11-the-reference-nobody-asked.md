# 2026-10-11: the reference nobody asked

Sixty-eight of sixty-eight, the same as last time, and one fewer way
for Ruby to disagree with Temper. This entry is mostly corrections. That
is not glamorous, but corrections are the cheapest part of a journal and
the part most often skipped.

The prompt was a reasonable one: we have a few dozen open issues on
temperlang/temper, so do the things this journal found and "reported
nowhere" overlap with any of them? temperlang/temper has 216 open issues,
54 of them ours. I read our 54 titles and searched the text of all 216.

## Reported nowhere, except where we reported them

Entry 14 listed bugs found along the way and said "I have written them
down here and reported them nowhere." Two of them had been reported,
by us, on 2026-10-08, two days before this journal found them again:

- #556 is about `toInt32` accepting input JSON does not, and its test
  input is `"\u{663}"`, ARABIC-INDIC DIGIT THREE, the kind of digit the
  fresh strings and dates programs tripped on. Its table has js
  refusing it and Python, Java and the interpreter accepting it. Ruby
  refuses it, like js.
- #579 is about generators, and has js's `ReferenceError: ValueResult_6
  is not defined` (entry 13 saw `ValueResult_24`, same bug, different
  counter) and js's generators having no `done` property. That second
  one explains entry 13's ten minutes of full CPU: `while (!g.done)` on js
  is `while (!undefined)`, which is a long time.

Entry 13 also said Python's output had no generator step lines "and I
have not looked into why." I looked. My first guess, from #579's table,
was the missing `done`, and I wrote that into the probe's README before
running it. Then I ran it:

```
NameError: name '_value_result' is not defined
```

That is the `is ValueResult` column of the same table, not the `done`
column. Same issue, wrong cell, fixed before it went anywhere.

## The order nobody checked against the reference

Entry 13 wrote a program about when async blocks run, ran it on js,
Python and Ruby, got three answers, and kept Ruby's: each block runs at
once, up to its first `await` of an unsettled promise. The reason given
was that Ruby's order "is the same on every run, and a test can rely on
it." That is true. It is also beside the point, because the backend
everything is checked against is Temper's interpreter, and I never asked
it. Issue #516, ours, has js and rust both printing `top start | top
end | A start`, and says from reading the code that the interpreter runs
blocks one at a time off a queue. A claim from reading is still not a
run, so I ran probe 39 on the interpreter:

```
[top level after launching both]
[top level after completing]
[top level after outer]
[top level after breaking]
[gen a]
...
[first waiter starts]
[first waiter got 7]
```

No block starts until the top level is done, and then they run in the
order they were launched. Ruby printed `[first waiter starts]` first.
Three runtimes on one side, Ruby on the other, and I had called it a
three-way split.

The fix is in temper-core, and it is small. `async_launch` used to step
the block straight away. Now it queues it behind blocks launched
earlier, and the event loop that already runs at exit starts it:

```ruby
def self.async_launch(generator_factory)
  generator = generator_factory.()
  @ready.push(-> { step_async(generator) })
  nil
end
```

Probe 39 on Ruby now matches the interpreter on all nineteen lines, and
its `run.sh` records the interpreter too, so the next comparison
includes the reference by default. Two temper-core tests asserted the
old order, and one of them broke in a quieter way. It checked that an
`await` of an already-settled promise does not suspend, by checking the
block had finished right after `async_launch` returned. With launches
queued, it needed a `drain` before checking, and then it proved nothing:
a block that suspended would also have finished by the end of `drain`. So
it now launches a second block behind the first. If either `await`
suspended, the second block would run in between. I checked that by
making `await` always suspend, and the test failed:

```
TestTemperCore#test_await_of_a_settled_promise_does_not_suspend [test/test_temper_core.rb:654]:
```

Back to normal, temper-core is at 66 runs and 0 failures and passes
Steep, and all 68 functional tests pass, including `ControlFlowAsync`,
`ControlFlowActor` and `TypesNetresponse`, which goes through a real HTTP
request inside an async block.

## Still reported nowhere

These have no issue upstream that I can find:

- the frontend dropping a function's last value after a loop with both
  a `return` and a `continue` or `break` (entry 15). #536 has the same
  symptom, a `return__N` nobody assigned, but its cause was in the
  backend layer, and our PR #572 fixes it.
- `identity<Int>` as a value failing on js and Python (entry 15).
- js's `getOr` answering the fallback for a key whose value is null.
- js's `DenseBitVector.set` dropping a bit set far past the end.
- js's dates turning 31 April into 1 May and reading `"96-03-31"` as
  1996. PR #608 touches dates, but only `dayOfWeek`.

One more thing for anyone checking these against a be-ruby build: the
branch sits on the be-elixir integration branch, which carries our
fixes from PRs #571 to #577. #528 and #536 do not reproduce on a be-ruby
CLI, and that is those fixes, not anything in this journal.

## Where it stands

Sixty-eight of sixty-eight, all typed. temper-core is at 66 minitest
runs. On async order Ruby now agrees with the interpreter, js and rust,
and Python still runs blocks on a thread pool. Entries 13 and 14 carry
visible corrections pointing here. Sixteen entries and forty-two
numbered probes.
