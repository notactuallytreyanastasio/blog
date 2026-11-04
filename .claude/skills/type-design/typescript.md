# Type design in TypeScript

The thing to know first: TypeScript's types vanish at runtime, so a value
that arrived as JSON is whatever the network sent, whatever its annotation
says. The whole design rests on one habit: the boundary function takes
`unknown` and narrows it by inspection. An `as Order` at the boundary is a
comment, not a parser.

Output below is from `tsc` 5.9.3 with `--strict`.

## What the compiler enforces

A discriminated union with one member per state:

```ts
type Order =
  | { kind: "draft"; items: readonly string[] }
  | { kind: "submitted"; items: readonly string[]; submittedAt: Date }
  | { kind: "paid"; items: readonly string[]; submittedAt: Date; receipt: string };
```

A `switch` that forgets a variant, with `assertNever` in the default:

```ts
function assertNever(x: never): never {
  throw new Error(`unhandled: ${JSON.stringify(x)}`);
}

function label(order: Order): string {
  switch (order.kind) {
    case "draft":     return "Draft";
    case "submitted": return "Submitted";
    default:          return assertNever(order);
  }
}
```

```
error TS2345: Argument of type '{ kind: "paid"; items: readonly string[];
submittedAt: Date; receipt: string; }' is not assignable to parameter of type 'never'.
```

Reading a field only one variant has, without narrowing first:

```ts
function receiptOf(order: Order): string {
  return order.receipt;
}
```

```
error TS2339: Property 'receipt' does not exist on type 'Order'.
  Property 'receipt' does not exist on type '{ kind: "draft"; items: readonly string[]; }'.
```

Passing a plain string where a branded one is required:

```ts
type Email = string & { readonly __brand: "Email" };
function send(to: Email): void {}
send("someone@example.com");
```

```
error TS2345: Argument of type 'string' is not assignable to parameter of type 'Email'.
  Type 'string' is not assignable to type '{ readonly __brand: "Email"; }'.
```

All three are compile errors, not warnings, and all three disappear with
`as any` or `as Email`. A grep for `as ` in the inside code is part of the
review.

## How to spell the design

### Discriminated unions, one member per state

The discriminant is a string literal field, conventionally `kind` or
`type`, present on every member. Fields a state does not have are absent
from that member, not optional. `readonly` on arrays and on object fields
unless something mutates them, so a transition returns a new value instead
of editing the old one.

Without `assertNever`, a missing case is silent: the function returns
`undefined` and the return type check is the only thing that might notice.
Put `assertNever` in every `default`. With
`switch` on a union and a declared return type, `tsc` also reports
"Function lacks ending return statement" when a case is missing; the
`assertNever` message is the clearer of the two.

### Branded primitives

```ts
type Email = string & { readonly __brand: "Email" };

function parseEmail(raw: string): Email | null {
  return /^[^@\s]+@[^@\s]+$/.test(raw) ? (raw as Email) : null;
}
```

The one `as Email` lives inside `parseEmail` and nowhere else. The brand is
erased at runtime; an `Email` is a `string` when it is logged or sent.
Brand ids too: `UserId` and `OrderId` are both `number` underneath, and
without brands `findOrder(user.id)` type-checks.

### Transitions

```ts
function submit(order: Extract<Order, { kind: "draft" }>, at: Date):
  Extract<Order, { kind: "submitted" }> {
  return { kind: "submitted", items: order.items, submittedAt: at };
}
```

`Extract<Order, { kind: "draft" }>` names one member of the union without
declaring it twice. If the members are used on their own a lot, declare
them as named types and build `Order` from them.

### The boundary

```ts
function parseOrder(input: unknown): Order | ParseError {
  if (typeof input !== "object" || input === null) return { error: "not an object" };
  const o = input as Record<string, unknown>;
  switch (o.kind) {
    case "draft":
      return Array.isArray(o.items) ? { kind: "draft", items: o.items.map(String) } : { error: "items" };
    // ...
    default:
      return { error: `unknown kind ${String(o.kind)}` };
  }
}
```

`unknown` in, a union or a named error out, one `as Record<string,
unknown>` to get at the keys. Everything after `parseOrder` takes `Order`.
A schema library (zod, valibot) does the same job with less code; the
contract is the same: `unknown` in, the inside type out, the inferred type
of the schema *is* the inside type, never a second hand-written copy.

### Compiler flags that make the design hold

In `tsconfig.json`:

- `"strict": true`. Without it, `null` is assignable to everything and the
  union narrowing above is partial.
- `"noUncheckedIndexedAccess": true`. `items[0]` is `string | undefined`,
  which is what it is.
- `"exactOptionalPropertyTypes": true`. An optional field cannot be set to
  `undefined` explicitly, so "absent" and "present but undefined" stop
  being two states.
- No `any` in the inside code; `@typescript-eslint/no-explicit-any` as an
  error if the project lints.

## Proving it

```bash
npx tsc --noEmit
```

Probe 1 (forgotten variant): remove a `case` from a switch that ends in
`assertNever`. Expect `TS2345 ... not assignable to parameter of type
'never'`.

Probe 2 (field from the wrong variant): read the field on the union type
without narrowing. Expect `TS2339 Property ... does not exist on type`.

Probe 3 (bypassing the parser): pass a `string` where the branded type is
required. Expect `TS2345 Argument of type 'string' is not assignable`.
Then grep the inside code for `as Email` (or whatever the brand is); the
count should be one, in the parser.

The thing TypeScript cannot prove: that the parser is right. A parser that
accepts `{ kind: "paid" }` without a receipt and returns it as `Order` is a
type error the compiler never sees, because the `as` inside the parser is
trusted. The parser gets unit tests with malformed input; that is the
proof for Step 2.
