# be-ruby: a journal

A Temper backend for Ruby, written in the open, with types. This directory
is the running record of building it: one entry per working session, newest
last, plus a guide that grows as the backend does. Ruby should be the easy
target, since it already has nearly everything Temper has. Most of what
follows is about the word "nearly".

- [guide.md](guide.md) -- how the backend works as it stands, and what it
  cannot do yet.
- [probes/](probes/) -- the Ruby scripts every claim about the target was
  checked with, because "I'm pretty sure Ruby does X" has a poor track
  record. Run any of them with `ruby probes/<file>.rb`, or the `run.sh` or
  `run.rb` in a probe that is a directory. They were written against ruby
  4.0.7.

## Entries

1. [2026-10-10: the easy one, and the four ways it is not](2026-10-10-the-easy-one.md)
2. [2026-10-10: a backend that says hello whatever you tell it](2026-10-10-hello-whatever-you-say.md)
3. [2026-10-10: temper-core, and a type checker you have to talk into it](2026-10-10-the-runtime-and-the-receipts.md)
