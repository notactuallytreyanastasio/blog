# Markdown helpers

The half of the post renderer that is functions over strings and positions.
This was the leaves of `src/10_markdown.blimp`; every name exported here is
the Blimp name it replaces, so the Blimp half calls them unchanged.

What stayed in Blimp, and why:

- The block parser and the inline scanner build tuples tagged with atoms
  (`{:para, text}`, `{:delim, "*", 2, true, false}`) and list-marker maps.
  Temper has neither; the Temper shape would be classes, and a Temper class
  is a Blimp actor that is never collected. One per block and one per token
  across every post at boot is not a trade to make for a port.
- `code_block_html` sends to the `HIGHLIGHTER` actor.
- Everything that lower-cases (`md_strip_scripts`, `md_html_start`,
  `md_html_block_ends`, `md_is_script_open`): Temper's `String` has no case
  mapping.
- The character-class predicates (`md_is_ws`, `md_is_ascii_punct`, ...) the
  Blimp half asks one character at a time. Here they take a code point, not a
  one-byte string or nil, and are private.

## Positions

A position is a `StringIndex`, which on the Blimp backend is the byte
offset, so the Blimp callers pass and get back the same numbers as before.
Temper does no arithmetic on one: `i + 2` is `s.next(s.next(i))`. Every place
the Blimp did byte arithmetic it was stepping over ASCII it had just looked
at, so a code point step is a byte step there.

"Not found" was -1 in some of these and 0 in others (`md_entity_end`,
`md_autolink_end`). Here it is always `StringIndex.none`, which is -1; every
Blimp caller of the 0 kind tests `> 0`, which -1 fails the same way.

    let { trim, trim_right, drop } = import("../text");

`code_at` is Blimp's `char_at` with nil spelled -1.

    let code_at(s: String, i: StringIndex): Int {
      if (i < s.end) { s[i] } else { -1 }
    }

    let md_is_letter_code(c: Int): Boolean {
      if (c < 65) {
        false
      } else if (c <= 90) {
        true
      } else if (c < 97) {
        false
      } else {
        c <= 122
      }
    }

    let md_is_digit_code(c: Int): Boolean {
      if (c < 48) { false } else { c <= 57 }
    }

    let md_is_alnum_code(c: Int): Boolean {
      if (md_is_digit_code(c)) { true } else { md_is_letter_code(c) }
    }

    let md_is_punct_code(c: Int): Boolean {
      if (c < 33) {
        false
      } else if (c <= 47) {
        true
      } else if (c < 58) {
        false
      } else if (c <= 64) {
        true
      } else if (c < 91) {
        false
      } else if (c <= 96) {
        true
      } else if (c < 123) {
        false
      } else {
        c <= 126
      }
    }

    let md_is_ws_code(c: Int): Boolean {
      if (c == 32) { true } else if (c == 9) { true } else { c == 10 }
    }

Whether code point `c` is one of a fixed set of ASCII characters. These were
`contains("...", c)`, one builtin call; a Temper loop over the set's code
points cost 330ms of the 15 posts' render in md_href alone, so each set is
an if-chain.

    let md_href_punct(c: Int): Boolean {
      if (c == 33) {
        true
      } else if (c == 35) {
        true
      } else if (c == 36) {
        true
      } else if (c == 37) {
        true
      } else if (c == 40) {
        true
      } else if (c == 41) {
        true
      } else if (c == 42) {
        true
      } else if (c == 43) {
        true
      } else if (c == 44) {
        true
      } else if (c == 45) {
        true
      } else if (c == 46) {
        true
      } else if (c == 47) {
        true
      } else if (c == 58) {
        true
      } else if (c == 59) {
        true
      } else if (c == 61) {
        true
      } else if (c == 63) {
        true
      } else if (c == 64) {
        true
      } else if (c == 95) {
        true
      } else if (c == 126) {
        true
      } else {
        false
      }
    }

    let md_attr_name_punct(c: Int): Boolean {
      if (c == 45) {
        true
      } else if (c == 46) {
        true
      } else if (c == 58) {
        true
      } else if (c == 95) {
        true
      } else {
        false
      }
    }

    let md_unquoted_stop(c: Int): Boolean {
      if (c == 34) {
        true
      } else if (c == 39) {
        true
      } else if (c == 60) {
        true
      } else if (c == 61) {
        true
      } else if (c == 62) {
        true
      } else if (c == 96) {
        true
      } else {
        false
      }
    }

    let md_hex_letter(c: Int): Boolean {
      if (c == 65) {
        true
      } else if (c == 66) {
        true
      } else if (c == 67) {
        true
      } else if (c == 68) {
        true
      } else if (c == 69) {
        true
      } else if (c == 70) {
        true
      } else if (c == 97) {
        true
      } else if (c == 98) {
        true
      } else if (c == 99) {
        true
      } else if (c == 100) {
        true
      } else if (c == 101) {
        true
      } else if (c == 102) {
        true
      } else {
        false
      }
    }

    let md_scheme_punct(c: Int): Boolean {
      if (c == 43) {
        true
      } else if (c == 45) {
        true
      } else if (c == 46) {
        true
      } else {
        false
      }
    }

    let md_bare_before(c: Int): Boolean {
      if (c == 40) {
        true
      } else if (c == 42) {
        true
      } else if (c == 95) {
        true
      } else if (c == 126) {
        true
      } else {
        false
      }
    }

    let md_domain_punct(c: Int): Boolean {
      if (c == 45) {
        true
      } else if (c == 46) {
        true
      } else if (c == 95) {
        true
      } else {
        false
      }
    }

    let md_trailing_punct(c: Int): Boolean {
      if (c == 33) {
        true
      } else if (c == 34) {
        true
      } else if (c == 39) {
        true
      } else if (c == 42) {
        true
      } else if (c == 44) {
        true
      } else if (c == 46) {
        true
      } else if (c == 58) {
        true
      } else if (c == 63) {
        true
      } else if (c == 95) {
        true
      } else if (c == 126) {
        true
      } else {
        false
      }
    }

Whether `lit` is spelled out in `s` starting at `i`.

    let md_looking_at(s: String, i: StringIndex, lit: String): Boolean {
      md_looking_from(s, i, lit, String.begin)
    }

    let md_looking_from(s: String, i: StringIndex, lit: String, j: StringIndex): Boolean {
      if (j >= lit.end) {
        true
      } else if (i >= s.end) {
        false
      } else if (s[i] == lit[j]) {
        md_looking_from(s, s.next(i), lit, lit.next(j))
      } else {
        false
      }
    }

## Escaping

Each pass is written out as a split and a join with a literal separator,
which the backend makes into Blimp's own `join(split(...))`: one call to
temper-core's split per pass. Through a helper function it was two calls per
pass, and the escapes run on every run of text in every post: that alone was
110ms of the 15 posts' render. The Blimp asked `contains` before each pass
to skip it; Temper's only way to ask is `indexOf`, which slices the string.

Text escaping as comrak does it: & < > and ", not '.

    export let md_esc(s: String): String {
      let s1 = s.split("&").join("&amp;") { (piece): String => piece };
      let s2 = s1.split("<").join("&lt;") { (piece): String => piece };
      let s3 = s2.split(">").join("&gt;") { (piece): String => piece };
      s3.split("\"").join("&quot;") { (piece): String => piece }
    }

highlight() escapes & < > " and ' already; MDEx also writes braces as
entities. No tag the highlighter emits contains a brace.

    export let md_esc_braces(s: String): String {
      let s1 = s.split("{").join("&lbrace;") { (piece): String => piece };
      s1.split("}").join("&rbrace;") { (piece): String => piece }
    }

    export let md_esc_code(s: String): String {
      md_esc_braces(md_esc(s).split("'").join("&#39;") { (piece): String => piece })
    }

The reference escapes braces in code spans (MDEx does this so the HTML can
sit inside HEEx). No post has a brace in plain text, so whether text braces
are escaped too is unverified; they are left alone.

    export let md_esc_code_span(s: String): String { md_esc_braces(md_esc(s)) }

Image alt text: the link text without markup characters.

    export let md_plain(s: String): String {
      let s1 = s.split("*").join("") { (piece): String => piece };
      let s2 = s1.split("_").join("") { (piece): String => piece };
      s2.split("`").join("") { (piece): String => piece }
    }

    export let md_chop_newlines(s: String): String {
      if (s.isEmpty) {
        s
      } else {
        let p = s.prev(s.end);
        if (s[p] == 10) { md_chop_newlines(s.slice(String.begin, p)) } else { s }
      }
    }

    export let md_unescape(s: String): String {
      if (s.indexOf("\\") is StringIndex) {
        md_unescape_loop(s, String.begin, String.begin, "")
      } else {
        s
      }
    }

    let md_unescape_loop(s: String, i: StringIndex, ts: StringIndex, acc: String): String {
      if (i >= s.end) {
        "${acc}${s.slice(ts, i)}"
      } else if (s[i] == 92) {
        let j = s.next(i);
        if (md_is_punct_code(code_at(s, j))) {
          let k = s.next(j);
          md_unescape_loop(s, k, k, "${acc}${s.slice(ts, i)}${s.slice(j, k)}")
        } else {
          md_unescape_loop(s, j, ts, acc)
        }
      } else {
        md_unescape_loop(s, s.next(i), ts, acc)
      }
    }

Percent-encode a URL the way comrak's escape_href does: these bytes pass,
& and ' become entities, everything else becomes %XX, one per UTF-8 byte.
The Blimp walked bytes; this walks code points and writes each one's bytes
back out, which is the same for any valid UTF-8 (an invalid byte would come
out as U+FFFD's three bytes; no post has one).

    export let md_href(url: String): String {
      md_href_loop(url, String.begin, String.begin, "")
    }

    let md_href_safe(c: Int): Boolean {
      if (md_is_alnum_code(c)) { true } else { md_href_punct(c) }
    }

    let md_href_loop(s: String, i: StringIndex, ts: StringIndex, acc: String): String {
      if (i >= s.end) {
        "${acc}${s.slice(ts, i)}"
      } else {
        let c = s[i];
        if (md_href_safe(c)) {
          md_href_loop(s, s.next(i), ts, acc)
        } else {
          let enc = if (c == 38) { "&amp;" } else if (c == 39) { "&#x27;" } else { md_pct_utf8(c) };
          let n = s.next(i);
          md_href_loop(s, n, n, "${acc}${s.slice(ts, i)}${enc}")
        }
      }
    }

    let md_pct_utf8(c: Int): String {
      if (c < 128) {
        md_pct(c)
      } else if (c < 2048) {
        "${md_pct(192 + c / 64)}${md_pct(128 + c % 64)}"
      } else if (c < 65536) {
        "${md_pct(224 + c / 4096)}${md_pct(128 + (c / 64) % 64)}${md_pct(128 + c % 64)}"
      } else {
        "${md_pct(240 + c / 262144)}${md_pct(128 + (c / 4096) % 64)}${md_pct(128 + (c / 64) % 64)}${md_pct(128 + c % 64)}"
      }
    }

    let md_pct(b: Int): String {
      let hex = "0123456789ABCDEF";
      let hi = hex.step(String.begin, b / 16);
      let lo = hex.step(String.begin, b % 16);
      "%${hex.slice(hi, hex.next(hi))}${hex.slice(lo, hex.next(lo))}"
    }

## Lines

First position at or after `i` that is not a space or tab. The Blimp half
keeps its own `md_skip_ws`, `md_is_blank`, `md_indent`, `md_strip_cols` and
`md_run_length`: the parser asks them about every line several times, and a
Temper character step is three interpreter calls (`u8_decode_at`,
`temper_string_next`, `temper_int32` for the `+ 1`) where Blimp's is one
builtin. Moved here they cost 115ms of the 15 posts' 1.1s render.

    let md_space_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end) {
        let c = s[i];
        if (c == 32) {
          md_space_end(s, s.next(i))
        } else if (c == 9) {
          md_space_end(s, s.next(i))
        } else {
          i
        }
      } else {
        i
      }
    }

The same, over newlines too.

    export let md_skip_ws_nl(s: String, i: StringIndex): StringIndex {
      if (i < s.end) {
        if (md_is_ws_code(s[i])) { md_skip_ws_nl(s, s.next(i)) } else { i }
      } else {
        i
      }
    }

    let md_blank(line: String): Boolean {
      md_space_end(line, String.begin) >= line.end
    }

Where a run of code point `code` starting at `i` ends.



    let md_run_end(s: String, i: StringIndex, code: Int): StringIndex {
      if (i < s.end) {
        if (s[i] == code) { md_run_end(s, s.next(i), code) } else { i }
      } else {
        i
      }
    }

    export let md_setext_level(t: String): Int {
      let c = code_at(t, String.begin);
      if (c == 61 || c == 45) {
        if (md_blank(drop(t, md_run_end(t, String.begin, c)))) {
          if (c == 61) { 1 } else { 2 }
        } else {
          0
        }
      } else {
        0
      }
    }

    export let md_is_hr(t: String): Boolean {
      let c = code_at(t, String.begin);
      if (c == 45) {
        md_hr_loop(t, c, String.begin, 0)
      } else if (c == 42) {
        md_hr_loop(t, c, String.begin, 0)
      } else if (c == 95) {
        md_hr_loop(t, c, String.begin, 0)
      } else {
        false
      }
    }

    let md_hr_loop(t: String, c: Int, i: StringIndex, n: Int): Boolean {
      if (i >= t.end) {
        n >= 3
      } else {
        let ch = t[i];
        if (ch == c) {
          md_hr_loop(t, c, t.next(i), n + 1)
        } else if (ch == 32) {
          md_hr_loop(t, c, t.next(i), n)
        } else if (ch == 9) {
          md_hr_loop(t, c, t.next(i), n)
        } else {
          false
        }
      }
    }

An ATX heading's text: drop an optional closing run of #s, which must follow
a space.

    export let md_atx_content(s: String): String {
      let stripped = md_trim_hashes(s);
      if (stripped == s) {
        s
      } else if (stripped.isEmpty) {
        stripped
      } else {
        let last = stripped[stripped.prev(stripped.end)];
        if (last == 32 || last == 9) { trim_right(stripped) } else { s }
      }
    }

    let md_trim_hashes(s: String): String {
      if (s.isEmpty) {
        s
      } else {
        let p = s.prev(s.end);
        if (s[p] == 35) { md_trim_hashes(s.slice(String.begin, p)) } else { s }
      }
    }

    let md_digits_end(s: String, i: StringIndex): StringIndex {
      if (md_is_digit_code(code_at(s, i))) { md_digits_end(s, s.next(i)) } else { i }
    }


## HTML tags

    export let md_block_tag(name: String): Boolean {
      " address article aside base basefont blockquote body caption center col colgroup dd details dialog dir div dl dt fieldset figcaption figure footer form frame frameset h1 h2 h3 h4 h5 h6 head header hr html iframe legend li link main menu menuitem nav noframes ol optgroup option p param search section summary table tbody td tfoot th thead title tr track ul ".indexOf(" ${name} ") is StringIndex
    }

    export let md_tag_name_end(s: String, i: StringIndex): StringIndex {
      if (md_is_letter_code(code_at(s, i))) { md_tag_name_rest(s, s.next(i)) } else { i }
    }

    let md_tag_name_rest(s: String, i: StringIndex): StringIndex {
      let c = code_at(s, i);
      if (md_is_alnum_code(c)) {
        md_tag_name_rest(s, s.next(i))
      } else if (c == 45) {
        md_tag_name_rest(s, s.next(i))
      } else {
        i
      }
    }

End of an HTML tag, closing tag or comment starting at `i` (a "<"), or none.

    export let md_html_tag_end(s: String, i: StringIndex): StringIndexOption {
      let i1 = s.next(i);
      if (md_looking_at(s, i, "<!--")) {
        let e = s.indexOf("-->", s.step(i, 4));
        if (e is StringIndex) { s.step(e, 3) } else { StringIndex.none }
      } else if (code_at(s, i1) == 47) {
        let i2 = s.next(i1);
        let ne = md_tag_name_end(s, i2);
        if (ne > i2) {
          let j = md_skip_ws_nl(s, ne);
          if (code_at(s, j) == 62) { s.next(j) } else { StringIndex.none }
        } else {
          StringIndex.none
        }
      } else {
        let ne = md_tag_name_end(s, i1);
        if (ne > i1) { md_attrs_end(s, ne) } else { StringIndex.none }
      }
    }

    let md_attrs_end(s: String, i: StringIndex): StringIndexOption {
      let j = md_skip_ws_nl(s, i);
      let c = code_at(s, j);
      if (c == 62) {
        s.next(j)
      } else if (c == 47) {
        let j1 = s.next(j);
        if (code_at(s, j1) == 62) { s.next(j1) } else { StringIndex.none }
      } else if (j > i && md_attr_name_start(c)) {
        let ne = md_attr_name_end(s, s.next(j));
        let k = md_skip_ws_nl(s, ne);
        if (code_at(s, k) == 61) {
          let ve = md_attr_value_end(s, md_skip_ws_nl(s, s.next(k)));
          if (ve is StringIndex) { md_attrs_end(s, ve) } else { StringIndex.none }
        } else {
          md_attrs_end(s, ne)
        }
      } else {
        StringIndex.none
      }
    }

    let md_attr_name_start(c: Int): Boolean {
      if (md_is_letter_code(c)) { true } else if (c == 95) { true } else { c == 58 }
    }

    let md_attr_name_end(s: String, i: StringIndex): StringIndex {
      let c = code_at(s, i);
      if (md_is_alnum_code(c)) {
        md_attr_name_end(s, s.next(i))
      } else if (md_attr_name_punct(c)) {
        md_attr_name_end(s, s.next(i))
      } else {
        i
      }
    }

    let md_attr_value_end(s: String, i: StringIndex): StringIndexOption {
      let c = code_at(s, i);
      if (c == 34 || c == 39) {
        let e = s.indexOf(s.slice(i, s.next(i)), s.next(i));
        if (e is StringIndex) { s.next(e) } else { StringIndex.none }
      } else {
        let e = md_unquoted_end(s, i);
        if (e > i) { e } else { StringIndex.none }
      }
    }

    let md_unquoted_end(s: String, i: StringIndex): StringIndex {
      let c = code_at(s, i);
      if (c < 0) {
        i
      } else if (md_is_ws_code(c)) {
        i
      } else if (md_unquoted_stop(c)) {
        i
      } else {
        md_unquoted_end(s, s.next(i))
      }
    }

## Inline finders

`&name;` `&#123;` `&#x1F;`: the position after the ";" of a valid-looking
entity at `i`, or none.

    export let md_entity_end(s: String, i: StringIndex): StringIndexOption {
      let i1 = s.next(i);
      let c = code_at(s, i1);
      if (c == 35) {
        let i2 = s.next(i1);
        let x = code_at(s, i2);
        if (x == 120 || x == 88) {
          let i3 = s.next(i2);
          md_entity_close(s, md_hex_run(s, i3), i3, 6)
        } else {
          md_entity_close(s, md_digits_end(s, i2), i2, 7)
        }
      } else if (md_is_letter_code(c)) {
        md_entity_close(s, md_alnum_run(s, i1), i1, 32)
      } else {
        StringIndex.none
      }
    }

    let md_entity_close(s: String, e: StringIndex, start: StringIndex, max: Int): StringIndexOption {
      if (e > start) {
        if (s.countBetween(start, e) <= max) {
          if (code_at(s, e) == 59) { s.next(e) } else { StringIndex.none }
        } else {
          StringIndex.none
        }
      } else {
        StringIndex.none
      }
    }

    let md_alnum_run(s: String, i: StringIndex): StringIndex {
      if (md_is_alnum_code(code_at(s, i))) { md_alnum_run(s, s.next(i)) } else { i }
    }

    let md_hex_run(s: String, i: StringIndex): StringIndex {
      let c = code_at(s, i);
      if (md_is_digit_code(c)) {
        md_hex_run(s, s.next(i))
      } else if (md_hex_letter(c)) {
        md_hex_run(s, s.next(i))
      } else {
        i
      }
    }

Start of the next backtick run of exactly `k`, or none.

    export let md_find_backticks(s: String, i: StringIndex, k: Int): StringIndexOption {
      let j = s.indexOf("`", i);
      if (j is StringIndex) {
        let e = md_run_end(s, j, 96);
        if (s.countBetween(j, e) == k) { j } else { md_find_backticks(s, e, k) }
      } else {
        StringIndex.none
      }
    }

    export let md_code_span_trim(s: String): String {
      if (s.isEmpty) {
        s
      } else {
        let first = s.next(String.begin);
        let last = s.prev(s.end);
        if (first < last && s[String.begin] == 32 && s[last] == 32 && !trim(s).isEmpty) {
          s.slice(first, last)
        } else {
          s
        }
      }
    }

A soft or hard line break drops the spaces before it: where they start.

    export let md_back_spaces(s: String, j: StringIndex, floor: StringIndex): StringIndex {
      if (j > floor) {
        let p = s.prev(j);
        if (s[p] == 32) { md_back_spaces(s, p, floor) } else { j }
      } else {
        j
      }
    }

The "]" that closes the bracket opened just before `i`, or none. Backslash
escapes and code spans are skipped over.

    export let md_find_bracket_close(s: String, i: StringIndex, depth: Int): StringIndexOption {
      let c = code_at(s, i);
      if (c < 0) {
        StringIndex.none
      } else if (c == 92) {
        md_find_bracket_close(s, s.next(s.next(i)), depth)
      } else if (c == 96) {
        let e = md_run_end(s, i, 96);
        let close = md_find_backticks(s, e, s.countBetween(i, e));
        if (close is StringIndex) {
          md_find_bracket_close(s, s.step(close, s.countBetween(i, e)), depth)
        } else {
          md_find_bracket_close(s, e, depth)
        }
      } else if (c == 91) {
        md_find_bracket_close(s, s.next(i), depth + 1)
      } else if (c == 93) {
        if (depth == 0) { i } else { md_find_bracket_close(s, s.next(i), depth - 1) }
      } else {
        md_find_bracket_close(s, s.next(i), depth)
      }
    }

A `<...>` link destination: the ">", or none.

    export let md_angle_dest_end(s: String, i: StringIndex): StringIndexOption {
      let c = code_at(s, i);
      if (c < 0) {
        StringIndex.none
      } else if (c == 10) {
        StringIndex.none
      } else if (c == 60) {
        StringIndex.none
      } else if (c == 62) {
        i
      } else if (c == 92) {
        md_angle_dest_end(s, s.next(s.next(i)))
      } else {
        md_angle_dest_end(s, s.next(i))
      }
    }

End of a bare destination: no spaces or control characters, parentheses
balanced.

    export let md_dest_end(s: String, i: StringIndex, depth: Int): StringIndexOption {
      let c = code_at(s, i);
      if (c < 0 || md_is_ws_code(c)) {
        if (depth == 0) { i } else { StringIndex.none }
      } else if (c == 92) {
        let i1 = s.next(i);
        if (md_is_punct_code(code_at(s, i1))) { md_dest_end(s, s.next(i1), depth) } else { md_dest_end(s, i1, depth) }
      } else if (c == 40) {
        md_dest_end(s, s.next(i), depth + 1)
      } else if (c == 41) {
        if (depth == 0) { i } else { md_dest_end(s, s.next(i), depth - 1) }
      } else if (c < 32) {
        StringIndex.none
      } else {
        md_dest_end(s, s.next(i), depth)
      }
    }

    export let md_title_end(s: String, i: StringIndex, closer: String): StringIndexOption {
      let c = code_at(s, i);
      if (c < 0) {
        StringIndex.none
      } else if (c == 92) {
        md_title_end(s, s.next(s.next(i)), closer)
      } else if (c == closer[String.begin]) {
        i
      } else {
        md_title_end(s, s.next(i), closer)
      }
    }

## Autolinks

`<scheme:...>` or `<user@host>` at `i`: the position after the ">", or none.

    export let md_autolink_end(s: String, i: StringIndex): StringIndexOption {
      let i1 = s.next(i);
      let e = md_autolink_scan(s, i1);
      if (e is StringIndex) {
        let body = s.slice(i1, e);
        if (md_is_uri(body) || md_is_email(body)) { s.next(e) } else { StringIndex.none }
      } else {
        StringIndex.none
      }
    }

    let md_autolink_scan(s: String, i: StringIndex): StringIndexOption {
      let c = code_at(s, i);
      if (c < 0) {
        StringIndex.none
      } else if (c == 60) {
        StringIndex.none
      } else if (md_is_ws_code(c)) {
        StringIndex.none
      } else if (c == 62) {
        i
      } else {
        md_autolink_scan(s, s.next(i))
      }
    }

The scheme's length is counted in code points, where the Blimp counted
bytes; the two differ only when the scheme has a non-ASCII character, which
fails `md_scheme_chars` either way.

    export let md_is_uri(body: String): Boolean {
      let colon = body.indexOf(":");
      if (colon is StringIndex) {
        let n = body.countBetween(String.begin, colon);
        if (n >= 2 && n <= 32 && md_is_letter_code(code_at(body, String.begin))) {
          md_scheme_chars(body, body.next(String.begin), colon)
        } else {
          false
        }
      } else {
        false
      }
    }

    let md_scheme_chars(s: String, i: StringIndex, stop: StringIndex): Boolean {
      if (i >= stop) {
        true
      } else {
        let c = s[i];
        if (md_is_alnum_code(c) || md_scheme_punct(c)) { md_scheme_chars(s, s.next(i), stop) } else { false }
      }
    }

    export let md_is_email(body: String): Boolean {
      let at = body.indexOf("@");
      if (at is StringIndex) {
        if (at > String.begin) {
          let dot = body.indexOf(".", at);
          if (dot is StringIndex) {
            if (dot > body.next(at)) { !(body.indexOf("\\") is StringIndex) } else { false }
          } else {
            false
          }
        } else {
          false
        }
      } else {
        false
      }
    }

Bare URLs (the GFM autolink extension): `www.`, `http://`, `https://` at
`i`. The end of the link, or none.

    export let md_bare_end(s: String, i: StringIndex): StringIndexOption {
      let prev = if (i <= String.begin) { 32 } else { s[s.prev(i)] };
      if (md_is_ws_code(prev) || md_bare_before(prev)) {
        let dom = if (md_looking_at(s, i, "www.")) {
          i
        } else if (md_looking_at(s, i, "https://")) {
          s.step(i, 8)
        } else if (md_looking_at(s, i, "http://")) {
          s.step(i, 7)
        } else {
          StringIndex.none
        };
        if (dom is StringIndex) {
          let de = md_domain_end(s, dom);
          if (de <= dom) {
            StringIndex.none
          } else if (dom == i && !(s.slice(dom, de).indexOf(".") is StringIndex)) {
            StringIndex.none
          } else {
            md_autolink_trim(s, i, md_link_run_end(s, de))
          }
        } else {
          StringIndex.none
        }
      } else {
        StringIndex.none
      }
    }

    let md_domain_end(s: String, i: StringIndex): StringIndex {
      let c = code_at(s, i);
      if (c < 0) {
        i
      } else if (md_is_alnum_code(c)) {
        md_domain_end(s, s.next(i))
      } else if (c >= 128 || md_domain_punct(c)) {
        md_domain_end(s, s.next(i))
      } else {
        i
      }
    }

    let md_link_run_end(s: String, i: StringIndex): StringIndex {
      let c = code_at(s, i);
      if (c < 0) {
        i
      } else if (md_is_ws_code(c) || c == 60) {
        i
      } else {
        md_link_run_end(s, s.next(i))
      }
    }

Trailing punctuation is not part of the link; a ")" only is when it closes a
"(" inside the link.

    let md_autolink_trim(s: String, start: StringIndex, e: StringIndex): StringIndex {
      if (e <= start) {
        e
      } else {
        let p = s.prev(e);
        let c = s[p];
        if (md_trailing_punct(c)) {
          md_autolink_trim(s, start, p)
        } else if (c == 41) {
          let link = s.slice(start, e);
          if (link.split(")").length > link.split("(").length) { md_autolink_trim(s, start, p) } else { e }
        } else if (c == 59) {
          md_autolink_trim(s, start, md_trim_entity(s, start, p))
        } else {
          e
        }
      }
    }

"...&amp;" at the end drops the entity; any other ";" drops just itself.

    let md_trim_entity(s: String, start: StringIndex, semi: StringIndex): StringIndex {
      let j = md_alnum_back(s, semi, start);
      if (j < semi && j > start) {
        let p = s.prev(j);
        if (s[p] == 38) { p } else { semi }
      } else {
        semi
      }
    }

    let md_alnum_back(s: String, j: StringIndex, floor: StringIndex): StringIndex {
      if (j > floor) {
        let p = s.prev(j);
        if (md_is_alnum_code(s[p])) { md_alnum_back(s, p, floor) } else { j }
      } else {
        j
      }
    }
