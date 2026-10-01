# 2026-10-01: lists that index in constant time

Both of the list types grew quadratically. I measured them with a probe
library that builds a list by `add` and sums one with an indexed `for`
loop, the most common Temper loop:

```
n=1000:  build 5 ms,    indexed sum 1 ms
n=4000:  build 70 ms,   indexed sum 15 ms
n=16000: build 1184 ms, indexed sum 236 ms
```

Four times as many items cost sixteen times as long, for each of them.

**The builder copied on every append.** A `ListBuilder` held an Elixir
list, and appending to a list copies it. It now holds an Erlang `:array`,
which costs `O(log n)` for get, set and append, constant time for size,
and handles `removeLast` with a resize. The 16,000-item build went from
1,184 ms to 2 ms. Inserting into the middle still rebuilds from a list,
which is linear, as it is everywhere.

**The loop walked the list twice per step.** `i < xs.length` and `xs[i]`
both walk an Elixir list. This one was not internal: a Temper `List` is
what Elixir code passes to a Temper library and gets back from it, so
changing it changes the interface. I put three options to the user: keep
plain lists, use bare tuples, or wrap a tuple in a struct. They chose the
struct, `%TemperCore.Vec{t: tuple}`:

- `get` is `elem/2` and `length` is `tuple_size/1`.
- It implements `Enumerable` (count in constant time, slice by `elem`),
  so `Enum.map(result, ...)` works on what a library returns. It also
  implements `Inspect`, as `#TemperCore.Vec<[0, 1, 2, 3, 4]>`.
- Every Temper list operation still accepts a plain Elixir list, so
  Elixir callers can pass `[1, 2, 3]`. A list in the wrong form is only
  slower, never wrong.
- A literal builds its tuple in place: `%TemperCore.Vec{t: {1, 2, 3}}`.
- The producers return a Vec: `toList`, `map`, `filter`, `slice`,
  `sorted`, `splice`, rest arguments, string and regex `split`, and map
  `keys`, `values` and `toList`.

```
n=16000:   build 2 ms,   indexed sum 0 ms
n=250000:  build 45 ms,  indexed sum 4 ms
n=1000000: build 186 ms, indexed sum 20 ms
```

## Two type tests that were wrong

The type checks mapped `List` and `Listed` to Kernel's `is_list`, which
would have rejected a Vec. `Listed` was already wrong before this
change, because a `ListBuilder` is `Listed` and is a heap ref, not a
list. `Float64` was also wrong: it mapped to `is_float`, which says no to
`:infinity` and `:nan` (entry 10). They now call `TemperCore.List.list?`,
`listed?` and `TemperCore.Float.float?`.

Eight runtime tests compared results with `==` against plain lists. They
now compare `Enum.to_list` of the result, and a new test covers the Vec
itself. temper-core: 78 tests, 0 failures. 65 of 65 still pass, including
the JSON, sorting and Myers-diff tests, which use lists the most.
