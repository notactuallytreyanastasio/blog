# be-elixir: a journal

A Temper backend for Elixir and the BEAM, written in the open. This directory
is the running record: one entry per working session, newest last, plus a
guide that grows as the backend does.

- [guide.md](guide.md) -- how the backend works as it stands: running it, what
  each Temper construct becomes in Elixir and why, and its limits.
- [probes/](probes/) -- the scripts every claim about the target was
  checked with. Run an `.exs` one with `elixir probes/<file>.exs`; a
  directory has a README saying how to run it.
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
23. [2026-10-01: compiling without warnings](2026-10-01-no-warnings.md)
24. [2026-10-01: a library initializes itself](2026-10-01-self-init.md)
25. [2026-10-01: programs the suite never saw](2026-10-01-outside-programs.md)
26. [2026-10-01: a real app](2026-10-01-a-real-app.md)
27. [2026-10-01: the runtime's hot paths](2026-10-01-hot-paths.md)
28. [2026-10-01: tests out of the library, and tests that test something](2026-10-01-tests-out-of-the-library.md)
29. [2026-10-01: what production cannot reach](2026-10-01-what-production-cannot-reach.md)
30. [2026-10-01: code nothing reaches](2026-10-01-code-nothing-reaches.md)
31. [2026-10-01: names that stay put](2026-10-01-names-that-stay-put.md)
32. [2026-10-01: the constructor of a rejected class](2026-10-01-rejected-constructor.md)
33. [2026-10-01: a library may have a `main`](2026-10-01-temper-main.md)
34. [2026-10-01: what a reviewer found](2026-10-01-what-a-reviewer-found.md)
35. [2026-10-01: what a `do` assigned before it bubbled](2026-10-01-try-keeps-assignments.md)
36. [2026-10-01: a hoisted function, made too early](2026-10-01-hoisted-closures.md)
37. [2026-10-01: `<=>` on floats, and the empty string](2026-10-01-float-order-and-empty-index.md)
38. [2026-10-01: two differences, kept on purpose](2026-10-01-kept-on-purpose.md)
39. [2026-10-01: the backend moves into Temper](2026-10-01-the-backend-moves-into-temper.md)
40. [2026-10-01: a loop whose condition fails while compiling](2026-10-01-a-loop-whose-condition-fails.md)
41. [2026-10-01: typespecs, and a Dialyzer that checks them](2026-10-01-typespecs-and-a-dialyzer-that-checks-them.md)
42. [2026-10-01: one class is not another](2026-10-01-one-class-is-not-another.md)
43. [2026-10-01: what Elixir can call, and what `h` shows](2026-10-01-what-elixir-can-call.md)
44. [2026-10-01: an app you can change](2026-10-01-an-app-you-can-change.md)
45. [2026-10-01: a return is not a throw](2026-10-01-a-return-is-not-a-throw.md)
46. [2026-10-02: a plain list at the door](2026-10-02-a-plain-list-at-the-door.md)
47. [2026-10-02: a loop is a named function](2026-10-02-a-loop-is-a-named-function.md)
