# shapes

    export interface Shape { public area(): Float64; }
    @imu export class Square(public side: Float64) extends Shape {
      public area(): Float64 { side * side }
    }
    export class Stack {
      public var items: ListBuilder<Int> = new ListBuilder<Int>();
      public push(x: Int): Void { items.add(x) }
      public size(): Int { items.length }
    }
    @actor export class Tally {
      public var n: Int = 0;
      public add(k: Int): Int { n += k; n }
    }
    export let unit = new Square(1.0);
    export let tally = new Tally();
    export let total(shapes: List<Shape>): Float64 {
      var sum = 0.0;
      for (var i = 0; i < shapes.length; ++i) { sum += shapes[i].area(); }
      sum
    }
