# Camera Browser

What `/cameras` decides rather than looks up: the pure parts of
`BlogWeb.CameraBrowserLive` (its tabs, its URL, how a price, a date and a
rarity are printed, which colour a tag is), `Blog.CameraBrowser.Facets`
(what value a listing has for each facet, the buckets, the order values are
shown in, whether a row passes the other facets) and the key
`Blog.CameraBrowser.collapse_dupes/1` groups re-posts by.

The page's program (`static/cameras/cameras.blimp`) holds the rows and the
state and draws the view; the rows are Postgres's, sent by
`src/99_cameras.blimp`, which also uses the tabs and the parameter parsing
here to build the same query `list_listings/1` built.

What stayed in Blimp, and why:

- Lower-casing. `Facets.brand/1`, `formats/1`, the condition facet and the
  dupe key all start from `String.downcase`; Temper's `String` has no case
  mapping, so the Blimp caller lower-cases and these take the result.
- Counting and sorting. A Temper list only gets longer through
  `ListBuilder`, an actor on this backend that is never collected. Counting
  a facet's values is a map from value to count and a sort, which Blimp has
  (`sort_by_keys` is stable, as `Enum.sort_by` is); the sort keys are here.

A missing number crosses as -1 (a price, a time, a rarity), a missing
string as "". Times are Unix seconds in an `Int`, which holds them until
2038.

Every name starts `cam_`: the site has one flat namespace.

## Where

The tabs and their sub-city chips, `@tabs`, in order.

    export let cam_tabs: List<String> = ["nyc", "bay", "sea", "pdx"];

    export let cam_tab_label(tab: String): String {
      if (tab == "nyc") { "NYC" } else if (tab == "bay") { "SF / East Bay" } else if (tab == "sea") { "Seattle" } else if (tab == "pdx") { "Portland" } else { "" }
    }

    export let cam_tab_subs(tab: String): List<String> {
      if (tab == "nyc") {
        ["mnh", "brk", "que", "brx"]
      } else if (tab == "bay") {
        ["sfc", "eby"]
      } else if (tab == "sea") {
        ["see", "est"]
      } else if (tab == "pdx") {
        ["mlt", "wsc", "clc", "clk"]
      } else {
        []
      }
    }

`Listing.city/1`'s table. Every chip under a tab is labelled with the same
name, so the chips use it too.

    export let cam_sub_label(sub: String): String {
      if (sub == "sfc") { "San Francisco" } else if (sub == "eby") { "East Bay" } else if (sub == "mnh") { "Manhattan" } else if (sub == "brk") { "Brooklyn" } else if (sub == "que") { "Queens" } else if (sub == "brx") { "Bronx" } else if (sub == "stn") { "Staten Island" } else if (sub == "pen") { "Peninsula" } else if (sub == "sby") { "South Bay" } else if (sub == "nby") { "North Bay" } else if (sub == "scz") { "Santa Cruz" } else if (sub == "see") { "Seattle" } else if (sub == "est") { "Eastside" } else if (sub == "sno") { "Snohomish" } else if (sub == "tac") { "Tacoma" } else if (sub == "mlt") { "Portland" } else if (sub == "wsc") { "Washington Co" } else if (sub == "clc") { "Clackamas" } else if (sub == "clk") { "Vancouver WA" } else { "" }
    }

`Map.get(table, sub, sub || area)`.

    export let cam_city(sub: String, area: String): String {
      let known = cam_sub_label(sub);
      if (!known.isEmpty) { known } else if (!sub.isEmpty) { sub } else { area }
    }

`where/1`: the neighbourhood, else the location description, else the city.

    export let cam_where(hood: String, loc: String, sub: String, area: String): String {
      if (!hood.isEmpty) { hood } else if (!loc.isEmpty) { loc } else { cam_city(sub, area) }
    }

`tab_of/1`: which tab a `city` value belongs to, "nyc" for anything else.

    export let cam_tab_of(city: String): String {
      if (city == "bay" || city == "sfc" || city == "eby") {
        "bay"
      } else if (city == "sea" || city == "see" || city == "est") {
        "sea"
      } else if (city == "pdx" || city == "mlt" || city == "wsc" || city == "clc" || city == "clk") {
        "pdx"
      } else {
        "nyc"
      }
    }

`filter_city/2`: a tab filters on the Craigslist area, anything else on
the subarea. The area, or "" when `city` is a subarea (or empty, which
`list_listings` does not filter on at all).

    export let cam_city_area(city: String): String {
      if (city == "nyc") { "newyork" } else if (city == "bay") { "sfbay" } else if (city == "sea") { "seattle" } else if (city == "pdx") { "portland" } else { "" }
    }

## The URL

`parse_status/1`, `parse_sort/1`, the sort's label, and `parse_dollars/1`
(`Integer.parse/1`: an optional sign, then digits, anything after them
ignored; only a positive number counts). Dollars come back as cents, -1 for
none.

    export let cam_status(raw: String): String {
      if (raw == "closed") { "closed" } else if (raw == "all") { "all" } else { "open" }
    }

    export let cam_sort(raw: String): String {
      if (raw == "newest") { "newest" } else if (raw == "price_asc") { "price_asc" } else if (raw == "price_desc") { "price_desc" } else { "best" }
    }

    export let cam_sorts: List<String> = ["best", "newest", "price_asc", "price_desc"];

    export let cam_sort_label(sort: String): String {
      if (sort == "newest") { "newest" } else if (sort == "price_asc") { "cheapest" } else if (sort == "price_desc") { "priciest" } else { "best" }
    }

    export let cam_dollars(raw: String): Int {
      if (raw.isEmpty) {
        -1
      } else {
        let c = raw[String.begin];
        let neg = c == 45;
        let start = if (c == 43 || c == 45) { raw.next(String.begin) } else { String.begin };
        let n = cam_digits(raw, start, 0, 0);
        if (neg || n <= 0) { -1 } else { n * 100 }
      }
    }

The number the digits at `i` make, or -1 when there are none. Past nine
digits it stops counting (a price is never that high, and an `Int` would
overflow).

    let cam_digits(s: String, i: StringIndex, n: Int, count: Int): Int {
      if (i < s.end && s[i] >= 48 && s[i] <= 57 && count < 9) {
        cam_digits(s, s.next(i), n * 10 + s[i] - 48, count + 1)
      } else if (count == 0) {
        -1
      } else {
        n
      }
    }

`Facets.from_params/1` for one facet: split on commas, trim, drop the
empty ones.

    export let cam_param_values(raw: String): List<String> {
      if (raw.isEmpty) {
        []
      } else {
        raw.split(",").map { (v): String => cam_trim(v) }.filter { (v): Boolean => !v.isEmpty }
      }
    }

    let cam_space(c: Int): Boolean { c == 32 || c == 9 || c == 10 || c == 13 }

    let cam_trim(s: String): String { cam_trim_right(cam_trim_left(s, String.begin)) }

    let cam_trim_left(s: String, i: StringIndex): String {
      if (i < s.end && cam_space(s[i])) { cam_trim_left(s, s.next(i)) } else { s.slice(i, s.end) }
    }

    let cam_trim_right(s: String): String {
      if (s.isEmpty) { s } else {
        let p = s.prev(s.end);
        if (cam_space(s[p])) { cam_trim_right(s.slice(String.begin, p)) } else { s }
      }
    }

`filter_params/3` drops what is the default: nil, "", "0", status open,
sort best, city nyc. The page builds its URL from `(key, value)` pairs,
already in the order `~p` writes a map's keys (sorted); this says whether
one is written.

    export let cam_param_kept(key: String, value: String): Boolean {
      !(value.isEmpty || value == "0" || (key == "status" && value == "open") || (key == "sort" && value == "best") || (key == "city" && value == "nyc"))
    }

`URI.encode_www_form/1`, which `Plug.Conn.Query.encode/1` writes every
value with: the unreserved characters as they are, a space as `+`,
everything else as its UTF-8 bytes, `%XX` each.

    export let cam_enc(s: String): String {
      cam_enc_from(s, String.begin, "")
    }

    let cam_enc_from(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) { acc } else { cam_enc_from(s, s.next(i), "${acc}${cam_enc_code(s[i])}") }
    }

    let cam_unreserved(c: Int): Boolean {
      (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122) || c == 45 || c == 46 || c == 95 || c == 126
    }

    let cam_enc_code(c: Int): String {
      if (cam_unreserved(c)) {
        String.fromCodePoint(c) orelse panic()
      } else if (c == 32) {
        "+"
      } else if (c < 128) {
        cam_pct(c)
      } else if (c < 2048) {
        "${cam_pct(192 + cam_q(c, 64))}${cam_pct(128 + cam_r(c, 64))}"
      } else if (c < 65536) {
        "${cam_pct(224 + cam_q(c, 4096))}${cam_pct(128 + cam_r(cam_q(c, 64), 64))}${cam_pct(128 + cam_r(c, 64))}"
      } else {
        "${cam_pct(240 + cam_q(c, 262144))}${cam_pct(128 + cam_r(cam_q(c, 4096), 64))}${cam_pct(128 + cam_r(cam_q(c, 64), 64))}${cam_pct(128 + cam_r(c, 64))}"
      }
    }

    let cam_pct(b: Int): String { "%${cam_hex(cam_q(b, 16))}${cam_hex(cam_r(b, 16))}" }

    let cam_q(a: Int, b: Int): Int { (a / b) orelse panic() }

    let cam_r(a: Int, b: Int): Int { (a % b) orelse panic() }

    let cam_hex(d: Int): String {
      if (d < 10) { d.toString() } else { String.fromCodePoint(55 + d) orelse panic() }
    }

## Printing

`price/1`: whole dollars with thousands commas, a dash for none.

    export let cam_price(cents: Int): String {
      if (cents < 0) { "—" } else { "$${cam_thousands(cam_q(cents, 100))}" }
    }

    let cam_thousands(n: Int): String {
      if (n < 1000) { n.toString() } else { "${cam_thousands(cam_q(n, 1000))},${cam_pad3(cam_r(n, 1000))}" }
    }

    let cam_pad3(n: Int): String {
      if (n < 10) { "00${n.toString()}" } else if (n < 100) { "0${n.toString()}" } else { n.toString() }
    }

`ago/1`: minutes (at least one), hours, days, and past thirty days the
date, `Calendar.strftime(dt, "%b %-d")`. `now` is the server's clock: the
browser's Blimp has none.

    export let cam_ago(now: Int, t: Int): String {
      if (t < 0) {
        ""
      } else {
        let secs = now - t;
        if (secs < 3600) {
          let m = cam_q(secs, 60);
          let shown = if (m < 1) { 1 } else { m };
          "${shown.toString()}m"
        } else if (secs < 86400) {
          "${cam_q(secs, 3600).toString()}h"
        } else if (secs < 86400 * 30) {
          "${cam_q(secs, 86400).toString()}d"
        } else {
          cam_month_day(t)
        }
      }
    }

`div/2` truncates toward zero, so a time in the future (a clock a little
ahead) is "0m" there and "1m" here: `max(div(secs, 60), 1)` is 1 for any
negative too. The same.

    export let cam_month_day(t: Int): String {
      let days = cam_floor_div(t, 86400);
      let md = cam_civil(days);
      let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      "${months[md[0] - 1]} ${md[1].toString()}"
    }

    let cam_floor_div(a: Int, b: Int): Int {
      let q = cam_q(a, b);
      if (q * b > a) { q - 1 } else { q }
    }

Days since 1970 -> [month, day] (Howard Hinnant's civil_from_days).

    let cam_civil(z0: Int): List<Int> {
      let z = z0 + 719468;
      let era = cam_floor_div(z, 146097);
      let doe = z - era * 146097;
      let yoe = cam_q(doe - cam_q(doe, 1460) + cam_q(doe, 36524) - cam_q(doe, 146096), 365);
      let doy = doe - (365 * yoe + cam_q(yoe, 4) - cam_q(yoe, 100));
      let mp = cam_q(5 * doy + 2, 153);
      let d = doy - cam_q(153 * mp + 2, 5) + 1;
      let m = if (mp < 10) { mp + 3 } else { mp - 9 };
      [m, d]
    }

`Analyst.stars/1`: the rarity (1-5) as filled and empty stars; nothing
without one.

    export let cam_stars(r: Int): String {
      if (r < 0) { "" } else { "${cam_repeat("★", r)}${cam_repeat("☆", 5 - r)}" }
    }

    let cam_repeat(s: String, n: Int): String {
      if (n <= 0) { "" } else { "${s}${cam_repeat(s, n - 1)}" }
    }

`tag_class/1`.

    export let cam_tag_class(t: String): String {
      if (t == "working") { "t-good" } else if (t == "hopeful" || t == "lot") { "t-hope" } else if (t == "not film?" || t == "accessory") { "t-bad" } else if (t == "needs work") { "t-warn" } else { "" }
    }

## Photos

`Craigslist.image_url/2`, `CameraBrowser.thumb_url/1` and `image_urls/2`:
a thumbnail is always Craigslist's; the lightbox shows the copies in object
storage when the sweep made them (`Blog.Storage.url/1`), else Craigslist's
1200x900.

    export let cam_image_url(id: String, size: String): String {
      "https://images.craigslist.org/${id}_${size}.jpg"
    }

    export let cam_photo_urls(bucket: String, mirrored: List<String>, ids: List<String>): List<String> {
      if (mirrored.isEmpty) {
        ids.map { (id): String => cam_image_url(id, "1200x900") }
      } else {
        mirrored.map { (key): String => "https://${bucket}.fsn1.your-objectstorage.com/${key}" }
      }
    }

`map_url/1`, when the post has both coordinates. They arrive as the text
Postgres prints a float8 as, which is the shortest text that reads back as
the same double, as Elixir prints one.

    export let cam_map_url(lat: String, lng: String): String {
      if (lat.isEmpty || lng.isEmpty) { "" } else { "https://www.google.com/maps?q=${lat},${lng}" }
    }

## Facets

`@facets`, in the order the rail shows them, and their labels.

    export let cam_facet_names: List<String> = ["brand", "format", "tags", "rarity", "price_take", "condition", "price", "photos", "when", "contact"];

    export let cam_facet_label(name: String): String {
      if (name == "brand") { "Brand" } else if (name == "format") { "Format" } else if (name == "tags") { "Read" } else if (name == "rarity") { "Rarity" } else if (name == "price_take") { "Price take" } else if (name == "condition") { "Condition" } else if (name == "price") { "Price" } else if (name == "photos") { "Photos" } else if (name == "when") { "Bumped" } else { "Contact" }
    }

`Facets.brand/1`: the first of `@brands`, in that list's order, that is a
whole word (no letter either side) of the lower-cased make and title,
aliased; "" for none.

    let cam_brands: List<String> = [
      "leica", "hasselblad", "mamiya", "rolleiflex", "rollei", "contax", "nikon", "canon", "pentax", "olympus", "minolta", "yashica",
      "bronica", "fuji", "fujifilm", "konica", "ricoh", "voigtlander", "zeiss", "plaubel", "linhof", "graflex", "polaroid", "kodak", "minox",
      "holga", "lomo", "argus", "agfa", "exakta", "praktica", "petri", "miranda", "topcon", "chinon", "vivitar", "edixa",
    ];

    export let cam_brand(low: String): String {
      let found = cam_brands.filter { (b): Boolean => cam_word_in(low, b, String.begin) };
      if (found.isEmpty) { "" } else { cam_brand_alias(found[0]) }
    }

    let cam_brand_alias(b: String): String {
      if (b == "rolleiflex") { "rollei" } else if (b == "fujifilm") { "fuji" } else if (b == "leitz") { "leica" } else { b }
    }

    let cam_letter(c: Int): Boolean { c >= 97 && c <= 122 }

`~r/(?<![a-z])word(?![a-z])/`: an occurrence of `w` at or after `from`
with no lower-case ASCII letter just before or just after it.

    let cam_word_in(s: String, w: String, from: StringIndex): Boolean {
      let found = s.indexOf(w, from);
      if (found is StringIndex) {
        let before_ok = found <= String.begin || !cam_letter(s[s.prev(found)]);
        let rest = s.slice(found, s.end);
        let after_ok = w.end >= rest.end || !cam_letter(rest[w.end]);
        if (before_ok && after_ok) { true } else { cam_word_in(s, w, s.next(found)) }
      } else {
        false
      }
    }

`formats/1`: every format one of whose needles the lower-cased title and
body contain, in `@formats` order.

    let cam_format_names: List<String> = ["35mm", "medium format", "large format", "instant", "rangefinder", "slr", "point & shoot", "tlr"];

    let cam_format_needles: List<List<String>> = [
      ["35mm", "35 mm", "135 film"],
      ["medium format", "120 film", "6x6", "6x7", "6x9", "6x4.5", "645", "rz67", "rb67", "hasselblad", "rolleiflex", "tlr"],
      ["large format", "4x5", "8x10", "sheet film", "graflex", "linhof"],
      ["instant", "polaroid", "instax", "sx-70", "land camera"],
      ["rangefinder", "leica m", "contax g", "canonet"],
      ["slr"],
      ["point and shoot", "point & shoot", "point-and-shoot", "compact", "stylus", "mju", "contax t2", "contax t3", "yashica t4", "gr1", "klasse"],
      ["tlr", "rolleiflex", "rolleicord", "yashica mat", "c330"],
    ];

    export let cam_formats(low: String): List<String> {
      cam_format_names.filter { (name): Boolean => cam_format_hit(low, name) }
    }

    let cam_format_hit(low: String, name: String): Boolean {
      let at = cam_index_of_name(name, 0);
      !cam_format_needles[at].filter { (needle): Boolean => low.indexOf(needle) is StringIndex }.isEmpty
    }

    let cam_index_of_name(name: String, i: Int): Int {
      if (i >= cam_format_names.length) { panic() } else if (cam_format_names[i] == name) { i } else { cam_index_of_name(name, i + 1) }
    }

The buckets.

    export let cam_price_bucket(cents: Int): String {
      if (cents < 0) { "no price" } else if (cents < 20000) { "under $200" } else if (cents < 50000) { "$200–500" } else if (cents < 100000) { "$500–1k" } else if (cents < 250000) { "$1k–2.5k" } else { "$2.5k+" }
    }

    export let cam_photo_bucket(n: Int): String {
      if (n <= 0) { "none" } else if (n <= 2) { "1–2" } else if (n <= 5) { "3–5" } else { "6+" }
    }

`age_bucket/1` on `renewed_at || posted_at`: `DateTime.diff(now, dt, :day)`
counts whole days, truncating.

    export let cam_age_bucket(now: Int, t: Int): String {
      if (t < 0) {
        "unknown"
      } else {
        let days = cam_q(now - t, 86400);
        if (days < 1) { "today" } else if (days < 3) { "3 days" } else if (days < 7) { "this week" } else if (days < 30) { "this month" } else { "older" }
      }
    }

The rarity facet's value: as many filled stars as the rarity.

    export let cam_rarity_value(r: Int): String {
      if (r < 0) { "" } else { cam_repeat("★", r) }
    }

`matches?/3` over every active facet but `skip` (-1 for none): within a
facet the selections OR together, across facets they AND. A row's values
and the selections are lists in `cam_facet_names` order.

    export let cam_passes(vals: List<List<String>>, active: List<List<String>>, skip: Int): Boolean {
      cam_passes_from(vals, active, skip, 0)
    }

    let cam_passes_from(vals: List<List<String>>, active: List<List<String>>, skip: Int, i: Int): Boolean {
      if (i >= active.length) {
        true
      } else if (i == skip || active[i].isEmpty) {
        cam_passes_from(vals, active, skip, i + 1)
      } else {
        let sel = active[i];
        let hit = !vals[i].filter { (v): Boolean => !sel.filter { (s): Boolean => s == v }.isEmpty }.isEmpty;
        if (hit) { cam_passes_from(vals, active, skip, i + 1) } else { false }
      }
    }

`@ordered`: the facets whose values have a natural order, and where a
value sits in it (99 for one not in the list, which then sorts after, in
the order it came). The page sorts a facet's values by this key when it is
not -1, and by count then value when it is.

    export let cam_order_key(name: String, value: String): Int {
      let order = cam_order(name);
      if (order.isEmpty) { -1 } else { cam_position(order, value, 0) }
    }

    let cam_position(xs: List<String>, v: String, i: Int): Int {
      if (i >= xs.length) { 99 } else if (xs[i] == v) { i } else { cam_position(xs, v, i + 1) }
    }

    let cam_order(name: String): List<String> {
      if (name == "price") { ["under $200", "$200–500", "$500–1k", "$1k–2.5k", "$2.5k+", "no price"] } else if (name == "photos") { ["6+", "3–5", "1–2", "none"] } else if (name == "when") { ["today", "3 days", "this week", "this month", "older", "unknown"] } else if (name == "condition") { ["new", "like new", "excellent", "good", "fair", "salvage"] } else if (name == "rarity") { ["★★★★★", "★★★★", "★★★", "★★", "★"] } else if (name == "price_take") { ["steal", "fair", "high", "unclear"] } else { [] }
    }

How many values a facet shows: 18 for brand and tags, 12 for the rest.

    export let cam_facet_limit(name: String): Int {
      if (name == "brand" || name == "tags") { 18 } else { 12 }
    }

Open without anything selected: brand, format and the tags.

    export let cam_facet_open(name: String, selected: Int): Boolean {
      selected > 0 || name == "brand" || name == "format" || name == "tags"
    }

## Re-posts

`dupe_key/1`: the lower-cased title with every run of anything but ASCII
letters and digits made one space, trimmed, and the price.

    export let cam_dupe_key(low_title: String, cents: Int): String {
      "${cam_squash(low_title, String.begin, "", false)}|${cents.toString()}"
    }

    let cam_alnum(c: Int): Boolean { (c >= 48 && c <= 57) || (c >= 97 && c <= 122) }

    let cam_squash(s: String, i: StringIndex, acc: String, gap: Boolean): String {
      if (i >= s.end) {
        acc
      } else {
        let c = s[i];
        if (cam_alnum(c)) {
          let ch = String.fromCodePoint(c) orelse panic();
          let sep = if (gap && !acc.isEmpty) { " " } else { "" };
          cam_squash(s, s.next(i), "${acc}${sep}${ch}", false)
        } else {
          cam_squash(s, s.next(i), acc, true)
        }
      }
    }
