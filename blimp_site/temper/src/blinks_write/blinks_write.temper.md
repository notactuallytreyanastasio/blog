# Blinks, the writing half

What the token-gated writes (`src/99_blinkswrite.blimp`) decide before
Postgres sees anything: whether an id in a path is one `Integer.parse/1`
takes whole, and what Elixir's `String.trim/1` leaves of a string, which is
also how Ecto's `cast/3` decides that a field was sent empty (`"   "` casts
to `nil`). Tags and quotes are lower-cased, trimmed and de-duplicated in
Postgres instead: lower-casing has to be Unicode's (`String.downcase/1`),
Temper's `String` has no case mapping and Blimp's `downcase` maps ASCII
only, while Postgres `lower()` under the database's UTF-8 collation does
what Elixir does for everything but a few special cases (`İ`).

No classes; every name starts `blkw_`.

## Integer.parse/1, whole

`Integer.parse("+3")` is `{3, ""}` and `Integer.parse("-3")` is
`{-3, ""}`, so `PATCH /api/blinks/+3` edits link 3 and `/-3` is a 404, not
a 400. `" 3"`, `"3x"`, `""` and `"+"` are 400s.

    export let blkw_is_int(s: String): Boolean {
      if (s.isEmpty) {
        false
      } else {
        let c = s[String.begin];
        if (c == 43 || c == 45) {
          blkw_digits(s, s.next(String.begin), false)
        } else {
          blkw_digits(s, String.begin, false)
        }
      }
    }

    let blkw_digits(s: String, i: StringIndex, seen: Boolean): Boolean {
      if (i >= s.end) {
        seen
      } else {
        let c = s[i];
        if (c < 48 || c > 57) { false } else { blkw_digits(s, s.next(i), true) }
      }
    }

## String.trim/1

The code points `String.trim/1` removes, found by asking Elixir 1.19 about
every one below U+10000: tab through carriage return, space, U+0085,
U+00A0, U+1680, U+2000 to U+200A, U+2028, U+2029, U+202F, U+205F and
U+3000. (Not U+200B or U+FEFF.)

    export let blkw_is_ws(c: Int): Boolean {
      (c >= 9 && c <= 13) || c == 32 || c == 0x85 || c == 0xA0 || c == 0x1680 ||
        (c >= 0x2000 && c <= 0x200A) || c == 0x2028 || c == 0x2029 ||
        c == 0x202F || c == 0x205F || c == 0x3000
    }

    export let blkw_trim(s: String): String {
      let from = blkw_skip(s, String.begin);
      s.slice(from, blkw_back(s, from, s.end))
    }

    let blkw_skip(s: String, i: StringIndex): StringIndex {
      if (i < s.end && blkw_is_ws(s[i])) { blkw_skip(s, s.next(i)) } else { i }
    }

    let blkw_back(s: String, from: StringIndex, n: StringIndex): StringIndex {
      if (n > from) {
        let p = s.prev(n);
        if (blkw_is_ws(s[p])) { blkw_back(s, from, p) } else { n }
      } else {
        n
      }
    }

Ecto's empty value: nothing left once trimmed.

    export let blkw_blank(s: String): Boolean { blkw_trim(s).isEmpty }
