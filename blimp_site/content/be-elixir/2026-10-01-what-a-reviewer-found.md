# 2026-10-01: what a reviewer found

Entries 25, 32 and 33 each came with tests and a list of programs that still
passed. This time the diffs of those chapters went to a reviewer that was
given the code and nothing else, no commit messages and no journal, and was
asked what was wrong with it. It found two things in entry 32 that turned
valid programs into failures, and the claims that hid them.

## A class found by its short name

Entry 32's check, "does this class define a setter for this property?",
found the class like this:

```kotlin
val base = (definition.name as? ResolvedParsedName)?.baseName?.nameText ?: return false
val decl = types[base]?.takeIf { it.kind == TmpL.TypeDeclarationKind.Class } ?: return false
```

`types` holds this library's classes by short name. When a dependency has a
class with the same short name, the local one answers for it:

```temper
// library base
export class Foo(public x: Int) {}
export let makeFoo(): Foo { new Foo(42) }

// library user
let { makeFoo } = import("base/src");
export class Foo(public y: Int) {}
console.log(makeFoo().x.toString());
```

user's `Foo` has no `x`, so the read became `broken code: read of .x on a
class that does not declare it`, on a program the frontend had no complaint
about. Entry 32's own comment said "another library's class cannot be
checked from here, so its accessor call stands". The code did not do that.

The lookup it copied had the same flaw: `concreteClassModule` sent the call
to `Temper.User.Foo.get_x`, so before entry 32 this program failed with
`UndefinedFunctionError`. Six more lookups did the same thing: instanceof,
casts, a type used as a value, constructor calls, ancestors, and
flattening members. All eight now go through one function that answers
only for a name that is not another library's:

```kotlin
private fun localType(name: TemperName?): TmpL.TypeDeclaration? {
    if (isExternal(name)) return null
    val base = (name as? ResolvedParsedName)?.baseName?.nameText ?: return null
    return types[base]
}
```

`journal/examples/samename/` is that program, run three ways:

```
$ temper run -b elixir --library user -w .
theirs.x=42 doubled=84
mine.y=1
```

js and py print the same. The test helpers build one library, so this case
is checked through the CLI rather than in `ElixirBackendTest`.

## A member inherited from another library

The second shape: a class that inherits a getter from another library's
interface.

```temper
// library base
export interface Named { get label(): String { "named" } }
// library user
export class Q() extends Named {}
console.log(new Q().label);
```

Flattening only follows supertypes this library declares, so it cannot see
`label`, and entry 32 called the read broken code. The check now says "don't
know" when any ancestor is another library's. That puts the program back
where it was before entry 32: `Q.get_label/1` and `Q.describe/1` are not
defined. That is a gap in the backend, not in the program, and it is the
next entry's work.

## A constructor still knows its arity

Entry 32 let a call that failed to type-check pass its arguments "as
written", on the grounds that its arity was unknown. For a constructor it is
not: the call's signature is lost, but the class's constructor is still
declared. With a defaulted third input, `new Query(n, [])` produced
`Query.new/2` against a `new/3`. Such a call now takes the constructor's own
signature and is padded like any other: `Query.new(n, %TemperCore.Vec{t:
{}}, nil)`.

## One more crash, found by fixing a test

The reviewer pointed out that entry 25's second test did not reach the code
it was named for: the block had already been cut short by an earlier raise.
Rewritten so that the read is the first thing to fail, with a parameter of
an undeclared type, it stopped the build again:

```
kotlin.NotImplementedError: getter AnyValue.fieldType has no Elixir support code
```

A parameter whose declared type does not exist is typed `AnyValue`, not
`Invalid`, and `AnyValue` has no properties at all. A read of one is broken
code: `broken code: read of .fieldType on a value with no properties`.

## Two titles, one name

Unrelated to those diffs, the reviewer also tried tests in two modules with
the same title. `temper test` handles them, but `mix test` would not compile
the generated file:

```
** (ArgumentError) "test same" is already defined in Temper.Dupt.TemperTest
```

That was against one `test/temper_test.exs` for the whole library. Entry 28,
merged while this chapter waited, writes one ExUnit file per source file, so
the reviewer's library (`src/a/a.temper.md` and `src/b/b.temper.md`, a
`test("same")` in each) now gets `a_test.exs` and `b_test.exs` and compiles
without help: `3 tests, 1 failure`, the one failure being the test written to
fail.

Two `test("same")` in one source file still land in one module. With the
numbering taken out of the generated file, `mix test` says:

```
** (ArgumentError) "test same" is already defined in Temper.Dupt1.OneTest
```

A repeated title within a file is now numbered, `same` and `same (2)`, and
that library also gives `3 tests, 1 failure`.

## What the review did not find

No problem with the block truncation at a raise (entry 25), the test
registration (entry 25), or the `__temper_main__` rename (entry 33). It
confirmed no valid same-library accessor is caught by the check: an
interface getter implemented by a field, an inherited concrete getter or
setter, a `public var` written from outside, an explicit get/set pair.

## Left as is

A broken read or write raises before evaluating its operands, so
`sideEffect().x` on a class without `x` never calls `sideEffect()`. js
evaluates them. It only happens in code the frontend rejected.

Five `ElixirBackendTest` cases changed or added, 8 in all. 65 of 65
functional tests pass; temper-core's own `mix test` is 93 tests, 0
failures. alloy, prismora, templight, blimp-highlight, temper_snake and the
`main` example compile with no warnings and pass as before.
