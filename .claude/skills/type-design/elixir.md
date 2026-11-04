# Type design in Elixir

The thing to know first: `@type` and `@spec` are not checked by the compiler.
The compiler's own type checker (Elixir 1.18 and later) infers types from
patterns, guards and the functions you call, and ignores typespecs
altogether. Dialyzer reads the specs. So a design has two checkers with
different ideas of what the types are, and "the illegal state is rejected"
has to be shown against one of them by name.

Output below is from Elixir 1.19.5 on OTP 28.

## What the compiler enforces

Given a function with one clause per state:

```elixir
@spec label(status()) :: String.t()
def label(:draft), do: "Draft"
def label(:submitted), do: "Submitted"
def label(:paid), do: "Paid"

def bad_call, do: label(:refunded)
```

`mix compile` rejects the call, from the clause heads alone, no spec
needed:

```
warning: incompatible types given to label/1:

    label(:refunded)

given types:

    -:refunded-

but expected one of:

    #1
    dynamic(:draft)

    #2
    dynamic(:submitted)

    #3
    dynamic(:paid)
```

It also rejects reading a key the struct does not have:

```
warning: unknown key .totl_cents in expression:

    order.totl_cents

the given type does not have the given key:

    dynamic(%Probe.Order{status: term(), total_cents: term()})
```

What it does **not** reject: `%Order{status: :paid, total_cents: "12"}`.
The struct's fields are `term()` as far as the compiler is concerned; the
`@type t` saying `pos_integer()` changes nothing. The same probe produced
no warning for it. Field types are enforced by constructors and by
Dialyzer, not by `defstruct`.

## How to spell the design

### One tagged tuple or one struct per state

The idiomatic sum type is a tagged tuple, and the compiler tracks the tag:

```elixir
@type order ::
        {:draft, Draft.t()}
        | {:submitted, Submitted.t()}
        | {:paid, Paid.t()}
```

with one struct per state, each with only the fields that state has:

```elixir
defmodule Order.Submitted do
  @enforce_keys [:items, :total, :submitted_at]
  defstruct [:items, :total, :submitted_at]

  @type t :: %__MODULE__{
          items: [Item.t(), ...],
          total: Money.cents(),
          submitted_at: DateTime.t()
        }
end
```

`@enforce_keys` is a runtime check on construction, and it is the one that
catches a transition that forgot a field. A missing key raises an
`ArgumentError` at the `%Submitted{}` literal, which is where the bug is.

A single struct with a `status` atom and nilable fields is acceptable when
the states differ by one or two fields and the struct is an Ecto schema
that has to match one table. Then the rule lives in the changeset and in
the transition functions, and the probe in Step 4 is a test, not a
compiler warning. Say so in the delivery.

### Transitions are functions, matches are exhaustive

```elixir
@spec submit(Draft.t(), Money.cents()) :: {:ok, Submitted.t()} | {:error, :empty}
def submit(%Draft{items: []}, _total), do: {:error, :empty}
def submit(%Draft{items: items}, total) do
  {:ok, %Submitted{items: items, total: total, submitted_at: DateTime.utc_now()}}
end
```

Dispatch on the tag with one clause per variant and no `_ ->`. A missing
clause is a `FunctionClauseError` at runtime, not a compile error, so a new
variant needs a test that exercises every dispatch. The compiler helps only
when the call site passes a literal, as in `label(:refunded)` above.

### Newtypes

Elixir has no zero-cost newtype. The choices, cheapest first:

- A `@type cents :: non_neg_integer()` alias and a constructor that
  validates: documentation plus Dialyzer. Nothing stops a caller passing
  `-5`.
- A one-field struct, `%Money{cents: 1200}`, with `@opaque t` and a
  `new/1` that returns `{:ok, t} | {:error, reason}`. Pattern-matching on
  `%Money{}` in every function that takes one means a raw integer is a
  `FunctionClauseError` at the first use. This is the one to use when the
  rule matters.

`@opaque` makes Dialyzer warn when another module pattern-matches on the
struct's insides, which is how "only constructible through `new/1`" is
enforced.

### The boundary

A changeset is the parser. `cast/3` then `validate_*` then
`apply_action(:insert)` turns params into a struct or an error, once. The
inside functions take the struct. Passing a params map past the context
module is the smell this skill exists to remove.

For non-Ecto input (a JSON body, a message), write a `parse/1` that returns
`{:ok, struct} | {:error, reason}` and keep every `Map.get` inside it.
Never `String.to_atom/1` on the way in; map the known strings to atoms
explicitly and reject the rest.

`Ecto.Enum` for a status column gives the atom list in one place and
rejects unknown values at the changeset. Pair it with `@type status ::
:draft | :submitted | :paid` so Dialyzer sees the same set.

## Proving it

```bash
mix compile --force --warnings-as-errors   # the compiler's type checker
mix assay                                   # Dialyzer, this repo's wrapper
```

Probe 1 (forgotten variant): write a call with a literal the clauses do not
cover. Expect `incompatible types given to`. If the call site is not a
literal, the compiler cannot see it; write a test and expect
`FunctionClauseError`.

Probe 2 (field from the wrong variant): read `order.receipt` on a value the
compiler knows is a `%Draft{}`. Expect `unknown key .receipt`.

Probe 3 (bypassing the constructor): `%Money{cents: -5}` compiles. There is
no compile-time rejection in Elixir. The rejection is the test that calls
`Money.new(-5)` and asserts `{:error, :negative}`, plus `@opaque` so that
Dialyzer flags a module reaching inside. State this in the delivery rather
than implying the type caught it.

Dialyzer's warning for a spec violation names the call and says it
`breaks the contract`, quoting the spec. It only appears for code the
success typing can see through; a value that came from a map lookup is
`term()` and passes. The compiler warnings above were reproduced for this
document; the Dialyzer run was not, because a cold PLT build takes minutes.
Run `mix assay` once on the real module and paste its output.
