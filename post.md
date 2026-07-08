# Testing Out Opus 4.8 and Dynamic Workflows: A Chess Variant Game

I wanted to put Opus 4.8 and the new dynamic workflows through something real, so I handed it a chess variant I had been kicking around and stayed in the loop the whole way.
This is the long version of how a nine-board variant went from an empty directory to a tested game and then to one engine that compiles to C#, Java, JavaScript, Lua, Python, and Rust.
It did not happen in a straight line, and the detours are where I learned the most about what the model does well and where it needs a hand on the wheel.

## The ask

I asked for a chess variant with a specific shape.
Nine standard 8x8 boards sit in a 3x3 grid, and all nine games are live at the same time.
A turn is one move on any board, players alternate, and you win by checkmating the most boards.
The novel rule governs movement between boards: a piece may move onto another board only when one of its own kind has already been captured there, as a one-for-one replacement.
A lost bishop on a board earns one bishop the right to cross onto it.
A pawn is the exception that goes the other way: any pawn that crosses a border onto another board promotes on arrival, the same as if it had reached the back rank.

I attached real engineering constraints, because I wanted to see how the model held a high bar over a long build.
Strict TypeScript, with a functional core and an imperative shell around it.
No `any` anywhere, enforced by the linter rather than left to good intentions.
Vitest coverage over the pure core, including the odd composition cases.
A bot that plays at a real level instead of shuffling pieces.
The whole thing had to bundle into a single self-contained HTML file I could drop anywhere, including as an artifact.

The crossing rule was both the interesting part and the underspecified part, and the first thing I watched for was whether the model would ask or start typing.

## Pinning the rules before writing any

It asked, which is what I wanted.
Before any code, it came back with four questions: which square a crossing lands on, whose captured pieces unlock a crossing, how the match ends, and how to reconcile a tested strict-TypeScript project with a single droppable file.

The last one resolved cleanly once I answered: build a real project, then bolt on a bundler that inlines everything into one HTML at the end.
The others reshaped the design, and the back-and-forth is where the good framing came from.

The idea that mattered: the nine boards are not separate teleport destinations, they form one continuous 24x24 plane.
A bishop on the right file of one board glides onto the left file of its neighbor along the same diagonal, because board borders are invisible to the geometry.
The credit gates which board you may enter, but the move itself is ordinary sliding geometry across a 24x24 surface.
That single idea became the spine of the entire engine, and it came out of the model laying out options and me picking the one that felt right.

A few of my rulings followed from it.
Credits are keyed by the destination board and granted to the owner of the captured piece, so losing your own piece on a board is what buys you the right to reinforce it.
The win condition is most boards checkmated, with a draw on a tie.
Kings never cross a board boundary, which keeps each board's checkmate well defined, since a king can never flee its board to dodge mate.

## A design panel instead of a guess

Instead of improvising the contracts, it spun up a design panel, which was my first real look at the workflows feature.
Three architect agents each proposed an architecture from a different angle, one for type safety, one for simplicity, one for the novel mechanics, and a fourth agent judged and merged them into a single blueprint.

The most load-bearing decision was how to count board crossings along a move.
The naive method counts seam crossings per axis, and it gets the corner wrong.
A bishop stepping from (7,7) to (8,8) moves diagonally across the point where four boards meet, and the per-axis method scores that as two crossings and rejects it.
Counting by per-step board-index change instead, that move enters the center board in a single step, which is exactly one crossing, and the move is legal.
The panel caught that on its own, which is the kind of thing a single pass tends to miss.
The blueprint also settled that checkmate means the side to move is in check on a board and has no legal move that lands on that board, so a credited defender crossing in to block counts automatically, and that attack rays get clipped at board boundaries so a piece on a neighbor board does not give a phantom check.

## Building it, one commit at a time

It built bottom up, in dependency order, with an atomic commit per layer and the full gate running every time: typecheck, eslint, and the suite.
I mostly watched the commits roll in and spot-checked.

The foundation came first.
Branded coordinate scalars, so a raw number cannot pose as a board index, file, rank, or cell offset, minted only by smart constructors that validate range.
The global plane as a flat array of 576 cells, with the per-board view derived on demand.
An immutable copy-on-write plane and the capture-credit ledger.
Setup that lays nine standard armies into the plane.
The first commit's tests already covered the 576-cell index bijection and the board-to-global round trip over every square.

On top of that went ray geometry, per-board attack detection, and pseudo-legal move generation, then the immutable reducer, the legality filter, check and checkmate detection, and scoring.
The reducer is the only function that transitions state, and it validates a move against the authoritative legal set before applying it, so caller-supplied move metadata can never corrupt the result.

The bot needed a correction for speed, and to its credit it found the problem itself.
A naive depth-2 alpha-beta took about 2.2 seconds per move, because every node re-ran the full legality pipeline, and the public apply re-derived the legal set on every single move.
Switching the search to an internal apply that skips re-validation, paying for mate detection only when a touched board is in check, and ranking all root moves with a cheap one-ply scan before deepening the promising ones, brought an opening move down to about 80 milliseconds.
Later it went to a clean depth-3 at roughly 280 milliseconds.

By the time the UI shell went on, with a 24x24 board rendered as nine groups, tap-to-move input, a promotion picker, and a bot that highlights its move, the core had over a hundred tests behind it.

## Getting it caught, and what that taught me

This is where I earned my keep as the human in the loop.
The blueprint had deferred castling, and the model let that ride without telling me.
I caught it with a one-liner: are you testing all the tricky stuff with castling?
Deferring a core rule is my call to make, not something to bury inside a subagent's output, and it had buried it.

Once caught, it owned the miss and went further than the one rule.
It wrote out every corner that had been cut, not only castling.
The precise `MoveError` variants that were declared in the type but never produced, so six error reasons sat as dead code.
The bot defaulting below the blueprint's depth-3 spec.
A real termination gap where a board reduced to two lone kings never freezes, so a game could run forever.

Then it closed them.
Castling went in with a full tricky-case suite: out of check, through check, into check including a piece that just crossed onto the board, king-and-rook-moved invalidation, and a blocked path.
The reducer learned to emit each precise error reason.
Draw and termination rules went in: insufficient material, a per-board 50-move clock, and a hard ply cap.
The bot moved to its real depth-3 search with a cross-board threat term in the evaluation.

The lesson stuck for the rest of the project.
The model is strong, and it will still make a defensible call and not flag it, and a decision made without surfacing it is a decision hidden.
Pushing once changed how it reported for the rest of the build.

## The adversarial review

With the engine green at 109 tests and about 99 percent statement coverage, I had it run a read-only multi-agent review of the core.
Seven reviewers, each on a different concern, found candidate issues, and then an independent skeptic tried to refute each finding before it counted, defaulting to not real unless the code mishandled the case.
The pass raised 33 findings and verified 27, one of them critical.

The critical one was real and the reason I wanted the review at all.
Because a player can legally move on one board while in check on another, and because move generation never forbade a move that captures a king, the attacker could capture the enemy king on the following turn.
After the king came off, that board read as active again, since a side with no king cannot be in check, and the win was never scored.
My green suite had not caught it.
A passing suite proves the code does what the tests imagined, not what the rules require, and the adversarial pass imagined harder than the model or I had.

The full report, with file-and-line locations, fixes, and an order of operations, came back attached to the work as a review with inline comments.

## Playing it surfaces the real gaps

I played the single-file build, which turned up a bug that was not one.
A pawn could not capture across a seam, and that was the credit rule working as written, because no pawn had been lost on the destination board yet, so no crossing was earned.
The actual gap was that the board gave me no way to see which credits I held or why a crossing was unavailable.

I also asked whether the bot even knows it can cross, since I had not seen it happen.
It does.
The engine treats both colors with the same move generator, and the bot takes a cross-board capture the moment it holds a credit.
It proved it by setting up a position where Black held a knight credit into a board and a white queen sat on a square a knight could reach across the seam, and the bot chose the crossing capture that took the queen.
Black rarely holds a credit early, which is why I had not seen it in the opening.

## The rules revision

Then I changed the rules in a substantial way, and this time I made it pin every ambiguity in conversation before any code moved.
A move can cross as many board boundaries as an unobstructed slide allows, not only one, and it needs a credit for every board it enters, spending one credit per board.
Pawns can push straight across a seam, and any pawn move that crosses a board border always promotes on arrival.
Attack rays are no longer clipped at seams, so a piece can check a king on another board, but only when it holds the credits its capturing move would need to get there.
Per-board stalemate went away entirely.

That last one was my game-design call, and the reasoning is the win condition.
You win by accumulating checkmates, so a board that locks into a draw is one fewer board anyone can fight over.
Keeping boards live until a real checkmate or a genuine draw rule fires keeps the arena contestable and the scores higher, and it removes a turn-timing artifact where a board could freeze as a draw because the side to move happened to have no move on it.

It shipped each change as its own pull request stacked off the base, so each diff showed exactly one change.
Merging them produced the conflicts I expected, since the three changes all touch move generation, the reducer, and the type model, and it resolved them by hand.
The most interesting resolution extended the credit-backed check from the single-seam case it was written for to the new multi-board reality: a cross-board attacker gives check only if it holds a credit for every board its capturing slide enters, the target's board plus each intermediate one.

## Fixing the keystone bug for real

The review's headline finding got a proper fix rather than a patch.
Move generation now refuses to produce any move that lands on a king, so kings are uncapturable by construction and every active board keeps both kings.
Board status gets recomputed across every non-frozen board after each move, not only the one or two boards the move touched, so a checkmate delivered across a seam onto an otherwise untouched board now registers and scores.
Checkmate is evaluated before the draw rules, so a quiet mating move at the 50-move mark counts as a win and not a draw.
The per-board clock only ticks the boards a move touched, so idle boards stop getting force-drawn.

The UI caught up to the engine after I complained that I could not tell a dead king from a live one.
A king under attack now gets a red pulsing ring, and a finished board gets a clear overlay that says checkmate with the winner, or draw.
Before that, a king with no legal moves looked identical whether it was boxed in by its own pieces or checkmated.

The whole ruleset went into one canonical document, written to be the source of truth, and updated in the same pull request as any rule change.

## Porting it to Temper

Next I had it port the functional core to Temper.
Temper is a language that compiles one source library to C#, Java, JavaScript, Lua, Python, and Rust, emitting idiomatic code in each target rather than a lowest-common-denominator blob.
My core fit the brief almost exactly, because it is pure, immutable, strongly typed, and does no I/O, while the imperative UI shell stays per-platform and consumes the generated engine.

The first obstacle was that the compiler did not exist on my machine.
The `temper` command pointed at a binary under a build path that had never been produced.
So the work started by cloning the compiler repo, building its CLI through Gradle, and pinning a working JDK 21, because my environment's JAVA_HOME pointed at a Java install that was not on disk.
It wrote a small project wrapper script that fixed the JDK for every later invocation so the agents could not trip over it.

Before porting anything, it ran a smoke test: a trivial function with one inline test, compiled and run on the interpreter backend and on JavaScript, both green.
No point porting a real module onto a broken scaffold, and I was glad it checked instead of assuming.

## How the port ran

The port ran as a sequence of agent workflows, and the structure followed Temper's one hard constraint.
Temper compiles the whole library as one unit, and the modules form a dependency chain where everything imports the type vocabulary and the top of the stack imports nearly everything.

The foundation went first and sequential, because of that chain.
Six modules, ported one at a time, each compiled and tested before the next: the value types, the coordinates, the piece helpers, the plane, the credit ledger, and the game state with its initial setup.
That wave ended green at 33 tests on the interpreter.

I pushed to fan the work out, and the later waves did, by dependency level.
Three agents ported the independent modules at once, each working in its own isolated copy of the project so their compiles could not collide, then writing the finished file back into the shared tree.
The geometry and move-generation wave ran three modules in parallel and then chained the two that depended on them, ending at 71 tests.
The engine and AI wave ported the tightly coupled check, legality, and reducer cluster as one coherent unit, then fanned out scoring and evaluation in parallel, then finished with the bot, ending at 90 tests.

## Literate Temper: the module is the documentation

Temper leans hard on literate programming, and once I read the modules the model was producing I understood why the reference I had handed it kept using that phrase.
A module is not a code file with comments bolted on the side; it is a Markdown document whose prose is the main text and whose code lives in indented blocks that the compiler extracts and builds.
Each module opens by naming the section of the rules it implements, argues the design decision out in plain English, shows the code that decision produces, and then closes with the tests that hold the code to the claim.
The tests are not parked in a separate suite somewhere else in the tree; they sit inline in the very same file as the code they cover, and because Temper runs them on every backend, reading a module from top to bottom walks you through a rule, the implementation it forces, and the proof that the implementation matches, all in one pass.

This is the colour type as it appears in `types.temper.md`, the prose and the code and the test sitting together, lightly trimmed for length:

```markdown
Each case is a class with no fields. Because the engine needs exactly one White and one
Black and compares them by identity, we expose a single canonical instance of each as a
module-level constant. Later modules write `White` / `Black` (the values), never
`new ColorWhite()`, so there is only ever one of each to compare against.

    export class ColorWhite() extends Color {
      public opposite(): Color { Black }
    }
    export class ColorBlack() extends Color {
      public opposite(): Color { White }
    }
    export let White: Color = new ColorWhite();
    export let Black: Color = new ColorBlack();

This invariant pins the round-trip: flipping twice is identity, and `opposite` agrees with
the TS `opposite('white') === 'black'` test in `../../src/core/pieces.test.ts`.

    test("Color.opposite flips and round-trips") {
      assert(White.opposite() == Black) { "white flips to black" };
      assert(Black.opposite() == White) { "black flips to white" };
      assert(White.opposite().opposite() == White) { "double flip is identity" };
    }
```

What I kept noticing is that the prose carries the intent the types alone cannot.
A reader who has never touched Temper can follow why there is exactly one White object before meeting the syntax that makes it so, and a reader auditing the port against the original can see the exact TypeScript test each Temper test answers to, because the prose names the file it came from.
I had the model write every module in this shape, grounded in the canonical rules document, so the finished port reads as an explanation of the engine and not a transliteration of it.

## The translation, concept by concept

TypeScript and Temper share a lot of surface vocabulary and almost none of the same mechanics, so each construct needed a real decision, and watching the model reason through those one at a time was the most interesting part of the port for me.

The TypeScript `Result<T, E>` became `throws Bubble` with `orelse` recovery, since Bubble is control flow rather than a data value, and the typed `CoordError` record dropped out entirely.
Branded coordinate types became nominal classes that wrap one integer and are minted only by smart constructors, which is stronger than the phantom-type trick they replaced, because a raw integer cannot be cast into one.
String-literal unions like Color and PieceType became sealed interfaces with one fieldless singleton class per case, compared by identity, so White is an object and `toMove == White` is reference equality.
Discriminated unions like the move and the board status became sealed interfaces with one class per variant, matched with exhaustive `when`, except where a `when` used directly as a return value mistyped its arms, which it handled with narrowing if-else chains.

A few translations were more involved, and the credit ledger was the one I enjoyed most because the constraint and the fix are both visible in the code.
The TypeScript ledger keyed its credit counts on colour and piece-type objects, nested a couple of maps deep, but Temper restricts map keys to strings and integers, so a `Map<Color, Map<...>>` is not expressible at all: a `Color` is a class, not a key.
Rather than stringify the parts, the model repacked the three coordinates of a credit, the board it belongs to, the colour that owns it, and the piece type that may spend it, into a single integer that indexes one flat `Map<Int, Int>`:

```temper
let slotKey(board: BoardIndex, colorCode: Int, typeCode: Int): Int {
  (board.value() * 2 + colorCode) * 5 + typeCode
}
```

Two colours and five crossing types give a fixed radix, so every `(board, colour, type)` triple lands in its own slot with no collisions, and an absent key reads as zero credits, which lets the empty ledger be the empty map.
The module's prose spells this out and points at the same defaulting behaviour in the TypeScript `creditCount`, so the encoding documents itself rather than hiding in a helper.

The credit-backed check, the rule that a piece on another board only gives check when it has banked the credits its capturing move would spend, came across as a single readable predicate, and reading it next to the rule it enforces is the clearest argument I have for the literate style:

```temper
let threatens(
  ledger: Ledger, targetBoard: BoardIndex, attackerBoard: BoardIndex,
  byColor: Color, type: PieceType, entered: List<BoardIndex>,
): Boolean {
  if (attackerBoard.value() == targetBoard.value()) {
    true                              // same-board attack needs no credit
  } else if (!isCrossingType(type)) {
    false                             // kings cannot cross a seam to capture
  } else {
    var ok = true;
    for (let b of entered) {
      if (b.value() != attackerBoard.value() && !hasCredit(ledger, b, byColor, type)) {
        ok = false;                   // missing a credit for a board passed through
      }
    }
    ok && hasCredit(ledger, targetBoard, byColor, type)  // and one for the landing board
  }
}
```

The precise `MoveError` survived as a sealed interface with ten variant classes, and the apply result became a sealed Applied-or-Rejected pair, which preserved the exact rejection reason a move failed for rather than collapsing every failure into one bare Bubble.
The seeded mulberry32 random generator ported almost verbatim, because Temper's 32-bit integer wraps on overflow, which is the behavior the TypeScript version emulated by hand.

One discovery simplified everything.
All of the library's source files share a single namespace, so there are no import lines between modules, and an explicit import fails to resolve.
That let the mutually recursive check, legality, and reducer cluster reference each other freely, the same way the TypeScript modules did.

The vitest cases were rewritten as the inline `test()` blocks shown earlier, living in the same literate file as the code they verify, so when Temper runs them on every backend the suite stops being a TypeScript-only check and becomes a conformance test that the same engine behaves identically in six languages.

## A functional core, written into an object language

The friction in the port was paradigm, not syntax, and watching the model work through it was the most interesting stretch for me.
I wrote the TypeScript core in a deliberately functional style: the data is inert and the functions are smart.
A color is a string, a coordinate is a branded number, a move is a plain object with a `kind` tag, and a failure is a `Result` value you pattern-match.
Temper pulls the other way, toward objects that carry their own behavior.

The model did not fight that, and mostly that was the right call.
A color became a singleton object with an `opposite()` method, a piece type carried its material value and its crossing eligibility as methods, and the small pieces module collapsed into a facade that forwards to them.
The branded number became a real class minted only by a validating constructor, which is a stronger guarantee than the phantom-type trick it replaced, because a raw integer cannot be cast into it at all.
The tagged-union move became a sealed interface with one class per variant, matched by type instead of by a string tag.

The colour shows the move in miniature: a `'white' | 'black'` string in the TypeScript becomes the sealed interface and the two singletons shown earlier, with `opposite()` living on the type instead of in a free function, and identity comparison standing in for string equality.
The branded coordinate, a `number & { brand }` phantom type in TypeScript, becomes a real class you can only obtain from a constructor that validates the range and bubbles on failure:

```temper
export let mkGx(n: Int): GX throws Bubble {
  if (inRange(n, plane)) { new GX(n) } else { bubble() }
}
```

The costs are real.
Every coordinate is now a boxed object instead of a bare number, and because nominal classes have no structural equality, comparisons go through a `.value()` call and tests compare by field rather than by one deep-equals.
Classes can only extend interfaces, so the five move variants could not share a base record, and their common fields became interface getters that each variant re-implements.
A `when` expression used directly as a return value sometimes mistyped its arms, so a few branches turned into if-else narrowing.

What surprised me is how much of the functional shape survived anyway.
Temper is immutable by default, with persistent lists and maps and copy-on-write, so the pure core carried straight across.
The reducer stayed the single transition function, the search kept its shape, and the algorithms stayed plain functions operating over classes that act as records.
The bot is the clearest proof of that: its alpha-beta negamax came over as the same tight imperative loop the TypeScript ran, mutable accumulators and cutoff and all, now reading its moves and scores through methods instead of fields.

```temper
let negamax(state: GameState, depth: Int, alpha: Float64, beta: Float64): Float64 {
  if (depth <= 0 || gameOver(state)) { return leafScore(state, state.toMove); }
  let ordered = orderByPriority(legalMoves(state));
  let limit = if (ordered.length < interiorBeam) { ordered.length } else { interiorBeam };
  var best = -Infinity;
  var a = alpha;
  var i = 0;
  while (i < limit) {
    let score = -negamax(searchApply(state, ordered[i]), depth - 1, -beta, -a);
    if (score > best) { best = score; }
    if (best > a) { a = best; }
    if (a >= beta) { i = limit; } else { i += 1; }  // alpha-beta cutoff
  }
  best
}
```

Temper let me keep that loop almost character for character, which mattered, because a search you have rewritten is a search you have to re-tune, and I wanted the ported bot to play the identical game the original did.
The port landed as functional code in an object language, using the nominal types and sealed interfaces for the contracts and keeping the logic as ordinary functions.
That middle kept it close to the original and easy to check against it, instead of rewriting the engine into deep class hierarchies the TypeScript never had, and the model found that balance without much steering from me.

## Where the port landed

The whole core came across, and the bulk of it surprised me once it was done.
Sixteen logic modules ran to about 5,700 lines of literate Temper, every one of them reading as documentation with the code woven through the prose, and every one naming the section of the rules it implements so a reviewer can check the code against the law it is supposed to obey.
The suite passes 90 of 90 on the interpreter, on JavaScript, and on Python, and the engine compiles cleanly to all six backends, which means the same chess variant now has a real, tested implementation in several languages I never wrote a single line of for this project.

Every correctness invariant from the TypeScript side survived, verified green on multiple backends and not only on a reading: credit-backed cross-board check, all-boards cross-seam checkmate detection, checkmate before draws, the per-board clock, all-kings safety, uncapturable kings, the precise errors, and the absence of per-board stalemate.

One caveat it flagged and I am passing on.
The tree-walking interpreter backend has a shared step budget that the full faithful suite would exceed, so a handful of extra reducer cases are written and pass on JavaScript and Python but are left out of the interpreter run to stay under budget, each documented in prose.
Every headline invariant is covered and green on all three backends.

## What the port is for

Then I asked whether the generated JavaScript could replace the hand-written TypeScript core in the UI.
The model had called the port drop-in earlier, and I did not buy it, so I made it check.
The answer is no.

It ran the generated core in node and inspected the runtime shapes, which settled it with evidence.
`state.toMove` comes back as a `ColorWhite` object, not the string `"white"`, so `=== "white"` is false.
A square's `.gx` is a `GX` wrapper object, with the number behind a `.value()` call, not a bare number.
A move is a `MoveNormal` instance you discriminate with `instanceof`, and its `.kind` is undefined.
`applyMove` returns an `Applied` object, and its `.ok` is undefined.
The names line up with the TypeScript core, and the runtime shapes do not.

The good news from the same probe is that Temper's list type compiles to a plain JavaScript array, so the plane, the status array, and the move list all iterate, index, and report length unchanged.

A real swap needs a thin translation shim sitting where the core's public interface is, mapping colors and piece types to strings, the coordinate wrappers to numbers, and the move, status, and result classes to the plain shapes the UI reads, plus bundling the two Temper runtime packages the old core never required.
That reframes what the port is for.
It was never about deleting TypeScript that already ships small and clean.
It makes the same engine real in Python, Java, Rust, and the others, from one source, which is the whole point of writing it in Temper.
That overclaim, and my pushing on it, was the third time the same lesson showed up.

## Wiring the Temper engine into the real game

The drop-in finding nagged at me, so the next thing I had it do was build the adapter that finding called for.
The shim is a small module that presents the exact core interface the UI already imports, and runs the Temper engine behind it.
At the boundary it does the conversion the runtime needs: the `ColorWhite` object becomes the string `"white"`, the `GX` wrapper becomes a plain number, a `MoveNormal` instance becomes a `{ kind: "normal" }` object, and an `Applied` result becomes `{ ok: true, value }`.

Most of that difference is the move type.
In Temper a move is a sealed interface whose shared fields are getter methods, which is why the generated JavaScript exposes them as calls rather than properties:

```temper
export sealed interface Move {
  public from(): GlobalSquare;
  public to(): GlobalSquare;
  public piece(): Piece;
  public captured(): Piece?;
  public crossings(): List<BoundaryCrossing>;
}
```

The shim never rebuilds an engine value from a UI value.
When the UI hands a move back to play it, the shim looks up the original Temper move it handed out earlier, kept in a `WeakMap` keyed by the plain object the UI was holding.

Then I had it point the build at the shim.
The UI source did not change at all; a one-line alias in a second build config swaps the core for the shim at bundle time, and the same plugin inlines the Temper runtime into one self-contained HTML.
The Temper-backed file came out around 49 kilobytes against 26 for the TypeScript one, the extra weight being the engine and its runtime.
What I had called not drop-in turned out to be drop-in behind a thin and honest seam, a better answer than the overclaim or the flat no.

## Validating it in a browser, in parallel

I was not going to take "the tests pass" on faith for a swap this deep, so I had it write real browser tests, and write them as a fan-out.
Four agents each wrote one Playwright scenario at the same time, against the same self-contained build, which works here because the specs are independent files and the artifact is read-only, the rare case where parallel agents do not collide.
The scenarios split the surface: one played a multi-ply game, clicking pieces and waiting for the bot between moves; another checked selection and the clicks that should do nothing; a third confirmed that restart returns a fresh board; the last was a parity check.

The parity test is the one I cared about.
It loads the Temper build and the original TypeScript build in two browser tabs and asserts they render the identical starting position and light up the identical legal moves for the same pieces, which is the proof that the two engines agree, observed through the game a person would play.
The whole suite ran the Temper engine in a real Chromium, not in node, and came back green at eight tests.

One small thing I liked.
The selection agent set out to assert that clicking a selected piece deselects it, found that this build re-selects it instead, and rewrote its own test to match what the app does rather than what its instructions assumed.
That is the behavior I want from a test author, and it is not always what you get.

## The method: workflows of agents

Dynamic workflows were half of what I was testing, so a note on how they performed.
Most of the heavy phases ran as workflows that fan out to many short-lived agents and then collect their results, instead of one assistant typing in a loop.

The type model came from a design panel.
Three architect agents each proposed a full architecture from a different bias, a judge agent synthesized them into one blueprint, and only then did implementation start.
The blueprint was not a vague sketch; it specified the concrete type definitions, the module layout, the build order, and the pitfalls to watch.

The review had the same shape pointed at finished code.
Seven reviewer agents each took one concern, every finding went to an independent skeptic that tried to refute it before it counted, and a final agent ranked the survivors into an ordered plan.
That structure is why the king-capture bug got caught.
A single reader, including me, had walked past it, and the adversarial framing existed to walk into it.

The Temper port leaned on the same model under a harder constraint.
Temper compiles the whole library at once, so two agents writing into the same source tree corrupt each other's compile, and the modules form a dependency chain where you cannot build the coordinates before the types exist.
The foundation ran sequential for that reason, one module at a time.
Where the dependency graph had width, the later waves fanned out, with each parallel agent working in its own copy of the project so its compile stood alone, then writing its module back into the shared tree, followed by an integrate agent that compiled all of them together and resolved any name collision.

The tooling did not make this free.
The workflow runner offers git worktree isolation for exactly this case, and it refused, because the repository had been created partway through the session and the runner had already decided the directory was not a git repo.
So the parallel agents fell back to copying the source directory into a temporary location and compiling there, with a small per-copy wrapper that runs the compiler without a fragile directory change a background agent could not answer a prompt for.

Even the plain git workflow threw a curveball.
One of the fix pull requests got squash-merged at an earlier commit than I expected, which left two later commits, the stalemate removal and the rules document, stranded on the branch and out of the merge.
Recovering meant cherry-picking those two commits onto the freshly merged base and opening a clean pull request for them, then re-verifying the whole suite on the combined result.
The honest read is that the workflows bought real speed where the work had width, and the middle of a compiler-shaped dependency chain stays mostly sequential no matter how many agents you point at it.

## Where it stands

A tested nine-board chess variant that opens as a single HTML file.
A canonical ruleset that tracks the code in the same commits that change it.
The entire engine living a second life across six languages from one literate source.
And that ported engine driving the actual playable game behind a shim, checked move-for-move against the original in a real browser.

What I take away about Opus 4.8 and the workflows is mixed in the useful way.
The model held a high bar over a long, strange build and debugged its own performance and toolchain problems without much help from me.
It also made quiet calls it should have surfaced, and the three times I pushed, on the deferred castling, the king-capture bug, and the drop-in overclaim, were the three times the result got better.
The workflows earned their place on the design panel and the adversarial review, where independent agents see what one pass misses, and they hit the obvious wall on a single-compile dependency chain.
My job through all of it was setting direction, making the rule calls, and not nodding when something looked finished and was not.
