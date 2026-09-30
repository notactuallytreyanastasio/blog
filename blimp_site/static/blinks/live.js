// /blinks-next's transport, after app.js has mounted the page's Blimp
// program (window.BlimpApp, actor `blinks`). BlinksLive had four hooks
// (BlinksPrefs, BlinksPush, PaperFit, the tour's Joyride) and a LiveView
// socket; what they did that a Blimp program in the browser cannot do by
// itself is done here, and nothing else:
//
//   - :prefs before :location, so the first fetch already knows what this
//     device hid, whether it has seen the tour, its admin key, and the
//     always-shuffle cookie and seed the server put on the page
//   - the /live/blinks socket: frames go to :frame, its state to :socket
//   - the outbox: each <i data-op> the program draws under #bkl-outbox is
//     done once and answered with :done(n, status, body) (the ops are
//     listed in static/blinks/live.blimp)
//   - PaperFit: how many rows fit the paper, as :fit(count)
//   - the push bell: the service worker, and what this browser can do
//
// The localStorage keys are BlinksPrefs' own, so a device's hides, admin
// key and "seen the tour" carry over from /blinks.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r').replace(/#\{/g, '\\#{') + '"'
  }
  function get(k) { try { return localStorage.getItem(k) } catch (_) { return null } }
  function set(k, v) { try { if (v === '') localStorage.removeItem(k); else localStorage.setItem(k, v) } catch (_) {} }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var root = document.getElementById('blimp-app')
    var d = root.dataset

    // A send made while another is being handled is dropped by BlimpView,
    // and the outbox is read while a render is under way, so every send
    // waits its turn here.
    var queue = []
    function send(msg, args) { queue.push([msg, args]); setTimeout(drain, 0) }
    function drain() {
      while (queue.length) {
        var m = queue[0]
        if (view.send(m[0], m[1]) === false && view._sending) { setTimeout(drain, 5); return }
        queue.shift()
      }
    }

    // -- push: what this browser can do (the BlinksPush hook) -------------
    var supported = 'serviceWorker' in navigator && 'PushManager' in window && 'Notification' in window
    var ios = /iPhone|iPad|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
    var standalone = window.matchMedia('(display-mode: standalone)').matches || navigator.standalone === true
    var mobile = ios || /Android|Mobile/i.test(navigator.userAgent)
    var vapid = d.vapid || ''
    function pushState(extra) {
      var reg0 = supported && vapid ? navigator.serviceWorker.getRegistration('/blinks') : Promise.resolve(null)
      return reg0.then(function (reg) { return reg ? reg.pushManager.getSubscription() : null })
        .catch(function () { return null })
        .then(function (sub) {
          var s = { supported: supported, ios: ios, mobile: mobile, standalone: standalone, subscribed: !!sub,
            permission: supported ? Notification.permission : 'unsupported', promptSeen: get('blinksPushPromptSeen') === '1' }
          for (var k in (extra || {})) s[k] = extra[k]
          return { state: s, sub: sub }
        })
    }
    function b64ToBytes(b64) {
      var pad = '='.repeat((4 - (b64.length % 4)) % 4)
      var raw = atob((b64 + pad).replace(/-/g, '+').replace(/_/g, '/'))
      return Uint8Array.from(raw, function (c) { return c.charCodeAt(0) })
    }
    var json = { 'content-type': 'application/json' }
    function push(action, key) {
      if (action === 'subscribe') {
        if (!supported || !key) return pushState({ error: 'unsupported' })
        // requestPermission is called now, inside the tap that asked
        return Notification.requestPermission().then(function (perm) {
          if (perm !== 'granted') return pushState()
          return navigator.serviceWorker.ready
            .then(function (reg) { return reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: b64ToBytes(key) }) })
            .then(function (sub) { return fetch('/blinks-next/api/push/web', { method: 'POST', headers: json, body: JSON.stringify({ subscription: sub.toJSON() }) }) })
            .then(function (res) { if (!res.ok) throw new Error('server said ' + res.status); return pushState() })
        }).catch(function (e) { return pushState({ error: String(e) }) })
      }
      return pushState().then(function (r) {
        if (!r.sub) return r
        if (action === 'unsubscribe') {
          return fetch('/blinks-next/api/push/web?endpoint=' + encodeURIComponent(r.sub.endpoint), { method: 'DELETE' })
            .then(function () { return r.sub.unsubscribe() }).catch(function () {}).then(function () { return pushState() })
        }
        return fetch('/blinks-next/api/push/web/test', { method: 'POST', headers: json, body: JSON.stringify({ endpoint: r.sub.endpoint }) })
          .then(function (res) { return pushState(res.ok ? { tested: true } : { error: 'test failed (' + res.status + ')' }) })
          .catch(function (e) { return pushState({ error: String(e) }) })
      })
    }

    // -- the outbox --------------------------------------------------------
    var done = {}
    function answer(n, status, body) { send('done', n + ', ' + status + ', ' + literal(body || '')) }
    function run(i) {
      var n = i.dataset.n, op = i.dataset.op, a = i.dataset.a || '', b = i.dataset.b || '', c = i.dataset.c || ''
      if (done[n]) return
      done[n] = true
      switch (op) {
        case 'http':
          var headers = {}
          if (c) headers['content-type'] = 'application/json'
          if (i.dataset.key) headers['x-blinks-token'] = i.dataset.key
          if (i.dataset.csrf) headers['x-csrf-token'] = i.dataset.csrf
          var t0 = performance.now()
          fetch(b, { method: a, headers: headers, body: c || undefined, credentials: 'same-origin' })
            .then(function (res) { return res.text().then(function (text) { timing(a + ' ' + b, t0); answer(n, res.status, text) }) })
            .catch(function (e) { answer(n, 0, String(e)) })
          return
        case 'store': set(a, b); return answer(n, 0, '')
        case 'cookie': document.cookie = a; return answer(n, 0, '')
        case 'ws':
          if (ws && ws.readyState === 1) ws.send(a)
          return answer(n, 0, '')
        case 'rect':
          var el = document.querySelector('[data-joyride="' + a + '"]')
          if (!el) return answer(n, 404, '')
          el.scrollIntoView({ block: 'nearest' })
          var r = el.getBoundingClientRect()
          return answer(n, 200, JSON.stringify({ x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height), ww: window.innerWidth, wh: window.innerHeight }))
        case 'confirm': return answer(n, window.confirm(a) ? 1 : 0, '')
        case 'push':
          push(a, b).then(function (r) { answer(n, 200, JSON.stringify(r.state)) })
          return
        default: answer(n, 400, 'no such op ' + op)
      }
    }
    function scan() {
      var box = document.getElementById('bkl-outbox')
      if (box) Array.prototype.forEach.call(box.querySelectorAll('i[data-op]'), run)
      fit()
    }
    // every render: the outbox, synchronously, so an op a click asked for
    // (the push allow button) is still inside that click
    var render = view.render
    view.render = function (v) { var out = render.call(view, v); scan(); rendered(); return out }

    // -- PaperFit -------------------------------------------------------------
    var lastFit = 0, fitAgain = true
    function fit() {
      if (!fitAgain) return
      var paper = document.getElementById('paper')
      if (!paper) return
      var ch = paper.clientHeight
      var things = paper.querySelectorAll('.thing')
      if (ch < 60 || !things.length) return
      fitAgain = false
      var sum = 0
      things.forEach(function (t) { sum += t.offsetHeight })
      var count = Math.max(6, (Math.floor(ch / (sum / things.length)) - 1) * 2)
      // the hook's deadband: re-fitting on every patch made the page churn
      if (lastFit && Math.abs(lastFit - count) < 4) return
      lastFit = count
      send('fit', String(count))
    }
    var resizeT
    window.addEventListener('resize', function () {
      clearTimeout(resizeT)
      resizeT = setTimeout(function () { fitAgain = true; fit() }, 300)
    })

    // -- timings (window.blinksTimings, for the parity runs) --------------------
    var timings = window.blinksTimings = { boot: performance.now(), firstRows: null, fetches: [], renders: 0 }
    function timing(what, t0) { timings.fetches.push({ what: what, ms: Math.round(performance.now() - t0) }) }
    function rendered() {
      timings.renders++
      if (timings.firstRows === null && document.querySelector('#paper .thing')) timings.firstRows = Math.round(performance.now())
    }

    // -- the socket ---------------------------------------------------------------
    var ws = null, wait = 500
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/blinks')
      ws.onopen = function () { wait = 500; send('socket', literal('open')) }
      ws.onmessage = function (ev) { send('frame', literal(ev.data)) }
      ws.onclose = function () {
        send('socket', literal('closed'))
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }

    // -- boot ---------------------------------------------------------------------
    var hidden
    try { hidden = JSON.parse(get('blinksHidden') || '[]') } catch (_) { hidden = [] }
    send('prefs', literal(JSON.stringify({
      hidden: hidden,
      seenTour: get('blinksTourSeen') === '1',
      adminKey: get('blinksAdminKey') || '',
      promoHidden: get('blinksStumblePromoHidden') === '1',
      pushPromptSeen: get('blinksPushPromptSeen') === '1',
      always: d.always === '1', seed: d.seed || '', csrf: d.csrf || '', vapid: vapid
    })))
    send('location', literal(location.search.slice(1)))
    connect()
    if (supported && vapid) {
      navigator.serviceWorker.register('/blinks-sw.js', { scope: '/blinks' })
        .then(function () { return pushState() }, function (e) { return pushState({ error: String(e) }) })
        .then(function (r) { send('push_state', literal(JSON.stringify(r.state))) })
    } else {
      pushState().then(function (r) { send('push_state', literal(JSON.stringify(r.state))) })
    }
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
