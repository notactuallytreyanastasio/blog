# M

    let a(inputs: List<String>): Int {
      for (var i = 0; i < inputs.length; ++i) {
        if (inputs[i] == "") { continue; }
        return i;
      }
      -7
    }
    let b(inputs: List<String>): Int {
      for (var i = 0; i < inputs.length; ++i) {
        if (inputs[i] == "") { continue; }
        return i;
      }
      42
    }
    let c(inputs: List<String>): Int {
      for (var i = 0; i < inputs.length; ++i) {
        if (inputs[i] == "") { break; }
        return i;
      }
      -7
    }
    let d(inputs: List<String>): Int {
      for (var i = 0; i < inputs.length; ++i) {
        if (inputs[i] == "") { continue; }
      }
      -7
    }
    console.log("a: [${a([""]).toString()}]");
    console.log("b: [${b([""]).toString()}]");
    console.log("c: [${c([""]).toString()}]");
    console.log("d: [${d([""]).toString()}]");
