# Phish

The parts of phangraphs (`/phish`) that are arithmetic on numbers and walks
over strings: the year a query may carry, the batting average and its sort
key, days since 1970 and back, durations, and percent-encoding. The server
(`src/97_phish.blimp`) and the page's program (`static/phish/phish.blimp`,
built into `_build/phish.blimp`) both call them.

What stays Blimp: the queries and the JSON API (they talk to the `DB` actor
and build responses), the page's actor and views, and everything that works
on a song or a track *map*. A Blimp map has atom keys, `%{times_played: 3}`,
and a Temper `Map<String, Int>` is not that, so these functions take the
numbers out of the map at the call site instead. The chart's float math
(`ph_step`, the monotone curve, `ph_n`) stays too: temper-core compares and
formats floats with Blimp helper functions, where Blimp does it natively.

## The year a query asks about

"all", or four ASCII digits; anything else is "all". It goes into the query
as a parameter either way, never as SQL.

    export let phish_year(raw: String): String {
      if (phish_digits_exactly(raw, String.begin, 4)) { raw } else { "all" }
    }

    let phish_digits_exactly(s: String, i: StringIndex, left: Int): Boolean {
      if (i >= s.end) {
        left == 0
      } else if (left == 0) {
        false
      } else if (phish_is_digit(s[i])) {
        phish_digits_exactly(s, s.next(i), left - 1)
      } else {
        false
      }
    }

    let phish_is_digit(c: Int): Boolean {
      c >= 48 && c <= 57
    }

## The batting average

PhishLive.batting_avg/1 is jamcharts / times played, a float. Here it is kept
exact enough to sort by: scaled by 10^9. That, and the sort keys built on it,
are past 32 bits, so they are `Int64`; Temper's `Int` is 32 bits and wraps.

    export let phish_avg9(jc: Int64, n: Int64): Int64 {
      if (n == 0i64) { 0i64 } else { (jc * 1000000000i64 / n) orelse panic() }
    }

The key `phish_sorted` sorts a song by, smallest first.

    export let phish_sort_key(sort_by: String, jc: Int64, played: Int64): Int64 {
      if (sort_by == "jc") {
        0i64 - (jc * 10000000000i64 + phish_avg9(jc, played))
      } else if (sort_by == "played") {
        0i64 - played
      } else {
        0i64 - (phish_avg9(jc, played) * 10000i64 + jc)
      }
    }

PhishLive.fmt_avg/1: ".333", ".090", "1.000" -- thousandths, rounded half up.

    export let phish_fmt_avg(jc: Int, n: Int): String {
      if (n == 0) {
        ".000"
      } else {
        let thousandths = ((jc * 2000 + n) / (2 * n)) orelse panic();
        if (thousandths >= 1000) {
          "1.000"
        } else {
          ".${ph_pad3(thousandths)}"
        }
      }
    }

    let ph_pad3(n: Int): String {
      if (n < 10) { "00${n.toString()}" } else if (n < 100) { "0${n.toString()}" } else { n.toString() }
    }

## Small numbers as the page writes them

    export let ph_pad2(n: Int): String {
      if (n < 10) { "0${n.toString()}" } else { n.toString() }
    }

PhishLive.fmt_duration/1 and the chart's fmtDuration: "43:37", "?".

    export let ph_dur(ms: Int): String {
      if (ms <= 0) {
        "?"
      } else {
        let mins = (ms / 60000) orelse panic();
        let secs = ((ms % 60000) / 1000) orelse panic();
        "${mins.toString()}:${ph_pad2(secs)}"
      }
    }

Elixir's round/1 of a non-negative ratio a/b: half away from zero.

    export let ph_round_div(a: Int, b: Int): Int {
      ((2 * a + b) / (2 * b)) orelse panic()
    }

The set a song was played in, as the card names it. A track's set can be
missing, which Blimp hands over as nil.

    export let ph_fmt_set(s: String?): String {
      if (s == null) {
        ""
      } else if (s == "SET 1") {
        "Set 1"
      } else if (s == "SET 2") {
        "Set 2"
      } else if (s == "SET 3") {
        "Set 3"
      } else if (s == "ENCORE") {
        "Encore"
      } else if (s == "ENCORE 2") {
        "Encore 2"
      } else {
        s
      }
    }

A number from the URL, or the default when it is not all digits.

    export let ph_int_or(s: String, dflt: Int): Int {
      if (!s.isEmpty && ph_all_digits(s, String.begin)) { s.toInt32() orelse panic() } else { dflt }
    }

    let ph_all_digits(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else if (phish_is_digit(s[i])) {
        ph_all_digits(s, s.next(i))
      } else {
        false
      }
    }

## Characters, not bytes

The first n characters of s, and how many there are: jam notes are cut at 80
characters with "..." after.

    export let ph_chars(s: String, n: Int): String {
      s.slice(String.begin, ph_chars_end(s, String.begin, n))
    }

    let ph_chars_end(s: String, i: StringIndex, left: Int): StringIndex {
      if (i >= s.end || left == 0) { i } else { ph_chars_end(s, s.next(i), left - 1) }
    }

    export let ph_char_count(s: String): Int {
      ph_count_from(s, String.begin, 0)
    }

    let ph_count_from(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) { n } else { ph_count_from(s, s.next(i), n + 1) }
    }

## Percent-encoding

For a query value: a song is "Mike's Song" or "AC/DC Bag". Everything but
the unreserved characters is written as its UTF-8 bytes, `%XX` each. Temper
reads a string by code point, so the bytes are made back out of it.

    export let ph_enc(s: String): String {
      ph_enc_from(s, String.begin, "")
    }

    let ph_enc_from(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        ph_enc_from(s, s.next(i), "${acc}${ph_enc_code(s[i])}")
      }
    }

    let ph_unreserved(c: Int): Boolean {
      if (c >= 48 && c <= 57) { true } else if (c >= 65 && c <= 90) { true } else if (c >= 97 && c <= 122) { true } else {
        c == 45 || c == 46 || c == 95 || c == 126
      }
    }

    let ph_enc_code(c: Int): String {
      if (ph_unreserved(c)) {
        String.fromCodePoint(c) orelse panic()
      } else if (c < 128) {
        ph_pct(c)
      } else if (c < 2048) {
        "${ph_pct(192 + ph_q(c, 64))}${ph_pct(128 + ph_r(c, 64))}"
      } else if (c < 65536) {
        "${ph_pct(224 + ph_q(c, 4096))}${ph_pct(128 + ph_r(ph_q(c, 64), 64))}${ph_pct(128 + ph_r(c, 64))}"
      } else {
        "${ph_pct(240 + ph_q(c, 262144))}${ph_pct(128 + ph_r(ph_q(c, 4096), 64))}${ph_pct(128 + ph_r(ph_q(c, 64), 64))}${ph_pct(128 + ph_r(c, 64))}"
      }
    }

    let ph_pct(b: Int): String {
      "%${ph_hex(ph_q(b, 16))}${ph_hex(ph_r(b, 16))}"
    }

    let ph_q(a: Int, b: Int): Int { (a / b) orelse panic() }

    let ph_r(a: Int, b: Int): Int { (a % b) orelse panic() }

    let ph_hex(d: Int): String {
      if (d < 10) { d.toString() } else { String.fromCodePoint(55 + d) orelse panic() }
    }

## Days since 1970

days_from_civil (Howard Hinnant): "2023-04-17" -> days since 1970-01-01.
The date is read in one pass, a field per run of digits.

    export let ph_days(date: String): Int {
      ph_days_scan(date, String.begin, 0, 0, 0, 0)
    }

    let ph_days_scan(s: String, i: StringIndex, field: Int, y: Int, m: Int, d: Int): Int {
      if (i >= s.end) {
        ph_days_of(y, m, d)
      } else {
        let c = s[i];
        if (!phish_is_digit(c)) {
          ph_days_scan(s, s.next(i), field + 1, y, m, d)
        } else if (field == 0) {
          ph_days_scan(s, s.next(i), field, y * 10 + c - 48, m, d)
        } else if (field == 1) {
          ph_days_scan(s, s.next(i), field, y, m * 10 + c - 48, d)
        } else {
          ph_days_scan(s, s.next(i), field, y, m, d * 10 + c - 48)
        }
      }
    }

    let ph_days_of(y0: Int, m: Int, d: Int): Int {
      let y = if (m <= 2) { y0 - 1 } else { y0 };
      let era = (y / 400) orelse panic();
      let yoe = y - era * 400;
      let mp = if (m > 2) { m - 3 } else { m + 9 };
      let doy = ((153 * mp + 2) / 5) orelse panic();
      let doy1 = doy + d - 1;
      let doe = yoe * 365 + ((yoe / 4) orelse panic()) - ((yoe / 100) orelse panic()) + doy1;
      era * 146097 + doe - 719468
    }

...and back: days -> [year, month].

    export let ph_civil(z0: Int): List<Int> {
      let z = z0 + 719468;
      let era = (z / 146097) orelse panic();
      let doe = z - era * 146097;
      let yoe = ((doe - ((doe / 1460) orelse panic()) + ((doe / 36524) orelse panic()) - ((doe / 146096) orelse panic())) / 365) orelse panic();
      let doy = doe - (365 * yoe + ((yoe / 4) orelse panic()) - ((yoe / 100) orelse panic()));
      let mp = ((5 * doy + 2) / 153) orelse panic();
      let m = if (mp < 10) { mp + 3 } else { mp - 9 };
      let y = if (m <= 2) { yoe + era * 400 + 1 } else { yoe + era * 400 };
      [y, m]
    }

    export let ph_month_start(y: Int, m: Int): Int {
      ph_days_of(y, m, 1)
    }

An x-axis label: "May '23".

    export let ph_tick_label(day: Int): String {
      let ym = ph_civil(day);
      let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      "${months[ym[1] - 1]} '${ph_pad2((ym[0] % 100) orelse panic())}"
    }
