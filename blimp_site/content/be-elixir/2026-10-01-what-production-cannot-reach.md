# 2026-10-01: what production can't reach

Entry 28 moved what the frontend marks as test-only out of the library.
Regenerating Marginalia with its 26 new Temper tests still added 19 lines
to `lib/temper_main.ex`: the tests' `repeated` helper, and the Landor page
the reflow tests read, with the closure that joins it.

```elixir
def repeated__N(word, n) do
  sb = TemperCore.StringBuilder.new()
  ...
TemperCore.Global.put(:"Temper.MarginaliaCore.landor__N", TemperCore.List.join(...))
```

Both are used only by tests, and the frontend marked neither as test-only.
Every call to `repeated` had constant arguments, so the frontend evaluated
it while compiling and replaced the call with the string. Every read of
`landor` became the joined page. Nothing referenced either one any more,
and an unreferenced declaration keeps the default category, production.
This is entry 28's folding again, this time deciding where code goes.

So the backend now finds what production can reach before it translates.
Production's roots are the exported functions and values, the classes, and
the top-level statements. From those it follows every name, through
imports, to the module functions and values they use. Any non-exported
function or value it can't reach goes to the test side, with its
initializer. The translator already qualifies calls to test-side
functions with `Temper.MyLib.Tests`, so the tests that do still call
`repeated` find it there.

Marginalia's `lib/` is now what it was before it had tests, apart from the
`__N` suffixes, and six lines shorter:

```
<       TemperCore.Global.put(:"Temper.MarginaliaCore.targetWords__N", 1800)
<       TemperCore.Global.put(:"Temper.MarginaliaCore.minWords__N", 250)
<       TemperCore.Global.put(:"Temper.MarginaliaCore.maxWords__N", 4000)
<       TemperCore.Global.put(:"Temper.MarginaliaCore.v_EQ__N", 0)
...
```

Those are the segmenter's and the word diff's constants. The frontend
inlined every read of them, so production never read the values it
stored. Dropping them from the library's init changes nothing the library
does.

The new backend test fails with the pass switched off. The functional
suite is still 65 of 65, alloy 225 of 225 and templight 140 of 140 under
`-b elixir`. Marginalia's equivalence harnesses, 1,158 app tests and 26
Temper tests all pass.
