# What a test of constants reaches

    export let isSpace(c: Int): Boolean { c == 32 || (c >= 9 && c <= 13) }
    export let sumTo(n: Int): Int {
      var s = 0;
      for (var i = 0; i < n; ++i) { s += i; }
      s
    }
    @imu export class P(public n: Int) {}
    export let mk(n: Int): P { new P(n) }
    export let cut(t: String): List<String> {
      let out = new ListBuilder<String>();
      out.add(t);
      out.toList()
    }

Each of the first two becomes `assert(test, true, ...)`: the frontend ran
the call. The last two reach the generated code, because the call makes an
object, which stops the evaluation.

    test("constants") {
      assert(isSpace(32));
      assert(sumTo(4) == 6);
      assert(mk(3).n == 3);
      assert(cut("abc").length == 1);
    }
