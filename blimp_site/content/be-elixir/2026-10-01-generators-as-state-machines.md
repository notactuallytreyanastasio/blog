# 2026-10-01: generators and async as state machines

The BEAM's obvious answer to "a function that pauses" is a process, which
is wrong for Temper. Objects here live in a per-process heap (entry 3). A
generator running in its own process would see an empty heap: every object
it was handed would be a dangling `%TemperCore.Ref{}`. Moving the heap into
a shared process or ETS table would fix that, but it would turn every field
read into a message or a table lookup, and it would add the scheduling
nondeterminism that Temper's semantics never asked for.

Temper's frontend already has the alternative. With
`CoroutineStrategy.TranslateToRegularFunction`, which be-rust and be-java
also use, the frontend rewrites a generator body into an ordinary
function. That function switches on a `caseIndex` that it keeps across
calls, and nothing reaches the backend that pauses at all. Switching
be-elixir to that strategy needed no new translator constructs. The
mutable `caseIndex` is a local captured and assigned by a closure, so it
becomes a cell (entry 4). The `while (true)` around the dispatch becomes a
self-passing function (entry 2).

This probe:

```temper
f { (): GeneratorResult<Empty> throws Bubble extends GeneratorFn =>
  console.log("one");
  yield;
  console.log("two");
}
```

becomes this (the indentation after `fn ->` is the formatter's, and still
wrong):

```elixir
def fn__12() do
  caseIndex___18 = TemperCore.Heap.new(:cell, %{:v => 0})
  convertedCoroutine___21 = fn generator___17 ->
  caseIndexLocal___20 = TemperCore.Heap.get(caseIndex___18, :v)
  TemperCore.Heap.put(caseIndex___18, :v, -1)
  if caseIndexLocal___20 == 0 do
    IO.puts("one")
    TemperCore.Heap.put(caseIndex___18, :v, 1)
    {:value, :empty}
  else
    if caseIndexLocal___20 == 1 do
      IO.puts("two")
      :done
    ...
  TemperCore.Generator.adapt(convertedCoroutine___21)
end
```

It prints `start false / one / mid false / two / end true`, the same as JS.

## The runtime

`TemperCore.Generator` is a heap object `%{step: f, done: false}`.
`next/1` is a copy of `SafeGeneratorFnWrapper` in core.temper. It sets
`done` before running the step and clears it only when the step yields a
value, so a re-entrant `next` sees `:done`. A result is `{:value, v}` or
`:done`.

`TemperCore.Promise` is a heap object too: `%{state: :pending | {:ok, v} |
:broken, waiters: [...]}`. The first settle wins. Settling enqueues the
generators waiting on the promise. `async` does not run its body. Like the
interpreter's `AsyncFn`, it enqueues it on a FIFO run queue in the process
dictionary. `main/0` ends with `TemperCore.Async.drain()`, which pops one
generator, steps it once, and loops. No step ever runs inside another
step, so a chain of awaits is a loop and not a deepening stack. The design
prototype drained a million settled awaits in 444 ms.

## A silent `nil`, and two frontend bugs it was hiding

The first version passed both tests and still had a bug. A step function
that fell off its end returned `nil`, `next` read that as "not done", and
the generator ended early without an error. `next` now accepts only
`{:value, _}` or `:done`, and anything else raises:

```
** (TemperCore.Panic) generator step returned nil, not a GeneratorResult
```

That check found the actual bug, which was in Temper's frontend and not in
be-elixir. `CoroutineConverter` moves non-yielding sub-blocks out of the
state machine. It also moved the body of a `for` loop that `continue`s,
whose `continue#13` label the state machine had already dissolved into
cases. The isolated `continue` then had no target, so control fell out of
the dispatcher. A new `hasEscapingJump` keeps any sub-block that jumps to
a label outside itself where it was. A stage test,
`convert-coro/continue-in-yielding-loop`, and a `CoroutineConverterTest`
case cover it.

Fixing that exposed a second bug: a build-time `IndexOutOfBoundsException`
at `inspectBasicBlocks`. A bare `yield` followed by a condition gets an
"afterwards" case, and the code typed a promise temporary for it from
`yieldingCall.child(1)`. Only an `await` has a promise, and only an
`await` has that child. It is now one line:

```kotlin
if (needsAfterwardsCase && yieldingCall?.kind == YieldingFnKind.await) {
```

Probes for `break` after `yield`, `break` after `await`, labeled
`continue`, and `continue` in a `while` now match JS line for line. These
are changes to the shared frontend, so they reach be-rust and be-java as
well. be-rust's control-flow functional tests pass, 6 of 6. be-java's
could not be run on this machine: the harness fails to parse the 4-part
version `21.0.12.1` of the Homebrew JDK, and with JDK 26 it cannot find
`mvn`.

## Done is a getter, not a method

`g.done` on a builtin type used to fall through to
`TemperCore.call(g, :get_done, [])`, which works only for user classes.
The translator now has a `builtinGetters` table (`Generator.done`,
`SafeGenerator.done`, `ValueResult.value`). A getter on a builtin type
that has no entry fails the build with
`TODO("getter X.y has no Elixir support code")`. `is ValueResult` and
`is DoneResult` are tag tests on the result.

## Named arguments, by accident

`FunctionsNamedArgs` passes now, and nobody worked on it. Its last block
returns `empty()`. Generators needed `core.empty()`, so it now has support
code and compiles to the atom `:empty`. It is an atom and not `{}`
because `Empty` must differ from `nil` and survive string interpolation,
and a tuple does not.

## Two agents, one file

The work was done by a workflow: two design agents, then implementation,
then a verify-and-fix stage per feature. The verify stage was a pipeline,
so the generators fixer and the async fixer ran at the same time in the
same worktree, and both edited `ElixirTranslator.kt` and
`CoroutineConverter.kt`. Merging their edits went fine. The test scripts
did not: `ft-all.sh` and `ft-one.sh` each backed up
`FunctionalTestStatus.kt` to a fixed path in `/tmp`, rewrote it, and
restored it. Two overlapping runs restored each other's copy, and for a
while the file had no Elixir `onlyPasses` block at all. The generators
fixer caught it. The scripts now take a `mkdir` lock and back up to a
`mktemp` file, restored by an `EXIT` trap. Every count in this entry comes
from a run with nothing else in the worktree.

**55 of 65** pass, up from 52: `ControlFlowActorRun`, `ControlFlowAsync`,
`FunctionsNamedArgs`.

**Not done:**

- `TypesNetresponse` still fails, with "type not declared here:
  NetRequest", although `TemperCore.Net` exists and decodes the body by
  charset. UTF-8 invalid bytes become U+FFFD, Latin-1 and UTF-16 are
  converted, and any other charset breaks the promise.
- A bare `return;` inside `while (true)` in a generator fails in the
  frontend with "return__16 is not initialized along branches".
- The rest of the list: NaN and infinity, `Float64.near`, regex, `Date`,
  a type as a value, `instanceof JsonArray`, `SemanticsBroken`.
