// /cameras' socket, after app.js has mounted cameras.blimp (window.BlimpApp,
// actor `cam`). This is the part of CameraBrowserLive a Blimp program in the
// browser cannot be: the PubSub subscription and the star, hide and note
// events, now /live/cameras.
//
//  - every frame from /live/cameras goes to `cam <- :frame(json)`: a sweep
//    finished, or a listing changed;
//  - every 100ms `cam <- :outbox` answers what to send up (a star, a hide,
//    a note, each carrying the page's ?key=).
//
// A socket that drops is opened again, with a growing wait; what the page
// wrote meanwhile is sent when it is back.
(function () {
  var POLL_MS = 100

  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var blimp = app.blimp

    // A send made while the view is rendering is dropped, so a frame waits
    // for the stack to unwind.
    function tell(msg, args) { setTimeout(function () { view.send(msg, args) }, 0) }

    var queued = []
    var ws = null
    var wait = 500
    function up(frame) {
      if (ws && ws.readyState === 1) ws.send(frame)
      else queued.push(frame)
    }
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/cameras')
      ws.onopen = function () { wait = 500; queued.splice(0).forEach(up) }
      ws.onmessage = function (ev) { tell('frame', literal(ev.data)) }
      ws.onclose = function () {
        ws = null
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }

    setInterval(function () {
      var out = blimp.send('cam', 'outbox')
      if (out.ok && Array.isArray(out.value)) out.value.forEach(up)
    }, POLL_MS)
    connect()
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
