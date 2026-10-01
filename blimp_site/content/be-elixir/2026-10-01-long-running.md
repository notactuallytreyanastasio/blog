# 2026-10-01: long-running programs

Entry 1 put mutable Temper objects in a heap in the process dictionary,
and promised two costs: an object is never freed, and it only exists in
the process that made it. A script never notices either. A server notices
both. This chapter adds no new object model. It adds three things on top
of the existing one, each measured.

## A heap dies with its process

First I checked what the BEAM already does. A process put 200,000
objects in its dictionary and then exited
(`probes/09_closures_and_process_memory.exs`):

```
child memory with 200k objects: {:memory, 36097808}
processes memory before/after exit, alive?: {50198824, 16826224, false}
```

So a process per request or per job, the usual way to structure work on
the BEAM, already frees everything. That needs no code.

## `collect` for a process that lives on

A GenServer that holds Temper objects across calls never exits, so it
needs a collector. `TemperCore.Heap.collect(roots)` is mark and sweep. It
keeps every object reachable from:

- the roots passed in, which is whatever the caller still holds, such as
  the GenServer's state
- everything else in the process dictionary: Temper's globals, the async
  queue, anything the host keeps there
- anything those reach, through objects, lists, tuples, maps and
  closures

Every other object is freed, cycles included. A closure is traced through
its captured values, which the same probe confirmed `fun_info` returns:

```
local fn env: {:env, [%{id: #Reference<...>}]}
external capture env: {:env, []}
```

`collect` cannot see the stack. A local in a Temper function that is
still running is not a root, so this is only safe between calls into
Temper code. The host knows when that is; the translated code does not.

The test was a translated Temper service, run under a real GenServer for
100,000 requests. Each request makes a `StringBuilder` and a scratch
object, and adds to one long-lived counter:

```
collect=false: 200001 objects, 49364 KB, tally 100000, 492 ms for 100k requests
collect=true:  1 objects, 18 KB, tally 100000, 194 ms for 100k requests
```

The one object left is the counter, and its count is right. Collecting
was faster as well, because a process dictionary that keeps growing slows
every put and every garbage collection.

## `export` and `import` across processes

A ref is an id into one process's heap. Sent as is, it fails in the
receiver:

```
** "%TemperCore.Ref{class: Temper.Svc.Tally, id: #Reference<...>} is not an object in this process"
```

That is loud, which is right. The way across is
`TemperCore.Heap.export(value)`, which copies every object the value
reaches, followed by `import/1` in the receiver:

```
before send: 2
in the other process: 42
sender after: 2
```

There, the tally took `+40` and read 42. The sender's copy still says 2,
because an export is a copy, like any message.

The copies keep their ids. A ref's id is a `make_ref()`, which is unique
across processes and nodes, so the receiver can adopt it unchanged. This
is the reason export works at all: a ref captured inside a closure cannot
be rewritten, and with unchanged ids it never needs to be. Aliasing inside
the value survives as well. The unit test sends two fields that point at
one object and a closure that reads it, and all three see one write on
the other side.

## What this does not do

Temper code still runs in one process. Async is a queue in that process,
and nothing makes Temper's own code concurrent. These tools let the host
use processes around Temper code: a process per request, a GenServer that
collects, and messages that carry exports.

temper-core: 77 tests, 0 failures. 65 of 65 functional tests still pass.
