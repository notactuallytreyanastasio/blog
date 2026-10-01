# 2026-10-01: closures, cells, and failing by name

Thirty-four of Temper's functional tests pass, up from twenty-seven: local
functions, function values, rest parameters, constructor callbacks,
imported values, HelloFromClassToTop and PropertyOrder.

## A closure that counts

Elixir closures capture *values*; Temper closures capture *variables*. This
Temper prints 3:

```temper
let counter(): Int {
  var n = 0;
  let bump(): Void { n += 1; }
  bump();
  bump();
  bump();
  n
}
```

A closure capturing `n` by value would print 0. So a local that any closure
reads, and that is also assigned somewhere, lives in a cell, and the closure
and the function share it:

```elixir
def counter__5() do
  n__9 = TemperCore.Heap.new(:cell, %{:v => 0})
  bump__8 = fn ->
    TemperCore.Heap.put(n__9, :v, TemperCore.int32(TemperCore.Heap.get(n__9, :v) + 1))
    nil
  end
  bump__8.()
  bump__8.()
  bump__8.()
  TemperCore.Heap.get(n__9, :v)
end
```

A boxed variable is never rebound, so loops and branches no longer carry it.

## A function that calls itself

An Elixir `fn` has no name to call itself by. A recursive local function
takes itself as its first argument, as a loop does, and the name the rest
of the program sees is a wrapper that passes it in:

```elixir
ex_rec_3 = fn ex_rec_3, i__14 ->
  if i__14 <= 1 do
    1
  else
    TemperCore.int32(i__14 * ex_rec_3.(ex_rec_3, TemperCore.int32(i__14 - 1)))
  end
end
go__13 = fn i__14 -> ex_rec_3.(ex_rec_3, i__14) end
```

## What the eight `mix` failures were

Last chapter, eight tests got as far as `mix compile` and failed there. The
compiler said exactly why, in each case:

- `undefined variable "normSquared__2"`: an imported name. The importing
  module knows the function under its own name; imports are now resolved to
  the declaring module's name before anything is looked up.
- `undefined function say__6/1 (expected TemperMain.Something to define
  such a function...)`: a class method calling a module function. Module
  functions now always go out qualified, `TemperMain.say__6(...)`, which also
  ends any chance of meeting a Kernel import of the same name.
- `function TemperMain.C.new/0 is undefined ... Did you mean: new/1`: Temper
  drops trailing optional arguments at the call site. They are now passed
  as `nil`, which is what the declared body tests for.
- A file cut off mid-line at `TemperCore.Global.put(:infinity__27,`. The
  literal was `1E999`, infinity, which the renderer refused by throwing,
  and the half-written file was compiled anyway. The translator now refuses
  it by name, so the build fails before any file is written.
- `"7FFFFFFF" is not a Temper object`: a method on a builtin type with no
  support code fell through to `TemperCore.call` and crashed at run time.
  That is now a build failure that names the method.

That last change turned the rest of the failures into a work list:
`method Listed.join has no Elixir support code`, `Listed.map`,
`Listed.sorted`, `ListBuilder.add`, `String.toInt32`, `Float64.near`, and
`type not declared here: StringBuilder`, `Deque`, `DenseBitVector`, `Date`.

**Not done:** that list, plus `@test` blocks, async, generators, and NaN and
infinity, which the BEAM's floats cannot hold.
