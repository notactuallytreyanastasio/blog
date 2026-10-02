# 2026-10-01: a hoisted function, made too early

The second divergence from the programs written to break the backend was
not a wrong answer but a module that would not compile:

```temper
let f(n: Int): Int {
  let base = n * 10;
  let a(k: Int): Int { b(k) + 1 }
  let b(k: Int): Int { base + k }
  a(n)
}
```

js and py print `34 23`. be-elixir's Elixir stopped at `mix compile`:

```
error: undefined variable "base"
  5 │       TemperCore.int32(base + k1)
```

## The order the frontend hands over

```elixir
def f__3(n) do
  b = TemperCore.Heap.new(:cell, %{:v => nil})
  TemperCore.Heap.put(b, :v, fn k1 ->
    TemperCore.int32(base + k1)
  end)
  _base = TemperCore.int32(n * 10)
  a = fn k2 ->
    TemperCore.int32(TemperCore.Heap.get(b, :v).(k2) + 1)
  end
  a.(n)
end
```

`b` came out above `base` because the frontend put it there: `a` calls `b`
before `b` is declared, so `b` is hoisted, as js hoists a function. In js
that is harmless, since a closure captures the variable and `base` is bound
by the time `b` runs. An Elixir closure captures values when it is made,
and `base` had no value yet.

The cell made at the top is the part that has to stay: `a` calls `b`
through it. Only the store has to move. A local function in a cell that
captures a local declared later in its block is now stored into its cell
just after that declaration. Nothing can call it in between: a call there
would read a `let` before it is set, which js rejects too.

```elixir
b = TemperCore.Heap.new(:cell, %{:v => nil})
base = TemperCore.int32(n * 10)
TemperCore.Heap.put(b, :v, fn k1 ->
  TemperCore.int32(base + k1)
end)
```

Two functions that call each other and share a counter, `ping` and `pong`
over `var calls = 0`, failed the same way ("undefined variable calls") and
are fixed by the same move.

## Checking

An `ElixirBackendTest` case, red first: `b` is stored after `base` is
bound. The program above and both mutual-recursion programs now print what
js and py print. The closures program's remaining difference is py's own
(per-iteration `let` capture). alloy, prismora, templight, blimp-highlight
and temper_snake are unchanged and compile with no warnings. 65 of 65
functional tests pass.
