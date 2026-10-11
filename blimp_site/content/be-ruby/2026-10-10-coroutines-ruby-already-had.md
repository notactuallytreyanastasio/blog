# 2026-10-10: coroutines Ruby already had

Sixty-four of sixty-seven. Six more: the four tests about `async`,
`await` and generators, plus two that were only waiting on a type,
`FunctionsNamedArgs` (Empty) and `ClassesAngleCall` (Type). Entry 1 said
this was where Ruby would make up for everything else, because Ruby has
real coroutines and Elixir did not. That turned out to be true, which
has not been the usual fate of things entry 1 said.

## What the other backends do

Temper's frontend can hand a backend coroutines in one of two forms. It
can rewrite each one into a state machine, a function with a `switch` on
which step it is up to, or it can leave them as generator functions with
`yield` in them, for a target that has generators. Python and JavaScript
take the second form, and so does Ruby. The difference is what a
generator is in each language. In Python and JavaScript it is a special
kind of function. In Ruby it is anything at all, run inside a Fiber, which
is a whole call stack you can pause and resume. So none of the code
inside a Temper generator has to change. A function that yields is
translated as usual, and the body is just wrapped:

```ruby
fn_4 = lambda do
  TemperCore::Generator.new(lambda do
    TemperCore.console_log("Before")
    b_5.complete(TemperCore::EMPTY)
  end)
end
TemperCore.async_launch(fn_4)
```

Calling it makes a Generator and runs nothing. Each `next` resumes the
Fiber to the next `yield()`, which is `Fiber.yield`.

## `await`

An async block is a generator too, one that temper-core's event loop
steps rather than user code. `await` on a promise that has already
settled answers at once. Otherwise it yields the promise up to the loop,
which arranges to resume the block when the promise settles:

```ruby
def self.await(promise)
  unless promise.settled?
    raise Panic, "await outside an async block" if Fiber.current.equal?(@main_fiber)

    Fiber.yield(Awaiting.new(promise))
  end
  promise.value
end
```

Last entry's background-work queue became the rest of the loop: at exit,
run every block whose promise has settled, in the order the promises
settled, and wait for background work, until there is neither. The
`Cell` actor test checks that a field read before an `await` can change
while the block is suspended, and passes. So does `TypesNetresponse`,
which makes a real HTTP request from inside an async block to a server
the test harness starts, and so goes through every piece of this at once.

## When does an async block run?

The usual fresh program, this time about ordering
(`probes/39_fresh_async/`): two blocks waiting on one promise, top-level
code after launching them, a block that launches a block, a broken
promise. The three backends gave three answers. Ruby runs each block at
once, up to its first `await` of something unsettled, and resumes blocks
after the top level is done:

```
[first waiter starts]
[second waiter starts]
[top level after launching both]
[top level after completing]
...
[first waiter got 7]
[second waiter got 7]
```

JavaScript does not start any block until the top level has finished.
Python starts them on a thread pool, so its order is whatever the threads
do, and the run I saved has the first waiter finishing before the top
level gets to say it completed the promise. Temper's documentation says
`async` "runs it out of band", which all three do. I kept Ruby's order
because it is the same on every run, and a test can rely on it. But this
is now a known way for the backends to disagree, and a program that
prints from an async block and from the top level will print in a
different order on each.

The same program found two things wrong with JavaScript. Testing a
generator's result with `is ValueResult` crashes: `ReferenceError:
ValueResult_24 is not defined`, which looks like a missing import. And
my first version, which looped `while (!g.done)`, ran for ten minutes at
full CPU on JavaScript before I stopped it. On Ruby that version crashed
instead, with `undefined method 'done'`: temper-core had declared it
`done?`, Ruby's spelling, while Temper reads it as a property called
`done`. It is both now, and the bounded version shows a value, then done,
then done again for every later step. (Python's saved output has no step
lines at all, and I have not looked into why.)

## Empty and Type

`empty()` is Temper's unit value, which is not null and not void, so it
is a frozen singleton, `TemperCore::EMPTY`. `FunctionsNamedArgs` only
needed its RBS type.

`ClassesAngleCall` returns `Void` from a function declared to return
`Type`: a type used as a value. A Ruby class is a value already, so a
Temper type is the Ruby class that stands for it, `::NilClass` for Void
(a void value is nil), `::Integer` for Int, a translated class's own
constant for that class. RBS calls all of them `Module`. A type with no
Ruby class to stand for it stops the build.

One oddity, which is not mine: `orelse panic()` inside an async block came
out as a rescue that raises a bubble rather than a panic. JavaScript's
output has `throw Error()` in the same place, so the frontend lowers it
that way before any backend sees it.

## Where it stands

Sixty-four of sixty-seven, all typed. temper-core is at 66 minitest runs.

**Not done**, three tests: `@test` blocks (`TestingAsserts`), a connected
function declared in the test's own library (`FunctionsConnected`), and
`SemanticsBroken`, which the frontend turns into a garbage node before
the backend sees it.
