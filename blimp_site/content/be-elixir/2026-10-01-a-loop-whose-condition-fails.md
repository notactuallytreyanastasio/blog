# 2026-10-01: a loop whose condition fails while compiling

On today's Temper, Marginalia's Temper does not build. It fails before any
backend runs, so every backend fails the same way:

```
$ temper build -b js
Exception in thread "main" java.lang.IndexOutOfBoundsException: Index -1 out of bounds for length 0
	at lang.temper.common.SequenceCollectionsCompatKt.compatRemoveLast(SequenceCollectionsCompat.kt:30)
	at lang.temper.interp.Interpreter.interpretBlock(Interpreter.kt:877)
```

That is the CLI built from the fork's `main`, which is upstream `e9ff0d25`
plus be-elixir. The loop behind it is in Marginalia's `text.temper.md`, and
it cannot bubble:

```temper
let trim(s: String): String {
  var b = String.begin;
  while (s.hasIndex(b) && isTrimSpace(s[b])) { b = s.next(b); }
  ...
```

The fix is
[notactuallytreyanastasio/temper#6](https://github.com/notactuallytreyanastasio/temper/pull/6),
commit
[2c89d606](https://github.com/notactuallytreyanastasio/temper/commit/2c89d6066b493052cf216270021623340c2ef42b).
Its message explains the crash with a loop whose condition does bubble. That
explanation is right about the interpreter, but it is not what happened in
Marginalia. This entry covers both.

## A loop pops itself twice

The frontend evaluates a call whose arguments are all constants while it
compiles. It does this at several stages. A loop being evaluated sits on
the interpreter's evaluation stack, and each time round, the loop handler
evaluates the condition:

```kotlin
InProgress.LoopState.BEFORE_CONDITION -> {
    var runBody = false
    when (val r = interpretChild(cf.condition, ast, TBoolean)) {
        NotYet -> { result = NotYet }
        is Fail -> handleFail(r)
        is Value<*> -> { runBody = TBoolean.unpack(r) }
    }
    if (!runBody) {
        // Pop the loop
        popped(evaluation.stack.compatRemoveLast())
    }
}
```

`handleFail` pops the stack until it reaches an `orelse`. If there is none,
it leaves the stack empty and records the failure as the result. In both
cases the loop is already off the stack. But `runBody` is still `false`, so
the handler goes on to the "condition was false" branch and pops again.
When the stack is empty, that second pop is the `Index -1` above.

The `if` handler next to it does not have this bug, because it pops itself
before it evaluates its condition. The fix records that the condition
failed and skips the second pop:

```kotlin
is Fail -> {
    // handleFail has already unwound the stack past this loop,
    // to the nearest orelse or to empty.
    failed = true
    handleFail(r)
}
...
if (!runBody && !failed) {
```

The commit message adds that with an `orelse` on the stack, the second pop
would remove the else clause `handleFail` had just pushed, which would give
a wrong answer rather than a crash. I could not build a program that does
this. With `do { while (i < s.toInt32()) { ... } } orelse do { i = -5; }`
inside one function, fork `main` still crashes at line 877 with an empty
stack, and the fixed build prints `-5`. The same thing at module level
prints `-5` on both builds. In both programs the `orelse` was not on the
loop's stack, so that part of the message comes from reading the code and
has not been checked.

## Two ways a condition fails

The commit's example has a condition that really fails. `"abc".toInt32()`
bubbles:

```temper
let countBelow(s: String): Int throws Bubble {
  var i = 0;
  while (i < s.toInt32()) { i += 1; }
  i
}
console.log((countBelow("abc") orelse -1).toString());
```

Marginalia has nothing like this. Its loop conditions guard every index
with `hasIndex`, so I logged every loop-condition failure the interpreter
saw while building Marginalia. To do that, I added one `println` to the
`is Fail` branch of a fixed build. Over the whole build there was exactly
one:

```
LOOPFAIL stage=@T im=Full cond=(Block (stmt-block (if (Call (V do_call_hasIndex) (R s__1394) (R b__1396))
  (stmt-block (Call (V fn isTrimSpace) (Call (V do_call_get) (R s__1394) (R b__1396)))) (stmt-block (V false))))
  fail=fail(Interpreting)
```

That is `trim`'s first loop, reached from a reflow test that calls
`isWrapped` on a constant. The `&&` has already become an `if`, so
`s[b]` is read only where the index exists. The failure has no message of
its own. `Interpreting` is the label `interpretChild` puts on a `Fail` that
arrives without one. This failure comes from the interpreter itself, at an
early stage (`@T`), not from anything the program raises.

The smallest loop I found that does this has no strings and nothing that
can bubble:

```temper
let countTo(limit: Int): Int {
  var n = 0;
  while (n != limit) { n += 1; }
  n
}
```

```
LOOPFAIL stage=@T im=Full cond=(Call (V nym`!`) (Call (V nym`==`) (R n__4) (V 2)
  (V nym`do_call__==_`[EqIntInt, EqIntInt, EqFltFlt, EqStrStr, EqBoolBool]))) fail=fail(Interpreting)
```

At `@T` the `==` is still a set of five overloads, and the interpreter
answers with a failure. `while (n < 2)` gives no failure. `while (n < 2 &&
n != 7)`, `while (!(n == 2))` and `while (n != 2)` all crash fork `main`.
I have not traced why `!=` fails at that stage and `<` does not. What
matters for the crash is that any failure counts: a real bubble, or the
interpreter giving up on a condition it will finish at a later stage.

It does finish. The fixed build leaves the stack alone, the early
evaluation gives up, and a later stage folds the call:

```elixir
IO.puts("countBelow=" <> TemperCore.int_to_string(TemperCore.Global.get(:"Temper.Loopcond.t")))
IO.puts("countTo=" <> TemperCore.int_to_string(2))
IO.puts("leadingSpaces=" <> TemperCore.int_to_string(2))
```

`countBelow("abc")` really bubbles, so it is not folded. It stays a call
inside `try`/`rescue TemperCore.Bubble`, and it runs at run time.

This is also why Marginalia built before. The CLI built on Sep 20 from
temper-blimp's own `temper/` crashes on `countBelow`, but folds `countTo`
and `leadingSpaces` and prints `2` for each. The bug is old. Today's
frontend reaches it on conditions the older one evaluated without a
failure. The commit message's explanation for Marginalia's crash, "today's
frontend evaluates more of Marginalia's text logic ... and that code is
full of loops whose conditions can bubble", is wrong about the loop that
did it. The fix is the same either way, because both kinds of failure go
through the same branch.

[`examples/loopcond/`](examples/loopcond/) contains all three loops.
Each one alone crashes fork `main`. With #6 applied:

```
$ temper run -b elixir --library loopcond -w .
countBelow=-1
countTo=2
leadingSpaces=2
```

js and py print the same.

## Where the test went

The obvious place for a regression test is `InterpreterTest`, next to the
interpreter. It cannot show this bug. It defines its own `while` as a
Kotlin special function: a native `while` loop that evaluates the condition
and returns `Fail` directly when the condition fails:

```kotlin
ParsedName("while") to makeSpecialValue body@{ macroEnv ->
    ...
    when (val r = args.evaluate(i, InterpMode.Full)) {
        is Fail, NotYet -> return@body r
```

A test written there never builds the lowered `ControlFlow.Loop` that a real
build runs through `interpretBlock`, so it passes with or without the fix.
The test is in the shared functional suite instead, as a new section of
`control-flow/bubble/bubble.temper.md` with the `countBelow` program and
expected output `-1`. The interpreter runs that suite as
`InterpreterFunctionalTests` (which is in `frontend`, not `interp`), and so
does every backend. I built fork `main` with #6 applied, and then the same
tree with only `Interpreter.kt` reverted:

```
                                                  with #6   Interpreter.kt reverted
InterpreterFunctionalTests.controlFlowBubble      passed    IndexOutOfBoundsException: Index -1 out of bounds for length 0
ElixirFunctionalTest.controlFlowBubble            passed    IndexOutOfBoundsException: Index -1 out of bounds for length 0
```

The test's prose repeats the commit's account. It also says the interpreter
"unwound to the `orelse` and then popped the loop a second time, from an
empty stack", which cannot both be true on one stack. In this program the
`orelse` is in the caller, outside the evaluation of `countBelow("abc")`,
so the stack it unwinds is empty. The test only covers a loop whose
condition bubbles. No test covers a condition the interpreter gives up on,
like `n != limit`, though the fix covers both.

The commit reports interp's 76 tests and frontend's 703 passing, with
ktlint and detekt clean. I have not rerun those.

## What is still broken

*Update, 2026-10-02:* #6 merged into the fork's `main` on 2026-10-02 as [b77cfcdf](https://github.com/notactuallytreyanastasio/temper/commit/b77cfcdf06715984a4584e521710260deb9e13a7). What follows describes the day this was
written, before that merge.

#6 is open and is not on the fork's `main`. So the fork's `main`, and
[temperlang/temper#507](https://github.com/temperlang/temper/pull/507),
which proposes it upstream, still crash on Marginalia and on all three
loops above. The scratch tree that later chapters used to build Marginalia
has the patch applied by hand and staged, not committed. With fork `main`
plus #6, the workroot that holds Marginalia's two libraries, `alloy` and
`marginalia-core`, passes under `-b elixir`:

```
$ temper test -b elixir
Tests passed: 225 of 225
```

That run uses a scratch copy whose `_connected.ex` defines
`Temper.MarginaliaCore.Connected`. The file committed for
[marginalia#6](https://github.com/notactuallytreyanastasio/marginalia/pull/6)
still defines `TemperConnected`, and fork `main` plus #6 rejects it once the
frontend gets through:

```
java.lang.IllegalStateException: _connected.ex must define `Temper.MarginaliaCore.Connected`,
  the module this library's @connected functions call; it defines `TemperConnected`
```

That is Marginalia's file not keeping up with the backend, not the
interpreter.
