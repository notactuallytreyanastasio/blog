# Role Call

What `/role-call` decides rather than looks up: the pure parts of
`BlogWeb.RoleCallLive` (its `handle_params/3`, `run_search/2`, the liked and
hidden `MapSet`s, the tour's steps and moves, `thumb/1`, `format_number/1`,
how a rating and a run of years are printed), and the arithmetic of the two
hooks the page had in `assets/js/app.js`: `CardGrid`, which showed two rows
of cards, and `TourSpotlight`, which put the tour's spotlight and tooltip
next to what they point at.

The page's program (`static/role_call/role_call.blimp`) holds the state and
draws the view; the rows are Postgres's, sent by `src/99_role_call.blimp`.
Every name starts `rc_`: the site has one flat namespace.

    let { nyc_fixed1, nyc_format } = import("../nyc_census");

## The URL

`handle_params/3`: `?tab=liked` and `?tab=discover` are those tabs, anything
else is Search.

    export let rc_tab(tab: String): String {
      if (tab == "liked") { "liked" } else if (tab == "discover") { "discover" } else { "search" }
    }

`push_patch(to: ~p"/role-call?#{%{tab: tab, show: id}}")`, which the
running app writes `?show=tt0903747&tab=search`: the map's keys in their
sorted order. A show id is `tt` and digits and needs no escaping.

    export let rc_query(tab: String, show: String): String {
      if (show.isEmpty) { "tab=${tab}" } else { "show=${show}&tab=${tab}" }
    }

## Search

`run_search/2` asks the database only once the query is two characters
long: `String.length/1`, which counts graphemes. This counts code points,
the same thing for every query but one with combining marks or an emoji
built of several.

    export let rc_can_search(q: String): Boolean {
      !q.isEmpty && q.next(String.begin) < q.end
    }

## Liked and hidden

The LiveView kept each as a `MapSet` of show ids and stored
`MapSet.to_list/1` in localStorage. Here a set is its ids joined by commas,
kept sorted, which is the order `MapSet.to_list/1` gives for up to 32 ids
(past that the order is the map's hash order, which nobody could have
relied on). An id never has a comma: they are IMDb ids, `tt0903747`.

    export let rc_ids(set: String): List<String> {
      if (set.isEmpty) { [] } else { set.split(",") }
    }

    export let rc_has(set: String, id: String): Boolean {
      !rc_ids(set).filter { (x): Boolean => x == id }.isEmpty
    }

    export let rc_size(set: String): Int {
      rc_ids(set).length
    }

    export let rc_add(set: String, id: String): String {
      let ids = rc_ids(set);
      if (id.isEmpty || rc_has(set, id)) {
        set
      } else {
        rc_join3(
          ids.filter { (x): Boolean => x < id },
          id,
          ids.filter { (x): Boolean => x > id })
      }
    }

    export let rc_del(set: String, id: String): String {
      rc_ids(set).filter { (x): Boolean => x != id }.join(",") { (x): String => x }
    }

    let rc_join3(lo: List<String>, id: String, hi: List<String>): String {
      let a = lo.join(",") { (x): String => x };
      let b = hi.join(",") { (x): String => x };
      if (a.isEmpty && b.isEmpty) {
        id
      } else if (a.isEmpty) {
        "${id},${b}"
      } else if (b.isEmpty) {
        "${a},${id}"
      } else {
        "${a},${id},${b}"
      }
    }

`MapSet.union/2`, for the ids a query leaves out. Added one at a time, so
the result is sorted and has each id once.

    export let rc_union(a: String, b: String): String {
      rc_union_from(rc_ids(b), 0, a)
    }

    let rc_union_from(ids: List<String>, i: Int, acc: String): String {
      if (i >= ids.length) { acc } else { rc_union_from(ids, i + 1, rc_add(acc, ids[i])) }
    }

`MapSet.new(ids)`, for what localStorage hands back: whatever it held,
comma-joined by the page's script. Anything that is not an id (someone's
own localStorage edits) is dropped; an id is letters and digits.

    export let rc_clean(raw: String): String {
      rc_union("", rc_ids(raw).filter { (x): Boolean => rc_id_like(x) }.join(",") { (x): String => x })
    }

    let rc_id_like(s: String): Boolean {
      !s.isEmpty && rc_alnum_from(s, String.begin)
    }

    let rc_alnum_from(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else {
        let c = s[i];
        let ok = (c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
        if (ok) { rc_alnum_from(s, s.next(i)) } else { false }
      }
    }

## Printing a show

`Float.round(rating, 1)`, printed as Elixir prints a float: to the nearest
tenth of the double's exact value, one decimal. `nyc_fixed1` is exactly
that (see `temper/src/nyc_census`); every rating in the table has one
decimal already, so it only ever puts back the `.0` a JSON number loses.

    export let rc_rating(r: Float64): String {
      nyc_fixed1(r)
    }

A card's and a search result's second line: `{year_start}
{if rating, do: "★ #{Float.round(rating, 1)}"}`. The server sends a missing
year as 0 and a missing rating as -1, so these take plain numbers.

    export let rc_meta(year: Int, rating: Float64): String {
      let y = if (year > 0) { year.toString() } else { "" };
      if (rating < 0.0) { y } else if (y.isEmpty) { "★ ${rc_rating(rating)}" } else { "${y} ★ ${rc_rating(rating)}" }
    }

The modal's years: `{year_start}{if year_end && year_end != year_start, do:
"–#{year_end}"}`.

    export let rc_years(start: Int, stop: Int): String {
      let a = if (start > 0) { start.toString() } else { "" };
      if (stop > 0 && stop != start) { "${a}–${stop.toString()}" } else { a }
    }

A card's writers are `preload_writers/1`'s: the server sends every
`[show id, name]` its query gave for a list of cards, in the query's order
(creators first), and each card takes its own.

    export let rc_writers_of(pairs: List<List<String>>, id: String): List<String> {
      pairs.filter { (p): Boolean => p[0] == id }.map { (p): String => p[1] }
    }

On the card, the first two, `Enum.take(writers, 2)`, joined.

    export let rc_writers(names: List<String>): String {
      names.slice(0, 2).join(", ") { (x): String => x }
    }

`format_number/1`: a comma every three digits.

    export let rc_count(n: Int): String {
      nyc_format(n)
    }

`thumb/1`: `String.replace(url, ~r/@.*\./, "@._V1_SX200.")`, IMDb's way of
asking for the poster 200 pixels wide. The pattern is greedy, so it runs
from the first `@` to the last `.` after it, and the one match takes the
whole run. With no `@`, or no `.` after it, the URL is left alone. (`.`
does not match a newline, and no URL has one.)

    export let rc_thumb(url: String): String {
      let at = url.split("@");
      if (at.length < 2) {
        url
      } else {
        let after = at.slice(1, at.length).join("@") { (x): String => x };
        let dots = after.split(".");
        if (dots.length < 2) { url } else { "${at[0]}@._V1_SX200.${dots[dots.length - 1]}" }
      }
    }

## Two rows of cards

The shuffle grid is `repeat(auto-fill, minmax(150px, 1fr))` with a 16px
gap. `CardGrid` let the browser lay out all twenty cards, counted how many
shared the first card's top, and hid every card after two rows of them.
This is the count the browser comes to: auto-fill repeats a 150px track as
often as tracks and the gaps between them fit, and at least once
(CSS Grid, "repeat-to-fill"). The page's script reports the grid's width;
before it has, every card shows, as before the hook ran.

    export let rc_per_row(width: Int): Int {
      let n = ((width + 16) / 166) orelse 1;
      if (n < 1) { 1 } else { n }
    }

    export let rc_shown(cards: Int, width: Int): Int {
      if (width <= 0) {
        cards
      } else {
        let two = rc_per_row(width) * 2;
        if (cards < two) { cards } else { two }
      }
    }

## The tour

Five steps, as `tour_overlay/1` had them: a title, the text, the element it
points at (none for the first, which sits in the middle) and which side of
it the tooltip goes.

    export let rc_tour_total(): Int { 5 }

    export let rc_tour_title(step: Int): String {
      if (step == 1) {
        "Welcome to Role Call!"
      } else if (step == 2) {
        "Search for Shows"
      } else if (step == 3) {
        "Or Browse Random Picks"
      } else if (step == 4) {
        "Like Shows You Enjoy"
      } else {
        "Get Personalized Recommendations"
      }
    }

    export let rc_tour_text(step: Int): String {
      if (step == 1) {
        "Discover new TV shows based on the writers behind shows you already love. Let's take a quick tour!"
      } else if (step == 2) {
        "Type the name of any show you've enjoyed. We have over 58,000 shows in our database!"
      } else if (step == 3) {
        "Not sure where to start? Check out these random suggestions. Click 'Show me more' for fresh picks."
      } else if (step == 4) {
        "Click the heart to like a show. This teaches us your taste in writers."
      } else {
        "Once you've liked a few shows, head to the 'Liked' tab to see recommendations based on shared writers. Happy discovering!"
      }
    }

    export let rc_tour_target(step: Int): String {
      if (step == 1) {
        ""
      } else if (step == 2) {
        "tour-search"
      } else if (step == 3) {
        "tour-shuffle"
      } else if (step == 4) {
        "tour-card-0"
      } else {
        "tour-liked-tab"
      }
    }

    export let rc_tour_position(step: Int): String {
      if (step == 1) {
        "center"
      } else if (step == 2) {
        "bottom"
      } else if (step == 3) {
        "top"
      } else if (step == 4) {
        "right"
      } else {
        "bottom"
      }
    }

`tour_next`: the step after, or 0, no tour, past the last. `tour_prev`:
never before the first. `check_tour_status`: a visitor who has not finished
the tour and has liked nothing gets it from the start.

    export let rc_tour_next(step: Int): Int {
      if (step + 1 > rc_tour_total()) { 0 } else { step + 1 }
    }

    export let rc_tour_prev(step: Int): Int {
      if (step - 1 < 1) { 1 } else { step - 1 }
    }

    export let rc_tour_first(completed: Boolean, liked: Int): Int {
      if (!completed && liked == 0) { 1 } else { 0 }
    }

### Where the spotlight and the tooltip go

`TourSpotlight.positionElements()`: the spotlight is the target's box, 8px
bigger all round, as `[top, left, width, height]`.

    export let rc_spot(top: Float64, left: Float64, width: Float64, height: Float64): List<Float64> {
      [top - 8.0, left - 8.0, width + 16.0, height + 16.0]
    }

The tooltip, `[top, left]`, 20px off the target's side, centred on it but
never nearer the window's left edge than 20px (for `top` and `bottom`; the
hook did not clamp `right`). Centred tooltips are the stylesheet's, so they
get no place: `[]`.

    export let rc_tip(position: String, top: Float64, left: Float64, width: Float64, height: Float64, tip_w: Float64, tip_h: Float64): List<Float64> throws Bubble {
      let centred = rc_max(20.0, left + width / 2.0 - tip_w / 2.0);
      if (position == "bottom") {
        [top + height + 20.0, centred]
      } else if (position == "top") {
        [top - tip_h - 20.0, centred]
      } else if (position == "right") {
        [top + height / 2.0 - tip_h / 2.0, left + width + 20.0]
      } else {
        []
      }
    }

    let rc_max(a: Float64, b: Float64): Float64 { if (a > b) { a } else { b } }

The hook scrolled the target to the middle of the window when it was
within 100px of either edge.

    export let rc_scroll(top: Float64, bottom: Float64, window_h: Float64): Boolean {
      top < 100.0 || bottom > window_h - 100.0
    }
