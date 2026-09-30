tags: blimp,temper,programming,ai

# This site is Blimp now: a Temper-to-Blimp case study, and how the port finished

*Updated September 30, 2026. When this went up on the 29th, "Blimp now" had a "mostly" after it. A day later nothing on bobbby.online is served by Phoenix: every page comes from one Blimp process, and the few Phoenix pages left live at old.bobbby.online. The first part below is the post as it was, a case study of moving the site's logic into Temper. The second part, "The rest of the port", is how the last forty routes got across and what the interpreter had to learn on the way.*

Every page on bobbby.online comes from one Blimp process, and a good share of that process's logic is written in Temper. The first half of this post is a technical account of the Temper part, written with the Temper team in mind: what the Blimp backend emits, what I had to change in it, what it costs at run time, and what Temper could not express for a real site.

[Blimp](https://github.com/notactuallytreyanastasio/blimp) is a language I have been building where actors are the only abstraction. [Temper](https://temperlang.dev/) compiles one library to many languages. The backend that makes Temper emit Blimp lives in [temper-blimp](https://github.com/notactuallytreyanastasio/temper-blimp), as a stacked series of pull requests; this post covers what [#113](https://github.com/notactuallytreyanastasio/temper-blimp/pull/113) added to it. The site side is pull requests [#41 through #134](https://github.com/notactuallytreyanastasio/blog/pulls?q=is%3Apr+is%3Amerged) in the blog repository, one chapter each.

There is a map of all of it at [/stack](/stack): every compiler, build step, file, process and service between the Temper source and your screen, as a Blimp page whose graph and layout are themselves Temper. Click a box to see what it comes from and what it feeds.

Claude wrote nearly all of the code, in Claude Code. Every number below was measured by running the thing, and most of them are copied out of commit messages.

## The short version

- Nine site modules are Temper now: the text helpers, the Markdown and syntax-highlighting helpers, the homepage desktop, the Moon Phish lunar math, phangraphs' statistics, and the rules of 2048, Wordle and Blackjack. That is 3,872 lines of literate Temper in `blimp_site/temper/src`.
- Their output is byte-identical to the Blimp it replaced, checked per module (the 15 published posts, 11 homepage states, 454 KB of Moon Phish JSON, 3,025 Wordle guesses against the original Elixir).
- The first measurement said Temper made the site 33% slower to boot. The cause was two costs in the Blimp interpreter that grew with the number of top-level names, and Temper's output has a lot of names. Fixing the interpreter made the whole site, Temper included, about ten times faster.
- The things Temper could not do for this site are specific, and listed near the end.

## Blimp, in the parts that matter here

A Blimp program is one file of `def`s, actors and top-level bindings. There are no modules and no imports: the site is every file in `blimp_site/src` concatenated, then `main.blimp`. There is one flat namespace, and when two top-level defs share a name, the later one wins without a warning.

Blimp has `case`, `for .. in`, closures and tail calls, and no loops, `break` or early `return`. Its strings are UTF-8 bytes, so `length`, `char_at` and `slice` count bytes. Its interpreter is a tree-walker in Zig, compiled natively for the server and to WebAssembly for the pages that run in your browser. During a run it frees nothing; only the REPL compacts. Lists are slices, so `append`, `++` and `[x | rest]` all copy.

The backend's main lowerings, from the temper-blimp README:

- A Temper class becomes an actor: fields become `state`, methods become message handlers, and a method call becomes a synchronous send.
- A `while` becomes a top-level tail-recursive `def` that carries the loop variables.
- An early `return` becomes a continuation `def` that the non-returning paths tail-call.
- `instanceof` becomes a message you send the actor.

The first of those decides most of what follows. A Blimp actor is never collected, so every Temper object is a small permanent allocation. The Temper snake game on this site shows it best: every point on the board is an object, so 810 actors exist after the first frame and about 500 more are added each frame, forever.

## How Temper got into the site's build

The site now has a Temper library at `blimp_site/temper/`, one directory per module. `temper build -b blimp` turns the whole library into one Blimp file, `_build/temper.blimp`, with temper-core (the backend's runtime, about 130 KB of Blimp) included once. Tonight that file is 8,829 lines and 749 defs.

No program gets all of it. `build.sh` builds each program with a helper:

```sh
with_temper() {
  local out="$1"; shift
  perl temper/prune.pl _build/temper.blimp "$@" > "$out.temper"
  cat "$out.temper" "$@" > "$out"
  rm -f "$out.temper"
}

with_temper _build/site.blimp src/*.blimp main.blimp
with_temper _build/wordle.blimp static/wordle/wordle.blimp
```

`prune.pl` is 77 lines of Perl. It starts from every identifier in the program's own files and pulls in each top-level item of `temper.blimp` that one of them names, repeating until nothing new is added. It can keep too much and never too little, because Blimp cannot call a function whose name it builds at run time. It also refuses a file that defines one name twice, which found a real bug (below).

What each program ends up with:

```text
program                       size    defs
----------------------------  ------  ----
the server (site.blimp)       346 KB  670
post-page renderer (browser)  143 KB  270
phangraphs (browser)          76 KB   135
Wordle (browser)              35 KB   51
2048 (browser)                29 KB   57
Moon Phish (browser)          24 KB   54
```

The server never runs Java. The build runs on my machine, and the deploy ships the finished `.blimp` files and a static Linux binary of the interpreter.

Temper exports keep their names, which is what made the swap cheap. A Temper `export let starts_with(...)` compiles to `def starts_with(...)`, so no Blimp call site had to change. Private functions get a numeric suffix (`wd_count__70`). With one namespace for everything, each module prefixes its exports (`md_`, `hl_`, `wd_`, `t48_`, `bj_`), and a module may not export a name Blimp's evaluator dispatches by name (`map`, `filter`, `reduce`, `each`, `join`, `index_of`, `replace`), because a def of that name would redirect every call in the program.

## What the output looks like

The Wordle checker is a good specimen. The Elixir it replaces does a green pass, then a yellow pass that deletes letters from a copy of the target it then throws away, so a yellow letter never uses a letter up: `speed` against `abide` shows two yellow e's. The site has always played that way, so the port keeps it, written as a count:

```temper
let wd_count(xs: List<String>, x: String, i: Int, n: Int): Int {
  if (i >= xs.length) { n } else if (xs[i] == x) { wd_count(xs, x, i + 1, n + 1) } else { wd_count(xs, x, i + 1, n) }
}

let wd_one(g: List<String>, t: List<String>, i: Int): String {
  let x = g[i];
  if (x == t[i]) {
    "correct"
  } else if (wd_count(t, x, 0, 0) > wd_greens_of(g, t, x, 0, 0)) {
    "present"
  } else {
    "absent"
  }
}
```

The backend emits this for `wd_count`:

```blimp
def wd_count__70(xs__102: Any, x__103: Any, i__104: Any, n__105: Any) -> Any do
  case i__104 >= temper_len(xs__102) do
    true -> n__105
    _ -> case temper_get(xs__102, i__104) == x__103 do
      true -> wd_count__70(xs__102, x__103, temper_int32(i__104 + 1), temper_int32(n__105 + 1))
      _ -> wd_count__70(xs__102, x__103, temper_int32(i__104 + 1), n__105)
    end
  end
end
```

That is close to what I would write by hand, with two differences that cost time. Every `+` on an `Int` is wrapped in `temper_int32`, because Temper's `Int` wraps at 32 bits and Blimp's is 64-bit and does not wrap. And list access goes through `temper_len` and `temper_get`, because a Temper list may be a builder.

A boolean expression used as a value costs more. Here is part of the hard-mode check, where Temper had `r[i] != "absent" && !wd_has(g, w[i], 0)`:

```blimp
_ -> t___191 = nil
blimp_branch_111 = case temper_get(r__129, i__130) != "absent" do
  true -> t___191 = !wd_has__73(g__127, temper_get(w__128, i__130), 0)
  [t___191]
  _ -> t___191 = false
  [t___191]
end
t___191 = elem(blimp_branch_111, 0)
```

A Blimp `case` branch cannot assign to a variable outside it, so the backend writes the temporary inside each branch, returns it in a one-element list, and reads it back with `elem`. `if` used as a value, `&&`, `||` and a `when` with several values per branch all lower this way, one list per comparison. The ports learned to prefer nested `if`s and small functions whose body is a single `if`, which lower to a plain `case`.

## What I changed in the backend, and why

The compiler changes are on one branch, [#113](https://github.com/notactuallytreyanastasio/temper-blimp/pull/113). Every one came from a failure or a measurement on the site.

### `split` lost a field between two separators

This was in the interpreter copy that the backend's tests run on: `split("a,,b", ",")` gave `["a", ",b"]`. The loop did `i += sep.len; continue` inside a `while (...) : (i += 1)`, and Zig runs the continue-expression on `continue`, so the byte after every match was skipped. Nothing in the test suite split on two separators in a row. A Markdown renderer does it on every blank line, and the port found it on its first post.

### `join`, `index_of` and `replace` came across from Blimp main

into that interpreter copy, so temper-core could use them.

### temper-core now searches, splits and joins with the interpreter's builtins

It had found substrings by comparing a slice at every byte, split by appending each piece with `acc ++ [piece]`, and joined by concatenating onto everything built so far. Each is quadratic, and escaping a 200 KB page (`&` to `&amp;` is a split and a join) paid all three. The blog had once defined exactly that byte-at-a-time search itself, and its boot went from 8 s to 23 s. The same commit moved `filter` and list slicing to builtins. Measured on Blimp main:

```
filter 20,001 items by appending      41 ms
filter 20,001 items with `filter`      3 ms
build 40,000 items by `[h | acc]`     out of heap at the 2 GB ceiling
```

### A regex with a group in it could not be parsed

temper-core had two defs called `temper_rx_group`, the parser's (2 arguments) and the matcher's (4). Blimp kept the later one, so every pattern containing `(` failed with `Handler :fn expects 4 argument(s), got 2`. None of the 65 functional tests has a group in a pattern. `prune.pl` found it by refusing a file with a name defined twice.

### Bytes that do not decode are U+FFFD now, not a crash

A Temper string is Unicode by construction; a Blimp caller hands translated Temper whatever bytes it has. The blog asks `is_digit(char_at(s, i))` of every character of a post, and for `é` that is the lead byte alone. `u8_decode_at` read the continuation bytes a lead byte promised whether they existed or not, and `rem(nil, 64)` stopped the program. An undecodable byte now decodes to U+FFFD and is one byte wide.

### A lambda that captures nothing is a top-level def, not a closure per call

Creating a closure in Blimp copied every binding in sight (more on that below), and a Temper lambda is created each time its enclosing function runs. With about 600 top-level names that was about 140 KB per closure:

```
def probe(s) do f = fn(x) do x end; f(s) end    x1000   149 MB
def probe(s) do s end                           x1000     7 MB
```

The blog's `replace_all` is `s.split(find).join(with) { (piece) => piece }`, and the homepage calls it 2,961 times. One homepage render went from 36 MB to 470 MB, and two test files ran out of heap. The backend now emits a nested function that is not in a class, and names only its own parameters, module top-level declarations and builtins, as `def blimp_fn_N`, and binds the local to that name. The check is an allowlist. Asking "is this name bound in an enclosing scope" gets two mutually recursive local functions wrong, because the second is not in scope yet when the first is translated.

### Fewer def calls and fewer top-level names

The async runner (about 20 scheduler names) is emitted only when `sleep` or `readLine` is used. `s.split("lit")` becomes Blimp's `split`, and `.join(sep) { (x) => x }` becomes Blimp's `join`. `s.slice(a, b)` becomes `slice(s, a, b - a)` when `a` is a name or a number. `s[i]` calls `u8_decode_at` directly, and `temper_string_next` got an ASCII fast path.

### Int64 division no longer wraps to 32 bits

`DivIntInt64` was lowered to `temper_int_div`, which ends in `temper_int32(a / b)`, so `5000000000i64 / 1i64` came back as 705032704. The agent porting phangraphs found it, because its batting average is `jamcharts * 10^9 / played` as an Int64 sort key. It now calls `temper_int64_div`, which keeps the zero-divisor bubble and does not wrap.

The branch also carries one commit from the stack below it: a Temper library with three modules wrote its test report three times into one file, so the harness read only the last module's results.

After all of it the functional suite passes 65 of 65 and temper-core's own tests 51 of 51.

## The slowdown was in Blimp

Each module's port produced identical output and ran a little slower. Together, on the interpreter the site was running:

```text
                  before Temper  all six ports
----------------  -------------  -------------
boot              5.6 s          7.5 s
render 15 posts   1.0 s          1.3 s
the site's tests  26.7 s         36.6 s
```

The Markdown port showed it worst. Moving about 50 helper functions to Temper made boot 33% slower (6.2 s to 8.3 s) with byte-identical output, and its agent measured each group by putting the old Blimp defs back one group at a time: bare-URL autolinks cost about 520 ms, href encoding 315 ms, link destinations 150 ms. It kept 8 functions in Temper and moved the rest back.

The desktop port measured the per-character cost directly. Its pixel-icon loop went from 138 ms to 638 ms in Temper, because each character step in Temper is three interpreter calls (`u8_decode_at` for `s[i]`, `temper_string_next` for `s.next(i)` and `temper_int32` for `n + 1`), where the Blimp was one `char_at`.

The highlighter's agent found the rest of the cause, in the interpreter. Blimp looked up every top-level name by walking a list from the end, and every closure copied every top-level binding. Both costs grow with the number of top-level names, and Temper's output adds hundreds. With 100 extra dummy defs and nothing calling them, rendering the posts went from 4.6 s to 5.3 s. So every call in the site got slower, whether or not it touched Temper.

[blimp#64](https://github.com/notactuallytreyanastasio/blimp/pull/64) fixed it. The top-level scope has a hash table from each name to its latest binding. A closure captures only its non-global variables and records how many top-level bindings existed when it was made, so it still sees each global as it was then. That was the part the obvious fix would have broken: `x = 1; f = fn() do x end; x = 2; f()` still returns 1. A synthetic file with 3,000 filler defs shows the scaling:

```
200k calls of a global def, 3000 fillers    1408 ms  ->  36 ms
2000 closure-free lambdas                    828 MB  ->  20 MB
```

And the site:

```text
                        before #64  after #64
----------------------  ----------  ---------
boot, all Temper ports  7.5 s       0.59 s
render 15 posts         1.3 s       0.37 s
the site's tests        36.6 s      3.4 s
boot in production      about 12 s  1.3 s
```

On the new interpreter the full Markdown port costs 20 ms of boot and 27 ms of rendering, so I put it back ([#75](https://github.com/notactuallytreyanastasio/blog/pull/75)). The commit history keeps the port, the retreat and the revert.

## Module by module

- text: moved all of `00_text`: trim, escape, starts_with and ends_with, take and drop. Stayed in Blimp: nothing.
- highlight: moved all 948 lines and 67 defs; the scanner became pairs of pure functions. Stayed in Blimp: nothing.
- markdown: moved escaping, href encoding, HTML tag recognition, the finders and autolinks. Stayed in Blimp: the block parser, the emphasis stack and anything that lower-cases.
- desktop: moved URL state, the clock and the fixed HTML of the window chrome. Stayed in Blimp: records (maps with atom keys) and the pixel icons.
- moon: moved the Meeus phase math with its 14 planetary terms, dates and formatting. Stayed in Blimp: atom-keyed maps, the cons-list sweep and the actors.
- phangraphs: moved sort keys, averages, date and tick math and URL encoding. Stayed in Blimp: the SQL, map filtering and the float chart geometry.
- 2048: moved slide, merge, moves, game over and tile classes. Stayed in Blimp: the actor, the view and tile placement, which needs `random`.
- Wordle: moved the checker, hard mode, word validity, messages and key colours. Stayed in Blimp: the actor, the view and the server store.
- Blackjack: moved the deck, the seeded shuffle, hand value, the dealer rule and payouts. Stayed in Blimp: the server table actor and the views.

The highlighter shows the biggest change in shape. The Blimp scanner returned a tuple `{sink, index}` from every mode. Temper has no tuples, and temper-core's `Pair`, `StringBuilder` and `ListBuilder` are classes, so actors, so never freed. Each mode became two pure functions, `*_end` returning a `StringIndex` and `*_html` returning a string, and an emitting loop carries its output string as a parameter.

## What Temper could not express for this site

These are the reasons code stayed in Blimp, as the agents recorded them.

1. Objects become permanent actors. With no collection for actors, any class used per request or per frame is a leak. Every module avoided classes, which also ruled out `Pair`, `StringBuilder` and `ListBuilder`. A backend that lowered a class with no identity-dependent behaviour to a plain value (a Blimp map or tuple) would remove most of the other items on this list.
2. No tuples. Functions that want to return two things had to be split in two.
3. No case mapping on String. Everything that lower-cases (HTML tag names in Markdown, search in Moon Phish, category labels on the desktop) stayed in Blimp.
4. No `random`. 2048's tile placement stayed in Blimp. Blackjack's shuffle takes a seed from Blimp as an argument.
5. Blimp's records are maps with atom keys, and a Temper `Map<String, _>` is not one. Everything that reads or builds a database row or a JSON record stayed in Blimp.
6. Per-character loops cost three calls a character, as the desktop numbers above show.
7. Values from control flow cost a list each: `if` as a value, `&&`, `||` and multi-value `when`.
8. Every Int operation calls `temper_int32`, which Blimp does not need.
9. An inline lambda argument does not translate. `apply({ (x) => !x }, b)` becomes `temper_untranslatable(...)`. The trailing-block form `apply(b) { (x) => !x }` and a named local function both work.
10. Mixing Int and Float across the boundary fails to compile. A Blimp caller passing `length(xs)` where Temper expects a `Float64` fails the checker inside `temper_float_gt`; the moon port passes `x * 1.0`. Temper's `/` on `Float64`, and on `Int64` by a non-literal, needs `throws Bubble`, which costs nothing on the Blimp side because nothing catches it.

## Bugs the ports turned up in the original site

Porting a page means reading every line of it.

Bookmarks never showed anyone a bookmark. The LiveView looked them up by a user id from the session, and nothing put one there, so every visit made up a new id and found nothing. The Blimp page starts empty too.

Blackjack counted a second ace as 11 whenever the first one fit, so 10, A, A scored 22 and busted, and the dealer busted the same way. A push between two naturals paid 0 chips while the page announced "Blackjack! You win 15 chips!". Each browser also kept its own copy of the table and broadcast it after every click, so two clicks at once overwrote each other. The Blimp version keeps each table in one server actor and fixes the scoring.

Wordle's yellow letters were the one bug kept on purpose, as described above.

## How the work was organised

A workflow of Claude agents did the Temper ports. One agent set up the library, the build and the text module. Six more ported one module each, at the same time, in separate git worktrees. A final agent re-ran all of their checks and tried to refute each claim; it refuted none, and caught one overclaim (2048's "120 random boards" was the same 40 boards three times, because the server's `random` is never seeded). The six coordinated on the decision graph's message board: the phangraphs agent posted the Int64 fix so nobody would make it twice, and the highlighter agent told the Markdown agent which build lines named its file.

## The rest of the port

What follows was merged on September 30: about sixty pull requests to the blog, and the Blimp changes they needed. As before, Claude wrote nearly all of it, agents worked in parallel worktrees, and the numbers are the ones the commits recorded.

### Phoenix is at old.bobbby.online

The last change was a Caddy edit ([#129](https://github.com/notactuallytreyanastasio/blog/pull/129)). Nothing in the bobbby.online site block proxies to Phoenix any more. Every path that used to fall through to it now answers with a redirect. Checked while writing this:

```text
$ curl -sI https://bobbby.online/blinks      HTTP/2 200   x-served-by: blimp
$ curl -sI https://bobbby.online/stack       HTTP/2 200   x-served-by: blimp
$ curl -sI https://bobbby.online/gif-maker   HTTP/2 308   location: https://old.bobbby.online/gif-maker
```

Phoenix still runs, as its own site with its own host name, so its LiveView sockets accept connections there. Keeping it running is also the rollback: put the old Caddyfile back and it serves everything again.

### What the interpreter had to learn

The first forty routes needed only an HTTP server and a template. The last forty talked to other machines, and to move them the interpreter had to learn how.

- **HTTPS out** ([blimp#60](https://github.com/notactuallytreyanastasio/blimp/pull/60)): `h = http_start(method, url, headers, body)` hands the request to a worker thread, and a tick polls `http_result(h)` until it is `{:ok, status, body}` or `{:error, reason}`. The program never blocks on the network. Timeouts and redirects came later ([#74](https://github.com/notactuallytreyanastasio/blimp/pull/74)), and so did the rule that nothing a remote server sends (a reset, a cut-off body, an http redirect from an https URL) can kill the process ([#76](https://github.com/notactuallytreyanastasio/blimp/pull/76)).
- **A WebSocket client** ([blimp#67](https://github.com/notactuallytreyanastasio/blimp/pull/67)) for the Bluesky firehose. Reading Jetstream at about 38 frames a second costs the server under 1% of a core ([#91](https://github.com/notactuallytreyanastasio/blog/pull/91)).
- **TLS 1.2 with ECDSA certificates** ([blimp#75](https://github.com/notactuallytreyanastasio/blimp/pull/75)). Before it, Blimp could not reach a TLS 1.2 server with an ECDSA certificate, which is what Craigslist runs. The camera sweep was waiting on it; with this change, Craigslist answers 200.
- **Web Push** ([blimp#71](https://github.com/notactuallytreyanastasio/blimp/pull/71)): RFC 8291's encryption, checked byte for byte against the RFC's own example, and ES256 signatures that node and openssl accept. The Blinks web app's notifications come from Blimp now.
- **Postgres**, as a client written in Blimp, so the museum, Blinks, Role Call and the rest read the same database Phoenix wrote.
- **POST, sessions and CSRF tokens** ([#100](https://github.com/notactuallytreyanastasio/blog/pull/100)), and rooms with presence ([#102](https://github.com/notactuallytreyanastasio/blog/pull/102)) for the pages where visitors see each other.

One bug is worth telling in full, because the obvious reading of it was wrong. The site hung in production with no error. The obvious suspect was a slow request. The actual cause was the live runtime socket that draws the canvas on every page. On Linux a socket returned by `accept()` does not inherit `O_NONBLOCK` from the listening socket, so every accepted connection was blocking. A browser tab that stopped reading its `/live/runtime` feed made the server's next write wait on it, and the server is one thread, so every other visitor waited too. The fix ([#124](https://github.com/notactuallytreyanastasio/blog/pull/124), [blimp#73](https://github.com/notactuallytreyanastasio/blimp/pull/73)) sets each accepted socket non-blocking and writes only what the peer will take.

### What moved

About sixty pages and endpoints, as chapters. Some run on the server; some are Blimp programs your browser runs in the WebAssembly build of the same interpreter. The rule for the canvas in the corner follows from that: a page that runs in your browser draws its own program, and a page the server renders draws the server.

- Games: 2048, Tetris, Chess-9, Wordle, Blackjack, Pong and Snake. Blackjack's tables are one server actor now, so two players finally share a game ([#79](https://github.com/notactuallytreyanastasio/blog/pull/79)).
- Live from the internet: the firehose pages, the cursor tracker, Tag a Wook's map and the MTA bus map. The bus map has one poller for every visitor instead of one per tab ([#93](https://github.com/notactuallytreyanastasio/blog/pull/93)).
- Data: phangraphs, Phish Lab's 20,000-point chart, the NYC census estimate (worked out in your browser, in Temper, to the same marker as Phoenix), Fill the Sky, Hacker News, Stumble and the camera browser.
- Tools and toys: the build map at [/stack](/stack), the Mirror, the Markdown editor, the Typewriter, Temper Art, the Ziggy account, Blinks, the receipt printer on my desk, and the collage maker. The collage maker's resizing moved from ImageMagick on the server to a canvas in your browser.

Porting a page means reading every line of it, so the second half found bugs too. Stumble picked a random link with `ORDER BY random()` over 2.3 million rows, 800 ms a click; it samples by primary key now ([#105](https://github.com/notactuallytreyanastasio/blog/pull/105)). Bus Time's v2 URL answers 404 when asked for `version=2`. And the Finder admin never checked its password ([#123](https://github.com/notactuallytreyanastasio/blog/pull/123)).

### What did not move, by name

- **/gif-maker** stays on Phoenix, and it does not work there either: YouTube blocks the downloader it runs.
- **Creating a blink and writing a comment** stay on Phoenix, because they send the push to my iPhone, and Apple's push service needs HTTP/2, which Blimp does not speak. Reading Blinks, saves, reactions and chat are all Blimp.
- **Python in Elixir and Smart Steps** were left where they are, by choice.
- **Four background jobs are ported and switched off**: the Craigslist camera sweep, the Bluesky link ingester behind Stumble, the dead-link check and the work log's GitHub poller. Phoenix's copies are still running, and two writers would double every row. Each Blimp copy writes exactly the rows Phoenix's does. Switching each one over is a config change on each side: Phoenix's copy off, Blimp's copy on.

### The homepage

The homepage was a classic Mac desktop, a port of the LiveView it replaced. It is now a page about me and the things I made, with the running server drawn live further down: 33 actors when I checked, one of them the `Site` actor that answered your request, on Blimp commit `0cffc08`. It went through three versions in one afternoon. The first led with the pages Blimp runs ([#130](https://github.com/notactuallytreyanastasio/blog/pull/130)), the second put the server's canvas at the top ([#132](https://github.com/notactuallytreyanastasio/blog/pull/132)), and the third put me first and the machine after the work ([#134](https://github.com/notactuallytreyanastasio/blog/pull/134)).

One trap from that afternoon: the redesign shipped, and visitors got the new markup with the old stylesheet. Cloudflare keeps `/assets/*` for four hours, and the file name had not changed. Stylesheets are now linked with a hash of their contents in the URL ([#131](https://github.com/notactuallytreyanastasio/blog/pull/131)), so a changed file has a new URL.

### What is left

On the Temper side, the next useful thing is still the first item in the list above: letting a value-like class compile to a value instead of an actor. Most of what stayed in Blimp stayed because of it.

On the site, Phoenix still does three things nothing else does: it sends pushes to my iPhone, which needs HTTP/2 in Blimp; it runs the four background jobs until they are switched over; and it hosts /gif-maker, Python in Elixir and Smart Steps. When those are settled, old.bobbby.online can go.
