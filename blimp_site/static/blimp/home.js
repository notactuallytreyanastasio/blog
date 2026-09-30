// The homepage's scope: Blimp's canvas drawing the one Blimp process that
// serves this site, fed over /live/runtime (push_runtime in main.blimp).
// It is runtime.js's corner window made the page's centrepiece: the same
// feed into the same BlimpCanvas, into a canvas the page already has, and
// it keeps the page's gauges (server-rendered, zero-padded) current.
(function () {
  var canvas = document.getElementById('scope-canvas')
  if (!canvas || !window.BlimpCanvas || !window.WebSocket) return

  var status = document.getElementById('scope-status')
  var g = {
    actors: document.getElementById('g-actors'),
    served: document.getElementById('g-served'),
    up: document.getElementById('g-up')
  }
  var viz = new BlimpCanvas(canvas)
  document.documentElement.classList.add('scope-live')
  status.textContent = 'connecting to the server...'

  function pad(n, w) { var s = String(n); while (s.length < w) s = '0' + s; return s }
  function uptime(s) {
    return pad(Math.floor(s / 86400), 3) + 'd ' + pad(Math.floor(s % 86400 / 3600), 2) + 'h ' + pad(Math.floor(s % 3600 / 60), 2) + 'm'
  }

  var answered = 0
  var wait = 1000
  function connect() {
    var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
    var ws = new WebSocket(scheme + location.host + '/live/runtime')
    ws.onopen = function () { wait = 1000 }
    ws.onmessage = function (ev) {
      var state = JSON.parse(ev.data)
      viz.feed(state, null)
      state.messages.forEach(function (m) { if (/^(GET|HEAD|POST|WS) /.test(m.message)) answered++ })
      var site = state.actors.filter(function (a) { return a.type === 'Site' })[0]
      var st = site && site.state || {}
      if (g.actors) g.actors.textContent = pad(state.actors.length, 3)
      if (g.served && typeof st.served === 'number') g.served.textContent = pad(st.served, 8)
      if (g.up && typeof st.booted_at === 'number') g.up.textContent = uptime(Math.max(0, Math.floor(Date.now() / 1000) - st.booted_at))
      status.textContent = 'live: ' + state.actors.length + ' actors' +
        (answered ? ', ' + answered + (answered === 1 ? ' request' : ' requests') + ' answered while you watched' : '')
    }
    ws.onclose = function () {
      status.textContent = 'reconnecting...'
      setTimeout(connect, wait)
      wait = Math.min(wait * 2, 15000)
    }
  }
  connect()
})()
