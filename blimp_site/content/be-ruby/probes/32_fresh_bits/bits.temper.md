# Bits and deques

    let show(label: String, value: String): Void { console.log("${label}: [${value}]"); }

    let v = new DenseBitVector(0);
    v.set(1000, true);
    show("set 1000 on an empty vector, get 1000", v.get(1000).toString());
    let w = new DenseBitVector(16);
    w.set(200, true);
    show("set 200 on a 16-bit vector, get 200", w.get(200).toString());
    w.set(100, true);
    show("then set 100, get 100", w.get(100).toString());
    show("get -1", w.get(-1).toString());

    let d = new Deque<Int>();
    show("removeFirst on empty", do { d.removeFirst().toString() } orelse "bubble");
