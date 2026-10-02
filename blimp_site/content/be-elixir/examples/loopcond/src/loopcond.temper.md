# Loops the frontend runs while compiling

Each function is called with constants only, so the frontend evaluates the
call while it compiles. On Temper without
[notactuallytreyanastasio/temper#6](https://github.com/notactuallytreyanastasio/temper/pull/6)
any one of the three loops below stops the build with
`IndexOutOfBoundsException: Index -1 out of bounds for length 0`.

A condition that really does bubble: `"abc".toInt32()` fails.

    let countBelow(s: String): Int throws Bubble {
      var i = 0;
      while (i < s.toInt32()) { i += 1; }
      i
    }

A condition that cannot bubble at all. Early in compiling, the frontend
cannot yet evaluate this `!=`, and says so with a failure of its own.

    let countTo(limit: Int): Int {
      var n = 0;
      while (n != limit) { n += 1; }
      n
    }

The shape that stopped Marginalia's build: a guarded index, so `s[b]` is
only read where it exists.

    let isSpace(cp: Int): Boolean { cp == 32 || (cp >= 9 && cp <= 13) }

    let leadingSpaces(s: String): Int {
      var b = String.begin;
      var n = 0;
      while (s.hasIndex(b) && isSpace(s[b])) { n += 1; b = s.next(b); }
      n
    }

    console.log("countBelow=${countBelow("abc") orelse -1}");
    console.log("countTo=${countTo(2)}");
    console.log("leadingSpaces=${leadingSpaces("  ab")}");
