# Blinks, the reading half

What `/blinks` and `/blinks-reader` compute rather than fetch: a link's
domain, its headline, the day it was saved, an archive week's label, the
query string a page's state is kept in, the tag list a click makes, and
where the newspaper's two columns split. The pages are Blimp programs in
the browser (`static/blinks/*.blimp`), the rows come from
`src/99_blinks.blimp`; walking a decoded row stays Blimp, because a Temper
function takes strings, numbers and lists, not a Blimp map. So a row's
`nil`s arrive here as `""` with a flag beside them when the difference
matters, as it does for a title: Elixir's `blink.title || blink.url` keeps
an empty title, and so does `blk_headline`.

No classes: a Temper class on the Blimp backend is an actor, and actors are
never collected. Every name starts `blk_`.

    let { starts_with } = import("../text");

## Where a link points

`BlinksLive.domain/1`: the host `URI.parse/1` finds, less a leading
`www.`, or "" when there is none. A host is what follows `scheme://` up to
the first `/`, `?` or `#`, after any `user@` and before any `:port`.

    export let blk_host(url: String): String {
      let sep = url.indexOf("://");
      if (sep is StringIndex) {
        let rest = url.slice(url.step(sep, 3), url.end);
        let auth = rest.slice(String.begin, blk_auth_end(rest, String.begin));
        let at = blk_after_last_at(auth, String.begin, String.begin);
        let hostport = auth.slice(at, auth.end);
        hostport.slice(String.begin, blk_port_start(hostport, String.begin))
      } else {
        ""
      }
    }

    let blk_auth_end(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        s.end
      } else {
        let c = s[i];
        if (c == 47 || c == 63 || c == 35) { i } else { blk_auth_end(s, s.next(i)) }
      }
    }

    let blk_after_last_at(s: String, i: StringIndex, found: StringIndex): StringIndex {
      if (i >= s.end) {
        found
      } else if (s[i] == 64) {
        blk_after_last_at(s, s.next(i), s.next(i))
      } else {
        blk_after_last_at(s, s.next(i), found)
      }
    }

    let blk_port_start(s: String, i: StringIndex): StringIndex {
      if (i >= s.end) {
        s.end
      } else if (s[i] == 58) {
        i
      } else {
        blk_port_start(s, s.next(i))
      }
    }

    export let blk_domain(url: String): String {
      let host = blk_host(url);
      if (starts_with(host, "www.")) { host.slice(host.step(String.begin, 4), host.end) } else { host }
    }

The reader's `domain/1` answers the whole url when there is no host.

    export let blk_domain_or_url(url: String): String {
      let d = blk_domain(url);
      if (d == "" && blk_host(url) == "") { url } else { d }
    }

What the row says the link is: the site's own name when the enricher found
one, else the domain.

    export let blk_site_label(site_name: String, url: String): String {
      if (site_name == "") { blk_domain(url) } else { site_name }
    }

The two archives every row links, and where a dead link's title goes
instead of the link.

    export let blk_wayback(url: String): String { "https://web.archive.org/web/*/${url}" }

    export let blk_archive_ph(url: String): String { "https://archive.ph/newest/${url}" }

    export let blk_dead_href(url: String): String { "https://web.archive.org/web/2/${url}" }

## Headlines

`headline/1`: the first quote, in curly quotes, wins; then the first post
of a Bluesky thread, cut to `max` characters (140 on the newspaper, 300 in
the reader); then the title, even an empty one; then the url.
`String.slice/3` counts graphemes and this counts code points, so a
headline cut through a flag or a family emoji ends one piece sooner or
later than Phoenix's.

    export let blk_headline(first_quote: String, has_quote: Boolean, thread_text: String, has_thread: Boolean, title: String, has_title: Boolean, url: String, max: Int): String {
      if (has_quote) {
        "“${first_quote}”"
      } else if (has_thread) {
        blk_cut(thread_text, max)
      } else if (has_title) {
        title
      } else {
        url
      }
    }

The first `n` code points of `s`.

    export let blk_cut(s: String, n: Int): String {
      s.slice(String.begin, blk_step_upto(s, String.begin, n))
    }

    let blk_step_upto(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { blk_step_upto(s, s.next(i), n - 1) }
    }

How many code points, for the column estimate below.

    export let blk_chars(s: String): Int { blk_count(s, String.begin, 0) }

    let blk_count(s: String, i: StringIndex, acc: Int): Int {
      if (i >= s.end) { acc } else { blk_count(s, s.next(i), acc + 1) }
    }

## Dates

`inserted_at` comes as Postgres and Jason both write a `timestamp(0)`:
`2026-09-17T23:17:53`. The reader stamps each card `%b %-d`, `Sep 17`;
the archives head a week `Week of Sep 14 – Sep 20, 2026`, Monday to
Sunday, which crosses a month or a year as the calendar does.

    export let blk_month_abbrs: List<String> = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    export let blk_stamp(iso: String): String {
      let m = blk_field(iso, 5, 2);
      let d = blk_field(iso, 8, 2);
      if (m < 1 || m > 12 || d < 1) { "" } else { "${blk_month_abbrs[m - 1]} ${d.toString()}" }
    }

    export let blk_week_label(monday: String): String {
      let y = blk_field(monday, 0, 4);
      let m = blk_field(monday, 5, 2);
      let d = blk_field(monday, 8, 2);
      if (y < 0 || m < 1 || m > 12 || d < 1) {
        ""
      } else {
        let end = blk_civil(blk_days_of(y, m, d) + 6);
        "Week of ${blk_month_abbrs[m - 1]} ${d.toString()} – ${blk_month_abbrs[end[1] - 1]} ${end[2].toString()}, ${end[0].toString()}"
      }
    }

`n` digits at character `at`, or -1.

    let blk_field(s: String, at: Int, n: Int): Int {
      let from = s.step(String.begin, at);
      let to = s.step(from, n);
      if (to > s.end) { -1 } else { blk_digits(s.slice(from, to), String.begin, 0) }
    }

    let blk_digits(s: String, i: StringIndex, acc: Int): Int {
      if (i >= s.end) {
        if (s.isEmpty) { -1 } else { acc }
      } else {
        let c = s[i];
        if (c < 48 || c > 57) { -1 } else { blk_digits(s, s.next(i), acc * 10 + c - 48) }
      }
    }

Days since 1970 and back (Howard Hinnant's), as in the gallery module,
kept here so this one stands alone.

    let blk_div(a: Int, b: Int): Int {
      let q = (a / b) orelse panic();
      if (q * b > a) { q - 1 } else { q }
    }

    export let blk_days_of(y0: Int, m: Int, d: Int): Int {
      let y = if (m <= 2) { y0 - 1 } else { y0 };
      let era = blk_div(y, 400);
      let yoe = y - era * 400;
      let mp = if (m > 2) { m - 3 } else { m + 9 };
      let doy = blk_div(153 * mp + 2, 5) + d - 1;
      let doe = yoe * 365 + blk_div(yoe, 4) - blk_div(yoe, 100) + doy;
      era * 146097 + doe - 719468
    }

    export let blk_civil(days: Int): List<Int> {
      let z = days + 719468;
      let era = blk_div(z, 146097);
      let doe = z - era * 146097;
      let yoe = blk_div(doe - blk_div(doe, 1460) + blk_div(doe, 36524) - blk_div(doe, 146096), 365);
      let doy = doe - (365 * yoe + blk_div(yoe, 4) - blk_div(yoe, 100));
      let mp = blk_div(5 * doy + 2, 153);
      let d = doy - blk_div(153 * mp + 2, 5) + 1;
      let m = if (mp < 10) { mp + 3 } else { mp - 9 };
      let y = if (m <= 2) { yoe + era * 400 + 1 } else { yoe + era * 400 };
      [y, m, d]
    }

A `?week=` is any day of a week (`Date.beginning_of_week/1`): its Monday,
`YYYY-MM-DD`, or "" for something that is not a date.

    export let blk_monday(iso: String): String {
      let y = blk_field(iso, 0, 4);
      let m = blk_field(iso, 5, 2);
      let d = blk_field(iso, 8, 2);
      if (y < 0 || m < 1 || m > 12 || d < 1 || d > 31 || iso.end > iso.step(String.begin, 10) || iso.slice(iso.step(String.begin, 4), iso.step(String.begin, 5)) != "-" || iso.slice(iso.step(String.begin, 7), iso.step(String.begin, 8)) != "-") {
        ""
      } else {
        let days = blk_days_of(y, m, d);
        let c = blk_civil(days);
        if (c[1] != m || c[2] != d) {
          ""
        } else {
          // 1970-01-01 was a Thursday: (days + 3) mod 7 is 0 on a Monday
          let back = (days + 3) - blk_div(days + 3, 7) * 7;
          let mon = blk_civil(days - back);
          "${mon[0].toString()}-${blk_two(mon[1])}-${blk_two(mon[2])}"
        }
      }
    }

    let blk_two(n: Int): String { if (n < 10) { "0${n.toString()}" } else { n.toString() } }

## Counts and labels

    export let blk_comment_label(n: Int): String {
      if (n == 0) { "chat" } else if (n == 1) { "1 comment" } else { "${n.toString()} comments" }
    }

## Tags

A page's selected tags are the `?tags=` value, comma separated, which is
how they are kept here too: a list only grows through a `ListBuilder`,
which is an actor. The newspaper adds a clicked tag at the end
(`selected ++ [tag]`), the reader at the front (`[tag | tags]`); both drop
it when it is already there.

    export let blk_tag_list(csv: String): List<String> {
      csv.split(",").map { (t): String => blk_trim(t) }.filter { (t): Boolean => t != "" }
    }

    export let blk_has_tag(csv: String, tag: String): Boolean {
      blk_tag_list(csv).filter { (t): Boolean => t == tag }.length > 0
    }

    export let blk_toggle_tag(csv: String, tag: String, at_front: Boolean): String {
      let tags = blk_tag_list(csv);
      if (blk_has_tag(csv, tag)) {
        tags.filter { (t): Boolean => t != tag }.join(",") { (t): String => t }
      } else if (tags.isEmpty) {
        tag
      } else if (at_front) {
        "${tag},${tags.join(",") { (t): String => t }}"
      } else {
        "${tags.join(",") { (t): String => t }},${tag}"
      }
    }

    let blk_trim(s: String): String {
      s.slice(blk_skip(s, String.begin), blk_back(s, s.end))
    }

    let blk_skip(s: String, i: StringIndex): StringIndex {
      if (i < s.end && (s[i] == 32 || s[i] == 9 || s[i] == 10 || s[i] == 13)) { blk_skip(s, s.next(i)) } else { i }
    }

    let blk_back(s: String, n: StringIndex): StringIndex {
      if (n > String.begin) {
        let p = s.prev(n);
        let c = s[p];
        if (c == 32 || c == 9 || c == 10 || c == 13) { blk_back(s, p) } else { n }
      } else {
        n
      }
    }

## Query strings

`URI.encode_query/1`'s encoding: unreserved characters as they are, a
space as `+`, every other byte `%XX`.

    export let blk_encode(s: String): String {
      blk_enc_loop(s, String.begin, "")
    }

    let blk_enc_loop(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        let piece = if (c == 32) {
          "+"
        } else if (blk_unreserved(c)) {
          s.slice(i, s.next(i))
        } else {
          blk_pct_utf8(c)
        };
        blk_enc_loop(s, s.next(i), "${acc}${piece}")
      }
    }

    let blk_unreserved(c: Int): Boolean {
      if (c >= 97 && c <= 122) {
        true
      } else if (c >= 65 && c <= 90) {
        true
      } else if (c >= 48 && c <= 57) {
        true
      } else {
        c == 45 || c == 46 || c == 95 || c == 126
      }
    }

    let blk_pct_utf8(c: Int): String {
      if (c < 128) {
        blk_pct(c)
      } else if (c < 2048) {
        "${blk_pct(192 + c / 64)}${blk_pct(128 + c % 64)}"
      } else if (c < 65536) {
        "${blk_pct(224 + c / 4096)}${blk_pct(128 + (c / 64) % 64)}${blk_pct(128 + c % 64)}"
      } else {
        "${blk_pct(240 + c / 262144)}${blk_pct(128 + (c / 4096) % 64)}${blk_pct(128 + (c / 64) % 64)}${blk_pct(128 + c % 64)}"
      }
    }

    let blk_pct(b: Int): String {
      let hex = "0123456789ABCDEF";
      let hi = hex.step(String.begin, b / 16);
      let lo = hex.step(String.begin, b % 16);
      "%${hex.slice(hi, hex.next(hi))}${hex.slice(lo, hex.next(lo))}"
    }

A page's state as its query string. `keys` and `values` are parallel and
already in the order Phoenix writes them (its params are a map, so the
keys come out sorted); an empty value is left out, as `patch/2` rejects
`nil` and `""`.

    export let blk_query(keys: List<String>, values: List<String>): String {
      blk_query_from(keys, values, 0, "")
    }

    let blk_query_from(keys: List<String>, values: List<String>, i: Int, acc: String): String {
      if (i >= keys.length) {
        acc
      } else {
        let v = values[i];
        let next = if (v == "") {
          acc
        } else if (acc == "") {
          "${keys[i]}=${blk_encode(v)}"
        } else {
          "${acc}&${keys[i]}=${blk_encode(v)}"
        };
        blk_query_from(keys, values, i + 1, next)
      }
    }

The RSS link in the sidebar follows the tags that are selected.

    export let blk_rss_href(base: String, csv: String): String {
      if (blk_tag_list(csv).isEmpty) { base } else { "${base}?tags=${blk_encode(csv)}" }
    }

`?t=` is a window of time, one of five, or none.

    export let blk_window_days(t: String): Int {
      if (t == "1d") { 1 } else if (t == "3d") { 3 } else if (t == "1w") { 7 } else if (t == "1mo") { 30 } else if (t == "1y") { 365 } else { 0 }
    }

    export let blk_window(t: String): String { if (blk_window_days(t) > 0) { t } else { "" } }

A page number as `Integer.parse/1` takes one: digits all the way, at least
1, or 1.

    export let blk_page(s: String): Int {
      let n = blk_digits(s, String.begin, 0);
      if (n < 1) { 1 } else { n }
    }

An id as `Integer.parse/1` with nothing after it takes one, or -1.

    export let blk_id(s: String): Int {
      blk_digits(blk_trim(s), String.begin, 0)
    }

## Two columns

`split_columns/2`: a row's height is guessed from its headline, the quote
under it and whether it has pictures, and the left column takes rows until
it holds half the total. `quote_len` is -1 when there is no quote.

    export let blk_est_height(headline_len: Int, quote_len: Int, has_media: Boolean): Int {
      let title_lines = blk_max(1, blk_ceil_div(headline_len, 55));
      let quote_h = if (quote_len < 0) { 0 } else { 14 + blk_ceil_div(quote_len, 65) * 13 };
      let media_h = if (has_media) { 16 } else { 0 };
      46 + title_lines * 17 + quote_h + media_h
    }

    let blk_max(a: Int, b: Int): Int { if (a > b) { a } else { b } }

    let blk_ceil_div(a: Int, b: Int): Int {
      let q = blk_div(a, b);
      if (q * b < a) { q + 1 } else { q }
    }

How many rows go in the left column.

    export let blk_left_count(heights: List<Int>): Int {
      let total = heights.reduceFrom(0) { (acc: Int, h: Int): Int => acc + h };
      blk_left_from(heights, total, 0, 0)
    }

    let blk_left_from(heights: List<Int>, total: Int, i: Int, h: Int): Int {
      if (i >= heights.length) {
        i
      } else {
        let nh = h + heights[i];
        if (nh * 2 >= total && i > 0) { i + 1 } else { blk_left_from(heights, total, i + 1, nh) }
      }
    }

## The feed

`BlinkFeedController.xml_escape/1`: four characters, `&` first. An
apostrophe stays as it is.

    export let blk_xml_escape(s: String): String {
      let a = s.split("&").join("&amp;") { (p): String => p };
      let b = a.split("<").join("&lt;") { (p): String => p };
      let c = b.split(">").join("&gt;") { (p): String => p };
      c.split("\"").join("&quot;") { (p): String => p }
    }

The feed's title: `blinks`, or `blinks: a + b` for the tags asked for.

    export let blk_feed_title(csv: String): String {
      let tags = blk_tag_list(csv);
      if (tags.isEmpty) { "blinks" } else { "blinks: ${tags.join(" + ") { (t): String => t }}" }
    }
