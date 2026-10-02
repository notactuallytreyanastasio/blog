# shelf

The library from entry 43: one exported class, two exported functions with
doc comments, and three helpers that end up three different ways.

```
temper build -b elixir
cd temper.out/elixir/shelf && mix compile
```

- `tens`, called only from the root module: `defp tens`, called as `tens(...)`.
- `clamp`, called from `Shelf.add`, a different module: `def`, `@doc false`.
- `label`, called from `Shelf.describe`: the same.

`Temper.Shelf.Shelf`'s `@moduledoc` holds `"""`, `\n` and `#{x}`, which
the backend escapes; `h Temper.Shelf.Shelf` in IEx shows them as written.
