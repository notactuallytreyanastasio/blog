# 2026-10-01: a return is not a throw

be-elixir never sees a `return` inside a loop. By the time a function
reaches the backend, the frontend has turned this:

```temper
export let find(xs: List<Int>, want: Int): Int {
  for (var i = 0; i < xs.length; ++i) {
    if (xs[i] == want) { return i; }
  }
  -1
}
```

into an assignment and a `break` out of a labeled block wrapped around the
whole body, with the function's last value as a `return` inside that block.
The js backend writes the shape out almost as it receives it:

```js
export function find(xs_10, want_11) {
  let return_12;
  fn_13: {
    let i_14 = 0;
    while (i_14 < xs_10.length) {
      if (listedGet_6(xs_10, i_14) === want_11) {
        return_12 = i_14;
        break fn_13;
      }
      i_14 = i_14 + 1 | 0;
    }
    return -1;
  }
  return return_12;
};
```

Parsing every generated js file of the probe library below and of `std`,
and counting the `return`s that sit inside a loop of their own function:

```
loopret:  returns 21, inside a loop 0, labeled breaks inside a loop 10
std:      returns 358, inside a loop 0, labeled breaks inside a loop 12
```

That is why the obvious fix does nothing. "A loop that contains a `return`
hands back `{:return, v}` instead of throwing" has no loop to apply to.
The commit records that attempt in one line: it changes nothing, because
no TmpL loop contains a ReturnStatement. The `return` is gone before the
backend looks, and what is left is a `break` to a label outside the loop.

## Two throws for one return

Elixir has no loops, so a loop is a closure that calls itself (guide,
section 6). A `break` was handled by value only when its target was the
loop it sat in. `break fn_13` targets the block around the body, so it
threw. And the `return -1` threw too: a `return` was a value only at the
function's tail, and the inside of a labeled block is not the tail, even
when nothing follows the block but `return return_12`. So `find` became
two nested `try`s and two throws:

```elixir
def find(xs, want) do
  Temper.Loopret.__temper_init__()
  TemperCore.Heap.entry(fn ->
    try do
      return = nil
      return = try do
        i = 0
        ex_loop_2 = fn ex_loop_2, i, return ->
          if i < TemperCore.List.length(xs) do
            if TemperCore.List.get(xs, i) == want do
              return = i
              throw({:temper_break, :ex_block_1, return})
            else
              i = TemperCore.int32(i + 1)
              ex_loop_2.(ex_loop_2, i, return)
            end
          else
            {i, return}
          end
        end
        {_i, _return} = ex_loop_2.(ex_loop_2, i, return)
        throw({:temper_return, :ex_return_0, -1})
      catch
        {:temper_break, :ex_block_1, ex_vars_4} ->
          ex_vars_4
      end
      return
    catch
      {:temper_return, :ex_return_0, ex_value_5} ->
        ex_value_5
    end
  end)
end
```

It worked. Every test passed with it. The cost was what it hid, which
comes up below.

## After

[Fork PR #11](https://github.com/notactuallytreyanastasio/temper/pull/11),
commit [`ee05521d`](https://github.com/notactuallytreyanastasio/temper/commit/ee05521dcc63de7c456f4965f3820476ce411074),
makes `find` this:

```elixir
return = nil
i = 0
ex_loop_2 = fn ex_loop_2, i, return ->
  if i < TemperCore.List.length(xs) do
    if TemperCore.List.get(xs, i) == want do
      return = i
      {:temper_break, :ex_block_1, return}
    else
      i = TemperCore.int32(i + 1)
      ex_loop_2.(ex_loop_2, i, return)
    end
  else
    {:cont, {i, return}}
  end
end
case ex_loop_2.(ex_loop_2, i, return) do
  {:cont, {_i, _return}} ->
    -1
  {:temper_break, :ex_block_1, return} ->
    return
end
```

Three changes to `ElixirTranslator.kt` do it.

**A loop with an exit past it returns that exit.** Before translating a
loop, the translator walks its body for `return`s and for `break`s and
`continue`s whose label is outside the loop. If the list the loop sits in
can take one of those without a throw, the loop is *escaping*: where it
would have thrown `{:temper_break, :ex_block_1, return}` it returns that
tuple, and where it would have ended with `{i, return}` it ends with
`{:cont, {i, return}}`. The call site becomes a `case`. The rest of the
list after the loop goes into the `:cont` clause, and each exit the loop
actually handed back gets one clause, handled as the call site would have
handled the statement: as a value, or passed on.

Passing on is how two loops work. In `pairSum` the inner loop's call site
is inside the outer loop's body, which is itself escaping, so the inner
clause hands the same tuple up as the outer iteration's result:

```elixir
case ex_loop_4.(ex_loop_4, j, n, return) do
  {:cont, {_j, n, return}} ->
    i = TemperCore.int32(i + 1)
    ex_loop_2.(ex_loop_2, i, n, return)
  {:temper_break, :ex_block_1, return} ->
    {:temper_break, :ex_block_1, return}
end
```

The recursive call in the `:cont` clause is still in tail position, since
nothing in a `case` clause follows it.

**A labeled block has what follows it folded into each way out.** The
`break fn_13` and the fall-through past `return -1` both leave the block,
and after the block comes `return return_12`. When the statements after a
block are cheap, the translator translates them again at every way out,
so the `return` after the block becomes the value of the `case` clause
that took the break. "Cheap" is `copyable`: a `return`, an expression
statement or an assignment, of at most 8 nodes. The limit is there
because folding copies: a block with five breaks out of it would carry
five copies of whatever follows it. Anything longer keeps the old `try`
around the block.

**A `try` that ends a function returns from its arms.** `intOr` has no
loop at all:

```temper
export let intOr(s: String, d: Int): Int {
  return s.toInt32() orelse d;
}
```

It was two throws inside a `rescue` inside a `catch`. Now:

```elixir
try do
  TemperCore.String.to_int32(s)
rescue
  _ in TemperCore.Bubble ->
    d
end
```

This is allowed only for the last statement of a function. The end of a
loop body cannot be carried into a `try`: its end is the recursive call,
and a call inside a `try` is not a tail call. Each iteration would keep a
frame, and a bubble raised in a later iteration would be rescued by the
`try` of an earlier one.

## What still throws

One function in the probe library still has a `throw`, `midIf`, a loop
inside an `if` in the middle of the list:

```elixir
{r, _return} = if flag do
  ...
      if x == 3 do
        return = 333
        throw({:temper_break, :ex_block_1, return})
  ...
  {_q, r, return} = ex_loop_2.(ex_loop_2, q, r, return)
  r = TemperCore.int32(r + 1000)
  {r, return}
else
  {r, return}
end
r
```

An `if` in the middle of a list hands its assigned variables back as a
tuple, so its arms cannot end in the function's result; the exit has
nowhere to go but a throw. Folding the rest of the list into both arms
would fix it, at the cost of copying the rest. That was not done.

Counted in the generated code of two real libraries, from the commit
message:

```
marginalia-core   returns 45 -> 0    breaks 17 -> 5   continues 1 -> 1
std               returns 25 -> 8    breaks 21 -> 19
```

std's JSON parser is where most of the remaining ones are. In the probe
library the count went from 22 `throw(`s to 1.

## What Dialyzer sees now, and what it still does not

The point of this was the typespecs from fork
[#7](https://github.com/notactuallytreyanastasio/temper/pull/7). A function
whose result came out of a `catch` had, to Dialyzer, the result of
whatever `throw` it caught, which is anything. So a negative control:
take the probe library generated before and after this change, replace
one function's `@spec` result with the wrong type, and count the spec
warnings Dialyzer reports. Run now, against the same PLT:

```
wrong spec                         before  after
find      :: String.t()               0      0
pairSum   :: integer()                0      0
index     :: String.t()  (a method)   0      0
intOr     :: String.t()               0      0
sign      :: integer()                0      1
none (all specs correct)              0      0
```

The one it catches:

```
SPEC temper_main.ex:366: Invalid type specification for function 'Elixir.Temper.Loopret':sign/1.
```

`sign` has no loop, only early `return`s in an `if`. Its last arm used to
throw, so its result was invisible; now every arm is a string.

The loops are still invisible, and not because of throws. A loop is a
closure that calls itself, `ex_loop_2.(ex_loop_2, i, return)`, and
Dialyzer types the result of calling it `any()`. `find`'s result is now
the result of a `case` over that call, so it is `any()` as surely as it
was when it came out of a `catch`. This change made `find` readable; it
did not make it checkable. Turning loops into named functions, which
Dialyzer can follow, is the next step and is not done.

`intOr` is missed for a different reason: its fallback is the parameter
`d`. Dialyzer's own type for `d` is `any()`, and the spec is checked
against that, not used to narrow it, so the result `integer() | any()` is
`any()` and any spec fits. Changing the generated rescue arm to return `0`
instead of `d`, with the same wrong spec:

```
before  SPEC-TOTAL 0
after   SPEC temper_main.ex:354: Invalid type specification for function 'Elixir.Temper.Loopret':intOr/2.
```

With all specs correct, the warning total for the probe library went from
15 to 14. The one that left was in the old `sign`, which wrapped its arms
in `if true do`, and Dialyzer said of the missing `else`:

```
temper_main.ex:1: The pattern 'false' can never match the type 'true'
```

The commit reports Marginalia's total going from 113 to 89, and two
warnings that are new. They are in orm's `validateFloat`, whose Temper
throws away a parsed float on purpose:

```temper
let parseOk = do { val.toFloat64(); true } orelse false;
```

```elixir
TemperCore.String.to_float64(val)
TemperCore.Heap.put(parseOk, :v, true)
```

```
temper_main.ex:353:29: Expression produces a value of type
        'infinity' | 'nan' | 'neg_infinity' | float(), but this value is unmatched
```

The discard was always there. Dialyzer could not see it while the
function returned through a throw.

## Checked

The probe library is `journal/examples/loopret/`. Rebuilt now with the
backend at `ee05521d`, `temper test` passes 1 of 1 under `-b elixir` and
`-b js`, and its generated Elixir is byte-identical to the "after" build
used for the Dialyzer table.

From the commit: be-elixir's 101 tests pass, and the new one,
`returnsFromLoopsAreNotThrown` (`find`, a two-loop `pairAt`, `intOr`; no
`throw(`, no `catch`), fails on the code before it. alloy 225, templight
140, highlight 11, temper_snake 31 and marginalia-core 35 tests pass with
no compile warnings, and Dialyzer finds no spec warnings in any of them.

The PR is stacked on
[#10](https://github.com/notactuallytreyanastasio/temper/pull/10) and is
merged into the fork's main.
