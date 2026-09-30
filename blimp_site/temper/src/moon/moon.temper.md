# Moon

Moon Phish's arithmetic: Meeus, "Astronomical Algorithms" ch. 49, for the
instant of every new and full moon, the civil calendar around it, and the
formatting the page does with the answers. This was the math half of
`src/98_moon.blimp` and the pure half of `static/moon/moon.blimp`; what is
left there is actors, maps and the list sweeps, which are Blimp's own shapes.

Every function here answers exactly the bits the Blimp did: the sums are
written in the same order and grouping, because floating-point addition is
not associative and the gate is the JSON, byte for byte.

## Floats that bubble

Temper's `/` on `Float64` can bubble, so any function that divides says
`throws Bubble`. On the Blimp backend nothing is caught: the Blimp callers
call these as plain functions, and none of them ever divides by zero.

`MOON_DEG` was `3.141592653589793 / 180.0`, computed at load. It is written
as the literal that division gives, `0.017453292519943295`; Blimp says the two
are `==`.

    let moon_sin_d(degrees: Float64): Float64 {
      (degrees * 0.017453292519943295).sin()
    }

The JDE of the mean phase for lunation index `k`, plus the periodic
corrections. An integer `k` is a new moon, `k + 0.5` a full one.

    export let moon_phase_jde(k: Float64): Float64 throws Bubble {
      let t = k / 1236.85;
      let t2 = t * t;
      let t3 = t2 * t;
      let t4 = t3 * t;
      let mean = 2451550.09766 + 29.530588861 * k + 0.00015437 * t2 - 0.000000150 * t3 + 0.00000000073 * t4;
      let e = 1.0 - 0.002516 * t - 0.0000074 * t2;
      let m = 2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3;
      let mp = 201.5643 + 385.81693528 * k + 0.0107582 * t2 + 0.00001238 * t3 - 0.000000058 * t4;
      let f = 160.7108 + 390.67050284 * k - 0.0016118 * t2 - 0.00000227 * t3 + 0.000000011 * t4;
      let om = 124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3;
      let full = k - k.floor() > 0.25;
      mean + moon_correction(full, e, m, mp, f, om) + moon_planetary(k, t2)
    }

The seven leading coefficients differ between new and full moons; the rest
are shared. A `let x = if ...` lowers to a branch that writes the name and
hands it back in a one-element list, so the choice is a function whose body is
the `if`, which lowers to a plain `case`.

    let moon_pick(full: Boolean, a: Float64, b: Float64): Float64 {
      if (full) { a } else { b }
    }

    let moon_correction(full: Boolean, e: Float64, m: Float64, mp: Float64, f: Float64, om: Float64): Float64 {
      let c1 = moon_pick(full, -0.40614, -0.40720);
      let c2 = moon_pick(full, 0.17302, 0.17241);
      let c3 = moon_pick(full, 0.01614, 0.01608);
      let c4 = moon_pick(full, 0.01043, 0.01039);
      let c5 = moon_pick(full, 0.00734, 0.00739);
      let c6 = moon_pick(full, -0.00515, -0.00514);
      let c7 = moon_pick(full, 0.00209, 0.00208);
      c1 * moon_sin_d(mp) + c2 * e * moon_sin_d(m) + c3 * moon_sin_d(2.0 * mp) + c4 * moon_sin_d(2.0 * f) + c5 * e * moon_sin_d(mp - m) + c6 * e * moon_sin_d(mp + m) + c7 * e * e * moon_sin_d(2.0 * m) + -0.00111 * moon_sin_d(mp - 2.0 * f) + -0.00057 * moon_sin_d(mp + 2.0 * f) + 0.00056 * e * moon_sin_d(2.0 * mp + m) + -0.00042 * moon_sin_d(3.0 * mp) + 0.00042 * e * moon_sin_d(m + 2.0 * f) + 0.00038 * e * moon_sin_d(m - 2.0 * f) + -0.00024 * e * moon_sin_d(2.0 * mp - m) + -0.00017 * moon_sin_d(om) + -0.00007 * moon_sin_d(mp + 2.0 * m) + 0.00004 * moon_sin_d(2.0 * mp - 2.0 * f) + 0.00004 * moon_sin_d(3.0 * m) + 0.00003 * moon_sin_d(mp + m - 2.0 * f) + 0.00003 * moon_sin_d(2.0 * mp + 2.0 * f) + -0.00003 * moon_sin_d(mp + m + 2.0 * f) + 0.00003 * moon_sin_d(mp - m + 2.0 * f) + -0.00002 * moon_sin_d(mp - m - 2.0 * f) + -0.00002 * moon_sin_d(3.0 * mp + m) + 0.00002 * moon_sin_d(4.0 * mp)
    }

The fourteen planetary arguments. The Blimp folded a table of them with
`reduce` from `0.0`; this is that fold unrolled, in the table's order. The
table's thirteen `t2` coefficients of `0` added `0 * t2`, which is `+0.0` and
changes nothing (`t2` is a square, so it is never `-0.0` either), so they are
gone.

    let moon_planetary(k: Float64, t2: Float64): Float64 {
      0.0 + 0.000325 * moon_sin_d(299.77 + 0.107408 * k + -0.009173 * t2) + 0.000165 * moon_sin_d(251.88 + 0.016321 * k) + 0.000164 * moon_sin_d(251.83 + 26.651886 * k) + 0.000126 * moon_sin_d(349.42 + 36.412478 * k) + 0.000110 * moon_sin_d(84.66 + 18.206239 * k) + 0.000062 * moon_sin_d(141.74 + 53.303771 * k) + 0.000060 * moon_sin_d(207.14 + 2.453732 * k) + 0.000056 * moon_sin_d(154.84 + 7.306860 * k) + 0.000047 * moon_sin_d(34.52 + 27.261239 * k) + 0.000042 * moon_sin_d(207.19 + 0.121824 * k) + 0.000040 * moon_sin_d(291.34 + 1.844379 * k) + 0.000037 * moon_sin_d(161.72 + 24.198154 * k) + 0.000035 * moon_sin_d(239.56 + 25.513099 * k) + 0.000023 * moon_sin_d(331.55 + 3.592518 * k)
    }

JDE to unix seconds. This is dynamical time; ΔT, about a minute here, is
ignored, as Blog.Moon ignored it.

    export let moon_unix(jde: Float64): Int64 {
      ((jde - 2440587.5) * 86400.0).round().toInt64Unsafe()
    }

    export let moon_day_of(unix: Int64): Int64 throws Bubble {
      (unix.toFloat64Unsafe() / 86400.0).floor().toInt64Unsafe()
    }

## Civil dates

Days since 1970-01-01, and back. Integer division truncates, as Blimp's does,
which is why the negative eras step down by 399 first.

    export let moon_days(y0: Int64, m: Int64, d: Int64): Int64 {
      let y = moon_march_year(y0, m);
      moon_days_y(y, moon_era(y), m, d)
    }

The year counted from March, so that a leap day is the last day of it.

    let moon_march_year(y0: Int64, m: Int64): Int64 {
      if (m <= 2i64) { y0 - 1i64 } else { y0 }
    }

    let moon_days_y(y: Int64, era: Int64, m: Int64, d: Int64): Int64 {
      let yoe = y - era * 400i64;
      let doy = (153i64 * moon_march(m) + 2i64) / 5i64 + d - 1i64;
      era * 146097i64 + yoe * 365i64 + yoe / 4i64 - yoe / 100i64 + doy - 719468i64
    }

    let moon_era(y: Int64): Int64 {
      if (y >= 0i64) { y / 400i64 } else { (y - 399i64) / 400i64 }
    }

    let moon_day_era(z: Int64): Int64 {
      if (z >= 0i64) { z / 146097i64 } else { (z - 146096i64) / 146097i64 }
    }

    let moon_march(m: Int64): Int64 {
      if (m > 2i64) { m - 3i64 } else { m + 9i64 }
    }

A date is `YYYY-MM-DD`. Temper cannot slice a string at a byte count it made
up, so this splits on the dashes instead.

    export let moon_date_days(date: String): Int64 throws Bubble {
      let parts = date.split("-");
      moon_days(parts[0].toInt64(), parts[1].toInt64(), parts[2].toInt64())
    }

    export let moon_ymd(z0: Int64): List<Int64> {
      let z = z0 + 719468i64;
      let era = moon_day_era(z);
      let doe = z - era * 146097i64;
      let yoe = (doe - doe / 1460i64 + doe / 36524i64 - doe / 146096i64) / 365i64;
      let doy = doe - (365i64 * yoe + yoe / 4i64 - yoe / 100i64);
      let mp = (5i64 * doy + 2i64) / 153i64;
      let d = doy - (153i64 * mp + 2i64) / 5i64 + 1i64;
      let m = moon_civil_month(mp);
      [moon_civil_year(yoe + era * 400i64, m), m, d]
    }

    let moon_civil_month(mp: Int64): Int64 {
      if (mp < 10i64) { mp + 3i64 } else { mp - 9i64 }
    }

    let moon_civil_year(y: Int64, m: Int64): Int64 {
      if (m <= 2i64) { y + 1i64 } else { y }
    }

    export let moon_iso(day: Int64): String {
      let ymd = moon_ymd(day);
      "${ymd[0].toString()}-${moon_pad(ymd[1])}-${moon_pad(ymd[2])}"
    }

    export let moon_pad(n: Int64): String {
      if (n < 10i64) { "0${n.toString()}" } else { n.toString() }
    }

## Naming a phase

The phase name and its glyph for a fraction of the synodic month. On the
night of a full moon it is Full Moon whatever the fraction says; just either
side of one half it is the gibbous on the correct side.

    export let moon_named(full: Boolean, fraction: Float64): List<String> {
      if (full) {
        ["Full Moon", "🌕"]
      } else if (fraction >= 0.467) {
        if (fraction < 0.5) {
          ["Waxing Gibbous", "🌔"]
        } else if (fraction < 0.533) {
          ["Waning Gibbous", "🌖"]
        } else {
          moon_name_of(fraction)
        }
      } else {
        moon_name_of(fraction)
      }
    }

    let moon_name_of(fraction: Float64): List<String> {
      if (fraction < 0.033) {
        ["New Moon", "🌑"]
      } else if (fraction < 0.216) {
        ["Waxing Crescent", "🌒"]
      } else if (fraction < 0.283) {
        ["First Quarter", "🌓"]
      } else if (fraction < 0.467) {
        ["Waxing Gibbous", "🌔"]
      } else if (fraction < 0.533) {
        ["Full Moon", "🌕"]
      } else if (fraction < 0.717) {
        ["Waning Gibbous", "🌖"]
      } else if (fraction < 0.784) {
        ["Last Quarter", "🌗"]
      } else if (fraction < 0.967) {
        ["Waning Crescent", "🌘"]
      } else {
        ["New Moon", "🌑"]
      }
    }

    export let moon_illum(fraction: Float64): Float64 throws Bubble {
      (1.0 - (fraction * 2.0 * 3.141592653589793).cos()) / 2.0
    }

## The page's formatting

What `static/moon/moon.blimp` does to a show before it draws it. Month names
are an if-chain rather than a list, which is one comparison per month where a
list index is a bounds check that bubbles.

    let mp_month(m: Int64): String {
      if (m == 1i64) { "January" } else if (m == 2i64) { "February" } else if (m == 3i64) { "March" } else if (m == 4i64) { "April" } else if (m == 5i64) { "May" } else if (m == 6i64) { "June" } else if (m == 7i64) { "July" } else if (m == 8i64) { "August" } else if (m == 9i64) { "September" } else if (m == 10i64) { "October" } else if (m == 11i64) { "November" } else { "December" }
    }

    export let mp_year(date: String): Int64 throws Bubble {
      date.split("-")[0].toInt64()
    }

`Calendar.strftime(date, "%b %d")`: "Dec 02".

    export let mp_date(date: String): String throws Bubble {
      let parts = date.split("-");
      let month = mp_month(parts[1].toInt64());
      "${month.slice(String.begin, month.next(month.next(month.next(String.begin))))} ${parts[2]}"
    }

`"%B %-d, %Y"`: "December 2, 1983".

    export let mp_long_date(date: String): String throws Bubble {
      if (date.isEmpty) {
        ""
      } else {
        let parts = date.split("-");
        "${mp_month(parts[1].toInt64())} ${parts[2].toInt64().toString()}, ${parts[0]}"
      }
    }

`fmt_pct/2`: one decimal, as `:erlang.float_to_binary(decimals: 1)` gives it.
`total` is a `Float64` because one caller passes 29.5. The others have a
count, and pass `total * 1.0`: Blimp's checker refuses an Int where
temper-core's float comparisons declare a Float, at build time, which is
where the Blimp version did its `* 1.0` anyway.

    export let mp_pct(count: Int64, total: Float64): String throws Bubble {
      if (total > 0.0) {
        let tenths = ((1000i64 * count).toFloat64Unsafe() / total).round().toInt64Unsafe();
        "${(tenths / 10i64).toString()}.${(tenths % 10i64).toString()}%"
      } else {
        "0%"
      }
    }

    export let mp_era_title(era: String): String {
      if (era == "1.0") {
        "Phish 1.0 — 1983–2000"
      } else if (era == "2.0") {
        "Phish 2.0 — 2002–2004"
      } else if (era == "3.0") {
        "Phish 3.0 — 2009–2020"
      } else if (era == "4.0") {
        "Phish 4.0 — 2021–now"
      } else {
        "All eras"
      }
    }

    export let mp_era_match(year: Int64, era: String): Boolean {
      if (era == "1.0") {
        year <= 2000i64
      } else if (era == "2.0") {
        year >= 2002i64 && year <= 2004i64
      } else if (era == "3.0") {
        year >= 2009i64 && year <= 2020i64
      } else if (era == "4.0") {
        year >= 2021i64
      } else {
        true
      }
    }

`near_full_label/1`: within a day and a half of the full moon, and not on it.

    export let mp_near(full: Boolean, dff: Float64): String {
      let d = dff.abs();
      if (full) {
        ""
      } else if (d > 1.5) {
        ""
      } else {
        let days = moon_at_least_one(d.round().toInt64Unsafe());
        if (dff < 0.0) { "${days.toString()}d before full" } else { "${days.toString()}d after full" }
      }
    }

    let moon_at_least_one(n: Int64): Int64 {
      if (n < 1i64) { 1i64 } else { n }
    }

    export let mp_class(base: String, active: Boolean): String {
      if (active) { "${base} mp95-active" } else { base }
    }
