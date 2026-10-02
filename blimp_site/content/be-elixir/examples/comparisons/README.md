# comparisons

Comparisons as Temper has written them since upstream #494: only `Int`
keeps `<`, `<=`, `>` and `>=` as builtins, and every other type's `a < b`
reaches a backend as `(a <=> b) < 0`. be-elixir turns that back into
`a < b` where the BEAM's term order is Temper's order (String, Int64,
Boolean), and keeps `TemperCore.Float.cmp` for Float64. Entry 39 covers
it.

`same` compares two `@imu` instances with `==`, which Temper now rejects
on every backend, so the run reports the type error, prints the line, and
ends "Run failed".

    cd journal/examples/comparisons
    temper run -b elixir --library cmp -w .

js, py and elixir all print:

    true false true false true false true false
