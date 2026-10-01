# be-elixir: a journal

A Temper backend for Elixir and the BEAM, written in the open. This directory
is the running record: one entry per working session, newest last, plus a
guide that grows as the backend does.

- [guide.md](guide.md) -- how the backend works as it stands: running it, what
  each Temper construct becomes in Elixir and why, and its limits.
- [probes/](probes/) -- the Elixir scripts every claim about the target was
  checked with. Run any of them with `elixir probes/<file>.exs`.
- [examples/](https://github.com/notactuallytreyanastasio/temper-blimp/tree/main/journal/examples) -- runnable Temper libraries with the Elixir that
  drives them, such as `bank/`, a set of `@actor` accounts.

## Entries

1. [2026-09-30: what an object is on the BEAM, and the output grammar](2026-09-30-what-an-object-is.md)
2. [2026-10-01: loops without loops](2026-10-01-loops-without-loops.md)
3. [2026-10-01: classes as modules, objects as structs or heap refs](2026-10-01-classes-as-modules.md)
4. [2026-10-01: closures, cells, and failing by name](2026-10-01-closures-and-cells.md)
5. [2026-10-01: a list builder is a list, too](2026-10-01-lists.md)
6. [2026-10-01: a string index is a byte offset](2026-10-01-strings.md)
7. [2026-10-01: maps keep their order, and the user writes the Elixir](2026-10-01-maps-and-the-rest.md)
8. [2026-10-01: `@test` blocks, and the file `.gitignore` ate](2026-10-01-tests-and-a-missing-file.md)
9. [2026-10-01: generators and async as state machines](2026-10-01-generators-as-state-machines.md)
10. [2026-10-01: floats past the BEAM's edge](2026-10-01-floats-past-the-edge.md)
11. [2026-10-01: std was there all along](2026-10-01-libraries.md)
12. [2026-10-01: regex, broken code, and 65 of 65](2026-10-01-regex-and-broken-code.md)
13. [2026-10-01: output a person can read](2026-10-01-readable-output.md)
14. [2026-10-01: a concrete class is the class](2026-10-01-static-dispatch.md)
15. [2026-10-01: long-running programs](2026-10-01-long-running.md)
16. [2026-10-01: clause bodies, fields, and `cond`](2026-10-01-readability-finished.md)
17. [2026-10-01: lists that index in constant time](2026-10-01-lists-that-index.md)
18. [2026-10-01: `@imu` is the contract, and the heap collects itself](2026-10-01-imu-and-entry.md)
19. [2026-10-01: `@actor`: a Temper object that is a process](2026-10-01-actors.md)
20. [2026-10-01: supervised actors, and one set of module values per node](2026-10-01-supervision-and-shared-state.md)
21. [2026-10-01: std's values are values again, and two libraries meet](2026-10-01-std-imu-and-two-libraries.md)
22. [2026-10-01: `mix test`](2026-10-01-mix-test.md)
