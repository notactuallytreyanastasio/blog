# Stumble

What `/stumble` decides rather than looks up: the pure parts of
`BlogWeb.StumbleLive` and of `Blog.PokeAround.Tags.list_tags/1`. The menus'
choices, the tag presets and filter rules, what a rule keeps, how the tags
sort, how a post is cut to fit its row, and the words in the title and
status bars.

The page's program (`static/stumble/stumble.blimp`) holds the state and
draws the view; the links and tags are Postgres's, sent by
`src/99_stumble.blimp`. Every name starts `st_`: the site has one flat
namespace.

    let { ph_enc } = import("../phish");

## Languages

`@supported_langs`, code and name.

    export let st_lang_codes: List<String> = ["en", "es", "pt", "de", "fr", "ja", "ko", "zh"];

    export let st_lang_name(code: String): String {
      if (code == "en") { "English" } else if (code == "es") { "Espanol" } else if (code == "pt") { "Portugues" } else if (code == "de") { "Deutsch" } else if (code == "fr") { "Francais" } else if (code == "ja") { "Japanese" } else if (code == "ko") { "Korean" } else if (code == "zh") { "Chinese" } else { code }
    }

The selected languages were a list the LiveView kept newest first:
`toggle_lang` put a new one at the front (`[lang | current]`) and took a
selected one out (`List.delete/2`). Here the list is its codes joined by
commas, which is also how it travels to the server. A code never has one.

    export let st_langs(set: String): List<String> {
      if (set.isEmpty) { [] } else { set.split(",") }
    }

    export let st_lang_on(set: String, code: String): Boolean {
      !st_langs(set).filter { (x): Boolean => x == code }.isEmpty
    }

    export let st_toggle_lang(set: String, code: String): String {
      if (st_lang_on(set, code)) {
        st_langs(set).filter { (x): Boolean => x != code }.join(",") { (x): String => x }
      } else if (set.isEmpty) {
        code
      } else {
        "${code},${set}"
      }
    }

The status bar's `Filter: <%= Enum.join(@selected_langs, ", ") %> |`.

    export let st_langs_label(set: String): String {
      st_langs(set).join(", ") { (x): String => x }
    }

## What to ask the server

`fetch_links/1`, `random_links(50, min_score: 20, langs: ...)`, and
`links_by_tag(slug, order: :newest, langs: ...)`. `n` is the program's
serial for a request it wants made again (Shuffle); the server ignores it.

    export let st_links_url(langs: String, n: Int): String {
      "/stumble/links.json?langs=${langs}&n=${n.toString()}"
    }

    export let st_tag_url(slug: String, langs: String, n: Int): String {
      "/stumble/tag.json?slug=${ph_enc(slug)}&langs=${langs}&n=${n.toString()}"
    }

Where a row goes: the server counts the stumble (`increment_stumble_count/1`)
and redirects to the link, as the `open` event did.

    export let st_go_url(id: Int): String {
      "/stumble/go?id=${id.toString()}"
    }

## Pages

`@pages`, and `page_title/2` and `status_left/2`, which took the counts
the LiveView had: `length(@links)`, `length(@all_tags)`, `length(@tag_links)`.

    export let st_page_ids: List<String> = ["bag", "tags", "your_links"];

    export let st_page_name(id: String): String {
      if (id == "bag") { "Bag of Links" } else if (id == "tags") { "Tag Browsing" } else if (id == "your_links") { "Your Links" } else { id }
    }

    export let st_page_title(page: String, tag: String): String {
      if (page == "bag") {
        "bag of links"
      } else if (page == "tags") {
        if (tag.isEmpty) { "tag browsing" } else { "tag: ${tag}" }
      } else if (page == "your_links") {
        "your links"
      } else {
        "stumble"
      }
    }

The LiveView had no clause for another page and would have crashed; the
program only ever has these three.

    export let st_status_left(page: String, in_tag: Boolean, links: Int, tags: Int, tag_links: Int): String {
      if (page == "bag") {
        "${links.toString()} items"
      } else if (page == "tags") {
        if (in_tag) { "${tag_links.toString()} links" } else { "${tags.toString()} tags" }
      } else {
        "0 saved links"
      }
    }

## Cutting a post to its row

`truncate(text, 100)`: a text of at most 100 *bytes* is left alone;
anything longer is `String.slice(text, 0, 100)`, its first 100 *graphemes*,
and an ellipsis. So a post of 60 characters that takes more than 100 bytes
(accents, emoji) is kept whole and still gets the ellipsis. That is what
the page showed, so it is what this shows.

    export let st_truncate(text: String, max: Int): String {
      if (!st_bytes_over(text, String.begin, max)) {
        text
      } else {
        "${text.slice(String.begin, st_graphemes_end(text, String.begin, max))}…"
      }
    }

Whether the UTF-8 of `s` from `i` on is longer than `left` bytes. It stops
as soon as it is: a post can be long.

    let st_bytes_over(s: String, i: StringIndex, left: Int): Boolean {
      if (left < 0) {
        true
      } else if (i >= s.end) {
        false
      } else {
        st_bytes_over(s, s.next(i), left - st_utf8_len(s[i]))
      }
    }

    let st_utf8_len(c: Int): Int {
      if (c < 128) { 1 } else if (c < 2048) { 2 } else if (c < 65536) { 3 } else { 4 }
    }

Where the first `left` graphemes end. Temper reads code points, so the
clusters are put back together here, by the rules of Unicode's UAX #29 that
the posts in the table need: a line break `\r\n` is one; combining marks,
variation selectors, emoji skin tones and tag characters join the character
before them; a zero-width joiner joins the pictograph after it (a family, a
flag with a rainbow); and two regional indicators make one flag. Hangul
jamo sequences and the Indic "prepend" class are not handled: a post of
decomposed Korean would be cut at another place than Elixir cuts it. Every
post in the development database (24,156) is cut as Elixir cuts it.

    let st_graphemes_end(s: String, i: StringIndex, left: Int): StringIndex {
      if (i >= s.end || left == 0) {
        i
      } else {
        st_graphemes_end(s, st_cluster_end(s, i), left - 1)
      }
    }

The end of the cluster that starts at `i`.

    let st_cluster_end(s: String, i: StringIndex): StringIndex {
      let c = s[i];
      let j = s.next(i);
      if (c == 13 && j < s.end && s[j] == 10) {
        s.next(j)
      } else if (st_regional(c) && j < s.end && st_regional(s[j])) {
        st_extend(s, s.next(j), 0)
      } else if (c == 13 || c == 10) {
        j
      } else {
        st_extend(s, j, if (st_consonant(c)) { 1 } else { 0 })
      }
    }

Past every extending code point from `i`, past a pictograph joined by a
ZWJ, and past a consonant a virama links. `conj` is where a conjunct
stands: 0 none, 1 after a consonant, 2 after a consonant and a virama.

    let st_extend(s: String, i: StringIndex, conj: Int): StringIndex {
      if (i >= s.end) {
        i
      } else {
        let c = s[i];
        let j = s.next(i);
        if (c == 8205) {
          if (j < s.end && st_pictographic(s[j])) { st_extend(s, s.next(j), 0) } else { st_extend(s, j, conj) }
        } else if (st_linker(c)) {
          st_extend(s, j, if (conj > 0) { 2 } else { 0 })
        } else if (st_extending(c)) {
          st_extend(s, j, conj)
        } else if (conj == 2 && st_consonant(c)) {
          st_extend(s, j, 1)
        } else {
          i
        }
      }
    }

    let st_in(c: Int, lo: Int, hi: Int): Boolean { c >= lo && c <= hi }

    let st_regional(c: Int): Boolean { st_in(c, 127462, 127487) }

Grapheme_Extend and SpacingMark: every code point Unicode 16 files as a
mark (Mn, Me, Mc), less the Myanmar, Tai Tham, Tai Viet and Ahom vowel
signs UAX #29 leaves out of SpacingMark (U+102B, U+102C, U+1038, ...), plus
Thai and Lao AM, ZWNJ, the emoji skin tones, the tag characters and the
half-width kana voicing marks. Low and high ends of each run, sorted, generated with
Python's `unicodedata`; found by halving.

    let st_extend_runs: List<Int> = [
      768, 879, 1155, 1161, 1425, 1469, 1471, 1471, 1473, 1474, 1476, 1477, 1479, 1479, 1552, 1562,
      1611, 1631, 1648, 1648, 1750, 1756, 1759, 1764, 1767, 1768, 1770, 1773, 1809, 1809, 1840,
      1866, 1958, 1968, 2027, 2035, 2045, 2045, 2070, 2073, 2075, 2083, 2085, 2087, 2089, 2093,
      2137, 2139, 2199, 2207, 2250, 2273, 2275, 2307, 2362, 2364, 2366, 2383, 2385, 2391, 2402,
      2403, 2433, 2435, 2492, 2492, 2494, 2500, 2503, 2504, 2507, 2509, 2519, 2519, 2530, 2531,
      2558, 2558, 2561, 2563, 2620, 2620, 2622, 2626, 2631, 2632, 2635, 2637, 2641, 2641, 2672,
      2673, 2677, 2677, 2689, 2691, 2748, 2748, 2750, 2757, 2759, 2761, 2763, 2765, 2786, 2787,
      2810, 2815, 2817, 2819, 2876, 2876, 2878, 2884, 2887, 2888, 2891, 2893, 2901, 2903, 2914,
      2915, 2946, 2946, 3006, 3010, 3014, 3016, 3018, 3021, 3031, 3031, 3072, 3076, 3132, 3132,
      3134, 3140, 3142, 3144, 3146, 3149, 3157, 3158, 3170, 3171, 3201, 3203, 3260, 3260, 3262,
      3268, 3270, 3272, 3274, 3277, 3285, 3286, 3298, 3299, 3315, 3315, 3328, 3331, 3387, 3388,
      3390, 3396, 3398, 3400, 3402, 3405, 3415, 3415, 3426, 3427, 3457, 3459, 3530, 3530, 3535,
      3540, 3542, 3542, 3544, 3551, 3570, 3571, 3633, 3633, 3635, 3642, 3655, 3662, 3761, 3761,
      3763, 3772, 3784, 3790, 3864, 3865, 3893, 3893, 3895, 3895, 3897, 3897, 3902, 3903, 3953,
      3972, 3974, 3975, 3981, 3991, 3993, 4028, 4038, 4038, 4141, 4151, 4153, 4158, 4182, 4185,
      4190, 4192, 4209, 4212, 4226, 4226, 4228, 4230, 4237, 4237, 4253, 4253, 4957, 4959, 5906,
      5909, 5938, 5940, 5970, 5971, 6002, 6003, 6068, 6099, 6109, 6109, 6155, 6157, 6159, 6159,
      6277, 6278, 6313, 6313, 6432, 6443, 6448, 6459, 6679, 6683, 6741, 6750, 6752, 6752, 6754,
      6754, 6757, 6780, 6783, 6783, 6832, 6862, 6912, 6916, 6964, 6980, 7019, 7027, 7040, 7042,
      7073, 7085, 7142, 7155, 7204, 7223, 7376, 7378, 7380, 7400, 7405, 7405, 7412, 7412, 7415,
      7417, 7616, 7679, 8204, 8204, 8400, 8432, 11503, 11505, 11647, 11647, 11744, 11775, 12330,
      12335, 12441, 12442, 42607, 42610, 42612, 42621, 42654, 42655, 42736, 42737, 43010, 43010,
      43014, 43014, 43019, 43019, 43043, 43047, 43052, 43052, 43136, 43137, 43188, 43205, 43232,
      43249, 43263, 43263, 43302, 43309, 43335, 43347, 43392, 43395, 43443, 43456, 43493, 43493,
      43561, 43574, 43587, 43587, 43596, 43597, 43644, 43644, 43696, 43696, 43698, 43700, 43703,
      43704, 43710, 43711, 43713, 43713, 43755, 43759, 43765, 43766, 44003, 44010, 44012, 44013,
      64286, 64286, 65024, 65039, 65056, 65071, 65438, 65439, 66045, 66045, 66272, 66272, 66422,
      66426, 68097, 68099, 68101, 68102, 68108, 68111, 68152, 68154, 68159, 68159, 68325, 68326,
      68900, 68903, 68969, 68973, 69291, 69292, 69372, 69375, 69446, 69456, 69506, 69509, 69632,
      69634, 69688, 69702, 69744, 69744, 69747, 69748, 69759, 69762, 69808, 69818, 69826, 69826,
      69888, 69890, 69927, 69940, 69957, 69958, 70003, 70003, 70016, 70018, 70067, 70080, 70089,
      70092, 70094, 70095, 70188, 70199, 70206, 70206, 70209, 70209, 70367, 70378, 70400, 70403,
      70459, 70460, 70462, 70468, 70471, 70472, 70475, 70477, 70487, 70487, 70498, 70499, 70502,
      70508, 70512, 70516, 70584, 70592, 70594, 70594, 70597, 70597, 70599, 70602, 70604, 70608,
      70610, 70610, 70625, 70626, 70709, 70726, 70750, 70750, 70832, 70851, 71087, 71093, 71096,
      71104, 71132, 71133, 71216, 71232, 71339, 71351, 71453, 71455, 71458, 71467, 71724, 71738,
      71984, 71989, 71991, 71992, 71995, 71998, 72000, 72000, 72002, 72003, 72145, 72151, 72154,
      72160, 72164, 72164, 72193, 72202, 72243, 72249, 72251, 72254, 72263, 72263, 72273, 72283,
      72330, 72345, 72751, 72758, 72760, 72767, 72850, 72871, 72873, 72886, 73009, 73014, 73018,
      73018, 73020, 73021, 73023, 73029, 73031, 73031, 73098, 73102, 73104, 73105, 73107, 73111,
      73459, 73462, 73472, 73473, 73475, 73475, 73524, 73530, 73534, 73538, 73562, 73562, 78912,
      78912, 78919, 78933, 90398, 90415, 92912, 92916, 92976, 92982, 94031, 94031, 94033, 94087,
      94095, 94098, 94180, 94180, 94192, 94193, 113821, 113822, 118528, 118573, 118576, 118598,
      119141, 119145, 119149, 119154, 119163, 119170, 119173, 119179, 119210, 119213, 119362,
      119364, 121344, 121398, 121403, 121452, 121461, 121461, 121476, 121476, 121499, 121503,
      121505, 121519, 122880, 122886, 122888, 122904, 122907, 122913, 122915, 122916, 122918,
      122922, 123023, 123023, 123184, 123190, 123566, 123566, 123628, 123631, 124140, 124143,
      124398, 124399, 125136, 125142, 125252, 125258, 127995, 127999, 917536, 917631, 917760, 917999
    ];

    let st_extending(c: Int): Boolean {
      st_run_find(c, 0, st_extend_runs.length / 2 orelse 0)
    }

Whether c is in one of the runs from `lo` up to (not including) `hi`.

    let st_run_find(c: Int, lo: Int, hi: Int): Boolean {
      if (lo >= hi) {
        false
      } else {
        let mid = (lo + hi) / 2 orelse lo;
        if (c < st_extend_runs[mid * 2]) {
          st_run_find(c, lo, mid)
        } else if (c > st_extend_runs[mid * 2 + 1]) {
          st_run_find(c, mid + 1, hi)
        } else {
          true
        }
      }
    }

Indic conjuncts (GB9c, Unicode 15.1, which Elixir 1.19 follows): a
consonant, a virama, and the next consonant are one cluster, क्ष. The
viramas that link (InCB=Linker) and the consonants of those six scripts.

    let st_linker(c: Int): Boolean {
      c == 2381 || c == 2509 || c == 2765 || c == 2893 || c == 3149 || c == 3405
    }

    let st_consonant(c: Int): Boolean {
      st_in(c, 2325, 2361) || st_in(c, 2392, 2399) || st_in(c, 2424, 2431) ||
      st_in(c, 2453, 2489) || st_in(c, 2524, 2527) || st_in(c, 2544, 2545) ||
      st_in(c, 2709, 2745) || c == 2809 || st_in(c, 2837, 2873) || st_in(c, 2908, 2911) || c == 2929 ||
      st_in(c, 3093, 3129) || st_in(c, 3160, 3162) || st_in(c, 3349, 3386)
    }

Extended_Pictographic, roughly: the emoji blocks and the older symbols
emoji sequences are made of.

    let st_pictographic(c: Int): Boolean {
      st_in(c, 126976, 129791) || st_in(c, 9728, 10175) || st_in(c, 8592, 8703) ||
      st_in(c, 8960, 9215) || st_in(c, 11008, 11263) || c == 169 || c == 174 ||
      c == 8252 || c == 8265 || c == 8482 || c == 8505 || c == 12336 || c == 12349 ||
      c == 12951 || c == 12953
    }

## Tag presets

`@tag_presets`. A preset is its id; these give the rest. Its rules are
`[field, op, value, value2]`, the numbers as text, which the program turns
into rules of its own.

    export let st_preset_ids: List<String> = ["popular", "long_tail", "new_week", "trending", "single_use", "all"];

    export let st_preset_name(id: String): String {
      if (id == "popular") { "Popular" } else if (id == "long_tail") { "Long Tail" } else if (id == "new_week") { "New This Week" } else if (id == "trending") { "Trending" } else if (id == "single_use") { "Unique" } else { "All Tags" }
    }

    export let st_preset_icon(id: String): String {
      if (id == "popular") { "★" } else if (id == "long_tail") { "◇" } else if (id == "new_week") { "✦" } else if (id == "trending") { "↗" } else if (id == "single_use") { "①" } else { "∞" }
    }

    export let st_preset_rules(id: String): List<List<String>> {
      if (id == "popular") {
        [["usage_count", "gte", "10", "0"]]
      } else if (id == "long_tail") {
        [["usage_count", "between", "1", "5"]]
      } else if (id == "new_week") {
        [["created", "last_n_days", "7", "0"]]
      } else if (id == "trending") {
        [["created", "last_n_days", "3", "0"], ["usage_count", "gte", "3", "0"]]
      } else if (id == "single_use") {
        [["usage_count", "eq", "1", "0"]]
      } else {
        []
      }
    }

    export let st_preset_sort_field(id: String): String {
      if (id == "new_week") { "inserted_at" } else if (id == "single_use") { "name" } else { "usage_count" }
    }

    export let st_preset_sort_dir(id: String): String {
      if (id == "single_use") { "asc" } else { "desc" }
    }

## Filter rules

`@filter_fields`: each field, its label, and its operators with theirs.

    export let st_field_ids: List<String> = ["usage_count", "name", "created"];

    export let st_field_label(f: String): String {
      if (f == "usage_count") { "Link Count" } else if (f == "name") { "Name" } else { "Created" }
    }

    export let st_ops(f: String): List<String> {
      if (f == "usage_count") {
        ["gte", "lte", "eq", "between"]
      } else if (f == "name") {
        ["contains", "starts_with", "ends_with", "equals"]
      } else if (f == "created") {
        ["last_n_days", "after", "before"]
      } else {
        []
      }
    }

    export let st_op_label(op: String): String {
      if (op == "gte") { "≥" } else if (op == "lte") { "≤" } else if (op == "eq") { "=" } else if (op == "between") { "between" } else if (op == "contains") { "contains" } else if (op == "starts_with") { "starts with" } else if (op == "ends_with") { "ends with" } else if (op == "equals") { "equals" } else if (op == "last_n_days") { "in last N days" } else if (op == "after") { "after" } else if (op == "before") { "before" } else { op }
    }

`update_rule_field`: a new field takes its first operator, and that
operator's `default_value_for/2`.

    export let st_first_op(f: String): String {
      let ops = st_ops(f);
      if (ops.isEmpty) { "" } else { ops[0] }
    }

`default_value_for/2`, the number half of it: `{1, 10}` for between, 1 for
another count, 7 for last N days. A name's default is "", and a date's is
the time it was chosen, which the program keeps apart.

    export let st_default_value(f: String, op: String): Int {
      if (f == "usage_count") { 1 } else if (f == "created" && op == "last_n_days") { 7 } else { 0 }
    }

    export let st_default_value2(f: String, op: String): Int {
      if (f == "usage_count" && op == "between") { 10 } else { 0 }
    }

`parse_int/2`: `Integer.parse/1`, which reads the digits at the front and
ignores the rest ("12abc" is 12), with a sign; anything else is the
default; and never below 0.

    export let st_parse_int(s: String, dflt: Int): Int {
      if (s.isEmpty) {
        dflt
      } else {
        let c = s[String.begin];
        let neg = c == 45;
        let start = if (c == 45 || c == 43) { s.next(String.begin) } else { String.begin };
        if (start >= s.end || !st_digit(s[start])) {
          dflt
        } else {
          let n = st_digits(s, start, 0);
          if (neg) { 0 } else { n }
        }
      }
    }

    let st_digit(c: Int): Boolean { c >= 48 && c <= 57 }

Digits past what an Int holds stop adding: a count of links is never that
big, and Elixir's bignum would have matched nothing either way.

    let st_digits(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end || !st_digit(s[i])) {
        n
      } else if (n > 99999999) {
        n
      } else {
        st_digits(s, s.next(i), n * 10 + s[i] - 48)
      }
    }

## What a rule keeps

`apply_single_rule/2` and `build_rule_condition/1`, which said the same
thing as a `where` and as a `dynamic`. The program has every tag (there are
15 in production), so it asks this of each one instead of asking Postgres
again after every keystroke.

A tag comes with its name lower-cased by Postgres, its `usage_count`, and
its age in seconds when the server answered. A rule has its field and
operator, two numbers and a text: the text lower-cased by the program
(Temper has no case mapping), since Ecto matched `ilike(t.name, ^pattern)`
with the pattern built from `String.downcase(value)`.

`after` and `before` compared `inserted_at` with the `DateTime.utc_now()` of
when the operator was chosen; the page offered no way to change it ("date
picker"). Here that time is when the tags were fetched, which is the
page's now: `before` keeps every tag and `after` none, as before.

    export let st_rule_keeps(field: String, op: String, v: Int, v2: Int, text: String,
                             name: String, usage: Int, age_s: Float64): Boolean {
      if (field == "usage_count") {
        if (op == "gte") { usage >= v } else if (op == "lte") { usage <= v } else if (op == "eq") { usage == v } else if (op == "between") { usage >= v && usage <= v2 } else { true }
      } else if (field == "name") {
        if (op == "contains") { st_like("%${text}%", name) } else if (op == "starts_with") { st_like("${text}%", name) } else if (op == "ends_with") { st_like("%${text}", name) } else if (op == "equals") { name == text } else { true }
      } else if (field == "created") {
        if (op == "last_n_days") { age_s <= v.toFloat64() * 86400.0 } else if (op == "before") { age_s > 0.0 } else if (op == "after") { age_s < 0.0 } else { true }
      } else {
        true
      }
    }

A rule that means nothing (a field or operator the LiveView had no clause
for) left the query alone under "all"; under "any" it was dropped from the
`or`, and with none left the query was again left alone.

    export let st_rule_counts(field: String, op: String): Boolean {
      !st_ops(field).filter { (x): Boolean => x == op }.isEmpty
    }

## ILIKE

The value went into the pattern as typed, so `%` and `_` in it were
wildcards and a backslash escaped the next character: `a_b` matches `a-b`.
This is Postgres's LIKE over code points: `%` any run, `_` any one, `\x`
exactly x. Both sides are already lower case.

    export let st_like(pattern: String, s: String): Boolean {
      st_like_at(pattern, String.begin, s, String.begin)
    }

    let st_like_at(p: String, i: StringIndex, s: String, j: StringIndex): Boolean {
      if (i >= p.end) {
        j >= s.end
      } else {
        let c = p[i];
        if (c == 37) {
          st_like_any(p, p.next(i), s, j)
        } else if (j >= s.end) {
          false
        } else if (c == 95) {
          st_like_at(p, p.next(i), s, s.next(j))
        } else if (c == 92 && p.next(i) < p.end) {
          let k = p.next(i);
          if (p[k] == s[j]) { st_like_at(p, p.next(k), s, s.next(j)) } else { false }
        } else if (c == s[j]) {
          st_like_at(p, p.next(i), s, s.next(j))
        } else {
          false
        }
      }
    }

`%` then the rest of the pattern: the rest matches from here, or from one
character on.

    let st_like_any(p: String, i: StringIndex, s: String, j: StringIndex): Boolean {
      if (st_like_at(p, i, s, j)) {
        true
      } else if (j >= s.end) {
        false
      } else {
        st_like_any(p, i, s, s.next(j))
      }
    }

## Sorting the tags

`order_by: [{dir, field}]`, and `asc: :name` after it for any field but the
name. The program sorts twice with a stable sort (Blimp's `sort_by_keys`):
first by the name, then by this key, so ties keep the name order. The
server sends each tag's place in Postgres's own order of names (its
collation, not byte order) and of creation times, so this key is a number
whichever field it is.

    export let st_sort_key(field: String, dir: String, usage: Int, name_rank: Int, created_rank: Int): Int {
      let k = if (field == "name") { name_rank } else if (field == "inserted_at") { created_rank } else { usage };
      if (dir == "desc") { 0 - k } else { k }
    }

`@sort_fields` and the two directions.

    export let st_sort_field_ids: List<String> = ["usage_count", "name", "inserted_at"];

    export let st_sort_field_label(f: String): String {
      if (f == "usage_count") { "Link Count" } else if (f == "name") { "Name" } else { "Date Created" }
    }
