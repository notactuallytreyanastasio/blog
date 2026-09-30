# Text

The string and list helpers the rest of the site is written against. This was
`src/00_text.blimp`; every name it exported is exported here under the same
name, so no call site changed.

## Byte offsets

The site counts strings in bytes: Blimp's `length`, `slice` and `index_of` all
do. Temper does not let a program count in bytes. A position in a string is a
`StringIndex`, which a program gets from the string (`String.begin`, `s.end`,
`s.indexOf`, `s.next`) and cannot make out of an `Int`. On the Blimp backend a
`StringIndex` *is* the byte offset, an `Int`, so a function that takes one
here takes the byte offsets the Blimp callers already pass, and a function
that answers one answers a byte offset.

So `take`, `drop` and `index_of_from` take a `StringIndex`. A Temper caller
passes one it got from the string; a Blimp caller passes an `Int`, as it
always has. The two agree because the backend makes them the same thing.

What does not carry over is arithmetic. `ends_with` in Blimp was
`slice(s, n - m, m) == suffix`; Temper has no `s.end - suffix.end`. It walks
back one code point at a time from both ends instead, which is a loop where
there was a builtin, but a loop as long as the suffix, and every suffix the
site asks about is a file extension or a slash.

    export let replace_all(s: String, find: String, with: String): String {
      s.split(find).join(with) { (piece): String => piece }
    }

    export let starts_with(s: String, prefix: String): Boolean {
      s.end >= prefix.end && s.slice(String.begin, prefix.end) == prefix
    }

    export let ends_with(s: String, suffix: String): Boolean {
      ends_back(s, s.end, suffix, suffix.end)
    }

    let ends_back(s: String, i: StringIndex, suffix: String, j: StringIndex): Boolean {
      if (j <= String.begin) {
        true
      } else if (i <= String.begin) {
        false
      } else {
        let pi = s.prev(i);
        let pj = suffix.prev(j);
        if (s[pi] == suffix[pj]) { ends_back(s, pi, suffix, pj) } else { false }
      }
    }

The first `find` at or after `from`, or -1. temper-core answers this with the
interpreter's `index_of` over the rest of the string, not with a Blimp loop:
the loop is what the site had before, when it took most of a second to find
the last `</body>` of a 200KB page.

    export let index_of_from(s: String, find: String, from: StringIndex): StringIndexOption {
      s.indexOf(find, from)
    }

## Trimming

A space is one of four ASCII characters, so asking for the code point at a
position is exactly as good as asking for the byte there: every byte of a
multi-byte character is 128 or more, and so is the code point it decodes to.

    export let is_space(c: String): Boolean {
      !c.isEmpty && is_space_code(c[String.begin])
    }

    let is_space_code(c: Int): Boolean {
      c == 32 || c == 9 || c == 10 || c == 13
    }

    let trim_left_from(s: String, i: StringIndex): String {
      if (i < s.end) {
        if (is_space_code(s[i])) { trim_left_from(s, s.next(i)) } else { s.slice(i, s.end) }
      } else {
        ""
      }
    }

    let trim_right_to(s: String, n: StringIndex): String {
      if (n > String.begin) {
        let p = s.prev(n);
        if (is_space_code(s[p])) { trim_right_to(s, p) } else { s.slice(String.begin, n) }
      } else {
        ""
      }
    }

    export let trim_left(s: String): String { trim_left_from(s, String.begin) }

    export let trim_right(s: String): String { trim_right_to(s, s.end) }

    export let trim(s: String): String { trim_right(trim_left(s)) }

## Cutting

    export let drop(s: String, n: StringIndex): String {
      if (n >= s.end) { "" } else { s.slice(n, s.end) }
    }

    export let take(s: String, n: StringIndex): String {
      if (n >= s.end) { s } else { s.slice(String.begin, n) }
    }

Only an ASCII letter changes, which is what Blimp's `upcase` of the first
byte did too. The capital is cut out of an alphabet rather than made with
`String.fromCodePoint`, which can fail and so brings temper-core's bubble,
panic and UTF-8 encoder into every program that uses this: five more
top-level names, and every top-level name costs the interpreter time on each
closure it makes.

    export let capitalize(word: String): String {
      if (word.isEmpty) {
        ""
      } else {
        let c = word[String.begin];
        if (c < 97 || c > 122) {
          word
        } else {
          let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
          let at = upper.step(String.begin, c - 97);
          "${upper.slice(at, upper.next(at))}${word.slice(word.next(String.begin), word.end)}"
        }
      }
    }

The five characters that change meaning in HTML text or a quoted attribute.
`&` goes first, or it would escape the other four's escapes.

Each is written out as a split and a join rather than as `replace_all`. The
backend makes `s.split("&").join("&amp;") { (piece) => piece }`, with a
literal separator and the identity, into Blimp's own `join(split(s, "&"),
"&amp;")`, where `replace_all` has to go through temper-core for a separator
that might be "". /mirror escapes its page one character at a time, and the
call per escape was most of what it cost.

    export let escape_html(s: String): String {
      let s1 = s.split("&").join("&amp;") { (piece): String => piece };
      let s2 = s1.split("<").join("&lt;") { (piece): String => piece };
      let s3 = s2.split(">").join("&gt;") { (piece): String => piece };
      let s4 = s3.split("\"").join("&quot;") { (piece): String => piece };
      s4.split("'").join("&#39;") { (piece): String => piece }
    }

    export let repeat(s: String, n: Int): String { repeat_into(s, n, "") }

    let repeat_into(s: String, n: Int, acc: String): String {
      if (n <= 0) { acc } else { repeat_into(s, n - 1, "${acc}${s}") }
    }

    export let is_digit(c: String): Boolean {
      let code = c[String.begin];
      code >= 48 && code <= 57
    }

`is_alnum` is a chain of ifs rather than `(a && b) || (c && d) || ...`: an
`&&` that is not the last thing in its branch comes out of the backend as a
temporary and a one-element list per test, and the Markdown renderer asks
this about one character at a time.

    export let is_alnum(c: String): Boolean {
      let code = c[String.begin];
      if (code < 48) {
        false
      } else if (code <= 57) {
        true
      } else if (code < 65) {
        false
      } else if (code <= 90) {
        true
      } else if (code < 97) {
        false
      } else {
        code <= 122
      }
    }

## Lists

`list[i]` is the interpreter's `elem`, one step, where the Blimp version
walked `i` tails to it.

    export let elem_at<T>(list: List<T>, i: Int): T { list[i] }

    export let drop_list<T>(list: List<T>, n: Int): List<T> { list.slice(n, list.length) }

    export let last<T>(list: List<T>): T { list[list.length - 1] }
