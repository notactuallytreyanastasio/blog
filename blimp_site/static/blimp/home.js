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

  var meter = makeMeter()
  var answered = 0
  var wait = 1000
  function connect() {
    var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
    var ws = new WebSocket(scheme + location.host + '/live/runtime')
    ws.onopen = function () { wait = 1000 }
    ws.onmessage = function (ev) {
      var state = JSON.parse(ev.data)
      if (state.meter_history) { meter.history(state.meter_history); return }
      if (state.meter) meter.add(state.meter)
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

  // The meter: the server's CPU and memory, a sample a second, the last
  // two minutes. One time axis. CPU is drawn against its own percent scale
  // (a share of one core), memory as a filled shape from zero to the most
  // it reached in the window; the legend and the tooltip carry the values.
  function makeMeter() {
    var canvas = document.getElementById('meter-canvas')
    if (!canvas) return { history: function () {}, add: function () {} }
    var wrap = document.getElementById('meter-wrap')
    var tip = document.getElementById('meter-tip')
    var off = document.getElementById('meter-off')
    var cpuOut = document.getElementById('meter-cpu')
    var memOut = document.getElementById('meter-mem')
    var ctx = canvas.getContext('2d')
    var samples = []
    var hover = null
    var SPAN = 120
    if (off) off.hidden = true

    function mb(b) { return (b / 1048576).toFixed(b < 10485760 ? 1 : 0) + ' MB' }
    function css(name) { return getComputedStyle(document.documentElement).getPropertyValue(name).trim() }
    function niceMax(v) {
      var steps = [5, 10, 20, 25, 50, 100]
      for (var i = 0; i < steps.length; i++) if (v <= steps[i]) return steps[i]
      return Math.ceil(v / 100) * 100
    }

    function draw() {
      var w = wrap.clientWidth, h = wrap.clientHeight, dpr = window.devicePixelRatio || 1
      if (canvas.width !== Math.round(w * dpr) || canvas.height !== Math.round(h * dpr)) {
        canvas.width = Math.round(w * dpr); canvas.height = Math.round(h * dpr)
        canvas.style.width = w + 'px'; canvas.style.height = h + 'px'
      }
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
      ctx.clearRect(0, 0, w, h)
      var L = 40, R = 10, T = 10, B = 22, pw = w - L - R, ph = h - T - B
      var ink = css('--ink-3'), rule = css('--rule-2'), cpuC = css('--cpu'), memC = css('--mem')
      ctx.font = '11px ' + (css('--mono') || 'monospace')
      ctx.textBaseline = 'middle'

      var last = samples.length ? samples[samples.length - 1] : null
      var maxCpu = 0, maxRss = 0
      samples.forEach(function (s) { if (s.cpu > maxCpu) maxCpu = s.cpu; if (s.rss > maxRss) maxRss = s.rss })
      var top = niceMax(Math.max(maxCpu, 5))

      // grid and the CPU scale: recessive
      ctx.strokeStyle = rule; ctx.lineWidth = 1; ctx.fillStyle = ink; ctx.textAlign = 'right'
      ;[0, 0.5, 1].forEach(function (f) {
        var y = Math.round(T + ph - f * ph) + 0.5
        ctx.beginPath(); ctx.moveTo(L, y); ctx.lineTo(L + pw, y); ctx.stroke()
        ctx.fillText((top * f) + '%', L - 6, y)
      })
      ctx.textAlign = 'center'; ctx.textBaseline = 'top'
      ;[[0, '2 min ago'], [0.5, '1 min ago'], [1, 'now']].forEach(function (p) {
        ctx.textAlign = p[0] === 0 ? 'left' : p[0] === 1 ? 'right' : 'center'
        ctx.fillText(p[1], L + p[0] * pw, T + ph + 6)
      })
      if (!last) return

      function x(s) { return L + pw - (last.t - s.t) / SPAN * pw }
      var shown = samples.filter(function (s) { return last.t - s.t <= SPAN })

      // Runs of samples a second apart. The server only samples while it
      // ticks, and it ticks slowly when nobody is connected; a gap is left
      // as a gap, not bridged by a straight line that no sample drew.
      var runs = []
      shown.forEach(function (s, i) {
        if (i === 0 || s.t - shown[i - 1].t > 3) runs.push([])
        runs[runs.length - 1].push(s)
      })
      function memY(s) { return T + ph - s.rss / maxRss * ph * 0.92 }

      // memory: a filled shape, 0 to the window's peak
      if (maxRss > 0) {
        runs.forEach(function (run) {
          ctx.beginPath()
          ctx.moveTo(x(run[0]), T + ph)
          run.forEach(function (s) { ctx.lineTo(x(s), memY(s)) })
          ctx.lineTo(x(run[run.length - 1]), T + ph); ctx.closePath()
          ctx.globalAlpha = 0.14; ctx.fillStyle = memC; ctx.fill(); ctx.globalAlpha = 1
          ctx.beginPath()
          run.forEach(function (s, i) { if (i === 0) ctx.moveTo(x(s), memY(s)); else ctx.lineTo(x(s), memY(s)) })
          ctx.strokeStyle = memC; ctx.lineWidth = 2; ctx.lineJoin = 'round'; ctx.stroke()
        })
        // what the top of the memory shape stands for, in ink
        ctx.fillStyle = ink; ctx.textAlign = 'right'; ctx.textBaseline = 'bottom'
        ctx.fillText('memory peak ' + mb(maxRss), L + pw, T + ph * 0.08 - 3)
      }

      // CPU, over it
      runs.forEach(function (run) {
        ctx.beginPath()
        run.forEach(function (s, i) {
          var px = x(s), py = T + ph - Math.min(s.cpu, top) / top * ph
          if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
        })
        ctx.strokeStyle = cpuC; ctx.lineWidth = 2; ctx.lineJoin = 'round'; ctx.stroke()
      })

      // the hovered moment
      if (hover) {
        var hx = x(hover)
        ctx.strokeStyle = ink; ctx.lineWidth = 1
        ctx.beginPath(); ctx.moveTo(Math.round(hx) + 0.5, T); ctx.lineTo(Math.round(hx) + 0.5, T + ph); ctx.stroke()
        ;[[T + ph - Math.min(hover.cpu, top) / top * ph, cpuC], [memY(hover), memC]].forEach(function (d) {
          ctx.beginPath(); ctx.arc(hx, d[0], 4, 0, Math.PI * 2)
          ctx.fillStyle = d[1]; ctx.fill(); ctx.lineWidth = 2; ctx.strokeStyle = css('--sheet'); ctx.stroke()
        })
      }
    }

    function legend() {
      var last = samples[samples.length - 1]
      if (!last) return
      cpuOut.textContent = last.cpu.toFixed(1) + '%'
      memOut.textContent = mb(last.rss)
    }

    canvas.addEventListener('mousemove', function (ev) {
      if (!samples.length) return
      var r = canvas.getBoundingClientRect(), last = samples[samples.length - 1]
      var L = 40, pw = r.width - 50
      var tAt = last.t - (1 - (ev.clientX - r.left - L) / pw) * SPAN
      var best = null
      samples.forEach(function (s) { if (!best || Math.abs(s.t - tAt) < Math.abs(best.t - tAt)) best = s })
      hover = best
      var ago = last.t - best.t
      tip.hidden = false
      tip.textContent = (ago === 0 ? 'now' : ago + ' s ago') + ' \u00b7 CPU ' + best.cpu.toFixed(1) + '% \u00b7 resident ' + mb(best.rss) + ' \u00b7 heap ' + mb(best.heap)
      draw()
    })
    canvas.addEventListener('mouseleave', function () { hover = null; tip.hidden = true; draw() })
    window.addEventListener('resize', draw)
    if (typeof ResizeObserver !== 'undefined') new ResizeObserver(draw).observe(wrap)

    return {
      history: function (list) { samples = list.slice(-SPAN); legend(); draw() },
      add: function (s) {
        var last = samples[samples.length - 1]
        if (last && s.n <= last.n) return
        samples.push(s)
        if (samples.length > SPAN) samples.shift()
        legend(); draw()
      }
    }
  }
})()
