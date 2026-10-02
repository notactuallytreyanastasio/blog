# user

A different class also named `Foo`. The `Foo` that `makeFoo` returns is
base's, so reading `x` and calling `doubled` must go to base's module.

    let { makeFoo } = import("base/src");
    export class Foo(public y: Int) {}

    let theirs = makeFoo();
    console.log("theirs.x=${theirs.x.toString()} doubled=${theirs.doubled().toString()}");
    console.log("mine.y=${new Foo(1).y.toString()}");
