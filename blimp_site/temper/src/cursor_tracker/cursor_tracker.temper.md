# The cursor tracker's arithmetic

What `/cursor-tracker` computes rather than stores, shared by the server's
room (`src/94_cursor_tracker.blimp`) and the page's program
(`static/cursors/cursors.blimp`): a visitor's colour from their id, the
hourly clear, and the lines the page prints. A port of the pure functions of
`BlogWeb.CursorTrackerLive`. The room itself, who is here and where their
cursor is, is an actor, and stays Blimp.

## Colour

The LiveView took the first three bytes of `md5(user_id)`, each plus 100 and
at most 255. An id here is sixteen hex digits of `random_bytes(8)`, already
as random as a hash of it, so its first three bytes are used as they are.
Anything that is not a hex digit, or is missing, reads as 0.

    let ct_hex(c: Int): Int {
      if (c >= 48 && c <= 57) {
        c - 48
      } else if (c >= 97 && c <= 102) {
        c - 87
      } else if (c >= 65 && c <= 70) {
        c - 55
      } else {
        0
      }
    }

The first `n` hex digits of `s` as a number, `acc` so far.

    let ct_hex_value(s: String, i: StringIndex, n: Int, acc: Int): Int {
      if (n <= 0) {
        acc
      } else if (i >= s.end) {
        ct_hex_value(s, i, n - 1, acc * 16)
      } else {
        ct_hex_value(s, s.next(i), n - 1, acc * 16 + ct_hex(s[i]))
      }
    }

    let ct_lift(b: Int): Int { if (b + 100 > 255) { 255 } else { b + 100 } }

    export let ct_color(id: String): String {
      let rgb = ct_hex_value(id, String.begin, 6, 0);
      let r = ((rgb / 65536) orelse panic());
      let g = ((rgb / 256) orelse panic()) - r * 256;
      let b = rgb - r * 65536 - g * 256;
      "rgb(${ct_lift(r).toString()}, ${ct_lift(g).toString()}, ${ct_lift(b).toString()})"
    }

An id as the page shows it: its first six characters.

    let ct_short_end(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { ct_short_end(s, s.next(i), n - 1) }
    }

    export let ct_short(id: String): String {
      id.slice(String.begin, ct_short_end(id, String.begin, 6))
    }

Who drew a point, in the system log: `you` for your own, otherwise the short
id (`point_author_label/2`).

    export let ct_author(point_id: String, me: String): String {
      if (point_id.isEmpty || me.isEmpty) {
        ""
      } else if (point_id == me) {
        "you"
      } else {
        ct_short(point_id)
      }
    }

## The hourly clear

The page counts down to the next whole hour of Unix time
(`calculate_next_clear/0`), so that is when the server clears: a clear is
due when the hour a time is in differs from the hour of the last one. The
LiveView's store cleared sixty minutes after the app booted, whatever the
countdown said.

    export let ct_hour(now: Int64): Int64 { now / 3600i64 }

    export let ct_left(now: Int64): Int64 { 3600i64 - (now - ct_hour(now) * 3600i64) }

    export let ct_pad2(n: Int64): String {
      if (n < 10i64) { "0${n.toString()}" } else { n.toString() }
    }

`AUTO-CLEAR IN: 00:04:55`

    export let ct_clock(now: Int64): String {
      let left = ct_left(now);
      "${ct_pad2(left / 3600i64)}:${ct_pad2((left / 60i64) - (left / 3600i64) * 60i64)}:${ct_pad2(left - (left / 60i64) * 60i64)}"
    }

`Auto-clear scheduled in 0h 4m 55s`

    export let ct_left_text(now: Int64): String {
      let left = ct_left(now);
      "${(left / 3600i64).toString()}h ${((left / 60i64) - (left / 3600i64) * 60i64).toString()}m ${(left - (left / 60i64) * 60i64).toString()}s"
    }

## Positions

A coordinate from a browser, held to what the room will keep.

    export let ct_clamp(v: Int, lo: Int, hi: Int): Int {
      if (v < lo) { lo } else if (v > hi) { hi } else { v }
    }

Whether a position relative to the drawing area is inside it, edges
included, as the hook decided `inVisualization`.

    export let ct_inside(rx: Int, ry: Int, w: Int, h: Int): Boolean {
      rx >= 0 && ry >= 0 && rx <= w && ry <= h
    }

The system log's line for the `i`th newest point (from 1).

    export let ct_point_line(i: Int, x: Int, y: Int, author: String): String {
      "> Point ${i.toString()}: X:${x.toString()} Y:${y.toString()} by ${author}"
    }
