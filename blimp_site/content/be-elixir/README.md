# be-elixir: a journal

A Temper backend for Elixir and the BEAM, written in the open. This directory
is the running record: one entry per working session, newest last, plus a
guide that grows as the backend does.

- [guide.md](guide.md) -- how the backend works, written as a tutorial: what a
  Temper construct becomes in Elixir and why. Updated with every chapter.
- [probes/](probes/) -- the Elixir scripts every claim about the target was
  checked with. Run any of them with `elixir probes/<file>.exs`.

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
