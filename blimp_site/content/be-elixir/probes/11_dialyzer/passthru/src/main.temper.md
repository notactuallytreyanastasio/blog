# passthru

A function that hands back the list it was given.

    export let nonEmpty(xs: List<Int>): List<Int>? {
      if (xs.length > 0) { xs } else { null }
    }

    export let same(xs: List<Int>): List<Int> { xs }

    export let firstOr(xs: List<Int>, d: Int): Int {
      if (xs.length > 0) { xs[0] } else { d }
    }
