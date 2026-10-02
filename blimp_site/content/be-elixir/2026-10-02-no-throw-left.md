# 2026-10-02: no throw left

After entry 45, what still threw was an exit inside an `if` or a bubble
`try` in the middle of a statement list. std's JSON parser was most of
it, 9 thrown breaks and 8 thrown returns:

```elixir
if t1 do
  t3 = TemperCore.Heap.get(this, :out)
  ...
  throw({:temper_return, :ex_return_0, nil})
else
  ...
  throw({:temper_return, :ex_return_0, nil})
end
```

Such an `if` has no way to say "the function is done" to what follows it.
Its arms hand back the variables they assign, `{digit, return} = if ...`,
and the rest of the list runs after it. The only exit left was a throw,
caught by the loop, block or function it leaves.

## Why not copy the rest into each arm

An `if` whose arm always exits already gets the rest of the list folded
into its other arm (entry 2). Doing that for every `if` with an exit
somewhere inside means the rest of the list appears in both arms, and
again in both arms of the next such `if`. A chain of them doubles each
time.

## The same protocol as a loop

Entry 45 gave loops a way to hand an exit back: end with the tuple the
throw would have carried, or `{:cont, vars}` when finished normally,
and let a `case` at the call site take either. An `if` or a `try` can do
the same. Its arms end `{:cont, vars}` or with the exit, and a `case`
after it holds the rest of the list, once:

```elixir
ex_step_4 = try do
  t2 = TemperCore.Heap.get(t1, :v)
  t3 = TemperCore.String.to_int32(TemperCore.List.get(xs, i))
  TemperCore.Heap.put(t1, :v, TemperCore.int32(t2 + t3))
  {:cont, return}
rescue
  _ in TemperCore.Bubble ->
    return = -1
    {:temper_break, :ex_block_1, return}
end
case ex_step_4 do
  {:cont, return} ->
    TemperCore.Heap.put(t1, :v, TemperCore.int32(TemperCore.Heap.get(t1, :v) + 1))
    i = TemperCore.int32(i + 1)
    parsedSum_loop_14(t1, xs, i, return)
  {:temper_break, :ex_block_1, return} ->
    {:temper_break, :ex_block_1, return}
end
```

That is the loop body of

```temper
export let parsedSum(xs: List<String>): Int {
  var t = 0;
  for (var i = 0; i < xs.length; ++i) {
    do { t += xs[i].toInt32(); } orelse do { return -1; }
    t += 1;
  }
  t
}
```

The `case` is outside the `try`, so the loop's call to itself is still a
tail call; a `try` inside a loop body carrying the loop's own end into
its arms would hold a frame per iteration, and rescue a later
iteration's bubble in an earlier one. `parsedSum(["1", "2"])`,
`parsedSum(["1", "x", "3"])` and `parsedSum([])` give `5 -1 0` on both
js and Elixir.

Two things the first build caught:

- The value has a name before the `case`: `case if ... end do` does not
  parse.
- Elixir's type checker reported `{:cont, _}` as a clause that never
  matches, three times in marginalia-core, where every arm of the `if`
  exits through something entry 2's syntactic check does not see. The
  clause is now left out when nothing leaves the `if` normally.

## Counted

Thrown exits in the generated code:

| library | after entry 47 | now |
|---|---|---|
| std | 17 | 0 |
| marginalia-core | 6 | 0 |
| alloy's `orm` | 5 | 0 |
| templight, highlight, temper_snake, mainclash | 0 | 0 |

An exit can still throw from a list nothing can hand it back through:
module init code, or a labeled block whose following statements are too
long to copy into its ways out. None of the libraries here has one.

be-elixir's 102 tests pass; alloy (225), templight (140), highlight (11),
temper_snake (31), mainclash (1) and the marginalia workspace (260) pass
with no compile warnings and no spec warnings. `returnsFromLoopsAreNotThrown`
gains `parsedSum` and a loop inside a mid-list `if`, and fails on the
commit before.

Merged as [temper#15](https://github.com/notactuallytreyanastasio/temper/pull/15),
commit [8e859613](https://github.com/notactuallytreyanastasio/temper/commit/8e859613).
