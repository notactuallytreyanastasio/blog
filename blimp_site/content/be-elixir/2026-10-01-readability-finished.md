# 2026-10-01: clause bodies, fields, and `cond`

Three readability problems were left after entry 13.

## Clause bodies, with tokens nobody sees

A `case`, `rescue` or `catch` clause's body sat at the same depth as its
pattern:

```elixir
rescue
  _ in TemperCore.Bubble ->
  IO.puts("bubbled")
  nil
end
```

The formatter indents and dedents on tokens, and no Elixir token marks
where a clause ends. Temper's formatter has invisible tokens for exactly
this case, `SpecialTokens.indent` and `SpecialTokens.dedent`. They are
never printed but still count for indentation, and the out-grammar can
name them in backquotes. The clause rule now brackets its body with them:

```
Clause ::= pattern%Pattern & ((guard%Expr => "when" & guard) || ())
         & "->" & `SpecialTokens.indent` & body%Block & `SpecialTokens.dedent`;
```

```elixir
rescue
  _ in TemperCore.Bubble ->
    IO.puts("bubbled")
    nil
end
```

The first build failed because the generated `Elixir.kt` did not import
`SpecialTokens`. The grammar's `imports` block now lists it.

## Fields by their plain names

A struct was `defstruct [:x__29, :y__30]` and a heap object's map
`%{:count__37 => nil}`. A Temper class cannot have two members with the
same name, and a field is only read or written inside its own class
(elsewhere it is reached through `get_x`), so a field's plain name is
unique wherever it appears. Fields are now `defstruct [:x, :y]`,
`this.x` and `%{:count => nil}`.

## `else if` is `cond`

The frontend lowers `else if` to an `if` inside an `else`, and the
generator state machine nested one level deeper for every case. Every
`if` the backend emits passes through one builder. When the `else`
branch is nothing but another `if`, or a `cond` already built from one,
the chain becomes a single `cond`:

```elixir
cond do
  caseIndexLocal == 0 ->
    IO.puts("one")
    TemperCore.Heap.put(caseIndex, :v, 1)
    {:value, :empty}
  caseIndexLocal == 1 ->
    IO.puts("two")
    :done
  true ->
    :done
end
```

`if` and `cond` treat `nil` and `false` the same way, so the meaning does
not change. The arms reuse nodes already in the tree, so each one is a
deep copy; a node can only have one parent, a lesson from entry 4.

## The tables that did not render

The guide is mostly tables, and on bobbby.online every one of them
showed up as a paragraph of pipes. The site's Markdown renderer, written
in Blimp, says so at the top: "Not built, because no post uses them:
tables, ...". It now parses GFM tables and renders the same markup as
comrak, which the Phoenix site used (blog PR #167). One test caught a
mistake of mine: I had a table end at the first line with no pipe, but
in GFM a row needs no pipe, and a table ends only at a blank line or
the start of another block.

65 of 65 still pass. The grammar tests' expected clause bodies are now
indented.
