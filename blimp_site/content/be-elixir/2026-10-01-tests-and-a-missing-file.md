# 2026-10-01: `@test` blocks, and the file `.gitignore` ate

Fifty-two of Temper's functional tests pass, up from fifty:
TypesStringIndices and TypesStringBuild. `@test` blocks now translate and
run; TestingAsserts itself still stops at a NaN, which is the next chapter.

## Running Temper's tests

A Temper `@test` becomes a module function of one argument, the `Test` that
collects its asserts. The backend generates `__temper_tests__/0`, which runs
them all and answers JUnit XML; a test run calls `main()` first, because a
test can read values the module's top level sets, then writes the XML where
the harness looks for it.

The first plan was to call `std/testing`'s own `runTestCases`, which is
written in Temper and returns that XML. It failed at once: `method
Test.assert has no Elixir support code`. std/testing is a library of its
own, so it is not in this translation, and its `Test` class is connected.
`TemperCore.Test` is a line-for-line port instead: soft `assert` records and
carries on, `assertHard` records and bubbles, a test that bubbles for any
other reason gets the message `Bubble` added, and the report is the same
lines `reportTestResults` writes, escaping included.

## A string index cast

`StringIndexOption` has two kinds, `StringIndex` and `NoStringIndex`. Here
both are integers, so a cast between them cannot use a type guard: it is a
sign test, `>= 0` for an index and `== -1` for none.

## TypesStringBuild was never in the repository

The first entry noted that regenerating the functional suite dropped
`TypesStringBuild`, because its source file was missing. The cause: the
test lives in `types/string/build/`, and the root `.gitignore` says
`build/`, meaning Gradle's output, which also matches that directory. The
file never made it into the repository when Temper was extracted. The be-blimp
stack had already put it back; it is restored here with `git add -f`, and the
test passes on its first run.

**Not done:** NaN and infinity (TestingAsserts, TypesFloatBasics,
TypesFloatOps), regex, `Date`, generators and async, named arguments,
a type as a value, and JSON's `instanceof` on a type from another library.
Thirteen tests.
