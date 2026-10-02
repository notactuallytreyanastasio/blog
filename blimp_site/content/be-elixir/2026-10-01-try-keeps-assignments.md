# 2026-10-01: what a `do` assigned before it bubbled

The reviewer of entry 34 read diffs. This entry's bug came from the other
method in the decision graph: programs written to break the backend, run
under elixir, js and py, and diffed. About twenty of them; the worst
divergence was a wrong answer, not a crash.

```temper
let fail(b: Boolean): Void throws Bubble { if (b) { bubble() } }
let f(b: Boolean): Int {
  var x = 0;
  do { x = 1; fail(b); x = 2; } orelse do { x += 10; }
  x
}
var t = true; t = t;
console.log("${f(t)} ${f(!t)}");
```

```
js     11 2
py     11 2
elixir 10 2
```

## Why the inputs are not literals

`var t = true; t = t;` is there on purpose. Called with constants, `f(true)`
is run by Temper's frontend at compile time, and the Elixir program only
prints the string the frontend worked out. About half of the first runs that
"agreed" were agreeing about what the compiler had already computed. Every
test for this entry reads its inputs from a variable.

## A binding inside `try` stays inside it

```elixir
x = try do
  _x = 1
  Temper.MinOrelseLostAssign.fail__2(b)
  x = 2
  x
rescue
  _ in TemperCore.Bubble ->
    x = TemperCore.int32(x + 10)
    x
end
```

A `do` is a `try`, and an Elixir binding made inside `try` is gone when the
raise unwinds to `rescue`, which sees `x` as it was before. The tidy pass
then saw `x = 1` as a binding nobody reads and named it `_x`, which was
accurate. The same thing broke a counter in a loop that bubbles out of the
`do` (`count=0`, not 3), a `do` inside a loop (`last=-1`, not 9), and nested
`do` blocks.

The backend already had a fix for this shape. Elixir closures capture
values and Temper closures capture variables, so a local a closure assigns
lives in a heap cell (section 7 of the guide). A local assigned in a `do`
body and declared outside it now goes in a cell for the same reason: a cell
is written in place, and the write is still there after the raise. The
lowering of `try` already left cells out of the values it carries out, so
nothing else changed.

```elixir
x = TemperCore.Heap.new(:cell, %{:v => 0})
try do
  TemperCore.Heap.put(x, :v, 1)
  Temper.MinOrelseLostAssign.fail__2(b)
  TemperCore.Heap.put(x, :v, 2)
  ...
```

The rule is wider than it has to be: it boxes every outer local a `do`
assigns, not only the ones assigned before something that can bubble. A
cell costs a heap read and write per access, only for those locals.

## A raise stored in a cell

The first version of this entry passed its tests and the programs above,
and was committed without the count that entry 23 promises stays at zero:
warnings on valid programs. The next entry's checks counted them, and
alloy, which had none, printed 55:

```
warning: incompatible types given to TemperCore.Heap.put/3:
    TemperCore.Heap.put(t1, :v, raise(TemperCore.Panic.exception([])))
```

The frontend lowers `x orelse panic()` by assigning a temporary in a `do`,
with `panic()` on the `orelse` side. That temporary is now a cell, so the
`orelse` side stores a raise into it. Entry 23's tidy pass already turned
`t1 = raise(...)` into the raise alone; it now does the same for a raise
stored into a cell, and ends the block there. alloy, prismora, templight,
blimp-highlight, temper_snake and the `main` example are back to no
warnings.

## Checking

Two `ElixirBackendTest` cases, each red first: the assignment that reaches the `orelse`, and the raise stored in a cell. The program above and the
`partial` and `break-in-try` programs from that session, five lines of
difference between them, now match js and py exactly. The objects, control
flow, generators and closures programs are unchanged (the remaining
differences there are py's own: per-iteration `let` capture, `nextSafe`
after done). 65 of 65 functional tests pass.

Still open from the same session: a local function that captures a local
declared after it is hoisted does not compile, `<=>` on Float64 orders by
the BEAM's term order, and `"".indexOf` on an empty pattern raises
ArgumentError. The next entries.
