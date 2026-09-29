// Start Blimp Tetris on /tetris. Everything the game does is tetris.blimp;
// this only loads the interpreter, fetches the game and hands both to
// BlimpView (both files from Blimp, beside this one), in send mode so a long
// game does not grow the tab.
(async function () {
  var el = document.getElementById("tetris")
  var status = document.getElementById("tetris-status")
  function say(text, bad) {
    status.textContent = text
    status.className = bad ? "tetris-status bad" : "tetris-status"
  }
  try {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    blimp.onError(function (msg) { console.error(msg) })
    await blimp.init("/tetris/blimp.wasm")
    var res = await fetch("/tetris/tetris.blimp")
    if (!res.ok) throw new Error("tetris.blimp is " + res.status)
    var source = await res.text()
    var view = new BlimpView(blimp, el, {
      send: true,
      onError: function (msg) { say(msg, true) },
    })
    var mounted = view.mount(source, "game")
    if (!mounted.ok) return say(mounted.error, true)
    say("running in Blimp")
  } catch (e) {
    say(String(e.message || e), true)
  }
})()
