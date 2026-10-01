# 2026-10-01: std's values are values again, and two libraries meet

## Two user libraries

Until now, the only cross-library imports I had tried were imports of std.
The probe for two user libraries failed at first, because of my import:
`import("shapes")`. JS rejected it too ("Import of shapes failed"). A
library is imported by its module directory, just as `std/json` names std's
`json` directory, so the import is `import("shapes/src")`. With that fixed,
`app` uses `shapes`'s interface, an `@imu` class through a list typed by
the interface, a mutable class, and a module-level actor. It printed the
same line as the JS backend the first time it ran:

```
total=10.0 isSquare=true stack=2 tally=6
```

That needed no backend change. Entry 11's design (a root module per
library, `mix.exs` dependencies from cross-library imports, types traced to
their library) handled a user library exactly as it handles std. The pair
is kept as `examples/twolibs/`.

## Marking std's value classes `@imu`

Entry 18 made `@imu` the contract for struct versus ref. std carried
almost no annotations, so its classes went from 39 structs to 1, and a
parsed JSON tree reached Elixir as a set of heap refs. The fix was in std
itself, in this fork's copy of Temper.

I marked every class that looked like a value, then let the compiler
check, since `@imu` is deep:

```
Class Capture claims imu but property item has type RegexNode which is not imu
Class JsonArray claims imu but property elements has type List<JsonSyntaxTree> which is not imu
Class ListJsonAdapter claims imu but property adapterForT has type JsonAdapter<T__186> which is not imu
Class Regex claims imu but property compiled has type AnyValue which is not imu
...
```

So the node interfaces need the annotation too: `RegexNode`, `CodePart`,
`Special`, `SpecialSet` and `JsonSyntaxTree`. That holds, because every
class implementing them is immutable. Three claims were false and came
off:

- `Regex` holds its compiled pattern as an `AnyValue`.
- The generic `ListJsonAdapter` and `OrNullJsonAdapter` hold a
  `JsonAdapter<T>`. Making that interface `@imu` would forbid user-written
  adapters that keep state, which would change std's API.

std now has 30 structs. A parsed tree is plain data that crosses
processes as it is:

```
    %Temper.Std.JsonInt32{content: 1},
    %Temper.Std.JsonObject{properties: %TemperCore.Map{keys: [...], ...}}
  ]>
}
can cross processes: true
elements, read in another process: 2
```

The change is in std, which every backend shares. `@imu` only adds checks,
and the checks pass, so nothing should change elsewhere. I ran the tests to
confirm: `:frontend:jvmTest` passes, and the JS backend's functional suite
is 65 of 65. Like `@actor`, this belongs upstream.

65 of 65 Elixir functional tests pass.
