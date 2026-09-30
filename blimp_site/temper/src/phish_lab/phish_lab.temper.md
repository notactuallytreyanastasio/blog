# Phish Lab

The arithmetic of `/phish_lab`: what Phoenix's `BlogWeb.PhishLabLive` and
`Blog.PhishLab` decided on the server (which metrics a dataset has, the
presets, how the inspector writes a number), and what the page's d3 hook
decided in the browser (scales, ticks, tick labels, bins, colours, radii,
tooltip numbers). The page's program, `static/phish_lab/phish_lab.blimp`,
calls these; the loops over rows stay Blimp, because a row is a Blimp map
with string keys and because Temper builds a longer list only with a
`ListBuilder`, which on this backend is an actor that is never collected.
So a function here answers one tick, one boundary, one colour, and the
program walks.

d3 is the reference for everything under "Scales": `d3-array`'s `ticks`,
`tickIncrement`, `tickStep` and `bin`; `d3-scale`'s linear `nice`, log
`ticks`/`nice`/`tickFormat`, and time `ticks`/`nice`/`tickFormat`;
`d3-format`'s `",f"` and `"~s"`; `d3-interpolate`'s `interpolateRgb`. Where
this differs from d3 it says so.

## Eras

The hook's `eraOf`: the last show of each era.

    export let pl_era(date: String): String {
      if (date <= "2000-10-07") {
        "1.0"
      } else if (date <= "2004-08-15") {
        "2.0"
      } else if (date <= "2020-02-23") {
        "3.0"
      } else {
        "4.0"
      }
    }

## Dates as days

The hook parsed "YYYY-MM-DD" into a local-midnight `Date` and d3's time
scale worked in milliseconds. Here a date is days since 1970-01-01: the
scale is the same line, and no two dates are nearer than a day. (A local
midnight moves an hour at a DST change; on an axis of thirty years that is
a thousandth of a pixel.)

days_from_civil and civil_from_days (Howard Hinnant). The same as
`ph_days` in the phish module, kept here so this module stands alone.

    export let pl_days(date: String): Int {
      pl_days_scan(date, String.begin, 0, 0, 0, 0)
    }

    let pl_days_scan(s: String, i: StringIndex, field: Int, y: Int, m: Int, d: Int): Int {
      if (i >= s.end) {
        pl_days_of(y, m, d)
      } else {
        let c = s[i];
        if (c < 48 || c > 57) {
          pl_days_scan(s, s.next(i), field + 1, y, m, d)
        } else if (field == 0) {
          pl_days_scan(s, s.next(i), field, y * 10 + c - 48, m, d)
        } else if (field == 1) {
          pl_days_scan(s, s.next(i), field, y, m * 10 + c - 48, d)
        } else {
          pl_days_scan(s, s.next(i), field, y, m, d * 10 + c - 48)
        }
      }
    }

    export let pl_days_of(y0: Int, m: Int, d: Int): Int {
      let y = if (m <= 2) { y0 - 1 } else { y0 };
      let era = pl_div(y, 400);
      let yoe = y - era * 400;
      let mp = if (m > 2) { m - 3 } else { m + 9 };
      let doy = pl_div(153 * mp + 2, 5) + d - 1;
      let doe = yoe * 365 + pl_div(yoe, 4) - pl_div(yoe, 100) + doy;
      era * 146097 + doe - 719468
    }

`[year, month, day]`.

    export let pl_civil(z0: Int): List<Int> {
      let z = z0 + 719468;
      let era = pl_div(z, 146097);
      let doe = z - era * 146097;
      let yoe = pl_div(doe - pl_div(doe, 1460) + pl_div(doe, 36524) - pl_div(doe, 146096), 365);
      let doy = doe - (365 * yoe + pl_div(yoe, 4) - pl_div(yoe, 100));
      let mp = pl_div(5 * doy + 2, 153);
      let d = doy - pl_div(153 * mp + 2, 5) + 1;
      let m = if (mp < 10) { mp + 3 } else { mp - 9 };
      let y = if (m <= 2) { yoe + era * 400 + 1 } else { yoe + era * 400 };
      [y, m, d]
    }

0 is Sunday: 1970-01-01 was a Thursday.

    export let pl_weekday(z: Int): Int {
      pl_mod(pl_mod(z, 7) + 11, 7)
    }

    export let pl_date(z: Int): String {
      let c = pl_civil(z);
      "${c[0].toString()}-${pl_pad2(c[1])}-${pl_pad2(c[2])}"
    }

    let pl_pad2(n: Int): String {
      if (n < 10) { "0${n.toString()}" } else { n.toString() }
    }

Floor division and a modulus that is never negative, for the dates.

    export let pl_div(a: Int, b: Int): Int {
      let q = (a / b) orelse panic();
      if (q * b > a) { q - 1 } else { q }
    }

    export let pl_mod(a: Int, b: Int): Int {
      a - pl_div(a, b) * b
    }

## Scales

### Ticks (d3-array)

Powers of ten as d3 writes them, `+("1e" + n)`: exact for n >= 0, and the
nearest double to 10^n below, which one correctly rounded division is.

    export let pl_pow10(n: Int): Float64 {
      if (n >= 0) { pl_pow10_up(n, 1.0) } else { pl_q(1.0, pl_pow10_up(0 - n, 1.0)) }
    }

    let pl_pow10_up(n: Int, acc: Float64): Float64 {
      if (n <= 0) { acc } else { pl_pow10_up(n - 1, acc * 10.0) }
    }

`Math.floor(Math.log10(x))` for x > 0. A logarithm can land a hair under
an integer at an exact power of ten, where JavaScript's does not, so the
answer is checked against the powers themselves.

    export let pl_exponent(x: Float64): Int {
      let e = x.log10().floor().toInt32Unsafe();
      if (pl_pow10(e) > x) {
        e - 1
      } else if (pl_pow10(e + 1) <= x) {
        e + 1
      } else {
        e
      }
    }

Float division, which in Temper can fail; nothing here divides by zero.

    let pl_q(a: Float64, b: Float64): Float64 {
      (a / b) orelse panic()
    }

`Math.round`: half up, toward +infinity.

    export let pl_round(x: Float64): Float64 {
      (x + 0.5).floor()
    }

d3's tickSpec: `[i1, i2, inc]`, the ticks being `i * inc` for i from i1 to
i2, or `i / -inc` when inc is negative (a step under one, kept as its
reciprocal so that 0.1 steps are made by division and come out exact).

    export let pl_tick_spec(start: Float64, stop: Float64, count: Float64): List<Float64> {
      let step = pl_q(stop - start, count);
      let power = pl_exponent(step);
      let error = pl_q(step, pl_pow10(power));
      let factor = if (error >= 7.0710678118654755) {
        10.0
      } else if (error >= 3.1622776601683795) {
        5.0
      } else if (error >= 1.4142135623730951) {
        2.0
      } else {
        1.0
      };
      if (power < 0) {
        let inc = pl_q(pl_pow10(0 - power), factor);
        let a = pl_round(start * inc);
        let b = pl_round(stop * inc);
        let i1 = if (pl_q(a, inc) < start) { a + 1.0 } else { a };
        let i2 = if (pl_q(b, inc) > stop) { b - 1.0 } else { b };
        pl_tick_spec_or_twice(start, stop, count, i1, i2, 0.0 - inc)
      } else {
        let inc = pl_pow10(power) * factor;
        let a = pl_round(pl_q(start, inc));
        let b = pl_round(pl_q(stop, inc));
        let i1 = if (a * inc < start) { a + 1.0 } else { a };
        let i2 = if (b * inc > stop) { b - 1.0 } else { b };
        pl_tick_spec_or_twice(start, stop, count, i1, i2, inc)
      }
    }

    let pl_tick_spec_or_twice(start: Float64, stop: Float64, count: Float64, i1: Float64, i2: Float64, inc: Float64): List<Float64> {
      if (i2 < i1 && 0.5 <= count && count < 2.0) {
        pl_tick_spec(start, stop, count * 2.0)
      } else {
        [i1, i2, inc]
      }
    }

The tick numbered i of a spec.

    export let pl_tick_at(i: Float64, inc: Float64): Float64 {
      if (inc < 0.0) { pl_q(i, 0.0 - inc) } else { i * inc }
    }

    export let pl_tick_increment(start: Float64, stop: Float64, count: Float64): Float64 {
      pl_tick_spec(start, stop, count)[2]
    }

    export let pl_tick_step(start: Float64, stop: Float64, count: Float64): Float64 {
      let reverse = stop < start;
      let inc = if (reverse) { pl_tick_increment(stop, start, count) } else { pl_tick_increment(start, stop, count) };
      let step = if (inc < 0.0) { pl_q(1.0, 0.0 - inc) } else { inc };
      if (reverse) { 0.0 - step } else { step }
    }

### Linear nice (d3-scale)

`scale.nice(count)` on an ascending domain: widen it to whole steps, and
again while the step changes, at most ten times. `[start, stop]`.

    export let pl_nice(start: Float64, stop: Float64, count: Float64): List<Float64> {
      pl_nice_loop(start, stop, count, 0.0, 10)
    }

    let pl_nice_loop(start: Float64, stop: Float64, count: Float64, prestep: Float64, left: Int): List<Float64> {
      if (left <= 0 || !(stop > start)) {
        [start, stop]
      } else {
        let step = pl_tick_increment(start, stop, count);
        if (step == prestep) {
          [start, stop]
        } else if (step > 0.0) {
          pl_nice_loop(pl_q(start, step).floor() * step, pl_q(stop, step).ceil() * step, count, step, left - 1)
        } else if (step < 0.0) {
          pl_nice_loop(pl_q((start * step).ceil(), step), pl_q((stop * step).floor(), step), count, step, left - 1)
        } else {
          [start, stop]
        }
      }
    }

The hook's domain before `nice()`: the extent, padded 4% of its width (or
of 1, when every value is the same) each way.

    export let pl_pad(lo: Float64, hi: Float64): Float64 {
      let w = hi - lo;
      (if (w == 0.0) { 1.0 } else { w }) * 0.04
    }

### Mapping a value

A continuous scale with no clamping, d3's `r0 + (v - d0) / (d1 - d0) *
(r1 - r0)`, as `[k, b]` with r = v * k + b: the program maps twenty
thousand points by multiplying and adding in Blimp, rather than calling
Temper per point (27 ms a pass in the native interpreter, against 2).
They differ from d3 in the last bits of a pixel. A domain of one value
maps everything to the middle of the range, as d3's normalize does. A log
scale is this over the logarithms, a sqrt scale over signed square roots.

    export let pl_affine(d0: Float64, d1: Float64, r0: Float64, r1: Float64): List<Float64> {
      if (d1 == d0) {
        [0.0, r0 + (r1 - r0) * 0.5]
      } else {
        let k = pl_q(r1 - r0, d1 - d0);
        [k, r0 - d0 * k]
      }
    }

`scaleSqrt` is a power scale of exponent 0.5, which keeps the sign.

    export let pl_ssqrt(x: Float64): Float64 {
      if (x < 0.0) { 0.0 - (0.0 - x).sqrt() } else { x.sqrt() }
    }

### Log scales

`nice()`: out to the powers of ten either side.

    export let pl_log_nice(lo: Float64, hi: Float64): List<Float64> {
      [pl_pow10(lo.log10().floor().toInt32Unsafe()), pl_pow10(hi.log10().ceil().toInt32Unsafe())]
    }

`ticks(count)` for base 10 walks the decades i from floor(log10 u) to
ceil(log10 v) and the multiples k from 1 to 9, keeping those in [u, v]; the
program walks, this is one of them. When there are `count` decades or more
it takes linear ticks of the exponents instead, and when the multiples
come to fewer than half of `count`, linear ticks of the domain.

    export let pl_log_tick(i: Int, k: Int): Float64 {
      if (i < 0) { pl_q(k.toFloat64(), pl_pow10(0 - i)) } else { k.toFloat64() * pl_pow10(i) }
    }

    export let pl_log10(x: Float64): Float64 { x.log10() }

The log scale's `tickFormat()` labels a tick only if its leading digit is
at most k = max(1, 10 * 10 / the number of ticks(10)), and blanks the rest.

    export let pl_log_label_ok(d: Float64, k: Float64): Boolean {
      let i0 = pl_q(d, pl_pow10(d.log10().round().toInt32Unsafe()));
      let i = if (i0 * 10.0 < 9.5) { i0 * 10.0 } else { i0 };
      i <= k
    }

### Time (d3-scale's scaleTime, on days)

d3 picks the interval whose length is nearest the span over `count`, from
its table: 1, 5, 15 and 30 seconds, 1, 5, 15 and 30 minutes, 1, 3, 6 and 12
hours, 1 and 2 days, a week, 1 and 3 months, a year; past a year it counts
years by `tickStep`. The answer is `[kind, step]`: kind 0 days, 1 weeks
(Sundays), 2 months, 3 years. Dates have no time of day, so an interval
under a day is taken as a day: a span that short is one date.

    export let pl_time_interval(d0: Int, d1: Int, count: Float64): List<Int> {
      let span = if (d1 >= d0) { d1 - d0 } else { d0 - d1 };
      let target = pl_q(span.toFloat64(), count);
      if (target >= 365.0) {
        let k = pl_tick_step(pl_q(d0.toFloat64(), 365.0), pl_q(d1.toFloat64(), 365.0), count).floor().toInt32Unsafe();
        [3, if (k < 1) { 1 } else { k }]
      } else if (target >= 90.0) {
        pl_time_pick(target, 90.0, [2, 3], 365.0, [3, 1])
      } else if (target >= 30.0) {
        pl_time_pick(target, 30.0, [2, 1], 90.0, [2, 3])
      } else if (target >= 7.0) {
        pl_time_pick(target, 7.0, [1, 1], 30.0, [2, 1])
      } else if (target >= 2.0) {
        pl_time_pick(target, 2.0, [0, 2], 7.0, [1, 1])
      } else if (target >= 1.0) {
        pl_time_pick(target, 1.0, [0, 1], 2.0, [0, 2])
      } else {
        [0, 1]
      }
    }

    let pl_time_pick(target: Float64, below: Float64, a: List<Int>, above: Float64, b: List<Int>): List<Int> {
      if (pl_q(target, below) < pl_q(above, target)) { a } else { b }
    }

Is `z` a boundary of the interval? d3's `every(step)` for days, months
and years keeps those whose day of the month less one, month less one, or
year is a multiple of the step.

    export let pl_time_is(z: Int, kind: Int, step: Int): Boolean {
      let c = pl_civil(z);
      if (kind == 0) {
        pl_mod(c[2] - 1, step) == 0
      } else if (kind == 1) {
        pl_weekday(z) == 0
      } else if (kind == 2) {
        c[2] == 1 && pl_mod(c[1] - 1, step) == 0
      } else {
        c[1] == 1 && c[2] == 1 && pl_mod(c[0], step) == 0
      }
    }

The last boundary at or before `z` (d3's `interval.floor`, which `nice()`
widens the start to), and the one after a boundary.

    export let pl_time_floor(z: Int, kind: Int, step: Int): Int {
      let c = pl_civil(z);
      if (kind == 0) {
        z - pl_mod(c[2] - 1, step)
      } else if (kind == 1) {
        z - pl_weekday(z)
      } else if (kind == 2) {
        let m0 = c[1] - 1;
        pl_days_of(c[0], m0 - pl_mod(m0, step) + 1, 1)
      } else {
        pl_days_of(c[0] - pl_mod(c[0], step), 1, 1)
      }
    }

    let pl_time_after(b: Int, kind: Int, step: Int): Int {
      let c = pl_civil(b);
      if (kind == 0) {
        let first_next = pl_first_of_next_month(c[0], c[1]);
        if (b + step >= first_next) { first_next } else { b + step }
      } else if (kind == 1) {
        b + 7
      } else if (kind == 2) {
        let m0 = c[1] - 1 + step;
        if (m0 >= 12) { pl_days_of(c[0] + 1, m0 - 12 + 1, 1) } else { pl_days_of(c[0], m0 + 1, 1) }
      } else {
        pl_days_of(c[0] + step, 1, 1)
      }
    }

    let pl_first_of_next_month(y: Int, m: Int): Int {
      if (m == 12) { pl_days_of(y + 1, 1, 1) } else { pl_days_of(y, m + 1, 1) }
    }

The first boundary after `z`, and the first at or after it (d3's
`interval.ceil`, which `nice()` widens the end to).

    export let pl_time_next(z: Int, kind: Int, step: Int): Int {
      pl_time_after(pl_time_floor(z, kind, step), kind, step)
    }

    export let pl_time_ceil(z: Int, kind: Int, step: Int): Int {
      if (pl_time_floor(z, kind, step) == z) { z } else { pl_time_next(z, kind, step) }
    }

d3's multi-scale time format, for midnights: a year's first day is "1997",
a month's "March", a Sunday "Mar 09", any other day "Sun 09" -- which is
"%a %d", and so a weekday.

    export let pl_time_label(z: Int): String {
      let c = pl_civil(z);
      let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      if (c[2] != 1) {
        if (pl_weekday(z) != 0) {
          "${days[pl_weekday(z)]} ${pl_pad2(c[2])}"
        } else {
          let short = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
          "${short[c[1] - 1]} ${pl_pad2(c[2])}"
        }
      } else if (c[1] != 1) {
        months[c[1] - 1]
      } else {
        c[0].toString()
      }
    }

### Histogram bins (d3-array's bin)

The thresholds are the x scale's ticks, less any at or below the domain's
start or above its end; a value v in the domain goes in bin
`bisectRight(thresholds, v)`, so bin i holds thresholds[i-1] <= v <
thresholds[i]. The last threshold is usually the domain's end, so the last
bin is [end, end]: one pixel wide, holding the values equal to the end. The
hook drew it; so does this.

The program counts a bin as the difference of two positions in the sorted
values: how many are below its upper threshold, less how many are below
its lower one. That is this, a few dozen times, rather than a bisection
per value.

    export let pl_bisect_left(xs: List<Float64>, v: Float64): Int {
      pl_bisect_loop(xs, v, 0, xs.length)
    }

    let pl_bisect_loop(xs: List<Float64>, v: Float64, lo: Int, hi: Int): Int {
      if (lo >= hi) {
        lo
      } else {
        let mid = pl_div(lo + hi, 2);
        if (xs[mid] < v) { pl_bisect_loop(xs, v, mid + 1, hi) } else { pl_bisect_loop(xs, v, lo, mid) }
      }
    }

## Colour, size and density

`d3.interpolateRgb("#dbe4f7", "#16265c")` at t, each channel rounded as
d3-color writes it, as `#rrggbb` (the canvas takes either, and a draw op
cannot have spaces in it).

    export let pl_ramp(t: Float64): String {
      "#${pl_hex2(pl_channel(219.0, 22.0, t))}${pl_hex2(pl_channel(228.0, 38.0, t))}${pl_hex2(pl_channel(247.0, 92.0, t))}"
    }

    let pl_channel(a: Float64, b: Float64, t: Float64): Int {
      let v = pl_round(a + t * (b - a)).toInt32Unsafe();
      if (v < 0) { 0 } else if (v > 255) { 255 } else { v }
    }

    let pl_hex2(n: Int): String {
      let digits = "0123456789abcdef";
      "${pl_hex1(digits, pl_div(n, 16))}${pl_hex1(digits, pl_mod(n, 16))}"
    }

    let pl_hex1(digits: String, i: Int): String {
      String.fromCodePoint(if (i < 10) { 48 + i } else { 87 + i }) orelse panic()
    }

`scaleSequential(...).domain([lo, hi])`: where v falls, unclamped; the
middle when lo and hi are the same.

    export let pl_seq_t(v: Float64, lo: Float64, hi: Float64): Float64 {
      if (hi == lo) { 0.5 } else { pl_q(v - lo, hi - lo) }
    }

How big and how opaque a point is, by how many are drawn.

    export let pl_base_r(n: Int): Float64 {
      if (n > 5000) { 2.0 } else if (n > 1000) { 2.6 } else { 3.6 }
    }

    export let pl_alpha(n: Int): Float64 {
      if (n > 5000) { 0.55 } else if (n > 1000) { 0.75 } else { 0.9 }
    }

The largest a sized point gets.

    export let pl_max_r(n: Int): Float64 {
      let r = pl_base_r(n) * 2.6;
      if (r > 6.0) { r } else { 6.0 }
    }

The chart's height for its width, and how many ticks each axis asks for.

    export let pl_height(width: Int): Int {
      let h = pl_round(width.toFloat64() * 0.52).toInt32Unsafe();
      if (h > 500) { 500 } else if (h < 300) { 300 } else { h }
    }

    export let pl_x_count(width: Int): Int {
      let n = pl_div(width, 90);
      if (n > 10) { 10 } else { n }
    }

    export let pl_hist_count(width: Int): Int {
      let n = pl_div(width, 24);
      if (n > 40) { 40 } else if (n < 12) { 12 } else { n }
    }

## Numbers as the page wrote them

### JavaScript's

`Number.prototype.toString` writes a whole number without a point, where
Temper's `Float64.toString` writes "5.0"; otherwise they agree (both the
shortest digits that read back), for the magnitudes charted here.

    export let pl_js_num(v: Float64): String {
      if (v.floor() == v && v < 1.0e15 && v > -1.0e15) {
        pl_int_string(v)
      } else {
        v.toString()
      }
    }

d3 and the hook wrote numbers with `toFixed`, which rounds the double's exact value,
not the decimal it prints as: `(0.35).toFixed(1)` is "0.3", because 0.35 is
0.34999999999999997779... So the product x * 10^f is taken exactly, as a
rounded product and its error (Dekker's two-product: Veltkamp's split, all
in plain doubles), and the tie is settled by the error's sign. f is 0 to 3.

    export let pl_to_fixed(x: Float64, f: Int): String {
      let neg = x < 0.0;
      let a = if (neg) { 0.0 - x } else { x };
      let s = pl_pow10(f);
      let p = a * s;
      let e = pl_two_prod_err(a, s, p);
      let fl = p.floor();
      let n0 = if (fl == p && e < 0.0) { fl - 1.0 } else { fl };
      let frac = p - n0;
      let up = if (frac > 0.5) { true } else if (frac < 0.5) { false } else { e >= 0.0 };
      let n = if (up) { n0 + 1.0 } else { n0 };
      let digits = pl_int_string(n);
      let body = if (f == 0) { digits } else { pl_point(pl_zeros(digits, f + 1), f) };
      if (neg) { "-${body}" } else { body }
    }

    let pl_two_prod_err(a: Float64, b: Float64, p: Float64): Float64 {
      let ca = 134217729.0 * a;
      let ah = ca - (ca - a);
      let al = a - ah;
      let cb = 134217729.0 * b;
      let bh = cb - (cb - b);
      let bl = b - bh;
      ((ah * bh - p) + ah * bl + al * bh) + al * bl
    }

A whole double as digits. Integers past 2^31 are Int64.

    export let pl_int_string(n: Float64): String {
      n.toInt64Unsafe().toString()
    }

    let pl_zeros(s: String, width: Int): String {
      if (pl_len(s) >= width) { s } else { pl_zeros("0${s}", width) }
    }

    let pl_len(s: String): Int {
      pl_len_from(s, String.begin, 0)
    }

    let pl_len_from(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) { n } else { pl_len_from(s, s.next(i), n + 1) }
    }

"12345" with 2 places is "123.45".

    let pl_point(s: String, f: Int): String {
      let cut = pl_nth_index(s, String.begin, pl_len(s) - f);
      "${s.slice(String.begin, cut)}.${s.slice(cut, s.end)}"
    }

    let pl_nth_index(s: String, i: StringIndex, n: Int): StringIndex {
      if (n <= 0 || i >= s.end) { i } else { pl_nth_index(s, s.next(i), n - 1) }
    }

The hook's number for a tooltip: `+(+v).toFixed(3) + ""`.

    export let pl_num3(v: Float64): String {
      let fixed = pl_to_fixed(v, 3);
      pl_js_num(fixed.toFloat64() orelse panic())
    }

The hook's `fmtSec`: `Math.round`, then minutes by `Math.floor` and
seconds by `%`, which keeps the sign -- so -50 is "-1:-50", as it was.

    export let pl_js_sec(v: Float64): String {
      let s = pl_round(v);
      let m = pl_q(s, 60.0).floor();
      let r = s - (if (s < 0.0) { pl_q(s, 60.0).ceil() } else { m }) * 60.0;
      let rs = pl_int_string(r);
      "${pl_int_string(m)}:${if (pl_len(rs) < 2) { "0${rs}" } else { rs }}"
    }

A σ value in a tooltip or legend, and on an axis (where the tick is
written as it is, `${v}`).

    export let pl_js_sigma(v: Float64): String {
      "${if (v > 0.0) { "+" } else { "" }}${pl_to_fixed(v, 1)}σ"
    }

    export let pl_sigma_tick(v: Float64): String {
      "${if (v > 0.0) { "+" } else { "" }}${pl_js_num(v)}σ"
    }

Days, for a tooltip: "4.9y" past a year (`(v / 365).toFixed(1)`), else
"123d"; on an axis, whole years (`Math.round(v / 365)`).

    export let pl_js_days(v: Float64): String {
      if (v >= 365.0) { "${pl_to_fixed(pl_q(v, 365.0), 1)}y" } else { "${pl_js_num(v)}d" }
    }

    export let pl_days_tick(v: Float64): String {
      if (v >= 365.0) { "${pl_int_string(pl_round(pl_q(v, 365.0)))}y" } else { "${pl_js_num(v)}d" }
    }

### d3-format

`",.Nf"`: fixed, thousands grouped, and a minus sign (U+2212) unless the
number rounds to zero. The precision a linear axis uses is
`precisionFixed(tickStep(domain, 10))`: the step's decimal places.

    export let pl_precision_fixed(step: Float64): Int {
      let e = pl_exponent(if (step < 0.0) { 0.0 - step } else { step });
      if (e < 0) { 0 - e } else { 0 }
    }

    export let pl_d3_fixed(x: Float64, p: Int): String {
      let neg = x < 0.0;
      let body = pl_to_fixed(if (neg) { 0.0 - x } else { x }, p);
      let grouped = pl_group(body);
      if (neg && (body.toFloat64() orelse panic()) != 0.0) { "−${grouped}" } else { grouped }
    }

    let pl_group(s: String): String {
      let dot = pl_dot_index(s, String.begin);
      let whole = s.slice(String.begin, dot);
      "${pl_group_int(whole, pl_len(whole))}${s.slice(dot, s.end)}"
    }

    let pl_dot_index(s: String, i: StringIndex): StringIndex {
      if (i >= s.end || s[i] == 46) { i } else { pl_dot_index(s, s.next(i)) }
    }

    let pl_group_int(s: String, n: Int): String {
      if (n <= 3) {
        s
      } else {
        let cut = pl_nth_index(s, String.begin, n - 3);
        "${pl_group_int(s.slice(String.begin, cut), n - 3)},${s.slice(cut, s.end)}"
      }
    }

`"~s"` for a positive number: six significant digits under an SI prefix
(k, M, m, µ ...), trailing zeros trimmed. Only a log axis uses it, on
ticks like 20, 300 or 5000.

    export let pl_d3_si(x: Float64): String {
      if (x == 0.0) {
        "0"
      } else {
        let e0 = pl_exponent(x);
        let m0 = pl_round(pl_q(x, pl_pow10(e0 - 5)));
        let m = if (m0 >= 1000000.0) { pl_round(pl_q(m0, 10.0)) } else { m0 };
        let e = if (m0 >= 1000000.0) { e0 + 1 } else { e0 };
        let k0 = pl_div(e, 3);
        let k = if (k0 > 8) { 8 } else if (k0 < -8) { -8 } else { k0 };
        let coefficient = pl_int_string(m);
        let i = e - k * 3 + 1;
        let prefixes = ["y", "z", "a", "f", "p", "n", "µ", "m", "", "k", "M", "G", "T", "P", "E", "Z", "Y"];
        let body = if (i >= 6) {
          pl_pad_right(coefficient, i)
        } else if (i > 0) {
          pl_trim(pl_point(coefficient, 6 - i))
        } else {
          pl_trim("0.${pl_pad_right("", 0 - i)}${coefficient}")
        };
        "${body}${prefixes[k + 8]}"
      }
    }

    let pl_pad_right(s: String, width: Int): String {
      if (pl_len(s) >= width) { s } else { pl_pad_right("${s}0", width) }
    }

d3's formatTrim: drop the zeros after the point, and the point.

    let pl_trim(s: String): String {
      if (!pl_has_dot(s, String.begin)) {
        s
      } else {
        pl_trim_end(s)
      }
    }

    let pl_has_dot(s: String, i: StringIndex): Boolean {
      if (i >= s.end) { false } else if (s[i] == 46) { true } else { pl_has_dot(s, s.next(i)) }
    }

    let pl_trim_end(s: String): String {
      let last = s.prev(s.end);
      if (s[last] == 48) {
        pl_trim_end(s.slice(String.begin, last))
      } else if (s[last] == 46) {
        s.slice(String.begin, last)
      } else {
        s
      }
    }

### Elixir's (the inspector)

`Blog.PhishLab.fmt_sec/1`: `round/1`, then `div` and `rem`.

    export let pl_ex_sec(v: Float64): String {
      let s = v.round().toInt32Unsafe();
      let m = (s / 60) orelse panic();
      let r = s - m * 60;
      "${m.toString()}:${if (r < 10 && r >= 0) { "0${r.toString()}" } else { r.toString() }}"
    }

`fmt_days/1`: `"#{Float.round(d / 365, 1)}y"` past a year. d / 365 is never
a tie at one place (365 = 5 * 73), so this is exact in integers:
tenths = round(10d / 365). The hook's `(v / 365).toFixed(1)` agrees.

    export let pl_ex_days(d: Int): String {
      if (d >= 365) {
        let tenths = pl_div(d * 20 + 365, 730);
        "${pl_div(tenths, 10).toString()}.${pl_mod(tenths, 10).toString()}y"
      } else {
        "${d.toString()}d"
      }
    }

A float as Elixir's `to_string/1` writes it: the shortest digits that read
back, as JavaScript's, but a whole number keeps its ".0".

    export let pl_ex_float(v: Float64): String {
      let s = v.toString();
      if (pl_has_dot(s, String.begin) || pl_has_char(s, String.begin, 101)) { s } else { "${s}.0" }
    }

    let pl_has_char(s: String, i: StringIndex, c: Int): Boolean {
      if (i >= s.end) { false } else if (s[i] == c) { true } else { pl_has_char(s, s.next(i), c) }
    }

A PJJ score in the inspector: `:erlang.float_to_binary(score / 1,
decimals: 2)`. That is not `toFixed`: Erlang's short path takes the
fraction times 100 in doubles, adds a half and truncates, so 0.345 (really
0.34499999999999997...) is "0.35", where `toFixed(2)` says "0.34", and
0.285 is "0.28" because 0.285 * 100 is 28.499999999999996. Checked against
Erlang on every score in the data.

    export let pl_score(v: Float64): String {
      let whole = v.floor();
      let hundredths0 = ((v - whole) * 100.0 + 0.5).floor();
      let carry = hundredths0 >= 100.0;
      let hundredths = if (carry) { hundredths0 - 100.0 } else { hundredths0 };
      let w = if (carry) { whole + 1.0 } else { whole };
      "${pl_int_string(w)}.${pl_zeros(pl_int_string(hundredths), 2)}"
    }

Its bar's width, `round(score * 100)`: half away from zero.

    export let pl_score_width(v: Float64): Int {
      (v * 100.0).round().toInt32Unsafe()
    }

## What the page offers

`Blog.PhishLab`'s metric tables, as `[key, label, format]`. The fifteen
PJJ styles are appended to shows and songs by the program
(`pl_style_metrics`).

    export let pl_styles: List<String> = [
      "Ambient", "Bliss", "CowFunk", "DanceGroove", "Dark-Evil", "Hose", "LoveAndLight",
      "MachineGunTrey", "OutOfTheBlue", "Psychedelic", "QuickHits", "Space",
      "StopStart", "TensionAndRelease", "Weird",
    ];

    export let pl_base_metrics(ds: String): List<List<String>> {
      if (ds == "shows") {
        [
          ["d", "Show date", "date"],
          ["dur", "Show length", "sec"],
          ["nsongs", "Songs played", "num"],
          ["nsets", "Sets", "num"],
          ["avg_song", "Avg song length", "sec"],
          ["max_song", "Longest song", "sec"],
          ["rarity", "Setlist rarity index", "num"],
          ["rating", "Fan rating (relisten)", "num"],
          ["nrat", "# of ratings", "num"],
          ["rating_z", "Rating vs year", "sigma"],
          ["jam_z", "Jamminess vs era", "sigma"],
          ["uniq", "Anomaly score", "num"],
          ["jc_ct", "Jamchart entries", "num"],
          ["likes", "Track likes (total)", "num"],
          ["njams", "PJJ jams", "num"],
        ]
      } else if (ds == "songs") {
        [
          ["plays", "Times played", "num"],
          ["first", "First played", "date"],
          ["last", "Last played", "date"],
          ["avg", "Avg duration", "sec"],
          ["med", "Median duration", "sec"],
          ["max", "Longest version", "sec"],
          ["sd", "Duration std dev", "sec"],
          ["cv", "Unpredictability (CV)", "num"],
          ["maxgap", "Longest shelf gap", "days"],
          ["jc_ct", "Jamchart entries", "num"],
          ["jc_rate", "Jamchart rate", "num"],
          ["likes_avg", "Avg likes", "num"],
          ["njams", "PJJ jams", "num"],
        ]
      } else {
        [
          ["d", "Show date", "date"],
          ["dur", "Duration", "sec"],
          ["z", "Length vs song avg", "sigma"],
          ["pct", "× song average", "num"],
          ["gap", "Days since last played", "days"],
          ["pos", "Setlist position", "num"],
          ["likes", "Likes", "num"],
        ]
      }
    }

    export let pl_style_metrics(ds: String): List<List<String>> {
      if (ds == "perfs") {
        []
      } else {
        let suffix = if (ds == "shows") { "(show max)" } else { "(song avg)" };
        pl_styles.map { (s: String): List<String> => ["style:${s}", "${s} ${suffix}", "score"] }
      }
    }

    export let pl_datasets: List<List<String>> = [["shows", "Shows"], ["songs", "Songs"], ["perfs", "Performances"]];

    export let pl_noun(ds: String): String {
      if (ds == "shows") { "shows" } else if (ds == "songs") { "songs" } else { "performances" }
    }

`reset_axes/1`: `[x, y, color, size]` for a dataset just picked.

    export let pl_reset_axes(ds: String): List<String> {
      if (ds == "shows") {
        ["d", "avg_song", "era", "none"]
      } else if (ds == "songs") {
        ["plays", "avg", "cv", "none"]
      } else {
        ["d", "z", "era", "none"]
      }
    }

The five preset buttons, `[name, label]`, and what each sets:
`[ds, x, y, color, size]`.

    export let pl_presets: List<List<String>> = [
      ["anomaly-scan", "Anomaly Scan"],
      ["jam-era", "The Jamming Eras"],
      ["crowd-v-couch", "Long ≠ Loved?"],
      ["song-risk", "Song Risk Profiles"],
      ["type2-map", "Type II Map"],
    ];

    export let pl_preset(name: String): List<String> {
      if (name == "anomaly-scan") {
        ["perfs", "d", "z", "era", "none"]
      } else if (name == "jam-era") {
        ["shows", "d", "avg_song", "era", "njams"]
      } else if (name == "crowd-v-couch") {
        ["shows", "jam_z", "rating_z", "era", "none"]
      } else if (name == "song-risk") {
        ["songs", "avg", "cv", "plays", "plays"]
      } else if (name == "type2-map") {
        ["shows", "style:Psychedelic", "style:Bliss", "rating", "njams"]
      } else {
        []
      }
    }

The leaderboards in the order the select lists them, and the chart each
one jumps to: `[ds, x, y]`.

    export let pl_board_order: List<String> = [
      "perfs_outliers", "shows_jammiest", "shows_rarest", "songs_bustouts", "songs_variable",
      "shows_overachievers", "shows_most_unique", "songs_jam_vehicles", "perfs_longest",
      "shows_longest", "style_definers",
    ];

    export let pl_board_preset(lb: String): List<String> {
      if (lb == "shows_jammiest") {
        ["shows", "d", "jam_z"]
      } else if (lb == "shows_rarest") {
        ["shows", "d", "rarity"]
      } else if (lb == "shows_overachievers") {
        ["shows", "d", "rating_z"]
      } else if (lb == "shows_longest") {
        ["shows", "d", "dur"]
      } else if (lb == "shows_most_unique") {
        ["shows", "d", "uniq"]
      } else if (lb == "songs_variable") {
        ["songs", "avg", "cv"]
      } else if (lb == "songs_bustouts") {
        ["songs", "maxgap", "plays"]
      } else if (lb == "songs_jam_vehicles") {
        ["songs", "plays", "avg"]
      } else if (lb == "perfs_outliers") {
        ["perfs", "d", "z"]
      } else if (lb == "perfs_longest") {
        ["perfs", "d", "dur"]
      } else if (lb == "style_definers") {
        ["songs", "njams", "avg"]
      } else {
        ["shows", "d", "rating"]
      }
    }
