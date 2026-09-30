# Chess-9's rules

The game at `/chess-lv` (`static/chess_lv/chess_lv.blimp`): nine chess boards
in a 3x3 grid that make one 24x24 plane, played against a bot. A port of
`Blog.Chess.*` (setup, move generation, attack, check, legality, the reducer,
draws, scoring, evaluation and the bot's search) as functions over values.
The actor, the view, the order the bot's root moves are searched in and the
random pick among its best moves stay in Blimp.

Coordinates are global: `x` and `y` run 0..23, board `b` is
`(y / 8) * 3 + x / 8`, white starts at the bottom of every board and moves
toward smaller `y`.

## Values instead of structs

Temper classes are actors on the Blimp backend, and actors are never
collected, so there are no structs here. Everything is `Int`s in lists.

A piece is one `Int`: its type (1 pawn, 2 knight, 3 bishop, 4 rook, 5 queen,
6 king), plus 8 if it is black, plus 16 once it has moved. 0 is an empty
square. What a code means comes out of tables rather than arithmetic:
Temper's `/` and `%` can bubble, and each would be a call.

    let ch_tp: List<Int> = [0, 1, 2, 3, 4, 5, 6, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 1, 2, 3, 4, 5, 6, 0];
    let ch_cl: List<Int> = [-1, 0, 0, 0, 0, 0, 0, -1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 0, 0, 0, 0, 0, 0, -1, -1, 1, 1, 1, 1, 1, 1, -1];
    let ch_nm: List<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    let ch_mv16: List<Int> = [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31];

    export let ch_type(p: Int): Int { ch_tp[p] }
    export let ch_color(p: Int): Int { ch_cl[p] }

A game is a `List<List<Int>>` of 29 rows:

- 0..23, the plane, row `y` holding the 24 squares of that row;
- 24, `[to_move, en_passant x, en_passant y, ply, material]`, colour 0
  white, 1 black, -1 for no en-passant square; material is white's minus
  black's in 32nds of a pawn (see the evaluation), kept up to date by each
  move instead of counted over 576 squares for every position the bot
  scores;
- 25, the nine boards' statuses: 0 active, 1 white in check, 2 black in
  check, 3 white has mated, 4 black has mated, 5 stalemate, 6 drawn by the
  fifty-move rule (or the 600-ply cap, which the Elixir calls the same), 7
  drawn for insufficient material. 3 and up are frozen;
- 26, the nine halfmove clocks;
- 27, the credit ledger, 90 counts: board * 10 + colour * 5 + type - 1;
- 28, where the kings are: `(colour * 9 + board) * 2` is x and the next y,
  -1 once a king has been taken. The Elixir looked for the king by scanning
  the board's 64 squares on every check test, which is most of what a test
  costs here; kings never cross boards, so where each one is only changes
  when it moves or is taken.

A move is a `List<Int>` of 14: `[kind, fx, fy, tx, ty, piece, captured,
crossing, promote_to, ax, ay, bx, by, placed]`. Kind 0 normal, 1 double pawn
push, 2 en passant, 3 promotion, 4 castle kingside, 5 castle queenside.
`crossing` is 1 when the move leaves its board (it spends a credit on the
board it enters, for the piece's type). `ax, ay` is the pawn taken en
passant, or the castling rook's square; `bx, by` is where that rook goes.
`placed` is the piece standing on `to` afterwards.

    let ch_move(kind: Int, fx: Int, fy: Int, tx: Int, ty: Int, p: Int, cap: Int, cross: Int, promo: Int, ax: Int, ay: Int, bx: Int, by: Int): List<Int> {
      [kind, fx, fy, tx, ty, p, cap, cross, promo, ax, ay, bx, by, ch_placed(p, promo)]
    }

    let ch_placed(p: Int, promo: Int): Int {
      if (promo > 0) { promo + 8 * ch_cl[p] + 16 } else { ch_mv16[p] }
    }

## Geometry

    let ch_rows: List<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
    let ch_b8: List<Int> = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2];
    let ch_l8: List<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7];
    let ch_ox: List<Int> = [0, 8, 16, 0, 8, 16, 0, 8, 16];
    let ch_oy: List<Int> = [0, 0, 0, 8, 8, 8, 16, 16, 16];
    let ch_bdt: List<List<Int>> = ch_rows.map { (y): List<Int> => ch_rows.map { (x): Int => ch_b8[y] * 3 + ch_b8[x] } };

    export let ch_board_of(x: Int, y: Int): Int { ch_bdt[y][x] }

White moves up (`dy` -1) and promotes on a board's local rank 0, black down
and on 7; pawns double-step from local rank 6 and 1, kings castle from 7
and 0.

    let ch_fwd: List<Int> = [-1, 1];
    let ch_prank: List<Int> = [0, 7];
    let ch_start: List<Int> = [6, 1];
    let ch_home: List<Int> = [7, 0];

The directions, in the Elixir's order. Order matters here: the bot keeps
the first of equally good moves, so the port has to list them the same way.

    let ch_diag: List<List<Int>> = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
    let ch_orth: List<List<Int>> = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    let ch_queen: List<List<Int>> = [[1, 1], [1, -1], [-1, 1], [-1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]];
    let ch_knight_d: List<List<Int>> = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]];
    let ch_king_d: List<List<Int>> = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]];

## Lists without a builder

A list can only get longer through `ListBuilder`, an actor here. So new
lengths come from slicing a literal: up to 64 from a table made once, beyond
that from a slice of 0..1023 (more than 1024 moves on one side panics rather
than drops moves).

    let ch_upto64: List<Int> = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
      32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64,
    ];
    let ch_small: List<List<Int>> = ch_upto64.map { (n): List<Int> => ch_upto64.slice(0, n) };
    let ch_upto: List<Int> = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
      32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
      64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
      96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
      128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
      160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191,
      192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223,
      224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255,
      256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287,
      288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319,
      320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351,
      352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383,
      384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
      416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447,
      448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479,
      480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511,
      512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543,
      544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575,
      576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607,
      608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 628, 629, 630, 631, 632, 633, 634, 635, 636, 637, 638, 639,
      640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 660, 661, 662, 663, 664, 665, 666, 667, 668, 669, 670, 671,
      672, 673, 674, 675, 676, 677, 678, 679, 680, 681, 682, 683, 684, 685, 686, 687, 688, 689, 690, 691, 692, 693, 694, 695, 696, 697, 698, 699, 700, 701, 702, 703,
      704, 705, 706, 707, 708, 709, 710, 711, 712, 713, 714, 715, 716, 717, 718, 719, 720, 721, 722, 723, 724, 725, 726, 727, 728, 729, 730, 731, 732, 733, 734, 735,
      736, 737, 738, 739, 740, 741, 742, 743, 744, 745, 746, 747, 748, 749, 750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 760, 761, 762, 763, 764, 765, 766, 767,
      768, 769, 770, 771, 772, 773, 774, 775, 776, 777, 778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 790, 791, 792, 793, 794, 795, 796, 797, 798, 799,
      800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 831,
      832, 833, 834, 835, 836, 837, 838, 839, 840, 841, 842, 843, 844, 845, 846, 847, 848, 849, 850, 851, 852, 853, 854, 855, 856, 857, 858, 859, 860, 861, 862, 863,
      864, 865, 866, 867, 868, 869, 870, 871, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895,
      896, 897, 898, 899, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 924, 925, 926, 927,
      928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 958, 959,
      960, 961, 962, 963, 964, 965, 966, 967, 968, 969, 970, 971, 972, 973, 974, 975, 976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991,
      992, 993, 994, 995, 996, 997, 998, 999, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023,
    ];

    let ch_rng(n: Int): List<Int> {
      if (n <= 64) { ch_small[n] } else if (n <= 1024) { ch_upto.slice(0, n) } else { panic() }
    }

    let ch_cat(a: List<List<Int>>, b: List<List<Int>>): List<List<Int>> {
      let na = a.length;
      if (na == 0) {
        b
      } else if (b.isEmpty) {
        a
      } else {
        ch_rng(na + b.length).map { (i): List<Int> => ch_pick2(a, b, na, i) }
      }
    }

    let ch_pick2(a: List<List<Int>>, b: List<List<Int>>, na: Int, i: Int): List<Int> {
      if (i < na) { a[i] } else { b[i - na] }
    }

    let ch_flat(gs: List<List<List<Int>>>): List<List<Int>> {
      let ne = gs.filter { (g): Boolean => !g.isEmpty };
      let n = ne.length;
      if (n == 0) {
        []
      } else if (n == 1) {
        ne[0]
      } else if (n == 2) {
        ch_cat(ne[0], ne[1])
      } else {
        let total = ne.reduceFrom(0) { (acc: Int, g: List<List<Int>>): Int => acc + g.length };
        ch_rng(total).map { (k): List<Int> => ch_pick(ne, 0, k) }
      }
    }

    let ch_pick(gs: List<List<List<Int>>>, i: Int, k: Int): List<Int> {
      let g = gs[i];
      if (k < g.length) { g[k] } else { ch_pick(gs, i + 1, k - g.length) }
    }

    let ch_take(ms: List<List<Int>>, n: Int): List<List<Int>> {
      if (ms.length <= n) { ms } else { ch_rng(n).map { (i): List<Int> => ms[i] } }
    }

## The start

`Setup.initial_state/0`: every board gets a full army, black on local ranks
0 and 1, white on 6 and 7.

    let ch_back: List<Int> = [4, 2, 3, 5, 6, 3, 2, 4];

    let ch_start_piece(x: Int, y: Int): Int {
      let r = ch_l8[y];
      if (r == 0) {
        ch_back[ch_l8[x]] + 8
      } else if (r == 1) {
        9
      } else if (r == 6) {
        1
      } else if (r == 7) {
        ch_back[ch_l8[x]]
      } else {
        0
      }
    }

    let ch_kings0: List<Int> = [
      4, 7, 12, 7, 20, 7, 4, 15, 12, 15, 20, 15, 4, 23, 12, 23, 20, 23,
      4, 0, 12, 0, 20, 0, 4, 8, 12, 8, 20, 8, 4, 16, 12, 16, 20, 16,
    ];

    export let ch_initial(): List<List<Int>> {
      let rows = ch_rows.map { (y): List<Int> => ch_rows.map { (x): Int => ch_start_piece(x, y) } };
      let zeros9 = [0, 0, 0, 0, 0, 0, 0, 0, 0];
      let ledger = ch_rng(90).map { (i): Int => 0 };
      ch_rng(29).map { (i): List<Int> => ch_initial_row(rows, i, zeros9, ledger) }
    }

    let ch_initial_row(rows: List<List<Int>>, i: Int, zeros9: List<Int>, ledger: List<Int>): List<Int> {
      if (i < 24) {
        rows[i]
      } else if (i == 24) {
        [0, -1, -1, 0, 0]
      } else if (i == 27) {
        ledger
      } else if (i == 28) {
        ch_kings0
      } else {
        zeros9
      }
    }

## Pseudo-legal moves

`MoveGen`: every move a piece could make, before asking whether it leaves
its own king in check. A move that leaves its board needs a credit for the
piece's type on the board it enters (`resolve_crossing/5`): -1 refused, 0 no
crossing, 1 a crossing. Kings never cross.

    let ch_cross(st: List<List<Int>>, c: Int, t: Int, fb: Int, tb: Int): Int {
      if (fb == tb) {
        0
      } else if (t == 6) {
        -1
      } else if (st[27][tb * 10 + c * 5 + t - 1] > 0) {
        1
      } else {
        -1
      }
    }

    export let ch_piece_moves(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int): List<List<Int>> {
      let t = ch_tp[p];
      if (t == 1) {
        ch_pawn(st, x, y, p, c)
      } else if (t == 2) {
        ch_knight(st, x, y, p, c)
      } else if (t == 3) {
        ch_slide(st, x, y, p, c, 3, ch_diag)
      } else if (t == 4) {
        ch_slide(st, x, y, p, c, 4, ch_orth)
      } else if (t == 5) {
        ch_slide(st, x, y, p, c, 5, ch_queen)
      } else {
        ch_king(st, x, y, p, c)
      }
    }

### Pawns

`pawn_moves/3` builds its list by prepending: the push (promotions as
knight, bishop, rook, queen, since it prepends queen first; a double push
before the single one), then the capture to the left in front of it, then
the capture to the right in front of that. A capture that crosses a board
boundary promotes even off the last rank; an en-passant capture that
crosses one does not.

    let ch_pawn(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int): List<List<Int>> {
      let fdy = ch_fwd[c];
      let fb = ch_bdt[y][x];
      ch_cat(ch_cat(ch_pawn_cap(st, x, y, p, c, fdy, fb, 1), ch_pawn_cap(st, x, y, p, c, fdy, fb, -1)), ch_pawn_push(st, x, y, p, c, fdy, fb))
    }

    let ch_promos(x: Int, y: Int, tx: Int, ty: Int, p: Int, cap: Int, cross: Int): List<List<Int>> {
      [
        ch_move(3, x, y, tx, ty, p, cap, cross, 2, -1, -1, -1, -1),
        ch_move(3, x, y, tx, ty, p, cap, cross, 3, -1, -1, -1, -1),
        ch_move(3, x, y, tx, ty, p, cap, cross, 4, -1, -1, -1, -1),
        ch_move(3, x, y, tx, ty, p, cap, cross, 5, -1, -1, -1, -1),
      ]
    }

    let ch_pawn_push(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fdy: Int, fb: Int): List<List<Int>> {
      let ny = y + fdy;
      if (ny < 0) {
        []
      } else if (ny > 23) {
        []
      } else if (ch_bdt[ny][x] != fb) {
        []
      } else if (st[ny][x] != 0) {
        []
      } else if (ch_l8[ny] == ch_prank[c]) {
        ch_promos(x, y, x, ny, p, 0, 0)
      } else {
        ch_pawn_single(st, x, y, p, c, fdy, fb, ny, ch_move(0, x, y, x, ny, p, 0, 0, 0, -1, -1, -1, -1))
      }
    }

    let ch_pawn_single(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fdy: Int, fb: Int, ny: Int, one: List<Int>): List<List<Int>> {
      let ny2 = ny + fdy;
      if (p >= 16) {
        [one]
      } else if (ch_l8[y] != ch_start[c]) {
        [one]
      } else if (ny2 < 0) {
        [one]
      } else if (ny2 > 23) {
        [one]
      } else if (ch_bdt[ny2][x] != fb) {
        [one]
      } else if (st[ny2][x] != 0) {
        [one]
      } else {
        [ch_move(1, x, y, x, ny2, p, 0, 0, 0, -1, -1, -1, -1), one]
      }
    }

    let ch_pawn_cap(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fdy: Int, fb: Int, dx: Int): List<List<Int>> {
      let nx = x + dx;
      let ny = y + fdy;
      if (nx < 0) {
        []
      } else if (nx > 23) {
        []
      } else if (ny < 0) {
        []
      } else if (ny > 23) {
        []
      } else if (st[25][ch_bdt[ny][nx]] >= 3) {
        []
      } else {
        ch_pawn_cap2(st, x, y, p, c, fdy, fb, nx, ny, ch_cross(st, c, 1, fb, ch_bdt[ny][nx]))
      }
    }

    let ch_pawn_cap2(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fdy: Int, fb: Int, nx: Int, ny: Int, cr: Int): List<List<Int>> {
      let occ = st[ny][nx];
      if (cr < 0) {
        []
      } else if (occ != 0) {
        if (ch_cl[occ] == c) {
          []
        } else if (ch_l8[ny] == ch_prank[c]) {
          ch_promos(x, y, nx, ny, p, occ, cr)
        } else if (cr == 1) {
          ch_promos(x, y, nx, ny, p, occ, cr)
        } else {
          [ch_move(0, x, y, nx, ny, p, occ, cr, 0, -1, -1, -1, -1)]
        }
      } else {
        ch_en_passant(st, x, y, p, c, fdy, nx, ny, cr)
      }
    }

    let ch_en_passant(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fdy: Int, nx: Int, ny: Int, cr: Int): List<List<Int>> {
      let meta = st[24];
      let cy = ny - fdy;
      if (meta[1] != nx) {
        []
      } else if (meta[2] != ny) {
        []
      } else {
        let cp = st[cy][nx];
        if (ch_tp[cp] != 1) {
          []
        } else if (ch_cl[cp] == c) {
          []
        } else {
          [ch_move(2, x, y, nx, ny, p, cp, cr, 0, nx, cy, -1, -1)]
        }
      }
    }

### Knights and kings

A jump is one move or none: each piece maps its eight jumps to a move or an
empty list and keeps the ones that are moves, with no list to join.

    let ch_knight(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int): List<List<Int>> {
      let fb = ch_bdt[y][x];
      ch_knight_d.map { (d): List<Int> => ch_jump(st, x, y, p, c, fb, d[0], d[1]) }.filter { (m): Boolean => !m.isEmpty }
    }

    let ch_jump(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fb: Int, dx: Int, dy: Int): List<Int> {
      let nx = x + dx;
      let ny = y + dy;
      if (nx < 0) {
        []
      } else if (nx > 23) {
        []
      } else if (ny < 0) {
        []
      } else if (ny > 23) {
        []
      } else if (st[25][ch_bdt[ny][nx]] >= 3) {
        []
      } else {
        ch_jump2(st, x, y, p, c, fb, nx, ny, st[ny][nx])
      }
    }

    let ch_jump2(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fb: Int, nx: Int, ny: Int, occ: Int): List<Int> {
      let cr = ch_cross(st, c, 2, fb, ch_bdt[ny][nx]);
      if (ch_cl[occ] == c) {
        []
      } else if (cr < 0) {
        []
      } else {
        ch_move(0, x, y, nx, ny, p, occ, cr, 0, -1, -1, -1, -1)
      }
    }

    let ch_king(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int): List<List<Int>> {
      let fb = ch_bdt[y][x];
      let steps = ch_king_d.map { (d): List<Int> => ch_step(st, x, y, p, c, fb, x + d[0], y + d[1]) }.filter { (m): Boolean => !m.isEmpty };
      if (p >= 16) { steps } else { ch_cat(steps, ch_castles(st, x, y, p, c, fb)) }
    }

    let ch_step(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fb: Int, nx: Int, ny: Int): List<Int> {
      if (nx < 0) {
        []
      } else if (nx > 23) {
        []
      } else if (ny < 0) {
        []
      } else if (ny > 23) {
        []
      } else if (ch_bdt[ny][nx] != fb) {
        []
      } else if (ch_cl[st[ny][nx]] == c) {
        []
      } else {
        ch_move(0, x, y, nx, ny, p, st[ny][nx], 0, 0, -1, -1, -1, -1)
      }
    }

`castle_moves/3`: an unmoved king on its home square, not in check, an
unmoved rook in the corner, the squares between empty, and the squares the
king crosses not attacked. Kingside first. The Elixir asked about check
first; asking it last, and only when a rook and empty squares make a castle
possible, gives the same moves for less.

    let ch_castles(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, fb: Int): List<List<Int>> {
      let ox = ch_ox[fb];
      if (x - ox != 4) {
        []
      } else if (y - ch_oy[fb] != ch_home[c]) {
        []
      } else {
        let both = [ch_castle_k(st, x, y, p, c, ox), ch_castle_q(st, x, y, p, c, ox)].filter { (m): Boolean => !m.isEmpty };
        if (both.isEmpty) { both } else if (ch_attacked(st, x, y, 1 - c)) { [] } else { both }
      }
    }

    let ch_castle_k(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, ox: Int): List<Int> {
      let row = st[y];
      if (row[ox + 7] != 4 + 8 * c) {
        []
      } else if (row[ox + 5] != 0) {
        []
      } else if (row[ox + 6] != 0) {
        []
      } else if (ch_attacked(st, ox + 5, y, 1 - c)) {
        []
      } else if (ch_attacked(st, ox + 6, y, 1 - c)) {
        []
      } else {
        ch_move(4, x, y, ox + 6, y, p, 0, 0, 0, ox + 7, y, ox + 5, y)
      }
    }

    let ch_castle_q(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, ox: Int): List<Int> {
      let row = st[y];
      if (row[ox] != 4 + 8 * c) {
        []
      } else if (row[ox + 3] != 0) {
        []
      } else if (row[ox + 2] != 0) {
        []
      } else if (row[ox + 1] != 0) {
        []
      } else if (ch_attacked(st, ox + 3, y, 1 - c)) {
        []
      } else if (ch_attacked(st, ox + 2, y, 1 - c)) {
        []
      } else {
        ch_move(5, x, y, ox + 2, y, p, 0, 0, 0, ox, y, ox + 3, y)
      }
    }

### Sliders

`sliding_moves/4` walks each ray across the whole plane and stops at a
frozen board, at its own piece, at a boundary it has no credit for, or just
after a capture. It prepends as it walks, so each direction's moves come
farthest first. Here the ray is measured, then its moves made from the far
end.

    let ch_slide(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, t: Int, dirs: List<List<Int>>): List<List<Int>> {
      let fb = ch_bdt[y][x];
      ch_flat(dirs.map { (d): List<List<Int>> => ch_ray(st, x, y, p, c, t, fb, d[0], d[1]) })
    }

    let ch_ray(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, t: Int, fb: Int, dx: Int, dy: Int): List<List<Int>> {
      let n = ch_ray_len(st, c, t, fb, x + dx, y + dy, dx, dy, 0);
      if (n == 0) {
        []
      } else {
        ch_rng(n).map { (i): List<Int> => ch_ray_move(st, x, y, p, fb, x + (n - i) * dx, y + (n - i) * dy) }
      }
    }

    let ch_ray_move(st: List<List<Int>>, x: Int, y: Int, p: Int, fb: Int, tx: Int, ty: Int): List<Int> {
      if (ch_bdt[ty][tx] == fb) {
        ch_move(0, x, y, tx, ty, p, st[ty][tx], 0, 0, -1, -1, -1, -1)
      } else {
        ch_move(0, x, y, tx, ty, p, st[ty][tx], 1, 0, -1, -1, -1, -1)
      }
    }

    let ch_ray_len(st: List<List<Int>>, c: Int, t: Int, fb: Int, nx: Int, ny: Int, dx: Int, dy: Int, n: Int): Int {
      if (nx < 0) {
        n
      } else if (nx > 23) {
        n
      } else if (ny < 0) {
        n
      } else if (ny > 23) {
        n
      } else if (st[25][ch_bdt[ny][nx]] >= 3) {
        n
      } else {
        ch_ray_len2(st, c, t, fb, nx, ny, dx, dy, n, st[ny][nx])
      }
    }

    let ch_ray_len2(st: List<List<Int>>, c: Int, t: Int, fb: Int, nx: Int, ny: Int, dx: Int, dy: Int, n: Int, occ: Int): Int {
      if (ch_cl[occ] == c) {
        n
      } else if (ch_cross(st, c, t, fb, ch_bdt[ny][nx]) < 0) {
        n
      } else if (occ != 0) {
        n + 1
      } else {
        ch_ray_len(st, c, t, fb, nx + dx, ny + dy, dx, dy, n + 1)
      }
    }

### A side's moves

`pseudo_legal_moves/1`: every piece of the colour, in plane order (row by
row, left to right), except those on a frozen board.

    export let ch_pseudo(st: List<List<Int>>, c: Int): List<List<Int>> {
      ch_flat(ch_rows.map { (y): List<List<Int>> => ch_flat(ch_rows.map { (x): List<List<Int>> => ch_moves_at(st, x, y, c) }) })
    }

    let ch_moves_at(st: List<List<Int>>, x: Int, y: Int, c: Int): List<List<Int>> {
      let p = st[y][x];
      if (ch_cl[p] != c) {
        []
      } else if (st[25][ch_bdt[y][x]] >= 3) {
        []
      } else {
        ch_piece_moves(st, x, y, p, c)
      }
    }

## Attack and check

`Attack.attacked_by?/3` looks only at the square's own board: rays stop at
its edge, and a knight or pawn on the next board does not count.

    export let ch_attacked(st: List<List<Int>>, x: Int, y: Int, by: Int): Boolean {
      let b = ch_bdt[y][x];
      let lx = ch_ox[b];
      let ly = ch_oy[b];
      let e = 8 * by;
      if (ch_hit(st, lx, ly, x + 1, y + 1, 1, 1, 3 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x + 1, y - 1, 1, -1, 3 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x - 1, y + 1, -1, 1, 3 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x - 1, y - 1, -1, -1, 3 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x + 1, y, 1, 0, 4 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x - 1, y, -1, 0, 4 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x, y + 1, 0, 1, 4 + e, 5 + e)) {
        true
      } else if (ch_hit(st, lx, ly, x, y - 1, 0, -1, 4 + e, 5 + e)) {
        true
      } else if (ch_jumps_to(st, lx, ly, x, y, 2 + e)) {
        true
      } else if (ch_steps_to(st, lx, ly, x, y, 6 + e)) {
        true
      } else {
        ch_pawn_hits(st, lx, ly, x, y - ch_fwd[by], 1 + e)
      }
    }

The first piece along a ray on the same board (whose top-left corner is
`lx, ly`), if it is either code.

    let ch_hit(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, dx: Int, dy: Int, e1: Int, e2: Int): Boolean {
      if (x < lx) {
        false
      } else if (x > lx + 7) {
        false
      } else if (y < ly) {
        false
      } else if (y > ly + 7) {
        false
      } else {
        ch_hit2(st, lx, ly, x, y, dx, dy, e1, e2, st[y][x])
      }
    }

    let ch_hit2(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, dx: Int, dy: Int, e1: Int, e2: Int, q: Int): Boolean {
      if (q == 0) {
        ch_hit(st, lx, ly, x + dx, y + dy, dx, dy, e1, e2)
      } else if (ch_nm[q] == e1) {
        true
      } else {
        ch_nm[q] == e2
      }
    }

    let ch_is(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, code: Int): Boolean {
      if (x < lx) {
        false
      } else if (x > lx + 7) {
        false
      } else if (y < ly) {
        false
      } else if (y > ly + 7) {
        false
      } else {
        ch_nm[st[y][x]] == code
      }
    }

    let ch_jumps_to(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, code: Int): Boolean {
      if (ch_is(st, lx, ly, x + 1, y + 2, code)) {
        true
      } else if (ch_is(st, lx, ly, x + 2, y + 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x - 1, y + 2, code)) {
        true
      } else if (ch_is(st, lx, ly, x - 2, y + 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x + 1, y - 2, code)) {
        true
      } else if (ch_is(st, lx, ly, x + 2, y - 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x - 1, y - 2, code)) {
        true
      } else {
        ch_is(st, lx, ly, x - 2, y - 1, code)
      }
    }

    let ch_steps_to(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, code: Int): Boolean {
      if (ch_is(st, lx, ly, x + 1, y, code)) {
        true
      } else if (ch_is(st, lx, ly, x - 1, y, code)) {
        true
      } else if (ch_is(st, lx, ly, x, y + 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x, y - 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x + 1, y + 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x + 1, y - 1, code)) {
        true
      } else if (ch_is(st, lx, ly, x - 1, y + 1, code)) {
        true
      } else {
        ch_is(st, lx, ly, x - 1, y - 1, code)
      }
    }

    let ch_pawn_hits(st: List<List<Int>>, lx: Int, ly: Int, x: Int, py: Int, code: Int): Boolean {
      if (ch_is(st, lx, ly, x - 1, py, code)) { true } else { ch_is(st, lx, ly, x + 1, py, code) }
    }

`Check.in_check?/3`: the colour's king on that board is attacked. No king
there (it was taken) is no check.

    export let ch_in_check(st: List<List<Int>>, c: Int, b: Int): Boolean {
      let k = st[28];
      let i = (c * 9 + b) * 2;
      let kx = k[i];
      if (kx < 0) { false } else { ch_attacked(st, kx, k[i + 1], 1 - c) }
    }

## Making a move

`Reducer.apply_plane/2` and the kings: the squares a move empties and fills.
Only the rows it touches are rebuilt.

    let ch_after(old: Int, mv: List<Int>, x: Int, y: Int): Int {
      if (x == mv[1]) {
        if (y == mv[2]) { 0 } else { ch_after_to(old, mv, x, y) }
      } else {
        ch_after_to(old, mv, x, y)
      }
    }

    let ch_after_to(old: Int, mv: List<Int>, x: Int, y: Int): Int {
      if (x == mv[3]) {
        if (y == mv[4]) { mv[13] } else { ch_after_extra(old, mv, x, y) }
      } else {
        ch_after_extra(old, mv, x, y)
      }
    }

    let ch_after_extra(old: Int, mv: List<Int>, x: Int, y: Int): Int {
      let k = mv[0];
      if (k < 2) {
        old
      } else if (k == 3) {
        old
      } else if (x != mv[9]) {
        ch_after_rook(old, mv, x, y, k)
      } else if (y != mv[10]) {
        ch_after_rook(old, mv, x, y, k)
      } else {
        0
      }
    }

    let ch_after_rook(old: Int, mv: List<Int>, x: Int, y: Int, k: Int): Int {
      if (k == 2) {
        old
      } else if (x != mv[11]) {
        old
      } else if (y != mv[12]) {
        old
      } else {
        20 + 8 * ch_cl[mv[5]]
      }
    }

    let ch_touches(mv: List<Int>, y: Int): Boolean {
      if (y == mv[2]) {
        true
      } else if (y == mv[4]) {
        true
      } else if (mv[0] == 2) {
        y == mv[10]
      } else {
        false
      }
    }

    let ch_row_after(st: List<List<Int>>, mv: List<Int>, y: Int): List<Int> {
      let row = st[y];
      if (ch_touches(mv, y)) { ch_rows.map { (x): Int => ch_after(row[x], mv, x, y) } } else { row }
    }

    let ch_kings_after(k: List<Int>, mv: List<Int>): List<Int> {
      let p = mv[5];
      let cap = mv[6];
      if (ch_tp[p] == 6) {
        let at = (ch_cl[p] * 9 + ch_bdt[mv[2]][mv[1]]) * 2;
        ch_rng(36).map { (i): Int => ch_king_slot(k, i, at, mv[3], mv[4]) }
      } else if (ch_tp[cap] == 6) {
        let at = (ch_cl[cap] * 9 + ch_bdt[mv[4]][mv[3]]) * 2;
        ch_rng(36).map { (i): Int => ch_king_slot(k, i, at, -1, -1) }
      } else {
        k
      }
    }

    let ch_king_slot(k: List<Int>, i: Int, at: Int, kx: Int, ky: Int): Int {
      if (i == at) { kx } else if (i == at + 1) { ky } else { k[i] }
    }

The position after a move, with only the plane and the kings changed:
enough to ask about check (`apply_unchecked_no_status/2` also moved the
ledger and clocks, which a check test never reads).

    let ch_plane_after(st: List<List<Int>>, mv: List<Int>): List<List<Int>> {
      let kings = ch_kings_after(st[28], mv);
      ch_rng(29).map { (i): List<Int> => ch_plane_row(st, mv, i, kings) }
    }

    let ch_plane_row(st: List<List<Int>>, mv: List<Int>, i: Int, kings: List<Int>): List<Int> {
      if (i < 24) { ch_row_after(st, mv, i) } else if (i == 28) { kings } else { st[i] }
    }

`Legal.leaves_own_king_in_check?/2`: after the move, the mover's king is in
check on a board the move touched (its from and to boards, and for en
passant the taken pawn's). A king left in check on some other board does
not make a move illegal: that is the variant's rule, not a slip here.

    export let ch_leaves_check(st: List<List<Int>>, mv: List<Int>): Boolean {
      let next = ch_plane_after(st, mv);
      let c = ch_cl[mv[5]];
      if (ch_in_check(next, c, ch_bdt[mv[2]][mv[1]])) {
        true
      } else if (ch_in_check(next, c, ch_bdt[mv[4]][mv[3]])) {
        true
      } else if (mv[0] == 2) {
        ch_in_check(next, c, ch_bdt[mv[10]][mv[9]])
      } else {
        false
      }
    }

That test builds the position after the move and looks for attacks on up
to three kings, for every candidate. The same answer comes cheaper by
reading the position as it will be instead of building it: the squares the
move empties (where the piece stood, the pawn taken en passant) read as
empty and the destination reads as the piece put there. `ch_vread` is that
reading, `ch_attacked_v` the attack test over it.

And most candidates need no attack test at all. If the king on a touched
board is not in check now and does not move, a check there afterwards has
to come through a square the move emptied: filling a square never uncovers
an attack, and knights, pawns and kings attack the same squares whoever
stands between. So only the line from the king through an emptied square
is walked, and only if there is one. Castling, rare, still builds the
position (`ch_leaves_check`). The answer is the same as the full test for
every move, which the tests check.

`chk` is which boards the mover's king is in check on now, 1 or 0 each.

    export let ch_checks(st: List<List<Int>>, c: Int): List<Int> {
      ch_rng(9).map { (b): Int => ch_check_int(st, c, b) }
    }

    let ch_check_int(st: List<List<Int>>, c: Int, b: Int): Int {
      if (ch_in_check(st, c, b)) { 1 } else { 0 }
    }

    export let ch_illegal(st: List<List<Int>>, mv: List<Int>, chk: List<Int>): Boolean {
      let k = mv[0];
      let p = mv[5];
      let c = ch_cl[p];
      if (k >= 4) {
        ch_leaves_check(st, mv)
      } else if (ch_tp[p] == 6) {
        ch_attacked_v(st, mv[3], mv[4], 1 - c, mv[1], mv[2], mv[3], mv[4], mv[13], -1, -1)
      } else if (k == 2) {
        ch_illegal_move(st, mv, chk, c, mv[9], mv[10])
      } else {
        ch_illegal_move(st, mv, chk, c, -1, -1)
      }
    }

    let ch_illegal_move(st: List<List<Int>>, mv: List<Int>, chk: List<Int>, c: Int, cx: Int, cy: Int): Boolean {
      let fb = ch_bdt[mv[2]][mv[1]];
      let tb = ch_bdt[mv[4]][mv[3]];
      if (ch_unsafe(st, mv, chk, c, fb, cx, cy)) {
        true
      } else if (tb == fb) {
        ch_unsafe_ep(st, mv, chk, c, fb, tb, cx, cy)
      } else if (ch_unsafe(st, mv, chk, c, tb, cx, cy)) {
        true
      } else {
        ch_unsafe_ep(st, mv, chk, c, fb, tb, cx, cy)
      }
    }

    let ch_unsafe_ep(st: List<List<Int>>, mv: List<Int>, chk: List<Int>, c: Int, fb: Int, tb: Int, cx: Int, cy: Int): Boolean {
      if (cx < 0) {
        false
      } else {
        let cb = ch_bdt[cy][cx];
        if (cb == fb) { false } else if (cb == tb) { false } else { ch_unsafe(st, mv, chk, c, cb, cx, cy) }
      }
    }

Whether the move leaves colour c's king on board b attacked.

    let ch_unsafe(st: List<List<Int>>, mv: List<Int>, chk: List<Int>, c: Int, b: Int, cx: Int, cy: Int): Boolean {
      let i = (c * 9 + b) * 2;
      let kx = st[28][i];
      let ky = st[28][i + 1];
      if (kx < 0) {
        false
      } else if (chk[b] == 1) {
        ch_attacked_v(st, kx, ky, 1 - c, mv[1], mv[2], mv[3], mv[4], mv[13], cx, cy)
      } else if (ch_opens(st, mv, c, b, kx, ky, mv[1], mv[2], cx, cy)) {
        true
      } else if (cx < 0) {
        false
      } else {
        ch_opens(st, mv, c, b, kx, ky, cx, cy, cx, cy)
      }
    }

Whether emptying (vx, vy), if it is on board b, lets an enemy slider see the
king at (kx, ky) there.

    let ch_opens(st: List<List<Int>>, mv: List<Int>, c: Int, b: Int, kx: Int, ky: Int, vx: Int, vy: Int, cx: Int, cy: Int): Boolean {
      let dx = vx - kx;
      let dy = vy - ky;
      let e = 8 - 8 * c;
      let lx = ch_ox[b];
      let ly = ch_oy[b];
      if (ch_bdt[vy][vx] != b) {
        false
      } else if (dx == 0) {
        ch_hit_v(st, lx, ly, kx, ky + ch_sign(dy), 0, ch_sign(dy), 4 + e, 5 + e, mv[1], mv[2], mv[3], mv[4], mv[13], cx, cy)
      } else if (dy == 0) {
        ch_hit_v(st, lx, ly, kx + ch_sign(dx), ky, ch_sign(dx), 0, 4 + e, 5 + e, mv[1], mv[2], mv[3], mv[4], mv[13], cx, cy)
      } else if (dx == dy) {
        ch_hit_v(st, lx, ly, kx + ch_sign(dx), ky + ch_sign(dy), ch_sign(dx), ch_sign(dy), 3 + e, 5 + e, mv[1], mv[2], mv[3], mv[4], mv[13], cx, cy)
      } else if (dx + dy == 0) {
        ch_hit_v(st, lx, ly, kx + ch_sign(dx), ky + ch_sign(dy), ch_sign(dx), ch_sign(dy), 3 + e, 5 + e, mv[1], mv[2], mv[3], mv[4], mv[13], cx, cy)
      } else {
        false
      }
    }

    let ch_sign(n: Int): Int {
      if (n > 0) { 1 } else if (n < 0) { -1 } else { 0 }
    }

The square (x, y) with (fx, fy) and (cx, cy) emptied and (tx, ty) holding
`tp`.

    let ch_vread(st: List<List<Int>>, x: Int, y: Int, fx: Int, fy: Int, tx: Int, ty: Int, tp: Int, cx: Int, cy: Int): Int {
      if (x == tx) {
        if (y == ty) { tp } else { ch_vread2(st, x, y, fx, fy, cx, cy) }
      } else {
        ch_vread2(st, x, y, fx, fy, cx, cy)
      }
    }

    let ch_vread2(st: List<List<Int>>, x: Int, y: Int, fx: Int, fy: Int, cx: Int, cy: Int): Int {
      if (x == fx) {
        if (y == fy) { 0 } else { ch_vread3(st, x, y, cx, cy) }
      } else {
        ch_vread3(st, x, y, cx, cy)
      }
    }

    let ch_vread3(st: List<List<Int>>, x: Int, y: Int, cx: Int, cy: Int): Int {
      if (x == cx) {
        if (y == cy) { 0 } else { st[y][x] }
      } else {
        st[y][x]
      }
    }

`ch_attacked` over that reading.

    let ch_attacked_v(st: List<List<Int>>, x: Int, y: Int, by: Int, fx: Int, fy: Int, tx: Int, ty: Int, tp: Int, cx: Int, cy: Int): Boolean {
      let b = ch_bdt[y][x];
      let lx = ch_ox[b];
      let ly = ch_oy[b];
      let e = 8 * by;
      if (ch_hit_v(st, lx, ly, x + 1, y + 1, 1, 1, 3 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x + 1, y - 1, 1, -1, 3 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x - 1, y + 1, -1, 1, 3 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x - 1, y - 1, -1, -1, 3 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x + 1, y, 1, 0, 4 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x - 1, y, -1, 0, 4 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x, y + 1, 0, 1, 4 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_hit_v(st, lx, ly, x, y - 1, 0, -1, 4 + e, 5 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_near_v(st, lx, ly, x, y, ch_knight_d, 0, 2 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else if (ch_near_v(st, lx, ly, x, y, ch_king_d, 0, 6 + e, fx, fy, tx, ty, tp, cx, cy)) {
        true
      } else {
        ch_near_v(st, lx, ly, x, y - ch_fwd[by], ch_pawn_d, 0, 1 + e, fx, fy, tx, ty, tp, cx, cy)
      }
    }

    let ch_pawn_d: List<List<Int>> = [[-1, 0], [1, 0]];

    let ch_hit_v(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, dx: Int, dy: Int, e1: Int, e2: Int, fx: Int, fy: Int, tx: Int, ty: Int, tp: Int, cx: Int, cy: Int): Boolean {
      if (x < lx) {
        false
      } else if (x > lx + 7) {
        false
      } else if (y < ly) {
        false
      } else if (y > ly + 7) {
        false
      } else {
        let q = ch_vread(st, x, y, fx, fy, tx, ty, tp, cx, cy);
        if (q == 0) {
          ch_hit_v(st, lx, ly, x + dx, y + dy, dx, dy, e1, e2, fx, fy, tx, ty, tp, cx, cy)
        } else if (ch_nm[q] == e1) {
          true
        } else {
          ch_nm[q] == e2
        }
      }
    }

    let ch_near_v(st: List<List<Int>>, lx: Int, ly: Int, x: Int, y: Int, ds: List<List<Int>>, i: Int, code: Int, fx: Int, fy: Int, tx: Int, ty: Int, tp: Int, cx: Int, cy: Int): Boolean {
      if (i >= ds.length) {
        false
      } else {
        let d = ds[i];
        let nx = x + d[0];
        let ny = y + d[1];
        if (nx < lx) {
          ch_near_v(st, lx, ly, x, y, ds, i + 1, code, fx, fy, tx, ty, tp, cx, cy)
        } else if (nx > lx + 7) {
          ch_near_v(st, lx, ly, x, y, ds, i + 1, code, fx, fy, tx, ty, tp, cx, cy)
        } else if (ny < ly) {
          ch_near_v(st, lx, ly, x, y, ds, i + 1, code, fx, fy, tx, ty, tp, cx, cy)
        } else if (ny > ly + 7) {
          ch_near_v(st, lx, ly, x, y, ds, i + 1, code, fx, fy, tx, ty, tp, cx, cy)
        } else if (ch_nm[ch_vread(st, nx, ny, fx, fy, tx, ty, tp, cx, cy)] == code) {
          true
        } else {
          ch_near_v(st, lx, ly, x, y, ds, i + 1, code, fx, fy, tx, ty, tp, cx, cy)
        }
      }
    }

`ch_apply` has just worked out, for the side now to move, which boards it is
in check on: statuses 1 and 2. Moves only ever touch boards that are not
frozen, where that is the whole answer, so a search reads it from there
rather than looking again.

    export let ch_status_checks(st: List<List<Int>>, c: Int): List<Int> {
      st[25].map { (s): Int => ch_is_check(s, c) }
    }

    let ch_is_check(s: Int, c: Int): Int {
      if (s == 1 + c) { 1 } else { 0 }
    }

    export let ch_legal_moves(st: List<List<Int>>): List<List<Int>> {
      let c = st[24][0];
      let chk = ch_status_checks(st, c);
      ch_pseudo(st, c).filter { (m): Boolean => !ch_illegal(st, m, chk) }
    }

`Legal.legal_moves_for_square/2`, which is also the order
`find_legal_move/3` searches in: the first legal move from `from` to `to`.
For a pawn reaching a promotion square that is the knight, so a click
promotes to a knight, as it does in production.

    export let ch_square_moves(st: List<List<Int>>, x: Int, y: Int): List<List<Int>> {
      let p = st[y][x];
      let c = st[24][0];
      if (ch_cl[p] != c) {
        []
      } else if (st[25][ch_bdt[y][x]] >= 3) {
        []
      } else {
        let chk = ch_status_checks(st, c);
        ch_piece_moves(st, x, y, p, c).filter { (m): Boolean => !ch_illegal(st, m, chk) }
      }
    }

    export let ch_find(st: List<List<Int>>, fx: Int, fy: Int, tx: Int, ty: Int): List<Int> {
      let ms = ch_square_moves(st, fx, fy).filter { (m): Boolean => m[3] == tx && m[4] == ty };
      if (ms.isEmpty) { [] } else { ms[0] }
    }

`apply_core/2`: the plane, the ledger (a taken piece other than a king
credits its owner on the board it was taken on; a crossing spends one of
the mover's), the en-passant square, whose turn, the ply, and the clocks of
the boards the move touched (back to 0 for a pawn move or a capture).

    let ch_apply_core(st: List<List<Int>>, mv: List<Int>): List<List<Int>> {
      let c = ch_cl[mv[5]];
      let meta = st[24];
      let kings = ch_kings_after(st[28], mv);
      let ledger = ch_ledger_after(st[27], mv, c);
      let clocks = ch_clocks_after(st[26], mv);
      let next_meta = ch_meta_after(meta, mv, c);
      ch_rng(29).map { (i): List<Int> => ch_core_row(st, mv, i, next_meta, clocks, ledger, kings) }
    }

    let ch_core_row(st: List<List<Int>>, mv: List<Int>, i: Int, meta: List<Int>, clocks: List<Int>, ledger: List<Int>, kings: List<Int>): List<Int> {
      if (i < 24) {
        ch_row_after(st, mv, i)
      } else if (i == 24) {
        meta
      } else if (i == 26) {
        clocks
      } else if (i == 27) {
        ledger
      } else if (i == 28) {
        kings
      } else {
        st[i]
      }
    }

    let ch_meta_after(meta: List<Int>, mv: List<Int>, c: Int): List<Int> {
      let material = meta[4] - ch_signed[mv[6]] + ch_signed[mv[13]] - ch_signed[mv[5]];
      if (mv[0] == 1) {
        [1 - meta[0], mv[1], mv[2] + ch_fwd[c], meta[3] + 1, material]
      } else {
        [1 - meta[0], -1, -1, meta[3] + 1, material]
      }
    }

    let ch_ledger_after(l: List<Int>, mv: List<Int>, c: Int): List<Int> {
      let cap = mv[6];
      let ct = ch_tp[cap];
      let gain = ch_gain_index(mv, cap, ct);
      let spend = if (mv[7] == 1) { ch_bdt[mv[4]][mv[3]] * 10 + c * 5 + ch_tp[mv[5]] - 1 } else { -1 };
      if (gain < 0 && spend < 0) {
        l
      } else {
        ch_rng(90).map { (i): Int => ch_ledger_slot(l, i, gain, spend) }
      }
    }

    let ch_gain_index(mv: List<Int>, cap: Int, ct: Int): Int {
      if (cap == 0) {
        -1
      } else if (ct == 6) {
        -1
      } else if (mv[0] == 2) {
        ch_bdt[mv[10]][mv[9]] * 10 + ch_cl[cap] * 5 + ct - 1
      } else {
        ch_bdt[mv[4]][mv[3]] * 10 + ch_cl[cap] * 5 + ct - 1
      }
    }

    let ch_ledger_slot(l: List<Int>, i: Int, gain: Int, spend: Int): Int {
      let v = if (i == gain) { l[i] + 1 } else { l[i] };
      if (i == spend && v > 0) { v - 1 } else { v }
    }

    let ch_clocks_after(k: List<Int>, mv: List<Int>): List<Int> {
      let reset = ch_tp[mv[5]] == 1 || mv[6] != 0;
      let fb = ch_bdt[mv[2]][mv[1]];
      let tb = ch_bdt[mv[4]][mv[3]];
      let cb = if (mv[0] == 2) { ch_bdt[mv[10]][mv[9]] } else { fb };
      ch_rng(9).map { (b): Int => ch_clock(k[b], b == fb || b == tb || b == cb, reset) }
    }

    let ch_clock(v: Int, touched: Boolean, reset: Boolean): Int {
      if (!touched) { v } else if (reset) { 0 } else { v + 1 }
    }

## Board status

`Reducer.apply_unchecked/2`: after the move, every board that is not
frozen gets its status again, for the side now to move. Those statuses are
worked out against the position with the old statuses still in it (the
Elixir reduced them into a separate tuple), which decides which boards a
move generated along the way may enter.

    export let ch_apply(st: List<List<Int>>, mv: List<Int>): List<List<Int>> {
      let mid = ch_apply_core(st, mv);
      let old = st[25];
      let chk = ch_checks(mid, mid[24][0]);
      let status = ch_rng(9).map { (b): Int => ch_status_of(mid, old[b], b, chk) };
      ch_rng(29).map { (i): List<Int> => ch_status_row(mid, i, status) }
    }

    let ch_status_of(mid: List<List<Int>>, old: Int, b: Int, chk: List<Int>): Int {
      if (old >= 3) { old } else { ch_board_status(mid, b, chk) }
    }

    let ch_status_row(mid: List<List<Int>>, i: Int, status: List<Int>): List<Int> {
      if (i == 25) { status } else { mid[i] }
    }

`board_status/2`, in its order: check (mate if no legal move helps),
insufficient material, the fifty-move clock, the ply cap, stalemate.

    let ch_board_status(st: List<List<Int>>, b: Int, chk: List<Int>): Int {
      let c = st[24][0];
      if (chk[b] == 1) {
        if (ch_any_legal_board(st, b, c, chk)) { 1 + c } else { 4 - c }
      } else if (ch_insufficient(st, b)) {
        7
      } else if (st[26][b] >= 100) {
        6
      } else if (st[24][3] >= 600) {
        6
      } else if (ch_any_legal_board(st, b, c, chk)) {
        0
      } else {
        5
      }
    }

`Legal.legal_moves_for_board/2 == []`, asked as "is there one": the moves
of the colour's pieces on the board, wherever they go, and, if the colour
holds any credit on the board, the moves of its pieces elsewhere that cross
into it. Those include pieces on frozen boards, which the Elixir did not
leave out there. Only a piece whose type holds a credit on the board can
cross into it, so only those are asked. Whether there is one does not
depend on the order they are asked in.

    let ch_any_legal_board(st: List<List<Int>>, b: Int, c: Int, chk: List<Int>): Boolean {
      if (ch_any_on_board(st, b, c, chk, 0, 0)) {
        true
      } else if (ch_credits_on(st[27], b, c) > 0) {
        ch_any_into(st, b, c, chk, 0, 0)
      } else {
        false
      }
    }

    let ch_any_legal(st: List<List<Int>>, ms: List<List<Int>>, i: Int, chk: List<Int>): Boolean {
      if (i >= ms.length) {
        false
      } else if (ch_illegal(st, ms[i], chk)) {
        ch_any_legal(st, ms, i + 1, chk)
      } else {
        true
      }
    }

Ranks in the order a colour's pieces are most likely to have a move:
its pawns' rank, its back rank, then on across the board.

    let ch_rank_order: List<List<Int>> = [[6, 7, 5, 4, 3, 2, 1, 0], [1, 0, 2, 3, 4, 5, 6, 7]];

    let ch_any_on_board(st: List<List<Int>>, b: Int, c: Int, chk: List<Int>, ri: Int, f: Int): Boolean {
      if (f > 7) {
        if (ri >= 7) { false } else { ch_any_on_board(st, b, c, chk, ri + 1, 0) }
      } else {
        let x = ch_ox[b] + f;
        let y = ch_oy[b] + ch_rank_order[c][ri];
        let p = st[y][x];
        if (ch_cl[p] != c) {
          ch_any_on_board(st, b, c, chk, ri, f + 1)
        } else if (ch_any_legal(st, ch_piece_moves(st, x, y, p, c), 0, chk)) {
          true
        } else {
          ch_any_on_board(st, b, c, chk, ri, f + 1)
        }
      }
    }

    let ch_credits_on(l: List<Int>, b: Int, c: Int): Int {
      let i = b * 10 + c * 5;
      l[i] + l[i + 1] + l[i + 2] + l[i + 3] + l[i + 4]
    }

    let ch_any_into(st: List<List<Int>>, b: Int, c: Int, chk: List<Int>, x: Int, y: Int): Boolean {
      if (x > 23) {
        if (y >= 23) { false } else { ch_any_into(st, b, c, chk, 0, y + 1) }
      } else {
        let p = st[y][x];
        if (ch_cl[p] != c) {
          ch_any_into(st, b, c, chk, x + 1, y)
        } else if (ch_bdt[y][x] == b) {
          ch_any_into(st, b, c, chk, x + 1, y)
        } else if (ch_tp[p] == 6) {
          ch_any_into(st, b, c, chk, x + 1, y)
        } else if (st[27][b * 10 + c * 5 + ch_tp[p] - 1] == 0) {
          ch_any_into(st, b, c, chk, x + 1, y)
        } else if (ch_any_legal(st, ch_piece_moves(st, x, y, p, c).filter { (m): Boolean => ch_enters(m, b) }, 0, chk)) {
          true
        } else {
          ch_any_into(st, b, c, chk, x + 1, y)
        }
      }
    }

    let ch_enters(m: List<Int>, b: Int): Boolean {
      if (m[7] != 1) { false } else { ch_bdt[m[4]][m[3]] == b }
    }

`Draws.insufficient_material?/2`: both kings on the board and at most one
bishop or knight besides; anything else on it (or a king missing) is
enough to play on.

    let ch_insufficient(st: List<List<Int>>, b: Int): Boolean {
      ch_insuf(st, ch_ox[b], ch_oy[b], 0, 0, 0, 0, 0)
    }

    let ch_insuf(st: List<List<Int>>, ox: Int, oy: Int, r: Int, f: Int, wk: Int, bk: Int, minors: Int): Boolean {
      if (f > 7) {
        if (r < 7) {
          ch_insuf(st, ox, oy, r + 1, 0, wk, bk, minors)
        } else if (wk == 0) {
          false
        } else if (bk == 0) {
          false
        } else {
          minors <= 1
        }
      } else {
        let p = st[oy + r][ox + f];
        let t = ch_tp[p];
        if (p == 0) {
          ch_insuf(st, ox, oy, r, f + 1, wk, bk, minors)
        } else if (t == 6) {
          if (ch_cl[p] == 0) { ch_insuf(st, ox, oy, r, f + 1, 1, bk, minors) } else { ch_insuf(st, ox, oy, r, f + 1, wk, 1, minors) }
        } else if (t == 2 || t == 3) {
          ch_insuf(st, ox, oy, r, f + 1, wk, bk, minors + 1)
        } else {
          false
        }
      }
    }

## The match

    export let ch_frozen(status: Int): Boolean { status >= 3 }

    export let ch_game_over(st: List<List<Int>>): Boolean {
      st[25].filter { (s): Boolean => s < 3 }.isEmpty
    }

    export let ch_boards_won(st: List<List<Int>>, c: Int): Int {
      st[25].filter { (s): Boolean => s == 3 + c }.length
    }

`Scoring.winner/1`: "white", "black" or "draw" on boards won.

    export let ch_winner(st: List<List<Int>>): String {
      let w = ch_boards_won(st, 0);
      let b = ch_boards_won(st, 1);
      if (w > b) { "white" } else if (b > w) { "black" } else { "draw" }
    }

## The bot's evaluation

`Eval.evaluate/2`, in 32nds of a pawn. The Elixir's scores are floats, but
every constant in them is a multiple of 1/32 (a bishop is 3.25, a capture
on crossing is an eighth of the victim's value, 13/32 for a bishop), so the
floats were exact and these integers are the same numbers times 32. The
tie window of 1.0 is 32.

    let ch_val: List<Int> = [0, 32, 96, 104, 160, 288, 0];
    let ch_val8: List<Int> = [0, 4, 12, 13, 20, 36, 0];

Material for white minus material for black, per piece code. A move
changes it by what it takes and, for a promotion, by the pawn becoming
something else (`ch_meta_after`); the moved flag does not change a value.

    let ch_signed: List<Int> = [
      0, 32, 96, 104, 160, 288, 0, 0, 0, -32, -96, -104, -160, -288, 0, 0,
      0, 32, 96, 104, 160, 288, 0, 0, 0, -32, -96, -104, -160, -288, 0, 0,
    ];

    export let ch_material(st: List<List<Int>>): Int {
      ch_rows.reduceFrom(0) { (acc: Int, y: Int): Int => acc + st[y].reduceFrom(0) { (a: Int, p: Int): Int => a + ch_signed[p] } }
    }

    export let ch_evaluate(st: List<List<Int>>, color: Int): Int {
      let opp = 1 - color;
      let boards = (ch_boards_won(st, color) - ch_boards_won(st, opp)) * 1600;
      let white = st[24][4] + ch_threats(st);
      if (color == 0) { boards + white } else { boards - white }
    }

`cross_threat_bonus/2`: 8 a credit held, and for every crossing move the
colour could make (its pseudo-legal moves, as if it were to move) 6, plus
an eighth of what it would take, plus 70 if it would give check on the
board it enters. With no credit anywhere there is no crossing move, so the
moves are not generated at all.

    export let ch_threat(st: List<List<Int>>, color: Int): Int {
      let l = st[27];
      let credits = ch_credit_total(l, color, 0, 0);
      if (credits == 0) {
        0
      } else {
        let by_type = ch_by_type(l, color);
        credits * 256 + ch_rows.reduceFrom(0) { (acc: Int, y: Int): Int => ch_row_threat(st, st[y], y, 0, acc, color, by_type, by_type) }
      }
    }

    let ch_by_type(l: List<Int>, color: Int): List<Int> {
      [0, ch_type_credits(l, color, 1), ch_type_credits(l, color, 2), ch_type_credits(l, color, 3), ch_type_credits(l, color, 4), ch_type_credits(l, color, 5), 0]
    }

White's bonus minus black's, both from one pass over the plane (a colour
with no credit gets an all-zero `by_type`, so none of its pieces is asked).

    let ch_threats(st: List<List<Int>>): Int {
      let l = st[27];
      let cw = ch_credit_total(l, 0, 0, 0);
      let cb = ch_credit_total(l, 1, 0, 0);
      if (cw + cb == 0) {
        0
      } else {
        let bw = if (cw == 0) { ch_no_types } else { ch_by_type(l, 0) };
        let bb = if (cb == 0) { ch_no_types } else { ch_by_type(l, 1) };
        (cw - cb) * 256 + ch_rows.reduceFrom(0) { (acc: Int, y: Int): Int => ch_row_threat(st, st[y], y, 0, acc, -1, bw, bb) }
      }
    }

    let ch_no_types: List<Int> = [0, 0, 0, 0, 0, 0, 0];

`color` -1 counts both, black's negated.

    let ch_row_threat(st: List<List<Int>>, row: List<Int>, y: Int, x: Int, acc: Int, color: Int, bw: List<Int>, bb: List<Int>): Int {
      if (x > 23) {
        acc
      } else {
        let p = row[x];
        let c = ch_cl[p];
        if (p == 0) {
          ch_row_threat(st, row, y, x + 1, acc, color, bw, bb)
        } else if (color >= 0 && c != color) {
          ch_row_threat(st, row, y, x + 1, acc, color, bw, bb)
        } else if (c == 0) {
          ch_row_threat(st, row, y, x + 1, acc + ch_square_threat(st, x, y, p, 0, bw), color, bw, bb)
        } else if (color >= 0) {
          ch_row_threat(st, row, y, x + 1, acc + ch_square_threat(st, x, y, p, 1, bb), color, bw, bb)
        } else {
          ch_row_threat(st, row, y, x + 1, acc - ch_square_threat(st, x, y, p, 1, bb), color, bw, bb)
        }
      }
    }

    let ch_square_threat(st: List<List<Int>>, x: Int, y: Int, p: Int, color: Int, by_type: List<Int>): Int {
      let t = ch_tp[p];
      if (by_type[t] == 0) {
        0
      } else if (st[25][ch_bdt[y][x]] >= 3) {
        0
      } else if (t == 1) {
        let lx = ch_l8[x];
        if (lx == 0) {
          ch_pawn_threat(st, x, y, p, color, -1)
        } else if (lx == 7) {
          ch_pawn_threat(st, x, y, p, color, 1)
        } else {
          0
        }
      } else if (t == 2) {
        if (ch_inner[ch_l8[x]] && ch_inner[ch_l8[y]]) {
          0
        } else {
          ch_knight_d.reduceFrom(0) { (acc: Int, d: List<Int>): Int => acc + ch_jump_threat(st, x, y, p, color, x + d[0], y + d[1]) }
        }
      } else if (t == 3) {
        ch_slider_threat(st, x, y, p, color, t, ch_diag)
      } else if (t == 4) {
        ch_slider_threat(st, x, y, p, color, t, ch_orth)
      } else {
        ch_slider_threat(st, x, y, p, color, t, ch_queen)
      }
    }

A knight two squares or more from every edge of its board lands on the
same board; a pawn's capture toward the inside of its board does too.

    let ch_inner: List<Boolean> = [false, false, true, true, true, true, false, false];

Whether colour c's piece of type t may enter board tb from board fb.

    let ch_may_enter(st: List<List<Int>>, c: Int, t: Int, fb: Int, tb: Int): Boolean {
      if (fb == tb) {
        false
      } else if (st[25][tb] >= 3) {
        false
      } else {
        st[27][tb * 10 + c * 5 + t - 1] > 0
      }
    }

    let ch_pawn_threat(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, dx: Int): Int {
      let nx = x + dx;
      let ny = y + ch_fwd[c];
      if (nx < 0) {
        0
      } else if (nx > 23) {
        0
      } else if (ny < 0) {
        0
      } else if (ny > 23) {
        0
      } else if (!ch_may_enter(st, c, 1, ch_bdt[y][x], ch_bdt[ny][nx])) {
        0
      } else {
        let occ = st[ny][nx];
        if (occ != 0) {
          if (ch_cl[occ] == c) { 0 } else { 4 * ch_move_bonus(st, x, y, nx, ny, p, occ, c) }
        } else if (st[24][1] != nx) {
          0
        } else if (st[24][2] != ny) {
          0
        } else {
          let cp = st[y][nx];
          if (ch_tp[cp] != 1) {
            0
          } else if (ch_cl[cp] == c) {
            0
          } else {
            ch_move_bonus(st, x, y, nx, ny, p, cp, c)
          }
        }
      }
    }

    let ch_jump_threat(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, nx: Int, ny: Int): Int {
      if (nx < 0) {
        0
      } else if (nx > 23) {
        0
      } else if (ny < 0) {
        0
      } else if (ny > 23) {
        0
      } else if (!ch_may_enter(st, c, 2, ch_bdt[y][x], ch_bdt[ny][nx])) {
        0
      } else if (ch_cl[st[ny][nx]] == c) {
        0
      } else {
        ch_move_bonus(st, x, y, nx, ny, p, st[ny][nx], c)
      }
    }

    let ch_slider_threat(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, t: Int, dirs: List<List<Int>>): Int {
      let fb = ch_bdt[y][x];
      dirs.reduceFrom(0) { (acc: Int, d: List<Int>): Int => acc + ch_dir_threat(st, x, y, p, c, t, fb, d[0], d[1]) }
    }

How many steps from local coordinate l to the edge of its board going
d: 8 - l forward, l + 1 back, never for 0.

    let ch_to_edge(l: Int, d: Int): Int {
      if (d > 0) { 8 - l } else if (d < 0) { l + 1 } else { 99 }
    }

    let ch_dir_threat(st: List<List<Int>>, x: Int, y: Int, p: Int, c: Int, t: Int, fb: Int, dx: Int, dy: Int): Int {
      let sx = ch_to_edge(ch_l8[x], dx);
      let sy = ch_to_edge(ch_l8[y], dy);
      let k = if (sx < sy) { sx } else { sy };
      let ex = x + k * dx;
      let ey = y + k * dy;
      if (ex < 0) {
        0
      } else if (ex > 23) {
        0
      } else if (ey < 0) {
        0
      } else if (ey > 23) {
        0
      } else if (!ch_may_enter(st, c, t, fb, ch_bdt[ey][ex])) {
        0
      } else {
        ch_ray_bonus(st, c, t, fb, p, x, y, x + dx, y + dy, dx, dy, 0)
      }
    }

A slider's crossing moves along one ray: the same walk as `ch_ray_len`,
scoring each square it reaches off its own board.

    let ch_ray_bonus(st: List<List<Int>>, c: Int, t: Int, fb: Int, p: Int, fx: Int, fy: Int, nx: Int, ny: Int, dx: Int, dy: Int, acc: Int): Int {
      if (nx < 0) {
        acc
      } else if (nx > 23) {
        acc
      } else if (ny < 0) {
        acc
      } else if (ny > 23) {
        acc
      } else {
        let tb = ch_bdt[ny][nx];
        let occ = st[ny][nx];
        if (st[25][tb] >= 3) {
          acc
        } else if (ch_cl[occ] == c) {
          acc
        } else if (ch_cross(st, c, t, fb, tb) < 0) {
          acc
        } else if (tb == fb) {
          if (occ != 0) { acc } else { ch_ray_bonus(st, c, t, fb, p, fx, fy, nx + dx, ny + dy, dx, dy, acc) }
        } else if (occ != 0) {
          acc + ch_move_bonus(st, fx, fy, nx, ny, p, occ, c)
        } else {
          ch_ray_bonus(st, c, t, fb, p, fx, fy, nx + dx, ny + dy, dx, dy, acc + ch_move_bonus(st, fx, fy, nx, ny, p, occ, c))
        }
      }
    }

    let ch_move_bonus(st: List<List<Int>>, fx: Int, fy: Int, tx: Int, ty: Int, p: Int, occ: Int, c: Int): Int {
      if (ch_gives_check(st, fx, fy, tx, ty, p, c)) {
        192 + ch_val8[ch_tp[occ]] + 2240
      } else {
        192 + ch_val8[ch_tp[occ]]
      }
    }

    let ch_type_credits(l: List<Int>, color: Int, t: Int): Int {
      ch_rng(9).reduceFrom(0) { (acc: Int, b: Int): Int => acc + l[b * 10 + color * 5 + t - 1] }
    }

    let ch_credit_total(l: List<Int>, color: Int, b: Int, acc: Int): Int {
      if (b > 8) { acc } else { ch_credit_total(l, color, b + 1, acc + ch_credits_on(l, b, color)) }
    }

    export let ch_cross_bonus(st: List<List<Int>>, m: List<Int>, color: Int): Int {
      if (m[7] != 1) {
        0
      } else if (ch_cross_checks(st, m, color)) {
        192 + ch_val8[ch_tp[m[6]]] + 2240
      } else {
        192 + ch_val8[ch_tp[m[6]]]
      }
    }

`crossing_checks?/3` moves only the piece (a promoting pawn is still a
pawn, a pawn taken en passant stays) and asks whether the opposing king on
the board it enters is then attacked.

    let ch_cross_checks(st: List<List<Int>>, m: List<Int>, color: Int): Boolean {
      ch_gives_check(st, m[1], m[2], m[3], m[4], m[5], color)
    }

    let ch_gives_check(st: List<List<Int>>, fx: Int, fy: Int, tx: Int, ty: Int, p: Int, color: Int): Boolean {
      let opp = 1 - color;
      let tb = ch_bdt[ty][tx];
      let i = (opp * 9 + tb) * 2;
      let kx = st[28][i];
      let ky = st[28][i + 1];
      if (kx < 0) {
        false
      } else if (kx == tx && ky == ty) {
        false
      } else if (ch_direct(st, tx, ty, ch_tp[p], color, kx, ky)) {
        true
      } else if (st[24][0] == opp && st[25][tb] != 1 + opp) {
        false
      } else {
        ch_attacked_v(st, kx, ky, color, fx, fy, tx, ty, ch_mv16[p], -1, -1)
      }
    }

Most of that is known without the full test. The piece left another
board, and attacks do not cross boards, so on the board it enters nothing
changed but the square it lands on. If it attacks the king from there, that
is check. If not, the only other way is a piece already attacking the king,
and whether one is, is known when the king's side is the one to move (the
board's status says check). Only otherwise is the whole board read.

    let ch_direct(st: List<List<Int>>, x: Int, y: Int, t: Int, color: Int, kx: Int, ky: Int): Boolean {
      let dx = kx - x;
      let dy = ky - y;
      if (t == 1) {
        if (dy != ch_fwd[color]) { false } else if (dx == 1) { true } else { dx == -1 }
      } else if (t == 2) {
        ch_knight_step(ch_abs(dx), ch_abs(dy))
      } else if (t == 4) {
        if (dx == 0 || dy == 0) { ch_clear(st, x + ch_sign(dx), y + ch_sign(dy), ch_sign(dx), ch_sign(dy), kx, ky) } else { false }
      } else if (t == 3) {
        if (ch_abs(dx) == ch_abs(dy)) { ch_clear(st, x + ch_sign(dx), y + ch_sign(dy), ch_sign(dx), ch_sign(dy), kx, ky) } else { false }
      } else if (t == 5) {
        if (dx == 0 || dy == 0 || ch_abs(dx) == ch_abs(dy)) { ch_clear(st, x + ch_sign(dx), y + ch_sign(dy), ch_sign(dx), ch_sign(dy), kx, ky) } else { false }
      } else {
        false
      }
    }

    let ch_abs(n: Int): Int { if (n < 0) { 0 - n } else { n } }

    let ch_knight_step(ax: Int, ay: Int): Boolean {
      if (ax == 1) { ay == 2 } else if (ax == 2) { ay == 1 } else { false }
    }

    let ch_clear(st: List<List<Int>>, x: Int, y: Int, dx: Int, dy: Int, kx: Int, ky: Int): Boolean {
      if (x == kx && y == ky) { true } else if (st[y][x] != 0) { false } else { ch_clear(st, x + dx, y + dy, dx, dy, kx, ky) }
    }

`leaf_score/2`: a finished match is worth 10000 either way, or nothing
drawn.

    export let ch_leaf(st: List<List<Int>>, color: Int): Int {
      if (ch_game_over(st)) {
        let w = ch_winner(st);
        if (w == "draw") { 0 } else if ((w == "white") == (color == 0)) { 320000 } else { -320000 }
      } else {
        ch_evaluate(st, color)
      }
    }

## The bot's search

`Bot.negamax/4`: alpha-beta over the 30 best-ordered legal moves at each
node. The Elixir starts from -10^15; nothing scores beyond a few hundred
thousand here, so -10^9 does the same and stays inside an Int.

    let ch_inf: Int = 1000000000;

`order_moves/2` sorts by a priority (ten times a capture's value, 25 more
for a crossing), largest first, keeping the generated order among equals;
here in quarters of a pawn. There are twelve priorities, so the sort is
twelve filters, and when nothing captures or crosses it is none.

    let ch_prio_of: List<Int> = [0, 40, 120, 130, 200, 360, 0];
    let ch_prios: List<Int> = [460, 360, 300, 230, 220, 200, 140, 130, 120, 100, 40];

    let ch_priority(m: List<Int>): Int { ch_prio_of[ch_tp[m[6]]] + m[7] * 100 }

    let ch_ordered(ms: List<List<Int>>, n: Int): List<List<Int>> {
      let loud = ms.filter { (m): Boolean => ch_priority(m) > 0 };
      if (loud.isEmpty) {
        ch_take(ms, n)
      } else {
        let quiet = ms.filter { (m): Boolean => ch_priority(m) == 0 };
        let by = ch_prios.map { (v): List<List<Int>> => loud.filter { (m): Boolean => ch_priority(m) == v } };
        ch_take(ch_cat(ch_flat(by), quiet), n)
      }
    }

    export let ch_negamax(st: List<List<Int>>, depth: Int, alpha: Int, beta: Int): Int {
      let c = st[24][0];
      if (depth <= 0) {
        ch_leaf(st, c)
      } else if (ch_game_over(st)) {
        ch_leaf(st, c)
      } else {
        let moves = ch_legal_moves(st);
        if (moves.isEmpty) {
          ch_leaf(st, c)
        } else {
          ch_search(st, ch_ordered(moves, 30), 0, depth, beta, alpha, 0 - ch_inf)
        }
      }
    }

    let ch_search(st: List<List<Int>>, ms: List<List<Int>>, i: Int, depth: Int, beta: Int, a: Int, best: Int): Int {
      if (i >= ms.length) {
        best
      } else {
        let score = 0 - ch_negamax(ch_apply(st, ms[i]), depth - 1, 0 - beta, 0 - a);
        let nb = if (score > best) { score } else { best };
        let na = if (nb > a) { nb } else { a };
        if (na >= beta) { nb } else { ch_search(st, ms, i + 1, depth, beta, na, nb) }
      }
    }

`score_root/2`'s two scores for a root move: the shallow one every legal
move gets (the position after it, from the mover's side), and the deep one
the best twelve of those get (`-negamax` of the position after it). The
root loop, its sort and the random pick among the best are Blimp's, so the
browser can do them a move at a time.

    export let ch_shallow(st: List<List<Int>>, m: List<Int>): Int {
      ch_evaluate(ch_apply(st, m), st[24][0])
    }

    export let ch_deep(st: List<List<Int>>, m: List<Int>, depth: Int): Int {
      0 - ch_negamax(ch_apply(st, m), depth - 1, 0 - ch_inf, ch_inf)
    }

## What the page shows

`ChessLive`'s template helpers: the glyph for a piece, a square's colour
(light when its local file and rank add up even), a frozen board's label,
and the match result's banner.

    let ch_glyphs: List<String> = ["", "♙", "♘", "♗", "♖", "♕", "♔", "", "", "♟", "♞", "♝", "♜", "♛", "♚", ""];

    export let ch_glyph(p: Int): String { ch_glyphs[ch_nm[p]] }

    export let ch_piece_class(p: Int): String {
      if (ch_cl[p] == 0) { "sq-piece piece-white" } else { "sq-piece piece-black" }
    }

    let ch_light: List<Boolean> = [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true];

    export let ch_square_bg(x: Int, y: Int): String {
      if (ch_light[ch_l8[x] + ch_l8[y]]) { "background:#F0D9B5;" } else { "background:#B58863;" }
    }

`board_status_label/1`, for a frozen board only (the template shows no
label on one that is merely in check).

    export let ch_status_label(s: Int): String {
      if (s == 3) {
        "white wins"
      } else if (s == 4) {
        "black wins"
      } else if (s == 5) {
        "stalemate"
      } else if (s == 6) {
        "draw (fifty_move)"
      } else if (s == 7) {
        "draw (insufficient_material)"
      } else {
        ""
      }
    }

    export let ch_banner_class(st: List<List<Int>>): String {
      let w = ch_winner(st);
      if (w == "white") { "game-over-banner game-over-white" } else if (w == "black") { "game-over-banner game-over-black" } else { "game-over-banner game-over-draw" }
    }

    export let ch_banner_text(st: List<List<Int>>): String {
      let w = ch_winner(st);
      if (w == "white") { "WHITE WINS the match!" } else if (w == "black") { "BLACK WINS the match!" } else { "MATCH DRAWN" }
    }
