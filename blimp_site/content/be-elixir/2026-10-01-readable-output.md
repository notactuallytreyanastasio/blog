# 2026-10-01: output a person can read

With all 65 tests passing, I turned to what the output looks like, which
the tests never check. This is std's `parseJson` as the backend now emits
it:

```elixir
def parseJson(sourceText) do
  p = Temper.Std.JsonSyntaxTreeProducer.new()
  Temper.Std.parseJsonToProducer(sourceText, p)
  TemperCore.call(p, :toJsonSyntaxTree, [])
end
```

Before this chapter, the same function used `sourceText__786` and
`p__787`, and if a closure came anywhere above it in the file, the
function sat one indentation level too far left.

## `fn` never indented

The formatting hints indent after `do` and dedent at `end`, and every `end`
dedents. `fn ... end` closes with an `end` too, but `fn` never indented.
So each closure left the rest of the file one level further left than it
should have been. After a generator's state machine, `def main()` was in
column 0. Elixir's parser ignores indentation, so no test could see this.

`fn` now indents, and every `fn ... end` is balanced:

```elixir
def fn__11() do
  caseIndex = TemperCore.Heap.new(:cell, %{:v => 0})
  convertedCoroutine = fn generator ->
    caseIndexLocal = TemperCore.Heap.get(caseIndex, :v)
    TemperCore.Heap.put(caseIndex, :v, -1)
    if caseIndexLocal == 0 do
```

A capture was printed `& Temper.Gen.fn__11 / 0`. A capture's `&` and
`/` are punctuation tokens and a division's `/` is an operator token, so
the hints can now print the capture tight, `&Temper.Gen.fn__11/0`, without
touching arithmetic.

## Plain names, numbered where they repeat

Every local had the frontend's uid on it: `x__13`, or `caseIndex___17`
for a temporary. Elixir variables belong to their function, so inside one
function the uid only has to separate names that share a base. Each
function, method, getter, setter, constructor and test now gets its own
naming:

- a local declared once in it is plain: `sourceText`, `p`, `caseIndex`
- a name declared more than once is numbered in declaration order, `t1`,
  `t2`, `t3`, skipping any number another chosen name already uses, so
  shadowing stays distinct
- module functions and globals keep their suffixes, because one name has
  to be the same in every function that uses it

The first version named locals per class instead of per member. That
looked fine until I counted. Across std's 4,127 lines:

```
before                                4,223 suffixed names
per class, plain where unique         2,348   (745 of them `this`, 697 `t`)
per member, numbered where repeated     383
```

Each method declares its own `this`, so a whole class had dozens of them,
and naming per class meant they all kept their suffixes. Most of the 383
that remain are module functions, which keep suffixes on purpose, and
names that a type's static initializers share.

## Still not like hand-written Elixir

- A `case`, `rescue` or `catch` clause's body is not indented past its
  pattern, because nothing marks where the clause ends for the formatter
  to dedent at.
- `if a do ... else if b do ... end end` is not yet a `cond`.
- Every method call goes through `TemperCore.call(obj, :m, args)`, even
  when the class is known when the code is built.

65 of 65 still pass, and the grammar test's expected `fn` body is now
indented.
