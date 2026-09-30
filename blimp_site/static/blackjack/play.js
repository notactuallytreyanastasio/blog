// Start /blackjack. The page is blackjack.blimp; this loads Blimp's
// interpreter, mounts the program, and joins it to the server's tables over
// /live/blackjack: every message the server sends goes to the program as
// `bj <- :state(json)`, and after every render what the program queued
// (`bj <- :outbox`) goes up the socket.
(async function () {
  var el = document.getElementById('blackjack')
  var status = document.getElementById('blimp-app-status')
  var ws = null

  function fail(text) {
    status.textContent = text
    status.className = 'blimp-app-status bad'
  }

  // A Blimp string literal holding `s`, with \#{ so no name is read as
  // interpolation.
  function literal(s) {
    return '"' + s.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/#\{/g, '\\#{') + '"'
  }

  try {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    await blimp.init('/blimp/blimp.wasm')
    var res = await fetch('/blackjack/blackjack.blimp')
    if (!res.ok) throw new Error('blackjack.blimp is ' + res.status)
    var canvas = window.BlimpPageCanvas ? new BlimpPageCanvas(blimp) : null
    function flush() {
      var out = blimp.send('bj', 'outbox')
      if (!out.ok || !Array.isArray(out.value)) return
      out.value.forEach(function (m) {
        if (ws && ws.readyState === 1) ws.send(m)
      })
    }
    var view = new BlimpView(blimp, el, {
      send: true,
      onError: fail,
      onRender: function () {
        flush()
        if (canvas) canvas.feed()
      }
    })
    blimp.eval('seed(' + Date.now() + ')')
    var mounted = view.mount(await res.text(), 'bj')
    if (!mounted.ok) return
    status.textContent = ''
    status.className = 'blimp-app-status'
    var wait = 500
    ;(function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/blackjack')
      ws.onopen = function () { wait = 500 }
      ws.onmessage = function (ev) { view.send('state', literal(ev.data)) }
      ws.onclose = function () {
        view.send('offline')
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    })()
  } catch (e) {
    fail(String(e.message || e))
  }
})()
