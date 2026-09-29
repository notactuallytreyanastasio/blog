// Start Blimp Pong on /pong. The game is pong.blimp; this loads Blimp's
// interpreter, hands the game to BlimpView (which draws it and runs its
// timer and keys), and ten times a second sends the server what
// `pong <- :report` answers, so /pong/god can draw this game too.
(async function () {
  var el = document.getElementById('pong')
  var status = document.getElementById('pong-status')
  function say(text, bad) {
    status.textContent = text
    status.className = bad ? 'pong-status bad' : 'pong-status'
  }
  try {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    await blimp.init('/blimp/blimp.wasm')
    var res = await fetch('/pong/pong.blimp')
    if (!res.ok) throw new Error('pong.blimp is ' + res.status)
    var source = await res.text()
    var view = new BlimpView(blimp, el, { send: true, onError: function (msg) { say(msg, true) } })
    // The WebAssembly build has no clock; without a seed every visit plays
    // the same game.
    var seeded = blimp.eval('seed(' + Date.now() + ')')
    if (!seeded.ok) return say(seeded.error, true)
    var mounted = view.mount(source, 'pong')
    if (!mounted.ok) return say(mounted.error, true)
    say('running in Blimp')
    report(blimp, el.dataset.game, say)
  } catch (e) {
    say(String(e.message || e), true)
  }

  function report(blimp, game, say) {
    var ws = null
    var wait = 500
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/pong?game=' + encodeURIComponent(game))
      ws.onopen = function () { wait = 500 }
      ws.onclose = function () { ws = null; setTimeout(connect, wait); wait = Math.min(wait * 2, 10000) }
    }
    connect()
    setInterval(function () {
      if (!ws || ws.readyState !== 1) return
      var r = blimp.send('pong', 'report')
      if (r.ok) ws.send(r.value)
    }, 100)
  }
})()
