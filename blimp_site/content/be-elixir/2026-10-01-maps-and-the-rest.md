# 2026-10-01: maps keep their order, and the user writes the Elixir

Fifty of Temper's functional tests pass, up from forty-four: TypesMap,
TypesDeque, TypesDenseBitVector, AlgosMyersDiff (a real diff algorithm,
built on all of the above), FunctionsConnected and FunctionsLocals.

## Elixir maps are not ordered, and pretend to be

Temper's `Map` and `MapBuilder` keep insertion order. An Elixir map of up
to 32 keys iterates in key order, which looks like it keeps order for any
test that inserts keys sorted, and a larger one iterates in hash order. So a
Temper map is two things: its keys in the order they arrived, beside an
Elixir map. A repeated key keeps its first place and takes its last value,
which is what JavaScript's `Map` does and what Temper's tests expect. The
`temper-core` test for this uses 40 keys inserted in descending order, past
the size where the pretending stops.

`Pair` is a struct with `get_key`/`get_value`, so `pair.key` reads like any
translated object's property. `Deque` is an Erlang `:queue` on the heap.
`DenseBitVector` keeps only the set bits in a map, because a bit read past
the end is `false` and nothing can ask its length.

## Two closures that call each other

FunctionsLocals' generated code would not compile:

```
error: undefined variable "walker__111"
170 │ walker__111.(TemperCore.int32(i__116 + 1), out__117)
```

`putter` calls `walker`, and `walker` calls `putter`, and `putter` is
defined first. An Elixir closure can only see variables that exist when it
is made. The cells from chapter 7 already solve this: a local function
that another closure calls now lives in a cell made at the top of its
block, before either function, and both read the other out of it when they
run. Making that work also turned up parameters that a closure captures:
functions, methods and constructors now put those into cells too, before
the body runs. Before that fix a cell read was handed the raw number 4.

## The user writes the Elixir

Temper lets a library declare a function `@connected` and supply it in each
target language by hand. Each backend reads a file of its own beside the
Temper source; for Elixir that is `_connected.ex`, which the backend copies
into `lib/` and which defines `TemperConnected`. A `@connected` function's
generated body runs Temper's own defaulting for its optional parameters and
then calls `TemperConnected.<name>`. This repository now has an
`_connected.ex` for the functional test, beside the `.lua`, `.py`, `.js` and
the rest.

**Not done:** regular expressions, `Date`, generators and async, `@test`
blocks, NaN and infinity, `Float64.near`, named arguments, generic type
arguments as values, and JSON's `instanceof` on a type the program did not
declare. Fifteen tests, each failing by name.
