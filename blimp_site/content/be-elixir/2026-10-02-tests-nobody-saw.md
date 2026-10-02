# 2026-10-02: tests nobody saw

Two ways `temper test -b elixir` reported fewer tests than it had, both
found while checking something else, both silent.

## A workspace of two libraries tested one

Checking the loop work against Marginalia, the workspace that holds
alloy's `orm` and `marginalia-core` printed:

```
Tests passed: 225 of 225
```

That is alloy's count. js, on the same workspace:

```
Tests passed: 225 of 260 (35 not run)
```

marginalia-core's 35 tests were generated, compiled and, run by hand with
`mix test`, all passed. `temper test` never ran them, and said nothing.
be-elixir's runner took the first library it was asked to test:

```kotlin
is RunTestsRequest -> when (val libraryName = request.libraries?.firstOrNull()) {
```

js and py map over every library in the request. Elixir now does too,
and the workspace reports

```
Tests passed: 260 of 260
```

js still reports 35 not run, and for a reason it does print: marginalia-core
implements its `@connected` functions in `_connected.ex` and has no
`_connected.js`, so mocha stops with `ERR_MODULE_NOT_FOUND` for
`src/_connected.js` before any test runs.

## One panic ended the run

httpeex_prismora has a test that reaches a frontend bug: a rejected `==`
that the compiler leaves for run time, which panics with the frontend's
own message on every backend. js reports that test and runs the others.
Elixir reported none of them:

```
js:      Tests passed: 7 of 12
elixir:  Tests passed: 0 of 12 (12 not run)
```

`TemperCore.Test.process/1`, which runs a library's tests for `temper
test`, rescued `TemperCore.Bubble` and nothing else, so a `Panic` left
the loop over tests and ended the run. Now a raise, a throw or an exit
fails that test alone, with Elixir's banner for it as the message:

```
Test failed (elixir): color conversions - ** (TemperCore.Panic) broken code:
  Operator member infix nym`==` should have been converted to dot-name form
Tests passed: 7 of 12
```

the same count and the same test as js. `mix test` never had the
problem, since ExUnit runs each test on its own. A temper-core test runs
a panicking test, a crashing one and a throwing one before a passing
one; before the change it fails with the Panic escaping.

The underlying `==` bug is upstream's and is in the guide's Limits.

Merged as [temper#14](https://github.com/notactuallytreyanastasio/temper/pull/14),
commits [b404b2d9](https://github.com/notactuallytreyanastasio/temper/commit/b404b2d9)
and [3a223bc2](https://github.com/notactuallytreyanastasio/temper/commit/3a223bc2).
