# Maps, edge cases not in the suite

    let show(label: String, value: String): Void { console.log("${label}: [${value}]"); }

    let keysOf(m: Mapped<String, Int>): String {
      m.toListWith { (k: String, v: Int): String => "${k}=${v.toString()}" }.join(" ") { (s: String): String => s }
    }

    let dup = new Map([new Pair("a", 1), new Pair("b", 2), new Pair("a", 3)]);
    show("duplicate keys in constructor", keysOf(dup));
    show("duplicate keys length", dup.length.toString());

    let b = new MapBuilder<String, Int>();
    b["x"] = 1;
    b["y"] = 2;
    b["z"] = 3;
    b["x"] = 10;
    show("overwrite keeps place", keysOf(b));
    b.remove("x") orelse void;
    b["x"] = 100;
    show("remove then set moves to end", keysOf(b));

    show("get missing", do { b["nope"].toString() } orelse "bubble");
    show("remove missing", do { b.remove("nope").toString() } orelse "bubble");
    show("remove returns", do { b.remove("y").toString() } orelse "bubble");
    show("after remove", keysOf(b));

    let keys = b.keys();
    let values = b.values();
    let frozen = b.toMap();
    b["w"] = 4;
    show("keys() after a later set", keys.join(" ") { (s: String): String => s });
    show("values() after a later set", values.join(" ") { (n: Int): String => n.toString() });
    show("toMap() after a later set", keysOf(frozen));

    let nullable = new MapBuilder<String, String?>();
    nullable["n"] = null;
    show("has key with null value", nullable.has("n").toString());
    show("getOr key with null value", nullable.getOr("n", "fallback") ?? "null");
    show("get key with null value", do { nullable["n"] ?? "null" } orelse "bubble");
    show("remove key with null value", do { nullable.remove("n") ?? "null" } orelse "bubble");
    show("length after", nullable.length.toString());

    let accents = new Map([new Pair("é", 1), new Pair("é", 2), new Pair("", 3)]);
    show("composed and decomposed are two keys", accents.length.toString());
    show("empty string key", accents[""].toString() orelse "bubble");

    let ints = new Map([new Pair(-1, "minus"), new Pair(0, "zero"), new Pair(2147483647, "max")]);
    show("int keys", ints.toListWith { (k: Int, v: String): String => "${k.toString()}:${v}" }.join(" ") { (s: String): String => s });

    let grow = new MapBuilder<String, Int>();
    grow["a"] = 1;
    show("set existing during forEach", do {
      grow.forEach { (k: String, v: Int): Void => grow[k] = v + 1; };
      keysOf(grow)
    } orelse "bubble");
    show("remove during forEach", do {
      let shrink = new MapBuilder<String, Int>();
      shrink["a"] = 1;
      shrink["b"] = 2;
      var seen = 0;
      shrink.forEach { (k: String, v: Int): Void => seen += 1; shrink.remove("b") orelse void; };
      "${keysOf(shrink)} seen ${seen.toString()}"
    } orelse "bubble");

    let copy = b.toMapBuilder();
    copy["only in copy"] = 0;
    show("toMapBuilder copies", "${b.length.toString()} ${copy.length.toString()}");
    show("pairs", b.toList().map { (p: Pair<String, Int>): String => "(${p.key},${p.value.toString()})" }.join("") { (s: String): String => s });
