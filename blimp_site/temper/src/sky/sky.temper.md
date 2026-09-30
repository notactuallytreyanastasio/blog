# Fill The Sky

The per-community arithmetic behind `/sky`, a map of 545,173 Bluesky accounts
in 418 communities. Phoenix drew it with a deck.gl hook
(`assets/js/hooks/sky_map.js`, `SkyMap`) that did all of this in JavaScript on
every change of view mode: sort the communities by size, lay each one out as a
disc on a golden-angle spiral pushed outward until it overlaps nothing, and
colour it by its rank. That layout is a function of the communities alone --
every community's disc is sized by its member count, and every community has
exactly as many points as members -- so it is here.

It does not run in the browser, though. The All view is 1.1 million overlap
tests; compiled to Blimp that is 4.2s natively (Big Scene 0.6s, Niche 1.6s),
and slower again in WebAssembly, on every click of a view button. Nor at the
server's boot, which it would make five times longer. `build.sh` runs it once,
through `static/sky/layout.blimp`, and the page fetches the answer.

What stays in JavaScript is what is done once per *point*: the position of
each of the 545,173 accounts inside its disc, the median of those positions
(where the label goes), the selection ring and the camera.

Every expression is the hook's, in the hook's order. The decisions -- which
step clears every disc -- are the hook's in all 836 placements; the places
are within 1.4e-14 of its, the difference between V8's and Zig's `sin` and
`cos` in the last bit; the colours are its exactly. `test/sky_test.blimp`
holds them to the hook's own output.

## Discs

A community's disc: `Math.sqrt(c.member_count || 1) * 0.08`.

    export let sky_disc_radius(members: Int): Float64 {
      sky_at_least_one(members).toFloat64().sqrt() * 0.08
    }

    let sky_at_least_one(n: Int): Int {
      if (n == 0) { 1 } else { n }
    }

Big Scene is every community of 500 members or more, Niche the rest, All
both.

    export let sky_in_mode(mode: String, members: Int): Boolean {
      if (mode == "big") {
        members >= 500
      } else if (mode == "niche") {
        members < 500
      } else {
        true
      }
    }

## Placing a disc

`placed` is every disc placed so far, flattened to `x, y, r, x, y, r, ...`,
largest first (a list of numbers, not of objects: an object here would be a
class, and a class on the Blimp backend is an actor, never collected). The
answer is `[x, y]` for a disc of radius `r`.

The first disc sits at the origin. Every other one starts on the golden angle
times the number placed, one radius beyond the first disc's, and walks
outward -- 0.3 of its radius and 0.2 radians a step -- until it clears every
disc by 15%, or 500 steps have gone by. After the 500th it stays where the
500th put it, as the hook's `while` left `cx, cy`. (None of the three views
comes near that: the most steps any disc takes is 208.)

    export let sky_place(placed: List<Float64>, r: Float64): List<Float64> {
      if (placed.isEmpty) {
        [0.0, 0.0]
      } else {
        let n = (placed.length / 3) orelse panic();
        sky_seek(placed, r, n.toFloat64() * 2.399963, r + placed[2], 0)
      }
    }

    let sky_seek(placed: List<Float64>, r: Float64, angle: Float64, dist: Float64, tries: Int): List<Float64> {
      let x = angle.cos() * dist;
      let y = angle.sin() * dist;
      if (tries >= 499 || !sky_hits(placed, 0, x, y, r)) {
        [x, y]
      } else {
        sky_seek(placed, r, angle + 0.2, dist + r * 0.3, tries + 1)
      }
    }

Does a disc at `x, y` come within 15% of any placed from index `j` on? The
hook's `(cx - p.x) ** 2` is `Math.pow(d, 2)`, which is `d * d` exactly.

    let sky_hits(placed: List<Float64>, j: Int, x: Float64, y: Float64, r: Float64): Boolean {
      if (j >= placed.length) {
        false
      } else {
        let dx = x - placed[j];
        let dy = y - placed[j + 1];
        if ((dx * dx + dy * dy).sqrt() < (r + placed[j + 2]) * 1.15) {
          true
        } else {
          sky_hits(placed, j + 3, x, y, r)
        }
      }
    }

## Colours

The community of rank `i` (0 the largest) is the hook's
`generateCommunityColors`: a hue 137.508 degrees on from the last, three
lightnesses and two saturations in turn, through its `hslToRgb`. The answer
is `[r, g, b]`, each 0 to 255.

    export let sky_rgb(i: Int): List<Int> throws Bubble {
      let hue = sky_mod360(i.toFloat64() * 137.508) / 360.0;
      let l = 0.45 + ((i % 3) orelse panic()).toFloat64() * 0.1;
      let s = 0.7 + ((i % 2) orelse panic()).toFloat64() * 0.15;
      let q = sky_q(l, s);
      let p = 2.0 * l - q;
      [
        sky_byte(sky_hue(p, q, hue + 1.0 / 3.0)),
        sky_byte(sky_hue(p, q, hue)),
        sky_byte(sky_hue(p, q, hue - 1.0 / 3.0)),
      ]
    }

JavaScript's `%` on numbers is C's `fmod`: exact, with the sign of the
dividend. The hue is never negative.

    let sky_mod360(x: Float64): Float64 {
      (x % 360.0) orelse panic()
    }

    let sky_q(l: Float64, s: Float64): Float64 {
      if (l < 0.5) { l * (1.0 + s) } else { l + s - l * s }
    }

    let sky_hue(p: Float64, q: Float64, t0: Float64): Float64 throws Bubble {
      let t = sky_wrap(t0);
      if (t < 1.0 / 6.0) {
        p + (q - p) * 6.0 * t
      } else if (t < 1.0 / 2.0) {
        q
      } else if (t < 2.0 / 3.0) {
        p + (q - p) * (2.0 / 3.0 - t) * 6.0
      } else {
        p
      }
    }

    let sky_wrap(t: Float64): Float64 {
      if (t < 0.0) { t + 1.0 } else if (t > 1.0) { t - 1.0 } else { t }
    }

`Math.round`, for the non-negative numbers it gets here.

    let sky_byte(v: Float64): Int {
      (v * 255.0 + 0.5).floor().toInt32Unsafe()
    }
