# 2026-10-01: `<=>` on floats, and the empty string

The last two runtime divergences from the programs written to break the
backend were both in temper-core, the Elixir that translated code calls.

## `<=>` on Float64

```temper
var nz = -0.0; nz = nz;
let z = nz * -1.0;
console.log("${nz <=> z} ${nz < z}");
```

js and py: `-1 true`. elixir: `0 true`. `<` was right and `<=>` was not,
because they arrive differently. `<` on two Float64 is `LtFltFlt`, which
already went to `TemperCore.Float.lt`, Temper's float order. `<=>` arrives
as the generic comparison, `TemperCore.cmp`, which compared with Elixir's
`<`. That is the BEAM's term order, and it disagrees with Temper's in two
places: `-0.0 < 0.0` is false, and the atoms entry 10 uses for NaN and the
infinities sort above every number. Sorting `[3.0, -Infinity, NaN, -1.0,
Infinity, 0.0, -0.0]` with `<=>` gave `-1.0 0.0 -0.0 3.0 Infinity NaN
-Infinity`.

`TemperCore.cmp` now sends floats, and the three atoms, to
`TemperCore.Float.cmp`. Doing it at run time rather than in the translator
covers generic code too: a comparator passed to a sort of `List<Float64>`
reaches the same `cmp` without the translator ever seeing a Float64.

```
sorted [-Infinity, -1.0, -0.0, 0.0, 3.0, Infinity, NaN]
```

which is py's answer; js answers `-Infinity` for `-Infinity <=> 1.0`, its own
bug.

## `indexOf("")`

`"abc".indexOf("")` raised `ArgumentError`: `:binary.match` rejects an empty
pattern. js and py find the empty string where the search starts. Because
ArgumentError is neither a bubble nor a panic, it took down a whole test
run: the programs' regression tests reported `0 of 7 (7 not run)`. An empty
target now answers the start, clamped to the string.

## Checking

temper-core's own tests first, red: `cmp` on `-0.0`/`0.0`, both infinities
and NaN, a seven-value sort, and that ints, strings and booleans compare as
before; `index_of` with an empty target at 0, 3 and past the end. 99 tests,
0 failures. (The first attempt at the `cmp` test was appended to the last
module in a file that holds three, where `cmp` is not imported, and did not
compile.) The float programs match py, the empty-string program matches
js, and the regression tests run: 5 of 7 under elixir. The two left are
the open questions below. alloy, prismora, templight, blimp-highlight and
temper_snake compile with no warnings and pass as before. 65 of 65
functional tests pass.

## Open, and not bugs in the usual sense

Three differences from js and py are choices this backend made, and the
references disagree with each other on some of them:

- `@imu` objects compare by their fields (section 8 of the guide); js and
  py compare objects by identity.
- Number parsing follows JSON syntax: `"+7".toInt32()` and
  `"007".toFloat64()` fail. js and py accept both. Temper's own float test
  says forms JSON does not support are disallowed.
- Float64 `/` and `%` by zero give Infinity and NaN, as js does. py bubbles,
  and Temper's `BuiltinOperatorSpecs` says division by zero bubbles for
  Float64 too.
