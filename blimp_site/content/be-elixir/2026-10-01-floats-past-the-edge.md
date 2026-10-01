# 2026-10-01: floats past the BEAM's edge

A Temper `Float64` is an IEEE double, with infinities and NaN. A BEAM
float is not. On Elixir 1.19.5 / OTP 28:

```
big*2: raises ArithmeticError
1/0: raises ArithmeticError
sqrt -1: raises ArithmeticError
log 0: raises ArithmeticError
exp 1000: raises ArithmeticError
<<inf>>: raises MatchError
<<nan>>: raises MatchError
String.to 1e999: raises ArgumentError
```

The last two lines rule out the usual trick: you cannot even get an
infinity out of a binary, because `<<x::float>>` refuses to match those bit
patterns. Underflow is fine, and `1.0e-308 * 1.0e-308` is `0.0`. Since OTP
27, `-0.0` is its own value.

So a Float64 here is a BEAM float or one of three atoms: `:infinity`,
`:neg_infinity` or `:nan`. None of the three can come from a bare `+`, so
float arithmetic is never a bare operator any more. Every float operation
goes through `TemperCore.Float`:

```temper
let twice(x: Float64): Float64 { x * 2.0 }
var big = 1.7976931348623157e308;
big = big;
console.log("${twice(big)} ${twice(-big)} ${big - twice(big)} ${NaN > Infinity}");
```

```elixir
def twice__1(x__3) do
  TemperCore.Float.mul(x__3, 2.0)
end
```

```
Infinity -Infinity -Infinity true
```

A finite operation takes the fast path, which is the BEAM's own operator
inside a `try`. Only a raise is mapped to its IEEE answer:

```elixir
def mul(a, b) when is_float(a) and is_float(b) do
  a * b
rescue
  ArithmeticError -> inf(neg?(a) != neg?(b))
end
```

Ten million adds inside `Enum.reduce` take 46–49 ms bare and 52 ms through
`TemperCore.Float.add`. The `:math` functions work the same way:
`TemperCore.Float.math(:sqrt, x)` calls `:math.sqrt`, and then answers
IEEE where that raises (NaN for `sqrt(-1)`, `-Infinity` for `log(0)`).
It also handles the special values without ever calling `:math`.

## Temper's order is not IEEE's

`NaN > Infinity` is true in Temper, and so is `NaN == NaN`. The frontend's
`ConsistentDoubleComparator` places `-0.0` just before `0.0` and every NaN
above +Infinity. The comparisons already went through `TemperCore.Float`
for the zeros, so they now rank the atoms as well: `:neg_infinity`, then
floats, then `:infinity`, then `:nan`. The functional test also wants
`max` and `min` to give NaN if either side is NaN, which is not what that
total order would pick.

## `near` is not its own body

core.temper defines `near` in Temper:

```temper
/** Matches semantics of Python's *math.isclose*. */
let margin = (content.abs().max(other.abs()) * relTol).max(absTol);
(content - other).abs() <= margin
```

I first ported the body as written. Under Temper's own order, though,
NaN-propagating `max` makes the margin NaN, and `NaN <= NaN` is true, so
`NaN.near(1.0)` came out `true`. The comment says otherwise, so I ran it
through the other backends:

```
== js
near(NaN, 1.0) false
near(NaN, NaN) false
== py
near(NaN, 1.0) false
near(NaN, NaN) false
```

They follow the comment, and `TemperCore.Float.near` now follows
`isclose` too. My first runtime test was wrong in the same way, and the
same run caught it.

## Smaller things the special values exposed

- `Float64.toInt64()` bubbles outside ±(2^53 − 1), not outside Int64:
  "Bubbles if the value isn't within plus or minus 0x1f_ffff_ffff_ffff,
  inclusive." `Int64.toFloat64()` has the same bound. The old code
  checked only that the value round-tripped, so it passed 2^53, which the
  test calls "sneaky big".
- `String.toFloat64()` is JSON's number syntax plus `NaN` and `±Infinity`.
  `Float.parse("1e999")` is `:error`, so the syntax is now checked by a
  regex first, and a number that is valid but too big becomes infinite.
- `round` takes halves up, as JavaScript's `Math.round` does. The JS, Java
  and Lua backends round that way too.
- `toInt32Unsafe` of NaN is `0`, as in JavaScript. core.temper leaves the
  result up to the backend.

I also made two mistakes, and the tests caught both. `import Kernel,
except: [abs: 1, ...]` made the float printer's `abs(exponent)` call the
new float `abs`, which passes integers through unchanged, so `1.0e-7`
printed as `1.0e--7`. And `mix format lib/*.ex` reformatted ten files that
had nothing to do with floats. Those were reverted before the commit.

**58 of 65** pass, up from 55: `TestingAsserts`, `TypesFloatBasics`,
`TypesFloatOps`.

**Not done:** regex (2), `Date`, `NetRequest`, a type as a value,
`instanceof JsonArray`, `SemanticsBroken`. Every one of the seven fails at
build time with a TODO that names it.
