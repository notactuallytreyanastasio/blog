# Does the Dialyzer check check anything?

Negative controls for the typespec check of
[fork PR #7](https://github.com/notactuallytreyanastasio/temper/pull/7)
(entry 41). `fixture/` is `ElixirTypespecTest`'s library plus one null
check; `passthru/` is a function that hands back the list it was given.
`run.sh` builds both with `temper build -b elixir`, then for each variant
copies the generated library, puts temper-core from the named commit beside
it, applies one edit from `edits/`, and runs the backend's own `dialyze.exs`.

```bash
TEMPER=path/to/fork/checkout/at/94efe3e0 ./run.sh
```

Results with Elixir 1.19.5 on OTP 28, temper CLI built at 94efe3e0:

| variant | edit | SPEC-TOTAL | named |
|---|---|---|---|
| base | none | 0 | |
| false8 | eight exported functions get a false return spec | 6 | half, big, flip, shout, upTo, contains |
| false8-entryfn | the same, with `Heap.entry` a function again | 0 | |
| false8-core62 | the same, with temper-core before its 214 specs | 5 | shout is missed |
| total-defp | the same, with `total`'s loop a `defp` | 7 | total is caught |
| boolint | `boolean()` replaced by `integer()` | 2 | flip/1, contains/2 |
| ifnil | `orEmpty`'s `case` written back as `if subject === nil` | 1 | orEmpty/1 "might also return 'nil'" |
| passthru | none | 1 | nonEmpty/1 "might also return [any()]" |

`lookup` is never caught: `TemperCore.Map.get_or/3`'s result is a spec
type variable, which Dialyzer does not instantiate at a call.
