// The socket for /reddit-links, /emoji-skeets and /jetstream_comparison,
// after app.js has mounted the page's Blimp program (window.BlimpApp, actor
// `fh`). The page says which feed it wants (data-firehose); every frame the
// server sends goes to `fh <- :frame(json)`, and a lost connection to
// `fh <- :offline`, then it tries again, waiting longer each time.
//
// Nothing goes up: what a page shows is decided in the page. The LiveViews
// sent every keystroke of the search box to the server and had it filter.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var page = document.getElementById('blimp-app').dataset.firehose
    var wait = 500
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      var ws = new WebSocket(scheme + location.host + '/live/firehose?page=' + encodeURIComponent(page))
      ws.onopen = function () { wait = 500 }
      ws.onmessage = function (ev) { app.view.send('frame', literal(ev.data)) }
      ws.onclose = function () {
        app.view.send('offline')
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }
    connect()
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
