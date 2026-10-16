# 2026-10-10: twelve errors Steep did not mention

Fifty-eight of sixty-seven. Six new tests pass: the two regex tests, the
JSON one, two of the import tests, and `FunctionsLocals`. All of them
were waiting on the same thing, references to names in another module or
another library, and that is most of this entry. The rest is a correction.
Last entry said the generated standard library passed Steep. It did not
even parse.

## How one library reads another

Within a library, every Temper module becomes part of one Ruby module, so
an import from a sibling module, `let { magicNumber } = import("./exporter")`,
is just a second name for something already declared. The translator now
treats it as an alias.

Across libraries it is harder, because each library is translated by its
own run of the backend, and the importing side has to know the Ruby name
the exporting side chose. So exported names are now chosen first, from
their text alone, and both sides compute them the same way. If two exports
would land on the same Ruby name, the build stops rather than numbering
one of them, since the other library could not know which got the `_2`.
An exported function is called on its library's module, and an exported
value gets a reader method there, so the importer does not need to know
whether the exporter wrote `let` or `var`:

```ruby
REGEX = Temper::Std::Sequence.new([Temper::Std.one_or_more(Temper::Std::CodeSet.new(...)), ...]).compiled()
```

```ruby
def self.begin_()
  BEGIN_
end
```

The importing library requires the other one, its Steepfile loads the
other's signatures, and a run puts every sibling library's `lib` on the
load path.

## `BEGIN`, which is not a constant

The first regex test to run failed like this:

```
expected a `{` after `BEGIN`
unexpected '=', ignoring it
```

std/regex exports a value called `Begin`, the regex anchor. A module-level
`let` becomes a Ruby constant in capitals, and `BEGIN` is a Ruby keyword:
`BEGIN { ... }` is a block that runs before the rest of the program, a
feature borrowed from awk. The same goes for `END`. The backend's list of
Ruby keywords has both, and methods and locals were checked against it.
Constants never were. Now `BEGIN_` and `END_`.

That was in std, and std had been translated since last entry, which means
the Ruby for std had never parsed. And I had run Steep on it, and Steep
had said:

```
No type error detected. 🫖
```

So I asked Steep about a file Ruby cannot parse
(`probes/37_steep_unparsable/`):

```
ruby -c:
ruby: lib/m.rb:2: syntax errors found (SyntaxError)
steep check:
No type error detected. 🫖
steep exit status: 0
```

Steep 2.1 does not report a file it cannot parse. It does not warn, it
does not fail, it is just happy, and it exits 0. The functional tests never
hit this, because they run the program before they type-check it, and a
program that does not parse does not print the right output. But nothing
ran std. The Date test only uses Ruby's own Date, so it never required std.

The harness now compiles every generated Ruby file before Steep sees it,
and it checks every library the build wrote, not just the one that ran.
That turned up what Steep had been sitting on.

## The twelve

With std parsing, Steep found twelve problems in it. They were real.
Here are the three kinds.

**A `return` nobody wrote.** Entry 7 taught the translator to turn the
frontend's "assign a temporary, break out, return the temporary" pattern
back into `return`. It then dropped the trailing `return return_` only
when the last statement was itself a `return`. When the last statement
was an `if` whose every branch returned, or a `begin`/`rescue` whose body
and handler both did, the trailing line stayed:

```ruby
      else
        return parse_json_number(source_text, i, out)
      end
    end
    return return_
```

`return_` was never assigned in that method, so to Ruby it is a method
call, and if control ever got there it would be a NameError. Control
cannot get there, which is why no output was ever wrong, and also why it
is worth fixing rather than explaining. The translator now knows when an
`if` or a `begin` cannot fall through. And where the assignment and the
`break` have a statement between them (`return_ = v; out.boolean_value(...);
break`), the value is kept and returned after, which preserves the order
things happen in.

**`x = nil` again.** A Temper local declared `var multis: MapBuilder<...>? = null`
came out as `multis = nil`, which Steep types as nil forever, the same
problem entry 7 fixed for a declaration with no value at all. It now
carries its type: `multis = nil #: Hash[String, Array[JsonSyntaxTree]]?`.

**`nil?` on a `T`.** In a generic class, `x.nil?` on a value of type `T?`
is an error, because Steep allows no methods at all on an unbounded type
parameter, `nil?` included (`probes/38_steep_nil_test/`). `nil == x` calls
NilClass#==, which takes anything, so a null test on a type parameter is
written that way. Everywhere else it is still `x.nil?`.

## A property called `hash`

The regex test's next failure was `undefined method 'begin_' for an
instance of Temper::Std::Group`. `Group` has a property `begin`. Its
reader was declared `attr_reader :begin`, which is legal Ruby, since
`range.begin` is a method too. But every read of a property goes through
a name that avoids keywords and Object's own methods, which made it
`group.begin_`. The two had never been compared because no test had a
property named after a keyword.

The fix makes the reader, the instance variable and every read the same
avoided name. The case it really fixes is not `begin`. It is a property
called `hash`, whose `attr_reader :hash` would have replaced Object#hash,
which is what a Hash calls to file a key. Every instance of that class
used as a key, or put in a Set, would have been filed by whatever the
property held, which is not what Temper's equality says and may not even
be an Integer.

## Local functions that call each other

`FunctionsLocals` has two local functions, each calling the other. Temper
hoists local functions; Ruby does not. A lambda that mentions `putter`
before `putter` has been assigned is calling a method named `putter`, and
that is a NameError (`probes/36_steep_forward_lambda/`). Declaring it
first, `putter = nil`, satisfies Ruby and gives Steep a nil-typed local.
Annotating that nil as a proc is "Assertion cannot hold". What works is a
value Steep thinks is untyped, asserted to be the proc type, which then is
checked:

```ruby
walker = TemperCore.forward_reference() #: (^(Integer, Array[Integer]) -> void)
putter = lambda do |i, out|
  out.push(TemperCore.int32(TemperCore.list_get(x, i) * 2))
  walker.(TemperCore.int32(i + 1), out)
end
```

`forward_reference` returns nil and is declared to return `untyped`,
which is the whole trick, and its comment says so. The probe also checks
that a wrong call through the forward-declared name is still an error,
which it is. A self-recursive local function gets the same treatment: Ruby
already sees it inside its own body, but Steep cannot type it there.

## Where it stands

Fifty-eight of sixty-seven, all typed, and now that means every library
the build writes, std included, parses and passes Steep. The four fresh
differential programs give the same Ruby output as before this chapter.
temper-core is at 62 minitest runs.

**Not done**, nine tests: `async` and generators (four: the actor pair,
`ControlFlowAsync`, `TypesNetresponse`), RBS for `Empty` and `Type` (two),
`@test` blocks, a connected function declared in the test's own library,
and `SemanticsBroken`. An imported function used as a value, rather than
called, stops the build; no test does that yet.
