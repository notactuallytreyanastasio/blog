# A null assigned in a loop

    for (var i = 0; i < 3; i += 1) {
      let x: Int? = if (i == 0) { 5 } else { null };
      console.log("x is ${(x ?? -1).toString()}");
    }
