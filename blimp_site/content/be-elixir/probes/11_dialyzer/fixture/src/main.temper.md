# fixture

ElixirTypespecTest's FIXTURE at 94efe3e0, plus one null check (`orEmpty`).

    export interface Shape { public area(): Float64; }

    @imu export class Point(public x: Int, public y: Int) {
      public plus(o: Point): Point { new Point(x + o.x, y + o.y) }
      public static origin(): Point { new Point(0, 0) }
    }

    export class Counter {
      public var count: Int = 0;
      public bump(): Void { count += 1; }
    }

    @actor export class Tally {
      public var n: Int = 0;
      public add(k: Int): Int { n += k; n }
    }

    export class Square(public side: Float64) extends Shape {
      public area(): Float64 { side * side }
    }

    export class Box<T>(public item: T) {
      public get(): T { item }
    }

    export let total(xs: List<Int>): Int {
      var t = 0;
      for (let x of xs) { t += x; }
      t
    }

    export let lookup(m: Map<String, Int>, k: String): Int { m.getOr(k, -1) }

    export let firstOrNull(xs: List<String>): String? {
      if (xs.length > 0) { xs[0] } else { null }
    }

    export let greet(name: String, greeting: String = "hi"): String { "${greeting} ${name}" }

    export let twice(f: fn (Int): Int, x: Int): Int { f(f(x)) }

    export let half(n: Int): Int throws Bubble {
      if (n % 2 != 0) { bubble() }
      n / 2
    }

    export let big(n: Int64): Int64 { n * 2i64 }

    export let flip(b: Boolean): Boolean { !b }

    export let pairs(k: String, v: Int): List<Pair<String, Int>> { [new Pair(k, v)] }

    export let shout(s: String): String {
      let sb = new StringBuilder();
      sb.append(s);
      sb.append("!");
      sb.toString()
    }

    export let upTo(n: Int): List<Int> {
      let b = new ListBuilder<Int>();
      for (var i = 0; i < n; ++i) { b.add(i); }
      b.toList()
    }

    export let contains(s: String, t: String): Boolean { s.indexOf(t) is StringIndex }

    export let areas(shapes: List<Shape>): Float64 {
      var a = 0.0;
      for (let s of shapes) { a += s.area(); }
      a
    }

    let wrap(n: Int): List<Int>? { if (n > 0) { [n] } else { null } }

    export let orEmpty(n: Int): List<Int> { wrap(n) ?? [] }

