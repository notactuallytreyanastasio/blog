# Strings, edge cases not in the suite

    let show(label: String, value: String): Void { console.log("${label}: [${value}]"); }

    let joined(parts: List<String>): String { parts.join("|") { (p: String): String => p } }

    show("split a,,b,", joined("a,,b,".split(",")));
    show("split ,", joined(",".split(",")));
    show("split abab by ab", joined("abab".split("ab")));
    show("split κό by empty", joined("κό".split("")));
    show("split 🌍x🌍 by x", joined("🌍x🌍".split("x")));

    let walk(s: String): Void {
      var i = String.begin;
      let out = new StringBuilder();
      while (s.hasIndex(i)) {
        out.append(s[i].toString(16));
        out.append(" ");
        i = s.next(i);
      }
      var back = s.end;
      var n = 0;
      while (back > String.begin) {
        back = s.prev(back);
        n += 1;
      }
      show("walk ${s}", "${out.toString()}/ back ${n.toString()} / count ${s.countBetween(String.begin, s.end).toString()}");
    }
    walk("κόσμε𐆊");
    walk("");
    walk("a🌍b");

    let found(hay: String, needle: String): Void {
      let i = hay.indexOf(needle);
      when (i) {
        is StringIndex -> show("indexOf ${needle} in ${hay}", hay.slice(i, hay.end));
        else -> show("indexOf ${needle} in ${hay}", "none");
      }
    }
    found("naïve café", "café");
    found("naïve café", "e");
    found("naïve café", "x");
    found("", "");
    found("abc", "");

    let int(s: String): Void { show("toInt32 ${s}", s.toInt32().toString() orelse "bubble"); }
    int("+5"); int("-0"); int("007"); int(" 7 "); int(""); int("1e3"); int("-2147483648"); int("2147483648"); int("٣");

    let hex(s: String): Void { show("toInt32 ${s} radix 16", s.toInt32(16).toString() orelse "bubble"); }
    hex("FF"); hex("ff"); hex("-7fffffff"); hex("0x10"); hex("g");

    let flt(s: String): Void { show("toFloat64 ${s}", s.toFloat64().toString() orelse "bubble"); }
    flt("1e3"); flt("-0"); flt("1E+2"); flt("1."); flt(".5"); flt(" 2.5 "); flt("NaN"); flt("-Infinity"); flt("1e400"); flt("0.1");

    let sb = new StringBuilder();
    sb.append("héllo");
    let mid = sb.end;
    sb.appendCodePoint(0x1F30D) orelse panic();
    sb.appendBetween("xyz", "xyz".next(String.begin), "xyz".end);
    let built = sb.toString();
    sb.clear();
    sb.append("again");
    show("builder", "${built} / ${built.slice(String.begin, mid)} / ${sb.toString()}");

    let sortedWords = ["éclair", "zebra", "Zebra", "apple", "Äpfel", ""].sorted { (a: String, b: String): Int => if (a < b) { -1 } else if (b < a) { 1 } else { 0 } };
    show("sorted", joined(sortedWords));
    show("less", "${"a" < "b"} ${"é" < "z"} ${"Z" < "a"} ${"" < "a"}");
    show("empty", "${"".isEmpty} ${" ".isEmpty}");
