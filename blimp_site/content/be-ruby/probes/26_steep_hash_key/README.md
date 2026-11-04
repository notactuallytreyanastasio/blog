Steep 2.1 and RBS 4.2 against a Hash whose key type is a method's type
parameter. `steep check` here prints the errors quoted in journal entry 10.

RBS asks a Hash key for `hash` and `eql?` (`Hash::_Key`). An unbounded `K`
cannot be passed to `Hash#[]` (`plain`). Bounded by `Hash::_Key`, it can go
to `[]`, `key?`, `fetch(key, default)`, `delete`, `store` and `to_h`, but
not to `fetch(key) { ... }` or to another method with a bounded type
parameter of its own (`calls_bounded`): "Unsatisfiable constraint". A
bounded `K` can go to an unbounded one (`bounded_calls_plain`), and an
unbounded key annotated `untyped` can go anywhere (`cast_key`).
