# Async and generators, ordering not in the suite

    let show(label: String): Void { console.log("[${label}]"); }

    let gate = new PromiseBuilder<Int>();
    async { (): GeneratorResult<Empty> extends GeneratorFn =>
      show("first waiter starts");
      let n = await gate.promise orelse -1;
      show("first waiter got ${n.toString()}");
    }
    async { (): GeneratorResult<Empty> extends GeneratorFn =>
      show("second waiter starts");
      let n = await gate.promise orelse -1;
      show("second waiter got ${n.toString()}");
    }
    show("top level after launching both");
    gate.complete(7);
    show("top level after completing");

    let chain = new PromiseBuilder<String>();
    async { (): GeneratorResult<Empty> extends GeneratorFn =>
      show("outer starts");
      async { (): GeneratorResult<Empty> extends GeneratorFn =>
        show("inner starts");
        chain.complete("from inner");
        show("inner ends");
      }
      show("outer after inner, ${await chain.promise orelse "broken"}");
    }
    show("top level after outer");

    let broken = new PromiseBuilder<Int>();
    async { (): GeneratorResult<Empty> extends GeneratorFn =>
      let n = await broken.promise orelse -2;
      show("broken gave ${n.toString()}");
    }
    broken.breakPromise();
    show("top level after breaking");

    let count(body: fn (): SafeGenerator<Empty>): Void {
      let g = body();
      for (var step = 0; step < 4; step += 1) {
        let result = g.nextSafe();
        let kind = when (result) {
          is ValueResult -> "value";
          else -> "done";
        };
        show("step ${step.toString()}: ${kind}, done is ${g.done.toString()}");
      }
    }
    count { (): GeneratorResult<Empty> extends GeneratorFn =>
      show("gen a");
      yield();
      show("gen b");
    }
