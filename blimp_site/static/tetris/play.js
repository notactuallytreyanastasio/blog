// Start Blimp Tetris on /tetris, and draw the running program beside it.
// Everything the game does is tetris.blimp; this loads the interpreter,
// fetches the game, hands both to BlimpView, and after every render gives
// Blimp's canvas the runtime's actors and message log (all three files from
// Blimp, beside this one).
//
// The view runs on eval rather than send: the message log the canvas draws
// is something eval fills and a send, by design, does not. The cost is that
// the tab keeps what each eval parsed, about 7MB per 4,000 moves.
(async function () {
  var el = document.getElementById("tetris")
  var status = document.getElementById("tetris-status")
  function say(text, bad) {
    status.textContent = text
    status.className = bad ? "tetris-status bad" : "tetris-status"
  }
  try {
    var viz = new BlimpCanvas(document.getElementById("tetris-viz"))
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    blimp.onError(function (msg) { console.error(msg) })
    await blimp.init("/tetris/blimp.wasm")
    var res = await fetch("/tetris/tetris.blimp")
    if (!res.ok) throw new Error("tetris.blimp is " + res.status)
    var source = await res.text()
    var view = new BlimpView(blimp, el, {
      onError: function (msg) { say(msg, true) },
      onRender: function () { viz.feed(blimp.getState(), null) },
    })
    // The WebAssembly build has no clock; without a seed every visit deals
    // the same pieces.
    var seeded = blimp.eval("seed(" + Date.now() + ")")
    if (!seeded.ok) return say(seeded.error, true)
    var mounted = view.mount(source, "game")
    if (!mounted.ok) return say(mounted.error, true)
    say("running in Blimp")
  } catch (e) {
    say(String(e.message || e), true)
  }
})()
