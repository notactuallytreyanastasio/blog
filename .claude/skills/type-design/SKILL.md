---
name: type-design
description: Design the types for a feature, module or domain before writing its logic, in Elixir, TypeScript or Rust. Enumerate the states, make the illegal ones unrepresentable, parse once at the boundary, and prove it by making the checker reject the illegal state. Use for "design the types for <x>", "model <domain>", "what should the type of <x> be", "make <state> impossible", "should this be a union / enum / struct", "type this properly", or whenever a function takes a record of optional fields plus a status that decides which fields matter. Not an annotation pass: it changes the shape of the data, so run it before the implementation, not after.
argument-hint: <what to model> [elixir|typescript|rust]
---

# Type design

The output of this skill is a set of type definitions, a parser at the
boundary, and a checker error. The checker error is the deliverable that
matters: a type design that cannot show the checker rejecting the illegal
state is a naming convention, not a type.

Language references, each with the idioms and the exact checker output:

- `elixir.md`: tagged tuples, one struct per state, `@enforce_keys`, the
  compiler's type checker, Dialyzer.
- `typescript.md`: discriminated unions, `never` exhaustiveness, branded
  primitives, `unknown` at the edge.
- `rust.md`: enums with data, newtypes with private fields, typestate,
  `TryFrom` at the edge.

Read the one for the language in play before Step 3.

## Step 0: What is being modelled

`$ARGUMENTS` names the thing (an order, a session, a sync job, a form) and
optionally the language. If the language is not given, take it from the
files the user is working in; if the thing is not given, ask for it in one
line. Do not start from the existing struct or interface. Start from what
the thing can *be*.

## Step 1: List the states, not the fields

Write a table before any code:

| State     | What is known in this state         | What can happen next   |
| --------- | ----------------------------------- | ---------------------- |
| draft     | items                               | submit                 |
| submitted | items, total, submitted_at          | pay, cancel            |
| paid      | items, total, submitted_at, receipt | refund                 |

Three signs the current shape is wrong, each of which this table exposes:

- A `status` field next to several fields that are only meaningful for some
  statuses. (`receipt` is nil in every state but one.)
- A boolean that decides which other fields to read. (`is_guest` and
  `author_name`.)
- A function that starts by checking that a field "should" be present given
  another field, and raising or returning an error if it is not.

If the table has one row, the thing is a record, not a state machine, and
this skill's remaining steps are short. If it has a row whose "known" column
is a subset of another row's, that is a transition, not a separate type;
keep it.

## Step 2: Draw the boundary

Divide every place the data arrives into *outside* and *inside*:

- **Outside**: HTTP params, JSON bodies, database rows, files, environment
  variables, messages from another service, user input. Shape is not
  guaranteed. One parser per entry point turns an outside value into an
  inside value or a named error, once.
- **Inside**: every function after the parser. It takes the inside type and
  cannot fail because of shape. No re-validation, no `if is_nil`, no
  "should not happen" branch.

Write down where the parser goes. In a Phoenix app it is a changeset or a
function in the context module; in a TypeScript service it is the function
that takes `unknown`; in Rust it is a `TryFrom` or a `parse` function on the
type. The inside type must be impossible to construct without going through
it (an opaque type, a private constructor, a module boundary).

## Step 3: Make the illegal states unrepresentable

For each row in the table, one variant with exactly the fields that row
knows. Nothing optional unless the thing is genuinely absent in that state.

- Sum over product: a union / enum / tagged tuple with one variant per
  state, instead of one struct with a status and nullable fields.
- Newtype the primitives that carry a rule: an email that has been checked,
  a non-negative amount in cents, a non-empty list, an id of one entity and
  not another. A `string` that must have an `@` in it is a different type
  from `string`.
- Transitions are functions from one variant to another, taking only what
  the transition needs. `submit(draft, total) -> submitted`. They are the
  only way to get from one state to the next.
- Dispatch on the variant with an exhaustive match and no catch-all. A new
  state must break every match that does not handle it.

The language reference says how each of these is spelled and which of them
the checker actually enforces.

## Step 4: Prove it

Write the illegal state and run the checker. Keep the probe out of the
source tree (a scratch file is fine). The three probes that cover most
designs:

1. A match that forgets a variant.
2. A read of a field from a variant that does not have it.
3. A construction that bypasses the parser or constructor.

Paste the checker's output into the commit message or the PR body. If the
checker accepts one of the probes, the design does not enforce that rule;
say so, and either change the design or state that the rule lives in a test
instead.

## Step 5: Deliver

In this order:

1. The type definitions, with a one-line comment per variant saying when it
   exists.
2. The parser at the boundary and the transitions.
3. The probes and the checker's rejection of each.
4. What stays dynamic, and why. A JSON blob passed straight through to a
   client is fine as a map; say that it is.

Then implement the logic against the inside types. If a function needs a
field the variant does not have, that is the design catching a bug, not a
reason to add an optional field.

## When not to

- A script, a one-off migration, a test fixture.
- A record that has one state. Give it a struct and stop.
- Data the program carries but never interprets.

A newtype for every string and a variant for every flag makes the design
harder to read than the bug it prevents. The test is Step 1: if nothing in
the states table is illegal, there is nothing to make unrepresentable.
