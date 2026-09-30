# How many people live here?

The arithmetic of `/nyc_census_and_pluto`, from `Blog.Population.Geometry`,
`Blog.Population.Estimator`, the LiveView's `format_number/1` and the
`NycMap` hook's markers. The page's program (`static/nyc_census/census.blimp`)
runs it in the browser over rows the server passes through from Postgres:
every tax lot in the drawn shape's bounding box, and every census tract.

Every name starts `nyc_`: the site has one flat namespace.

    let { escape_html } = import("../text");

## The shape

A polygon is two lists, latitudes and longitudes, vertex for vertex, as
Leaflet.draw hands them over (`[[lat, lng], ...]`, unzipped).

Its bounding box, `[min_lat, max_lat, min_lng, max_lng]`, is what the
server is asked for: `Geometry.bounding_box/1`.

    export let nyc_bbox(lats: List<Float64>, lngs: List<Float64>): List<Float64> {
      [nyc_min(lats, 1, lats[0]), nyc_max(lats, 1, lats[0]), nyc_min(lngs, 1, lngs[0]), nyc_max(lngs, 1, lngs[0])]
    }

    let nyc_min(xs: List<Float64>, i: Int, best: Float64): Float64 {
      if (i >= xs.length) { best } else if (xs[i] < best) { nyc_min(xs, i + 1, xs[i]) } else { nyc_min(xs, i + 1, best) }
    }

    let nyc_max(xs: List<Float64>, i: Int, best: Float64): Float64 {
      if (i >= xs.length) { best } else if (xs[i] > best) { nyc_max(xs, i + 1, xs[i]) } else { nyc_max(xs, i + 1, best) }
    }

Whether a point is inside: `Geometry.point_in_polygon?/2`, ray casting,
the same test in the same order. Each edge runs from vertex `i` to the next,
the last back to the first; a horizontal ray from the point crosses it when
the edge straddles the point's latitude and meets the ray east of the
point. An odd number of crossings is inside. Where an edge straddles the
latitude its ends differ in latitude, so the division has a divisor.

    export let nyc_inside(lat: Float64, lng: Float64, lats: List<Float64>, lngs: List<Float64>): Boolean throws Bubble {
      nyc_crossings(lat, lng, lats, lngs, 0, false)
    }

    let nyc_crossings(lat: Float64, lng: Float64, lats: List<Float64>, lngs: List<Float64>, i: Int, inside: Boolean): Boolean throws Bubble {
      if (i >= lats.length) {
        inside
      } else if (nyc_crosses(lat, lng, lats[i], lngs[i], lats[nyc_next(i, lats.length)], lngs[nyc_next(i, lats.length)])) {
        nyc_crossings(lat, lng, lats, lngs, i + 1, !inside)
      } else {
        nyc_crossings(lat, lng, lats, lngs, i + 1, inside)
      }
    }

    let nyc_next(i: Int, n: Int): Int { if (i + 1 == n) { 0 } else { i + 1 } }

    let nyc_crosses(lat: Float64, lng: Float64, lat1: Float64, lng1: Float64, lat2: Float64, lng2: Float64): Boolean throws Bubble {
      if ((lat1 > lat) == (lat2 > lat)) {
        false
      } else {
        lng < lng1 + (lat - lat1) / (lat2 - lat1) * (lng2 - lng1)
      }
    }

## Tracts

PLUTO names a census tract `bct2020`: a borough digit, then the tract. The
Census names it by county FIPS code and tract (`Estimator.bct2020_to_geoid/1`).
"" for anything that is not a tract, where the Elixir said `nil`.

    export let nyc_geoid(bct2020: String): String {
      if (bct2020.isEmpty || bct2020.next(String.begin) >= bct2020.end) {
        ""
      } else {
        let second = bct2020.next(String.begin);
        let rest = bct2020.slice(second, bct2020.end);
        let fips = nyc_fips(bct2020.slice(String.begin, second));
        if (fips.isEmpty) { "" } else { "${fips}${rest}" }
      }
    }

    let nyc_fips(boro: String): String {
      if (boro == "1") {
        "061"
      } else if (boro == "2") {
        "005"
      } else if (boro == "3") {
        "047"
      } else if (boro == "4") {
        "081"
      } else if (boro == "5") {
        "085"
      } else {
        ""
      }
    }

## The estimate

A lot's people are its tract's people in proportion to its share of the
tract's residential units, to a tenth of a person (`proportional_pop/3`).
A tract with no units gives everyone in it none.

    export let nyc_share(units: Int, tract_units: Int, tract_pop: Int): Float64 throws Bubble {
      if (tract_units == 0) {
        0.0
      } else {
        nyc_round1(tract_pop.toFloat64() * (units.toFloat64() / tract_units.toFloat64()))
      }
    }

`Float.round(x, 1)`: to the nearest tenth of the double's exact value, a
half up. Never negative here. The exact value is what `nyc_tenths` below
decides by, for the reason given there.

    export let nyc_round1(x: Float64): Float64 throws Bubble {
      let p = x * 10.0;
      nyc_tenths(x, p, p.floor()) / 10.0
    }

## Numbers as the page prints them

`format_number/1`: a whole number with a comma every three digits.

    export let nyc_format(n: Int): String {
      if (n < 0) { "-${nyc_group(0 - n)}" } else { nyc_group(n) }
    }

    let nyc_group(n: Int): String {
      if (n < 1000) {
        n.toString()
      } else {
        let top = (n / 1000) orelse panic();
        "${nyc_group(top)},${nyc_pad3(n - top * 1000)}"
      }
    }

    let nyc_pad3(n: Int): String {
      if (n < 10) { "00${n.toString()}" } else if (n < 100) { "0${n.toString()}" } else { n.toString() }
    }

`toFixed(1)` in the hook's popup: one decimal, always printed. For the
numbers it is given here, never negative.

The obvious `(x * 10).round()` is wrong about one popup in ten. `toFixed`
rounds the double's exact value, and 2.85 / 2 is the double just under
1.425, so `toFixed(1)` says 1.4; but `x * 10.0` rounds its product to
14.25 exactly, which rounds to 15. The product can only mislead when it
lands exactly on a half, and then the exact product decides: Dekker's
split of `x` gives what `x * 10.0` rounded away (10 needs no split). A
true tie goes up, as `toFixed` picks the larger of two.

    export let nyc_fixed1(x: Float64): String {
      let p = x * 10.0;
      let tenths = nyc_tenths(x, p, p.floor()).toInt32Unsafe();
      let whole = (tenths / 10) orelse panic();
      "${whole.toString()}.${(tenths - whole * 10).toString()}"
    }

    let nyc_tenths(x: Float64, p: Float64, down: Float64): Float64 {
      if (p - down != 0.5) {
        p.round()
      } else if (nyc_mul10_error(x, p) < 0.0) {
        down
      } else {
        down + 1.0
      }
    }

    let nyc_mul10_error(x: Float64, p: Float64): Float64 {
      let c = 134217729.0 * x;
      let hi = c - (c - x);
      let lo = x - hi;
      (hi * 10.0 - p) + lo * 10.0
    }

## Markers

The hook drew a lot as a circle whose size and colour say how its people
compare with the most crowded lot in the shape: `intensity` is its share of
that maximum, at most 1.

    export let nyc_intensity(pop: Float64, max_pop: Float64): Float64 throws Bubble {
      let m = if (max_pop < 1.0) { 1.0 } else { max_pop };
      let t = pop / m;
      if (t > 1.0) { 1.0 } else { t }
    }

    export let nyc_radius(intensity: Float64): Float64 { 3.0 + intensity * 12.0 }

`popColor`: blue through yellow to red.

    export let nyc_color(intensity: Float64): String {
      if (intensity < 0.5) {
        let t = intensity * 2.0;
        nyc_rgb(65.0 + t * 190.0, 105.0 + t * 150.0, 225.0 - t * 200.0)
      } else {
        let t = (intensity - 0.5) * 2.0;
        nyc_rgb(255.0, 255.0 - t * 200.0, 25.0 - t * 25.0)
      }
    }

    let nyc_rgb(r: Float64, g: Float64, b: Float64): String {
      "rgb(${r.round().toInt32Unsafe().toString()},${g.round().toInt32Unsafe().toString()},${b.round().toInt32Unsafe().toString()})"
    }

A lot's popup, as the hook wrote it. The address is escaped here; the hook
put it in as it came. `floors` is as Postgres printed it, "" or "0" for
none; `year` 0 for unknown.

    export let nyc_popup(address: String, pop: Float64, units: Int, tract_units: Int, floors: String, year: Int, bbl: String): String throws Bubble {
      let name = if (address.isEmpty) { "Unknown" } else { escape_html(address) };
      let head = "<strong>${name}</strong><br/>Est. population: <strong>${pop.round().toInt32Unsafe().toString()}</strong><br/>Residential units: <strong>${units.toString()}</strong><br/>";
      let note = nyc_note(pop, units, tract_units);
      let fl = if (floors == "" || floors == "0") { "" } else { "Floors: ${escape_html(floors)}<br/>" };
      let built = if (year > 0) { "Built: ${year.toString()}<br/>" } else { "" };
      let id = if (bbl.isEmpty) { "N/A" } else { escape_html(bbl) };
      "${head}${note}${fl}${built}<span style=\"color:#9ca3af;font-size:11px\">BBL: ${id}</span>"
    }

    let nyc_note(pop: Float64, units: Int, tract_units: Int): String throws Bubble {
      if (units > 0 && pop > 0.0) {
        let ppu = nyc_fixed1(pop / units.toFloat64());
        let share = if (tract_units > 0) {
          " &middot; ${nyc_fixed1(units.toFloat64() / tract_units.toFloat64() * 100.0)}% of tract's ${nyc_format(tract_units)} units"
        } else { "" };
        "<span style=\"color:#6b7280;font-size:12px\">~${ppu} people per unit${share}</span><br/>"
      } else if (units == 0) {
        "<span style=\"color:#6b7280;font-size:12px\">Non-residential lot</span><br/>"
      } else {
        ""
      }
    }
