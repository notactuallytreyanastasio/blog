// The socket for /wordle and /wordle_god, after app.js has mounted the
// page's Blimp program (window.BlimpApp).
//
// /wordle: this page's game is `wordle`. Every 200ms this asks it for its
// report and sends it up /live/wordle?game=<id> if it changed; the server
// answers with the most recent games, which go to `wordle <- :others`.
// Also the phone keyboard: LiveView's FocusInput hook, here outside the
// program -- a hidden field that, once tapped into, turns what is typed into
// `wordle <- :key(...)`, as the on-screen keys do.
//
// /wordle_god: everything the server sends goes to `god <- :games`, and a
// cleanup a button asked for (`god <- :outbox`) goes up the socket.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function socket(path, onmessage, onclose) {
    var ws = null
    var wait = 500
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + path)
      ws.onopen = function () { wait = 500; if (sock.onopen) sock.onopen() }
      ws.onmessage = function (ev) { onmessage(ev.data) }
      ws.onclose = function () {
        ws = null
        if (onclose) onclose()
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }
    var sock = { send: function (s) { if (ws && ws.readyState === 1) { ws.send(s); return true } return false } }
    connect()
    return sock
  }

  function player(app) {
    var bytes = new Uint8Array(8)
    crypto.getRandomValues(bytes)
    var id = 'wd_' + Array.prototype.map.call(bytes, function (b) { return ('0' + b.toString(16)).slice(-2) }).join('')
    app.view.send('joined', literal(id))
    var sent = ''
    var sock = socket('/live/wordle?game=' + id, function (data) { app.view.send('others', literal(data)) })
    // a reconnect is a new socket: tell it the game again
    sock.onopen = function () { sent = '' }
    setInterval(function () {
      var r = app.blimp.send('wordle', 'report')
      if (!r.ok || !r.value || r.value === sent) return
      if (sock.send(r.value)) sent = r.value
    }, 200)
    phoneKeys(app)
    // A clicked key keeps the focus, and Enter would click it again.
    document.addEventListener('click', function (e) {
      var b = e.target.closest && e.target.closest('button')
      if (b) setTimeout(function () { b.blur() }, 0)
    })
  }

  function phoneKeys(app) {
    if (!window.matchMedia || !matchMedia('(pointer: coarse)').matches) return
    var input = document.createElement('input')
    input.type = 'text'
    input.className = 'sr-only'
    input.id = 'mobile-input'
    input.setAttribute('autocomplete', 'off')
    input.setAttribute('spellcheck', 'false')
    input.setAttribute('autocapitalize', 'none')
    input.setAttribute('inputmode', 'text')
    document.body.appendChild(input)
    // the phone's keyboard opens only for a tap, so a tap on the board
    document.addEventListener('click', function (e) {
      if (e.target.closest && e.target.closest('#game-board')) input.focus()
    })
    input.addEventListener('input', function (e) {
      var k = (e.data || '').toLowerCase()
      input.value = ''
      if (/^[a-z]$/.test(k)) app.view.send('key', literal(k))
    })
    input.addEventListener('keydown', function (e) {
      if (e.key === 'Backspace' || e.key === 'Enter') {
        e.preventDefault()
        app.view.send('key', literal(e.key))
      }
    })
  }

  function god(app) {
    var sock = socket('/live/wordle-god',
      function (data) { app.view.send('games', literal(data)) },
      function () { app.view.send('offline') })
    setInterval(function () {
      var r = app.blimp.send('god', 'outbox')
      if (r.ok && r.value) sock.send(r.value)
    }, 200)
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    if (app.actor === 'wordle') player(app)
    else if (app.actor === 'god') god(app)
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
