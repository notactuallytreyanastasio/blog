# 2026-10-02: a plain list at the door

The Dialyzer gate (entry 41) failed on a function with nothing wrong in it.
A journal writer for entry 41 found it:

```temper
export let nonEmpty(xs: List<Int>): List<Int>? {
  if (xs.length > 0) { xs } else { null }
}
```

```
@spec nonEmpty(TemperCore.Vec.t(integer())) :: TemperCore.Vec.t(integer()) | nil

SPEC temper_main.ex:341: The success typing for 'Elixir.Temper.MyTestLibrary':nonEmpty/1
implies that the function might also return [any()] but the specification
return is 'nil' | #{'__struct__' := 'Elixir.TemperCore.Vec', 't' := tuple()}
```

Entry 41's limits list filed it as "a true spec can fail the check". It
was not a true spec. The guide promises that Elixir code may pass a plain
list wherever Temper takes a `List`, and temper-core's list operations
accept one, so a plain list goes in, nothing turns it into a Vec, and the
function hands it straight back:

```elixir
iex> Temper.Listin.nonEmpty([1, 2, 3])
[1, 2, 3]
iex> Temper.Listin.nonEmpty(TemperCore.Vec.new([1]))
#TemperCore.Vec<[1]>
```

The spec said `Vec` for both. Dialyzer inferred, from `TemperCore.List.length(xs)`
accepting `Vec.t(e) | [e]`, that `xs` might be a list, and that what came
back might be one too. It was right, and the parameter spec was also too
narrow for what the guide promised callers.

## Why not widen the spec

The obvious fix is to say what happens: return `Vec.t(integer()) | [integer()] | nil`.
That makes every Elixir caller of every `List`-returning function handle
two representations, forever, to cover a call that only some of them make.
Converting at the door costs one pattern match for a Vec and one
`List.to_tuple` for a plain list, and makes both specs true as written.

temper-core gains `TemperCore.Vec.of/1`:

```elixir
@spec of(t(elem) | [elem]) :: t(elem) when elem: term()
@spec of(nil) :: nil
def of(%__MODULE__{} = vec), do: vec
def of(items) when is_list(items), do: new(items)
def of(nil), do: nil
```

and a function Elixir code can call, an exported one, or a public method
or constructor of an exported class, starts by calling it on each `List`
parameter, `List<T>?` included. Its spec says what it accepts:

```elixir
@spec nonEmpty(TemperCore.List.list_in(integer())) :: TemperCore.Vec.t(integer()) | nil
def nonEmpty(xs) do
  Temper.Listin.__temper_init__()
  TemperCore.Heap.entry(fn ->
    xs = TemperCore.Vec.of(xs)
    ...
```

```elixir
iex> Temper.Listin.nonEmpty([1, 2, 3])
#TemperCore.Vec<[1, 2, 3]>
iex> Temper.Listin.Bag.new(["a"]) |> Temper.Listin.Bag.get_items()
#TemperCore.Vec<["a"]>
```

Inside the library every `List` is then a Vec. A function that is not
reachable from Elixir keeps `Vec.t` in its spec and does no conversion.

## Checked

The typespec fixture now has `nonEmpty` and a class whose constructor
takes a `List`. On the code before the change,
`dialyzerFindsNoSpecTheCodeContradicts` fails with exactly the warning
above; after it, it passes. be-elixir's 101 tests pass, and alloy (225),
templight (140), highlight (11), temper_snake (31), mainclash (1) and
marginalia-core (35) pass with no compile warnings and no spec warnings.

## Not converted

A `List` inside another value: a map's values, a list of lists, an
object's field set from Elixir code. Those still arrive as whatever Elixir
passed, and temper-core's list operations still accept a plain list
there, so the code works; only the spec is optimistic about them.

The same pull request fixed three things the guide had wrong, found by
the writers of entries 41 and 45: the loop example still showed a
`throw`, it blamed `total`'s unchecked spec on a throw that `total` does
not have, and the Comparisons paragraph had swallowed a sentence about
`toString`.

Merged as [temper#12](https://github.com/notactuallytreyanastasio/temper/pull/12),
commits [a6795a9d](https://github.com/notactuallytreyanastasio/temper/commit/a6795a9d)
and [176ccb38](https://github.com/notactuallytreyanastasio/temper/commit/176ccb38).
