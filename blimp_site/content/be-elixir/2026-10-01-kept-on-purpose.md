# 2026-10-01: two differences, kept on purpose

Entry 37 ended on three places where this backend and the reference
backends part ways, and asked which to keep. Two are decided.

**`@imu` values compare by their fields.** An `@imu` class is a struct, and
`new V(1) == new V(1)` is `true`, where js and py say `false` because they
compare objects by identity. Kept: an Elixir developer reading a translated
library sees a struct and expects struct equality. A class that is not
`@imu` is a heap ref and compares by identity, as in js and py.

The test that pins it has to pin the representation, not the operator:
`==` compiles to Elixir's `==` for every class, and what makes it compare
fields is that `V` is a `defstruct`. The first version asserted only on
`a == b`, which would still pass if `@imu` stopped producing a struct.
`imuValuesCompareByTheirFields` asserts both, and fails when the `@imu`
annotation is removed from its input.

**Float64 division by zero gives Infinity and NaN.** `1.0 / 0.0` is
`Infinity`, `0.0 / 0.0` and `x % 0.0` are `NaN`, as js gives. py bubbles,
and so does Temper's `BuiltinOperatorSpecs`. Kept, so that a program
dividing by a computed zero keeps running with a value rather than raising.
That is entry 10's design, not the BEAM's: plain Elixir raises
ArithmeticError for `1.0 / 0.0`, and entry 10 is what gave Temper's
infinities and NaN the atoms `:infinity`, `:neg_infinity` and `:nan`.
temper-core's IEEE tests already pinned all three cases.

The guide has a new section listing both, with these reasons, so the next
comparison against js and py does not file them as bugs.

Still open: number parsing follows JSON syntax, so `"+7"` and `"007"` fail
where js and py accept them.

65 of 65 functional tests pass.
