// /piet's animation, after app.js has mounted piet.blimp (window.BlimpApp,
// actor `piet`). The program owns the window, the list and Play; this file
// owns #piet-stage. After every render it asks `piet <- :scene` which
// program to show and whether to play it again (`run` went up).
//
// /piet/data.json.gz holds, for each program: its compiled image (a PNG),
// npiet's step count, and for every codel npiet landed on, how many steps
// landed there and the step it was first reached (from npiet 1.3f patched
// to count; the patch changes nothing about how a program runs), plus the
// program's real output. For Piet in Piet it also holds the 130x3 program
// it interprets and npiet's trace of it, 34 steps.
(function () {
  var RGB = ['#FFC0C0', '#FF0000', '#C00000', '#FFFFC0', '#FFFF00', '#C0C000', '#C0FFC0', '#00FF00', '#00C000',
    '#C0FFFF', '#00FFFF', '#00C0C0', '#C0C0FF', '#0000FF', '#0000C0', '#FFC0FF', '#FF00FF', '#C000C0']
  function colourOf(ch) { return ch === 'K' ? '#000000' : ch === 'W' ? '#FFFFFF' : RGB[ch.charCodeAt(0) - 97] }
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  function fmt(n) { return n.toLocaleString('en-US') }
  function wait(ms) { return new Promise(function (r) { setTimeout(r, ms) }) }
  function frame() { return new Promise(function (r) { requestAnimationFrame(r) }) }
  function el(tag, cls, text) {
    var e = document.createElement(tag)
    if (cls) e.className = cls
    if (text !== undefined) e.textContent = text
    return e
  }

  // Dim gold for one landing, through orange, to red for the most.
  function heatColour(t) {
    var stops = [[106, 90, 0], [255, 212, 0], [255, 122, 0], [255, 32, 32]]
    var p = Math.min(0.999, Math.max(0, t)) * (stops.length - 1), i = Math.floor(p), f = p - i
    var a = stops[i], b = stops[i + 1]
    return 'rgb(' + a.map(function (v, k) { return Math.round(v + (b[k] - v) * f) }).join(',') + ')'
  }

  function Program(d, inner, root) {
    var self = this
    this.d = d
    this.inner = inner
    this.token = 0
    this.root = el('div', 'piet-program')
    var acts = el('div', 'piet-acts')
    this.acts = ['1 · Assemble', '2 · Run', '3 · Output'].map(function (t) { var a = el('span', 'piet-act', t); acts.appendChild(a); return a })
    var image = el('div', 'piet-image')
    this.canvas = el('canvas')
    this.bar = el('i')
    var barWrap = el('div', 'piet-bar'); barWrap.appendChild(this.bar)
    var meter = el('div', 'piet-meter')
    this.phase = el('span'); this.count = el('span')
    meter.appendChild(this.phase); meter.appendChild(this.count)
    image.appendChild(this.canvas); image.appendChild(barWrap); image.appendChild(meter)
    this.out = el('div', 'piet-output')
    this.root.appendChild(acts); this.root.appendChild(image); this.root.appendChild(this.out)
    root.appendChild(this.root)

    // Fold the tall image into columns, so all of it fits.
    this.ctx = this.canvas.getContext('2d')
    this.colH = Math.ceil(d.height / d.columns)
    this.gap = 14
    this.canvas.width = d.columns * d.width + (d.columns - 1) * this.gap
    this.canvas.height = this.colH
    var H = d.heat, lmax = Math.log(d.maxCount + 1), pts = []
    for (var i = 0; i < H.length; i += 4) {
      var x = H[i], y = H[i + 1], n = H[i + 2], first = H[i + 3], col = Math.floor(y / this.colH)
      pts.push({ x: col * (d.width + this.gap) + x, y: y - col * this.colH, first: first, c: heatColour(Math.log(n + 1) / lmax) })
    }
    pts.sort(function (a, b) { return a.first - b.first })
    this.pts = pts
    this.heat = el('canvas')
    this.heat.width = this.canvas.width; this.heat.height = this.canvas.height
    this.hctx = this.heat.getContext('2d')
    this.buildOutput()
    this.ready = new Promise(function (r) { self.img = new Image(); self.img.onload = r; self.img.src = d.png })
  }

  Program.prototype.setAct = function (k) {
    this.acts.forEach(function (a, i) { a.classList.toggle('piet-on', i === k); a.classList.toggle('piet-done', i < k) })
  }
  Program.prototype.drawImage = function (upTo, alpha) {
    var d = this.d, c = this.ctx
    c.fillStyle = '#000'; c.fillRect(0, 0, this.canvas.width, this.canvas.height)
    c.globalAlpha = alpha === undefined ? 1 : alpha
    for (var col = 0; col < d.columns; col++) {
      var y0 = col * this.colH, rows = Math.max(0, Math.min(this.colH, upTo - y0))
      if (rows > 0) c.drawImage(this.img, 0, y0, d.width, rows, col * (d.width + this.gap), 0, d.width, rows)
    }
    c.globalAlpha = 1
  }
  Program.prototype.scanline = function (row) {
    var col = Math.floor(row / this.colH)
    if (col >= this.d.columns) return
    this.ctx.fillStyle = 'rgba(255,255,255,.9)'
    this.ctx.fillRect(col * (this.d.width + this.gap), row - col * this.colH, this.d.width, 4)
  }
  Program.prototype.plot = function (from, to) {
    for (var i = from; i < to; i++) { var p = this.pts[i]; this.hctx.fillStyle = p.c; this.hctx.fillRect(p.x, p.y - 1, 2, 3) }
  }
  Program.prototype.showFinal = function () {
    this.token++
    this.drawImage(this.d.height, 0.32)
    this.hctx.clearRect(0, 0, this.heat.width, this.heat.height)
    this.plot(0, this.pts.length)
    this.ctx.drawImage(this.heat, 0, 0)
    this.bar.style.width = '100%'
    this.phase.textContent = 'ran ' + fmt(this.d.steps) + ' steps in ' + this.d.seconds + ' s'
    this.count.textContent = fmt(this.pts.length) + ' codels landed on'
    this.setAct(3)
    this.finishOutput()
  }

  // A newer play() or showFinal() bumps the token; an older play() stops.
  Program.prototype.play = async function () {
    var token = ++this.token, self = this, d = this.d
    function live() { return token === self.token }
    this.resetOutput()
    this.setAct(0)
    this.phase.textContent = 'drawing ' + fmt(d.width) + ' × ' + fmt(d.height) + ' codels'
    var t0 = performance.now(), p = 0
    while (p < 1) {
      await frame(); if (!live()) return
      p = Math.min(1, (performance.now() - t0) / 3200)
      var row = Math.floor(p * d.height)
      this.drawImage(row); if (p < 1) this.scanline(row)
      this.bar.style.width = p * 100 + '%'
      this.count.textContent = 'row ' + fmt(row) + ' of ' + fmt(d.height)
    }
    await wait(350); if (!live()) return
    this.setAct(1)
    this.hctx.clearRect(0, 0, this.heat.width, this.heat.height)
    var shown = 0
    t0 = performance.now(); p = 0
    while (p < 1) {
      await frame(); if (!live()) return
      p = Math.min(1, (performance.now() - t0) / 7000)
      var step = Math.floor(p * d.steps), next = shown
      while (next < this.pts.length && this.pts[next].first <= step) next++
      this.plot(shown, next); shown = next
      this.drawImage(d.height, 0.32)
      this.ctx.drawImage(this.heat, 0, 0)
      this.bar.style.width = p * 100 + '%'
      this.phase.textContent = 'npiet, step ' + fmt(step) + ' of ' + fmt(d.steps)
      this.count.textContent = fmt(shown) + ' codels reached'
    }
    this.phase.textContent = 'ran ' + fmt(d.steps) + ' steps in ' + d.seconds + ' s'
    this.setAct(2)
    await this.playOutput(live)
    if (live()) this.setAct(3)
  }

  // --- outputs ---------------------------------------------------------
  Program.prototype.buildOutput = function () {
    var o = this.out, k = this.d.kind
    o.appendChild(el('div', 'piet-eyebrow', k === 'piet-in-piet' ? 'Output: the program it runs, running' : 'Output'))
    if (k === 'piet-in-piet') {
      var wrap = el('div', 'piet-strip'); this.strip = el('canvas'); wrap.appendChild(this.strip); o.appendChild(wrap)
      this.said = el('div', 'piet-said'); o.appendChild(this.said)
      this.status = el('div', 'piet-status'); o.appendChild(this.status)
      this.stackEl = el('div', 'piet-stack'); o.appendChild(this.stackEl)
      this.S = 7
      var W = this.inner.rows[0].length, Hh = this.inner.rows.length
      this.strip.width = W * this.S; this.strip.height = Hh * this.S
    }
    if (k === 'life') {
      this.lifeCanvas = el('canvas', 'piet-life'); o.appendChild(this.lifeCanvas)
      this.lifeGen = el('div', 'piet-said'); o.appendChild(this.lifeGen)
      this.lifeRun = el('div', 'piet-status'); o.appendChild(this.lifeRun)
      var L = this.d.life
      this.lifeCanvas.width = L.width * 4; this.lifeCanvas.height = L.height * 4
    }
    this.term = el('pre', 'piet-terminal'); o.appendChild(this.term)
    if (k === 'mondrian') {
      this.paint = el('canvas', 'piet-painting'); o.appendChild(this.paint)
      var g = this.d.grid; this.paint.width = g[0].length * 12; this.paint.height = g.length * 12
    }
  }
  Program.prototype.resetOutput = function () {
    var k = this.d.kind
    this.term.textContent = ''
    if (k === 'piet-in-piet') { this.drawStrip(-1, 0); this.said.textContent = ''; this.status.textContent = 'waiting for npiet'; this.stackEl.textContent = '' }
    if (k === 'mondrian') this.drawPainting(0)
    if (k === 'life') { this.drawLife(0); this.lifeGen.textContent = ''; this.lifeRun.textContent = 'waiting for npiet' }
  }
  Program.prototype.finishOutput = function () {
    var k = this.d.kind
    this.term.textContent = this.d.text
    if (k === 'piet-in-piet') {
      this.drawStrip(this.inner.trace.length - 1, this.inner.blocks.length)
      this.said.textContent = 'Piet!'
      this.status.textContent = 'step 34 of 34, then trapped: halts'
      this.stackEl.textContent = ''
    }
    if (k === 'mondrian') this.drawPainting(this.d.grid.length)
    if (k === 'life') { var last = this.d.life.frames.length - 1; this.showLife(last); this.term.textContent = this.lifeSummary() }
  }
  Program.prototype.playOutput = async function (live) {
    var k = this.d.kind, lines, i
    if (k === 'mondrian') {
      this.term.textContent = this.d.text
      for (var r = 0; r <= this.d.grid.length; r++) { this.drawPainting(r); await wait(90); if (!live()) return }
    } else if (k === 'life') {
      this.term.textContent = ''
      for (var g = 0; g < this.d.life.frames.length; g++) {
        this.showLife(g); await wait(g < 3 ? 1400 : 260); if (!live()) return
      }
      this.term.textContent = this.lifeSummary()
    } else if (k === 'fact-check') {
      lines = this.d.text.split('\n')
      for (i = 0; i < lines.length; i++) { this.term.textContent += lines[i] + '\n'; await wait(lines[i] ? 160 : 60); if (!live()) return }
    } else {
      await this.playInner(live)
    }
  }
  // Life's boards come from the program's own output, run-length encoded
  // ("1a129K..."), one per generation.
  Program.prototype.lifeCells = function (g) {
    var L = this.d.life
    if (!L.cells) L.cells = []
    if (!L.cells[g]) {
      var out = [], re = /(\d+)([a-rKW])/g, m
      while ((m = re.exec(L.frames[g]))) for (var i = 0; i < +m[1]; i++) out.push(m[2])
      L.cells[g] = out
    }
    return L.cells[g]
  }
  Program.prototype.drawLife = function (g) {
    var L = this.d.life, c = this.lifeCanvas.getContext('2d'), cells = this.lifeCells(g), k = 4
    c.fillStyle = '#000'; c.fillRect(0, 0, L.width * k, L.height * k)
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] === 'K') continue
      c.fillStyle = colourOf(cells[i]); c.fillRect((i % L.width) * k, Math.floor(i / L.width) * k, k, k)
    }
  }
  Program.prototype.showLife = function (g) {
    var r = this.d.life.runs[g]
    this.drawLife(g)
    this.lifeGen.textContent = 'generation ' + g
    var said = r.said ? ', said "' + r.said + '"' : ', said nothing'
    var how = r.how === 'stopped' ? 'stopped at the ' + fmt(this.d.life.limit) + '-step limit' : (r.steps === 0 ? 'halted before taking a step' : 'halted after ' + r.steps + ' steps')
    this.lifeRun.textContent = fmt(r.live) + ' live codels; run as a Piet program, it ' + how + said
  }
  Program.prototype.lifeSummary = function () { return this.d.text }
  Program.prototype.drawPainting = function (rows) {
    var c = this.paint.getContext('2d'), g = this.d.grid
    c.fillStyle = '#fff'; c.fillRect(0, 0, this.paint.width, this.paint.height)
    for (var y = 0; y < rows; y++) for (var x = 0; x < g[y].length; x++) { c.fillStyle = g[y][x]; c.fillRect(x * 12, y * 12, 12, 12) }
  }
  Program.prototype.drawStrip = function (k, laid) {
    var c = this.strip.getContext('2d'), S = this.S, rows = this.inner.rows, W = rows[0].length, H = rows.length
    c.fillStyle = '#000'; c.fillRect(0, 0, W * S, H * S)
    for (var b = 0; b < laid; b++) {
      var cells = this.inner.blocks[b].cells
      for (var j = 0; j < cells.length; j++) { c.fillStyle = colourOf(rows[cells[j][1]][cells[j][0]]); c.fillRect(cells[j][0] * S, cells[j][1] * S, S, S) }
    }
    c.strokeStyle = 'rgba(0,0,0,.18)'; c.lineWidth = 1
    for (var x = 1; x < W; x++) { c.beginPath(); c.moveTo(x * S + 0.5, 0); c.lineTo(x * S + 0.5, H * S); c.stroke() }
    if (k < 0) return
    for (var i = 0; i <= k; i++) {
      var to = this.inner.trace[i].to
      c.fillStyle = 'rgba(0,0,0,.5)'; c.beginPath(); c.arc(to[0] * S + S / 2, to[1] * S + S / 2, S / 6, 0, 7); c.fill()
    }
    var at = this.inner.trace[k].to, cx = at[0] * S + S / 2, cy = at[1] * S + S / 2
    c.fillStyle = '#000'; c.strokeStyle = '#fff'; c.lineWidth = 2
    c.beginPath(); c.arc(cx, cy, S * 0.42, 0, 7); c.fill(); c.stroke()
    var wrap = this.strip.parentNode
    if (wrap.scrollWidth > wrap.clientWidth) wrap.scrollLeft = Math.max(0, at[0] * S - wrap.clientWidth / 2)
  }
  Program.prototype.playInner = async function (live) {
    var B = this.inner.blocks, T = this.inner.trace, b, k
    this.status.textContent = 'the interpreter reads the program it embeds'
    for (b = 1; b <= B.length; b++) {
      this.drawStrip(-1, b)
      this.status.textContent = 'laying block ' + b + ' of ' + B.length + (B[b - 1].op ? ': ' + B[b - 1].op : '')
      await wait(70); if (!live()) return
    }
    await wait(300); if (!live()) return
    var said = ''
    for (k = 0; k < T.length; k++) {
      var t = T[k]
      if (t.action === 'out(char)') said += String.fromCharCode(T[k - 1].stack[0])
      this.drawStrip(k, B.length)
      this.said.textContent = said.replace(/\n$/, '')
      if (k < T.length - 1) this.said.appendChild(el('span', 'piet-cursor', '▌'))
      this.status.textContent = 'step ' + (k + 1) + ' of ' + T.length + ': ' + t.action
      this.stackEl.textContent = ''
      for (var s = 0; s < t.stack.length; s++) this.stackEl.appendChild(el('span', '', String(t.stack[s])))
      await wait(260); if (!live()) return
    }
    this.status.textContent = 'step 34 of 34, then trapped: halts'
    var lines = this.d.text.split('\n')
    for (var i = 0; i < lines.length; i++) { this.term.textContent += lines[i] + '\n'; await wait(220); if (!live()) return }
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var holder = el('div', 'piet-holder')
    var programs = null, current = null, run = -1

    function place() {
      var stage = document.getElementById('piet-stage')
      if (stage && holder.parentNode !== stage) stage.appendChild(holder)
    }
    function ask(msg) { var r = app.blimp.send('piet', msg); return r.ok ? r.value : null }
    function sync() {
      place()
      if (!programs) return
      var s = ask('scene')
      if (!s) return
      if (s.current !== current) {
        if (current && programs[current]) programs[current].root.hidden = true
        current = s.current
        programs[current].root.hidden = false
        programs[current].showFinal()
      }
      if (s.run !== run) {
        var first = run < 0
        run = s.run
        if (!(first && reduce)) programs[current].play()
      }
    }

    var render = view.render
    view.render = function (v) { var out = render.call(view, v); sync(); return out }

    fetch('/piet/data.json.gz')
      .then(function (r) {
        if (!r.ok) throw new Error('/piet/data.json.gz is ' + r.status)
        return new Response(r.body.pipeThrough(new DecompressionStream('gzip'))).json()
      })
      .then(function (data) {
        var made = {}
        data.programs.forEach(function (d) { made[d.kind] = new Program(d, data.inner, holder); made[d.kind].root.hidden = true })
        return Promise.all(Object.keys(made).map(function (k) { return made[k].ready })).then(function () {
          programs = made
          sync()
          setTimeout(function () { view.send('loaded') }, 0)
        })
      })
      .catch(function (e) { console.error('[piet] failed to load the programs:', e) })

    place()
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
