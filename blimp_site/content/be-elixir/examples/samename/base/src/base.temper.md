# base

A class named `Foo`, and a function that makes one.

    export class Foo(public x: Int) {
      public doubled(): Int { x * 2 }
    }
    export let makeFoo(): Foo { new Foo(42) }
