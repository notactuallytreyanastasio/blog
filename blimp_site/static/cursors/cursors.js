// /cursor-tracker's hook, after app.js has mounted cursors.blimp
// (window.BlimpApp, actor `cur`). Blimp's view has no pointer events, so
// this is the part of CursorTrackerLive's JS hook that a program cannot be:
//
//  - the mouse: every mousemove is measured against #visualization-area and
//    handed to the program as `cur <- :move(x, y, rx, ry, w, h)`, at most
//    once an animation frame (the latest wins);
//  - the socket: every frame from /live/cursors goes to `cur <- :frame(json)`;
//    every 50ms `cur <- :report` goes up if it changed, so a moving cursor
//    costs the server at most 20 frames a second and a still one, or one
//    outside the area, none; after a click, and every 50ms,
//    `cur <- :outbox` (points clicked, clears) goes up;
//  - the clock: `cur <- :clock(unix seconds)` every second, for the
//    countdown; the WebAssembly build of Blimp has none.
//
// The LiveView's hook pushed every mousemove to the server as it came.
(function () {
  var REPORT_MS = 50

  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var ws = null
    var wait = 500
    var sent = ''

    function up(s) {
      if (ws && ws.readyState === 1) { ws.send(s); return true }
      return false
    }

    function flush() {
      var out = app.blimp.send('cur', 'outbox')
      if (out.ok && Array.isArray(out.value)) out.value.forEach(up)
    }

    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/cursors')
      // a new socket is a new visitor to the room: tell it where we are again
      ws.onopen = function () { wait = 500; sent = '' }
      ws.onmessage = function (ev) { view.send('frame', literal(ev.data)) }
      ws.onclose = function () {
        ws = null
        view.send('offline')
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }

    function moveTo(e) {
      var area = document.getElementById('visualization-area')
      var r = area ? area.getBoundingClientRect() : { left: 0, top: 0, width: -1, height: -1 }
      var x = Math.round(e.clientX), y = Math.round(e.clientY)
      view.send('move', [x, y, Math.round(x - r.left), Math.round(y - r.top), Math.round(r.width), Math.round(r.height)].join(', '))
    }

    var last = null
    var queued = false
    document.addEventListener('mousemove', function (e) {
      last = e
      if (queued) return
      queued = true
      requestAnimationFrame(function () {
        queued = false
        if (last) moveTo(last)
      })
    })

    // A click is the program's own (click: :save_point on the area), and it
    // saves where the program thinks the mouse is. The move that brought the
    // mouse there may still be waiting for its frame, so the click's own
    // position goes first: capture runs before the area's listener.
    document.addEventListener('click', function (e) {
      last = null
      moveTo(e)
      setTimeout(flush, 0)
    }, true)

    setInterval(function () {
      var r = app.blimp.send('cur', 'report')
      if (r.ok && typeof r.value === 'string' && r.value !== sent && up(r.value)) sent = r.value
      flush()
    }, REPORT_MS)

    function tick() { view.send('clock', String(Math.floor(Date.now() / 1000))) }
    tick()
    setInterval(tick, 1000)
    connect()
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
