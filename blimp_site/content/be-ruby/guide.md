# How be-ruby works

be-ruby compiles Temper to Ruby. This guide describes the backend as it
is now. The dated entries in this directory tell how each piece came
about.

## 1. What you need

Ruby 4.0 or later (developed on 4.0.7), and JDK 21 to build Temper. On
macOS the system Ruby is 2.6 and will not do; Homebrew's is keg-only, so
put it first on the path:

```bash
export PATH=/opt/homebrew/opt/ruby/bin:$PATH
```

## 2. Running it

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21
./gradlew :cli:installDist                     # a `temper` that knows -b ruby
cli/build/install/temper/bin/temper build -b ruby -w path/to/my-lib
cd path/to/my-lib/temper.out/ruby/my-lib
ruby -I lib -e 'require "temper/my_lib"'
```

Each Temper library is a gem at `temper.out/ruby/<library>/`: a
`temper-<library>.gemspec` and `lib/temper/<library>.rb`, with dashes in
the library's name turned to underscores. Its module is
`Temper::<Library>`, written as two nested modules: `module
Temper::MyLib` raises NameError unless `Temper` already exists. Requiring
the file runs the library's top-level statements. `temper run -b ruby`
does the same.

## 3. How the backend is put together

A Temper backend never prints target code as strings. `ruby.out-grammar`
describes the Ruby this backend emits as a tree; `./gradlew
kcodegen:updateGeneratedCode` turns it into `Ruby.kt`, one class per node,
and Temper's formatter renders the tree.

| File | What it does |
|------|--------------|
| `ruby.out-grammar` | the Ruby syntax tree. Every statement writes its own newline |
| `RubyOperatorDefinition.kt` | the precedence ladder, which decides every parenthesis. `&` is tighter than `==`, unary minus looser than `**` |
| `RubyOperator.kt` | the operators. No `and`, `or` or `not`, which bind looser than `=` |
| `RubyFormattingHints.kt` | spaces only. The formatter never breaks a Ruby line itself |
| `RubyBackend.kt` | one gem per library: the gemspec and `lib/temper/<library>.rb` |
| `RubySupportNetwork.kt` | how this target differs: bubbles are exceptions, coroutines generators, void is `nil` |
| `RubySpecifics.kt` | running the output with `ruby -I lib` |
| `RubyHelpers.kt` | literals: strings with every `#` escaped, floats with a digit after the point, NaN and the infinities as constants |

## 4. Checking it

```bash
./gradlew :be-ruby:jvmTest :be-ruby:ktlintCheck
ruby be-ruby/journal/probes/04_grammar_samples.rb
```

The probe evaluates every rendering the grammar test pins and checks its
value, so the test's expected strings are known to mean what the tree
says.

## 5. Limits

The translator is a placeholder that prints Hello, World! whatever the input, and no builtins are mapped, so a library that calls `console.log` fails to build.
