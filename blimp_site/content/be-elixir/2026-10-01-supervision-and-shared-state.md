# 2026-10-01: supervised actors, and one set of module values per node

Two questions were left from the actor chapter, and the answer to both was
yes. Can an actor outlive its creator and restart after a crash? Can
module-level state live in one place that every process sees?

## Module values, shared by the node

The first thing to settle was what "shared" means. A module `var` read and
written by two processes is a race: `count += 1` is a read and then a
write, two processes can both read 4 and both write 5, and Temper has no
locks. So sharing comes with rules:

- **Init runs once per node.** `init_once` used to keep its flag in the
  process dictionary. Now the flag lives in an ETS table, and the init runs
  under `:global.trans`, so a second process waits for the first to finish
  instead of starting its own.
- **Values that can be shared are shared.** A number, string, list, map,
  `@imu` struct or actor goes into ETS. Every process reads the same one
  and sees every write.
- **A mutable non-actor object is copied per process.** Its ref only means
  something in the heap of the process that made it. `Global.put` keeps
  the object in the writer's process dictionary and stores a snapshot
  (`Heap.export`) in ETS. Another process imports that snapshot the first
  time it reads the value, and its copy is its own from then on.
- **Shared mutable state that must stay consistent goes in an actor.** An
  actor created by a library's top level belongs to the node: `init_once`
  runs the top level inside `supervised/1`, so the actor does not end with
  whichever process ran the init.

```temper
@actor export class Ledger {
  public var entries: Int = 0;
  public record(): Int { entries += 1; entries }
}
export let ledger = new Ledger();
```

```
after 1000 concurrent deposits: 1000
the shared ledger saw: 1000
...
the ledger, seen from another process: 1002
```

The ETS table needs an owner that outlives every writer. So does the
registry that names actors, and so does the supervisor. temper-core is now
an OTP application, `TemperCore.Application`, which starts all three. Mix
starts it for any project that depends on a translated library, under
`mix run` and Phoenix alike.

## Supervision

An actor's identity used to be its pid, and a restarted process has a new
pid. So an actor is now `%TemperCore.Actor{class, id}`, with the id
registered in `TemperCore.Actors.Registry` to whichever process runs it.

Actors created inside `TemperCore.Actor.supervised(fn -> ... end)` start
under a `DynamicSupervisor` with `restart: :transient`, and are not tied to
their creator. A restart re-runs the constructor with the same arguments,
the same closure kept in the child spec. The result is fresh state under
the same identity, as OTP does it.

This needed a line drawn between an error and a crash:

- **A Temper bubble or panic is one call's result.** The caller raises it
  again, and the actor carries on.
- **Anything else crashes the actor.** That means an Elixir error, an exit
  or a throw. The actor replies with the error first, then stops with
  `{:crash, kind, reason}`, and the supervisor restarts it.

## The call that reached a dead process

The restart test failed. Restarting itself worked: a new process took
over within 20 ms. But the call made right after the crash got "actor has
ended". The registry was still naming the dead process: a `Registry`
entry is removed asynchronously, after its process exits. My first fix
retried only on `:noproc`. It still failed, because a call that reaches a
process while it is dying exits with the crash's own reason, not
`:noproc`.

What makes a retry safe is that the call never ran. An actor stops only
after replying to the call that crashed it, so a call that finds the
process dead or dying was never handled. Retrying cannot run it twice.
`run` now retries once on any exit, provided a different process has
taken over the identity; otherwise the actor has ended. The suite then
passed three runs in a row.

temper-core: 93 tests, 0 failures, five of them new: a supervised actor
outliving its creator, a crash restarting it, a Temper error not counting
as a crash, shared and copied module values, and an init that runs once
for twenty processes. 65 of 65 functional tests pass.
