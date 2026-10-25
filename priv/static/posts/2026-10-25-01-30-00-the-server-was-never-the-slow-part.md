tags: blimp,performance,programming,ai

# The server was never the slow part: a performance pass on this site, measured

This site answers a page in a third of a millisecond. I measured that on the box, from inside the Caddy container, straight at the Blimp process. Yet loading a page from my desk took 65 to 160 ms, and every 28 seconds the whole site stopped for 177 ms to collect garbage. Nobody noticed, because nothing was measuring it.

This post is the pass that went looking: what was slow, what changed in [Blimp](https://github.com/notactuallytreyanastasio/blimp) and in the site, what the reviews of those changes caught, and what is still not done. Claude wrote the code, in Claude Code, as two workflows of agents with an independent reviewer per change. Every number here comes from running the thing.

The work is nineteen pull requests: [Blimp #95 to #107](https://github.com/notactuallytreyanastasio/blimp/pulls?q=is%3Apr+is%3Amerged) and [blog #215 to #220](https://github.com/notactuallytreyanastasio/blog/pulls?q=is%3Apr+is%3Amerged). They went live at 01:19 UTC on October 25.

## Where the time went

I split each request into its hops before changing anything.

```text
hop                                             time
----------------------------------------------  -----------
the Blimp process, on the box                   0.3-0.8 ms
through Caddy and TLS, on the box               5 ms
my desk to the box, around Cloudflare           50 ms (15 ms of it the round trip)
my desk to the box, through Cloudflare          65-160 ms
```

The process was nowhere near the problem. Every hot page is prebuilt at boot as the exact bytes of an HTTP response, and serving one is a map lookup and a write. Cloudflare held none of it: HTML went out as `no-cache`, nothing carried an ETag, and the interpreter's `.wasm` and the `.blimp` programs aren't file types Cloudflare caches unless told to.

The 177 ms came from the interpreter's own report. Blimp has a control socket you can type into while the site runs, and `:stats` said this:

```text
ticks 3816010, errors 1, compactions 13554 (2406845ms), heap 177619542 bytes,
live after last compaction 111614540, actors 37 (48193 unreachable dropped), up 387310s
```

That is 13,554 stop-the-world copies of 111.6 MB of live data in four and a half days, 40 minutes of pause in all. A request that arrived during one waited in the kernel's accept queue, so the site's own request log, which times from accept to write, never saw it.

## Two things that weren't performance problems

Production was running a Blimp from October 2. The interpreter had gotten about 2.5 times faster since then (names hashed once by the parser, builtin calls cached at their call site, actors indexed by id), but none of it could ship. Twenty-eight commits existed only on my laptop: no branch, no pull request. Under them sat a build that had been broken since October 14. The server runs a static `x86_64-linux-musl` binary, and that cross-build stopped at

```text
src/native_ext.zig: cimport.h:1:10: error: 'sqlite3.h' not found
```

SQLite was vendored with its header on the library's include path, but `main.zig` imports the evaluator by file path, so the files that `@cInclude("sqlite3.h")` compile in the executable's own module. macOS ships its own `sqlite3.h`, which hid it. The fix is one line in `build.zig` ([#105](https://github.com/notactuallytreyanastasio/blimp/pull/105)). The 28 commits went up first as five chapters ([#95 to #99](https://github.com/notactuallytreyanastasio/blimp/pull/95)), with the claims in their messages re-measured where that was cheap. They held.

## The collector

A Blimp compaction copies everything reachable into a new heap and throws the old one away. Profiling one showed the copier remembering every value it had moved in a hash map keyed by address, so most of the pause was hashing and growing that map. [#100](https://github.com/notactuallytreyanastasio/blimp/pull/100) replaced it with a forwarding table laid beside the old heap, one slot per value-sized cell. It couldn't overwrite the old values in place, the textbook move, because a copy that runs out of memory leaves the evaluator on the old heap, which then has to be intact. Pauses on the local site under load went from 50 ms to 21 ms.

The bigger change was to stop copying the boot heap at all. Almost all of the 106 MB live set (every rendered post, the routes, the `/sky` data, bobbbyBot's archive of my IMs) is built at boot and never changes. [#101](https://github.com/notactuallytreyanastasio/blimp/pull/101) promotes whatever survives the first compaction after boot into an old space that later compactions leave where it is. The mutable things that can point from old into new (actor state, top-level bindings, the handle tables) are walked as roots every time, and there is a test that rebinds a binding and an actor's state after promotion, compacts, and reads them back.

```text
                          before    after
pause, mean               16-22 ms  0.42 ms
pause, worst (8 clients)            2.5 ms
compactions in 60 s       44-52     249
```

Pauses happen more often now because they're cheap. The budget dropped to a flat 16 MB of growth, once pause length stopped depending on how much is alive.

## Your browser was leaking too

Pages like [/temper-snake](/temper-snake) and [/aim](/aim) run a Blimp program in your browser on the WebAssembly build of the same interpreter. The server learned to drop unreachable actors back in September. The WASM build compacted after every call but kept every actor. Temper classes compile to actors, and the snake game makes one for every point on the board, so the page got slower the longer you played:

```text
snake, 100 restarts           actors    heap      frame
before                        869,507   104.1 MB  5.6 ms, growing to 126.9 ms
after (#102)                  19        0.4 MB    2.2 ms, staying at 2.1 ms
```

In Chrome, sixty seconds of key presses with a new game every second used to take a frame from 83 ms to 564 ms and memory from 20 MB to 101 MB. Now frames stay under 8 ms and memory sits at 6 MB.

## One thread, and the things that could hold it

The site is one Blimp process on one thread. Anything that waits holds every visitor, and three things could wait.

A slow reader. A response went out with a blocking write that gave up only after 10 seconds without progress. With one `curl --limit-rate 100k` on the 4.8 MB `/sky` data, a request for a 0.3 ms stylesheet took 30.7 seconds. [blog #217](https://github.com/notactuallytreyanastasio/blog/pull/217) parks a response the socket won't take and offers the rest when it drains. The same stylesheet now answers in 0.5 ms with that reader attached.

Postgres. The site's Postgres client was written in Blimp over a blocking socket with no timeout, so a slow query stopped the site, and a database that accepted a connection and never answered stopped it for good. [Blimp #104](https://github.com/notactuallytreyanastasio/blimp/pull/104) adds `pg_start` and `pg_result`, the wire protocol in Zig on worker threads with a deadline per query that cancels the statement on the server. With Postgres frozen under `SIGSTOP`, 29 of 29 homepage requests answered in under a millisecond ([blog #219](https://github.com/notactuallytreyanastasio/blog/pull/219)).

A flood of connections. The accept loop recursed until the queue was empty, so a burst could keep the tick from ever returning, and with it the collector. It now takes 64 a tick.

## The heap diet

With pauses cheap, the size of the heap still set memory use. bobbbyBot's archive, 75,344 posts of mine loaded as Blimp maps, was 70 of the 106 MB. It lives in SQLite now ([blog #218](https://github.com/notactuallytreyanastasio/blog/pull/218)), and the live heap after boot went from 97.6 MB to 32.3 MB. The bot's search answers in about the same time.

The homepage's runtime view also took a snapshot of every actor on every tick while anyone had the page open, before checking whether 250 ms had passed. Swapping those two lines, and stopping idle actors from building new state each tick, halved the compactions a minute.

## The browser and the edge

Posts, `/blog` and the other pages built from files now carry an ETag and answer `If-None-Match` with a 304 and no body ([blog #216](https://github.com/notactuallytreyanastasio/blog/pull/216)). The homepage used to differ per request only by its clock and three live counters spliced in by the server. home.js fills those in now, so the homepage is the same bytes for everyone and can be cached like the posts. The 78 icons inlined into it moved into one cached SVG sprite, and the HTML went from 99 KB to 57 KB. A request for a page that doesn't exist went from 78 µs to 8 µs, because it no longer walks a hundred routes before giving up.

## What the reviews caught

Every change had a second agent check it in its own worktree, with instructions to refute the claim and to default to "it does not hold." Three changes came back wrong.

The non-blocking writes could take the site down for good. A big file served as a constant was serialized again on every request, so each parked download kept its own 4.8 MB copy alive. A hundred and fifty readers at 20 KB/s used up the heap limit, the next tick failed at its first allocation, and so did every tick after it. The response is serialized once at boot now. Under the same 150 readers the live heap stays flat at 113 MB and a stylesheet still answers in 0.6 ms.

The same change made big files ten times slower for everyone else: the tick slept 10 ms before asking which sockets had room, so the 4.8 MB file went from 2 ms to 25.6 ms. Blimp could only wait on reads or on writes. [#107](https://github.com/notactuallytreyanastasio/blimp/pull/107) adds one call for both:

```blimp
got = tcp_poll_rw([listener | reading], parked, 100)
readable = elem(got, 0)
writable = elem(got, 1)
```

The file is back to 1.9 ms.

The third was preloading the interpreter. Telling the browser in `<head>` to fetch `blimp.wasm` and the page's program at once drew the program up to 170 ms sooner on a fast connection, which is what the change measured. On a slow one the 617 KB of WASM competed with the stylesheets and pushed first paint back by up to 1.6 seconds. I measured four versions on two emulated links:

```text
150 ms, 1.5 Mbps     first paint (ms)            program drawn (ms)
                     before  preload  neither    before  preload  neither
/who                  1860    2832     1880       5629    5141     5510
/temper-snake         1792    3388     1840       6593    6102     6463
```

Marking the preloads low priority changed nothing. What shipped is "neither": no preloads, with the page's loader asking for the program while the interpreter starts up instead of after. First paint is unchanged on every page and link, and the program draws 40 to 300 ms sooner.

The reviews also caught a thread leak in the Postgres workers. A query that timed out gave its slot back while its worker kept running to send the cancel, so a program retrying against a dead server reached 3,874 threads. Now it stops at 32. A pooled connection left inside a transaction was handed to the next query, which then failed with `25P02` until the connection fell out of the pool ([#106](https://github.com/notactuallytreyanastasio/blimp/pull/106)).

## After

```text
                                    before       after
boot, 16 posts rendered (box)       6,944 ms     1,810 ms
live heap after boot                111.6 MB     48 MB (46.8 MB of it old space)
collection pause                    177 ms       about 2 ms
a page, on the box                  0.3-0.8 ms   0.25-0.7 ms
```

## Not done

The edge half is waiting on me. Cloudflare needs a cache rule before it will hold HTML, and an API token so a deploy can purge it. Until those exist the HTML is still fetched from the box on every visit, and Cloudflare strips the ETags, which the box itself answers correctly. Unversioned stylesheets and scripts can now sit at the edge for a day after a deploy, with nothing to purge them.

A request that needs the database still waits for its query. The wait is capped at 5 seconds and the query is cancelled on the server, but removing it needs Blimp to be able to park a request in the middle of a handler, and it can't yet.

Five hundred and twelve readers slow enough to fill the connection table make new visitors queue in the kernel until one finishes, and boot takes about 85 ms longer because the archive goes into SQLite at startup instead of at build time.

On the night this shipped, the path from Cloudflare's Newark edge to the box was erratic: pages took 70 ms to 1.3 seconds, and `/arena`, which never touches Blimp, was as bad. Through Caddy on the box every request finished inside 6.5 ms.
