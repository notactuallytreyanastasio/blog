# Stumble: which posts become links

What `Blog.PokeAround.Bluesky.Extractor` decides about a post from Graze's
turbostream, and what `Blog.PokeAround.Links.store_link/1` makes of its
link: whether the post has exactly one link, whether its language, its
author and its text qualify, the score, and the url's hash, domain and
whether its host is banned. `src/99_stumble_ingest.blimp` decodes the
frames, picks the fields out, and writes the rows; everything here is a
function of strings and numbers.

The answers have to be Phoenix's, to the byte: the url hash is the unique
key of `pa_links`, so a link hashed differently would be stored twice
while both ingesters' rows are in the table. So this follows the Elixir
standard library where it is odd, not where it is sensible: `URI.parse`'s
regular expressions, `URI.decode_query`'s map, `DateTime.from_iso8601`'s
offsets, `String.downcase`'s Unicode table, `String.length`'s graphemes.

## Links

`Parser.extract_links/1`: the link card's uri, then every link facet's,
without repeats, keeping those that start `http://` or `https://` and are
not Bluesky's own. The extractor stores a post only when that leaves
exactly one ("multiple links = spam"); this is the one, or "" for none or
several.

    export let st_the_link(links: List<String>): String {
      let ok = links.filter { (x): Boolean => st_link_ok(x) };
      if (ok.isEmpty) {
        ""
      } else {
        let first = ok[0];
        if (ok.filter { (x): Boolean => x != first }.isEmpty) { first } else { "" }
      }
    }

How many different links the post has, for the stats line.

    export let st_link_count(links: List<String>): Int {
      st_distinct(links.filter { (x): Boolean => st_link_ok(x) }, 0, 0)
    }

    let st_distinct(xs: List<String>, i: Int, n: Int): Int {
      if (i >= xs.length) {
        n
      } else {
        let x = xs[i];
        let seen = !xs.slice(0, i).filter { (y): Boolean => y == x }.isEmpty;
        st_distinct(xs, i + 1, if (seen) { n } else { n + 1 })
      }
    }

`valid_link?/1`, prefix for prefix: `https://bsky.application.com` is out too.

    export let st_link_ok(url: String): Boolean {
      if (st_starts(url, "https://bsky.app") || st_starts(url, "http://bsky.app")) {
        false
      } else if (st_starts(url, "https://bsky.social") || st_starts(url, "http://bsky.social")) {
        false
      } else {
        st_starts(url, "https://") || st_starts(url, "http://")
      }
    }

    let st_starts(s: String, p: String): Boolean {
      st_starts_at(s, String.begin, p, String.begin)
    }

    let st_starts_at(s: String, i: StringIndex, p: String, j: StringIndex): Boolean {
      if (j >= p.end) {
        true
      } else if (i >= s.end) {
        false
      } else if (s[i] != p[j]) {
        false
      } else {
        st_starts_at(s, s.next(i), p, p.next(j))
      }
    }

    let st_ends(s: String, p: String): Boolean {
      let n = st_cps(s, String.begin, 0);
      let m = st_cps(p, String.begin, 0);
      n >= m && st_starts_at(s, st_skip(s, String.begin, n - m), p, String.begin)
    }

Whether `s` has at most `n` characters: what fits a `varchar(255)`
column. Postgres refuses a longer value, and Phoenix's insert raised.

    export let st_fits(s: String, n: Int): Boolean {
      st_fits_at(s, String.begin, n)
    }

    let st_fits_at(s: String, i: StringIndex, n: Int): Boolean {
      if (i >= s.end) { true } else if (n <= 0) { false } else { st_fits_at(s, s.next(i), n - 1) }
    }

    let st_cps(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) { n } else { st_cps(s, s.next(i), n + 1) }
    }

    let st_skip(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { st_skip(s, s.next(i), n - 1) }
    }

## Language

`lang_qualifies?/1`: one of the post's languages is `en` or `en-` something.

    export let st_lang_ok(langs: List<String>): Boolean {
      !langs.filter { (x): Boolean => x == "en" || st_starts(x, "en-") }.isEmpty
    }

## Author

`author_qualifies?/1` less the bio and the age, which are below: at least
500 followers, following at most 5000. A missing count is 0.

    export let st_author_ok(followers: Int, follows: Int): Boolean {
      followers >= 500 && follows <= 5000
    }

`String.trim(s) == ""`, over the characters Elixir trims: Unicode's
White_Space. The bio must not be blank. The same test is Ecto's
`empty_trimmed_string?/1`, by which `cast/4` stores a blank handle or
display name as NULL.

    export let st_blank(s: String): Boolean {
      st_blank_at(s, String.begin)
    }

    let st_blank_at(s: String, i: StringIndex): Boolean {
      if (i >= s.end) { true } else if (!st_space(s[i])) { false } else { st_blank_at(s, s.next(i)) }
    }

    let st_space(c: Int): Boolean {
      (c >= 9 && c <= 13) || c == 32 || c == 133 || c == 160 || c == 5760 ||
      (c >= 8192 && c <= 8202) || c == 8232 || c == 8233 || c == 8239 || c == 8287 || c == 12288
    }

`account_age_ok?/1`: `DateTime.diff(now, indexed_at, :day) >= 365`, which
is 365 days of microseconds. `indexed_at` is when Bluesky last indexed the
profile, not when the account was made (that is `created_at`, which the
extractor does not read); a profile edited this year is "too new". An
`indexed_at` that `DateTime.from_iso8601` refuses is too new as well.

    export let st_age_ok(indexed_at: String, now_ms: Int64): Boolean {
      let t = st_iso(indexed_at);
      if (t.isEmpty) {
        false
      } else {
        now_ms * 1000i64 - (t[0] * 1000000i64 + t[1]) >= 31536000000000i64
      }
    }

## Text

`post_qualifies?/1`: at most one hashtag, at most one emoji, and at least
50 characters once the hashtags are cut out and the ends trimmed.

`~r/#\w+/` has no `u` flag, so `\w` is ASCII: `#café` is the hashtag
`#caf`, and `#日本` is no hashtag at all. The emoji pattern does have `u`
and counts code points in five ranges, two of them inside a third.
`String.length/1` counts graphemes, the clusters `st_cluster_end` finds
for `st_truncate`.

    export let st_text_ok(text: String): Boolean {
      if (st_tags(text, String.begin, 0) > 1) {
        false
      } else if (st_emojis(text, String.begin, 0) > 1) {
        false
      } else {
        let cut = st_untag(text, String.begin, String.begin, "");
        st_clusters_at_least(cut, st_first_solid(cut, String.begin), st_solid_end(cut), 50)
      }
    }

    let st_word(c: Int): Boolean {
      (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 95
    }

    let st_word_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && st_word(s[i])) { st_word_end(s, s.next(i)) } else { i }
    }

    let st_tag_at(s: String, i: StringIndex): Boolean {
      s[i] == 35 && s.next(i) < s.end && st_word(s[s.next(i)])
    }

    let st_tags(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) {
        n
      } else if (st_tag_at(s, i)) {
        st_tags(s, st_word_end(s, s.next(i)), n + 1)
      } else {
        st_tags(s, s.next(i), n)
      }
    }

The text with every hashtag removed: `from` is where the kept run began.

    let st_untag(s: String, i: StringIndex, from: StringIndex, acc: String): String {
      if (i >= s.end) {
        "${acc}${s.slice(from, i)}"
      } else if (st_tag_at(s, i)) {
        let e = st_word_end(s, s.next(i));
        st_untag(s, e, e, "${acc}${s.slice(from, i)}")
      } else {
        st_untag(s, s.next(i), from, acc)
      }
    }

    let st_emojis(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) {
        n
      } else {
        let c = s[i];
        let e = (c >= 127744 && c <= 129535) || (c >= 9728 && c <= 9983) || (c >= 9984 && c <= 10175);
        st_emojis(s, s.next(i), if (e) { n + 1 } else { n })
      }
    }

    let st_first_solid(s: String, i: StringIndex): StringIndex {
      if (i < s.end && st_space(s[i])) { st_first_solid(s, s.next(i)) } else { i }
    }

Where the trimmed text ends: after its last character that is not white space.

    let st_solid_end(s: String): StringIndex {
      st_solid_end_from(s, String.begin, String.begin)
    }

    let st_solid_end_from(s: String, i: StringIndex, last: StringIndex): StringIndex {
      if (i >= s.end) {
        last
      } else {
        let j = s.next(i);
        st_solid_end_from(s, j, if (st_space(s[i])) { last } else { j })
      }
    }

Whether `[i, e)` holds at least `n` grapheme clusters.

    let st_clusters_at_least(s: String, i: StringIndex, e: StringIndex, n: Int): Boolean {
      if (n <= 0) {
        true
      } else if (i >= e) {
        false
      } else {
        let t = s.slice(i, e);
        st_clusters_from(t, String.begin, n)
      }
    }

    let st_clusters_from(t: String, i: StringIndex, n: Int): Boolean {
      if (n <= 0) { true } else if (i >= t.end) { false } else { st_clusters_from(t, st_cluster_end(t, i), n - 1) }
    }

## Score

`calculate_score/1`: 15 log10(followers), plus five times followers per
followed capped at 20, rounded (half away from zero) and capped at 100.

    export let st_score(followers: Int, follows: Int): Int {
      let f = if (followers < 1) { 1 } else { followers };
      let g = if (follows < 1) { 1 } else { follows };
      let base = f.toFloat64().log10() * 15.0;
      let ratio = (followers.toFloat64() / g.toFloat64()) orelse panic();
      let bonus = if (ratio * 5.0 > 20.0) { 20.0 } else { ratio * 5.0 };
      let total = (base + bonus + 0.5).floor().toInt32Unsafe();
      if (total > 100) { 100 } else { total }
    }

## Time

`DateTime.from_iso8601/1`, as `parse_datetime/1` called it, then Ecto's
`:utc_datetime_usec`: `post_created_at` is the instant in UTC, written
`2026-09-30 06:40:58.408000`, or "" (NULL) for anything Elixir refuses.
Elixir takes `T` or a space between date and time, `.` or `,` before at
most six fraction digits (more are dropped), and `Z`, `+HH:MM`, `+HHMM` or
`+HH` (never `-00:00`), and refuses a missing offset, a 60th second and a
day the month does not have. A year before 1 is refused here, where Elixir
would take it; Bluesky's own clients never write one.

    export let st_utc(s: String): String {
      let t = st_iso(s);
      if (t.isEmpty) { "" } else { st_utc_text(t[0], t[1]) }
    }

`[seconds since 1970 in UTC, microseconds]`, or `[]`.

    let st_iso(s0: String): List<Int64> {
      let s = if (!s0.isEmpty && s0[String.begin] == 43) { s0.slice(s0.next(String.begin), s0.end) } else { s0 };
      if (!st_shape(s, String.begin, "dddd-dd-ddXdd:dd:dd")) {
        []
      } else {
        let y = st_num(s, 0, 4);
        let mo = st_num(s, 5, 2);
        let d = st_num(s, 8, 2);
        let h = st_num(s, 11, 2);
        let mi = st_num(s, 14, 2);
        let se = st_num(s, 17, 2);
        let rest = s.slice(st_skip(s, String.begin, 19), s.end);
        let frac = st_fraction(rest);
        if (frac.isEmpty) {
          []
        } else {
          let off = st_offset(rest.slice(st_skip(rest, String.begin, frac[1]), rest.end));
          if (off.isEmpty) {
            []
          } else if (y < 1 || mo < 1 || mo > 12 || d < 1 || d > st_month_days(y, mo)) {
            []
          } else if (h > 23 || mi > 59 || se > 59) {
            []
          } else {
            let secs = st_days_from_civil(y, mo, d) * 86400i64 + (h * 3600 + mi * 60 + se - off[0]).toInt64();
            [secs, frac[0].toInt64()]
          }
        }
      }
    }

Whether `s` from `i` has the shape of `p`: `d` a digit, `X` a `T` or a
space, anything else itself.

    let st_shape(s: String, i: StringIndex, p: String): Boolean {
      st_shape_at(s, i, p, String.begin)
    }

    let st_shape_at(s: String, i: StringIndex, p: String, j: StringIndex): Boolean {
      if (j >= p.end) {
        true
      } else if (i >= s.end) {
        false
      } else {
        let c = s[i];
        let k = p[j];
        let ok = if (k == 100) { st_digit(c) } else if (k == 88) { c == 84 || c == 32 } else { c == k };
        ok && st_shape_at(s, s.next(i), p, p.next(j))
      }
    }

The number in the `n` ASCII digits at code point `at`.

    let st_num(s: String, at: Int, n: Int): Int {
      st_num_from(s, st_skip(s, String.begin, at), n, 0)
    }

    let st_num_from(s: String, i: StringIndex, n: Int, acc: Int): Int {
      if (n <= 0) { acc } else { st_num_from(s, s.next(i), n - 1, acc * 10 + s[i] - 48) }
    }

`[microseconds, code points read]`, or `[]` for a `.` with no digit after it.

    let st_fraction(r: String): List<Int> {
      if (r.isEmpty || (r[String.begin] != 46 && r[String.begin] != 44)) {
        [0, 0]
      } else {
        st_frac_digits(r, r.next(String.begin), 0, 0, 1)
      }
    }

    let st_frac_digits(r: String, i: StringIndex, n: Int, us: Int, read: Int): List<Int> {
      if (i < r.end && st_digit(r[i])) {
        if (n < 6) {
          st_frac_digits(r, r.next(i), n + 1, us * 10 + r[i] - 48, read + 1)
        } else {
          st_frac_digits(r, r.next(i), n, us, read + 1)
        }
      } else if (n == 0) {
        []
      } else {
        [us * st_pow10(6 - n), read]
      }
    }

    let st_pow10(n: Int): Int {
      if (n <= 0) { 1 } else { 10 * st_pow10(n - 1) }
    }

`[offset in seconds]` when the rest is exactly an offset, else `[]`. The
patterns are tried in Elixir's order: `+HH:MM`, then `+HHMM`, then `+HH`,
the first whose shape fits decides.

    let st_offset(r: String): List<Int> {
      if (r == "Z") {
        [0]
      } else if (r == "-00:00" || r.isEmpty) {
        []
      } else {
        let c = r[String.begin];
        if (c != 43 && c != 45) {
          []
        } else {
          let sign = if (c == 45) { -1 } else { 1 };
          let t = r.slice(r.next(String.begin), r.end);
          let n = st_cps(t, String.begin, 0);
          if (n >= 5 && t[st_skip(t, String.begin, 2)] == 58) {
            st_offset_of(sign, t, 0, 3, 5, n)
          } else if (n >= 4) {
            st_offset_of(sign, t, 0, 2, 4, n)
          } else if (n >= 2) {
            st_offset_hours(sign, t, n)
          } else {
            []
          }
        }
      }
    }

    let st_offset_of(sign: Int, t: String, h_at: Int, m_at: Int, used: Int, n: Int): List<Int> {
      if (n != used) {
        []
      } else {
        let h1 = t[st_skip(t, String.begin, h_at)];
        let h2 = t[st_skip(t, String.begin, h_at + 1)];
        let m1 = t[st_skip(t, String.begin, m_at)];
        let m2 = t[st_skip(t, String.begin, m_at + 1)];
        st_offset_digits(sign, h1, h2, m1, m2)
      }
    }

    let st_offset_hours(sign: Int, t: String, n: Int): List<Int> {
      if (n != 2) {
        []
      } else {
        st_offset_digits(sign, t[String.begin], t[t.next(String.begin)], 48, 48)
      }
    }

    let st_offset_digits(sign: Int, h1: Int, h2: Int, m1: Int, m2: Int): List<Int> {
      if (h1 < 48 || h1 > 50 || !st_digit(h2) || m1 < 48 || m1 > 53 || !st_digit(m2)) {
        []
      } else {
        let hour = (h1 - 48) * 10 + h2 - 48;
        let min = (m1 - 48) * 10 + m2 - 48;
        if (hour >= 24) { [] } else { [((hour * 60 + min) * 60) * sign] }
      }
    }

    let st_leap(y: Int): Boolean {
      (((y % 4) orelse panic()) == 0 && ((y % 100) orelse panic()) != 0) || ((y % 400) orelse panic()) == 0
    }

    let st_month_days(y: Int, m: Int): Int {
      if (m == 2) { if (st_leap(y)) { 29 } else { 28 } } else if (m == 4 || m == 6 || m == 9 || m == 11) { 30 } else { 31 }
    }

days_from_civil and civil_from_days (Howard Hinnant), for years from 1 on.

    let st_days_from_civil(y0: Int, m: Int, d: Int): Int64 {
      let y = if (m <= 2) { y0 - 1 } else { y0 };
      let era = (y / 400) orelse panic();
      let yoe = y - era * 400;
      let mp = if (m > 2) { m - 3 } else { m + 9 };
      let doy = (((153 * mp + 2) / 5) orelse panic()) + d - 1;
      let doe = yoe * 365 + ((yoe / 4) orelse panic()) - ((yoe / 100) orelse panic()) + doy;
      era.toInt64() * 146097i64 + doe.toInt64() - 719468i64
    }

    let st_floor_div(a: Int64, b: Int64): Int64 {
      let q = (a / b) orelse panic();
      if (q * b > a) { q - 1i64 } else { q }
    }

    let st_utc_text(secs: Int64, us: Int64): String {
      let days = st_floor_div(secs, 86400i64);
      let sod = secs - days * 86400i64;
      let z = days + 719468i64;
      let era = st_floor_div(z, 146097i64);
      let doe = z - era * 146097i64;
      let yoe = ((doe - ((doe / 1460i64) orelse panic()) + ((doe / 36524i64) orelse panic()) - ((doe / 146096i64) orelse panic())) / 365i64) orelse panic();
      let doy = doe - (365i64 * yoe + ((yoe / 4i64) orelse panic()) - ((yoe / 100i64) orelse panic()));
      let mp = ((5i64 * doy + 2i64) / 153i64) orelse panic();
      let d = doy - (((153i64 * mp + 2i64) / 5i64) orelse panic()) + 1i64;
      let m = if (mp < 10i64) { mp + 3i64 } else { mp - 9i64 };
      let y = yoe + era * 400i64 + (if (m <= 2i64) { 1i64 } else { 0i64 });
      let h = (sod / 3600i64) orelse panic();
      let mi = ((sod - h * 3600i64) / 60i64) orelse panic();
      let se = sod - h * 3600i64 - mi * 60i64;
      "${st_pad(y, 4)}-${st_pad(m, 2)}-${st_pad(d, 2)} ${st_pad(h, 2)}:${st_pad(mi, 2)}:${st_pad(se, 2)}.${st_pad(us, 6)}"
    }

    let st_pad(n: Int64, w: Int): String {
      st_pad_text(n.toString(), w)
    }

    let st_pad_text(t: String, w: Int): String {
      if (st_cps(t, String.begin, 0) >= w) { t } else { st_pad_text("0${t}", w) }
    }

## The url

`URI.parse/1` cuts a url with RFC 3986's regular expression, without the
`u` flag and with `.` not matching a newline,
`^(([a-z][a-z0-9\+\-\.]*):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?`,
and the authority with `(^(.*)@)?(\[[a-zA-Z0-9:.]*\]|[^:]*)(:(\d*))?`.
Every link here starts `http://` or `https://`, so the scheme is one of
those two and there is always an authority. What falls out, and what the
extractor and `Link` do with it:

- the userinfo is everything before the last `@` (before any newline); an
  empty one is dropped;
- the host is `[...]` or everything up to the first `:`; an empty host is
  `nil`, and a url whose host is `nil` is hashed as it is and has no domain;
- the port is the digits after `:`, anything after them ignored; the
  scheme's own (80, 443) is left out when the url is written again;
- the fragment stops at a newline, and whatever follows it is lost.

`[userinfo, host, port digits, path, query, fragment, which]`, where
`which` says with a `1` or `0` each whether the userinfo, host, query and
fragment are there at all (not `nil`); a missing port is "".

    let st_url_parts(url: String): List<String> {
      let a = st_after(url, "://");
      let ae = st_find_any(url, a, "/?#");
      let authority = url.slice(a, ae);
      let pe = st_find_any(url, ae, "?#");
      let path = url.slice(ae, pe);
      let qe = if (pe < url.end && url[pe] == 63) { st_find_any(url, url.next(pe), "#") } else { pe };
      let has_q = pe < url.end && url[pe] == 63;
      let query = if (has_q) { url.slice(url.next(pe), qe) } else { "" };
      let has_f = qe < url.end;
      let fragment = if (has_f) { url.slice(url.next(qe), st_find_any(url, url.next(qe), "\n")) } else { "" };
      let qf = "${st_bit(has_q)}${st_bit(has_f)}";
      if (authority.isEmpty) {
        ["", "", "", path, query, fragment, "01${qf}"]
      } else {
        let line = authority.slice(String.begin, st_find_any(authority, String.begin, "\n"));
        let at = st_last(line, String.begin, 64, line.end);
        let has_u = at < line.end && at != String.begin;
        let user = if (has_u) { authority.slice(String.begin, at) } else { "" };
        let hs = if (at >= line.end) { String.begin } else { authority.next(at) };
        let bracket = st_bracket_end(authority, hs);
        let he = if (bracket > hs) { bracket } else { st_find_any(authority, hs, ":") };
        let raw = authority.slice(hs, he);
        let host = if (raw.isEmpty) { "" } else { st_unbracket(raw) };
        let port = if (he < authority.end && authority[he] == 58) { st_port(authority, authority.next(he)) } else { "" };
        [user, host, port, path, query, fragment, "${st_bit(has_u)}${st_bit(!raw.isEmpty)}${qf}"]
      }
    }

    let st_bit(b: Boolean): String { if (b) { "1" } else { "0" } }

    let st_has_part(p: List<String>, k: Int): Boolean {
      st_skip(p[6], String.begin, k) < p[6].end && p[6][st_skip(p[6], String.begin, k)] == 49
    }

Where the text after the first `sep` starts.

    let st_after(s: String, sep: String): StringIndex {
      st_after_at(s, String.begin, sep)
    }

    let st_after_at(s: String, i: StringIndex, sep: String): StringIndex {
      if (i >= s.end) {
        i
      } else if (st_starts_at(s, i, sep, String.begin)) {
        st_skip(s, i, st_cps(sep, String.begin, 0))
      } else {
        st_after_at(s, s.next(i), sep)
      }
    }

The first index from `i` whose code point is one of `set`'s, or the end.

    let st_find_any(s: String, i: StringIndex, set: String): StringIndex {
      if (i >= s.end || st_has(set, String.begin, s[i])) { i } else { st_find_any(s, s.next(i), set) }
    }

    let st_has(set: String, j: StringIndex, c: Int): Boolean {
      if (j >= set.end) { false } else if (set[j] == c) { true } else { st_has(set, set.next(j), c) }
    }

The index of the last `c` from `i`, or `none`.

    let st_last(s: String, i: StringIndex, c: Int, none: StringIndex): StringIndex {
      if (i >= s.end) { none } else { st_last(s, s.next(i), c, if (s[i] == c) { i } else { none }) }
    }

Where `\[[a-zA-Z0-9:.]*\]` from `i` ends, or `i` when it does not match.

    let st_bracket_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end || s[i] != 91) { i } else { st_bracket_in(s, s.next(i), i) }
    }

    let st_bracket_in(s: String, j: StringIndex, i: StringIndex): StringIndex {
      if (j >= s.end) {
        i
      } else {
        let c = s[j];
        if (c == 93) {
          s.next(j)
        } else if (st_word(c) && c != 95 || c == 58 || c == 46) {
          st_bracket_in(s, s.next(j), i)
        } else {
          i
        }
      }
    }

`String.trim_leading(host, "[") |> String.trim_trailing("]")`: every `[`
in front and every `]` behind.

    let st_unbracket(h: String): String {
      let a = st_skip_while(h, String.begin, 91);
      h.slice(a, st_trim_back(h, a, 93))
    }

    let st_skip_while(s: String, i: StringIndex, c: Int): StringIndex {
      if (i < s.end && s[i] == c) { st_skip_while(s, s.next(i), c) } else { i }
    }

The end of `s` less every trailing `c`, not before `from`.

    let st_trim_back(s: String, from: StringIndex, c: Int): StringIndex {
      st_trim_back_at(s, from, c, from)
    }

    let st_trim_back_at(s: String, i: StringIndex, c: Int, last: StringIndex): StringIndex {
      if (i >= s.end) { last } else { st_trim_back_at(s, s.next(i), c, if (s[i] == c) { last } else { s.next(i) }) }
    }

The port's digits as `Integer.to_string(String.to_integer(digits))` writes
them, no leading zeros, or "" for none.

    let st_port(s: String, i: StringIndex): String {
      let e = st_digits_end(s, i);
      if (e == i) { "" } else { st_no_zeros(s.slice(i, e)) }
    }

    let st_digits_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && st_digit(s[i])) { st_digits_end(s, s.next(i)) } else { i }
    }

    let st_no_zeros(d: String): String {
      let a = st_skip_while(d, String.begin, 48);
      if (a >= d.end) { "0" } else { d.slice(a, d.end) }
    }

### The domain, and banned hosts

`Link.extract_domain/1`: the host lower-cased, less one `www.`; "" for no
host (and Ecto would have stored "" as NULL anyway).

    export let st_url_domain(url: String): String {
      let p = st_url_parts(url);
      if (!st_has_part(p, 1)) {
        ""
      } else {
        let h = st_lower(p[1]);
        if (st_starts(h, "www.")) { h.slice(st_skip(h, String.begin, 4), h.end) } else { h }
      }
    }

`domain_banned?/1` compares the host as it was written, not lower-cased:
`X.com` is not banned.

    export let st_url_banned(url: String): Boolean {
      let host = st_url_parts(url)[1];
      !st_banned.filter { (b): Boolean => host == b || st_ends(host, ".${b}") }.isEmpty
    }

    let st_banned: List<String> = [
      "tinyurl.com", "bit.ly", "t.co", "x.com", "twitter.com", "media.tenor.com",
      "coinbase.com", "binance.com", "binance.us", "kraken.com", "crypto.com", "gemini.com",
      "kucoin.com", "bybit.com", "okx.com", "bitfinex.com", "bitstamp.net", "gate.io", "huobi.com",
      "mexc.com", "bitget.com", "coindesk.com", "cointelegraph.com", "decrypt.co", "theblock.co",
      "bitcoinmagazine.com", "opensea.io", "uniswap.org", "rarible.com", "foundation.app", "blur.io",
      "looksrare.org", "pancakeswap.finance", "aave.com", "coingecko.com", "coinmarketcap.com",
      "dextools.io", "dexscreener.com", "pump.fun", "metamask.io", "phantom.app", "trustwallet.com"
    ];

### What is hashed

`Link.hash_url/1` hashes `normalize_url/1`: the url written again by
`URI.to_string/1` with the host lower-cased, every trailing `/` cut from
the path (an empty path is `/`), and the query decoded into a map, sorted
and encoded again. A url without a host is hashed as it came. The SHA-256
and its first 32 hex digits are the caller's (Temper has no hash).

    export let st_url_normal(url: String): String {
      let p = st_url_parts(url);
      if (!st_has_part(p, 1)) {
        url
      } else {
        let scheme = url.slice(String.begin, st_find_any(url, String.begin, ":"));
        let host = st_lower(p[1]);
        let user = if (st_has_part(p, 0)) { "${p[0]}@" } else { "" };
        let h = if (st_has(host, String.begin, 58)) { "[${host}]" } else { host };
        let dflt = if (scheme == "https") { "443" } else { "80" };
        let port = if (p[2].isEmpty || p[2] == dflt) { "" } else { ":${p[2]}" };
        let path0 = p[3].slice(String.begin, st_trim_back(p[3], String.begin, 47));
        let path = if (path0.isEmpty) { "/" } else { path0 };
        let query = if (st_has_part(p, 2)) { "?${st_query(p[4])}" } else { "" };
        let frag = if (st_has_part(p, 3)) { "#${p[5]}" } else { "" };
        "${scheme}://${user}${h}${port}${path}${query}${frag}"
      }
    }

`q |> URI.decode_query() |> Enum.sort() |> URI.encode_query()`. The query
is split at each `&` (a trailing one ends it; an empty piece between two is
the key ""), each piece at its first `=`, and both sides decoded as a form:
`+` is a space, `%` and two hex digits a byte, any other `%` itself. Into a
map, so a key's last value wins. Sorted by the keys' bytes, and written
again with every byte but `A-Za-z0-9-._~` as `%XX`, a space as `+`.

The decoded bytes are kept as lowercase hex, two digits a byte, which sorts
as the bytes do and never has to be a String of its own (`%FF` is no
character). Each piece is `keyhex=valuehex`.

    let st_query(q: String): String {
      let parts = q.split("&");
      let pieces = if (!parts.isEmpty && parts[parts.length - 1].isEmpty) { parts.slice(0, parts.length - 1) } else { parts };
      let kv = pieces.map { (p): String => st_form_pair(p) };
      st_query_emit(kv, "", false, "")
    }

    let st_form_pair(p: String): String {
      let eq = st_find_any(p, String.begin, "=");
      let k = st_form_hex(p.slice(String.begin, eq), String.begin, "");
      let v = if (eq < p.end) { st_form_hex(p.slice(p.next(eq), p.end), String.begin, "") } else { "" };
      "${k}=${v}"
    }

Each next key in byte order after `prev`, with its last value.

    let st_query_emit(kv: List<String>, prev: String, started: Boolean, acc: String): String {
      let next = st_query_min(kv, 0, prev, started, "", false);
      if (next.isEmpty) {
        acc
      } else {
        let key = next.slice(next.next(String.begin), next.end);
        let pair = "${st_form_enc(key, String.begin, "")}=${st_form_enc(st_query_last(kv, 0, key, ""), String.begin, "")}";
        st_query_emit(kv, key, true, if (started) { "${acc}&${pair}" } else { pair })
      }
    }

The smallest key after `prev`, behind a `k` so that "" is a key and not
"none left", or "" for none.

    let st_query_min(kv: List<String>, i: Int, prev: String, started: Boolean, best: String, found: Boolean): String {
      if (i >= kv.length) {
        if (found) { "k${best}" } else { "" }
      } else {
        let key = st_key_of(kv[i]);
        let after = !started || st_less(prev, key);
        let better = after && (!found || st_less(key, best));
        st_query_min(kv, i + 1, prev, started, if (better) { key } else { best }, found || better)
      }
    }

    let st_query_last(kv: List<String>, i: Int, key: String, value: String): String {
      if (i >= kv.length) {
        value
      } else {
        let p = kv[i];
        let v = if (st_key_of(p) == key) { p.slice(p.next(st_find_any(p, String.begin, "=")), p.end) } else { value };
        st_query_last(kv, i + 1, key, v)
      }
    }

    let st_key_of(p: String): String {
      p.slice(String.begin, st_find_any(p, String.begin, "="))
    }

Byte order of two hex strings: code point by code point, a prefix first.

    let st_less(a: String, b: String): Boolean {
      st_less_at(a, String.begin, b, String.begin)
    }

    let st_less_at(a: String, i: StringIndex, b: String, j: StringIndex): Boolean {
      if (j >= b.end) {
        false
      } else if (i >= a.end) {
        true
      } else if (a[i] != b[j]) {
        a[i] < b[j]
      } else {
        st_less_at(a, a.next(i), b, b.next(j))
      }
    }

`URI.decode_www_form/1`, to hex.

    let st_form_hex(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        let j = s.next(i);
        if (c == 43) {
          st_form_hex(s, j, "${acc}20")
        } else if (c == 37 && j < s.end && st_hexd(s[j]) >= 0 && s.next(j) < s.end && st_hexd(s[s.next(j)]) >= 0) {
          st_form_hex(s, s.next(s.next(j)), "${acc}${st_hex2(st_hexd(s[j]) * 16 + st_hexd(s[s.next(j)]))}")
        } else {
          st_form_hex(s, j, "${acc}${st_utf8_hex(c)}")
        }
      }
    }

    let st_hexd(c: Int): Int {
      if (c >= 48 && c <= 57) { c - 48 } else if (c >= 65 && c <= 70) { c - 55 } else if (c >= 97 && c <= 102) { c - 87 } else { -1 }
    }

    let st_hex2(b: Int): String {
      "${st_hex_digit((b / 16) orelse panic())}${st_hex_digit((b % 16) orelse panic())}"
    }

    let st_hex_digit(d: Int): String {
      if (d < 10) { d.toString() } else { String.fromCodePoint(87 + d) orelse panic() }
    }

    let st_utf8_hex(c: Int): String {
      if (c < 128) {
        st_hex2(c)
      } else if (c < 2048) {
        "${st_hex2(192 + ((c / 64) orelse panic()))}${st_hex2(128 + ((c % 64) orelse panic()))}"
      } else if (c < 65536) {
        "${st_hex2(224 + ((c / 4096) orelse panic()))}${st_hex2(128 + (((c / 64) orelse panic()) % 64 orelse panic()))}${st_hex2(128 + ((c % 64) orelse panic()))}"
      } else {
        "${st_hex2(240 + ((c / 262144) orelse panic()))}${st_hex2(128 + (((c / 4096) orelse panic()) % 64 orelse panic()))}${st_hex2(128 + (((c / 64) orelse panic()) % 64 orelse panic()))}${st_hex2(128 + ((c % 64) orelse panic()))}"
      }
    }

`URI.encode_www_form/1`, from hex.

    let st_form_enc(h: String, i: StringIndex, acc: String): String {
      if (i >= h.end) {
        acc
      } else {
        let j = h.next(i);
        let b = st_hexd(h[i]) * 16 + st_hexd(h[j]);
        let out = if (b == 32) {
          "+"
        } else if (st_word(b) && b != 95 || b == 45 || b == 46 || b == 95 || b == 126) {
          String.fromCodePoint(b) orelse panic()
        } else {
          "%${st_hex_digit_up((b / 16) orelse panic())}${st_hex_digit_up((b % 16) orelse panic())}"
        };
        st_form_enc(h, h.next(j), "${acc}${out}")
      }
    }

    let st_hex_digit_up(d: Int): String {
      if (d < 10) { d.toString() } else { String.fromCodePoint(55 + d) orelse panic() }
    }

### Lower case

`String.downcase/1`, which Temper has no word for: Unicode's lower-case
mapping, dumped from Elixir 1.18 (production's) for every code point it
changes, 1460 of them, as runs `[first, last, add, step]`: each code point
from `first` to `last`, `step` apart, becomes itself plus `add`. The one
that becomes two code points, `İ` to `i̇`, is its own case. Elixir's
default mode has no final-sigma rule, so neither has this.

    export let st_lower(s: String): String {
      st_lower_from(s, String.begin, "")
    }

    let st_lower_from(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        let l = if (c == 304) { "i${String.fromCodePoint(775) orelse panic()}" } else { String.fromCodePoint(st_lower_cp(c)) orelse panic() };
        st_lower_from(s, s.next(i), "${acc}${l}")
      }
    }

    let st_lower_cp(c: Int): Int {
      if (c >= 65 && c <= 90) {
        c + 32
      } else if (c < 192) {
        c
      } else {
        c + st_lower_find(c, 0, (st_lower_runs.length / 4) orelse panic())
      }
    }

    let st_lower_find(c: Int, lo: Int, hi: Int): Int {
      if (lo >= hi) {
        0
      } else {
        let mid = (lo + hi) / 2 orelse lo;
        let first = st_lower_runs[mid * 4];
        let last = st_lower_runs[mid * 4 + 1];
        if (c < first) {
          st_lower_find(c, lo, mid)
        } else if (c > last) {
          st_lower_find(c, mid + 1, hi)
        } else if (((c - first) % st_lower_runs[mid * 4 + 3] orelse panic()) == 0) {
          st_lower_runs[mid * 4 + 2]
        } else {
          0
        }
      }
    }

    let st_lower_runs: List<Int> = [
      65, 90, 32, 1, 192, 214, 32, 1, 216, 222, 32, 1, 256, 302, 1, 2, 306, 310, 1, 2, 313,
      327, 1, 2, 330, 374, 1, 2, 376, 376, -121, 1, 377, 381, 1, 2, 385, 385, 210, 1, 386,
      388, 1, 2, 390, 390, 206, 1, 391, 391, 1, 1, 393, 394, 205, 1, 395, 395, 1, 1, 398,
      398, 79, 1, 399, 399, 202, 1, 400, 400, 203, 1, 401, 401, 1, 1, 403, 403, 205, 1, 404,
      404, 207, 1, 406, 406, 211, 1, 407, 407, 209, 1, 408, 408, 1, 1, 412, 412, 211, 1,
      413, 413, 213, 1, 415, 415, 214, 1, 416, 420, 1, 2, 422, 422, 218, 1, 423, 423, 1, 1,
      425, 425, 218, 1, 428, 428, 1, 1, 430, 430, 218, 1, 431, 431, 1, 1, 433, 434, 217, 1,
      435, 437, 1, 2, 439, 439, 219, 1, 440, 440, 1, 1, 444, 444, 1, 1, 452, 452, 2, 1, 453,
      453, 1, 1, 455, 455, 2, 1, 456, 456, 1, 1, 458, 458, 2, 1, 459, 475, 1, 2, 478, 494,
      1, 2, 497, 497, 2, 1, 498, 500, 1, 2, 502, 502, -97, 1, 503, 503, -56, 1, 504, 542, 1,
      2, 544, 544, -130, 1, 546, 562, 1, 2, 570, 570, 10795, 1, 571, 571, 1, 1, 573, 573,
      -163, 1, 574, 574, 10792, 1, 577, 577, 1, 1, 579, 579, -195, 1, 580, 580, 69, 1, 581,
      581, 71, 1, 582, 590, 1, 2, 880, 882, 1, 2, 886, 886, 1, 1, 895, 895, 116, 1, 902,
      902, 38, 1, 904, 906, 37, 1, 908, 908, 64, 1, 910, 911, 63, 1, 913, 929, 32, 1, 931,
      939, 32, 1, 975, 975, 8, 1, 984, 1006, 1, 2, 1012, 1012, -60, 1, 1015, 1015, 1, 1,
      1017, 1017, -7, 1, 1018, 1018, 1, 1, 1021, 1023, -130, 1, 1024, 1039, 80, 1, 1040,
      1071, 32, 1, 1120, 1152, 1, 2, 1162, 1214, 1, 2, 1216, 1216, 15, 1, 1217, 1229, 1, 2,
      1232, 1326, 1, 2, 1329, 1366, 48, 1, 4256, 4293, 7264, 1, 4295, 4295, 7264, 1, 4301,
      4301, 7264, 1, 5024, 5103, 38864, 1, 5104, 5109, 8, 1, 7305, 7305, 1, 1, 7312, 7354,
      -3008, 1, 7357, 7359, -3008, 1, 7680, 7828, 1, 2, 7838, 7838, -7615, 1, 7840, 7934, 1,
      2, 7944, 7951, -8, 1, 7960, 7965, -8, 1, 7976, 7983, -8, 1, 7992, 7999, -8, 1, 8008,
      8013, -8, 1, 8025, 8031, -8, 2, 8040, 8047, -8, 1, 8072, 8079, -8, 1, 8088, 8095, -8,
      1, 8104, 8111, -8, 1, 8120, 8121, -8, 1, 8122, 8123, -74, 1, 8124, 8124, -9, 1, 8136,
      8139, -86, 1, 8140, 8140, -9, 1, 8152, 8153, -8, 1, 8154, 8155, -100, 1, 8168, 8169,
      -8, 1, 8170, 8171, -112, 1, 8172, 8172, -7, 1, 8184, 8185, -128, 1, 8186, 8187, -126,
      1, 8188, 8188, -9, 1, 8486, 8486, -7517, 1, 8490, 8490, -8383, 1, 8491, 8491, -8262,
      1, 8498, 8498, 28, 1, 8544, 8559, 16, 1, 8579, 8579, 1, 1, 9398, 9423, 26, 1, 11264,
      11311, 48, 1, 11360, 11360, 1, 1, 11362, 11362, -10743, 1, 11363, 11363, -3814, 1,
      11364, 11364, -10727, 1, 11367, 11371, 1, 2, 11373, 11373, -10780, 1, 11374, 11374,
      -10749, 1, 11375, 11375, -10783, 1, 11376, 11376, -10782, 1, 11378, 11378, 1, 1,
      11381, 11381, 1, 1, 11390, 11391, -10815, 1, 11392, 11490, 1, 2, 11499, 11501, 1, 2,
      11506, 11506, 1, 1, 42560, 42604, 1, 2, 42624, 42650, 1, 2, 42786, 42798, 1, 2, 42802,
      42862, 1, 2, 42873, 42875, 1, 2, 42877, 42877, -35332, 1, 42878, 42886, 1, 2, 42891,
      42891, 1, 1, 42893, 42893, -42280, 1, 42896, 42898, 1, 2, 42902, 42920, 1, 2, 42922,
      42922, -42308, 1, 42923, 42923, -42319, 1, 42924, 42924, -42315, 1, 42925, 42925,
      -42305, 1, 42926, 42926, -42308, 1, 42928, 42928, -42258, 1, 42929, 42929, -42282, 1,
      42930, 42930, -42261, 1, 42931, 42931, 928, 1, 42932, 42946, 1, 2, 42948, 42948, -48,
      1, 42949, 42949, -42307, 1, 42950, 42950, -35384, 1, 42951, 42953, 1, 2, 42955, 42955,
      -42343, 1, 42956, 42956, 1, 1, 42960, 42960, 1, 1, 42966, 42970, 1, 2, 42972, 42972,
      -42561, 1, 42997, 42997, 1, 1, 65313, 65338, 32, 1, 66560, 66599, 40, 1, 66736, 66771,
      40, 1, 66928, 66938, 39, 1, 66940, 66954, 39, 1, 66956, 66962, 39, 1, 66964, 66965,
      39, 1, 68736, 68786, 64, 1, 68944, 68965, 32, 1, 71840, 71871, 32, 1, 93760, 93791,
      32, 1, 125184, 125217, 34, 1
    ];
