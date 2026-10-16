# Dates, edge cases not in the suite

    let {Date} = import("std/temporal");

    let show(label: String, value: String): Void { console.log("${label}: [${value}]"); }

    let make(y: Int, m: Int, d: Int): Void {
      show("new Date(${y.toString()}, ${m.toString()}, ${d.toString()})",
        do { let date = new Date(y, m, d); "${date.toString()} weekday ${date.dayOfWeek.toString()}" } orelse "bubble");
    }
    make(12, 11, 10);
    make(1, 1, 1);
    make(1500, 2, 29);
    make(1582, 10, 10);
    make(1600, 2, 29);
    make(1900, 2, 29);
    make(2023, 6, -1);
    make(2023, -1, 1);
    make(2023, 0, 1);
    make(2023, 4, 31);
    make(12345, 1, 2);

    let parse(s: String): Void {
      show("fromIsoString ${s}", do { Date.fromIsoString(s).toString() } orelse "bubble");
    }
    parse("1596-03-31");
    parse("0012-11-10");
    parse("96-03-31");
    parse("15960331");
    parse("1596-091");
    parse("+1596-03-31");
    parse(" 1596-03-31");
    parse("1596-03-31 ");
    parse("12345-01-02");
    parse("1596-3-31");
    parse("1596-03-3");
    parse("1596-02-30");
    parse("١٥٩٦-03-31");

    let between(a: String, b: String): Void {
      show("yearsBetween ${a} ${b}", do {
        Date.yearsBetween(Date.fromIsoString(a), Date.fromIsoString(b)).toString()
      } orelse "bubble");
    }
    between("2020-02-29", "2021-02-28");
    between("2020-02-29", "2021-03-01");
    between("2012-03-21", "2010-03-21");
