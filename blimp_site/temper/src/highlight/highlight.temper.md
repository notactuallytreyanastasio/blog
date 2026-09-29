# Highlight

Server-side syntax highlighting, emitting highlight.js class names so a stock
highlight.js theme (or `highlight_css` below) styles the result. This was
`src/20_highlight.blimp`; `highlight`, `highlight_lines` and `highlight_css`
keep their names, so no call site changed.

`highlight(lang, code)` takes the raw text of a fenced block and returns the
HTML that goes inside `<code>`. Only Elixir is highlighted. Every other
language comes back HTML-escaped and nothing more: no auto-detection.

The Elixir scanner follows highlight.js 11's grammar (src/languages/
elixir.js) mode by mode. That grammar is a list of modes tried at each
position in order; the first mode whose begin matches at the leftmost
position wins, and text between modes is scanned for keywords.

Classes emitted, all from the hljs grammar:

- hljs-keyword        after alias and case ... with, plus def/defmodule
- hljs-literal        true false nil
- hljs-string         "..." '...' """...""" '''...''' ~S"..." ~s(...) etc
- hljs-subst          #{...} inside strings and lowercase sigils
- hljs-char escape_   backslash escapes inside sigils (not plain strings)
- hljs-regex          ~r/.../ and ~R/.../ (hljs says "regex", not "regexp")
- hljs-comment        # to end of line
- hljs-doctag         TODO: FIXME: NOTE: BUG: OPTIMIZE: HACK: XXX: in comments
- hljs-function       def/defp/defmacro/defmacrop through the name
- hljs-class          defmodule/defimpl/defprotocol/defrecord through the name
- hljs-title          the name after those
- hljs-title class_   any other Capitalised name (module references)
- hljs-symbol         :atom, :"atom", key:
- hljs-number         42, -1, 1_000, 3.14, 1.0e10, 0x1F, 0b101, 0o17
- hljs-variable       @attr, @@x, $x

Known departures from hljs, all in edge cases the posts do not hit: `\s`
after ":" means ASCII whitespace only; a backslash escape swallows one whole
character where hljs takes one UTF-16 unit; hljs's "phrasal words" comment
mode only scores relevance, so it is not modelled.

    let { escape_html, repeat } = import("../text");

## Why every mode is two functions

The Blimp version returned `{sink, index}` from every mode. Temper has no
tuples, and its `Pair`, `StringBuilder` and `ListBuilder` are classes, which
the Blimp backend makes into actors that are never collected: one per token
would be thousands per page. So each mode here is a pair of functions over
values. `*_end` answers where the mode ends, a `StringIndex`; `*_html`
answers its HTML, a `String`. A loop that emits carries its output as a
parameter, and when it needs to continue after a nested mode it asks that
mode's `_end`. The price is that nested modes are scanned more than once; a
code block is a few KB and nests two or three deep.

## Positions

A position is a `StringIndex`, which on the Blimp backend is the byte
offset. Temper has no arithmetic on it, so the Blimp version's `i + 1`
becomes `code.next(i)`, a whole character. That is the same scan: every mode
begins with an ASCII byte, so no mode can begin at a UTF-8 continuation byte,
and a code point of 128 or more is no word character, space or delimiter,
just as a byte of 128 or more was not. `hl_c` is -1 at the end and
`hl_before` is -1 at the start.

    let hl_c(code: String, i: StringIndex): Int {
      if (i < code.end) { code[i] } else { -1 }
    }

    let hl_before(code: String, i: StringIndex): Int {
      if (i > String.begin) { code[code.prev(i)] } else { -1 }
    }

    let hl_c1(code: String, i: StringIndex): Int {
      if (i < code.end) { hl_c(code, code.next(i)) } else { -1 }
    }

    let hl_is_digit(c: Int): Boolean { c >= 48 && c <= 57 }

    let hl_is_upper(c: Int): Boolean { c >= 65 && c <= 90 }

    let hl_is_lower(c: Int): Boolean { c >= 97 && c <= 122 }

`[a-zA-Z_]` and `\w`, as if-chains: an `&&` inside an `||` comes out of the
backend as temporaries, and these are asked of every character.

    let hl_is_ident_start(c: Int): Boolean {
      if (c < 65) {
        false
      } else if (c <= 90) {
        true
      } else if (c == 95) {
        true
      } else if (c < 97) {
        false
      } else {
        c <= 122
      }
    }

    let hl_is_word(c: Int): Boolean {
      if (c < 48) {
        false
      } else if (c <= 57) {
        true
      } else {
        hl_is_ident_start(c)
      }
    }

    let hl_is_space(c: Int): Boolean {
      if (c == 32) { true } else { c >= 9 && c <= 13 }
    }

`\b` before position i: the characters either side differ in wordness.

    let hl_boundary(code: String, i: StringIndex): Boolean {
      hl_is_word(hl_before(code, i)) != hl_is_word(hl_c(code, i))
    }

    let hl_next_to(code: String, n: StringIndex, i: StringIndex): StringIndex {
      let j = code.next(i);
      if (j > n) { n } else { j }
    }

The end of `s` matched at i, or i when it does not match there. Every `s`
asked about is short and ASCII.

    let hl_at_end(code: String, i: StringIndex, s: String): StringIndex {
      hl_at_loop(code, i, i, s, String.begin)
    }

    let hl_at_loop(code: String, i0: StringIndex, i: StringIndex, s: String, j: StringIndex): StringIndex {
      if (j >= s.end) {
        i
      } else if (i >= code.end) {
        i0
      } else if (code[i] != s[j]) {
        i0
      } else {
        hl_at_loop(code, i0, code.next(i), s, s.next(j))
      }
    }

    let hl_at(code: String, i: StringIndex, s: String): Boolean {
      hl_at_end(code, i, s) > i
    }

`\w*`, `[a-zA-Z0-9_.]*` and ELIXIR_IDENT_RE, `[a-zA-Z_][a-zA-Z0-9_.]*(!|\?)?`,
never reading past n.

    let hl_word_run(code: String, n: StringIndex, i: StringIndex): StringIndex {
      if (i >= n) { i } else if (hl_is_word(code[i])) { hl_word_run(code, n, code.next(i)) } else { i }
    }

    let hl_ident_run(code: String, n: StringIndex, i: StringIndex): StringIndex {
      if (i < n) {
        let c = code[i];
        if (hl_is_word(c)) {
          hl_ident_run(code, n, code.next(i))
        } else if (c == 46) {
          hl_ident_run(code, n, code.next(i))
        } else {
          i
        }
      } else {
        i
      }
    }

    let hl_ident_end(code: String, n: StringIndex, i: StringIndex): StringIndex {
      let e = hl_ident_run(code, n, code.next(i));
      if (e < n) {
        let c = code[e];
        if (c == 33 || c == 63) { code.next(e) } else { e }
      } else {
        e
      }
    }

## Output

`escape_html` is five split/join passes, which the Blimp version skipped for
the tokens that need none of them. Here it always runs; the passes are the
interpreter's own `split` and `join`.

    let hl_text(code: String, a: StringIndex, b: StringIndex): String {
      if (a < b) { escape_html(code.slice(a, b)) } else { "" }
    }

    let hl_span(cls: String, code: String, a: StringIndex, b: StringIndex): String {
      "<span class=\"hljs-${cls}\">${escape_html(code.slice(a, b))}</span>"
    }

## Keywords, applied to the text between modes

Keywords, by first letter and then one `==` at a time. A chain of `||` in
an `if` condition, or a `when` with several values on one branch, comes out
of the backend as a temporary and a one-element list per comparison, and this
is asked of every identifier.

    let hl_kw_kind(w: String): String {
      let c = w[String.begin];
      if (c == 97) {
        if (w == "after") { "keyword" } else if (w == "alias") { "keyword" } else if (w == "and") { "keyword" } else { "" }
      } else if (c == 99) {
        if (w == "case") { "keyword" } else if (w == "catch") { "keyword" } else if (w == "cond") { "keyword" } else { "" }
      } else if (c == 100) {
        if (w == "defguard") { "keyword" } else if (w == "defstruct") { "keyword" } else if (w == "do") { "keyword" } else { "" }
      } else if (c == 101) {
        if (w == "else") { "keyword" } else if (w == "end") { "keyword" } else { "" }
      } else if (c == 102) {
        if (w == "false") { "literal" } else if (w == "fn") { "keyword" } else if (w == "for") { "keyword" } else { "" }
      } else if (c == 105) {
        if (w == "if") { "keyword" } else if (w == "import") { "keyword" } else if (w == "in") { "keyword" } else { "" }
      } else if (c == 110) {
        if (w == "nil") { "literal" } else if (w == "not") { "keyword" } else { "" }
      } else if (c == 111) {
        if (w == "or") { "keyword" } else { "" }
      } else if (c == 113) {
        if (w == "quote") { "keyword" } else { "" }
      } else if (c == 114) {
        if (w == "raise") { "keyword" } else if (w == "receive") { "keyword" } else if (w == "require") { "keyword" } else if (w == "reraise") { "keyword" } else if (w == "rescue") { "keyword" } else { "" }
      } else if (c == 116) {
        if (w == "true") { "literal" } else if (w == "try") { "keyword" } else { "" }
      } else if (c == 117) {
        if (w == "unless") { "keyword" } else if (w == "unquote") { "keyword" } else if (w == "unquote_splicing") { "keyword" } else if (w == "use") { "keyword" } else { "" }
      } else if (c == 119) {
        if (w == "when") { "keyword" } else if (w == "with") { "keyword" } else { "" }
      } else {
        ""
      }
    }

hljs scans the buffer with ELIXIR_IDENT_RE, unanchored, so "Enum.map" is one
word (and not a keyword) and "x.end" is not the keyword end. The identifier
cannot run past the buffer's end b.

    let hl_kw(code: String, a: StringIndex, b: StringIndex): String {
      if (a < b) { hl_kw_scan(code, a, b, a, "") } else { "" }
    }

    let hl_kw_scan(code: String, j: StringIndex, b: StringIndex, run: StringIndex, out: String): String {
      if (j >= b) {
        "${out}${hl_text(code, run, b)}"
      } else if (hl_is_ident_start(code[j])) {
        let e = hl_ident_end(code, b, j);
        let k = hl_kw_kind(code.slice(j, e));
        if (k == "") {
          hl_kw_scan(code, e, b, run, out)
        } else {
          hl_kw_scan(code, e, b, e, "${out}${hl_text(code, run, j)}${hl_span(k, code, j, e)}")
        }
      } else {
        hl_kw_scan(code, code.next(j), b, run, out)
      }
    }

## The default mode: top level, and the inside of #{...}

From i, with `start` where the pending keyword buffer began. With `subst`,
an unclaimed "}" ends it: `_end` answers the position after the "}", and
`_html` emits the "}" (the caller closes the span).

Could any mode begin with this character? `" ' ~ # : - $ @` or a word
character.

    let hl_may_begin(c: Int): Boolean {
      if (hl_is_word(c)) {
        true
      } else {
        c == 34 || c == 39 || c == 126 || c == 35 || c == 58 || c == 45 || c == 36 || c == 64
      }
    }

Nothing began at a word's start, so nothing begins inside it: every mode but
key: needs a `\b`, and key: fails the same way from any later start in the
word.

    let hl_skip(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      if (!hl_is_word(c)) { code.next(i) } else if (hl_boundary(code, i)) { hl_word_run(code, n, i) } else { code.next(i) }
    }

    let hl_default_end(code: String, n: StringIndex, i: StringIndex, subst: Boolean): StringIndex {
      if (i >= n) {
        n
      } else {
        let c = code[i];
        if (!hl_may_begin(c)) {
          if (c != 125) { hl_default_end(code, n, code.next(i), subst) } else if (subst) { code.next(i) } else { hl_default_end(code, n, code.next(i), subst) }
        } else {
          let e = hl_mode_end(code, n, i, c);
          if (e > i) { hl_default_end(code, n, e, subst) } else { hl_default_end(code, n, hl_skip(code, n, i, c), subst) }
        }
      }
    }

    let hl_default_html(code: String, n: StringIndex, i: StringIndex, start: StringIndex, out: String, subst: Boolean): String {
      if (i >= n) {
        "${out}${hl_kw(code, start, n)}"
      } else {
        let c = code[i];
        if (!hl_may_begin(c)) {
          if (c != 125) {
            hl_default_html(code, n, code.next(i), start, out, subst)
          } else if (subst) {
            "${out}${hl_kw(code, start, i)}}"
          } else {
            hl_default_html(code, n, code.next(i), start, out, subst)
          }
        } else {
          let e = hl_mode_end(code, n, i, c);
          if (e > i) {
            hl_default_html(code, n, e, e, "${out}${hl_kw(code, start, i)}${hl_mode_html(code, n, i, c)}", subst)
          } else {
            hl_default_html(code, n, hl_skip(code, n, i, c), start, out, subst)
          }
        }
      }
    }

## Every mode, in the grammar's order

`hl_mode_end` answers i when nothing begins at i. `hl_mode_html` is only
asked where something does, and takes the same branches.

    let hl_mode_end(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      let v = hl_string_variant(code, i);
      if (v > 0) {
        hl_string_end(code, n, i, v)
      } else if (c == 126) {
        let k = hl_sigil_kind(code, i);
        if (k > 0) { hl_sigil_parts_end(code, n, code.next(code.next(i)), k) } else { i }
      } else if (c == 35) {
        hl_line_end(code, n, i)
      } else {
        let d = hl_def_kind(code, n, i);
        if (d > 0) {
          hl_def_end(code, n, hl_word_run(code, n, i), d == 2)
        } else if (c == 58) {
          let c1 = hl_c1(code, i);
          if (c1 == 58) {
            code.next(code.next(i))
          } else if (!hl_is_space(c1)) {
            hl_symbol_parts_end(code, n, code.next(i))
          } else {
            hl_token_end(code, n, i, c)
          }
        } else {
          hl_token_end(code, n, i, c)
        }
      }
    }

    let hl_mode_html(code: String, n: StringIndex, i: StringIndex, c: Int): String {
      let v = hl_string_variant(code, i);
      if (v > 0) {
        hl_string_html(code, n, i, v)
      } else if (c == 126) {
        let k = hl_sigil_kind(code, i);
        let j = code.next(code.next(i));
        let cls = if (k <= 2) { "regex" } else { "string" };
        hl_sigil_parts_html(code, n, j, k, "<span class=\"hljs-${cls}\">${hl_text(code, i, j)}")
      } else if (c == 35) {
        let e = hl_line_end(code, n, i);
        "<span class=\"hljs-comment\">${hl_doctags(code, i, e, i, "")}</span>"
      } else {
        let d = hl_def_kind(code, n, i);
        if (d > 0) {
          let w = hl_word_run(code, n, i);
          let cls = if (d == 2) { "class" } else { "function" };
          "<span class=\"hljs-${cls}\">${hl_span("keyword", code, i, w)}${hl_def_html(code, n, w, w, d == 2)}"
        } else if (c == 58) {
          let c1 = hl_c1(code, i);
          if (c1 == 58) {
            hl_text(code, i, code.next(code.next(i)))
          } else if (!hl_is_space(c1)) {
            hl_symbol_parts_html(code, n, code.next(i), "<span class=\"hljs-symbol\">:")
          } else {
            hl_token_html(code, n, i, c)
          }
        } else {
          hl_token_html(code, n, i, c)
        }
      }
    }

## One-token modes: key:, Module, number, @attr, in that order

    let hl_is_title(code: String, n: StringIndex, i: StringIndex, c: Int): Boolean {
      if (!hl_is_upper(c)) {
        false
      } else if (!hl_boundary(code, i)) {
        false
      } else {
        hl_is_word(hl_c1(code, i))
      }
    }

    let hl_token_end(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      let k = hl_key_symbol_end(code, n, i, c);
      if (k > i) {
        k
      } else if (hl_is_title(code, n, i, c)) {
        hl_word_run(code, n, code.next(i))
      } else {
        let m = hl_number_end(code, n, i, c);
        if (m > i) { m } else { hl_variable_end(code, n, i, c) }
      }
    }

    let hl_token_html(code: String, n: StringIndex, i: StringIndex, c: Int): String {
      let k = hl_key_symbol_end(code, n, i, c);
      if (k > i) {
        hl_span("symbol", code, i, k)
      } else if (hl_is_title(code, n, i, c)) {
        hl_span("title class_", code, i, hl_word_run(code, n, code.next(i)))
      } else {
        let m = hl_number_end(code, n, i, c);
        if (m > i) { hl_span("number", code, i, m) } else { hl_span("variable", code, i, hl_variable_end(code, n, i, c)) }
      }
    }

ELIXIR_IDENT_RE + `:(?!:)`. Not anchored to a word start, like hljs.

    let hl_key_symbol_end(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      if (hl_is_ident_start(c)) {
        let e = hl_ident_end(code, n, i);
        if (hl_c(code, e) != 58) { i } else if (hl_c1(code, e) == 58) { i } else { code.next(e) }
      } else {
        i
      }
    }

`(\b0o[0-7_]+)|(\b0b[01_]+)|(\b0x[0-9a-fA-F_]+)|(-?\b[0-9][0-9_]*(\.[0-9_]+([eE][-+]?[0-9]+)?)?)`

    let hl_number_end(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      if (c == 45) {
        if (hl_is_digit(hl_c1(code, i))) { hl_decimal_end(code, n, code.next(i)) } else { i }
      } else if (!hl_is_digit(c)) {
        i
      } else if (!hl_boundary(code, i)) {
        i
      } else {
        let p = hl_radix_end(code, n, i);
        if (p > i) { p } else { hl_decimal_end(code, n, i) }
      }
    }

    let hl_radix_end(code: String, n: StringIndex, i: StringIndex): StringIndex {
      if (code[i] == 48) {
        let x = hl_c1(code, i);
        let d = code.next(code.next(i));
        let e = hl_radix_run(code, n, d, x);
        if (e > d) { e } else { i }
      } else {
        i
      }
    }

Digits allowed after 0o, 0b, 0x (x is the letter's code), plus "_".

    let hl_radix_ok(c: Int, x: Int): Boolean {
      if (c == 95) {
        true
      } else if (x == 111) {
        c >= 48 && c <= 55
      } else if (x == 98) {
        c == 48 || c == 49
      } else if (x == 120) {
        if (hl_is_digit(c)) { true } else if (c >= 97 && c <= 102) { true } else { c >= 65 && c <= 70 }
      } else {
        false
      }
    }

    let hl_radix_run(code: String, n: StringIndex, i: StringIndex, x: Int): StringIndex {
      if (i >= n) { i } else if (hl_radix_ok(code[i], x)) { hl_radix_run(code, n, code.next(i), x) } else { i }
    }

    let hl_digits_(code: String, n: StringIndex, i: StringIndex): StringIndex {
      if (i < n) {
        let c = code[i];
        if (hl_is_digit(c)) { hl_digits_(code, n, code.next(i)) } else if (c == 95) { hl_digits_(code, n, code.next(i)) } else { i }
      } else {
        i
      }
    }

    let hl_digits(code: String, n: StringIndex, i: StringIndex): StringIndex {
      if (i >= n) { i } else if (hl_is_digit(code[i])) { hl_digits(code, n, code.next(i)) } else { i }
    }

`[0-9][0-9_]*(\.[0-9_]+([eE][-+]?[0-9]+)?)?` from a digit at i.

    let hl_decimal_end(code: String, n: StringIndex, i: StringIndex): StringIndex {
      let e = hl_digits_(code, n, code.next(i));
      if (hl_c(code, e) != 46) {
        e
      } else {
        let f0 = code.next(e);
        let f = hl_digits_(code, n, f0);
        if (f <= f0) {
          e
        } else {
          let x = hl_c(code, f);
          if (x == 101 || x == 69) {
            let sgn = hl_c1(code, f);
            let d = if (sgn == 43 || sgn == 45) { code.next(code.next(f)) } else { code.next(f) };
            let g = hl_digits(code, n, d);
            if (g > d) { g } else { f }
          } else {
            f
          }
        }
      }
    }

`(\$\W)|((\$|@@?)(\w+))`; i when neither.

    let hl_variable_end(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      let i1 = code.next(i);
      let c1 = hl_c(code, i1);
      if (c == 36) {
        if (i1 < n && !hl_is_word(c1)) { hl_next_to(code, n, i1) } else { hl_word_run_1(code, n, i1, i) }
      } else if (c == 64) {
        if (c1 == 64 && hl_is_word(hl_c1(code, i1))) {
          hl_word_run(code, n, code.next(i1))
        } else {
          hl_word_run_1(code, n, i1, i)
        }
      } else {
        i
      }
    }

`\w+` from i: its end, or `none` when there is not one word character.

    let hl_word_run_1(code: String, n: StringIndex, i: StringIndex, none: StringIndex): StringIndex {
      if (hl_is_word(hl_c(code, i))) { hl_word_run(code, n, i) } else { none }
    }

## Strings

The STRING mode's variants, in order, or 0: 1 `"""`, 2 `"`, 3 `'''`, 4 `'`,
and 5 to 8 the same after `~S`. The `~S` forms have no escapes and no
interpolation; the others have both.

    let hl_string_variant(code: String, i: StringIndex): Int {
      let c = hl_c(code, i);
      if (c == 34) {
        if (hl_at(code, i, "\"\"\"")) { 1 } else { 2 }
      } else if (c == 39) {
        if (hl_at(code, i, "'''")) { 3 } else { 4 }
      } else if (c == 126) {
        if (hl_at(code, i, "~S\"\"\"")) {
          5
        } else if (hl_at(code, i, "~S\"")) {
          6
        } else if (hl_at(code, i, "~S'''")) {
          7
        } else if (hl_at(code, i, "~S'")) {
          8
        } else {
          0
        }
      } else {
        0
      }
    }

    let hl_string_open(v: Int): String {
      if (v == 1) {
        "\"\"\""
      } else if (v == 2) {
        "\""
      } else if (v == 3) {
        "'''"
      } else if (v == 4) {
        "'"
      } else if (v == 5) {
        "~S\"\"\""
      } else if (v == 6) {
        "~S\""
      } else if (v == 7) {
        "~S'''"
      } else {
        "~S'"
      }
    }

    let hl_string_close(v: Int): String {
      if (v == 1 || v == 5) {
        "\"\"\""
      } else if (v == 2 || v == 6) {
        "\""
      } else if (v == 3 || v == 7) {
        "'''"
      } else {
        "'"
      }
    }

Escape style `esc` for `hl_delim_*`: 0 backslash is ordinary; 1 backslash and
one character are consumed with no span (hljs.BACKSLASH_ESCAPE has no scope);
2 backslash and one character are an `hljs-char escape_` span; 3 backslash and
the closer are one.

    let hl_string_end(code: String, n: StringIndex, i: StringIndex, v: Int): StringIndex {
      let j = hl_at_end(code, i, hl_string_open(v));
      if (v >= 5) {
        hl_delim_end(code, n, j, hl_string_close(v), 0, false)
      } else {
        hl_delim_end(code, n, j, hl_string_close(v), 1, true)
      }
    }

    let hl_string_html(code: String, n: StringIndex, i: StringIndex, v: Int): String {
      let j = hl_at_end(code, i, hl_string_open(v));
      let head = "<span class=\"hljs-string\">${hl_text(code, i, j)}";
      if (v >= 5) {
        "${hl_delim_html(code, n, j, j, hl_string_close(v), 0, false, head)}</span>"
      } else {
        "${hl_delim_html(code, n, j, j, hl_string_close(v), 1, true, head)}</span>"
      }
    }

The inside of a string or sigil, from i up to and including `close`, or to
the end of input when it never closes. `run` is where pending text starts.
The string `#{` is written in two halves because Blimp reads it, in a string
literal, as the start of an interpolation.

    let hl_is_subst(code: String, i: StringIndex, c: Int): Boolean {
      if (c == 35) { hl_c1(code, i) == 123 } else { false }
    }

What the character at i does inside a delimited run: 1 an escape, 2 an
interpolation, 0 neither. One test in the loop rather than a chain of `&&`,
which the backend turns into temporaries.

    let hl_delim_what(code: String, n: StringIndex, i: StringIndex, i1: StringIndex, c: Int, esc: Int, subst: Boolean): Int {
      if (c > 92) {
        0
      } else if (c == 92) {
        if (esc == 0) { 0 } else if (i1 < n) { 1 } else { 0 }
      } else if (c == 35) {
        if (!subst) { 0 } else if (hl_c(code, i1) == 123) { 2 } else { 0 }
      } else {
        0
      }
    }

    let hl_delim_end(code: String, n: StringIndex, i: StringIndex, close: String, esc: Int, subst: Boolean): StringIndex {
      if (i >= n) {
        n
      } else {
        let c = code[i];
        let i1 = code.next(i);
        let what = hl_delim_what(code, n, i, i1, c, esc, subst);
        if (what == 1) {
          if (esc == 1) {
            hl_delim_end(code, n, code.next(i1), close, esc, subst)
          } else if (esc == 2) {
            hl_delim_end(code, n, hl_next_to(code, n, i1), close, esc, subst)
          } else {
            let e = hl_at_end(code, i1, close);
            if (e > i1) { hl_delim_end(code, n, e, close, esc, subst) } else { hl_delim_end(code, n, i1, close, esc, subst) }
          }
        } else if (what == 2) {
          hl_delim_end(code, n, hl_default_end(code, n, code.next(i1), true), close, esc, subst)
        } else {
          if (c != close[String.begin]) {
            hl_delim_end(code, n, i1, close, esc, subst)
          } else {
            let e = hl_at_end(code, i, close);
            if (e > i) { e } else { hl_delim_end(code, n, i1, close, esc, subst) }
          }
        }
      }
    }

    let hl_delim_html(code: String, n: StringIndex, i: StringIndex, run: StringIndex, close: String, esc: Int, subst: Boolean, out: String): String {
      if (i >= n) {
        "${out}${hl_text(code, run, n)}"
      } else {
        let c = code[i];
        let i1 = code.next(i);
        let what = hl_delim_what(code, n, i, i1, c, esc, subst);
        if (what == 1) {
          if (esc == 1) {
            hl_delim_html(code, n, code.next(i1), run, close, esc, subst, out)
          } else if (esc == 2) {
            let e = hl_next_to(code, n, i1);
            hl_delim_html(code, n, e, e, close, esc, subst, "${out}${hl_text(code, run, i)}${hl_span("char escape_", code, i, e)}")
          } else {
            let e = hl_at_end(code, i1, close);
            if (e > i1) {
              hl_delim_html(code, n, e, e, close, esc, subst, "${out}${hl_text(code, run, i)}${hl_span("char escape_", code, i, e)}")
            } else {
              hl_delim_html(code, n, i1, run, close, esc, subst, out)
            }
          }
        } else if (what == 2) {
          let b = code.next(i1);
          let inner = hl_default_html(code, n, b, b, "", true);
          let e = hl_default_end(code, n, b, true);
          hl_delim_html(code, n, e, e, close, esc, subst, "${out}${hl_text(code, run, i)}<span class=\"hljs-subst\">#${"{"}${inner}</span>")
        } else {
          if (c != close[String.begin]) {
            hl_delim_html(code, n, i1, run, close, esc, subst, out)
          } else {
            let e = hl_at_end(code, i, close);
            if (e > i) { "${out}${hl_text(code, run, e)}" } else { hl_delim_html(code, n, i1, run, close, esc, subst, out) }
          }
        }
      }
    }

## Sigils

`~x` followed by a delimiter. The kind, or 0: 1 `~r`, 2 `~R`, 3 another
uppercase sigil, 4 another lowercase one. Lowercase sigils (and `~r`) take
escapes as spans and interpolate; uppercase ones only escape their own
closer. Regex sigils also take up to seven modifier letters after the closer.

In hljs the sigil is a wrapper mode whose delimited sections are sub-modes
and whose own end is empty. Sub-modes are tried before the end, so a
delimiter straight after a closer opens another section in the same span:
`~H"""` is `~H""` followed by a section running to the next `"`.

    let hl_sigil_close(c: Int): String {
      if (c == 47) {
        "/"
      } else if (c == 124) {
        "|"
      } else if (c == 40) {
        ")"
      } else if (c == 91) {
        "]"
      } else if (c == 123) {
        "}"
      } else if (c == 60) {
        ">"
      } else if (c == 34) {
        "\""
      } else if (c == 39) {
        "'"
      } else {
        ""
      }
    }

    let hl_sigil_kind(code: String, i: StringIndex): Int {
      let i1 = code.next(i);
      let k = hl_c(code, i1);
      if (hl_sigil_close(hl_c1(code, i1)) == "") {
        0
      } else if (k == 114) {
        1
      } else if (k == 82) {
        2
      } else if (hl_is_upper(k)) {
        3
      } else if (hl_is_lower(k)) {
        4
      } else {
        0
      }
    }

    let hl_sigil_lower(k: Int): Boolean { k == 1 || k == 4 }

    let hl_sigil_esc(k: Int): Int { if (hl_sigil_lower(k)) { 2 } else { 3 } }

    let hl_sigil_after(code: String, n: StringIndex, e: StringIndex, k: Int): StringIndex {
      if (k <= 2) { hl_modifiers(code, n, e, 0) } else { e }
    }

    let hl_sigil_parts_end(code: String, n: StringIndex, j: StringIndex, k: Int): StringIndex {
      let close = hl_sigil_close(hl_c(code, j));
      if (j >= n || close == "") {
        j
      } else {
        let e = hl_delim_end(code, n, code.next(j), close, hl_sigil_esc(k), hl_sigil_lower(k));
        hl_sigil_parts_end(code, n, hl_sigil_after(code, n, e, k), k)
      }
    }

    let hl_sigil_parts_html(code: String, n: StringIndex, j: StringIndex, k: Int, out: String): String {
      let close = hl_sigil_close(hl_c(code, j));
      if (j >= n || close == "") {
        "${out}</span>"
      } else {
        let j1 = code.next(j);
        let body = hl_delim_html(code, n, j1, j1, close, hl_sigil_esc(k), hl_sigil_lower(k), "");
        let e = hl_delim_end(code, n, j1, close, hl_sigil_esc(k), hl_sigil_lower(k));
        let m = hl_sigil_after(code, n, e, k);
        hl_sigil_parts_html(code, n, m, k, "${out}${hl_text(code, j, j1)}${body}${hl_text(code, e, m)}")
      }
    }

`[uismxfU]{0,7}`

    let hl_modifiers(code: String, n: StringIndex, i: StringIndex, k: Int): StringIndex {
      if (k >= 7) {
        i
      } else if (i < n) {
        let c = code[i];
        if (c == 117 || c == 105 || c == 115 || c == 109 || c == 120 || c == 102 || c == 85) {
          hl_modifiers(code, n, code.next(i), k + 1)
        } else {
          i
        }
      } else {
        i
      }
    }

## Symbols

":" then strings and operator/names, as many as follow each other directly.
Like a sigil, the symbol mode's end is empty and its sub-modes are tried
first, so `:"a"b` is one symbol.

    let hl_symbol_parts_end(code: String, n: StringIndex, j: StringIndex): StringIndex {
      let v = hl_string_variant(code, j);
      if (v > 0) {
        hl_symbol_parts_end(code, n, hl_string_end(code, n, j, v))
      } else {
        let e = hl_method_end(code, n, j);
        if (e > j) { hl_symbol_parts_end(code, n, e) } else { j }
      }
    }

    let hl_symbol_parts_html(code: String, n: StringIndex, j: StringIndex, out: String): String {
      let v = hl_string_variant(code, j);
      if (v > 0) {
        hl_symbol_parts_html(code, n, hl_string_end(code, n, j, v), "${out}${hl_string_html(code, n, j, v)}")
      } else {
        let e = hl_method_end(code, n, j);
        if (e > j) { hl_symbol_parts_html(code, n, e, "${out}${hl_text(code, j, e)}") } else { "${out}</span>" }
      }
    }

ELIXIR_METHOD_RE, first alternative that matches (JS alternation, not
longest match): ``[a-zA-Z_]\w*[!?=]?|[-+~]@|<<|>>|=~|===?|<=>|[<>]=?|\*\*|[-/+%^&*~`|]|\[\]=?``.
It answers i when nothing matches.

    let hl_method_end(code: String, n: StringIndex, i: StringIndex): StringIndex {
      let c = hl_c(code, i);
      if (hl_is_ident_start(c)) {
        let e = hl_word_run(code, n, code.next(i));
        if (e < n) {
          let t = code[e];
          if (t == 33 || t == 63 || t == 61) { code.next(e) } else { e }
        } else {
          e
        }
      } else if (c == 45 || c == 43 || c == 126) {
        if (hl_c1(code, i) == 64) { code.next(code.next(i)) } else { hl_method_ops(code, n, i, c) }
      } else {
        hl_method_ops(code, n, i, c)
      }
    }

    let hl_first_end(code: String, i: StringIndex, a: String, b: String): StringIndex {
      let e = hl_at_end(code, i, a);
      if (e > i) { e } else { hl_at_end(code, i, b) }
    }

    let hl_method_ops(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      let e = hl_first_end(code, i, "<<", ">>");
      if (e > i) {
        e
      } else {
        let e2 = hl_first_end(code, i, "=~", "===");
        if (e2 > i) {
          e2
        } else {
          let e3 = hl_first_end(code, i, "==", "<=>");
          if (e3 > i) { e3 } else { hl_method_ops2(code, n, i, c) }
        }
      }
    }

    let hl_is_op(c: Int): Boolean {
      c == 45 || c == 47 || c == 43 || c == 37 || c == 94 || c == 38 || c == 42 || c == 126 || c == 96 || c == 124
    }

    let hl_method_ops2(code: String, n: StringIndex, i: StringIndex, c: Int): StringIndex {
      if (c == 60 || c == 62) {
        let i1 = code.next(i);
        if (hl_c(code, i1) == 61) { code.next(i1) } else { i1 }
      } else {
        let e = hl_at_end(code, i, "**");
        if (e > i) {
          e
        } else if (hl_is_op(c) && i < n) {
          code.next(i)
        } else {
          hl_first_end(code, i, "[]=", "[]")
        }
      }
    }

## Comments: "#" to the end of the line, with doctags

JS "$" in multiline mode stops before \n and before \r.

    let hl_line_end(code: String, n: StringIndex, i: StringIndex): StringIndex {
      if (i >= n) {
        i
      } else {
        let c = code[i];
        if (c == 10 || c == 13) { i } else { hl_line_end(code, n, code.next(i)) }
      }
    }

    let hl_doctags(code: String, j: StringIndex, e: StringIndex, run: StringIndex, out: String): String {
      if (j >= e) {
        "${out}${hl_text(code, run, e)}"
      } else {
        let t = hl_doctag_end(code, j, e);
        if (t > j) {
          hl_doctags(code, t, e, t, "${out}${hl_text(code, run, j)}${hl_span("doctag", code, j, t)}")
        } else {
          hl_doctags(code, code.next(j), e, run, out)
        }
      }
    }

The first tag that matches at j (none is a prefix of another), if it ends by
e; j otherwise. The first letter picks the tag.

    let hl_doctag_end(code: String, j: StringIndex, e: StringIndex): StringIndex {
      let c = code[j];
      let t = if (c == 84) {
        hl_at_end(code, j, "TODO:")
      } else if (c == 70) {
        hl_at_end(code, j, "FIXME:")
      } else if (c == 78) {
        hl_at_end(code, j, "NOTE:")
      } else if (c == 66) {
        hl_at_end(code, j, "BUG:")
      } else if (c == 79) {
        hl_at_end(code, j, "OPTIMIZE:")
      } else if (c == 72) {
        hl_at_end(code, j, "HACK:")
      } else if (c == 88) {
        hl_at_end(code, j, "XXX:")
      } else {
        j
      };
      if (t <= e) { t } else { j }
    }

## def / defmodule and friends: hljs "beginKeywords" modes

The word at i when it is one of the def-like words: whole word, not after a
".", not followed by a ".". 1 for `hljs-function`, 2 for `hljs-class`, or 0.

    let hl_def_kind(code: String, n: StringIndex, i: StringIndex): Int {
      if (code[i] != 100) {
        0
      } else if (!hl_boundary(code, i)) {
        0
      } else if (hl_before(code, i) == 46) {
        0
      } else {
        let e = hl_word_run(code, n, i);
        if (hl_c(code, e) == 46) {
          0
        } else {
          let w = code.slice(i, e);
          if (w == "def") {
            1
          } else if (w == "defp") {
            1
          } else if (w == "defmacro") {
            1
          } else if (w == "defmacrop") {
            1
          } else if (w == "defmodule") {
            2
          } else if (w == "defimpl") {
            2
          } else if (w == "defprotocol") {
            2
          } else if (w == "defrecord") {
            2
          } else {
            0
          }
        }
      }
    }

`<span class="hljs-function"><span class="hljs-keyword">def</span> <span
class="hljs-title">name</span></span>`. The title ends the outer mode. A
function mode only ends at its title; a class mode also ends at the end of
the line or a ";". `_html` is everything after the keyword, the outer
`</span>` included.

    let hl_def_end(code: String, n: StringIndex, i: StringIndex, is_class: Boolean): StringIndex {
      if (i >= n) {
        n
      } else {
        let c = code[i];
        if (hl_is_ident_start(c)) {
          hl_ident_end(code, n, i)
        } else if (is_class && (c == 10 || c == 13)) {
          i
        } else if (is_class && c == 59) {
          code.next(i)
        } else {
          hl_def_end(code, n, code.next(i), is_class)
        }
      }
    }

    let hl_def_html(code: String, n: StringIndex, i: StringIndex, run: StringIndex, is_class: Boolean): String {
      if (i >= n) {
        "${hl_text(code, run, n)}</span>"
      } else {
        let c = code[i];
        if (hl_is_ident_start(c)) {
          "${hl_text(code, run, i)}${hl_span("title", code, i, hl_ident_end(code, n, i))}</span>"
        } else if (is_class && (c == 10 || c == 13)) {
          "${hl_text(code, run, i)}</span>"
        } else if (is_class && c == 59) {
          "${hl_text(code, run, code.next(i))}</span>"
        } else {
          hl_def_html(code, n, code.next(i), run, is_class)
        }
      }
    }

## The entry point

    export let highlight(lang: String, code: String): String {
      if (lang == "elixir" || lang == "ex" || lang == "exs") {
        hl_default_html(code, code.end, String.begin, String.begin, "", false)
      } else {
        escape_html(code)
      }
    }

## A theme for the classes above, scoped to .hljs-*

Code blocks on the post page sit on a dark #1f2937 with #e5e7eb text
(assets/post.css), so these are colours for a dark background.

    export let highlight_css(): String {
      ".hljs-keyword, .hljs-literal { color: #93c5fd; font-weight: bold; }\n.hljs-string { color: #fca5a5; }\n.hljs-subst { color: #e5e7eb; }\n.hljs-char.escape_ { color: #fdba74; }\n.hljs-regex { color: #fdba74; }\n.hljs-comment { color: #9ca3af; font-style: italic; }\n.hljs-doctag { font-weight: bold; }\n.hljs-symbol { color: #d8b4fe; }\n.hljs-number { color: #5eead4; }\n.hljs-title { color: #fde68a; }\n.hljs-title.class_ { color: #86efac; }\n.hljs-variable { color: #fcd34d; }"
    }

## Lines

The markdown renderer wraps each line of a code block in `<span
class="line" data-line="N">`, as MDEx does. A string or a heredoc can span
lines, so its hljs span has to be closed at the end of each line and opened
again at the start of the next, or the line spans would nest inside it.
`highlight_lines` does that and returns one balanced string per line.

The input is `highlight()`'s output: text is escaped, so every "<" starts a
tag, and the only tags are `<span class="...">` and `</span>`. The tags open
at the end of a line are kept as one string, outermost first, which is
exactly what the next line reopens with. The finished lines are joined with
"\n" as they go (no line contains one) and split once at the end, so no list
grows an item at a time.

    export let highlight_lines(lang: String, code: String): List<String> {
      let html = highlight(lang, code);
      let lines = html.split("\n");
      if (html.split("<").length == 1) {
        lines
      } else {
        hl_lines_from(lines, 0, "", "", "").split("\n")
      }
    }

Only Elixir has tags, so the other languages are split and done: going line
by line costs a list index, a length and an `Int` overflow check per line,
each a call into temper-core.

`closes` is one `</span>` per tag in `open`. A line with no tag in it (every
line of a block in any language but Elixir) keeps both.

    let hl_lines_from(lines: List<String>, k: Int, open: String, closes: String, out: String): String {
      if (k >= lines.length) {
        out
      } else {
        let line = lines[k];
        let pieces = line.split("<");
        if (pieces.length == 1) {
          hl_lines_from(lines, k + 1, open, closes, hl_add_line(out, k, "${open}${line}${closes}"))
        } else if (open == "" && hl_balanced(line)) {
          hl_lines_from(lines, k + 1, "", "", hl_add_line(out, k, line))
        } else {
          let after = hl_track(pieces, 1, open);
          let shut = repeat("</span>", after.split("<").length - 1);
          hl_lines_from(lines, k + 1, after, shut, hl_add_line(out, k, "${open}${line}${shut}"))
        }
      }
    }

A line that opens as many spans as it closes, with none open before it,
leaves none open after it: most lines, which then need no walk.

    let hl_balanced(line: String): Boolean {
      line.split("<span").length == line.split("</span>").length
    }

    let hl_add_line(out: String, k: Int, line: String): String {
      if (k == 0) { line } else { "${out}\n${line}" }
    }

Each piece is the text after a "<": `span class=...>...` or `/span>...`.

    let hl_track(pieces: List<String>, k: Int, open: String): String {
      if (k >= pieces.length) {
        open
      } else {
        let p = pieces[k];
        if (p[String.begin] == 47) {
          hl_track(pieces, k + 1, hl_pop(open))
        } else {
          hl_track(pieces, k + 1, "${open}<${p.split(">")[0]}>")
        }
      }
    }

The open tags without the innermost: every tag starts with "<" and has no
other.

    let hl_pop(open: String): String {
      let parts = open.split("<");
      parts.slice(0, parts.length - 1).join("<") { (part): String => part }
    }
