# 2026-10-01: programs the suite never saw

65 of 65 says the backend handles the 65 programs it was built against. The
Blimp backend reached the same number, and the first program written outside
its suite, a 130-line calculator, failed five of its six tests. So this
session ran be-elixir over every Temper program on hand that was not written
for it, and compared each with `-b js`. It ran on Elixir 1.18.4 and OTP 28; the
entries before it used 1.19.5.

| Program | `-b js` | `-b elixir`, before this entry |
|---------|---------|-------------|
| blimp-highlight, a Blimp syntax highlighter written in Temper | 11 of 11 | 11 of 11 |
| temper_snake, the game library | 31 of 31 | 31 of 31 |
| alloy | 225 of 225 | 225 of 225 |
| prismora | 12 of 12 | 12 of 12 |
| templight | 140 of 140 | 140 of 140 |
| ormery | 0 of 30 (30 not run) | translation crashed |
| an older ORM | 0 of 127 (127 not run) | translation crashed |

The highlighter carries its own oracle: a token dumper built from Blimp's
real `lexer.zig`. Its `dump` under Elixir matched the oracle on all 96
`.blimp` files tracked in this repository, plus the 11,000-line generated
snake server, 62,362 tokens, in one `mix run`: 1.9 s, 289 MB peak. Under
`-b blimp` the same library runs out of a 2 GB heap on the largest of them.

The two ORMs do not run anywhere: each has a class that declares its
constructor inputs and an explicit constructor, which the frontend rejects.
`-b js` builds them anyway and stops at run time with the frontend's
message. be-elixir stopped the build. That difference turned into three
fixes.

## A property of a value whose type did not compile

```
kotlin.NotImplementedError: An operation is not implemented:
  getter Invalid.fieldType has no Elixir support code: fieldInfo__396.fieldType
```

ormery's `Query` is the rejected class, so its field `schema` has the type
*Invalid*, and so does `schema.getField(...)`. `builtinGet` read `Invalid` as
a builtin type it had no support code for, which is a `TODO`. It is the case
the build was told to go on through, so it now gets what every other garbage
node gets, a raise where it stands:

```elixir
raise(TemperCore.Panic, "broken code: read of .fieldType on a value of a type that did not compile")
```

`semantics/broken` covers garbage nodes, but none typed this way, which is
why 65 of 65 never reached it. Fifteen lines reproduce it, and they are the
first test in a new `ElixirBackendTest`.

## A raise ends its block

With the crash gone, ormery's Elixir did not compile:

```
error: undefined variable "fieldType"
 442 │                 fieldType == "Int" ->
```

Entry 23's tidy pass turns `fieldType = raise(...)` into `raise(...)`,
because Elixir's type checker warns that the binding can never match. But
Elixir checks every variable a function reads, reachable or not, so the
later read of `fieldType` is a compile error. `probes/10_unbound_after_raise.exs`
shows all three shapes:

```
error: undefined variable "x"
binding dropped, read kept: {:compile_error, ...}
warning: the following pattern will never match:
binding kept          : :compiles
block ends at raise   : :compiles
```

Keeping the binding brings back the warning entry 23 removed. Nothing after
a raise in the same block can run, so the pass now ends the block there.
The second test in `ElixirBackendTest` covers it. Reverting only the tidy
change makes that test fail, which is how the test was checked. The first
attempt at it failed for another reason: the generated output includes the
source map, whose `sourcesContent` is the Temper source, so a search for a
Temper name always matched. The helper leaves `.map` files out.

## Tests the CLI never heard about

ormery then compiled and failed at run time, as on JS, but reported
differently:

```
-b js       Tests passed: 0 of 30 (30 not run)
-b elixir   Tests passed: 0 of 0
```

The CLI counts tests from the ones each backend registers through
`dependenciesBuilder.addTest`. be-js, be-py and be-lua register theirs;
be-elixir did not, so a run that died before writing `test-results.xml`
looked like an empty suite. The registered name has to be the name the
JUnit report carries, so it is the test's function name. That also gives
the CLI the sentence to print for a failure:

```
before: Test failed (elixir): thisOneIsWrongOnPurpose__6 - expected 3
after:  Test failed (elixir): this one is wrong on purpose - expected 3
```

The test helpers do not hand back a backend's dependencies, so this one is
checked through the CLI: ormery now reports `0 of 30 (30 not run)`, alloy
still `225 of 225`, and the line above was checked both ways by reverting
the change.

## What is left

The rejected class's constructor still compiles to a call of a setter the
class never defined (`Query.set_schema/2`): a compiler warning on code the
frontend already refused, and an `UndefinedFunctionError` if Elixir code
constructs such a class directly. The library's own init raises the
frontend's message before anything gets there, as JS does.

65 of 65 functional tests pass.
