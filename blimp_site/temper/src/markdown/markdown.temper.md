# Markdown helpers

The part of the post renderer (`src/10_markdown.blimp`) that is as fast in
Temper as it was in Blimp: the escaping passes and a few whole-string
trims. Each export here keeps the Blimp name it replaces, so the renderer
calls it unchanged.

## Why so little

The first cut of this module moved about fifty functions: escaping, href
encoding, HTML tag recognition, the entity, backtick, bracket and link
destination finders, bare-URL autolinks. The output was byte-identical and
boot went from 6.2s to 8.3s, the posts' render alone from 5.4s to 7.5s.

- A Temper character step is three interpreter calls: `s[i]` is
  temper-core's `u8_decode_at`, `s.next(i)` is `temper_string_next`, and
  `n + 1` is `temper_int32(n + 1)`. The Blimp was one `char_at` builtin and
  a `+`. The bare-URL scanner alone cost half a second of boot, href
  encoding a third of one.
- `contains("-_.", c)` is a builtin in Blimp. Temper has no way to ask it
  of a code point without a loop or a helper function, and each helper is a
  top-level def: the site pays about 15ms of boot for every top-level name
  it has, whether it is called or not (twenty dummy defs: 5471 -> 5768 ms).
- Temper's `String` has no case mapping, so nothing that lower-cases
  (`md_strip_scripts`, `md_html_start`) could move at all.
- The block parser, the inline scanner and the emphasis matcher build
  tuples tagged with atoms and list-marker maps. The Temper shape for those
  is a class, and a Temper class is a Blimp actor that is never collected:
  one per block and per token of every post at boot.
- `code_block_html` sends to the `HIGHLIGHTER` actor.

What is left is what does not walk characters: every pass below is one
split and one join, the same two builtins the Blimp's `replace_all` came to.

    let { trim, trim_right } = import("../text");

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
