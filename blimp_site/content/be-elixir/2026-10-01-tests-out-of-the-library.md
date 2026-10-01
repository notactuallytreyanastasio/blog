# 2026-10-01: tests out of the library, and tests that test something

Marginalia's Temper had no tests of its own. Its ports were checked by
harnesses that compared them with the original Elixir. So this session
ported some of the app's Elixir tests into Temper, ran them through
be-elixir, and looked at what came out. Three things were wrong, and the
worst one is not be-elixir's.

## The tests did not test the generated code

The first test was a plain port:

```temper
test("identical prose is all same") {
  let text = p(["One.", "Two.", "Three."]);
  assert(kinds(rows(text, text)) == "same same same");
}
```

Here is the Elixir it became:

```elixir
def identicalProseIsAllSame__1236(test___55) do
  _text = "One.\n\nTwo.\n\nThree."
  fn_ = fn ->
    "expected kinds(`-work/marginalia-core//src/`.rows(text, text)) == (same same same) not (same same same)"
  end
  TemperCore.Test.assert(test___55, true, fn_)
  nil
end
```

`assert(test, true, ...)`. The frontend ran the paragraph diff while
compiling, found the answer, and wrote down `true`. A test meant to fail
came out as `assert(false)`, with its message already computed. The JS
backend gets the same `test_902.assert(true, fn_905)`, so this is the
frontend's partial evaluation, and it affects every backend. A Temper
test of constants checks the compiler's interpreter, not the code the
backend generated.

I tried four ways of hiding the inputs from it, and what each one became:

| The input comes from | The assert in the output |
|---|---|
| constants | `assert(test, true, ...)` |
| a module `var` | a real call into the library |
| a `StringBuilder` or `ListBuilder` | a real call |
| a helper that takes the `test` and its inputs as parameters | a real call |

Even so, a helper is not enough when the check sits outside it.
`assert(!isWrapped(prose))`, where `prose` was built by a pure helper from
constants, was still folded to `assert(true)`. The rule that held for all
26 tests: each check runs inside a function that takes the `test`, which
is never evaluated early. Calls to `@connected` functions are never
evaluated early either.

## Tests were part of the library

Everything was in `lib/temper_main.ex`: the tests, their helpers, the
runner. A library with tests also gained a dependency on std, for
std/testing, which every consumer then compiled. The JS backend has always
put tests under `test/`. The frontend marks each declaration that only
tests reach, and be-elixir now follows those marks:

- **Where test code goes.** Tests, and the functions, classes and module
  values only they reach, go to `test/support/temper_tests.ex` under
  `Temper.MyLib.Tests`. A call to one of them is qualified with that
  module.
- **When it is compiled.** `mix.exs` compiles `test/support/` for `:test`
  only (`elixirc_paths`).
- **Test-only dependencies.** A dependency that nothing in `lib/` names is
  `only: :test`. The check walks the library's generated tree for module
  names and global atoms under the dependency's root. That is sound
  because a dependency's init sets only its own values: if the library
  never reads them, leaving the init out changes nothing.
- **Running the tests.** The test module has its own `__temper_init__`,
  which runs the library's init first, then the test-only values. The
  harness compiles and runs with `MIX_ENV=test`.

A `MIX_ENV=prod` build of Marginalia's library compiles two apps,
temper_core and the library: no std, and no tests.

## A failure pointed at the wrong file

ExUnit reported `test/temper_test.exs:17`, a generated file that nobody
edits. Each test now names its Temper line, worked out from the source's
`FilePositions` (the frontend `Module`s the backend already holds), and
`TemperCore.Test.check/2` puts that line first in the failure message:

```
  1) test a deliberately wrong expectation (Temper.MarginaliaCore.WordsTest)
     test/words_test.exs:13
     src/words_test.temper.md:24: a b -> a c: got same:a |del:b|ins:c
```

There is also one ExUnit file per Temper source file:
`src/words_test.temper.md` becomes `test/words_test.exs`, with module
`WordsTest`.

## Marginalia

Marginalia now has 26 Temper tests across six files, ported from its
Elixir tests for the diffs, the segmenter, sentences and PDF reflow,
including the em-dash marker. A shared `testing.temper.md` holds the
helpers and the folding rule. All 26 pass against the generated code, and
the output contains no `assert(test, true`.

## Upstream

Folding is right for production code and wrong for tests. Two fixes are
possible in the frontend. It could stop evaluating inside `test` bodies.
Or it could warn when an assert folds to a constant, since a check that
can never run is never what the author meant. The assert message also
renders a qualified name as `` `-work/marginalia-core//src/`.rows ``.

65 of 65 functional tests pass, as do ElixirBackendTest's 4 tests (2 new) and
temper-core's 97 tests (1 new).
