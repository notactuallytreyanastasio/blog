# shelf

    /** Clamps a count to zero or more. */
    let clamp(n: Int): Int { if (n < 0) { 0 } else { n } }

    let label(n: Int): String { "#${n.toString()}" }

    /**
     * A shelf holds a number of books.
     *
     * Use `"""` sparingly, and `\n` and `#{x}` mean nothing here.
     */
    export class Shelf(public books: Int) {
      /** The shelf with [k] more books, never fewer than none. */
      public add(k: Int): Shelf { new Shelf(clamp(books + k)) }
      public describe(): String { label(books) }
    }

    /** A shelf of [n] books, or of none if [n] is negative. */
    export let shelfOf(n: Int): Shelf { new Shelf(clamp(n)) }

    export let total(xs: List<Int>): Int {
      xs.reduceFrom(0, fn (a: Int, b: Int): Int { clamp(a) + clamp(b) })
    }

    /** Rounds down to a multiple of ten. */
    let tens(n: Int): Int { n - n % 10 }

    /** A shelf of [n] books, rounded down to tens. */
    export let shelfOfTens(n: Int): Shelf { new Shelf(tens(clamp(n))) }
