# The camera sweep

What `Blog.CameraBrowser.poll/1` decides rather than looks up, for the
sweep in `src/99_camera_sweep.blimp`: the search URL
(`Craigslist.search/3`), what a search item's location string, image ids
and link mean (`decode_items/2`), everything `parse_post/1` reads out of a
post page, the phone numbers and emails `extract_contact/1` finds in its
body, `classify/5`'s tags and score, and the analyst's prompt.

The Phoenix code reads the page with Floki and finds the contact details
with regexes. There is neither here, so each is written out for exactly
the page, selector or pattern it is used on, and checked against the
Elixir's own answers for every page in `test/fixtures/cameras/sweep/`
(`test/camera_sweep_test.blimp`). Where Floki's behaviour decides the
answer it is named below: its parser (mochiweb's) drops text that is only
spaces, tabs and newlines, `Floki.text/2` puts `sep` between text nodes
and a newline for every `<br>`, and leaves `<script>` out.

A post page crosses to Blimp as one JSON document (`cam_post_json`), which
the sweep reads with `json_decode`: a Temper list only grows through
`ListBuilder`, an actor this backend never collects, and a string does not.

As in `cameras.temper.md`: a missing string is "", a missing number -1,
and every name starts `cam_`. Byte offsets (`StringIndex`) never leave
Temper.

## Searching

`Craigslist.areas/0`: the number the API wants for each area.

    export let cam_area_id(area: String): Int {
      if (area == "sfbay") { 1 } else if (area == "seattle") { 2 } else if (area == "newyork") { 3 } else if (area == "portland") { 9 } else { -1 }
    }

`search/3`'s request, with `@search_opts` (by owner, with photos, $100
and up) as every search of the sweep passes them. Req writes `params:`
with `URI.encode_query/1`, in the keyword list's order: a space is `+`
(`cam_enc`, `URI.encode_www_form/1`).

    export let cam_search_url(area_id: Int, query: String): String {
      "https://sapi.craigslist.org/web/v8/postings/search/full?batch=${area_id.toString()}-0-360-0-0&cc=US&lang=en&query=${cam_enc(query)}&searchPath=sss&sort=date&hasPic=1&purveyor=owner&min_price=100"
    }

## A search item

An item's fifth element is its location, "sub:loc[:hood]~lat~lng" or just
"sub:loc[:hood]" (`parse_loc/1`). Anything that is not one or three
`~`-separated parts has no indexes and no coordinates.

    let cam_tilde_parts(loc: String): Int {
      let t1 = loc.indexOf("~");
      if (t1 is StringIndex) {
        let t2 = loc.indexOf("~", loc.next(t1));
        if (t2 is StringIndex) {
          let t3 = loc.indexOf("~", loc.next(t2));
          if (t3 is StringIndex) { 4 } else { 3 }
        } else { 2 }
      } else { 1 }
    }

The `n`th part of `s` split on the one-character `sep`, "" past the last.

    let cam_part(s: String, sep: String, i: StringIndex, n: Int): String {
      let found = s.indexOf(sep, i);
      if (n <= 0) {
        if (found is StringIndex) { s.slice(i, found) } else { s.slice(i, s.end) }
      } else if (found is StringIndex) {
        cam_part(s, sep, s.next(found), n - 1)
      } else {
        ""
      }
    }

`Enum.at(ints, n)` of the `:`-separated indexes, each read with
`Integer.parse/1` (a sign, then the leading digits). -1 when there is no
such part or it does not start with a number. A negative index would be
counted from the end by `Enum.at`; Craigslist sends none, and here it is
-1 too.

    export let cam_loc_index(loc: String, n: Int): Int {
      let parts = cam_tilde_parts(loc);
      let idxs = if (parts == 1) { loc } else if (parts == 3) { cam_part(loc, "~", String.begin, 0) } else { "" };
      let p = cam_part(idxs, ":", String.begin, n);
      if (p.isEmpty) {
        -1
      } else {
        let c = p[String.begin];
        if (c == 45) { -1 } else {
          let start = if (c == 43) { p.next(String.begin) } else { String.begin };
          cam_digits(p, start, 0, 0)
        }
      }
    }

The latitude (`n` = 1) or longitude (2), as the text `Float.parse/1`
reads: "" when there is none. The sweep hands Postgres this text for a
float8 column, which reads it to the same double Elixir's parse makes.

    export let cam_loc_coord(loc: String, n: Int): String {
      if (cam_tilde_parts(loc) == 3) { cam_float_text(cam_part(loc, "~", String.begin, n)) } else { "" }
    }

`Float.parse/1`'s prefix: a sign, digits, then `.digits` and an exponent
if they are whole. ".5" and " 1" are not numbers; "1." is 1.

    export let cam_float_text(s: String): String {
      if (s.isEmpty) {
        ""
      } else {
        let c = s[String.begin];
        let a = if (c == 43 || c == 45) { s.next(String.begin) } else { String.begin };
        let b = cam_digit_run(s, a);
        if (b <= a) { "" } else { s.slice(String.begin, cam_exponent(s, cam_fraction(s, b))) }
      }
    }

    let cam_digit(c: Int): Boolean { c >= 48 && c <= 57 }

    let cam_digit_run(s: String, i: StringIndex): StringIndex {
      if (i < s.end && cam_digit(s[i])) { cam_digit_run(s, s.next(i)) } else { i }
    }

    let cam_fraction(s: String, i: StringIndex): StringIndex {
      if (i < s.end && s[i] == 46) {
        let j = s.next(i);
        let k = cam_digit_run(s, j);
        if (k > j) { k } else { i }
      } else {
        i
      }
    }

    let cam_exponent(s: String, i: StringIndex): StringIndex {
      if (i < s.end && (s[i] == 101 || s[i] == 69)) {
        let j = s.next(i);
        let j2 = if (j < s.end && (s[j] == 43 || s[j] == 45)) { s.next(j) } else { j };
        let k = cam_digit_run(s, j2);
        if (k > j2) { k } else { i }
      } else {
        i
      }
    }

`strip_image_prefix/1`: "3:00a0a_jx892ZIFraf_0CI0qt" is
"00a0a_jx892ZIFraf_0CI0qt"; the width prefix is what the image URLs do
without.

    export let cam_image_short(id: String): String {
      let c = id.indexOf(":");
      if (c is StringIndex) { id.slice(id.next(c), id.end) } else { id }
    }

`post_url/5`. The id is text: a posting id does not fit an `Int`.

    export let cam_post_url(area: String, sub: String, slug: String, id: String, token: String): String {
      if (!token.isEmpty) {
        let s = if (slug.isEmpty) { "post" } else { slug };
        "https://www.craigslist.org/view/d/${s}/${token}"
      } else if (!sub.isEmpty) {
        "https://${area}.craigslist.org/${sub}/sss/${id}.html"
      } else {
        "https://${area}.craigslist.org/${id}.html"
      }
    }

## A post page

`@gone_markers`, looked for in this order, before anything is parsed.

    export let cam_gone_reason(html: String): String {
      if (cam_has(html, "This posting has been deleted by its author")) {
        "deleted"
      } else if (cam_has(html, "This posting has expired")) {
        "expired"
      } else if (cam_has(html, "This posting has been flagged for removal")) {
        "flagged"
      } else if (cam_has(html, "This posting has been removed")) {
        "removed"
      } else {
        ""
      }
    }

    let cam_has(s: String, find: String): Boolean { s.indexOf(find) is StringIndex }

Everything `parse_post/1` answers, as one JSON object with the keys
`gone` (""), `title`, `body`, `attrs` (`[[label, value], ...]`),
`image_ids`, `times`, `lat`, `lng`, `reply_url`, `phones` and `emails`;
or `{"gone": reason}`. "" is nil for the strings. `attrs` keeps every
pair in page order (`Map.new/1` keeps the last of a label); `times` are
the `datetime`s `DateTime.from_iso8601/1` accepts, in page order, cut to
the second as Ecto's `:utc_datetime` cuts them; `lat` and `lng` are the
text `Float.parse/1` reads.

    export let cam_post_json(html: String): String {
      let gone = cam_gone_reason(html);
      if (!gone.isEmpty) {
        "{\"gone\":${cam_json_str(gone)}}"
      } else {
        let title = cam_utrim(cam_texts_with(html, String.begin, "id", "titletextonly", "", ""));
        let body = cam_clean_body(cam_texts_with(html, String.begin, "id", "postingbody", "\n", ""));
        let map_at = cam_find_tag(html, String.begin, html.end, "id", "map");
        let map_gt = cam_tag_gt(html, map_at);
        let lat = if (map_at < html.end) { cam_float_text(cam_attr(html, map_at, map_gt, "data-latitude")) } else { "" };
        let lng = if (map_at < html.end) { cam_float_text(cam_attr(html, map_at, map_gt, "data-longitude")) } else { "" };
        let attrs = cam_attr_groups(html, String.begin, "");
        let times = cam_info_times(html, String.begin, "");
        let images = cam_imgids(html, String.begin, "");
        let reply = cam_replace(cam_reply_url(html, String.begin), "/__SERVICE_ID__", "");
        let phones = cam_phones(body, String.begin, "");
        let emails = cam_emails(body, String.begin, "");
        "{\"gone\":\"\",\"title\":${cam_json_str(title)},\"body\":${cam_json_str(body)},\"attrs\":[${cam_list_body(attrs)}],\"image_ids\":[${cam_list_body(images)}],\"times\":[${cam_list_body(times)}],\"lat\":${cam_json_str(lat)},\"lng\":${cam_json_str(lng)},\"reply_url\":${cam_json_str(reply)},\"phones\":[${cam_list_body(phones)}],\"emails\":[${cam_list_body(emails)}]}"
      }
    }

### Reading the markup

What `<` at `p` starts, as mochiweb's tokenizer sees it: 1 a start tag
(a letter follows), 2 an end tag (`</`), 3 a comment, 4 a doctype or
processing instruction, 0 text (anything else: `a < b` is text).

    let cam_kind(s: String, p: StringIndex): Int {
      let n = s.next(p);
      if (n >= s.end) {
        0
      } else {
        let c = s[n];
        if (c == 47) {
          2
        } else if (c == 33) {
          if (cam_at(s, p, "<!--")) { 3 } else { 4 }
        } else if (c == 63) {
          4
        } else if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
          1
        } else {
          0
        }
      }
    }

Whether `lit` is at `i` in `s`.

    let cam_at(s: String, i: StringIndex, lit: String): Boolean {
      cam_at_from(s, i, lit, String.begin)
    }

    let cam_at_from(s: String, i: StringIndex, lit: String, j: StringIndex): Boolean {
      if (j >= lit.end) { true } else if (i >= s.end) { false } else if (s[i] != lit[j]) { false } else { cam_at_from(s, s.next(i), lit, lit.next(j)) }
    }

Where `s` continues after the `lit` at `i`.

    let cam_past(s: String, i: StringIndex, lit: String, j: StringIndex): StringIndex {
      if (j >= lit.end || i >= s.end) { i } else { cam_past(s, s.next(i), lit, lit.next(j)) }
    }

After the first `find` at or after `i`, or the end.

    let cam_after(s: String, i: StringIndex, find: String): StringIndex {
      let f = s.indexOf(find, i);
      if (f is StringIndex) { cam_past(s, f, find, String.begin) } else { s.end }
    }

The next `<` at or after `i` that starts markup (not text), or `lim`.

    let cam_next_markup(s: String, i: StringIndex, lim: StringIndex): StringIndex {
      let f = s.indexOf("<", i);
      if (f is StringIndex) {
        if (f >= lim) { lim } else if (cam_kind(s, f) != 0) { f } else { cam_next_markup(s, s.next(f), lim) }
      } else {
        lim
      }
    }

Just past the `>` that closes the tag at `p`; a quoted attribute value
may hold a `>`.

    let cam_tag_gt(s: String, p: StringIndex): StringIndex {
      if (p >= s.end) { s.end } else { cam_gt_from(s, s.next(p), 0) }
    }

    let cam_gt_from(s: String, i: StringIndex, quote: Int): StringIndex {
      if (i >= s.end) {
        s.end
      } else {
        let c = s[i];
        if (quote != 0) {
          let q = if (c == quote) { 0 } else { quote };
          cam_gt_from(s, s.next(i), q)
        } else if (c == 62) {
          s.next(i)
        } else if (c == 34 || c == 39) {
          cam_gt_from(s, s.next(i), c)
        } else {
          cam_gt_from(s, s.next(i), 0)
        }
      }
    }

Past whatever markup starts at `p`: a comment, a tag (a `<script>` or
`<style>` with everything up to its end tag), or a doctype.

    let cam_skip_markup(s: String, p: StringIndex): StringIndex {
      let k = cam_kind(s, p);
      if (k == 3) {
        cam_after(s, s.next(p), "-->")
      } else if (k == 1) {
        let name = cam_tag_name(s, s.next(p));
        let gt = cam_tag_gt(s, p);
        if (name == "script" || name == "style") { cam_after(s, cam_after(s, gt, "</${name}"), ">") } else { gt }
      } else {
        cam_after(s, s.next(p), ">")
      }
    }

A tag's name, from the character after `<` (or `</`), lower-cased as
mochiweb does.

    let cam_tag_name(s: String, i: StringIndex): String {
      cam_name_from(s, i, "")
    }

    let cam_name_from(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        if (c >= 65 && c <= 90) {
          cam_name_from(s, s.next(i), "${acc}${String.fromCodePoint(c + 32) orelse panic()}")
        } else if ((c >= 97 && c <= 122) || cam_digit(c) || c == 45 || c == 95 || c == 58) {
          cam_name_from(s, s.next(i), "${acc}${String.fromCodePoint(c) orelse panic()}")
        } else {
          acc
        }
      }
    }

A void element has no end tag: mochiweb's singletons, or `<x/>`.

    let cam_void(s: String, p: StringIndex, gt: StringIndex, name: String): Boolean {
      let lt = s.prev(gt);
      name == "hr" || name == "img" || name == "input" || name == "keygen" || name == "link" || name == "meta" || name == "param" || name == "source" || name == "track" || name == "wbr" || name == "br" || (lt > p && s[lt] == 62 && s[s.prev(lt)] == 47)
    }

The value of attribute `want` of the start tag `<...>` at `p` (whose `>`
ends before `gt`), entities decoded; "" when it has none, which is what
every caller here would make of an empty one too.

    let cam_attr(s: String, p: StringIndex, gt: StringIndex, want: String): String {
      let name_end = cam_name_end(s, s.next(p));
      cam_attr_from(s, name_end, gt, want)
    }

    let cam_name_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && !cam_attr_stop(s[i])) { cam_name_end(s, s.next(i)) } else { i }
    }

    let cam_ws(c: Int): Boolean { c == 32 || c == 9 || c == 10 || c == 13 }

    let cam_attr_stop(c: Int): Boolean { cam_ws(c) || c == 61 || c == 62 || c == 47 }

    let cam_attr_from(s: String, i: StringIndex, gt: StringIndex, want: String): String {
      if (i >= gt || i >= s.end) {
        ""
      } else {
        let c = s[i];
        if (cam_ws(c) || c == 47) {
          cam_attr_from(s, s.next(i), gt, want)
        } else if (c == 62) {
          ""
        } else {
          let ne = cam_name_end(s, i);
          let key = cam_lower(s.slice(i, ne));
          let eq = cam_skip_ws(s, ne);
          if (eq < s.end && s[eq] == 61) {
            let v0 = cam_skip_ws(s, s.next(eq));
            let q = if (v0 < s.end) { s[v0] } else { 0 };
            let vs = if (q == 34 || q == 39) { s.next(v0) } else { v0 };
            let ve = if (q == 34) { cam_find(s, "\"", vs) } else if (q == 39) { cam_find(s, "'", vs) } else { cam_unquoted_end(s, vs) };
            if (key == want) {
              cam_decode(s.slice(vs, ve), String.begin, "")
            } else {
              let after = if ((q == 34 || q == 39) && ve < s.end) { s.next(ve) } else { ve };
              cam_attr_from(s, after, gt, want)
            }
          } else if (key == want) {
            ""
          } else if (ne > i) {
            cam_attr_from(s, ne, gt, want)
          } else {
            cam_attr_from(s, s.next(i), gt, want)
          }
        }
      }
    }

    let cam_skip_ws(s: String, i: StringIndex): StringIndex {
      if (i < s.end && cam_ws(s[i])) { cam_skip_ws(s, s.next(i)) } else { i }
    }

    let cam_unquoted_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && !cam_ws(s[i]) && s[i] != 62) { cam_unquoted_end(s, s.next(i)) } else { i }
    }

    let cam_find(s: String, find: String, i: StringIndex): StringIndex {
      let f = s.indexOf(find, i);
      if (f is StringIndex) { f } else { s.end }
    }

    let cam_lower(s: String): String { cam_lower_from(s, String.begin, "") }

    let cam_lower_from(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        let d = if (c >= 65 && c <= 90) { c + 32 } else { c };
        cam_lower_from(s, s.next(i), "${acc}${String.fromCodePoint(d) orelse panic()}")
      }
    }

Whether the start tag at `p` matches `#want` (`attr` "id") or `.want`
(`attr` "class": one of its space-separated classes).

    let cam_tag_is(s: String, p: StringIndex, gt: StringIndex, attr: String, want: String): Boolean {
      let v = cam_attr(s, p, gt, attr);
      if (attr == "class") { cam_has_token(v, want, String.begin) } else { v == want }
    }

    let cam_has_token(v: String, tok: String, i: StringIndex): Boolean {
      let f = v.indexOf(tok, i);
      if (f is StringIndex) {
        let before = f <= String.begin || cam_ws(v[v.prev(f)]);
        let e = cam_past(v, f, tok, String.begin);
        let after = e >= v.end || cam_ws(v[e]);
        if (before && after) { true } else { cam_has_token(v, tok, v.next(f)) }
      } else {
        false
      }
    }

The `<` of the next start tag at or after `i`, before `lim`, that matches
(see `cam_tag_is`), or `lim`. Tag by tag this would read every attribute of
a 30KB page, several times over; so the name looked for is found with
`indexOf`, and the `<` it sits in by going back to the nearest `<` (a `>`
first means it is text). A tag with a `>` inside a quoted attribute
before the name, or a matching tag written inside a `<script>`, would
fool this; the pages' do neither (every recorded page gives Floki's
answer).

    let cam_find_tag(s: String, i: StringIndex, lim: StringIndex, attr: String, want: String): StringIndex {
      let f = s.indexOf(want, i);
      if (f is StringIndex) {
        if (f >= lim) {
          lim
        } else {
          let p = cam_tag_start(s, f);
          let hit = p < f && p >= i && cam_kind(s, p) == 1 && cam_tag_gt(s, p) > f && cam_tag_is(s, p, cam_tag_gt(s, p), attr, want);
          if (hit) { p } else { cam_find_tag(s, s.next(f), lim, attr, want) }
        }
      } else {
        lim
      }
    }

The `<` before `f` with no `>` between, or `f`.

    let cam_tag_start(s: String, f: StringIndex): StringIndex {
      cam_tag_start_from(s, f, f)
    }

    let cam_tag_start_from(s: String, f: StringIndex, j: StringIndex): StringIndex {
      if (j <= String.begin) {
        f
      } else {
        let q = s.prev(j);
        let c = s[q];
        if (c == 60) { q } else if (c == 62) { f } else { cam_tag_start_from(s, f, q) }
      }
    }

Where the content of the element whose start tag ends just before `i`
ends: the `<` of the end tag that closes it, counting the elements of the
same name opened in between. A void element has no content.

    let cam_content_end(s: String, p: StringIndex): StringIndex {
      let gt = cam_tag_gt(s, p);
      let name = cam_tag_name(s, s.next(p));
      if (cam_void(s, p, gt, name)) { gt } else { cam_close(s, gt, name, 1) }
    }

    let cam_close(s: String, i: StringIndex, name: String, depth: Int): StringIndex {
      let p = cam_next_markup(s, i, s.end);
      if (p >= s.end) {
        s.end
      } else {
        let k = cam_kind(s, p);
        if (k == 2) {
          let n = cam_tag_name(s, s.next(s.next(p)));
          let next = cam_after(s, p, ">");
          if (n != name) {
            cam_close(s, next, name, depth)
          } else if (depth <= 1) {
            p
          } else {
            cam_close(s, next, name, depth - 1)
          }
        } else if (k == 1) {
          let gt = cam_tag_gt(s, p);
          let n = cam_tag_name(s, s.next(p));
          if (n == "script" || n == "style") {
            cam_close(s, cam_skip_markup(s, p), name, depth)
          } else if (n == name && !cam_void(s, p, gt, n)) {
            cam_close(s, gt, name, depth + 1)
          } else {
            cam_close(s, gt, name, depth)
          }
        } else {
          cam_close(s, cam_skip_markup(s, p), name, depth)
        }
      }
    }

### Text

`Floki.text(nodes, sep: sep)` of what lies between `i` and `lim`, added to
`acc` (the text of the nodes before): every text node that is not only
spaces, tabs and newlines, entities decoded, with `sep` before each but
the first; a newline for each `<br>`, with no `sep`; no comments and no
`<script>`. A `<style>`'s text counts, as Floki's default has it. A node
kept is never empty, so `acc` is empty exactly when nothing came before.

    let cam_text(s: String, i: StringIndex, lim: StringIndex, sep: String, acc: String): String {
      if (i >= lim) {
        acc
      } else {
        let p = cam_next_markup(s, i, lim);
        let raw = s.slice(i, p);
        let acc2 = if (p > i && !cam_blank(raw, String.begin)) { cam_join(acc, sep, cam_decode(raw, String.begin, "")) } else { acc };
        if (p >= lim) {
          acc2
        } else if (cam_kind(s, p) == 1) {
          let gt = cam_tag_gt(s, p);
          let name = cam_tag_name(s, s.next(p));
          if (name == "br") {
            cam_text(s, gt, lim, sep, "${acc2}\n")
          } else if (name == "script") {
            cam_text(s, cam_skip_markup(s, p), lim, sep, acc2)
          } else if (name == "style") {
            let e = cam_find(s, "</style", gt);
            let css_end = if (e < lim) { e } else { lim };
            let css = s.slice(gt, css_end);
            let acc3 = if (cam_blank(css, String.begin)) { acc2 } else { cam_join(acc2, sep, css) };
            cam_text(s, cam_skip_markup(s, p), lim, sep, acc3)
          } else {
            cam_text(s, gt, lim, sep, acc2)
          }
        } else {
          cam_text(s, cam_skip_markup(s, p), lim, sep, acc2)
        }
      }
    }

    let cam_join(acc: String, sep: String, t: String): String {
      if (acc.isEmpty) { t } else { "${acc}${sep}${t}" }
    }

    let cam_blank(s: String, i: StringIndex): Boolean {
      if (i >= s.end) { true } else if (cam_ws(s[i])) { cam_blank(s, s.next(i)) } else { false }
    }

The text of every element matching `attr`/`want` (`Floki.find/2` then
`Floki.text/2`), from `i` on, folded into one.

    let cam_texts_with(s: String, i: StringIndex, attr: String, want: String, sep: String, acc: String): String {
      let p = cam_find_tag(s, i, s.end, attr, want);
      if (p >= s.end) {
        acc
      } else {
        let gt = cam_tag_gt(s, p);
        let e = cam_content_end(s, p);
        cam_texts_with(s, e, attr, want, sep, cam_text(s, gt, e, sep, acc))
      }
    }

The same between `i` and `lim`, for the elements inside another.

    let cam_texts_in(s: String, i: StringIndex, lim: StringIndex, attr: String, want: String, acc: String): String {
      let p = cam_find_tag(s, i, lim, attr, want);
      if (p >= lim) {
        acc
      } else {
        let gt = cam_tag_gt(s, p);
        let e = cam_content_end(s, p);
        let stop = if (e < lim) { e } else { lim };
        cam_texts_in(s, e, lim, attr, want, cam_text(s, gt, stop, "", acc))
      }
    }

### Entities

mochiweb reads `&...;` as a character reference when there is a `;`
before any space, quote, `/` or `>`, and the name between is one
`Floki.Entities.decode/1` knows; otherwise the `&` is text. Numbers are
read as `Integer.parse/2` reads them (the leading digits), and mapped as
`Floki.HTML.NumericCharref` maps them: 0, surrogates and anything past
U+10FFFF are U+FFFD, and 0x80-0x9F are Windows-1252's characters.

Floki knows all 2231 names of HTML5. Named here are the ones that turn
up in text: Craigslist writes a seller's text with only `&amp;` `&lt;`
`&gt;` `&quot;` and `&#39;`. Any other name stays as it is written, where
Floki would decode it.

    let cam_decode(s: String, i: StringIndex, acc: String): String {
      let amp = s.indexOf("&", i);
      if (amp is StringIndex) {
        let before = "${acc}${s.slice(i, amp)}";
        let name_at = s.next(amp);
        let semi = cam_ref_end(s, name_at);
        let cp = if (semi < s.end) { cam_ref_value(s.slice(name_at, semi)) } else { -1 };
        if (cp >= 0) {
          cam_decode(s, s.next(semi), "${before}${String.fromCodePoint(cp) orelse panic()}")
        } else {
          cam_decode(s, name_at, "${before}&")
        }
      } else {
        "${acc}${s.slice(i, s.end)}"
      }
    }

The `;` that ends a reference starting at `i`, or the end when something
else comes first.

    let cam_ref_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        s.end
      } else {
        let c = s[i];
        if (c == 59) { i } else if (cam_ws(c) || c == 39 || c == 34 || c == 47 || c == 62) { s.end } else { cam_ref_end(s, s.next(i)) }
      }
    }

    let cam_ref_value(name: String): Int {
      if (name.isEmpty) {
        -1
      } else if (name[String.begin] == 35) {
        let a = name.next(String.begin);
        let hex = a < name.end && (name[a] == 120 || name[a] == 88);
        let start = if (hex) { name.next(a) } else { a };
        let base = if (hex) { 16 } else { 10 };
        let n = cam_num(name, start, base, 0, false);
        if (n < 0) { -1 } else { cam_numeric_ref(n) }
      } else {
        cam_named(name, 0)
      }
    }

The leading digits of base `base` (a `+` first is allowed, a `-` makes it
negative, which Floki refuses); -1 when there are none. Past U+10FFFF it
stops growing: any such number means U+FFFD.

    let cam_num(s: String, i: StringIndex, base: Int, n: Int, any: Boolean): Int {
      if (!any && i < s.end && s[i] == 43 && n == 0) {
        cam_num(s, s.next(i), base, 0, false)
      } else if (i < s.end && cam_digit_value(s[i], base) >= 0) {
        let m = n * base + cam_digit_value(s[i], base);
        let capped = if (m > 1114112) { 1114112 } else { m };
        cam_num(s, s.next(i), base, capped, true)
      } else if (any) {
        n
      } else {
        -1
      }
    }

    let cam_digit_value(c: Int, base: Int): Int {
      if (cam_digit(c)) {
        c - 48
      } else if (base == 16 && c >= 97 && c <= 102) {
        c - 87
      } else if (base == 16 && c >= 65 && c <= 70) {
        c - 55
      } else {
        -1
      }
    }

    let cam_cp1252: List<Int> = [
      8364, 129, 8218, 402, 8222, 8230, 8224, 8225, 710, 8240, 352, 8249, 338, 141, 381, 143,
      144, 8216, 8217, 8220, 8221, 8226, 8211, 8212, 732, 8482, 353, 8250, 339, 157, 382, 376,
    ];

    let cam_numeric_ref(n: Int): Int {
      if (n == 0 || n > 1114111 || (n >= 55296 && n <= 57343)) {
        65533
      } else if (n >= 128 && n <= 159) {
        cam_cp1252[n - 128]
      } else {
        n
      }
    }

    let cam_entity_names: List<String> = [
      "amp", "AMP", "lt", "LT", "gt", "GT", "quot", "QUOT", "apos", "nbsp", "copy", "COPY", "reg", "REG", "trade",
      "hellip", "mdash", "ndash", "lsquo", "rsquo", "ldquo", "rdquo", "sbquo", "bdquo", "bull", "middot", "deg",
      "times", "divide", "frac12", "frac14", "frac34", "hearts", "rsaquo", "lsaquo", "laquo", "raquo", "cent",
      "pound", "euro", "yen", "sect", "para", "plusmn", "micro", "iexcl", "iquest", "acute", "cedil", "uml",
      "ordf", "ordm", "shy", "not", "macr", "sup1", "sup2", "sup3", "prime", "Prime", "larr", "rarr", "uarr",
      "darr", "harr", "star", "starf", "check", "hyphen", "dash", "minus", "le", "ge", "ne", "infin",
      "Agrave", "Aacute", "Acirc", "Atilde", "Auml", "Aring", "AElig", "Ccedil", "Egrave", "Eacute", "Ecirc",
      "Euml", "Igrave", "Iacute", "Icirc", "Iuml", "ETH", "Ntilde", "Ograve", "Oacute", "Ocirc", "Otilde",
      "Ouml", "Oslash", "Ugrave", "Uacute", "Ucirc", "Uuml", "Yacute", "THORN", "szlig", "agrave", "aacute",
      "acirc", "atilde", "auml", "aring", "aelig", "ccedil", "egrave", "eacute", "ecirc", "euml", "igrave",
      "iacute", "icirc", "iuml", "eth", "ntilde", "ograve", "oacute", "ocirc", "otilde", "ouml", "oslash",
      "ugrave", "uacute", "ucirc", "uuml", "yacute", "thorn", "yuml",
    ];

    let cam_entity_codes: List<Int> = [
      38, 38, 60, 60, 62, 62, 34, 34, 39, 160, 169, 169, 174, 174, 8482,
      8230, 8212, 8211, 8216, 8217, 8220, 8221, 8218, 8222, 8226, 183, 176,
      215, 247, 189, 188, 190, 9829, 8250, 8249, 171, 187, 162,
      163, 8364, 165, 167, 182, 177, 181, 161, 191, 180, 184, 168,
      170, 186, 173, 172, 175, 185, 178, 179, 8242, 8243, 8592, 8594, 8593,
      8595, 8596, 9734, 9733, 10003, 8208, 8208, 8722, 8804, 8805, 8800, 8734,
      192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202,
      203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213,
      214, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225,
      226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236,
      237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 248,
      249, 250, 251, 252, 253, 254, 255,
    ];

    let cam_named(name: String, i: Int): Int {
      if (i >= cam_entity_names.length) { -1 } else if (cam_entity_names[i] == name) { cam_entity_codes[i] } else { cam_named(name, i + 1) }
    }

### The fields

`body`: the text of `#postingbody` with a newline between text nodes, the
QR code's label taken out, every line trimmed, runs of three or more
newlines made two, trimmed.

    let cam_clean_body(raw: String): String {
      let noqr = cam_replace(raw, "QR Code Link to This Post", "");
      cam_utrim(cam_collapse(cam_trim_lines(noqr, String.begin, ""), String.begin, ""))
    }

    let cam_replace(s: String, find: String, with: String): String {
      cam_replace_from(s, find, with, String.begin, "")
    }

    let cam_replace_from(s: String, find: String, with: String, i: StringIndex, acc: String): String {
      let f = s.indexOf(find, i);
      if (f is StringIndex) {
        cam_replace_from(s, find, with, cam_past(s, f, find, String.begin), "${acc}${s.slice(i, f)}${with}")
      } else {
        "${acc}${s.slice(i, s.end)}"
      }
    }

    let cam_trim_lines(s: String, i: StringIndex, acc: String): String {
      let nl = s.indexOf("\n", i);
      if (nl is StringIndex) {
        cam_trim_lines(s, s.next(nl), "${acc}${cam_utrim(s.slice(i, nl))}\n")
      } else {
        "${acc}${cam_utrim(s.slice(i, s.end))}"
      }
    }

    let cam_collapse(s: String, i: StringIndex, acc: String): String {
      let f = s.indexOf("\n\n\n", i);
      if (f is StringIndex) {
        cam_collapse(s, cam_newlines_end(s, f), "${acc}${s.slice(i, f)}\n\n")
      } else {
        "${acc}${s.slice(i, s.end)}"
      }
    }

    let cam_newlines_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && s[i] == 10) { cam_newlines_end(s, s.next(i)) } else { i }
    }

`String.trim/1`: Unicode's white space off both ends, the no-break space
included.

    let cam_uspace(c: Int): Boolean {
      (c >= 9 && c <= 13) || c == 32 || c == 133 || c == 160 || c == 5760 || (c >= 8192 && c <= 8202) || c == 8232 || c == 8233 || c == 8239 || c == 8287 || c == 12288
    }

    let cam_utrim(s: String): String {
      let a = cam_utrim_left(s, String.begin);
      let t = s.slice(a, s.end);
      t.slice(String.begin, cam_utrim_right(t, t.end))
    }

    let cam_utrim_left(s: String, i: StringIndex): StringIndex {
      if (i < s.end && cam_uspace(s[i])) { cam_utrim_left(s, s.next(i)) } else { i }
    }

    let cam_utrim_right(s: String, e: StringIndex): StringIndex {
      if (e > String.begin && cam_uspace(s[s.prev(e)])) { cam_utrim_right(s, s.prev(e)) } else { e }
    }

`attrs`: every `.attrgroup .attr`. The label is the text of its `.labl`
with the trailing colons and then white space off; the value the text of
its `.valu`, trimmed. Both there: a pair. No label but some text: the
whole text, trimmed, is the label and "yes" the value ("cryptocurrency
ok"). Returned as JSON array elements, each after a comma.

    let cam_attr_groups(s: String, i: StringIndex, acc: String): String {
      let g = cam_find_tag(s, i, s.end, "class", "attrgroup");
      if (g >= s.end) {
        acc
      } else {
        let gt = cam_tag_gt(s, g);
        let e = cam_content_end(s, g);
        cam_attr_groups(s, e, cam_attrs_in(s, gt, e, acc))
      }
    }

    let cam_attrs_in(s: String, i: StringIndex, lim: StringIndex, acc: String): String {
      let a = cam_find_tag(s, i, lim, "class", "attr");
      if (a >= lim) {
        acc
      } else {
        let gt = cam_tag_gt(s, a);
        let e0 = cam_content_end(s, a);
        let e = if (e0 < lim) { e0 } else { lim };
        let label = cam_utrim(cam_trim_colons(cam_texts_in(s, gt, e, "class", "labl", "")));
        let value = cam_utrim(cam_texts_in(s, gt, e, "class", "valu", ""));
        let whole = cam_utrim(cam_text(s, gt, e, "", ""));
        let pair = if (!label.isEmpty && !value.isEmpty) {
          ",[${cam_json_str(label)},${cam_json_str(value)}]"
        } else if (label.isEmpty && !whole.isEmpty) {
          ",[${cam_json_str(whole)},\"yes\"]"
        } else {
          ""
        };
        cam_attrs_in(s, e, lim, "${acc}${pair}")
      }
    }

`String.trim_trailing(s, ":")`: every trailing colon.

    let cam_trim_colons(s: String): String {
      if (!s.isEmpty && s[s.prev(s.end)] == 58) { cam_trim_colons(s.slice(String.begin, s.prev(s.end))) } else { s }
    }

`times`: the `datetime` of every `time.date` inside a `p.postinginfo`.
The page's "Posted" line at the top is a `p.postinginfo` too, so the
first is when it was posted and the second the "posted:" line at the
bottom, which is what `parse_post/1` stores as `updated_at`.

    let cam_info_times(s: String, i: StringIndex, acc: String): String {
      let p = cam_find_tag(s, i, s.end, "class", "postinginfo");
      if (p >= s.end) {
        acc
      } else if (cam_tag_name(s, s.next(p)) != "p") {
        cam_info_times(s, cam_tag_gt(s, p), acc)
      } else {
        let gt = cam_tag_gt(s, p);
        let e = cam_content_end(s, p);
        cam_info_times(s, e, cam_times_in(s, gt, e, acc))
      }
    }

    let cam_times_in(s: String, i: StringIndex, lim: StringIndex, acc: String): String {
      let t = cam_find_tag(s, i, lim, "class", "date");
      if (t >= lim) {
        acc
      } else {
        let gt = cam_tag_gt(s, t);
        let iso = if (cam_tag_name(s, s.next(t)) == "time") { cam_iso(cam_attr(s, t, gt, "datetime")) } else { "" };
        let acc2 = if (iso.isEmpty) { acc } else { "${acc},${cam_json_str(iso)}" };
        cam_times_in(s, gt, lim, acc2)
      }
    }

`DateTime.from_iso8601/1`'s extended form: a date, `T` or a space, the
time, maybe a fraction, and an offset (`Z`, `±hh:mm`, `±hhmm` or `±hh`;
without one it is an error). The answer is the same text without the
fraction, which Postgres reads as the same instant, cut to the second;
"" when Elixir would refuse it (the day must exist, the hour be under 24,
the minute and second under 60).

    export let cam_iso(v: String): String {
      if (!cam_iso_shape(v)) {
        ""
      } else {
        let y = cam_num_at(v, 0, 4);
        let mo = cam_num_at(v, 5, 2);
        let d = cam_num_at(v, 8, 2);
        let h = cam_num_at(v, 11, 2);
        let mi = cam_num_at(v, 14, 2);
        let se = cam_num_at(v, 17, 2);
        if (mo < 1 || mo > 12 || d < 1 || d > cam_month_days(y, mo) || h > 23 || mi > 59 || se > 59) {
          ""
        } else {
          let head = cam_first(v, 19);
          let rest = v.slice(cam_nth_index(v, String.begin, 19), v.end);
          let tz = if (!rest.isEmpty && rest[String.begin] == 46) { rest.slice(cam_digit_run(rest, rest.next(String.begin)), rest.end) } else { rest };
          if (cam_offset_ok(tz)) { "${head}${tz}" } else { "" }
        }
      }
    }

    let cam_iso_shape(v: String): Boolean {
      cam_digits_at(v, 0, 4) && cam_char_at(v, 4) == 45 && cam_digits_at(v, 5, 2) && cam_char_at(v, 7) == 45 && cam_digits_at(v, 8, 2) && (cam_char_at(v, 10) == 84 || cam_char_at(v, 10) == 32) && cam_digits_at(v, 11, 2) && cam_char_at(v, 13) == 58 && cam_digits_at(v, 14, 2) && cam_char_at(v, 16) == 58 && cam_digits_at(v, 17, 2)
    }

    let cam_offset_ok(tz: String): Boolean {
      if (tz == "Z") {
        true
      } else if (tz.isEmpty || !(tz[String.begin] == 43 || tz[String.begin] == 45)) {
        false
      } else {
        let n = cam_count(tz, String.begin, 0);
        let hh = cam_digits_at(tz, 1, 2) && cam_num_at(tz, 1, 2) <= 23;
        if (n == 3) {
          hh
        } else if (n == 5) {
          hh && cam_digits_at(tz, 3, 2) && cam_num_at(tz, 3, 2) <= 59
        } else if (n == 6) {
          hh && cam_char_at(tz, 3) == 58 && cam_digits_at(tz, 4, 2) && cam_num_at(tz, 4, 2) <= 59
        } else {
          false
        }
      }
    }

    let cam_month_days(y: Int, m: Int): Int {
      if (m == 2) {
        if (cam_r(y, 4) == 0 && (cam_r(y, 100) != 0 || cam_r(y, 400) == 0)) { 29 } else { 28 }
      } else if (m == 4 || m == 6 || m == 9 || m == 11) {
        30
      } else {
        31
      }
    }

Characters by position, for the fixed-width date: -1 past the end.

    let cam_nth_index(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { cam_nth_index(s, s.next(i), n - 1) }
    }

    let cam_char_at(s: String, n: Int): Int {
      let i = cam_nth_index(s, String.begin, n);
      if (i < s.end) { s[i] } else { -1 }
    }

    let cam_digits_at(s: String, n: Int, count: Int): Boolean {
      if (count <= 0) { true } else if (cam_digit(cam_char_at(s, n))) { cam_digits_at(s, n + 1, count - 1) } else { false }
    }

    let cam_num_at(s: String, n: Int, count: Int): Int {
      cam_digits(s, cam_nth_index(s, String.begin, n), 0, 9 - count)
    }

    let cam_count(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) { n } else { cam_count(s, s.next(i), n + 1) }
    }

    let cam_first(s: String, n: Int): String {
      s.slice(String.begin, cam_nth_index(s, String.begin, n))
    }

`image_ids`: `~r/"imgid":"(?:\d+:)?([^"]+)"/`, every match, each once, in
the order first seen. The width prefix goes only when something is left
after it: `"imgid":"3:"` is "3:".

    let cam_imgids(s: String, i: StringIndex, acc: String): String {
      let f = s.indexOf("\"imgid\":\"", i);
      if (f is StringIndex) {
        let v = cam_past(s, f, "\"imgid\":\"", String.begin);
        let d = cam_digit_run(s, v);
        let skip = d > v && d < s.end && s[d] == 58 && s.next(d) < s.end && s[s.next(d)] != 34;
        let start = if (skip) { s.next(d) } else { v };
        let q = cam_find(s, "\"", start);
        if (q < s.end && q > start) {
          cam_imgids(s, s.next(q), cam_add_once(acc, s.slice(start, q)))
        } else {
          cam_imgids(s, s.next(f), acc)
        }
      } else {
        acc
      }
    }

Adding `v` to a list written as `,"a","b"`, unless it is there: a JSON
string token cannot occur inside another, so looking for `,"v",` in
`acc,` is exact.

    let cam_add_once(acc: String, v: String): String {
      let tok = ",${cam_json_str(v)}";
      if (cam_has("${acc},", "${tok},")) { acc } else { "${acc}${tok}" }
    }

    let cam_list_body(acc: String): String {
      if (acc.isEmpty) { acc } else { acc.slice(acc.next(String.begin), acc.end) }
    }

`reply_url`: `~r/reply-button[^>]*data-href="([^"]+)"/`, the first match.
`[^>]*` is greedy, so within one tag it is the last `data-href="` that has
a value and a closing quote.

    let cam_reply_url(s: String, i: StringIndex): String {
      let f = s.indexOf("reply-button", i);
      if (f is StringIndex) {
        let a = cam_past(s, f, "reply-button", String.begin);
        let gt = cam_find(s, ">", a);
        let v = cam_last_href(s, a, gt, "");
        if (v.isEmpty) { cam_reply_url(s, s.next(f)) } else { v }
      } else {
        ""
      }
    }

    let cam_last_href(s: String, i: StringIndex, gt: StringIndex, best: String): String {
      let k = s.indexOf("data-href=\"", i);
      if (k is StringIndex) {
        let vs = cam_past(s, k, "data-href=\"", String.begin);
        if (vs > gt) {
          best
        } else {
          let q = cam_find(s, "\"", vs);
          let found = if (q < s.end && q > vs) { s.slice(vs, q) } else { best };
          cam_last_href(s, s.next(k), gt, found)
        }
      } else {
        best
      }
    }

### Contact details

`extract_contact/1`'s phone pattern,
`~r/(?:\+?1[\s.-]?)?\(?\b\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b/`, scanned as
`Regex.scan/2` scans: the leftmost match, then on from its end. Every
optional part but the leading `+1` group is decided by the next
character (taking it is the only way to go on), so only that group is
tried both ways, with it first. `\b` and `\s` are ASCII here, as the
pattern has no `u`: a word character is a letter, a digit or `_`, and a
space is one of space, tab, newline, vertical tab, form feed, return.

    let cam_phones(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let e = cam_phone_at(s, i);
        if (e > i) { cam_phones(s, e, cam_add_once(acc, cam_utrim(s.slice(i, e)))) } else { cam_phones(s, s.next(i), acc) }
      }
    }

    let cam_word(c: Int): Boolean { (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95 }

    let cam_pspace(c: Int): Boolean { c == 32 || (c >= 9 && c <= 13) }

    let cam_psep(c: Int): Boolean { cam_pspace(c) || c == 46 || c == 45 }

Where a phone number starting at `p` ends, or `p`. A match always ends
past the start of the text, so `String.begin` stands for "no match".

    let cam_phone_at(s: String, p: StringIndex): StringIndex {
      let plus = if (s[p] == 43) { s.next(p) } else { p };
      let with_one = if (plus < s.end && s[plus] == 49) {
        let k = s.next(plus);
        let k2 = if (k < s.end && cam_psep(s[k])) { s.next(k) } else { k };
        cam_phone_core(s, k2)
      } else {
        String.begin
      };
      if (with_one > String.begin) {
        with_one
      } else {
        let bare = cam_phone_core(s, p);
        if (bare > String.begin) { bare } else { p }
      }
    }

    let cam_phone_core(s: String, q: StringIndex): StringIndex {
      let q1 = if (q < s.end && s[q] == 40) { s.next(q) } else { q };
      let bound = q1 <= String.begin || !cam_word(s[s.prev(q1)]);
      let d1 = cam_digits_n(s, q1, 3);
      if (!bound || d1 <= String.begin) {
        String.begin
      } else {
        let q2 = if (d1 < s.end && s[d1] == 41) { s.next(d1) } else { d1 };
        let q3 = if (q2 < s.end && cam_psep(s[q2])) { s.next(q2) } else { q2 };
        let d2 = cam_digits_n(s, q3, 3);
        if (d2 <= String.begin) {
          String.begin
        } else {
          let q4 = if (d2 < s.end && cam_psep(s[d2])) { s.next(d2) } else { d2 };
          let d3 = cam_digits_n(s, q4, 4);
          if (d3 <= String.begin) {
            String.begin
          } else if (d3 >= s.end || !cam_word(s[d3])) {
            d3
          } else {
            String.begin
          }
        }
      }
    }

After exactly `n` ASCII digits from `i`, or `String.begin` when there are
fewer.

    let cam_digits_n(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0) { i } else if (i < s.end && cam_digit(s[i])) { cam_digits_n(s, s.next(i), n - 1) } else { String.begin }
    }

The email pattern, `~r/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i`, the same
way. A match has an `@`; for the first `@` from `i`, the leftmost start
is where the run of name characters before it begins (not before `i`),
and every start in that run meets the same domain. The domain run is
greedy and gives characters back from the right, so the dot it settles
on is the last one with a name before it and two letters after it; the
letters then run as far as they go.

    let cam_emails(s: String, i: StringIndex, acc: String): String {
      let at = s.indexOf("@", i);
      if (at is StringIndex) {
        let start = cam_local_start(s, at, i);
        let d0 = s.next(at);
        let de = cam_domain_end(s, d0);
        let dot = cam_last_dot(s, d0, de);
        if (start < at && dot > String.begin) {
          let e = cam_letters_end(s, s.next(dot));
          cam_emails(s, e, cam_add_once(acc, s.slice(start, e)))
        } else {
          cam_emails(s, d0, acc)
        }
      } else {
        acc
      }
    }

    let cam_alpha(c: Int): Boolean { (c >= 65 && c <= 90) || (c >= 97 && c <= 122) }

    let cam_local(c: Int): Boolean { cam_alpha(c) || cam_digit(c) || c == 46 || c == 95 || c == 37 || c == 43 || c == 45 }

    let cam_local_start(s: String, at: StringIndex, lo: StringIndex): StringIndex {
      if (at > lo && cam_local(s[s.prev(at)])) { cam_local_start(s, s.prev(at), lo) } else { at }
    }

    let cam_domain_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && (cam_alpha(s[i]) || cam_digit(s[i]) || s[i] == 46 || s[i] == 45)) { cam_domain_end(s, s.next(i)) } else { i }
    }

The last `.` before `j` with at least one domain character before it
(after `lo`) and two letters after it, or `String.begin` for none.

    let cam_last_dot(s: String, lo: StringIndex, j: StringIndex): StringIndex {
      if (j <= lo) {
        String.begin
      } else {
        let p = s.prev(j);
        if (p > lo && s[p] == 46 && cam_two_letters(s, s.next(p))) { p } else { cam_last_dot(s, lo, p) }
      }
    }

    let cam_two_letters(s: String, i: StringIndex): Boolean {
      i < s.end && cam_alpha(s[i]) && s.next(i) < s.end && cam_alpha(s[s.next(i)])
    }

    let cam_letters_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && cam_alpha(s[i])) { cam_letters_end(s, s.next(i)) } else { i }
    }

### JSON

A JSON string: quotes, backslashes and control characters escaped, the
rest as it is (`json_decode` reads UTF-8).

    export let cam_json_str(s: String): String {
      "\"${cam_json_from(s, String.begin, String.begin, "")}\""
    }

    let cam_json_from(s: String, i: StringIndex, run: StringIndex, acc: String): String {
      if (i >= s.end) {
        "${acc}${s.slice(run, s.end)}"
      } else {
        let c = s[i];
        if (c == 34 || c == 92 || c < 32) {
          cam_json_from(s, s.next(i), s.next(i), "${acc}${s.slice(run, i)}${cam_json_escape(c)}")
        } else {
          cam_json_from(s, s.next(i), run, acc)
        }
      }
    }

    let cam_json_escape(c: Int): String {
      if (c == 34) {
        "\\\""
      } else if (c == 92) {
        "\\\\"
      } else if (c == 10) {
        "\\n"
      } else if (c == 13) {
        "\\r"
      } else if (c == 9) {
        "\\t"
      } else {
        "\\u00${cam_hex(cam_q(c, 16))}${cam_hex(cam_r(c, 16))}"
      }
    }

## Classifying

`classify/5`. The caller lower-cases (Temper's `String` has no case
mapping): `title_d` is the title, `text` the title, body and attributes
joined as `classify/5` joins them. `any?/2` is
`~r/(?<![a-z0-9])needle(?![a-z0-9])/`: an occurrence with no lower-case
letter or digit on either side.

    let cam_film_signals: List<String> = ["film", "35mm", "120 film", "220 film", "medium format", "rangefinder", "large format", "sheet film", "instant film", "polaroid", "roll of film", "rolls of film"];

    let cam_digital_signals: List<String> = ["digital", "mirrorless", "dslr", "megapixel", "4k video", "cmos", "sd card", "micro four thirds", "eos r", "sony a7", "x-t", "x100", "z6", "z7", "d850", "d750", "5d mark"];

    let cam_working_signals: List<String> = ["works perfectly", "works great", "works fine", "works well", "working", "fully functional", "tested", "film tested", "serviced", "cla", "cla'd", "cla’d", "overhauled", "meter works", "shutter speeds accurate", "just serviced", "recently serviced", "light seals replaced", "new seals", "new light seals", "good working"];

    let cam_hopeful_signals: List<String> = ["untested", "not tested", "haven't tested", "havent tested", "never tested", "as-is", "as is", "no idea", "don't know", "dont know", "not sure", "estate", "grandfather", "grandpa", "grandmother", "attic", "basement", "garage sale", "unknown condition", "can't test", "cannot test", "no battery to test"];

    let cam_lot_signals: List<String> = ["lot of", "camera lot", "collection", "bundle", "estate", "several cameras", "bunch of", "assorted", "multiple cameras"];

    let cam_broken_signals: List<String> = ["broken", "doesn't work", "does not work", "not working", "needs repair", "for parts", "parts only", "stuck shutter", "shutter stuck", "fungus", "haze", "light leak", "light leaks", "needs cla", "needs service", "sticky"];

    let cam_accessory_words: List<String> = ["lens", "lenses", "strap", "bag", "case", "flash", "tripod", "manual", "battery", "charger", "filter", "filters", "adapter", "mount", "hood", "cap", "grip", "backpack", "enlarger", "scanner", "darkroom", "film only", "expired film", "viewfinder", "finder", "prism", "knob", "film back", "magazine", "cable release", "focusing screen", "eyepiece", "winder", "motor drive"];

    let cam_camera_words: List<String> = ["camera body", "film camera", "slr", "rangefinder", "kit", "outfit", "w/", "with ", "+", "and lens", "body", "set"];

    let cam_camera_things: List<String> = ["strap", "bag", "case", "lens cap", "cap", "flash", "tripod", "manual", "battery", "charger", "filter", "adapter", "mount", "hood", "grip", "backpack", "back"];

    let cam_alnum_low(c: Int): Boolean { (c >= 48 && c <= 57) || (c >= 97 && c <= 122) }

    let cam_whole(s: String, w: String, from: StringIndex): Boolean {
      let found = s.indexOf(w, from);
      if (found is StringIndex) {
        let before_ok = found <= String.begin || !cam_alnum_low(s[s.prev(found)]);
        let e = cam_past(s, found, w, String.begin);
        let after_ok = e >= s.end || !cam_alnum_low(s[e]);
        if (before_ok && after_ok) { true } else { cam_whole(s, w, s.next(found)) }
      } else {
        false
      }
    }

    let cam_any(s: String, needles: List<String>, i: Int): Boolean {
      if (i >= needles.length) { false } else if (cam_whole(s, needles[i], String.begin)) { true } else { cam_any(s, needles, i + 1) }
    }

    let cam_contains_any(s: String, needles: List<String>, i: Int): Boolean {
      if (i >= needles.length) { false } else if (cam_has(s, needles[i])) { true } else { cam_contains_any(s, needles, i + 1) }
    }

`any_model_query?/1`: a query that is not one of the four generic ones.

    let cam_generic(q: String): Boolean {
      q == "film camera" || q == "35mm camera" || q == "rangefinder camera" || q == "medium format camera"
    }

    let cam_any_model(qs: List<String>, i: Int): Boolean {
      if (i >= qs.length) { false } else if (!cam_generic(qs[i])) { true } else { cam_any_model(qs, i + 1) }
    }

"Nikon FM2 with 50mm lens" is a camera, "Nikon camera strap" is not:
`~r/camera (strap|...|back)\b/` is tried at every "camera " in the title,
each alternative in order, `\b` after it.

    let cam_camera_thing(t: String, from: StringIndex): Boolean {
      let f = t.indexOf("camera ", from);
      if (f is StringIndex) {
        let a = cam_past(t, f, "camera ", String.begin);
        if (cam_thing_at(t, a, 0)) { true } else { cam_camera_thing(t, t.next(f)) }
      } else {
        false
      }
    }

    let cam_thing_at(t: String, a: StringIndex, i: Int): Boolean {
      if (i >= cam_camera_things.length) {
        false
      } else {
        let w = cam_camera_things[i];
        let e = cam_past(t, a, w, String.begin);
        if (cam_at(t, a, w) && (e >= t.end || !cam_word(t[e]))) { true } else { cam_thing_at(t, a, i + 1) }
      }
    }

    let cam_accessory(title_d: String): Boolean {
      cam_any(title_d, cam_accessory_words, 0) && !cam_any(title_d, cam_camera_words, 0) && (!cam_has(title_d, "camera") || cam_camera_thing(title_d, String.begin))
    }

    let cam_film(text: String, qs: List<String>): Boolean { cam_any(text, cam_film_signals, 0) || cam_any_model(qs, 0) }

    let cam_digital(text: String): Boolean { cam_any(text, cam_digital_signals, 0) && !cam_whole(text, "film", String.begin) }

The model tags: the queries, in order, that name a model and that the
title contains.

    let cam_model_tags(title_d: String, qs: List<String>, i: Int, acc: String): String {
      if (i >= qs.length) {
        acc
      } else {
        let q = qs[i];
        let hit = !cam_generic(q) && cam_has(title_d, q);
        let acc2 = if (hit) { cam_line(acc, q) } else { acc };
        cam_model_tags(title_d, qs, i + 1, acc2)
      }
    }

    let cam_line(acc: String, t: String): String {
      if (acc.isEmpty) { t } else { "${acc}\n${t}" }
    }

The tags, one per line, in `classify/5`'s order. The queries are already
lower case.

    export let cam_tags(title_d: String, text: String, qs: List<String>): String {
      let t1 = if (cam_film(text, qs)) { "film" } else { "" };
      let t2 = cam_line_if(t1, cam_digital(text), "not film?");
      let t3 = cam_line_if(t2, cam_any(text, cam_working_signals, 0), "working");
      let t4 = cam_line_if(t3, cam_any(text, cam_hopeful_signals, 0), "hopeful");
      let t5 = cam_line_if(t4, cam_any(text, cam_lot_signals, 0), "lot");
      let t6 = cam_line_if(t5, cam_any(text, cam_broken_signals, 0), "needs work");
      let t7 = cam_line_if(t6, cam_accessory(title_d), "accessory");
      let models = cam_model_tags(title_d, qs, 0, "");
      if (models.isEmpty) { t7 } else { cam_line(t7, models) }
    }

    let cam_line_if(acc: String, yes: Boolean, t: String): String {
      if (yes) { cam_line(acc, t) } else { acc }
    }

The score: 50, then the signals' weights, the condition (lower-cased,
"" when the seller gave none) and the photo count.

    export let cam_score(title_d: String, text: String, qs: List<String>, condition: String, n_images: Int): Int {
      let models = cam_model_tags(title_d, qs, 0, "");
      50 + cam_w(cam_film(text, qs), 20) + cam_w(cam_digital(text), -40) + cam_w(cam_any(text, cam_working_signals, 0), 15) + cam_w(cam_any(text, cam_hopeful_signals, 0), 8) + cam_w(cam_any(text, cam_lot_signals, 0), 10) + cam_w(cam_any(text, cam_broken_signals, 0), -8) + cam_w(cam_accessory(title_d), -30) + cam_w(!models.isEmpty, 12) + cam_condition_bonus(condition) + cam_photo_bonus(n_images)
    }

    let cam_w(yes: Boolean, n: Int): Int { if (yes) { n } else { 0 } }

    let cam_condition_bonus(c: String): Int {
      if (c == "new") { 5 } else if (c == "like new" || c == "excellent") { 8 } else if (c == "good") { 4 } else if (c == "salvage") { -10 } else { 0 }
    }

    let cam_photo_bonus(n: Int): Int {
      if (n == 0) { -15 } else if (n >= 4) { 5 } else { 0 }
    }

## The analyst

`Analyst`'s system prompt, trimmed as `String.trim(@system)` trims it.

    export let cam_analyst_system: String = "You are a seasoned film camera dealer and collector writing quick, honest notes for a friend\nbrowsing Craigslist. Be specific to the exact model when you can identify it. Judge price against\nthe current used market for working examples. Flag digital cameras, lenses-only or accessory-only\nposts plainly. Keep every field short and concrete. Never invent condition details the seller\ndidn't state.";

`prompt/1`. `hood` is "" for none, `price_cents` -1, `posted` the date as
`Calendar.strftime(dt, "%b %-d, %Y")` wrote it or "". The body is cut to
3000 characters: code points here, graphemes in Elixir, which differ only
for a body longer than that with combining marks or joined emoji.

    export let cam_analyst_prompt(city: String, hood: String, title: String, price_cents: Int, attrs: String, photos: Int, posted: String, body: String): String {
      let where = if (hood.isEmpty) { city } else { "${city}, ${hood}" };
      let price = if (price_cents < 0) { "not listed" } else { "$${cam_q(price_cents, 100).toString()}" };
      let seller = if (attrs.isEmpty) { "none" } else { attrs };
      "Craigslist post (${where}):\n\nTitle: ${title}\nAsking: ${price}\nSeller attributes: ${seller}\nPhotos: ${photos.toString()}\nPosted: ${posted}\n\nBody:\n${cam_first(body, 3000)}\n"
    }

## For the writes

Ecto's `cast/4` makes a string that is empty once trimmed (Unicode white
space, `String.trim_leading/1`) nil, for every field; so does the sweep.

    export let cam_blank_text(s: String): Boolean { cam_utrim(s).isEmpty }

`Listing.changeset/2` cuts the title to 255 characters (`String.slice/3`,
graphemes; code points here).

    export let cam_first_chars(s: String, n: Int): String { cam_first(s, n) }
