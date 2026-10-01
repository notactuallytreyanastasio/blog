# 2026-10-01: loops without loops

Eleven of Temper's functional tests pass now, up from one: AlgosFibonacci,
ControlFlowIfReturn, ControlFlowLoops, ControlFlowLoopReenterable,
NamesNonascii, SemanticsConstness, SemanticsTypeCheckedLocals,
TypesIntBasics, TypesListEmpty, TypesStringIsEmpty, and AlgosHelloWorld.

## What a while loop becomes

Elixir has no loops and no reassignment. This Temper

```temper
let sumTo(n: Int): Int {
  var total = 0;
  for (var k = 1; k <= n; ++k) {
    if (k == 3) { continue; }
    total += k;
  }
  total
}
```

comes out as (the indentation is the formatter's, see below)

```elixir
def sumTo__3(n__7) do
  total__9 = 0
  k__10 = 1
  ex_loop_5 = fn ex_loop_5, k__10, total__9 ->
  if k__10 <= n__7 do
    total__9 = if true do
      if k__10 == 3 do
        total__9
      else
        total__9 = TemperCore.int32(total__9 + k__10)
        total__9
      end
    end
    k__10 = TemperCore.int32(k__10 + 1)
    ex_loop_5.(ex_loop_5, k__10, total__9)
  else
    {k__10, total__9}
  end
end
{k__10, total__9} = ex_loop_5.(ex_loop_5, k__10, total__9)
total__9
end
```

and prints 12. The pieces:

- **A local is an Elixir variable, rebound.** Straight-line code needs
  nothing else.
- **A loop is an anonymous function passed to itself**, because an Elixir
  `fn` cannot name itself. It takes and returns the variables the loop
  assigns, and the recursive call is the last thing it does, so the BEAM
  does not grow the stack.
- **An `if` that assigns outer variables returns them.** Variables bound
  inside an Elixir `if` do not escape it, so `total = if ... end`.
- **Exits are folded.** An `if` whose branch always exits takes the rest of
  the statement list into its other branch, so most `return`, `break` and
  `continue` become a value or a recursive call. Temper's `continue` arrives
  from the frontend as a break out of a labeled block, which is the
  `if true do ... end` above.
- **What cannot be folded throws**, and the function or loop it leaves
  catches its own tag. A `return` inside a loop is one: the loop function
  hands back its variables, so the return has nowhere else to go. When a loop
  needs a `try`, its recursive call stays outside it, or it would not be a
  tail call.

## The bug that ran for twenty minutes

The first full run with loops never finished. One BEAM process sat at 100%
CPU for over twenty minutes, inside AlgosFibonacci's generated `fib`:

```elixir
ex_loop_1 = fn ex_loop_1, a__5, b__6 ->
  if i__3 > 0 do
    ...
    i__3 = TemperCore.int32(i__3 - 1)
    ex_loop_1.(ex_loop_1, a__5, b__6)
```

`i` is a parameter, and parameters had not been registered as locals, so
the loop did not carry it: every iteration read the same `i`. The fix is one
line. The lesson is the runner's: a translated program now gets a watchdog
that halts it after 60 seconds with a message, because a test harness that
times out still leaves the BEAM process spinning underneath it.

## Temper's numbers are not the BEAM's

- **Int wraps at 32 bits.** Every `+ - *` on Int is
  `TemperCore.int32(a + b)`.
- **Floats print the way JavaScript prints them, but always with a point:**
  `1.0`, `1.0e+25`, `9.999999999919205e+207`, `-0.0`. Erlang's shortest
  round-trip digits (`float_to_binary(f, [:short])`) are re-laid out by
  ECMAScript's rule in `TemperCore.Float.to_string`, tested against the
  exact strings in Temper's float tests.
- **Temper calls `0.0` and `-0.0` unequal, and orders `-0.0` first.** Since
  OTP 27, `===` already tells them apart; `<` does not, so float comparisons
  go through `TemperCore.Float.lt` and friends.
- **Float division by zero raises** `ArithmeticError` where IEEE gives
  infinity. The BEAM has no infinity. This is a known gap, by name.

## Names

[probes/07_names.exs](probes/07_names.exs): a module may *define*
`length/1`, but an unqualified call to it is a compile error ("imported
Kernel.length/1 conflicts with local function"). Translated names that
collide with Kernel get a trailing underscore; the list is Kernel's own
`__info__`, not a guess.

## The day the disk filled

Mid-session the disk filled and every tool that writes a file failed. I
blamed the test runs' temp directories, and was wrong: there were less than
a megabyte of them. A likelier culprit is the spinning BEAM process above,
which grew without bound. One real casualty: the edit that added the
connected-method table was written while the disk was full and never
landed, which is why `toString` stayed untranslated until it was redone.

**Not done:** classes (18 tests stop there), strings beyond `isEmpty`,
lists beyond reading, closures that assign captured variables, and the
indentation after `fn ... ->`, which is valid and ugly.
