# 2026-10-01: compiling without warnings

`mix test` in the last entry showed something every Elixir user of a
translated library would see on each build: a stream of compiler warnings,
about 205 from std alone.

```
 102       warning: variable "X" is unused (if the variable is not meant to be used, prefix it with an underscore)
  27       warning: variable "X" is unused (there is a variable with the same name in the context, use the pin operator (^) ...)
   ...
   2      warning: the following pattern will never match:
```

None of them were bugs, but a build that prints 200 warnings looks broken.
They have two causes:

- **Bindings nothing reads.** The way loops and branches hand back their
  variables (entry 2) binds everything they assign: `{i, total} =
  loop.(...)` even when only `total` is read afterwards. Frontend
  temporaries are sometimes bound and never read too.
- **Binding a raise.** `t1 = raise(TemperCore.Panic)` binds the result of
  something that never returns, and Elixir 1.19's type checker reports
  that pattern as one that "will never match".

`ElixirTidy.kt` is a last pass over each generated function, on the Elixir
tree, before formatting.

My first version prefixed `_` to any variable never read anywhere in the
function. That took std from about 205 warnings to 129. The rest were
names read somewhere but bound more than once, where some of those
bindings are never read. Elixir warns about each binding, so the pass
has to work per binding. It now does backward liveness through each
block, scoped as Elixir scopes. A binding is unused if nothing after it
reads the name before the next binding of it. Variables bound inside an
`if`, `case`, `cond`, `try` or `fn` do not leak out, so each inner block
is analysed with nothing live after it, and its reads of outer variables
count where the construct stands. Parameters and clause patterns are
bindings like any other, and a pinned `^x` is a read. Names that are not
variables are skipped: called functions, fields, modules and keyword
keys. A `Match` whose right side is a `raise` keeps just the raise.

```
std: 0 warnings
tour: 0 warnings   gen: 0   bank: 0   tested: 0   lists: 0   svc: 0
```

If the pass had renamed a binding that is in fact read, the result would
be a compile error, an undefined variable, rather than a warning, and
the functional suite would fail. It passes 65 of 65.
