# 2026-10-01: the constructor of a rejected class

Entry 25 left one thing open. ormery's `Query` declares its constructor
inputs twice, which the frontend rejects, and its constructor still says
`this.schema = schema` about a property the class no longer has. That
compiled to:

```elixir
def new(schema) do
  this = TemperCore.Heap.new(Temper.Inv.Query, %{})
  Temper.Inv.Query.set_schema(this, schema)
  this
end
```

`set_schema/2` is never defined: a compiler warning, and an
`UndefinedFunctionError` when Elixir code constructs the class.

## Asking the question the module will answer

A class module defines `set_x` exactly when the class's flattened members
include a setter for `x` with a body; `translateType` writes one function
per such member. So before calling a setter, the translator now asks the
same question of the subject's static type. When the type is a class of
this library and the answer is no, the write is broken code, like the rest
of the class:

```
** (TemperCore.Panic) broken code: write of .schema on a class that does not declare it
```

The fifteen-line repro now compiles with no warnings at all and raises that
when Elixir constructs the class. A class from another library cannot be
inspected from here, so a call into one stands.

Reads had the same problem, `get_schema/1`, and get the same check.

## A call with no signature

The second ORM showed a third shape:

```
warning: Temper.Orm.Query.new/1 is undefined or private. Did you mean:
      * new/6
 795 │ Temper.Orm.Query.new(%TemperCore.Vec{t: {tableName, %TemperCore.Vec{t: {}}, ...}})
```

`new Query(tableName, [], [], [], null, null)` failed to type-check, because
another type in that library did not compile. A call the frontend could not
check carries `invalidSig`:

```kotlin
val invalidSig = Signature2(
    returnType2 = WellKnownTypes.invalidType2,
    hasThisFormal = false,
    requiredInputTypes = listOf(),
    restInputsType = WellKnownTypes.invalidType2,
)
```

No fixed parameters and a rest parameter, so `arguments` packed all six into
the rest list. With the real arity unknown, the arguments now go as
written, which is what js does: `new Query(tableName_249, Object.freeze([]),
..., null, null)`.

## Checking

Three `ElixirBackendTest` cases, one per shape, each red before its fix.
The getter and the signature were found by counting what warnings the two
ORMs still produced after the setter fix. After all three, neither ORM's
Elixir calls an undefined function. Valid programs are unchanged and still
compile without a warning: alloy 225/225, prismora 12/12, templight
140/140, blimp-highlight 11/11, temper_snake 31/31.

What the ORMs still print is Elixir's type checker reasoning about values
whose types did not compile: ormery 36 "incompatible types given to", the
other 10 of those and 35 "comparison between distinct types". A constructor
that now raises is inferred to return `none()`, and every call that uses
its result is flagged. That is accurate, and it is about code the frontend
refused.

## What is left

ormery's last warning of another kind is not about broken code:

```
warning: clauses with the same name and arity ... "def main/0" was previously defined
```

ormery exports a function called `main`, and be-elixir names its own entry
point `main/0`. The user's is emitted first, so the entry point never runs.
Four lines show the cost:

```temper
console.log("top level ran");
export let main(): Void { console.log("user main ran"); }
```

```
$ mix run --no-compile -e 'Temper.Mainclash.main()'
top level ran
user main ran
```

The program printed "user main ran" though nothing called `main`, and the
entry point's `TemperCore.Async.drain()` never ran, so async work would be
left in the queue. Fixing it means renaming one of the two, which changes
how a translated program is run.

65 of 65 functional tests pass.
