# 2026-10-02: a loop is a named function

Entry 45 ended on a negative control that failed: give `find`, a
two-loop `pairSum` and a method `Finder.index` return specs naming the
wrong type, and Dialyzer says nothing, before that change or after it.
Entry 41's writer found the same of `total`, which has no `throw` in it
at all. The reason was the loop itself. A loop was a closure passed to
itself:

```elixir
ex_loop_1 = fn ex_loop_1, i, total ->
  if i < TemperCore.List.length(xs) do
    ...
    ex_loop_1.(ex_loop_1, i, total)
  else
    {i, total}
  end
end
{_i, total} = ex_loop_1.(ex_loop_1, i, total)
```

Dialyzer types a call through a closure argument `any()`. Whatever came
out of a loop was `any()`, `any()` overlaps every spec, and so a function
whose result came from a loop could claim anything.

## A named function, with a `term()` spec

The fix is a `defp` beside the function the loop came from. Every
generated function must have a spec (entry 41), and a loop's variables
have no handy Temper types, so the spec would be `term()` throughout. If
Dialyzer took that spec at its word, the whole idea would fail, so that
was checked first, by hand, on `find`:

```elixir
@spec find([integer()], integer()) :: String.t()   # false on purpose
def find(xs, want) do
  case find_loop(xs, want, 0, nil) do ...

@spec find_loop(term(), term(), term(), term()) :: term()
defp find_loop(xs, want, i, return) do ...
```

```
Invalid type specification for function 'Elixir.Probe.Termspec':find/2.
 The success typing is 'Elixir.Probe.Termspec':find ([any()], _) -> integer()
 But the spec is ... -> 'Elixir.String':t()
 The return types do not overlap
```

The same with no spec on `find_loop`. Dialyzer infers a named function's
result from its body whatever its spec says, so the `term()` spec costs
nothing. The generated code now reads:

```elixir
def sum(xs) do
  ...
  {_i, total} = sum_loop_1(xs, i, total)
  total
end

@spec sum_loop_1(term(), term(), term()) :: term()
defp sum_loop_1(xs, i, total) do
  if i < TemperCore.List.length(xs) do
    total = TemperCore.int32(total + TemperCore.List.get(xs, i))
    i = TemperCore.int32(i + 1)
    sum_loop_1(xs, i, total)
  else
    {i, total}
  end
end
```

and every false spec in the control is caught:

| false spec on | closure (before #11) | closure (#11) | `defp` |
|---|---|---|---|
| `find` | not caught | not caught | caught |
| `pairSum` | not caught | not caught | caught |
| `Finder.index` | not caught | not caught | caught |
| `labeled` | | | caught |
| `skipping` | | | caught |

A new gate test, `dialyzerSeesThroughLoops`, makes `total`'s and `upTo`'s
specs false and expects to be told. It fails on the commit before.

## What a loop is passed

A closure captured whatever it read. A `defp` has to be passed it, and
working that out from Temper's references would miss what the translator
writes into a loop on its own: a cell, a recursive local function's
`self`, the variables a `break` to an outer loop carries. But the backend
already had the answer on the Elixir side. Tidy's liveness pass (entry 23)
works out, for every block, what it reads before binding it, so it can
prefix unread bindings with `_`. Run on a copy of the loop, the same pass
gives its free variables. A name it missed would be an undefined variable
at compile time, not a wrong value.

Two things went wrong on the way, both caught by the first build of std:

- The loop's calls to itself have its free variables put in front of
  their arguments once those are known. The generated tree's setter for a
  call's arguments empties the list it replaces, and the first version
  kept a reference to that list, not a copy: `find_loop_2(want, xs)`, two
  arguments short.
- The calls were remembered as they were made, and `afterSubstring_loop_14(i, j, return)`
  still came out without its free variables. An `if` whose other branch is
  another `if` is written as a `cond`, from deep copies of both, so the
  call in the tree was not the call remembered. The calls are now found by
  walking the finished body.

## `while (true)`

Once Dialyzer could see into loops, it found patterns that can never
match: the `else` of `if true do`, and the `{:cont, _}` clause after a
`while (true)` that only ever leaves by `return`. A `while (true)` loop is
now its body alone, and when nothing breaks out of it, its call site has
no clause for its ending. snake's generator loop:

```elixir
convertedCoroutine1 = fn generator1 ->
  case fn__loop_1(awaited1, awaited2, awaited3, awaited4, caseIndex1, generator1, msg, ws) do
    {:temper_return, :ex_return_1, ex_value_7} ->
      ex_value_7
  end
end
```

## Checked

be-elixir's 102 tests pass, and alloy (225), templight (140), highlight
(11), temper_snake (31), mainclash (1) and marginalia-core (35) pass with
no compile warnings and no spec warnings. Dialyzer's other warnings fell
with the loops visible and the `while (true)` noise gone:

| library | before | after |
|---|---|---|
| marginalia-core | 89 | 20 |
| templight | 27 | 14 |
| alloy | 19 | 17 |
| highlight | 17 | 14 |

marginalia-core's never-matching patterns went from 73 to 4. Speed did not
move: a million-item indexed sum takes 10 ms as a `defp` and took 11 as a
closure; building the list, 188 ms against 184.

## Still not checked

A value typed by a spec's type variable, such as a map's value from
`get_or`, is `term()`, since Dialyzer does not instantiate type variables
at a call.

Merged as [temper#13](https://github.com/notactuallytreyanastasio/temper/pull/13),
commit [041b67a8](https://github.com/notactuallytreyanastasio/temper/commit/041b67a8).
