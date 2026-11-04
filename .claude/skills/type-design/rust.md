# Type design in Rust

The thing to know first: Rust enforces more of this design than the other
two languages, so the temptation is the opposite one. A match is exhaustive
unless you write `_ =>`; a private field stops construction outside the
module; a transition that takes `self` by value makes the old state
unusable. The design work is choosing *not* to undo those with a wildcard
arm, a `pub` field, or `Clone` on something that should move.

Output below is from `rustc` 1.96.0.

## What the compiler enforces

An enum with one variant per state, and a match that forgets one:

```rust
pub enum Order {
    Draft { items: Vec<String> },
    Submitted { items: Vec<String>, total: Cents },
    Paid { items: Vec<String>, total: Cents, receipt: String },
}

fn label(order: &Order) -> &'static str {
    match order {
        Order::Draft { .. } => "Draft",
        Order::Submitted { .. } => "Submitted",
    }
}
```

```
error[E0004]: non-exhaustive patterns: `&Order::Paid { .. }` not covered
  --> probe.rs:20:11
   |
20 |     match order {
   |           ^^^^^ pattern `&Order::Paid { .. }` not covered
```

A newtype with a private field, constructed from outside its module:

```rust
mod order {
    pub struct Cents(i64);
    impl Cents {
        pub fn new(value: i64) -> Option<Cents> {
            if value >= 0 { Some(Cents(value)) } else { None }
        }
    }
}

fn negative() -> order::Cents {
    order::Cents(-5)
}
```

```
error[E0423]: cannot initialize a tuple struct which contains private fields
  --> probe.rs:27:5
   |
27 |     Cents(-5)
   |     ^^^^^
note: constructor is not visible here due to private fields
```

Both are hard errors. Note what makes the second one work: the `mod`
boundary. A newtype whose field is private but which is defined in the
same module as its callers is constructible by them; the rule is only as
strong as the module line.

## How to spell the design

### Enums with data per variant

Fields a state does not have are not in that variant. Shared fields repeat
across variants rather than moving to an outer struct with an `Option`;
if the repetition is large, the variants hold a shared struct:

```rust
pub struct Core { items: Vec<Item> }
pub enum Order {
    Draft(Core),
    Submitted { core: Core, total: Cents, at: DateTime<Utc> },
    Paid { core: Core, total: Cents, at: DateTime<Utc>, receipt: Receipt },
}
```

On a public enum, `#[non_exhaustive]` forces downstream crates to write a
wildcard arm, which is the opposite of what this skill wants. Use it on
error enums that will grow, not on state enums.

### Newtypes

```rust
pub struct Cents(i64);                 // private field: only `new` builds one
pub struct UserId(u64);
pub struct OrderId(u64);               // `find_order(user.id)` is now an error
```

`NonZeroU32` and friends from `std::num` are the standard library's
newtypes for "not zero"; `Option<NonZeroU32>` is the same size as `u32`.

Derive only what the type should do. A `Cents` that is `Copy + PartialOrd +
Add` is fine; a `Receipt` that is `Default` is a receipt that came from
nowhere. `#[must_use]` on a type whose value carries an obligation (a
`Submitted` that must be paid or cancelled) turns a dropped value into a
warning.

### Transitions consume the old state

```rust
impl Draft {
    pub fn submit(self, total: Cents, at: DateTime<Utc>) -> Result<Submitted, SubmitError> {
        if self.items.is_empty() { return Err(SubmitError::Empty); }
        Ok(Submitted { items: self.items, total, at })
    }
}
```

`self` by value: after `submit`, the `Draft` is gone, and using it is
`E0382: use of moved value`. That is the compiler enforcing "a draft that
has been submitted is not a draft any more", for free, as long as the
state types are not `Clone` where cloning would mean "two live copies of
the same order".

Typestate goes one step further when the states share almost everything:

```rust
pub struct Order<S> { items: Vec<Item>, state: S }
pub struct Draft;
pub struct Submitted { total: Cents }

impl Order<Draft> {
    pub fn submit(self, total: Cents) -> Order<Submitted> { ... }
}
impl Order<Submitted> {
    pub fn pay(self, receipt: Receipt) -> Order<Paid> { ... }
}
```

`pay` does not exist on `Order<Draft>`; calling it is `E0599: no method
named pay`. The cost is that a collection of orders in mixed states needs
an enum anyway, so typestate suits a pipeline (one value moving forward),
and an enum suits a list.

### The boundary

```rust
impl TryFrom<OrderDto> for Order {
    type Error = ParseError;
    fn try_from(dto: OrderDto) -> Result<Self, Self::Error> { ... }
}
```

The DTO is the serde type, every field `Option` and `String`, derived
`Deserialize`. The domain type is built from it once by `TryFrom`, and
inside code never sees a DTO. `From` is for conversions that cannot fail;
if a `From` impl contains `unwrap`, it is a `TryFrom`.

Error enums with one variant per thing that can go wrong, not a `String`.
`thiserror` writes the `Display` impl; without it, write it by hand. Inside
functions return `Result<T, E>` with the narrowest `E` they can; the
boundary maps into the one the caller sees.

## Proving it

```bash
cargo check
cargo clippy -- -D warnings
```

Probe 1 (forgotten variant): remove a match arm. Expect `E0004
non-exhaustive patterns`. If the match has `_ =>`, delete it and see what
the compiler says the arm was hiding.

Probe 2 (field from the wrong variant): there is no way to write it; the
field is in a variant pattern or it is not accessible. The probe is a
`match` that binds `receipt` in the `Draft` arm, and the error is `E0026:
variant Order::Draft does not have a field named receipt`.

Probe 3 (bypassing the constructor): construct the newtype from another
module. Expect `E0423 cannot initialize a tuple struct which contains
private fields`. If it compiles, the probe is in the same module as the
type; that is a finding about where the type lives.

Probe 4 (using a consumed state): call a method on a value after passing
it to a transition. Expect `E0382 use of moved value`. If it compiles, the
state is `Clone` or `Copy`, or the transition took `&self`; decide which
of those is the bug.

Clippy adds `clippy::large_enum_variant` when one variant is much bigger
than the rest (box it) and `clippy::wildcard_enum_match_arm` (allow-by-
default; turn it on for the state enums) when a match uses `_` on an enum
from this crate.
