Async ordering and generators, written fresh for journal entry 13, on the
interpreter and the js, py and ruby backends. `sh run.sh <temper>`
regenerates `*.out`.

Temper's docs say only that `async` "runs it out of band", and the
backends disagree about when a block runs:

- the interpreter starts no block until the top level has finished, then
  runs them in the order they were launched (`interp.out`). js and rust
  do the same (rust from issue #516's table).
- ruby now does too, and `ruby.out` matches `interp.out` line for line.
  Until entry 16 it ran a block at once, up to its first `await` of an
  unsettled promise. Entry 13 compared only js, py and ruby, never ran the
  interpreter, and kept that order on the grounds that it was the same
  every run. It was, but it was not the reference's order.
- js stops at `is ValueResult`: `ReferenceError: ValueResult_24 is not
  defined`. An earlier version of this program, with a `while (!g.done)`
  loop, ran for ten minutes at full CPU on js before I stopped it. js's
  generators have no `done` property, so `!g.done` is always true. Both
  are in upstream issue #579.
- py runs blocks on a thread pool, so its order is whatever the threads
  do; `py.out` is one run of it. It has no generator step lines because
  `is ValueResult` fails there too, with `NameError: name '_value_result'
  is not defined`, also in #579.
