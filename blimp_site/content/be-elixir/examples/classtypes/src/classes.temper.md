# classes

    export interface Shape { public area(): Float64; }

    export class Counter {
      public var count: Int = 0;
      public bump(): Void { count += 1; }
    }

    export class Square(public side: Float64) extends Shape {
      public area(): Float64 { side * side }
    }

    @actor export class Tally {
      public var n: Int = 0;
      public add(k: Int): Int { n += k; n }
    }

    export let fresh(): Int {
      let c = new Counter();
      c.bump();
      c.count
    }
