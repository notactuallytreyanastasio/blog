Async ordering and generators, written fresh for journal entry 13, on the
js, py and ruby backends. `sh run.sh <temper>` regenerates `*.out`.

The three disagree about when an async block runs, and Temper's docs say
only that `async` "runs it out of band":

- ruby runs a block at once, up to its first `await` of an unsettled
  promise, and resumes blocks after the top level finishes, in the order
  their promises settled. The output is the same every run.
- js starts no block until the top level has finished (`js.out`), and then
  stops at `is ValueResult`: `ReferenceError: ValueResult_24 is not
  defined`, a missing import in its generated code.
- py runs blocks on a thread pool, so its order is whatever the threads
  do; `py.out` is one run of it. An earlier version of this program, with
  a `while (!g.done)` loop, ran for ten minutes at full CPU on js before
  I stopped it; `done` apparently never became true there.
