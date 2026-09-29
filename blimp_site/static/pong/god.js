// Start /pong/god. The page is god.blimp; this loads Blimp's interpreter,
// hands the program to BlimpView, and gives it every message the server
// sends as `god <- :games(json)`.
(async function () {
  var el = document.getElementById('god')
  var status = document.getElementById('god-status')

  // A Blimp string literal holding `s`: the escapes Blimp reads, plus \#{
  // so a game id is never taken for interpolation.
  function literal(s) {
    return '"' + s.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/#\{/g, '\\#{') + '"'
  }

  try {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    await blimp.init('/blimp/blimp.wasm')
    var res = await fetch('/pong/god.blimp')
    if (!res.ok) throw new Error('god.blimp is ' + res.status)
    var view = new BlimpView(blimp, el, { send: true, onError: function (msg) { status.textContent = msg } })
    blimp.eval('seed(' + Date.now() + ')')
    var mounted = view.mount(await res.text(), 'god')
    if (!mounted.ok) return
    status.textContent = 'running in Blimp'
    var wait = 500
    ;(function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      var ws = new WebSocket(scheme + location.host + '/live/pong-god')
      ws.onopen = function () { wait = 500 }
      ws.onmessage = function (ev) { blimp.send('god', 'games', literal(ev.data)) }
      ws.onclose = function () {
        blimp.send('god', 'offline')
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    })()
  } catch (e) {
    status.textContent = String(e.message || e)
  }
})()
