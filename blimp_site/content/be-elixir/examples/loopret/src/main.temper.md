# loop returns

    export let find(xs: List<Int>, want: Int): Int {
      for (var i = 0; i < xs.length; ++i) {
        if (xs[i] == want) { return i; }
      }
      -1
    }

    export let firstBig(xs: List<Int>): Int? {
      for (var q = 0; q < xs.length; ++q) { let x = xs[q];
        if (x > 10) { return x; }
      }
      null
    }

    export let pairSum(xs: List<Int>, t: Int): String {
      var n = 0;
      for (var i = 0; i < xs.length; ++i) {
        for (var j = i + 1; j < xs.length; ++j) {
          n += 1;
          if (xs[i] + xs[j] == t) { return "${i},${j} after ${n}"; }
        }
      }
      "none after ${n}"
    }

    export let skipping(xs: List<Int>): Int {
      var s = 0;
      var i = 0;
      outer: while (i < xs.length) {
        let x = xs[i];
        i += 1;
        if (x < 0) { continue; }
        if (x == 0) { break; }
        if (x > 100) { return -x; }
        s += x;
      }
      s * 10 + i
    }

    export let labeled(xs: List<Int>): Int {
      var count = 0;
      rows: for (var i = 0; i < 3; ++i) {
        for (var j = 0; j < xs.length; ++j) {
          if (xs[j] == i) { continue rows; }
          if (xs[j] == 9) { return 900 + count; }
          count += 1;
        }
      }
      count
    }

    export let after(xs: List<Int>): Int {
      var t = 0;
      for (var q = 0; q < xs.length; ++q) { let x = xs[q]; if (x == 7) { return 7; }
        t += x; }
      var u = t;
      while (u > 5) { u -= 5; if (u == 6) { return 66; }
      }
      u
    }

    export class Finder(public xs: List<String>) {
      public index(s: String): Int {
        var i = 0;
        while (i < xs.length) {
          if (xs[i] == s) { return i; }
          i += 1;
        }
        -1
      }
    }

    export let viaClosure(xs: List<Int>): Int {
      var hits = 0;
      let f(x: Int): Int {
        for (var k = 0; k < x; ++k) { if (k * k == x) { return k; } }
        0
      }
      for (var q = 0; q < xs.length; ++q) { let x = xs[q]; hits += f(x); }
      hits
    }

    export let midIf(xs: List<Int>, flag: Boolean): Int {
      var r = 0;
      if (flag) {
        for (var q = 0; q < xs.length; ++q) { let x = xs[q]; if (x == 3) { return 333; }
        r += x; }
        r += 1000;
      }
      r
    }

    export let intOr(s: String, d: Int): Int {
      return s.toInt32() orelse d;
    }

    export let sign(n: Int): String {
      if (n < 0) { return "neg"; }
      if (n == 0) { return "zero"; }
      "pos"
    }

    let same(test: Test, got: String, want: String): Void {
      assert(got == want) { "got ${got}, want ${want}" }
    }

    test("loop returns") { test =>
      let data = [1, 5, 3, 12, 0, 7];
      same(test, "${find(data, 3)} ${find(data, 4)}", "2 -1");
      same(test, "${firstBig(data) ?? -1} ${firstBig([1]) ?? -1}", "12 -1");
      same(test, "${pairSum(data, 15)} | ${pairSum(data, 100)}", "2,3 after 10 | none after 15");
      same(test, "${skipping([1, -2, 3, 0, 5])} ${skipping([1, 200, 3])} ${skipping([4, 4])}", "44 -200 82");
      same(test, "${labeled([5, 1, 2])} ${labeled([5, 9])} ${labeled([0, 1, 2])}", "6 901 3");
      same(test, "${after([1, 7])} ${after([10, 3])} ${after([1, 2])}", "7 3 3");
      same(test, "${new Finder(["a", "b"]).index("b")} ${new Finder(["a"]).index("z")}", "1 -1");
      same(test, "${intOr("12", 0)} ${intOr("x", 7)} ${sign(-2)} ${sign(0)} ${sign(5)}", "12 7 neg zero pos");
      same(test, "${viaClosure([4, 9, 5])}", "5");
      same(test, "${midIf([1, 3], true)} ${midIf([1, 2], true)} ${midIf([1, 3], false)}", "333 1003 0");
    }
