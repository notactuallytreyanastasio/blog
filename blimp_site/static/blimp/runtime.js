// The Blimp window on every page: Blimp's canvas drawing the one Blimp
// process that serves this site, as it runs. The server sends its actors
// and its messages over /live/runtime a few times a second (see
// push_runtime in main.blimp); every actor is a hexagon, every message a
// ray, and every page anyone requests is a ray into the Site actor.
// Nothing here draws anything of its own: it is BlimpCanvas, fed.
(function () {
  if (!window.BlimpCanvas || !window.WebSocket || document.getElementById('blimp-runtime')) return

  var closed = document.createElement('span')
  closed.id = 'blimp-rt-closed'
  var box = document.createElement('div')
  box.id = 'blimp-runtime'
  box.className = 'blimp-window blimp-runtime'
  box.innerHTML =
    '<div class="mac-title-bar"><a href="#blimp-rt-closed" class="mac-close-box" title="close"></a>' +
    '<div class="mac-title">Blimp: this site, running</div></div>' +
    '<div id="blimp-rt-wrap"><canvas id="blimp-rt"></canvas></div>' +
    '<div id="blimp-rt-status" class="blimp-status">connecting to the server...</div>'
  document.body.appendChild(closed)
  document.body.appendChild(box)

  var status = document.getElementById('blimp-rt-status')
  var viz = new BlimpCanvas(document.getElementById('blimp-rt'))
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
      var served = site && typeof site.state.served === 'number' ? site.state.served : null
      status.textContent = state.actors.length + ' actors' +
        (served !== null ? ', ' + served + ' requests since it booted' : '') +
        (answered ? ', ' + answered + ' while you watched' : '')
    }
    ws.onclose = function () {
      status.textContent = 'reconnecting...'
      setTimeout(connect, wait)
      wait = Math.min(wait * 2, 15000)
    }
  }
  connect()
})()
