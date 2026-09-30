# Temper Art

The generative art engine behind `/art` (`static/art/art.blimp`). It was
already Temper: `~/code/temper-art/engine/src/engine.temper`, compiled to
JavaScript as `assets/vendor/temper-engine.js`, which Phoenix's `TemperArt`
hook ran in the browser. This is the same engine, rewritten so that the
Blimp backend can run it, and drawing to SVG instead of handing JSON to a
canvas renderer. Same seed, same generator, same size: same shapes, in the
same order, with the same colors.

What had to change is how it is written, not what it computes. The original
has an `Rng` class with a mutable field, a `Shape` interface with four
classes, and a `ListBuilder` it fills. On the Blimp backend a class is an
actor and a `ListBuilder` is an actor, and actors are never collected: a
flow picture is about 14,000 shapes, so every click would leave 14,000
actors behind. Here there are only functions of numbers and strings.

## The random numbers

The original's generator is splitmix32: the state goes up by `0x9E3779B9`
on every call and the answer is a hash of the new state. So the n-th number
a seed gives is a function of the seed and `n` alone, with no state to
carry: the state after `n + 1` calls is `start + (n + 1) * 0x9E3779B9`, and
Temper's `Int` wraps at 32 bits exactly as the repeated `+=` did.

Every function below takes the start state `r` and a counter `c`, the
number of draws made so far, and says how many it used by what it passes on.

    let art_golden = -1640531527;   // 0x9E3779B9

    export let art_start(seed: Int): Int {
      if (seed == 0) { -559038737 } else { seed }   // 0xDEADBEEF for 0, as mkRng did
    }

    export let art_raw(r: Int, c: Int): Int {
      let z0 = r + (c + 1) * art_golden;
      let z1 = (z0 ^ (z0 >>> 16)) * -2048144789;   // 0x85EBCA6B
      let z2 = (z1 ^ (z1 >>> 13)) * -1028477387;   // 0xC2B2AE35
      z2 ^ (z2 >>> 16)
    }

`unit` was `(next() & 0x7fffffff) / 2147483648.0`. Multiplying by 2^-31
gives the same float (a power of two is exact), and cannot bubble.

    export let art_unit(r: Int, c: Int): Float64 {
      (art_raw(r, c) & 0x7fffffff).toFloat64() * 0.0000000004656612873077392578125
    }

    let art_between(r: Int, c: Int, lo: Float64, hi: Float64): Float64 {
      lo + (hi - lo) * art_unit(r, c)
    }

    export let art_int_between(r: Int, c: Int, lo: Int, hi: Int): Int {
      lo + (art_unit(r, c) * (hi - lo).toFloat64()).floor().toInt32Unsafe()
    }

    let art_chance(r: Int, c: Int, p: Float64): Boolean {
      art_unit(r, c) < p
    }

## Palettes

Index 0 is the background, the rest are inks. The original built `Rgb`
objects and printed them with `hex2`; these are what that printed.

    let art_palettes: List<List<String>> = [
      ["#f4f0e1", "#d62828", "#003049", "#f7b731", "#141414"],   // Bauhaus primary
      ["#f5f5f0", "#ff48b0", "#00a99d", "#ffd100", "#28283c"],   // Riso pop
      ["#1c182e", "#ff6e5a", "#ffc46e", "#78c8dc", "#f5ebdc"],   // Dusk
      ["#eef0e6", "#22573c", "#7aa05a", "#d69f40", "#283228"],   // Forest
      ["#f0f0f3", "#232937", "#636e82", "#aab2c2", "#d64541"],   // Mono slate + alarm
    ];

    let art_ink(r: Int, c: Int, pal: List<String>): String {
      pal[art_int_between(r, c, 1, pal.length)]
    }

## Writing SVG

The canvas renderer took float coordinates. SVG would too, but printing a
float is a long walk in Blimp (temper-core has to make Blimp's `to_string`
agree with JavaScript's), and a flow picture has about 60,000 of them. So
the picture is drawn in tenths of a pixel, as integers: the `viewBox` is
ten times the size, and nothing a tenth of a pixel wide can be seen.

    let art_n(v: Float64): String {
      (v * 10.0).round().toInt32Unsafe().toString()
    }

An alpha, to three places.

    export let art_alpha(a: Float64): String {
      let k = (a * 1000.0).round().toInt32Unsafe();
      if (k >= 1000) {
        "1"
      } else if (k < 10) {
        "0.00${k.toString()}"
      } else if (k < 100) {
        "0.0${k.toString()}"
      } else {
        "0.${k.toString()}"
      }
    }

The four shapes. The canvas renderer set `globalAlpha` around each, which
for one filled or stroked shape is its `fill-opacity` or `stroke-opacity`.
Lines had round caps; the `<svg>` sets `stroke-linecap` once for all of
them. The original `Rect` had a rotation, which no generator ever set, so
it is not here.

    let art_rect(x: Float64, y: Float64, w: Float64, h: Float64, fill: String, a: Float64): String {
      "<rect x=\"${art_n(x)}\" y=\"${art_n(y)}\" width=\"${art_n(w)}\" height=\"${art_n(h)}\" fill=\"${fill}\" fill-opacity=\"${art_alpha(a)}\"/>"
    }

    let art_circle(cx: Float64, cy: Float64, rad: Float64, fill: String, a: Float64): String {
      "<circle cx=\"${art_n(cx)}\" cy=\"${art_n(cy)}\" r=\"${art_n(rad)}\" fill=\"${fill}\" fill-opacity=\"${art_alpha(a)}\"/>"
    }

    let art_tri(x1: Float64, y1: Float64, x2: Float64, y2: Float64, x3: Float64, y3: Float64, fill: String, a: Float64): String {
      "<polygon points=\"${art_n(x1)},${art_n(y1)} ${art_n(x2)},${art_n(y2)} ${art_n(x3)},${art_n(y3)}\" fill=\"${fill}\" fill-opacity=\"${art_alpha(a)}\"/>"
    }

    let art_line(x1: Float64, y1: Float64, x2: Float64, y2: Float64, stroke: String, width: Float64, a: Float64): String {
      "<line x1=\"${art_n(x1)}\" y1=\"${art_n(y1)}\" x2=\"${art_n(x2)}\" y2=\"${art_n(y2)}\" stroke=\"${stroke}\" stroke-width=\"${art_n(width)}\" stroke-opacity=\"${art_alpha(a)}\"/>"
    }

## Bauhaus

A grid of 4-7 by 4-7 cells, about a third left empty; each of the rest a
square, a circle, a triangle or a thick diagonal. Then two to four accent
circles anywhere.

How many draws a cell uses depends on what it drew, so the cells are a
recursion that passes the counter on, and the accents come when the cells
run out. Cell `i` is row `i / cols`, column `i % cols`: the original's
loops ran rows outside and columns inside.

    let art_bauhaus_cells(
      r: Int, c: Int, pal: List<String>, w: Int, h: Int,
      cols: Int, rows: Int, cw: Float64, ch: Float64, i: Int,
    ): String {
      if (i >= cols * rows) { return art_bauhaus_accents(r, c, pal, w, h); }
      if (art_chance(r, c, 0.32)) {
        return art_bauhaus_cells(r, c + 1, pal, w, h, cols, rows, cw, ch, i + 1);   // leave breathing room
      }
      let gx = (i % cols) orelse 0;
      let gy = (i / cols) orelse 0;
      let x = gx.toFloat64() * cw;
      let y = gy.toFloat64() * ch;
      let kind = art_int_between(r, c + 1, 0, 4);
      let col = art_ink(r, c + 2, pal);
      let a = art_between(r, c + 3, 0.78, 1.0);
      if (kind == 1) {
        let rad = cw.min(ch) * 0.5 * art_between(r, c + 4, 0.55, 0.95);
        let shape = art_circle(x + cw * 0.5, y + ch * 0.5, rad, col, a);
        return "${shape}${art_bauhaus_cells(r, c + 5, pal, w, h, cols, rows, cw, ch, i + 1)}";
      }
      let shape = if (kind == 0) {
        art_rect(x, y, cw, ch, col, a)
      } else if (kind == 2) {
        art_tri(x, y + ch, x + cw, y + ch, x + cw * 0.5, y, col, a)
      } else {
        art_line(x, y, x + cw, y + ch, col, ch * 0.18, a)
      };
      "${shape}${art_bauhaus_cells(r, c + 4, pal, w, h, cols, rows, cw, ch, i + 1)}"
    }

Each accent is five draws: its radius, then (in the order the original's
`new Circle(...)` evaluated its arguments) x, y, ink and alpha.

    let art_bauhaus_accents(r: Int, c: Int, pal: List<String>, w: Int, h: Int): String {
      let n = art_int_between(r, c, 2, 5);
      art_bauhaus_accent(r, c + 1, pal, w.toFloat64(), h.toFloat64(), n)
    }

    let art_bauhaus_accent(r: Int, c: Int, pal: List<String>, wf: Float64, hf: Float64, left: Int): String {
      if (left <= 0) { return ""; }
      let rad = art_between(r, c, wf * 0.04, wf * 0.13);
      let shape = art_circle(
        art_between(r, c + 1, 0.0, wf), art_between(r, c + 2, 0.0, hf),
        rad, art_ink(r, c + 3, pal), art_between(r, c + 4, 0.5, 0.9));
      "${shape}${art_bauhaus_accent(r, c + 5, pal, wf, hf, left - 1)}"
    }

    let art_bauhaus(r: Int, c: Int, pal: List<String>, w: Int, h: Int): String {
      let cols = art_int_between(r, c, 4, 8);
      let rows = art_int_between(r, c + 1, 4, 8);
      let cw = (w.toFloat64() / cols.toFloat64()) orelse 100.0;
      let ch = (h.toFloat64() / rows.toFloat64()) orelse 100.0;
      art_bauhaus_cells(r, c + 2, pal, w, h, cols, rows, cw, ch, 0)
    }

## Flow

150-279 particles pushed through a sin/cos vector field, each leaving a
trail of short, faint line segments; a particle stops when it leaves the
picture. Every draw a particle makes is made before its trail (where it
starts, its ink, alpha and width), so particle `p` always uses draws
`c + 5p` to `c + 5p + 4` and the particles need no counter passed between
them.

    export let art_flow_ang(x: Float64, y: Float64, scale: Float64, swirl: Float64): Float64 {
      ((x * scale).sin() + (y * scale).cos()) * swirl * Float64.pi
    }

    let art_flow_trail(
      x: Float64, y: Float64, k: Int, steps: Int, step: Float64,
      scale: Float64, swirl: Float64, wf: Float64, hf: Float64,
    ): String {
      if (k >= steps) { return ""; }
      let ang = art_flow_ang(x, y, scale, swirl);
      let nx = x + ang.cos() * step;
      let ny = y + ang.sin() * step;
      let seg = "<line x1=\"${art_n(x)}\" y1=\"${art_n(y)}\" x2=\"${art_n(nx)}\" y2=\"${art_n(ny)}\"/>";
      if (nx < 0.0 || nx > wf || ny < 0.0 || ny > hf) { return seg; }
      "${seg}${art_flow_trail(nx, ny, k + 1, steps, step, scale, swirl, wf, hf)}"
    }

One particle is a `<g>` carrying its ink, width and alpha, so each segment
is only its ends. `stroke-opacity` is inherited by each line and applied to
each line, as `globalAlpha` was, so where two segments of a trail overlap
at a round cap it is darker, as on the canvas; `opacity` on the group would
have flattened the trail first.

    let art_flow_particle(
      r: Int, c: Int, pal: List<String>, steps: Int, step: Float64,
      scale: Float64, swirl: Float64, wf: Float64, hf: Float64,
    ): String {
      let x = art_between(r, c, 0.0, wf);
      let y = art_between(r, c + 1, 0.0, hf);
      let col = art_ink(r, c + 2, pal);
      let a = art_between(r, c + 3, 0.16, 0.5);
      let lw = art_between(r, c + 4, 1.0, 3.2);
      let trail = art_flow_trail(x, y, 0, steps, step, scale, swirl, wf, hf);
      "<g stroke=\"${col}\" stroke-width=\"${art_n(lw)}\" stroke-opacity=\"${art_alpha(a)}\">${trail}</g>"
    }

Particles `lo` to `hi - 1`, halving: adding them one at a time to the end of
one string would copy the whole picture so far once per particle.

    let art_flow_span(
      r: Int, c: Int, pal: List<String>, steps: Int, step: Float64,
      scale: Float64, swirl: Float64, wf: Float64, hf: Float64, lo: Int, hi: Int,
    ): String {
      if (hi - lo <= 0) { return ""; }
      if (hi - lo == 1) { return art_flow_particle(r, c + 5 * lo, pal, steps, step, scale, swirl, wf, hf); }
      let mid = lo + (((hi - lo) / 2) orelse 1);
      "${art_flow_span(r, c, pal, steps, step, scale, swirl, wf, hf, lo, mid)}${art_flow_span(r, c, pal, steps, step, scale, swirl, wf, hf, mid, hi)}"
    }

    let art_flow(r: Int, c: Int, pal: List<String>, w: Int, h: Int): String {
      let wf = w.toFloat64();
      let hf = h.toFloat64();
      let particles = art_int_between(r, c, 150, 280);
      let steps = art_int_between(r, c + 1, 26, 50);
      let step = wf.min(hf) * 0.012;
      let scale = art_between(r, c + 2, 0.004, 0.011);
      let swirl = art_between(r, c + 3, 1.5, 3.5);
      art_flow_span(r, c + 4, pal, steps, step, scale, swirl, wf, hf, 0, particles)
    }

## Subdivision

Mondrian: split the picture in two, across its longer side, at 32-68%, and
split the halves, seven levels down; the first two levels always split, the
rest 88% of the time while a side is over 40px. A leaf is filled (15% of
the time with the background) and given a heavy black border.

The right half's draws start where the left half's ended, and that depends
on everything the left half did. With no object to carry the generator,
`art_sub_used` answers where a subtree's draws end, and the drawing asks it
for each left half. That walks each subtree once more per level above it:
at most seven times, on at most 128 leaves.

The counter after the split decisions of a node that splits, or `-1` if it
does not: whether it splits, which way (a draw only for a square), where.

    let art_sub_can(w: Float64, h: Float64, depth: Int): Boolean {
      depth > 0 && (w > 40.0 || h > 40.0)
    }

    let art_sub_splits(r: Int, c: Int, w: Float64, h: Float64, depth: Int): Int {
      if (!art_sub_can(w, h, depth)) { return -1; }
      if (depth > 5) { return c; }
      if (art_chance(r, c, 0.88)) { c + 1 } else { -1 }
    }

`1` for a vertical split (side by side), `0` for horizontal; the draw it
may use is at `c`.

    let art_sub_vert(r: Int, c: Int, w: Float64, h: Float64): Boolean {
      if (w > h) { true } else if (h > w) { false } else { art_chance(r, c, 0.5) }
    }

    let art_sub_after_vert(c: Int, w: Float64, h: Float64): Int {
      if (w > h || h > w) { c } else { c + 1 }
    }

    let art_sub_leaf_used(r: Int, c: Int): Int {
      if (art_chance(r, c, 0.15)) { c + 1 } else { c + 2 }
    }

    let art_sub_used(r: Int, c: Int, w: Float64, h: Float64, depth: Int): Int {
      let s = art_sub_splits(r, c, w, h, depth);
      if (s < 0) {
        // not splitting still used the chance draw, when there was one
        let c1 = if (art_sub_can(w, h, depth) && depth <= 5) { c + 1 } else { c };
        return art_sub_leaf_used(r, c1);
      }
      let vert = art_sub_vert(r, s, w, h);
      let ct = art_sub_after_vert(s, w, h);
      let t = art_between(r, ct, 0.32, 0.68);
      if (vert) {
        let ww = w * t;
        art_sub_used(r, art_sub_used(r, ct + 1, ww, h, depth - 1), w - ww, h, depth - 1)
      } else {
        let hh = h * t;
        art_sub_used(r, art_sub_used(r, ct + 1, w, hh, depth - 1), w, h - hh, depth - 1)
      }
    }

    let art_sub_leaf(r: Int, c: Int, pal: List<String>, x: Float64, y: Float64, w: Float64, h: Float64): String {
      let fill = if (art_chance(r, c, 0.15)) { pal[0] } else { art_ink(r, c + 1, pal) };
      let bc = "#141414";
      "${art_rect(x, y, w, h, fill, 1.0)}${art_line(x, y, x + w, y, bc, 6.0, 1.0)}${art_line(x + w, y, x + w, y + h, bc, 6.0, 1.0)}${art_line(x + w, y + h, x, y + h, bc, 6.0, 1.0)}${art_line(x, y + h, x, y, bc, 6.0, 1.0)}"
    }

    let art_sub(r: Int, c: Int, pal: List<String>, x: Float64, y: Float64, w: Float64, h: Float64, depth: Int): String {
      let s = art_sub_splits(r, c, w, h, depth);
      if (s < 0) {
        let c1 = if (art_sub_can(w, h, depth) && depth <= 5) { c + 1 } else { c };
        return art_sub_leaf(r, c1, pal, x, y, w, h);
      }
      let vert = art_sub_vert(r, s, w, h);
      let ct = art_sub_after_vert(s, w, h);
      let t = art_between(r, ct, 0.32, 0.68);
      if (vert) {
        let ww = w * t;
        let right = art_sub_used(r, ct + 1, ww, h, depth - 1);
        "${art_sub(r, ct + 1, pal, x, y, ww, h, depth - 1)}${art_sub(r, right, pal, x + ww, y, w - ww, h, depth - 1)}"
      } else {
        let hh = h * t;
        let below = art_sub_used(r, ct + 1, w, hh, depth - 1);
        "${art_sub(r, ct + 1, pal, x, y, w, hh, depth - 1)}${art_sub(r, below, pal, x, y + hh, w, h - hh, depth - 1)}"
      }
    }

## The picture

The first draw picks the palette, then the generator draws. An unknown
generator name is Bauhaus, as it was.

    export let art_generators(): List<String> {
      ["bauhaus", "flow", "subdivision"]
    }

    export let art_shapes(seed: Int, generator: String, width: Int, height: Int): String {
      let r = art_start(seed);
      let pal = art_palettes[art_int_between(r, 0, 0, art_palettes.length)];
      if (generator == "flow") {
        art_flow(r, 1, pal, width, height)
      } else if (generator == "subdivision") {
        art_sub(r, 1, pal, 0.0, 0.0, width.toFloat64(), height.toFloat64(), 7)
      } else {
        art_bauhaus(r, 1, pal, width, height)
      }
    }

    export let art_background(seed: Int): String {
      let r = art_start(seed);
      art_palettes[art_int_between(r, 0, 0, art_palettes.length)][0]
    }

The whole picture: an `<svg>` that fills the width it is given and keeps
its shape.

    export let art_svg(seed: Int, generator: String, width: Int, height: Int): String {
      let w10 = (width * 10).toString();
      let h10 = (height * 10).toString();
      "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ${w10} ${h10}\" width=\"100%\" preserveAspectRatio=\"xMidYMid meet\" stroke-linecap=\"round\" style=\"display:block\"><rect width=\"${w10}\" height=\"${h10}\" fill=\"${art_background(seed)}\"/>${art_shapes(seed, generator, width, height)}</svg>"
    }

## The seed in the URL

`ArtLive.parse_int/2`: `/art?seed=...` is a seed when it is a whole number
from 0 up, and otherwise the default. Integer.parse took leading digits
(`12abc` was 12); this takes only a seed that is digits and nothing else,
and no more than fits an `Int`, since `Math.random()` never gave more.

    export let art_seed_of(raw: String, dflt: Int): Int {
      if (raw.isEmpty || !art_all_digits(raw, String.begin, 0)) { return dflt; }
      let n = raw.toInt64() orelse -1i64;
      if (n < 0i64 || n > 2147483647i64) { dflt } else { n.toInt32() orelse dflt }
    }

    let art_all_digits(s: String, i: StringIndex, seen: Int): Boolean {
      if (i >= s.end) {
        seen <= 10
      } else {
        let c = s[i];
        c >= 48 && c <= 57 && art_all_digits(s, s.next(i), seen + 1)
      }
    }
