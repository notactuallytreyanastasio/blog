# 2026-10-01: typespecs, and a Dialyzer that checks them

The first Dialyzer check of the generated typespecs passed with false specs
in it. Give eight exported functions a return spec their code contradicts
(`flip` returns `integer()`, `shout` returns `integer()`, `upTo` returns
`integer()`, and so on) and put `TemperCore.Heap.entry` back the way it was
before this chapter:

```
### false8-entryfn
SPEC-TOTAL 0
```

Zero. Every exported function runs its body as
`TemperCore.Heap.entry(fn -> ... end)`, and `entry` was a function that took
the closure and called it. To Dialyzer a function that calls a closure it
was handed returns `any()`, and `any()` overlaps every spec. So the check
could not find any exported function's return spec false, whatever it
said. A green Dialyzer run here meant only that nothing was being compared.

This chapter is fork PR
[#7](https://github.com/notactuallytreyanastasio/temper/pull/7)'s
typespec half (its other half, five runtime fixes from a review of #5, is
not covered here) and one commit pushed to the fork's `main` after it merged:

| | |
|---|---|
| [a93b6577](https://github.com/notactuallytreyanastasio/temper/commit/a93b6577780059d67410be32e7988d314a886b6f) | generated code has typespecs, and Dialyzer checks them |
| [62dddaef](https://github.com/notactuallytreyanastasio/temper/commit/62dddaefeffb208aa6d9a1f7e722af36ab7f2e65) | a nil check is a case, which Dialyzer can follow |
| [39f7b8e3](https://github.com/notactuallytreyanastasio/temper/commit/39f7b8e386e888255120f93173e03ef5a56299a2) | temper-core: every public function has a spec, and Dialyzer agrees |
| [94efe3e0](https://github.com/notactuallytreyanastasio/temper/commit/94efe3e041321a6858bc33d51367de8fa2fd99c4) | the Dialyzer test may take longer than the build's 30 s default |

Everything in this entry was rerun at 94efe3e0, with Elixir 1.19.5 on OTP
28. The probe is `journal/probes/11_dialyzer/`, and `run.sh` there
reproduces every table below.

## What the specs say

Every `def` in generated code now has an `@spec`, and every class module an
`@type t`. From `ElixirTypespecTest`'s fixture, built with the CLI:

```elixir
defmodule Temper.Fixture.Point do
  defstruct [:x, :y]
  @type t() :: %Temper.Fixture.Point{x: integer(), y: integer()}
  ...
  @spec plus(Temper.Fixture.Point.t(), Temper.Fixture.Point.t()) :: Temper.Fixture.Point.t()

defmodule Temper.Fixture do
  require TemperCore.Heap
  @spec total(TemperCore.Vec.t(integer())) :: integer()
  @spec firstOrNull(TemperCore.Vec.t(String.t())) :: String.t() | nil
  @spec greet(String.t(), String.t() | nil) :: String.t()
  @spec twice((integer() -> integer()), integer()) :: integer()
```

`ElixirTypespecs.kt` maps a Temper type to the type its values actually have
on the BEAM, not to the nearest Elixir name. `Float64` is
`TemperCore.Float.t()`, because a float here may also be `:infinity`,
`:neg_infinity` or `:nan` (entry 10). `List<T>` is `TemperCore.Vec.t(t)`.
A heap class is `TemperCore.Ref.t()`, an `@imu` class its struct field by
field. An optional parameter gains `| nil`, since an omitted argument arrives
as `nil`. A function that `throws Bubble` returns its pass type, and an
abstract method, whose body only raises, is `no_return()`. A builtin type
with no row is a `TODO("no Elixir type for ...")`, so a new builtin fails
the build by name instead of getting `term()`.

Types are grammar nodes of their own in `elixir.out-grammar` (`TypeSpec`,
`TypeDef`, `LocalType`, `RemoteType`, `UnionType`, `StructType`, `FunType`,
`ListType`, `TupleType`), not expressions. The obvious shortcut is to build
`@spec f(a) :: b | nil` out of the expression nodes that already exist.
That is wrong because `::` and `|` mean other things in an expression (`|`
is the cons in `[h | t]`), and a spec built from them can render as text
that parses but is not the type meant. The formatter needed one change: it
broke the line after every `->`, which is right for a clause and splits
`(integer() -> integer())` in two. A function type's arrow is now its own
token, and the hints do not break after it.

## Three changes before the check checked

**`Heap.entry` is a macro.** The function it replaced:

```elixir
def entry(fun) do
  case Process.get(@depth, 0) do
    0 ->
      ...
      try do
        result = fun.()
```

Now `entry` matches the literal `fn -> body end` at compile time and expands
to `enter`/`leave` around the body inline, so the call's value is the body's
own:

```elixir
defmacro entry({:fn, _, [{:->, _, [[], body]}]}) do
  quote do
    heap = TemperCore.Heap.enter()
    try do
      result = unquote(body)
      TemperCore.Heap.leave(heap, [result])
      result
    catch
      kind, reason ->
        TemperCore.Heap.leave(heap, [])
        :erlang.raise(kind, reason, __STACKTRACE__)
    end
  end
end

defmacro entry(fun), do: quote(do: TemperCore.Heap.run(unquote(fun)))
```

The generated text does not change at all; `shout` still reads
`TemperCore.Heap.entry(fn -> ... end)`. What changes is that every module
`require TemperCore.Heap`, and an actor, which runs a method body it holds
as a value, calls `Heap.run/1`. The commit also names the fix that looks
cheaper and does not work: a spec on `entry` with a `when` type variable,
saying it returns what the closure returns. Dialyzer does not unify a
spec's type variable at a call site, so the result is still `any()`.

**temper-core has specs.** It had none before a93b6577 and four after it;
39f7b8e3 brings it to 214. With the macro in place but temper-core as of
62dddaef, the same eight false specs are caught five times, and `shout` is
missed:

```
### false8-core62
SPEC temper_main.ex:220: Invalid type specification for function 'Elixir.Temper.Fixture':half/1.
SPEC temper_main.ex:231: ... big/1.
SPEC temper_main.ex:238: ... flip/1.
SPEC temper_main.ex:262: ... upTo/1.
SPEC temper_main.ex:281: ... contains/2.
SPEC-TOTAL 5
```

`shout` ends in `TemperCore.StringBuilder.to_string(sb)`, which was
`Heap.get_value(sb)` with no spec: `any()` again. With
`@spec to_string(TemperCore.Ref.t()) :: String.t()` it is caught:

```
SPEC temper_main.ex:252: Invalid type specification for function 'Elixir.Temper.Fixture':shout/1.
 The success typing is 'Elixir.Temper.Fixture':shout
          (binary()) -> binary()
 But the spec is 'Elixir.Temper.Fixture':shout
          ('Elixir.String':t()) -> integer()
 The return types do not overlap
```

39f7b8e3 says that before its specs, "of four exported functions given a
false return spec on purpose, Dialyzer caught one". The commit does not
name the four, and I could not reproduce that figure; on this fixture it is
five of eight before and six of eight after.

**A null check is a `case`.** Run over Marginalia's Temper, the check gave
one warning (quoted from 62dddaef):

```
The success typing for 'Elixir.Temper.MarginaliaCore':byWindows/1
implies that the function might also return 'nil' but the
specification return is #{'__struct__' := 'Elixir.TemperCore.Vec', ...}
```

`byWindows` ends `finish(out.toList()) ?? []`, which cannot return nil. The
frontend writes `??`, like every null check, as an `if` on `x === nil`, and
Dialyzer does not narrow a variable through a boolean test: in the `else`
branch, `x` still has its nil. It does narrow through a pattern, so an `if`
whose test is `x === nil` or `x !== nil` on a variable is now a `case`. The
probe's `orEmpty(n) { wrap(n) ?? [] }` generates:

```elixir
subject = Temper.Fixture.wrap(n)
case subject do
  nil ->
    %TemperCore.Vec{t: {}}
  subject ->
    subject
end
```

Written back as the `if` it was, the same function draws the same warning
Marginalia did:

```
### ifnil
SPEC temper_main.ex:319: The success typing for 'Elixir.Temper.Fixture':orEmpty/1 implies that the function might also return
          'nil' but the specification return is
          #{'__struct__' := 'Elixir.TemperCore.Vec', 't' := tuple()}
SPEC-TOTAL 1
```

## The negative controls

`ElixirTypespecTest.dialyzerFindsNoSpecTheCodeContradicts` generates a
library that reaches every row of the mapping, copies temper-core beside it,
and runs `dialyze.exs` over both. `dialyze.exs` splits Dialyzer's warnings
into `SPEC` (a spec the code contradicts, a call that breaks one, a type that
does not exist) and the rest, and the test fails unless `SPEC-TOTAL 0`. The
controls, all at 94efe3e0:

| variant | SPEC-TOTAL | named |
|---|---|---|
| as generated | 0 | |
| `boolean()` mapped to `integer()` | 2 | `flip/1`, `contains/2` |
| eight false return specs | 6 | `half`, `big`, `flip`, `shout`, `upTo`, `contains` |
| the same, `entry` a function | 0 | |
| the same, temper-core before its specs | 5 | `shout` missed |

Two of the eight are never caught. `lookup` returns
`TemperCore.Map.get_or(m, k, -1)`, whose spec is
`value | fallback when value: term(), fallback: term()`, and Dialyzer does
not instantiate a spec's type variables at a call, so the result reaches
`lookup` as `term()`.

The commit and the README give the reason for `total` as "returns through a
`throw` from its loop". That is not what the fixture's `total` does. It has
no early return and no `throw`:

```elixir
ex_loop_1 = fn ex_loop_1, i, t ->
  if i < n do
    ...
    ex_loop_1.(ex_loop_1, i, t)
  else
    {i, t}
  end
end
{_i, t} = ex_loop_1.(ex_loop_1, i, t)
t
```

The loop is a closure passed to itself. At the call, `ex_loop_1` is a
parameter of the closure, so Dialyzer types its result `any()`, and `t`
comes out of the tuple as `any()`. Rewrite that loop by hand as a `defp`
that calls itself by name and the false spec on `total` is caught:

```
### total-defp
SPEC temper_main.ex:156: Invalid type specification for function 'Elixir.Temper.Fixture':total/1.
...
SPEC-TOTAL 7
```

So the gap is wider than the README says: no function whose result comes
out of a loop has its return spec checked, early return or not. A `throw`
is `any()` too, but `total` does not show it. "Loops as named `defp`s
instead of self-passed closures" is already on #7's list of design
questions from the review; this is a second reason for it. Arguments are
still checked at every call either way.

## A spec that is true, and a check that fails it

The fixture only has functions that pass the check. This one, from the
probe's `passthru/`, does not:

```temper
export let nonEmpty(xs: List<Int>): List<Int>? {
  if (xs.length > 0) { xs } else { null }
}
```

```
SPEC temper_main.ex:3: The success typing for 'Elixir.Temper.Passthru':nonEmpty/1 implies that the function might also return
          [any()] but the specification return is
          'nil' |
          #{'__struct__' := 'Elixir.TemperCore.Vec', 't' := tuple()}
SPEC-TOTAL 1
```

temper-core accepts a plain Elixir list wherever Temper expects a `List`
(`@type list_in(elem) :: Vec.t(elem) | [elem]`, so Elixir callers can pass
`[1, 2, 3]`), and `TemperCore.List.length/1` says so in its spec. Dialyzer
infers that `xs` may be a plain list, sees it handed back, and
`dialyze.exs` turns on `:extra_return`, which reports a success typing
wider than the spec. A caller that keeps to the spec passes a `Vec` and
gets a `Vec`, so the spec is not wrong. But any Temper function that returns
a `List` parameter it has called a list operation on fails this gate today,
and the fixture does not have one. `same(xs) { xs }`, with no list
operation, passes.

## What the specs found

Writing specs that Dialyzer had to agree with found things that were wrong
before any spec existed (from a93b6577 and 39f7b8e3):

- **std's `runTestCases` would have crashed.** `processTestCases` was
  connected to `TemperCore.Test.process/1`, which answers with an Elixir
  list of `{name, failures}` tuples. The translated `reportTestResults`
  reads each result's `.key` and `.value`. The test harness never calls
  `runTestCases`, so no test saw it. It is now `process_cases/1`, a Temper
  `List` of `Pair`s whose failures are `List`s, as std's signature says.
- **`Test.messages/1` returned a plain list** where std declares
  `List<String>`. It returns a `Vec` now.
- **`Heap.collect/1` miscounted.** It counted a freed object with
  `Process.delete(k) && true`, which answers the deleted value, so an
  object holding `nil` or `false` was freed and not counted.
- **Five functions ended `Heap.put(...) && nil`**, and two `for_each`s
  ended `Enum.each(...) && nil`, testing a value that is always `:ok`. They
  do the write and then return `nil`.
- **`Float.near/4` disagrees with Python's `math.isclose`** for an infinite
  `rel_tol` or a NaN `abs_tol`. Found, not fixed.

Two changes are only for Dialyzer: `String.to_float64` was
`parse(s) || raise(...)`, and Dialyzer cannot see that `||` leaves no nil,
so it is a `case`; and `Regex.replace` returned `text` untouched on no
match with nothing saying `text` was a binary, so it has an `is_binary`
guard.

Spec warnings over other libraries, quoted from 39f7b8e3 (spec warnings /
all warnings): alloy with std 0/42 (98 before any specs), templight 0/30,
blimp-highlight 0/20, temper_snake 0/16, mainclash 0/14. Marginalia's
Temper, after 62dddaef: 0 spec warnings, 26 Temper tests passing, 0 compile
warnings. The rest of the warnings are not about specs; most are MapSet
opacity in temper-core's heap, which the probe's runs also show:

```
OTHER temper_core.ex:537:39: The call 'Elixir.MapSet':difference
```

## The test that timed out in CI

The gate runs inside `:be-elixir:jvmTest`, so CI on upstream
[temperlang/temper#507](https://github.com/temperlang/temper/pull/507),
which proposes the fork's `main`, ran it as soon as #7 merged. The
[run](https://github.com/temperlang/temper/actions/runs/36951729729) at
39f7b8e3:

```
ElixirTypespecTest[jvm] > dialyzerFindsNoSpecTheCodeContradicts()[jvm] FAILED
    java.util.concurrent.TimeoutException: dialyzerFindsNoSpecTheCodeContradicts() timed out after 30 seconds
97 tests completed, 1 failed
> Task :be-elixir:allTests FAILED
BUILD FAILED in 23m 27s
```

The test already waited up to ten minutes for the Dialyzer process, so a
slow Dialyzer looked handled. It was not: `build.gradle` gives every test a
30-second default, and JUnit stops the test long before `waitFor` returns.
On a fresh runner the first thing `dialyze.exs` does is build a PLT of
Erlang/OTP and Elixir. Locally it is cached in `build/dialyzer/base.plt`
after the first run; built from nothing it took 18 s on the machine the
commit was written on, and on the runner longer than 30. 94efe3e0 puts `@Timeout(15 minutes)` on the test, past
its own ten-minute wait, so a Dialyzer that is only slow passes and one
that hangs fails with its own output rather than JUnit's. The commit checked
that the annotation governs it by lowering the build default to 5 s for one
run: the test still passed. The
[next run](https://github.com/temperlang/temper/actions/runs/36953899416),
at 94efe3e0, is green.

The commit went straight to the fork's `main`, not through a PR, since that
branch is #507's head.

## Left as is

- A function whose result comes out of a loop closure, or from a spec's type
  variable (`get_or`), has its return spec unchecked.
- A function that returns a `List` parameter after a list operation on it
  fails the gate with a spec that is true for spec-keeping callers.
- `Float.near/4` with an infinite `rel_tol` or a NaN `abs_tol`.
- The non-spec warnings (42 in alloy) are left; the gate counts only spec
  warnings.

be-elixir after 39f7b8e3, from the commit: 17 backend, 64 functional, 13
grammar, 1 support-code and 2 typespec tests; ktlint and detekt clean.
temper-core 106 tests, three runs, and `mix compile --warnings-as-errors`
clean.
