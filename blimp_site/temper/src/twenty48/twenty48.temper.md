# 2048's rules

What a move does to a board, for the game at `/2048`
(`static/twenty48/twenty48.blimp`). The actor, the view and where a new tile
lands (Blimp's `random`) stay in Blimp; everything that is a function of the
board is here.

A board is one `List<Int>`, row after row, 0 for an empty cell. A direction
is a string, `"left"`, `"right"`, `"up"` or `"down"`: Temper has no atoms, so
the Blimp caller passes `to_string(dir)`.

## Counting without a builder

Temper's lists have `map`, `filter`, `slice` and `reduceFrom`, and nothing
that makes a list longer than one it already has except `ListBuilder`, which
on the Blimp backend is an actor, and actors are never collected. A game of
2048 would leave a few behind on every move. So the positions of a board come
from one list literal: the biggest board is 12x12, and `t48_range` hands out
the front of it. A bigger board panics instead of drawing a short one.

    let t48_upto: List<Int> = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
      20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
      40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
      60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
      80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
      100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
      120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
      140, 141, 142, 143,
    ];

`List.slice` on this backend walks the list, so slicing 144 positions down to
12 on every call was most of what a move cost. The lengths a move asks for
are sliced once, when the program loads: 0 to 13 (a line, the tiles in it,
and the sizes below) and 16, 64, 100 and 144 (the boards). Any other length panics.

    let t48_sliced: List<List<Int>> = t48_upto.map { (n): List<Int> =>
      if (n <= 13 || n == 16 || n == 64 || n == 100) { t48_upto.slice(0, n) } else { [] }
    };

    export let t48_range(n: Int): List<Int> {
      if (n == 144) { return t48_upto; }
      if (n < 0 || n > 144) { panic() }
      let r = t48_sliced[n];
      if (r.length != n) { panic() }
      r
    }

    export let t48_blank(size: Int): List<Int> {
      t48_range(size * size).map { (i): Int => 0 }
    }

## One line

`Twenty48.slide_and_merge/2`: the tiles slide to the front, and each tile
merges with the next one if they are equal and it was not itself just merged
into. Which tiles start a merge is a question about runs: in a run of equal
tiles the first, third, fifth... start one, if there is a tile after them in
the run.

    let t48_run_back(z: List<Int>, k: Int): Int {
      if (k > 0 && z[k - 1] == z[k]) { 1 + t48_run_back(z, k - 1) } else { 0 }
    }

    let t48_starts(z: List<Int>, k: Int): Boolean {
      if (k + 1 >= z.length) {
        false
      } else if (z[k] != z[k + 1]) {
        false
      } else {
        t48_run_back(z, k) % 2 == 0
      }
    }

One line's values in sliding order to `[values after the move, [points],
indices in the line that were merges]`. Temper has no tuples, so it is a list
of three lists; `t48_shift` in Blimp is where it becomes a tuple. Whether
each tile starts a merge is asked once, into `starts`: asking it again for
every list built from it made a 12x12 move twice as slow.

A line with no two equal tiles side by side after sliding, which is most
lines on most moves, only slides.

    let t48_any_pair(z: List<Int>, k: Int): Boolean {
      if (k + 1 >= z.length) { false } else if (z[k] == z[k + 1]) { true } else { t48_any_pair(z, k + 1) }
    }

    let t48_pad(z: List<Int>, width: Int): List<List<Int>> {
      let n = z.length;
      [t48_range(width).map { (j): Int => if (j < n) { z[j] } else { 0 } }, [0], []]
    }

    export let t48_slide_line(values: List<Int>): List<List<Int>> {
      let z = values.filter { (v): Boolean => v != 0 };
      if (z.isEmpty) { return [values, [0], []]; }
      if (!t48_any_pair(z, 0)) { return t48_pad(z, values.length); }
      let starts = t48_range(z.length).map { (k): Boolean => t48_starts(z, k) };
      let kept = t48_range(z.length).filter { (k): Boolean => k == 0 || !starts[k - 1] };
      let out = kept.map { (k): Int => if (starts[k]) { z[k] * 2 } else { z[k] } };
      let merges = t48_range(kept.length).filter { (j): Boolean => starts[kept[j]] };
      let points = merges.reduceFrom(0) { (acc: Int, j: Int): Int => acc + out[j] };
      let n = out.length;
      let padded = t48_range(values.length).map { (j): Int => if (j < n) { out[j] } else { 0 } };
      [padded, [points], merges]
    }

## The whole board

Line `k`, position `j` along it, is a cell of the board; which one depends on
the direction. `:left` reads each row from its first cell, `:right` from its
last, `:up` and `:down` each column.

    let t48_cell(size: Int, dir: String, k: Int, j: Int): Int {
      let last = size - 1;
      if (dir == "left") {
        k * size + j
      } else if (dir == "right") {
        k * size + (last - j)
      } else if (dir == "up") {
        j * size + k
      } else if (dir == "down") {
        (last - j) * size + k
      } else {
        panic()
      }
    }

    let t48_div(a: Int, b: Int): Int { (a / b) orelse panic() }

    let t48_mod(a: Int, b: Int): Int { (a % b) orelse panic() }

    let t48_line_of(size: Int, dir: String, p: Int): Int {
      if (dir == "left" || dir == "right") { t48_div(p, size) } else { t48_mod(p, size) }
    }

    let t48_along(size: Int, dir: String, p: Int): Int {
      let last = size - 1;
      if (dir == "left") {
        t48_mod(p, size)
      } else if (dir == "right") {
        last - t48_mod(p, size)
      } else if (dir == "up") {
        t48_div(p, size)
      } else {
        last - t48_div(p, size)
      }
    }

`t48_has` is asked once per cell per move, of lists that are nearly always
empty, so it is a loop, not a `filter` with a closure made for every call.

    export let t48_has(list: List<Int>, x: Int): Boolean { t48_has_from(list, x, 0) }

    let t48_has_from(list: List<Int>, x: Int, i: Int): Boolean {
      if (i >= list.length) { false } else if (list[i] == x) { true } else { t48_has_from(list, x, i + 1) }
    }

Which line and which place along it every cell is, and the other way round,
depends only on the size and the direction, so it is worked out once per
board size when the program loads rather than with a division per cell per
move (a division here is a call wrapped in a `try`, since Temper's can
bubble). For each size, one entry per direction, `"left"` `"right"` `"up"`
`"down"`, each `[line of cell p, place of cell p along it, cell at line
position q]`, with q = k * size + j.

    let t48_geometry(size: Int): List<List<List<Int>>> {
      let cells = t48_range(size * size);
      ["left", "right", "up", "down"].map { (dir): List<List<Int>> =>
        [
          cells.map { (p): Int => t48_line_of(size, dir, p) },
          cells.map { (p): Int => t48_along(size, dir, p) },
          cells.map { (q): Int => t48_cell(size, dir, t48_div(q, size), t48_mod(q, size)) },
        ]
      }
    }

    let t48_geometries: List<List<List<List<Int>>>> = t48_range(13).map { (n): List<List<List<Int>>> =>
      if (n == 4 || n == 8 || n == 10 || n == 12) { t48_geometry(n) } else { [] }
    };

    let t48_dir_index(dir: String): Int {
      if (dir == "left") {
        0
      } else if (dir == "right") {
        1
      } else if (dir == "up") {
        2
      } else if (dir == "down") {
        3
      } else {
        panic()
      }
    }

A move: `[board, [points], merged cell indices]`, the indices in board order.
Sizes other than 4, 8, 10 and 12 panic. Every merge scores, so a move that
scored nothing merged nothing and the search for merged cells is skipped.

    export let t48_move(board: List<Int>, size: Int, dir: String): List<List<Int>> {
      if (size > 12) { panic() }
      let sized = t48_geometries[size];
      if (sized.isEmpty) { panic() }
      let geometry = sized[t48_dir_index(dir)];
      let line_of = geometry[0];
      let along = geometry[1];
      let at = geometry[2];
      let slid = t48_range(size).map { (k): List<List<Int>> =>
        t48_slide_line(t48_range(size).map { (j): Int => board[at[k * size + j]] })
      };
      let cells = t48_range(size * size);
      let next = cells.map { (p): Int => slid[line_of[p]][0][along[p]] };
      let points = slid.reduceFrom(0) { (acc: Int, r: List<List<Int>>): Int => acc + r[1][0] };
      let merged: List<Int> = if (points == 0) {
        []
      } else {
        cells.filter { (p): Boolean => t48_has(slid[line_of[p]][2], along[p]) }
      };
      [next, [points], merged]
    }

## The rest of the rules

A board can move if two neighbours, across or down, are a tile and an empty
cell or two equal tiles. That is the same as asking whether any of the four
moves changes the board, which is what the Blimp did, at a quarter of the
work and without building a board: a tile next to an empty cell slides into
it one way or the other, and if no neighbours are like that then every empty
cell's neighbours are empty, so either the board is empty or it is full with
no pair to merge.

    let t48_pair_moves(a: Int, b: Int): Boolean {
      if (a == 0) { b != 0 } else { b == 0 || a == b }
    }

    export let t48_any_move(board: List<Int>, size: Int): Boolean {
      !t48_range(size * size).filter { (p): Boolean =>
        let across = t48_mod(p, size) + 1 < size && t48_pair_moves(board[p], board[p + 1]);
        across || (p + size < size * size && t48_pair_moves(board[p], board[p + size]))
      }.isEmpty
    }

    export let t48_empties(board: List<Int>): List<Int> {
      t48_range(board.length).filter { (i): Boolean => board[i] == 0 }
    }

    export let t48_set(board: List<Int>, at: Int, value: Int): List<Int> {
      t48_range(board.length).map { (i): Int => if (i == at) { value } else { board[i] } }
    }

    export let t48_max(board: List<Int>): Int {
      board.reduceFrom(0) { (m: Int, v: Int): Int => if (v > m) { v } else { m } }
    }

## What a tile looks like

The classes `twenty48.css` draws.

    export let t48_tile_class(v: Int): String {
      if (v == 0) {
        "tile-empty"
      } else if (t48_is_tile(v)) {
        "tile-${v.toString()}"
      } else {
        "tile-super"
      }
    }

The view asks this of all 144 cells of a big board on every move, so it is a
chain of comparisons rather than a search of a list.

    let t48_is_tile(v: Int): Boolean {
      if (v <= 64) {
        v == 2 || v == 4 || v == 8 || v == 16 || v == 32 || v == 64
      } else {
        v == 128 || v == 256 || v == 512 || v == 1024 || v == 2048
      }
    }

    export let t48_digits(v: Int): String {
      if (v >= 10000) {
        "d5"
      } else if (v >= 1000) {
        "d4"
      } else if (v >= 100) {
        "d3"
      } else if (v >= 10) {
        "d2"
      } else {
        "d1"
      }
    }

    export let t48_active(yes: Boolean): String {
      if (yes) { "mac-btn size-btn active" } else { "mac-btn size-btn" }
    }
