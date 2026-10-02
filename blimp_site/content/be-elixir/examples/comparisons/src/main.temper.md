# Comparisons after #494

    var s = "abc";
    s = s;
    var n = 5i64;
    n = n;
    var t = true;
    t = t;
    var z = 0.0;
    z = z;
    var o: String? = "x";
    o = o;

    export let compare(): String {
      let negZ = -z;
      "${s < "abd"} ${n <= 4i64} ${t > false} ${negZ >= z} ${z >= negZ} ${s < "ab"} ${o != null} ${s == "abd"}"
    }

    @imu class V(public x: Int) {}
    export let same(k: Int): Boolean { new V(k) == new V(k) }

    console.log(compare());
