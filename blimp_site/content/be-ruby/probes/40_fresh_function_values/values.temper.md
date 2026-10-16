# Functions used as values, not in the suite

    let {oneOrMore, entire, RegexNode, CodeSet, CodePoints, Repeat} = import("std/regex");
    let {parseJson, JsonSyntaxTree, JsonArray} = import("std/json");

    let show(label: String, value: String): Void { console.log("${label}: [${value}]"); }

    let identity<T>(x: T): T { x }
    let repeat<A>(a: A, n: Int): List<A> {
      let out = new ListBuilder<A>();
      for (var i = 0; i < n; ++i) { out.add(a); }
      out.toList()
    }
    let double(n: Int): Int { n * 2 }
    let greet(name: String, punctuation: String = "!"): String { "hello ${name}${punctuation}" }
    let apply(f: fn (Int): Int, n: Int): Int { f(n) }
    let applyTwice<T>(f: fn (T): T, x: T): T { f(f(x)) }
    let firstOk(f: fn (String): Int throws Bubble, inputs: List<String>): Int {
      for (var i = 0; i < inputs.length; ++i) {
        let r = f(inputs[i]) orelse continue;
        return r;
      }
      -1
    }
    let parseOrBubble(s: String): Int throws Bubble { s.toInt32() }

    show("module function", apply(double, 21).toString());
    let ints: fn (Int): Int = identity<Int>;
    show("generic as Int", ints(5).toString());
    let strs: fn (String): String = identity<String>;
    show("generic as String", strs("s"));
    show("generic passed", applyTwice(identity<Int>, 9).toString());
    let rep: fn (String, Int): List<String> = repeat<String>;
    show("generic of two", rep("ab", 3).join(", ") { (s: String): String => s });
    show("generic into map", ([4, 5].map(identity<Int>)).join(",") { (i: Int): String => i.toString() });
    let twice: fn (Int): Int = double;
    show("same value twice", (apply(twice, 1) + apply(double, 2)).toString());
    let g: fn (String, String): String = greet;
    show("defaulted parameter", g("you", "?"));
    show("bubbling", firstOk(parseOrBubble, ["x", "", "42", "7"]).toString());
    show("bubbling, none parse", firstOk(parseOrBubble, ["x"]).toString());
    let wrap: fn (RegexNode): RegexNode = entire;
    show("other library", do { wrap(oneOrMore(new CodeSet([new CodePoints("ab")]))).compiled().find("abba").full.value } orelse "no match");
    show("other library, defaulted", (["ab", "c"].map { (s: String): Repeat => oneOrMore(new CodePoints(s)) }).length.toString());
    let parse: fn (String): JsonSyntaxTree throws Bubble = parseJson;
    let tree = parse("[1, 2]") orelse panic();
    show("other library, bubbling", (tree is JsonArray).toString());
    let parsed = (["[]", "{", "3"].map { (s: String): Boolean => do { parse(s); true } orelse false }).join(",") { (b: Boolean): String => b.toString() };
    show("other library, bubbling, mapped", parsed);
    var counter = 0;
    let bump(): Int { counter += 1; counter }
    let bumper: fn (): Int = bump;
    bumper(); bumper();
    show("closure over a var", counter.toString());
    let k = 10;
    let addK(n: Int): Int { n + k }
    show("local function over a let", apply(addK, 5).toString());
