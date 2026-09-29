// Mount the Blimp program a page names. The page has
//
//   <div id="blimp-app" data-program="/2048/twenty48.blimp" data-actor="game">
//
// and the program ends with `game <- :view`. This loads Blimp's interpreter,
// seeds its random numbers (the WebAssembly build has no clock), and hands
// the program to BlimpView, which draws it and sends it every click, key,
// swipe and timer. No page has JavaScript of its own beyond this.
(async function () {
  var el = document.getElementById('blimp-app')
  var status = document.getElementById('blimp-app-status')
  function fail(text) {
    status.textContent = text
    status.className = 'blimp-app-status bad'
  }
  try {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    await blimp.init('/blimp/blimp.wasm')
    var res = await fetch(el.dataset.program)
    if (!res.ok) throw new Error(el.dataset.program + ' is ' + res.status)
    var source = await res.text()
    var view = new BlimpView(blimp, el, { send: true, onError: fail })
    var seeded = blimp.eval('seed(' + Date.now() + ')')
    if (!seeded.ok) return fail(seeded.error)
    var mounted = view.mount(source, el.dataset.actor)
    if (!mounted.ok) return fail(mounted.error)
    status.textContent = ''
    status.className = 'blimp-app-status'
  } catch (e) {
    fail(String(e.message || e))
  }
})()
