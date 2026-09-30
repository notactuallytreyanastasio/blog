# The site, from source to screen

The diagram at `/stack`: every compiler, build step, file, process and
service between the source of bobbby.online and a reader's screen, as boxes
in nine columns with lines between them. The page's program
(`static/stack/stack.blimp`) is an actor with a view and nothing else. What
the diagram *is* lives here: the boxes and lines, the order of the boxes in
each column, where each one goes, the curve of each line, what a click on a
box lights up, what each trace and each search finds.

It was a d3 page first. d3 did three things for it: `d3.mean`, `d3.max` and
a sort for the ordering, `selection.data().join()` for the drawing, and
`d3.zoom` for pan and zoom. The first is a few functions below; the second is
Blimp's `el()`, SVG included; the third is a scroll box and three buttons.

Everything here is a function of values: lists, strings, ints. No classes,
because a Temper class on the Blimp backend is an actor, and actors are never
collected. The layout is computed once, when the program loads (the
top-level `let`s below), and a click asks only for the lineage of one box.

Every name starts `stk_`: the site has one flat namespace.

## Lists without a builder

A list only gets longer through `ListBuilder`, an actor here. So lengths come
from slicing one literal, as in `chess_lv`: `stk_range(n)` is `0 .. n-1`,
and a diagram of more than 512 boxes or lines panics rather than draws part
of itself.

    let stk_upto: List<Int> = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
      32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
      64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
      96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
      128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
      160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
      192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
      224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255,
      256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287,
      288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319,
      320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351,
      352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383,
      384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
      416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447,
      448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479,
      480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511,
    ];

    export let stk_range(n: Int): List<Int> {
      if (n < 0 || n > stk_upto.length) { panic() }
      stk_upto.slice(0, n)
    }

Two lists end to end, and a list of lists flattened, by picking from them.

    let stk_cat(a: List<Int>, b: List<Int>): List<Int> {
      let na = a.length;
      if (na == 0) {
        b
      } else if (b.isEmpty) {
        a
      } else {
        stk_range(na + b.length).map { (i): Int => if (i < na) { a[i] } else { b[i - na] } }
      }
    }

    let stk_flat_rows(gs: List<List<List<String>>>): List<List<String>> {
      let total = gs.reduceFrom(0) { (acc: Int, g: List<List<String>>): Int => acc + g.length };
      stk_range(total).map { (k): List<String> => stk_pick_row(gs, 0, k) }
    }

    let stk_pick_row(gs: List<List<List<String>>>, i: Int, k: Int): List<String> {
      let g = gs[i];
      if (k < g.length) { g[k] } else { stk_pick_row(gs, i + 1, k - g.length) }
    }

    let stk_flat_ints(gs: List<List<Int>>): List<Int> {
      let total = gs.reduceFrom(0) { (acc: Int, g: List<Int>): Int => acc + g.length };
      stk_range(total).map { (k): Int => stk_pick_int(gs, 0, k) }
    }

    let stk_pick_int(gs: List<List<Int>>, i: Int, k: Int): Int {
      let g = gs[i];
      if (k < g.length) { g[k] } else { stk_pick_int(gs, i + 1, k - g.length) }
    }

    let stk_has(xs: List<String>, x: String): Boolean {
      !xs.filter { (y): Boolean => y == x }.isEmpty
    }

## Kinds

What colour a box is. The order is the chips' order, and within a column
boxes of one kind sit together, in this order.

    let stk_kind_rows: List<List<String>> = [
      ["temper", "Temper source"],
      ["jvm", "JVM & Temper compiler"],
      ["zig", "Zig & the interpreter"],
      ["blimp", "Blimp server source"],
      ["browserprog", "Blimp browser program"],
      ["js", "JavaScript host code"],
      ["build", "Build & deploy step"],
      ["check", "Check"],
      ["artifact", "Built file"],
      ["server", "Production process"],
      ["browser", "In your browser"],
      ["data", "Data & outside service"],
      ["dev", "How it gets built"],
    ];

    export let stk_kinds(): List<List<String>> { stk_kind_rows }

    let stk_kind_rank(kind: String): Int { stk_kind_from(kind, 0) }

    let stk_kind_from(kind: String, i: Int): Int {
      if (i >= stk_kind_rows.length) {
        panic()
      } else if (stk_kind_rows[i][0] == kind) {
        i
      } else {
        stk_kind_from(kind, i + 1)
      }
    }

    export let stk_kind_name(kind: String): String { stk_kind_rows[stk_kind_rank(kind)][1] }

## The columns

Left to right is the direction things are made in.

    let stk_column_rows: List<List<String>> = [
      ["Temper source", "blimp_site/temper/src"],
      ["Compilers & toolchains", "JVM, Kotlin, Zig"],
      ["Blimp server source", "blimp_site/src + data"],
      ["Browser programs & host JS", "blimp_site/static"],
      ["Build, test & deploy", "build.sh, deploy.sh, zig build"],
      ["Built files", "_build/, binaries, image"],
      ["Production", "Hetzner, Caddy, one Blimp process"],
      ["In your browser", "WebAssembly Blimp"],
      ["Data, services, people", "Postgres, APIs, tooling"],
    ];

    export let stk_columns(): List<List<String>> { stk_column_rows }

## The boxes

One list per column. A box is `[id, kind, label, detail]`; a detail may
put `code` between backticks. Counts are as of main on 2026-09-29, after
blog #93 (lines from `wc -l`, tests from `./build.sh test`).

### Temper source

    let stk_col_temper: List<List<String>> = [
      ["t_config", "temper", "config.temper.md", "The library root. One Temper library, one directory per module; `temper build -b blimp` compiles all of them into a single Blimp file."],
      ["t_text", "temper", "text/text.temper.md", "189 lines. The site's string helpers: trim, take, drop, starts_with, ends_with, escape_html, is_digit, is_alnum. Replaced src/00_text.blimp with every export keeping its name and byte offsets, so no call site changed. The first module, used as the pilot."],
      ["t_markdown", "temper", "markdown/markdown.temper.md", "969 lines. Markdown's helpers: escaping, href percent-encoding, HTML tag and attribute recognition, the entity, backtick, bracket and link-destination finders, autolinks. The first port was byte-identical and 33% slower on the old interpreter; after blimp#64 it costs 20 ms of boot."],
      ["t_highlight", "temper", "highlight/highlight.temper.md", "1,137 lines. The whole syntax highlighter (was 948 lines of Blimp). Temper has no tuples and its Pair/StringBuilder are actors, so each scanner mode became two pure functions, *_end returning a StringIndex and *_html returning a string."],
      ["t_desktop", "temper", "desktop/desktop.temper.md", "153 lines. The homepage desktop's URL state, clock and the fixed HTML of its window chrome. Records (maps with atom keys) and the pixel icons stayed Blimp: the icon loop went 138 -> 638 ms in Temper."],
      ["t_moon", "temper", "moon/moon.temper.md", "301 lines. Meeus's lunar phase math with its 14 planetary terms, dates and formatting, for Moon Phish on the server and in the browser. JSON output byte-identical (454 KB)."],
      ["t_phish", "temper", "phish/phish.temper.md", "276 lines. phangraphs' sort keys (Int64), averages, dates, tick labels and URL encoding. Its port found that Int64 division wrapped to 32 bits (5000000000 / 1 gave 705032704)."],
      ["t_twenty48", "temper", "twenty48/twenty48.temper.md", "295 lines. 2048's rules: slide, merge, moves, game over, tile classes. Checked against the old Blimp on 160 distinct random boards."],
      ["t_wordle", "temper", "wordle/wordle.temper.md", "339 lines. The guess checker, hard mode, word validity, targets. 3,025 guesses checked against the Elixir, 0 differ."],
      ["t_blackjack", "temper", "blackjack/blackjack.temper.md", "213 lines. Deck, seeded shuffle, hand value, the dealer rule, outcomes and payouts, over card numbers 0-51. Fixes the Elixir's second-ace-as-11 bug."],
      ["t_cursor", "temper", "cursor_tracker/...temper.md", "123 lines. Colour from a visitor id, the countdown to the hourly clear, coordinate clamping, the inside-the-area test, log lines."],
      ["t_art", "temper", "art/art.temper.md", "403 lines. The generative art engine: seeded random numbers (the n-th depends only on seed and n, so no generator object), palettes, bauhaus/flow/subdivision, SVG output. Rewritten class-free from the JS-compiled original, which would have made ~6,700 permanent actors per flow picture."],
      ["t_chess", "temper", "chess_lv/chess_lv.temper.md", "1,816 lines. Chess-9: nine boards in a 3x3 grid that make one 24x24 plane. Setup, move generation, attack, check, legality, draws, scoring, evaluation and the bot's search, as functions over lists of Ints. The actor, the view and the bot's root loop stay Blimp."],
      ["t_map", "temper", "map/map.temper.md", "352 lines. Tag a Wook: which player a link embeds as, whether a tag may be saved (Blog.TagIn's changeset), the popup a pin opens. Shared by the server's room and the page's program."],
      ["t_nyc", "temper", "nyc_census/nyc_census.temper.md", "232 lines. The arithmetic of /nyc_census_and_pluto (Blog.Population.Geometry and Estimator): the lots inside a drawn shape, units to people by census tract, the numbers' formatting. Runs in the browser over rows the server passes through from Postgres."],
      ["t_firehose", "temper", "firehose/firehose.temper.md", "172 lines. What /reddit-links, /emoji-skeets and /jetstream_comparison compute rather than store: YouTube ids, matching, cutting. Shared by the server's Hose actors and the pages' programs. Lower-casing stays Blimp: Temper's String has no case mapping."],
      ["t_sky", "temper", "sky/sky.temper.md", "155 lines. Fill The Sky's layout: 418 communities as discs on a golden-angle spiral, each pushed outward until it overlaps nothing, and their colours. The All view is 1.1 million overlap tests, so it runs at build time, not in the browser."],
      ["t_mta", "temper", "mta/mta.temper.md", "307 lines. The MTA bus map's routes, the Bus Time request URL, route colours and marker HTML. Walking the decoded JSON stays Blimp: a Temper function takes strings and numbers, not a Blimp map."],
      ["t_stack", "temper", "stack/stack.temper.md", "This diagram: every box and line, the order of each column (six barycenter sweeps), positions, the curve of each line, lineage, traces and search, as functions over lists and strings. The layout runs once, when the page's program loads."],
      ["t_snake", "temper", "temper_snake (other repo)", "A snake game written in Temper, in its own repository. Every point is a class, so on Blimp every point is an actor that is never collected: 810 after the first frame, ~500 more per frame."],
    ];

### Compilers and toolchains

    let stk_col_tools: List<List<String>> = [
      ["jdk", "jvm", "OpenJDK 21", "Homebrew openjdk@21, pointed to with JAVA_HOME. The Temper compiler is Kotlin and runs on the JVM; nothing on the server needs Java."],
      ["gradle", "jvm", "Gradle :cli:installDist", "`./gradlew :cli:installDist` in temper-blimp/temper builds the temper CLI, including the be-blimp backend jar."],
      ["temper_fe", "jvm", "Temper frontend (Kotlin)", "temper-blimp/temper is a copy of temperlang/temper: parsing, type checking and lowering shared by every backend."],
      ["be_blimp", "jvm", "be-blimp backend", "Kotlin. Lowers Temper to Blimp: a class becomes an actor, a while becomes a tail-recursive def, an early return a continuation def. #113 added closure-free lambdas lifted to top-level defs, split/join peepholes, Int64 division without a 32-bit wrap."],
      ["temper_core", "jvm", "temper-core/core.blimp", "~130 KB of Blimp prepended to the compiled library: temper_int32 (Temper's Int wraps at 32 bits), UTF-8, strings, lists, regex, float printing. prune.pl keeps only what a program calls."],
      ["temper_cli", "jvm", "temper CLI", "temper-blimp-112/temper/cli/build/install/temper/bin/temper. `temper build -b blimp` -> temper.out/blimp/site/main.blimp."],
      ["tb_blimp", "zig", "temper-blimp's Blimp copy", "The interpreter the backend's own tests run on. #113 fixed its split and brought join, index_of and replace over from Blimp main."],
      ["zig", "zig", "Zig 0.16.0", "Compiles the Blimp interpreter three ways: native for local builds and tests, static x86_64-linux-musl for the server, and WebAssembly for browsers."],
      ["interp_src", "zig", "Blimp interpreter (Zig)", "blimp-for-blog/chunks/lang/src: eval.zig, builtins.zig, value.zig, gc.zig, wasm_api.zig, websocket.zig. A tree-walker. #64: the top level found by hash, site boot 6.2 s -> 0.54 s. #65: what blimp.wasm hands the page grows instead of being cut at 64 KiB. #66: a view with a carriage return mounts, and JSON that does not parse says where. #68: tcp_close drains the unread request instead of resetting the connection, and tcp_write's deadline is real time."],
      ["wss", "zig", "ws_open / ws_recv (blimp#67)", "A TLS WebSocket client in Blimp, the upgrade and the TLS both Zig's own, on a worker thread per connection. `ws_recv(ws)` hands over the frames that arrived since the last call. 38 frames/s from the Bluesky relay for five minutes, 15-29 MB under --serve."],
      ["host_js_src", "zig", "chunks/lang/web/*.js", "blimp.js (loads the WASM, eval/send/getState) and blimp-view.js (the view reconciler, SVG included). Copied byte-identical into static/blimp."],
      ["perl", "build", "perl", "Runs temper/prune.pl."],
      ["elixir", "check", "Elixir (reference)", "The Phoenix code the ports replace, run directly to compare outputs: Wordle 3,025 cases, Blackjack hand values and payouts."],
      ["chrome", "check", "Node + headless Chrome", "cdp.mjs drives Chrome over the DevTools protocol: load, click, type, evaluate, screenshot. Two-tab scripts check the multiplayer pages."],
    ];

### Blimp server source

    let stk_col_server: List<List<String>> = [
      ["s_main", "blimp", "main.blimp", "801 lines. The Site actor, the route table, dynamic() for everything not fixed, the WebSocket upgrade and frame loop, live_tick, push_runtime. At boot: render every post, open the DB, warm Moon Phish, open the Bluesky relay, give MTA its key."],
      ["s05", "blimp", "05_actors.blimp", "The Highlighter actor and friends; the markdown renderer asks it once per code block."],
      ["s10", "blimp", "10_markdown.blimp", "1,256 lines. The post renderer. Its HTML is byte-identical to the Phoenix/MDEx output on 11 of 15 posts. The same file runs in the browser."],
      ["s30", "blimp", "30_posts.blimp", "Loads the posts listed in data/posts.txt: titles, dates, tags, slugs, newest first."],
      ["s40", "blimp", "40_http.blimp", "HTTP request parsing, query_param, url_decode, response()."],
      ["s50", "blimp", "50_pages.blimp", "Page layout; adds the runtime window (the server drawn live) to every server-rendered page."],
      ["s60", "blimp", "60_desktop.blimp", "708 lines. The homepage desktop, its state in the query string; the museum and Finder windows read from Postgres."],
      ["s70", "blimp", "70_tetris.blimp", "The /tetris page."],
      ["s80", "blimp", "80_postgres.blimp", "424 lines. The Postgres wire protocol in Blimp, SCRAM-SHA-256 login included."],
      ["s85", "blimp", "85_db.blimp", "The DB actor: `DB <- :query(sql, params)` answers {:ok, rows} or {:error, reason}."],
      ["s90", "blimp", "90_live.blimp", "WebSocket framing, masking and upgrade; the /live rooms."],
      ["s93bj", "blimp", "93_blackjack.blimp", "505 lines. The BJ actor: every table, seats, turns, and what each player may see."],
      ["s93wd", "blimp", "93_wordle.blimp", "WordleStore: recent games, recoloured with the Temper checker so no browser-sent colour reaches another screen."],
      ["s94art", "blimp", "94_art.blimp", "The /art page title from ?seed= and ?generator=."],
      ["s94ct", "blimp", "94_cursor_tracker.blimp", "The CURSORS room actor: presence, cursors, up to 1,000 points."],
      ["s95", "blimp", "95_apps.blimp", "app_page(): the shell every browser-program page shares, this one included."],
      ["s96chess", "blimp", "96_chess_lv.blimp", "/chess-lv: the page, its program and its stylesheet, read once at boot. One game per visitor, as the LiveView had it."],
      ["s96dir", "blimp", "96_directory.blimp", "/directory, filled from live museum rows."],
      ["s96mir", "blimp", "96_mirror.blimp", "/mirror: the page shows the Blimp that renders it, cut from _build/site.blimp at run time."],
      ["s96sky", "blimp", "96_sky.blimp", "/sky: the page, its program, deck.gl, the layout and the 4.8 MB of points, all read at boot; and a clicked account's profile from Postgres."],
      ["s97map", "blimp", "97_map.blimp", "258 lines. /map, Tag a Wook: MAP_ROOM holds the pins, reads tag_ins from Postgres when a page connects over /live/map, saves a new one and sends it to every open page."],
      ["s97phish", "blimp", "97_phish.blimp", "phangraphs' SQL and JSON API."],
      ["s98fh", "blimp", "98_firehose.blimp", "512 lines. A Hose actor per relay (the Bluesky relay from boot, Jetstream only while /jetstream_comparison is open) and FIREHOSE, the room: it drains both every tick, keeps the fifty-video grid, and sends the search pages every post to filter themselves over /live/firehose."],
      ["s98moon", "blimp", "98_moon.blimp", "The MoonShows actor and moon_api."],
      ["s99hn", "blimp", "99_hacker_news.blimp", "The HN actor, stepped every tick; fetches over HTTPS with http_start / http_result so the server never blocks."],
      ["s99nyc", "blimp", "99_nyc_census.blimp", "/nyc_census_and_pluto: tracts.json (every tract once, kept) and lots.json?bbox=, written as JSON by Postgres itself (json_agg), so the one process does no per-row work."],
      ["s99mta", "blimp", "99_mta.blimp", "393 lines. /mta-bus-map: one poller, MTA, stepped by the Site's tick, asks Bus Time for the routes open pages watch (at most 16 requests at once, every 30 s) and sends each page its routes over /live/mta."],
      ["s99wl", "blimp", "99_work_log.blimp", "/work-log."],
      ["posts_md", "data", "priv/static/posts/*.md", "The posts, Markdown with a tags: line. Rendered at boot on the server, and again in your browser."],
      ["posts_txt", "data", "data/posts.txt", "Which posts are published, oldest first (16)."],
      ["tsv", "data", "data/*.tsv", "A snapshot of the museum and Finder, used when there is no database."],
      ["tag_ins", "data", "data/tag_ins.json", "Production's 60 /map pins on 2026-09-29, for a laptop or the tests, where there is no database."],
      ["sky_data", "data", "priv/static/data/sky_*.json", "Fill The Sky's input: 418 communities and 545,173 accounts' points (37.7 MB), as Phoenix served them."],
      ["pages_snap", "data", "content/pages/*.html", "Pages that never needed a server after the first byte, captured from Phoenix by content/snapshot.sh."],
      ["assets", "data", "assets/*.css", "Stylesheets, plus Phoenix's digested app css the ported pages reuse. This page's is assets/stack.css."],
    ];

### Browser programs and host JavaScript

    let stk_col_static: List<List<String>> = [
      ["p_post", "browserprog", "post/tail.blimp", "The Post actor that drives the server's own renderer in the browser."],
      ["p_editor", "browserprog", "editor/editor.blimp", "The Markdown editor, previewing with the posts' renderer."],
      ["p_pong", "browserprog", "pong/pong.blimp", "Pong. Reports its state to the server ten times a second for /pong/god."],
      ["p_pgod", "browserprog", "pong/god.blimp", "The Pong spectator page."],
      ["p_tetris", "browserprog", "tetris/tetris.blimp", "Tetris, 8 actors."],
      ["p_t48", "browserprog", "twenty48/twenty48.blimp", "2048's actor and view; its rules are Temper."],
      ["p_type", "browserprog", "typewriter/typewriter.blimp", "The typewriter."],
      ["p_phish", "browserprog", "phish/phish.blimp", "phangraphs' page: charts, cards, the player."],
      ["p_moon", "browserprog", "moon/moon.blimp", "Moon Phish's page."],
      ["p_hn", "browserprog", "hn/hn.blimp", "Top Hacker News stories."],
      ["p_book", "browserprog", "bookmarks/bookmarks.blimp", "Bookmarks, empty as it always was."],
      ["p_wordle", "browserprog", "wordle/wordle.blimp", "Your Wordle game; the checker is Temper."],
      ["p_wgod", "browserprog", "wordle/god.blimp", "/wordle_god."],
      ["p_bj", "browserprog", "blackjack/blackjack.blimp", "Draws what the BJ actor sends; sends back clicks."],
      ["p_cur", "browserprog", "cursors/cursors.blimp", "The cursor room's view."],
      ["p_art", "browserprog", "art/art.blimp", "The art studio: history, keys, full-screen view."],
      ["p_chess", "browserprog", "chess_lv/chess_lv.blimp", "Chess-9 against the bot, in your browser: 576 squares, one el() each."],
      ["p_map", "browserprog", "map/map.blimp", "Tag a Wook's form and list; Leaflet draws the map beside it."],
      ["p_nyc", "browserprog", "nyc_census/census.blimp", "Draw a shape, get how many people live in it: the estimate runs here, over the lots and tracts the server hands over."],
      ["p_fh", "browserprog", "firehose/*.blimp", "youtube.blimp, skeets.blimp and compare.blimp: the video grid, the search over every post as it arrives, and two relays side by side. Each filters in the page what the server sends it."],
      ["p_sky", "browserprog", "sky/sky.blimp", "Fill The Sky's sidebar: views, communities, the clicked account. deck.gl draws the points."],
      ["p_skybuild", "build", "sky/layout.blimp + build_*.blimp", "Blimp that runs at build time, not in a browser: build_layout.blimp runs the Temper layout for all three views into _build/sky_layout.json; build_points.blimp shrinks the points file to be gzipped."],
      ["p_mta", "browserprog", "mta/mta.blimp", "The bus map's route boxes and status; hands Leaflet its markers."],
      ["p_stack", "browserprog", "stack/stack.blimp", "This page: one actor whose view is this SVG and panel. A click sends it :pick(box); it asks the Temper for that box's lineage and draws again."],
      ["j_blimp", "js", "blimp/blimp.js", "Loads blimp.wasm; eval, send, getState."],
      ["j_view", "js", "blimp/blimp-view.js", "Reconciles el() trees into the DOM, SVG in its namespace; click, input, change, submit, swipe, key, timer, fetch, draw."],
      ["j_app", "js", "blimp/app.js", "The generic loader: fetch the program, mount it, feed the page canvas."],
      ["j_canvas", "js", "blimp/canvas.js", "BlimpCanvas: actors as shapes, messages as rays."],
      ["j_pcanvas", "js", "blimp/page-canvas.js", "The window that draws the page's own program; hides compiler-made names (...__N, temper_*)."],
      ["j_runtime", "js", "blimp/runtime.js", "The window that draws the server, fed over /live/runtime."],
      ["j_post", "js", "post/post.js + post-worker.js", "Renders the post again in a Worker with the server's renderer and compares the bytes with what the server sent."],
      ["j_loaders", "js", "play.js, god.js, live.js, ...", "Per-page WebSocket plumbing: Pong, Wordle, Blackjack, the cursor room, and firehose.js for the three firehose pages."],
      ["j_maps", "js", "map.js, mta.js + Leaflet", "What a program cannot be: Leaflet 1.x with marker clusters for /map, /nyc_census_and_pluto and /mta-bus-map, driven by the page's actor (`wook <- :clicked(json)`)."],
      ["j_deck", "js", "sky/sky.js + deck.gl 9.2.9", "deck.gl draws Fill The Sky's 545,173 points and the camera; which communities, where and in what colour is the program's to say."],
      ["j_wasm_src", "js", "blimp/blimp.wasm", "Committed build of the interpreter for browsers: 437 KB, Blimp 91f5978 (#66), with #64-#66."],
    ];

### Build, test and deploy

    let stk_col_build: List<List<String>> = [
      ["b_buildsh", "build", "build.sh", "Orchestrates: compile Temper if its sources or the CLI are newer, then build every program with with_temper; `./build.sh test` builds one file per test."],
      ["b_temper", "build", "temper build -b blimp", "One library, one output: temper-core once, then every module. Exports keep their names; privates get __N suffixes."],
      ["b_prune", "build", "temper/prune.pl", "77 lines of Perl. Follows names from a program's own files through _build/temper.blimp to a fixed point and keeps only those items."],
      ["b_with", "build", "with_temper OUT FILE...", "prune + cat: each program gets only the Temper it calls, in front of its own files."],
      ["b_skylayout", "build", "sky layout, at build time", "build.sh runs _build/sky-layout.blimp natively when it or the communities file changes (4.2 s for the All view), and gzips the points: 37.7 MB -> 4.8 MB."],
      ["b_test", "check", "./build.sh test", "29 test files, 238 tests, each file = sources + `# needs:` programs + the test. ~28 s with the Temper build, most of it the JVM."],
      ["b_ref", "check", "test/reference_diff.sh", "Renders the 15 reference posts and diffs them against the HTML Phoenix/MDEx served."],
      ["b_bench", "check", "bench.sh", "Times boot, rendering 15 posts, and the tests."],
      ["b_tbtests", "check", "be-blimp tests", "Temper's shared functional suite and temper-core's core_test, on temper-blimp's Blimp copy."],
      ["b_zignative", "build", "zig build interp", "Native (macOS arm64): the blimp that runs tests, benches, the sky layout and local servers."],
      ["b_ziglinux", "build", "zig build interp -Dtarget=x86_64-linux-musl", "A static Linux binary for the container, built inside deploy.sh stage."],
      ["b_zigwasm", "build", "zig build wasm", "The interpreter for browsers."],
      ["b_zigtest", "check", "zig build test", "641 interpreter tests (342 + 299), all passing at 896614f."],
      ["b_snakebuild", "build", "web/snake/build.sh", "In temper-blimp: temper build of the snake game plus its own blimp.wasm."],
      ["b_snapshot", "build", "content/snapshot.sh", "Captured static pages from the running Phoenix site, minus the LiveView script."],
      ["b_stage", "build", "deploy.sh stage", "Builds the Linux interpreter, runs the tests, and assembles _build/dist: the binary, BLIMP_COMMIT, the built .blimp files, assets, data, static, posts, images."],
      ["b_ship", "build", "deploy.sh ship", "rsync --delete to /opt/blimp-blog, then `docker compose up -d --build blimp-blog` on the box."],
      ["b_caddyedit", "build", "Caddyfile edits", "Each new page adds its paths to the @blimp matcher; @phoenix_live and @sky_points are their own handles. Back up, write in place, validate, reload, mirror into deploy/Caddyfile.snippet."],
    ];

### Built files

    let stk_col_built: List<List<String>> = [
      ["a_temper", "artifact", "_build/temper.blimp", "The whole compiled library: temper-core plus every module, ~535 KB."],
      ["a_site", "artifact", "_build/site.blimp", "The server program: pruned Temper + src/*.blimp + main.blimp, ~440 KB."],
      ["a_post", "artifact", "_build/post-renderer.blimp", "143 KB. The server's renderer, file for file, for the post page's Worker."],
      ["a_editor", "artifact", "_build/editor.blimp", "152 KB. The renderer plus the editor."],
      ["a_phish", "artifact", "_build/phish.blimp", "76 KB."],
      ["a_moon", "artifact", "_build/moon.blimp", "24 KB."],
      ["a_t48", "artifact", "_build/twenty48.blimp", "29 KB."],
      ["a_wordle", "artifact", "_build/wordle.blimp + god", "35 KB and 19 KB. The 14,855 allowed guesses ship separately as /wordle/words.txt."],
      ["a_cur", "artifact", "_build/cursors.blimp", "16 KB."],
      ["a_art", "artifact", "_build/art.blimp", "58 KB."],
      ["a_chess", "artifact", "_build/chess_lv.blimp", "113 KB, most of it the Temper rules and bot."],
      ["a_map", "artifact", "_build/map.blimp", "19 KB."],
      ["a_nyc", "artifact", "_build/nyc_census.blimp", "23 KB."],
      ["a_fh", "artifact", "_build/fh-*.blimp", "Three programs, 12, 15 and 16 KB."],
      ["a_sky", "artifact", "_build/sky.blimp + layout + points", "sky.blimp (9 KB), sky_layout.json (126 KB) and sky_points.json.gz (4.8 MB)."],
      ["a_mta", "artifact", "_build/mta.blimp", "33 KB."],
      ["a_stack", "artifact", "_build/stack.blimp", "147 KB: this page's program after the Temper it calls, most of it the boxes' text."],
      ["a_native", "artifact", "blimp (macOS arm64)", "blimp-for-blog/chunks/lang/zig-out/bin/blimp."],
      ["a_linux", "artifact", "bin/blimp (linux-musl)", "Static x86_64 binary plus BLIMP_COMMIT: 896614f, blimp#68."],
      ["a_snake", "artifact", "static/temper-snake/", "snake.blimp, harness.blimp and its own blimp.wasm, copied into every deploy."],
      ["a_dist", "artifact", "_build/dist/", "Exactly what the container needs; the layout matches the repo so ../priv/static/posts resolves in both."],
      ["a_image", "artifact", "image blog-blimp-blog", "FROM alpine; COPY bin, priv/static, blimp_site. CMD blimp --serve _build/site.blimp --tick \"site <- :tick\" --control site.sock."],
    ];

### Production

    let stk_col_prod: List<List<String>> = [
      ["cf", "server", "Cloudflare", "In front of the box; Caddy forwards CF-Connecting-IP to the apps."],
      ["hetzner", "server", "Hetzner 5.161.181.91", "One box, docker compose project /opt/blog: caddy, blimp-blog, app (Phoenix), db (postgres:17), deciduous-mcp, and others."],
      ["caddy", "server", "Caddy 2", "Named handles, in order: @phoenix_live, @sky_points, @blimp; everything else goes to app:4000. @blimp is retried for 20 s during a deploy, and a 404 from Blimp is re-sent to Phoenix."],
      ["c_phx_live", "server", "handle @phoenix_live", "/live/websocket and /live/longpoll straight to Phoenix. /live/* otherwise goes to Blimp, which answered LiveView's long-poll POST with 405."],
      ["c_sky_points", "server", "handle @sky_points", "/sky/points.json.gz with `response_buffers 16MB`: Caddy reads the 4.8 MB whole at loopback speed, so a slow reader cannot hold the one Blimp thread for up to 10 s."],
      ["c_blimp", "server", "blimp-blog (one process)", "The whole Blimp side of the site in one process: boots, renders every post, then ticks forever."],
      ["r_site", "server", "Site actor", "Accepts connections, answers HTTP from a route table built at boot plus dynamic(), and steps HN and MTA every tick."],
      ["r_hl", "server", "Highlighter actor", "Highlights each code block for the renderer."],
      ["r_db", "server", "DB actor", "Speaks Postgres; the museum, directory, phangraphs, Moon Phish, /map and the census queries go through it."],
      ["r_moon", "server", "MOON actor", "Moon Phish's shows against every full moon, warmed at boot."],
      ["r_hn", "server", "HN actor", "Steps every tick; polls its HTTPS requests on a worker thread."],
      ["r_bj", "server", "BJ actor", "Every Blackjack table."],
      ["r_wordle", "server", "WORDLE actor", "Recent Wordle games for the background and /wordle_god."],
      ["r_cur", "server", "CURSORS actor", "The cursor room; pushes the room at most every 50 ms, only when it changed."],
      ["r_map", "server", "MAP_ROOM actor", "The /map pins and who is looking at them."],
      ["r_fh", "server", "FIREHOSE + 2 Hose actors", "The Bluesky relay held from boot, Jetstream on demand; each tick the room drains both and pushes to the firehose pages at most every 250 ms."],
      ["r_mta", "server", "MTA actor", "One Bus Time poller for every open bus map, not one per visitor; with no page open it asks nothing."],
      ["r_live", "server", "/live/* sockets", "runtime, pong, pong-god, wordle, wordle-god, blackjack, cursors, map, firehose, mta."],
      ["r_control", "server", "control socket", "`blimp --attach site.sock`: a Blimp prompt inside the running site."],
      ["phoenix", "server", "Phoenix app (app:4000)", "Elixir/LiveView. Answers the routes Blimp does not serve yet, and every path Blimp 404s."],
      ["deciduous", "dev", "deciduous-mcp", "The decision graph server the agents log to and message through, on the same box."],
    ];

### In your browser

    let stk_col_browser: List<List<String>> = [
      ["br_html", "browser", "the HTML page", "Server-rendered by the Site actor, or a snapshot."],
      ["br_wasm", "browser", "Blimp in WebAssembly", "blimp.js instantiates blimp.wasm: the same interpreter as the server, compiled by Zig to wasm."],
      ["br_prog", "browser", "the page's program, running", "The fetched .blimp file, mounted by BlimpView: its actor answers :view with an el() tree."],
      ["br_view", "browser", "BlimpView DOM", "The rendered page, patched after every message. This diagram is one: an <svg> made with el()."],
      ["br_pcan", "browser", "page window", "Draws the page's own actors and messages."],
      ["br_rcan", "browser", "runtime window", "Draws the server's actors, live."],
      ["br_worker", "browser", "post Worker", "Re-renders the post and compares the bytes with what the server sent."],
      ["br_ws", "browser", "WebSocket client", "Game state, rooms, pins, buses, posts from the firehose, the runtime feed."],
      ["br_fetch", "browser", "fetch() JSON", "phangraphs, Moon Phish, Hacker News, the census rows, Fill The Sky's layout and points; Wordle's word list."],
      ["br_map", "browser", "Leaflet and deck.gl maps", "The maps a program cannot draw: pins, lots and buses on OpenStreetMap tiles, and 545,173 points on the GPU."],
      ["br_lv", "browser", "Phoenix LiveView JS", "On the pages Phoenix still serves."],
    ];

### Data, services and people

    let stk_col_outside: List<List<String>> = [
      ["pg", "data", "Postgres 17 (blog_prod)", "The museum, the directory, phangraphs' tracks, /map's tag_ins, New York's lots and census tracts, Phoenix's data."],
      ["hn_api", "data", "Hacker News API", "HTTPS, fetched by the HN actor."],
      ["bsky", "data", "Bluesky relays", "wss://bsky-relay.c.theo.io and Jetstream (jetstream2.us-east.bsky.network), read by the Hose actors with ws_open."],
      ["mta_api", "data", "MTA Bus Time", "vehicle-monitoring-v2.json, one request per route (5 KB, 0.1 s) rather than the whole city (1.27 MB, 7 s)."],
      ["osm", "data", "OpenStreetMap tiles", "tile.openstreetmap.org, under the three Leaflet maps."],
      ["github", "dev", "GitHub", "Stacked PRs: blog #41-#93 and this one, blimp #63-#68, temper-blimp #113."],
      ["claude", "dev", "Claude Code + agents", "Wrote nearly all of it; agents port pages in parallel and message each other through deciduous."],
      ["you", "dev", "you, reading this", "The last box in the chain."],
    ];

    let stk_groups: List<List<List<String>>> = [
      stk_col_temper, stk_col_tools, stk_col_server, stk_col_static, stk_col_build,
      stk_col_built, stk_col_prod, stk_col_browser, stk_col_outside,
    ];

    let stk_rows: List<List<String>> = stk_flat_rows(stk_groups);
    let stk_all: List<Int> = stk_range(stk_rows.length);
    let stk_col_of: List<Int> = stk_flat_ints(
      stk_range(stk_groups.length).map { (c): List<Int> => stk_groups[c].map { (r): Int => c } }
    );
    let stk_rank_of: List<Int> = stk_rows.map { (r): Int => stk_kind_rank(r[1]) };

    export let stk_count(): Int { stk_rows.length }
    export let stk_id(i: Int): String { stk_rows[i][0] }
    export let stk_kind(i: Int): String { stk_rows[i][1] }
    export let stk_label(i: Int): String { stk_rows[i][2] }
    export let stk_col(i: Int): Int { stk_col_of[i] }

The detail with its backticks as the places to switch between prose and
code: even pieces are prose, odd ones code.

    export let stk_detail_parts(i: Int): List<String> { stk_rows[i][3].split("`") }

A box is 210 pixels wide, about 28 characters of the label's monospace.

    export let stk_short(i: Int): String {
      let s = stk_rows[i][2];
      let cut = s.step(String.begin, 27);
      if (s.step(cut, 1) < s.end) { "${s.slice(String.begin, cut)}..." } else { s }
    }

Which box an id names, or -1.

    export let stk_find(id: String): Int { stk_find_from(id, 0) }

    let stk_find_from(id: String, i: Int): Int {
      if (i >= stk_rows.length) {
        -1
      } else if (stk_rows[i][0] == id) {
        i
      } else {
        stk_find_from(id, i + 1)
      }
    }

## The lines

A line is `[from, to, verb]`, or `[from, to, verb, "loop"]` for one that
runs against the flow on purpose (drawn dashed).

    let stk_line_groups: List<List<List<String>>> = [
      [
        ["t_config", "b_temper", "compiled by"], ["t_text", "b_temper", "compiled by"],
        ["t_markdown", "b_temper", "compiled by"], ["t_highlight", "b_temper", "compiled by"],
        ["t_desktop", "b_temper", "compiled by"], ["t_moon", "b_temper", "compiled by"],
        ["t_phish", "b_temper", "compiled by"], ["t_twenty48", "b_temper", "compiled by"],
        ["t_wordle", "b_temper", "compiled by"], ["t_blackjack", "b_temper", "compiled by"],
        ["t_cursor", "b_temper", "compiled by"], ["t_art", "b_temper", "compiled by"],
        ["t_chess", "b_temper", "compiled by"], ["t_map", "b_temper", "compiled by"],
        ["t_nyc", "b_temper", "compiled by"], ["t_firehose", "b_temper", "compiled by"],
        ["t_sky", "b_temper", "compiled by"], ["t_mta", "b_temper", "compiled by"],
        ["t_stack", "b_temper", "compiled by"],
      ],
      [
        ["t_markdown", "t_text", "imports"], ["t_highlight", "t_text", "imports"],
        ["t_desktop", "t_text", "imports"], ["t_nyc", "t_text", "imports"],
        ["jdk", "temper_cli", "runs"], ["gradle", "temper_cli", "builds"],
        ["temper_fe", "temper_cli", "part of"], ["be_blimp", "temper_cli", "part of"],
        ["temper_core", "be_blimp", "prepended by"],
        ["temper_cli", "b_temper", "runs"], ["b_temper", "a_temper", "writes"], ["b_buildsh", "b_temper", "calls"],
        ["a_temper", "b_prune", "read by"], ["perl", "b_prune", "runs"], ["b_prune", "b_with", "used by"],
        ["b_buildsh", "b_with", "calls"],
      ],
      [
        ["s_main", "b_with", "concatenated"], ["s05", "b_with", "concatenated"],
        ["s10", "b_with", "concatenated"], ["s30", "b_with", "concatenated"],
        ["s40", "b_with", "concatenated"], ["s50", "b_with", "concatenated"],
        ["s60", "b_with", "concatenated"], ["s70", "b_with", "concatenated"],
        ["s80", "b_with", "concatenated"], ["s85", "b_with", "concatenated"],
        ["s90", "b_with", "concatenated"], ["s93bj", "b_with", "concatenated"],
        ["s93wd", "b_with", "concatenated"], ["s94art", "b_with", "concatenated"],
        ["s94ct", "b_with", "concatenated"], ["s95", "b_with", "concatenated"],
        ["s96chess", "b_with", "concatenated"], ["s96dir", "b_with", "concatenated"],
        ["s96mir", "b_with", "concatenated"], ["s96sky", "b_with", "concatenated"],
        ["s97map", "b_with", "concatenated"], ["s97phish", "b_with", "concatenated"],
        ["s98fh", "b_with", "concatenated"], ["s98moon", "b_with", "concatenated"],
        ["s99hn", "b_with", "concatenated"], ["s99nyc", "b_with", "concatenated"],
        ["s99mta", "b_with", "concatenated"], ["s99wl", "b_with", "concatenated"],
      ],
      [
        ["b_with", "a_site", "writes"], ["b_with", "a_post", "writes"], ["b_with", "a_editor", "writes"],
        ["b_with", "a_phish", "writes"], ["b_with", "a_moon", "writes"], ["b_with", "a_t48", "writes"],
        ["b_with", "a_wordle", "writes"], ["b_with", "a_cur", "writes"], ["b_with", "a_art", "writes"],
        ["b_with", "a_chess", "writes"], ["b_with", "a_map", "writes"], ["b_with", "a_nyc", "writes"],
        ["b_with", "a_fh", "writes"], ["b_with", "a_sky", "writes"], ["b_with", "a_mta", "writes"],
        ["b_with", "a_stack", "writes"],
      ],
      [
        ["s10", "a_post", "same file, in the browser"], ["s10", "a_editor", "same file, in the browser"],
        ["s05", "a_post", "same file"], ["s97phish", "a_phish", "shared list logic"], ["s40", "a_art", "query_param"],
        ["p_post", "a_post", "appended"], ["p_editor", "a_editor", "appended"], ["p_phish", "a_phish", "appended"],
        ["p_moon", "a_moon", "appended"], ["p_t48", "a_t48", "appended"], ["p_wordle", "a_wordle", "appended"],
        ["p_wgod", "a_wordle", "appended"], ["p_cur", "a_cur", "appended"], ["p_art", "a_art", "appended"],
        ["p_chess", "a_chess", "appended"], ["p_map", "a_map", "appended"], ["p_nyc", "a_nyc", "appended"],
        ["p_fh", "a_fh", "appended"], ["p_sky", "a_sky", "appended"], ["p_mta", "a_mta", "appended"],
        ["p_stack", "a_stack", "appended"],
        ["b_with", "b_skylayout", "writes its program"], ["p_skybuild", "b_skylayout", "the program"],
        ["sky_data", "b_skylayout", "input"], ["a_native", "b_skylayout", "runs"],
        ["b_skylayout", "a_sky", "layout.json, points.json.gz"],
      ],
      [
        ["zig", "b_zignative", "compiles"], ["zig", "b_ziglinux", "compiles"], ["zig", "b_zigwasm", "compiles"],
        ["zig", "b_zigtest", "runs"],
        ["interp_src", "b_zignative", "source"], ["interp_src", "b_ziglinux", "source"],
        ["interp_src", "b_zigwasm", "source"], ["interp_src", "b_zigtest", "tested"],
        ["wss", "interp_src", "part of"],
        ["b_zignative", "a_native", "writes"], ["b_ziglinux", "a_linux", "writes"],
        ["b_zigwasm", "j_wasm_src", "committed as"],
        ["host_js_src", "j_blimp", "copied"], ["host_js_src", "j_view", "copied"],
        ["a_native", "b_test", "runs"], ["a_native", "b_ref", "runs"], ["a_native", "b_bench", "runs"],
        ["b_buildsh", "b_test", "calls"],
        ["s10", "b_ref", "checked"], ["posts_md", "b_ref", "input"], ["elixir", "b_test", "reference values"],
        ["chrome", "b_test", "browser checks"],
        ["tb_blimp", "b_tbtests", "runs"], ["be_blimp", "b_tbtests", "tested"], ["temper_core", "b_tbtests", "tested"],
        ["zig", "tb_blimp", "compiles"],
        ["t_snake", "b_snakebuild", "compiled by"], ["temper_cli", "b_snakebuild", "runs"],
        ["tb_blimp", "b_snakebuild", "wasm from"], ["b_snakebuild", "a_snake", "writes"],
      ],
      [
        ["b_ziglinux", "b_stage", "called by"], ["b_test", "b_stage", "gates"], ["a_linux", "b_stage", "packed"],
        ["a_snake", "b_stage", "packed"],
      ],
      [
        ["a_site", "b_stage", "packed"], ["a_post", "b_stage", "packed"], ["a_editor", "b_stage", "packed"],
        ["a_phish", "b_stage", "packed"], ["a_moon", "b_stage", "packed"], ["a_t48", "b_stage", "packed"],
        ["a_wordle", "b_stage", "packed"], ["a_cur", "b_stage", "packed"], ["a_art", "b_stage", "packed"],
        ["a_chess", "b_stage", "packed"], ["a_map", "b_stage", "packed"], ["a_nyc", "b_stage", "packed"],
        ["a_fh", "b_stage", "packed"], ["a_sky", "b_stage", "packed"], ["a_mta", "b_stage", "packed"],
        ["a_stack", "b_stage", "packed"],
      ],
      [
        ["posts_md", "b_stage", "packed"], ["posts_txt", "b_stage", "packed"], ["tsv", "b_stage", "packed"],
        ["tag_ins", "b_stage", "packed"], ["pages_snap", "b_stage", "packed"],
        ["assets", "b_stage", "packed"], ["j_wasm_src", "b_stage", "packed"],
        ["j_blimp", "b_stage", "packed"],
      ],
      [
        ["b_snapshot", "pages_snap", "writes"], ["phoenix", "b_snapshot", "captured from", "loop"],
        ["b_stage", "a_dist", "writes"], ["a_dist", "b_ship", "rsync"], ["b_ship", "a_image", "docker build"],
        ["a_image", "c_blimp", "runs as"], ["b_caddyedit", "caddy", "configures"],
      ],
      [
        ["cf", "caddy", "proxies to"], ["hetzner", "caddy", "hosts"], ["hetzner", "c_blimp", "hosts"],
        ["hetzner", "phoenix", "hosts"], ["hetzner", "deciduous", "hosts"],
        ["caddy", "c_phx_live", "first"], ["c_phx_live", "phoenix", "LiveView's socket"],
        ["caddy", "c_sky_points", "second"], ["c_sky_points", "c_blimp", "buffered"],
        ["caddy", "c_blimp", "@blimp paths"], ["caddy", "phoenix", "the rest + Blimp's 404s"],
        ["c_blimp", "r_site", "spawns"], ["c_blimp", "r_control", "listens"],
        ["r_site", "r_hl", "asks"], ["r_site", "r_db", "asks"], ["r_site", "r_moon", "asks"],
        ["r_site", "r_hn", "steps"], ["r_site", "r_mta", "steps"], ["r_site", "r_fh", "ticks"],
        ["r_site", "r_live", "upgrades"],
        ["r_live", "r_bj", "frames"], ["r_live", "r_wordle", "frames"], ["r_live", "r_cur", "frames"],
        ["r_live", "r_map", "frames"], ["r_live", "r_fh", "sockets"], ["r_live", "r_mta", "frames"],
        ["r_map", "r_db", "tag_ins"],
        ["s85", "r_db", "defines"], ["s80", "r_db", "protocol"], ["s99hn", "r_hn", "defines"],
        ["s93bj", "r_bj", "defines"], ["s93wd", "r_wordle", "defines"], ["s94ct", "r_cur", "defines"],
        ["s98moon", "r_moon", "defines"], ["s05", "r_hl", "defines"], ["s_main", "r_site", "defines"],
        ["s97map", "r_map", "defines"], ["s98fh", "r_fh", "defines"], ["s99mta", "r_mta", "defines"],
        ["s90", "r_live", "framing"], ["s99nyc", "r_db", "json_agg queries"],
        ["wss", "r_fh", "ws_open, ws_recv"],
        ["r_db", "pg", "wire protocol, SCRAM"], ["phoenix", "pg", "Ecto"], ["r_hn", "hn_api", "HTTPS"],
        ["r_fh", "bsky", "wss"], ["r_mta", "mta_api", "HTTPS, per route"],
        ["tsv", "r_site", "fallback"], ["tag_ins", "r_map", "offline snapshot"],
      ],
      [
        ["r_site", "br_html", "HTTP"], ["phoenix", "br_lv", "HTTP + LiveView"], ["br_html", "br_wasm", "loads"],
        ["j_blimp", "br_wasm", "hosts"], ["j_wasm_src", "br_wasm", "instantiated"],
        ["a_post", "br_worker", "fetched"], ["j_post", "br_worker", "starts"],
      ],
      [
        ["a_editor", "br_prog", "fetched"], ["a_phish", "br_prog", "fetched"],
        ["a_moon", "br_prog", "fetched"], ["a_t48", "br_prog", "fetched"],
        ["a_wordle", "br_prog", "fetched"], ["a_cur", "br_prog", "fetched"], ["a_art", "br_prog", "fetched"],
        ["a_chess", "br_prog", "fetched"], ["a_map", "br_prog", "fetched"], ["a_nyc", "br_prog", "fetched"],
        ["a_fh", "br_prog", "fetched"], ["a_sky", "br_prog", "fetched"], ["a_mta", "br_prog", "fetched"],
        ["a_stack", "br_prog", "fetched"],
      ],
      [
        ["p_pong", "br_prog", "fetched as-is"], ["p_pgod", "br_prog", "fetched as-is"],
        ["p_tetris", "br_prog", "fetched as-is"], ["p_type", "br_prog", "fetched as-is"],
        ["p_hn", "br_prog", "fetched as-is"], ["p_book", "br_prog", "fetched as-is"],
        ["p_bj", "br_prog", "fetched as-is"],
      ],
      [
        ["j_app", "br_prog", "mounts"], ["br_wasm", "br_prog", "runs"], ["j_view", "br_view", "renders"],
        ["br_prog", "br_view", "el() tree"],
        ["j_pcanvas", "br_pcan", "draws"], ["j_canvas", "br_pcan", "library"], ["j_canvas", "br_rcan", "library"],
        ["br_prog", "br_pcan", "getState()"], ["j_runtime", "br_rcan", "draws"], ["r_live", "br_rcan", "/live/runtime"],
        ["j_loaders", "br_ws", "opens"], ["r_live", "br_ws", "frames"], ["br_ws", "br_prog", "messages"],
        ["r_site", "br_fetch", "JSON"], ["br_fetch", "br_prog", "messages"],
        ["c_sky_points", "br_fetch", "points.json.gz"],
        ["j_maps", "br_map", "draws"], ["j_deck", "br_map", "draws"], ["br_prog", "br_map", "markers, discs"],
        ["osm", "br_map", "tiles", "loop"],
        ["br_view", "you", "pixels"], ["br_rcan", "you", "pixels"], ["br_lv", "you", "pixels"],
        ["br_map", "you", "pixels"], ["br_pcan", "you", "pixels"],
        ["a_site", "s96mir", "reads its own source", "loop"], ["br_worker", "br_html", "compares bytes with", "loop"],
        ["claude", "github", "opens PRs"], ["claude", "deciduous", "logs & messages", "loop"],
        ["github", "b_ship", "merged main", "loop"],
      ],
    ];

    let stk_lines: List<List<String>> = stk_flat_rows(stk_line_groups);
    let stk_edges: List<Int> = stk_range(stk_lines.length);
    let stk_from: List<Int> = stk_lines.map { (l): Int => stk_find(l[0]) };
    let stk_to: List<Int> = stk_lines.map { (l): Int => stk_find(l[1]) };

    export let stk_edge_count(): Int { stk_lines.length }
    export let stk_edge_from(e: Int): Int { stk_from[e] }
    export let stk_edge_to(e: Int): Int { stk_to[e] }
    export let stk_edge_verb(e: Int): String { stk_lines[e][2] }

Every id a line or a trace names that is not a box. The program refuses to
start unless this is empty, and says which.

    export let stk_unknown(): List<String> {
      let named = stk_lines.map { (l): String => l[0] }.filter { (id): Boolean => stk_find(id) < 0 };
      let named2 = stk_lines.map { (l): String => l[1] }.filter { (id): Boolean => stk_find(id) < 0 };
      let traced = stk_trace_rows.map { (t): String => stk_unknown_in(t) }.filter { (s): Boolean => !s.isEmpty };
      let all = [named.join(" ") { (s): String => s }, named2.join(" ") { (s): String => s }, traced.join(" ") { (s): String => s }];
      all.filter { (s): Boolean => !s.isEmpty }
    }

    let stk_unknown_in(t: List<String>): String {
      t.slice(1, t.length).filter { (id): Boolean => stk_find(id) < 0 }.join(" ") { (s): String => s }
    }

The lines into and out of each box, as line numbers.

    let stk_ins: List<List<Int>> = stk_all.map { (n): List<Int> => stk_edges.filter { (e): Boolean => stk_to[e] == n } };
    let stk_outs: List<List<Int>> = stk_all.map { (n): List<Int> => stk_edges.filter { (e): Boolean => stk_from[e] == n } };

    export let stk_in_edges(n: Int): List<Int> { stk_ins[n] }
    export let stk_out_edges(n: Int): List<Int> { stk_outs[n] }

## Ordering the columns

Lines cross less when every box sits near the boxes it is joined to. The d3
page did what a layered-graph layout does first, a barycenter sweep: in
each column, give every box the mean height (as a fraction of its own
column) of its neighbours in other columns, scaled to this column, and sort
by it, keeping each kind together. Six sweeps over the nine columns, each
column seeing the order the ones before it just got.

A row is a box's place in its column, from 0. `stk_row0` is the order the
boxes are written in above.

    let stk_members: List<List<Int>> = stk_range(stk_groups.length).map { (c): List<Int> =>
      stk_all.filter { (i): Boolean => stk_col_of[i] == c }
    };

    let stk_place: List<Int> = stk_all.map { (i): Int => stk_index_in(stk_members[stk_col_of[i]], i, 0) };

    let stk_index_in(xs: List<Int>, x: Int, k: Int): Int {
      if (k >= xs.length) { -1 } else if (xs[k] == x) { k } else { stk_index_in(xs, x, k + 1) }
    }

    let stk_row0: List<Int> = stk_place;

Each box's neighbours, once per line, so two lines to one box pull twice.

    let stk_nbrs: List<List<Int>> = stk_all.map { (n): List<Int> =>
      stk_cat(stk_ins[n].map { (e): Int => stk_from[e] }, stk_outs[n].map { (e): Int => stk_to[e] })
    };

    let stk_bary(rows: List<Int>, n: Int, c: Int): Float64 {
      let nb = stk_nbrs[n].filter { (m): Boolean => stk_col_of[m] != c };
      if (nb.isEmpty) {
        rows[n].toFloat64()
      } else {
        let sum = nb.reduceFrom(0.0) { (acc: Float64, m: Int): Float64 =>
          acc + ((rows[m].toFloat64() / stk_at_least_one(stk_members[stk_col_of[m]].length).toFloat64()) orelse 0.0)
        };
        ((sum / nb.length.toFloat64()) orelse 0.0) * stk_members[c].length.toFloat64()
      }
    }

    let stk_at_least_one(n: Int): Int { if (n < 1) { 1 } else { n } }

No sort: a box's new row is how many boxes of its column come before it --
an earlier kind, or the same kind and a smaller barycenter, or both the same
and a smaller row now (JavaScript's sort is stable, so ties kept their
order). Rows in a column are always a permutation of `0 .. n-1`.

    let stk_sweep_col(rows: List<Int>, c: Int): List<Int> {
      let ms = stk_members[c];
      let bs = ms.map { (n): Float64 => stk_bary(rows, n, c) };
      let at = stk_range(ms.length);
      let ranks = at.map { (a): Int => at.filter { (b): Boolean => stk_before(ms, bs, rows, b, a) }.length };
      stk_all.map { (i): Int => if (stk_col_of[i] == c) { ranks[stk_place[i]] } else { rows[i] } }
    }

    let stk_before(ms: List<Int>, bs: List<Float64>, rows: List<Int>, b: Int, a: Int): Boolean {
      let kb = stk_rank_of[ms[b]];
      let ka = stk_rank_of[ms[a]];
      if (kb != ka) {
        kb < ka
      } else if (bs[b] != bs[a]) {
        bs[b] < bs[a]
      } else {
        rows[ms[b]] < rows[ms[a]]
      }
    }

    let stk_sweeps(rows: List<Int>, pass: Int, c: Int): List<Int> {
      if (pass >= 6) {
        rows
      } else if (c >= stk_members.length) {
        stk_sweeps(rows, pass + 1, 0)
      } else {
        stk_sweeps(stk_sweep_col(rows, c), pass, c + 1)
      }
    }

    let stk_row: List<Int> = stk_sweeps(stk_row0, 0, 0);

    export let stk_row_of(i: Int): Int { stk_row[i] }

## Where things go

Columns 250 wide, boxes 210 by 20 on rows 27 apart, each column centred
on the tallest.

    let stk_colw = 250;
    export let stk_boxw(): Int { 210 }
    let stk_rowh = 27;
    let stk_top = 70;

    let stk_tallest: Int = stk_members.reduceFrom(0) { (acc: Int, m: List<Int>): Int => if (m.length > acc) { m.length } else { acc } };

    export let stk_width(): Int { 20 + stk_members.length * stk_colw }
    export let stk_height(): Int { stk_top + stk_tallest * stk_rowh + 40 }
    export let stk_column_x(c: Int): Int { 20 + c * stk_colw }

    let stk_xs: List<Int> = stk_all.map { (i): Int => 20 + stk_col_of[i] * stk_colw };
    let stk_ys: List<Int> = stk_all.map { (i): Int =>
      let left = stk_tallest - stk_members[stk_col_of[i]].length;
      stk_top + ((left * stk_rowh / 2) orelse 0) + stk_row[i] * stk_rowh
    };

    export let stk_x(i: Int): Int { stk_xs[i] }
    export let stk_y(i: Int): Int { stk_ys[i] }

## The curves

A line going right leaves a box's right edge and enters the next one's left,
as a cubic whose control points sit halfway across. Between two boxes of
one column it bows out to the right, further the further apart they are.
A line going left (the loops) drops under everything and comes back.

    let stk_paths: List<String> = stk_edges.map { (e): String => stk_path(stk_from[e], stk_to[e]) };

    let stk_path(s: Int, t: Int): String {
      let w = stk_boxw();
      let y1 = stk_ys[s] + 10;
      let y2 = stk_ys[t] + 10;
      if (stk_col_of[t] > stk_col_of[s]) {
        let x1 = stk_xs[s] + w;
        let x2 = stk_xs[t];
        let m = (x1 + x2) / 2 orelse 0;
        "M${x1},${y1} C${m},${y1} ${m},${y2} ${x2},${y2}"
      } else if (stk_col_of[t] == stk_col_of[s]) {
        let x = stk_xs[s] + w;
        let d = if (y2 > y1) { y2 - y1 } else { y1 - y2 };
        let bow = x + 30 + ((d * 3 / 20) orelse 0);
        "M${x},${y1} C${bow},${y1} ${bow},${y2} ${x},${y2}"
      } else {
        let x1 = stk_xs[s];
        let x2 = stk_xs[t] + w;
        let dip = stk_height() - 12;
        let mid = (x1 + x2) / 2 orelse 0;
        "M${x1},${y1} C${x1 - 60},${y1} ${x1 - 60},${dip} ${mid},${dip} S${x2 + 60},${y2} ${x2},${y2}"
      }
    }

    export let stk_edge_path(e: Int): String { stk_paths[e] }

Dashed: a line marked a loop, or one that runs right to left.

    export let stk_edge_dashed(e: Int): Boolean {
      stk_lines[e].length > 3 || stk_col_of[stk_to[e]] < stk_col_of[stk_from[e]]
    }

A line's verb is written halfway along it, only for lines going right.

    export let stk_edge_forward(e: Int): Boolean { stk_col_of[stk_to[e]] > stk_col_of[stk_from[e]] }
    export let stk_edge_label_x(e: Int): Int { (stk_xs[stk_from[e]] + stk_boxw() + stk_xs[stk_to[e]]) / 2 orelse 0 }
    export let stk_edge_label_y(e: Int): Int { (stk_ys[stk_from[e]] + stk_ys[stk_to[e]]) / 2 + 6 orelse 0 }

## Lineage

What a click on a box lights: everything upstream that goes into making it,
everything downstream it reaches, and the lines between. The d3 page walked
this with a stack and a Set of objects; here a set of boxes is a list of
booleans, one per box, grown to a fixed point: a box joins the upstream set
when one of its lines goes into a box already in it.

    let stk_upstream(marks: List<Boolean>): List<Boolean> {
      let next = stk_all.map { (i): Boolean =>
        marks[i] || !stk_outs[i].filter { (e): Boolean => marks[stk_to[e]] }.isEmpty
      };
      if (stk_trues(next) == stk_trues(marks)) { next } else { stk_upstream(next) }
    }

    let stk_downstream(marks: List<Boolean>): List<Boolean> {
      let next = stk_all.map { (i): Boolean =>
        marks[i] || !stk_ins[i].filter { (e): Boolean => marks[stk_from[e]] }.isEmpty
      };
      if (stk_trues(next) == stk_trues(marks)) { next } else { stk_downstream(next) }
    }

    let stk_trues(marks: List<Boolean>): Int {
      marks.reduceFrom(0) { (acc: Int, m: Boolean): Int => if (m) { acc + 1 } else { acc } }
    }

`[boxes lit, lines lit]`. A line is lit when it goes into the upstream set
or comes out of the downstream set: every way in, every way out.

    export let stk_lineage(n: Int): List<List<Boolean>> {
      let only = stk_all.map { (i): Boolean => i == n };
      let up = stk_upstream(only);
      let down = stk_downstream(only);
      [
        stk_all.map { (i): Boolean => up[i] || down[i] },
        stk_edges.map { (e): Boolean => up[stk_to[e]] || down[stk_from[e]] },
      ]
    }

## Traces

A named path through the diagram: its boxes, and every line between two of
them. The first string is the name.

    let stk_trace_rows: List<List<String>> = [
      ["A post, Markdown to screen", "posts_md", "posts_txt", "s30", "s10", "s05", "t_markdown", "t_highlight", "t_text", "b_temper", "temper_cli", "a_temper", "b_prune", "b_with", "a_site", "b_stage", "a_dist", "b_ship", "a_image", "c_blimp", "r_site", "r_hl", "caddy", "cf", "br_html", "j_post", "br_worker", "a_post", "j_blimp", "j_wasm_src", "br_wasm", "you"],
      ["Wordle, checker to both ends", "t_wordle", "b_temper", "a_temper", "b_prune", "b_with", "a_wordle", "p_wordle", "s93wd", "a_site", "r_wordle", "r_live", "r_site", "c_blimp", "br_ws", "br_prog", "br_wasm", "br_view", "j_loaders", "elixir", "b_test"],
      ["The Bluesky firehose", "bsky", "wss", "interp_src", "r_fh", "s98fh", "t_firehose", "b_temper", "b_with", "a_fh", "p_fh", "a_site", "r_live", "r_site", "c_blimp", "br_ws", "j_loaders", "br_fetch", "br_prog", "br_view", "you"],
      ["Fill The Sky, laid out at build time", "sky_data", "t_sky", "b_temper", "a_temper", "b_prune", "b_with", "p_skybuild", "b_skylayout", "a_native", "a_sky", "p_sky", "s96sky", "b_stage", "c_blimp", "caddy", "c_sky_points", "br_fetch", "br_prog", "j_deck", "br_map", "you"],
      ["The interpreter, three builds", "zig", "interp_src", "wss", "b_zignative", "b_ziglinux", "b_zigwasm", "b_zigtest", "a_native", "a_linux", "j_wasm_src", "b_stage", "a_dist", "b_ship", "a_image", "c_blimp", "br_wasm", "b_test"],
      ["The Temper compiler", "jdk", "gradle", "temper_fe", "be_blimp", "temper_core", "temper_cli", "b_temper", "a_temper", "tb_blimp", "b_tbtests", "zig"],
      ["Postgres to the page", "pg", "r_db", "s85", "s80", "s60", "s96dir", "s97phish", "s97map", "r_map", "s99nyc", "r_site", "c_blimp", "br_html", "br_fetch", "tsv", "tag_ins"],
      ["This page", "t_stack", "b_temper", "a_temper", "b_prune", "b_with", "p_stack", "a_stack", "s95", "a_site", "b_stage", "c_blimp", "r_site", "br_html", "br_wasm", "j_app", "br_prog", "j_view", "br_view", "br_pcan", "you"],
      ["Loops", "a_site", "s96mir", "br_worker", "br_html", "phoenix", "b_snapshot", "pages_snap", "s10", "a_post", "a_editor", "osm", "br_map"],
    ];

    export let stk_trace_names(): List<String> { stk_trace_rows.map { (t): String => t[0] } }

The boxes of trace `p`, in the order the trace names them.

    export let stk_trace_ids(p: Int): List<Int> {
      let t = stk_trace_rows[p];
      t.slice(1, t.length).map { (id): Int => stk_find(id) }.filter { (i): Boolean => i >= 0 }
    }

    export let stk_trace(p: Int): List<List<Boolean>> {
      let ids = stk_trace_ids(p);
      let on = stk_all.map { (i): Boolean => !ids.filter { (j): Boolean => j == i }.isEmpty };
      [on, stk_edges.map { (e): Boolean => on[stk_from[e]] && on[stk_to[e]] }]
    }

## Search

A box matches when every word of the query is somewhere in its id, label or
detail, ignoring case. Temper's `String` has no case mapping, so ASCII
letters are folded by hand, one split and join per letter; the backend
turns each into Blimp's native `join(split(s, "A"), "a")`. The boxes' text
is folded once, when the program loads.

    export let stk_fold(s: String): String {
      let a = s.split("A").join("a") { (p): String => p }.split("B").join("b") { (p): String => p };
      let b = a.split("C").join("c") { (p): String => p }.split("D").join("d") { (p): String => p };
      let c = b.split("E").join("e") { (p): String => p }.split("F").join("f") { (p): String => p };
      let d = c.split("G").join("g") { (p): String => p }.split("H").join("h") { (p): String => p };
      let e = d.split("I").join("i") { (p): String => p }.split("J").join("j") { (p): String => p };
      let f = e.split("K").join("k") { (p): String => p }.split("L").join("l") { (p): String => p };
      let g = f.split("M").join("m") { (p): String => p }.split("N").join("n") { (p): String => p };
      let h = g.split("O").join("o") { (p): String => p }.split("P").join("p") { (p): String => p };
      let i = h.split("Q").join("q") { (p): String => p }.split("R").join("r") { (p): String => p };
      let j = i.split("S").join("s") { (p): String => p }.split("T").join("t") { (p): String => p };
      let k = j.split("U").join("u") { (p): String => p }.split("V").join("v") { (p): String => p };
      let l = k.split("W").join("w") { (p): String => p }.split("X").join("x") { (p): String => p };
      l.split("Y").join("y") { (p): String => p }.split("Z").join("z") { (p): String => p }
    }

    let stk_labels_folded: List<String> = stk_rows.map { (r): String => stk_fold(r[2]) };
    let stk_hay: List<String> = stk_rows.map { (r): String => stk_fold("${r[0]} ${r[2]} ${r[3]}") };

    let stk_words(q: String): List<String> {
      stk_fold(q).split(" ").filter { (w): Boolean => !w.isEmpty }
    }

    let stk_has_all(s: String, words: List<String>): Boolean {
      words.filter { (w): Boolean => !(s.indexOf(w) is StringIndex) }.isEmpty
    }

Which boxes a query matches; none for a query of no words.

    export let stk_search(q: String): List<Boolean> {
      let words = stk_words(q);
      if (words.isEmpty) {
        stk_all.map { (i): Boolean => false }
      } else {
        stk_all.map { (i): Boolean => stk_has_all(stk_hay[i], words) }
      }
    }

    export let stk_search_hits(q: String): List<Int> {
      let hits = stk_search(q);
      stk_all.filter { (i): Boolean => hits[i] }
    }

What Enter picks: the first box whose label has every word, else the first
that matches at all, else -1.

    export let stk_best(q: String): Int {
      let words = stk_words(q);
      if (words.isEmpty) {
        -1
      } else {
        let by_label = stk_all.filter { (i): Boolean => stk_has_all(stk_labels_folded[i], words) };
        if (!by_label.isEmpty) {
          by_label[0]
        } else {
          let any = stk_all.filter { (i): Boolean => stk_has_all(stk_hay[i], words) };
          if (any.isEmpty) { -1 } else { any[0] }
        }
      }
    }

## Hiding kinds

A chip turned off hides its boxes and every line that touches one of them.

    export let stk_edges_hidden(hidden: List<String>): List<Boolean> {
      stk_edges.map { (e): Boolean => stk_has(hidden, stk_rows[stk_from[e]][1]) || stk_has(hidden, stk_rows[stk_to[e]][1]) }
    }

    export let stk_kind_total(kind: String): Int {
      stk_rows.filter { (r): Boolean => r[1] == kind }.length
    }
