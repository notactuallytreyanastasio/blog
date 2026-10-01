# app

    let { Shape, Square, Stack, unit, tally, total } = import("shapes/src");
    let s: Shape = new Square(3.0);
    let st = new Stack();
    st.push(1); st.push(2);
    tally.add(5);
    console.log("total=${total([s, unit])} isSquare=${s is Square} stack=${st.size()} tally=${tally.add(1)}");
