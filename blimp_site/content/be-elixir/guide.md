# How be-elixir works

A guide to the backend as it stands, written to be read in order. Each
chapter of the backend adds a section; nothing here describes code that does
not exist yet.

## 1. The output grammar

A Temper backend never prints strings of target code. It builds a tree of
the target language and lets Temper's formatter render it. For Elixir the
tree is described in one file:

    temper/be-elixir/src/commonMain/kotlin/lang/temper/be/elixir/elixir.out-grammar

and `./gradlew kcodegen:updateGeneratedCode` turns it into `Elixir.kt`, one
Kotlin class per node. A rule like

```
Match ::= left%Pattern & "=" & right%Expr;
```

becomes `class Match(pos, left: Pattern, right: Expr)` that renders as
`left = right`.

Three files sit next to the grammar:

- `ElixirOperatorDefinition.kt` is the precedence ladder. The formatter
  consults it to decide where parentheses go, so the tree never contains
  any. Comparison and equality are non-associative on purpose: `1 < 2 < 3`
  is valid Elixir and evaluates to `false`.
- `ElixirFormattingHints.kt` decides spaces and line breaks. Elixir ignores
  indentation but not newlines, so the hints that matter are the ones that
  keep `do` and `->` at the end of a line.
- `ElixirHelpers.kt` writes literals: strings with every `#` escaped so
  nothing interpolates, atoms quoted when they are not plain identifiers,
  and floats with digits on both sides of the point. NaN and infinity, which
  the BEAM cannot hold, are compile errors.

To check a change to any of them:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
cd temper
./gradlew :be-elixir:jvmTest :be-elixir:ktlintCheck
elixir ../journal/probes/05_grammar_samples.exs
```

## 2. The backend and its runner

Three classes make `-b elixir` exist:

- `ElixirBackend` turns Temper's intermediate form (TmpL) into output
  files. Today it ignores its input and writes a hello-world Mix project.
- `ElixirSupportNetwork` tells TmpL how this target handles what differs
  between languages: bubbles (Temper's errors) become exceptions, function
  values stay functions, void is `nil`.
- `ElixirSpecifics` runs the output: `mix compile`, then
  `mix run --no-compile -e "TemperMain.main()"`, so that Mix's
  "Compiling 1 file" lines never mix with the program's output.

It is registered in `settings.gradle`, `bundled-backends/build.gradle` and
`supported-backends/.../basic-plugin-list.json`, and then
`./gradlew :cli:installDist` gives a `temper` that knows it:

```bash
temper build -b elixir -w path/to/library
cd path/to/library/temper.out/elixir/<library>
mix compile && mix run --no-compile -e "TemperMain.main()"
```

## 3. temper-core

The runtime library lives in the backend's resources:

    temper/be-elixir/src/commonMain/resources/lang/temper/be/elixir/temper-core/

It is a complete Mix project. The backend copies it to
`temper.out/elixir/temper-core` (it is the backend's
`coreLibraryResources`), and every generated library depends on it by
path. Test it in place:

```bash
cd temper/be-elixir/src/commonMain/resources/lang/temper/be/elixir/temper-core
mix test
```

| Function | Why it exists |
|----------|---------------|
| `TemperCore.int32(x)`, `int64(x)` | Elixir integers have no width; Temper's wrap |
| `TemperCore.int32_div(a, b)`, `int32_rem(a, b)` | the wrap, plus a bubble on division by zero |
| `TemperCore.Heap.new/get/put` | mutable objects that every alias shares |
| `TemperCore.Bubble` | the exception an uncaught Temper bubble becomes |

## 4. The translator, and the functional suite

`ElixirTranslator` turns one Temper module (in TmpL form) into Elixir.
Top-level statements become the body of `TemperMain.main/0`, because a
Temper module runs its top level on load and `mix run` calls a function.

Support code is how Temper builtins reach the target. `console.log` is
connected support code: `ElixirSupportNetwork.translateConnectedReference`
answers the key `core.type Console.log()` with an `ElixirInlineSupportCode`
that builds `IO.puts(message)` at the call site.

Progress is measured by Temper's shared functional tests. Which ones run
for Elixir is the `onlyPasses(elixir(), ...)` list in
`temper/functional-test-suite/.../FunctionalTestStatus.kt`; everything else
is skipped. To run them:

```bash
./gradlew :be-elixir:jvmTest --tests 'lang.temper.be.elixir.ElixirFunctionalTest'
```

Passing so far: AlgosHelloWorld.
