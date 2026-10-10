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


  // --- Fill the page ------------------------------------------------------
  // Conway's Life over the whole window, in Piet's colours, in this script:
  // JavaScript, not npiet. It is seeded with the 130x3 Piet program Life ran
  // on in piet-programs/life, stamped across the page in both orientations,
  // with that program's colour rule (a newborn takes the colour two of its
  // three parents share, else the first's in reading order). The board wraps
  // at the edges. Dying codels fade instead of vanishing, so the page keeps a
  // trace of what lived there; when it goes quiet, another copy is stamped in.
  var CELL = 6, BLACK_CODE = 19
  function hexRGB(h) { return [parseInt(h.slice(1, 3), 16), parseInt(h.slice(3, 5), 16), parseInt(h.slice(5, 7), 16)] }
  var RGB3 = RGB.map(hexRGB)

  function Fill(rows) {
    var self = this
    this.rows = rows
    this.root = el('div', 'piet-fill-layer')
    this.canvas = el('canvas', 'piet-fill-canvas')
    this.root.appendChild(this.canvas)
    var card = el('div', 'piet-fill-card')
    card.setAttribute('role', 'dialog')
    card.setAttribute('aria-label', 'What this is')
    var h = el('div', 'piet-fill-title', "Life, filling the page")
    var p1 = el('p', '', "Conway's Game of Life in Piet's twenty colours, running in your browser. It started from the 130 by 3 Piet program that prints Piet!, the one the Life program on this page plays on, stamped across the window.")
    var p2 = el('p', '', "A codel with two or three live neighbours lives; an empty one with exactly three is born, in the colour two of them share, or the first's. When the page goes quiet another copy of the program is stamped in. Dying codels fade, so it paints its own history.")
    var p3 = el('p', 'piet-fill-hint', 'Click anywhere to stamp the program yourself.')
    this.stats = el('div', 'piet-fill-stats')
    var buttons = el('div', 'piet-fill-buttons')
    var hide = el('button', 'piet-fill-btn', 'Hide this')
    hide.type = 'button'
    var close = el('button', 'piet-fill-btn', 'Close (Esc)')
    close.type = 'button'
    buttons.appendChild(hide); buttons.appendChild(close)
    ;[h, p1, p2, p3, this.stats, buttons].forEach(function (n) { card.appendChild(n) })
    this.root.appendChild(card)
    var peek = el('button', 'piet-fill-btn piet-fill-peek', 'What is this?')
    peek.type = 'button'
    peek.hidden = true
    this.root.appendChild(peek)
    hide.onclick = function (e) { e.stopPropagation(); card.hidden = true; peek.hidden = false }
    peek.onclick = function (e) { e.stopPropagation(); card.hidden = false; peek.hidden = true }
    close.onclick = function (e) { e.stopPropagation(); self.close() }
    card.onclick = function (e) { e.stopPropagation() }
    this.onKey = function (e) { if (e.key === 'Escape') self.close() }
    document.addEventListener('keydown', this.onKey)
    this.canvas.addEventListener('click', function (e) {
      var r = self.canvas.getBoundingClientRect()
      self.stamp(Math.floor((e.clientX - r.left) / CELL), Math.floor((e.clientY - r.top) / CELL), Math.random() < 0.5)
    })
    document.body.appendChild(this.root)
    this.start()
  }

  Fill.prototype.start = function () {
    this.W = Math.ceil(window.innerWidth / CELL)
    this.H = Math.ceil(window.innerHeight / CELL)
    this.board = new Uint8Array(this.W * this.H).fill(BLACK_CODE)
    this.next = new Uint8Array(this.W * this.H)
    this.glow = new Float32Array(this.W * this.H * 3)
    this.canvas.width = this.W; this.canvas.height = this.H
    this.ctx = this.canvas.getContext('2d')
    this.image = this.ctx.createImageData(this.W, this.H)
    this.generation = 0; this.stamps = 0; this.live = 0; this.quiet = 0
    var n = Math.max(4, Math.round(this.W * this.H / 9000))
    for (var i = 0; i < n; i++) this.stamp(Math.floor(Math.random() * this.W), Math.floor(Math.random() * this.H), i % 2 === 1)
    this.paint()
    var self = this
    if (reduce) {
      for (var g = 0; g < 240; g++) this.step()
      this.paint(); this.report()
      return
    }
    var last = 0
    function loop(t) {
      if (!self.root.isConnected) return
      if (t - last > 45) { self.step(); last = t }
      self.paint()
      self.raf = requestAnimationFrame(loop)
    }
    this.raf = requestAnimationFrame(loop)
  }

  // The program's codels, from (x, y), along the row or down the column.
  Fill.prototype.stamp = function (x0, y0, vertical) {
    var W = this.W, H = this.H, rows = this.rows
    for (var r = 0; r < rows.length; r++) for (var c = 0; c < rows[r].length; c++) {
      var ch = rows[r][c]
      if (ch === 'K') continue
      var x = vertical ? x0 + r : x0 + c, y = vertical ? y0 + c : y0 + r
      x = ((x % W) + W) % W; y = ((y % H) + H) % H
      this.board[y * W + x] = ch === 'W' ? 18 : ch.charCodeAt(0) - 97
    }
    this.stamps++
    this.report()
  }

  Fill.prototype.step = function () {
    var W = this.W, H = this.H, b = this.board, nb = this.next, live = 0
    for (var y = 0; y < H; y++) {
      var ym = (y + H - 1) % H, yp = (y + 1) % H
      for (var x = 0; x < W; x++) {
        var xm = (x + W - 1) % W, xp = (x + 1) % W
        // neighbours in reading order
        var ns = [b[ym * W + xm], b[ym * W + x], b[ym * W + xp], b[y * W + xm], b[y * W + xp], b[yp * W + xm], b[yp * W + x], b[yp * W + xp]]
        var n = 0, f1 = 0, f2 = 0, f3 = 0
        for (var k = 0; k < 8; k++) {
          var c = ns[k]
          if (c === BLACK_CODE) continue
          if (n === 0) f1 = c; else if (n === 1) f2 = c; else if (n === 2) f3 = c
          n++
        }
        var here = b[y * W + x], out = BLACK_CODE
        if (here !== BLACK_CODE) { if (n === 2 || n === 3) out = here }
        else if (n === 3) out = (f1 === f2 || f1 === f3) ? f1 : (f2 === f3 ? f2 : f1)
        nb[y * W + x] = out
        if (out !== BLACK_CODE) live++
      }
    }
    this.board = nb; this.next = b
    this.generation++
    this.live = live
    // Quiet: little alive for a while, or nothing changing in the count.
    this.quiet = live < W * H * 0.004 ? this.quiet + 1 : 0
    if (this.quiet > 20 || this.generation % 400 === 0) {
      this.stamp(Math.floor(Math.random() * W), Math.floor(Math.random() * H), Math.random() < 0.5)
      this.quiet = 0
    }
    if (this.generation % 10 === 0) this.report()
  }

  Fill.prototype.paint = function () {
    var W = this.W, H = this.H, b = this.board, g = this.glow, d = this.image.data
    for (var i = 0; i < W * H; i++) {
      var c = b[i], o = i * 3
      if (c !== BLACK_CODE) {
        var rgb = c === 18 ? [255, 255, 255] : RGB3[c]
        g[o] = rgb[0]; g[o + 1] = rgb[1]; g[o + 2] = rgb[2]
      } else {
        g[o] *= 0.965; g[o + 1] *= 0.965; g[o + 2] *= 0.965
      }
      var p = i * 4
      d[p] = g[o]; d[p + 1] = g[o + 1]; d[p + 2] = g[o + 2]; d[p + 3] = 255
    }
    this.ctx.putImageData(this.image, 0, 0)
  }

  Fill.prototype.report = function () {
    this.stats.textContent = 'generation ' + fmt(this.generation) + ' · ' + fmt(this.live) + ' live codels · ' +
      fmt(this.stamps) + ' copies of the program stamped · ' + this.W + ' × ' + this.H + ' codels'
  }

  Fill.prototype.close = function () {
    cancelAnimationFrame(this.raf)
    document.removeEventListener('keydown', this.onKey)
    this.root.remove()
  }


  // --- Tile the page ------------------------------------------------------
  // As many small Life games as fit, each its own Piet program: drawn here,
  // as piet-programs/piet-in-piet/inner.py draws its program, to print a
  // word. After every generation each tile is run as a Piet program, by the
  // interpreter below, and its label says what it printed. A tile that has
  // come apart is replaced by a new program with a new word.

  // PIET-INTERPRETER-BEGIN
  // A Piet interpreter that does what npiet 1.3f does where the specification
  // leaves room (division by zero pushes 99999999; in() with nothing to read
  // pushes nothing; out(char) writes the low byte; a black start codel ends
  // the program). Colours are 0-17 (hue * 3 + lightness), 18 white, 19
  // black. Returns {steps, halted, said: [byte codes]}.
  function runPiet(board, W, H, limit) {
    var BLACKC = 19, WHITEC = 18
    function at(x, y) { return x < 0 || y < 0 || x >= W || y >= H ? BLACKC : board[y * W + x] }
    var cache = {}
    function block(x0, y0) {
      var key = y0 * W + x0
      if (cache[key]) return cache[key]
      var colour = at(x0, y0), seen = {}, qx = [x0], qy = [y0]
      seen[key] = 1
      for (var h = 0; h < qx.length; h++) {
        var d4 = [[1, 0], [0, 1], [-1, 0], [0, -1]]
        for (var d = 0; d < 4; d++) {
          var nx = qx[h] + d4[d][0], ny = qy[h] + d4[d][1], k = ny * W + nx
          if (!seen[k] && at(nx, ny) === colour) { seen[k] = 1; qx.push(nx); qy.push(ny) }
        }
      }
      var DX = [1, 0, -1, 0], DY = [0, 1, 0, -1], exits = []
      for (var dp = 0; dp < 4; dp++) for (var cc = 0; cc < 2; cc++) {
        var side = (dp + (cc === 0 ? 3 : 1)) % 4, best = 0
        for (var i = 1; i < qx.length; i++) {
          var far = qx[i] * DX[dp] + qy[i] * DY[dp], bf = qx[best] * DX[dp] + qy[best] * DY[dp]
          var al = qx[i] * DX[side] + qy[i] * DY[side], ba = qx[best] * DX[side] + qy[best] * DY[side]
          if (far > bf || (far === bf && al > ba)) best = i
        }
        exits.push([qx[best], qy[best]])
      }
      var b = { size: qx.length, exits: exits }
      for (var j = 0; j < qx.length; j++) cache[qy[j] * W + qx[j]] = b
      return b
    }
    var stack = [], said = [], x = 0, y = 0, dp = 0, cc = 0, steps = 0
    var DX2 = [1, 0, -1, 0], DY2 = [0, 1, 0, -1]
    function mod(a, b) { return a % b }
    function command(op, size) {
      var a, b
      switch (op) {
        case 1: stack.push(size); break
        case 2: if (stack.length >= 1) stack.pop(); break
        case 3: if (stack.length >= 2) { b = stack.pop(); stack.push(stack.pop() + b) } break
        case 4: if (stack.length >= 2) { b = stack.pop(); stack.push(stack.pop() - b) } break
        case 5: if (stack.length >= 2) { b = stack.pop(); stack.push(stack.pop() * b) } break
        case 6: if (stack.length >= 2) { b = stack.pop(); a = stack.pop(); stack.push(b === 0 ? 99999999 : Math.trunc(a / b)) } break
        case 7: if (stack.length >= 2) { b = stack.pop(); a = stack.pop(); stack.push(b === 0 ? 99999999 : a % b) } break
        case 8: if (stack.length >= 1) stack.push(stack.pop() === 0 ? 1 : 0); break
        case 9: if (stack.length >= 2) { b = stack.pop(); stack.push(stack.pop() > b ? 1 : 0) } break
        case 10: if (stack.length >= 1) dp = (((dp + stack.pop()) % 4) + 4) % 4; break
        case 11: if (stack.length >= 1) { if (stack.pop() % 2 !== 0) cc = 1 - cc } break
        case 12: if (stack.length >= 1) { a = stack.pop(); stack.push(a, a) } break
        case 13:
          if (stack.length >= 2) {
            var turns = stack.pop(), depth = stack.pop()
            if (depth <= 0 || depth > stack.length) { stack.push(depth, turns); break }
            var n = ((turns % depth) + depth) % depth
            for (var t = 0; t < n; t++) { var top = stack.pop(); stack.splice(stack.length - depth + 1, 0, top) }
          }
          break
        case 16: if (stack.length >= 1) { String(stack.pop()).split('').forEach(function (c) { said.push(c.charCodeAt(0)) }) } break
        case 17: if (stack.length >= 1) said.push(((stack.pop() % 256) + 256) % 256); break
      }
    }
    if (at(0, 0) === BLACKC) return { steps: 0, halted: true, said: said }
    while (steps < limit) {
      var blk = block(x, y), colour = at(x, y), moved = false
      for (var attempt = 0; attempt < 8; attempt++) {
        var e = blk.exits[dp * 2 + cc], nx = e[0] + DX2[dp], ny = e[1] + DY2[dp], next = at(nx, ny)
        if (next === WHITEC) throw new Error('white: not handled here')
        if (next !== BLACKC) {
          var dh = (Math.floor(next / 3) - Math.floor(colour / 3) + 6) % 6
          var dl = (next % 3 - colour % 3 + 3) % 3
          x = nx; y = ny; steps++
          command(dh * 3 + dl, blk.size)
          moved = true
          break
        }
        if (attempt % 2 === 0) cc = 1 - cc; else dp = (dp + 1) % 4
      }
      if (!moved) return { steps: steps, halted: true, said: said }
    }
    return { steps: steps, halted: false, said: said }
  }
  // PIET-INTERPRETER-END

  // inner.py's layout: one row of blocks at y = 1 between black rows, the
  // start codel (0, 0) joined to the first block, and a block three tall at
  // the end that traps the program. Colours advance by each command's
  // (hue, lightness) steps; a push pushes the size of the block it leaves.
  var OPS = { push: [0, 1], mul: [1, 2], add: [1, 0], outc: [5, 2] }
  function stepColour(c, op) { var d = OPS[op]; return ((Math.floor(c / 3) + d[0]) % 6) * 3 + (c % 3 + d[1]) % 3 }
  function drawProgram(word, startColour) {
    var ops = []
    for (var i = 0; i < word.length; i++) {
      var n = word.charCodeAt(i), a = Math.max(2, Math.floor(Math.sqrt(n))), b = Math.floor(n / a), r = n % a
      ops.push(['push', a], ['push', b], ['mul', 1])
      if (r) ops.push(['push', r], ['add', 1])
      ops.push(['outc', 1])
    }
    var row = [], colour = startColour
    ops.forEach(function (o, k) {
      for (var j = 0; j < (k === 0 ? o[1] - 1 : o[1]); j++) row.push(colour)
      colour = stepColour(colour, o[0])
    })
    row.push(colour)
    var w = row.length + 1, grid = []
    for (var y = 0; y < 3; y++) { grid.push([]); for (var x = 0; x < w; x++) grid[y].push(19) }
    for (var x2 = 0; x2 < row.length; x2++) grid[1][x2] = row[x2]
    grid[0][0] = row[0]
    var t = row.length - 1
    grid[0][t] = grid[2][t] = row[t]
    return grid
  }

  var WORDS = ['hi', 'ok', 'yes', 'no', 'art', 'sky', 'sun', 'red', 'blue', 'go', 'wow', 'fin', 'ah', 'oh', 'Piet', 'life', 'zap', 'hum', 'joy', 'pop']
  var TILE_W = 104, TILE_H = 48, TILE_CELL = 3

  function Tiles() {
    var self = this
    this.root = el('div', 'piet-fill-layer')
    this.canvas = el('canvas', 'piet-fill-canvas')
    this.root.appendChild(this.canvas)
    this.labels = el('div', 'piet-tile-labels')
    this.root.appendChild(this.labels)
    var card = el('div', 'piet-fill-card')
    card.setAttribute('role', 'dialog')
    card.setAttribute('aria-label', 'What this is')
    card.appendChild(el('div', 'piet-fill-title', 'Many games, each its own program'))
    card.appendChild(el('p', '', 'Every tile is a Piet program, drawn here to print a word, and its own game of Life. After every generation the tile is run as a Piet program and its label shows what it printed.'))
    card.appendChild(el('p', '', 'Generation 0 says its word. Life takes the program apart within a few generations: soon its start codel is cut off and it cannot take a step. Then it is replaced by a new program with a new word.'))
    card.appendChild(el('p', 'piet-fill-hint', 'Running in your browser: the interpreter does what npiet does, for at most 200 steps a run.'))
    this.stats = el('div', 'piet-fill-stats')
    card.appendChild(this.stats)
    var buttons = el('div', 'piet-fill-buttons')
    var hide = el('button', 'piet-fill-btn', 'Hide this'); hide.type = 'button'
    var close = el('button', 'piet-fill-btn', 'Close (Esc)'); close.type = 'button'
    buttons.appendChild(hide); buttons.appendChild(close); card.appendChild(buttons)
    this.root.appendChild(card)
    var peek = el('button', 'piet-fill-btn piet-fill-peek', 'What is this?'); peek.type = 'button'; peek.hidden = true
    this.root.appendChild(peek)
    hide.onclick = function () { card.hidden = true; peek.hidden = false }
    peek.onclick = function () { card.hidden = false; peek.hidden = true }
    close.onclick = function () { self.close() }
    this.onKey = function (e) { if (e.key === 'Escape') self.close() }
    document.addEventListener('keydown', this.onKey)
    document.body.appendChild(this.root)
    this.start()
  }

  Tiles.prototype.start = function () {
    var cols = Math.max(1, Math.floor(window.innerWidth / (TILE_W * TILE_CELL + 6)))
    var rows = Math.max(1, Math.floor(window.innerHeight / (TILE_H * TILE_CELL + 6)))
    this.cols = cols; this.rowsN = rows
    this.CW = cols * (TILE_W + 2); this.CH = rows * (TILE_H + 2)
    this.canvas.width = this.CW; this.canvas.height = this.CH
    this.canvas.style.width = this.CW * TILE_CELL + 'px'; this.canvas.style.height = this.CH * TILE_CELL + 'px'
    this.canvas.style.left = Math.floor((window.innerWidth - this.CW * TILE_CELL) / 2) + 'px'
    this.canvas.style.top = Math.floor((window.innerHeight - this.CH * TILE_CELL) / 2) + 'px'
    this.canvas.style.right = 'auto'; this.canvas.style.bottom = 'auto'
    this.ctx = this.canvas.getContext('2d')
    this.image = this.ctx.createImageData(this.CW, this.CH)
    this.labels.textContent = ''
    this.tiles = []; this.born = 0; this.ticks = 0
    for (var i = 0; i < cols * rows; i++) {
      var label = el('div', 'piet-tile-label')
      label.style.left = (parseInt(this.canvas.style.left) + (i % cols) * (TILE_W + 2) * TILE_CELL + 4) + 'px'
      label.style.top = (parseInt(this.canvas.style.top) + (Math.floor(i / cols) * (TILE_H + 2) + TILE_H) * TILE_CELL - 16) + 'px'
      this.labels.appendChild(label)
      var tile = { label: label, glow: new Float32Array(TILE_W * TILE_H * 3) }
      this.tiles.push(tile)
      this.birth(tile, i)
    }
    var self = this
    if (reduce) { this.paint(); return }
    var last = 0
    function loop(t) {
      if (!self.root.isConnected) return
      if (t - last > 120) { self.tick(); last = t }
      self.paint()
      self.raf = requestAnimationFrame(loop)
    }
    this.raf = requestAnimationFrame(loop)
  }

  Tiles.prototype.birth = function (tile, i) {
    var word = WORDS[(this.born + i * 7) % WORDS.length]
    this.born++
    var grid = drawProgram(word, Math.floor(Math.random() * 18))
    tile.word = word; tile.gen = 0; tile.quiet = 0
    // Generation 0 says the word: hold it there a moment before Life starts.
    // The first programs on the page wait different lengths, so words keep
    // surfacing at different times.
    tile.hold = 16 + Math.floor(Math.random() * (this.ticks === 0 ? 60 : 10))
    tile.board = new Uint8Array(TILE_W * TILE_H).fill(19)
    tile.next = new Uint8Array(TILE_W * TILE_H)
    for (var y = 0; y < grid.length; y++) for (var x = 0; x < grid[y].length && x < TILE_W; x++) tile.board[y * TILE_W + x] = grid[y][x]
    this.run(tile)
  }

  Tiles.prototype.run = function (tile) {
    var r = runPiet(tile.board, TILE_W, TILE_H, 200)
    var text = r.said.map(function (c) { return c >= 32 && c < 127 ? String.fromCharCode(c) : (c === 10 ? '' : '·') }).join('')
    tile.said = text
    var how = r.steps === 0 ? 'cannot take a step' : (r.halted ? 'halted after ' + r.steps : 'still going at ' + r.steps)
    tile.label.textContent = '"' + tile.word + '" · gen ' + tile.gen + ' · ' + (text ? 'says ' + JSON.stringify(text.length > 18 ? text.slice(0, 18) + '…' : text) : 'silent') + ' · ' + how
    tile.label.classList.toggle('piet-tile-speaks', text.length > 0)
    tile.steps = r.steps
  }

  // Life on a tile, wrapping at its edges, with the colour rule of
  // piet-programs/life.
  function lifeStep(b, nb, W, H) {
    var live = 0
    for (var y = 0; y < H; y++) {
      var ym = (y + H - 1) % H, yp = (y + 1) % H
      for (var x = 0; x < W; x++) {
        var xm = (x + W - 1) % W, xp = (x + 1) % W
        var ns = [b[ym * W + xm], b[ym * W + x], b[ym * W + xp], b[y * W + xm], b[y * W + xp], b[yp * W + xm], b[yp * W + x], b[yp * W + xp]]
        var n = 0, f1 = 0, f2 = 0, f3 = 0
        for (var k = 0; k < 8; k++) {
          var c = ns[k]
          if (c === 19) continue
          if (n === 0) f1 = c; else if (n === 1) f2 = c; else if (n === 2) f3 = c
          n++
        }
        var here = b[y * W + x], out = 19
        if (here !== 19) { if (n === 2 || n === 3) out = here }
        else if (n === 3) out = (f1 === f2 || f1 === f3) ? f1 : (f2 === f3 ? f2 : f1)
        nb[y * W + x] = out
        if (out !== 19) live++
      }
    }
    return live
  }

  Tiles.prototype.tick = function () {
    this.ticks++
    var self = this, speaking = 0
    this.tiles.forEach(function (tile, i) {
      if (tile.hold > 0) {
        tile.hold--
        if (tile.said) speaking++
        return
      }
      var live = lifeStep(tile.board, tile.next, TILE_W, TILE_H)
      var t = tile.board; tile.board = tile.next; tile.next = t
      tile.gen++
      self.run(tile)
      if (tile.said) speaking++
      tile.quiet = tile.steps === 0 ? tile.quiet + 1 : 0
      // Come apart: no step for a while, or nearly nothing left alive.
      if (tile.quiet > 40 + (i % 5) * 9 || live < 6) self.birth(tile, i)
    })
    this.stats.textContent = fmt(this.tiles.length) + ' programs on the page · ' + fmt(this.born) + ' born so far · ' + speaking + ' saying something right now'
  }

  Tiles.prototype.paint = function () {
    var d = this.image.data, CW = this.CW, cols = this.cols
    for (var i = 0; i < d.length; i += 4) { d[i] = 26; d[i + 1] = 28; d[i + 2] = 31; d[i + 3] = 255 }
    for (var ti = 0; ti < this.tiles.length; ti++) {
      var tile = this.tiles[ti], ox = (ti % cols) * (TILE_W + 2) + 1, oy = Math.floor(ti / cols) * (TILE_H + 2) + 1
      var b = tile.board, g = tile.glow
      for (var y = 0; y < TILE_H; y++) for (var x = 0; x < TILE_W; x++) {
        var c = b[y * TILE_W + x], o = (y * TILE_W + x) * 3
        if (c !== 19) { var rgb = c === 18 ? [255, 255, 255] : RGB3[c]; g[o] = rgb[0]; g[o + 1] = rgb[1]; g[o + 2] = rgb[2] }
        else { g[o] *= 0.93; g[o + 1] *= 0.93; g[o + 2] *= 0.93 }
        var p = ((oy + y) * CW + ox + x) * 4
        d[p] = g[o]; d[p + 1] = g[o + 1]; d[p + 2] = g[o + 2]
      }
    }
    this.ctx.putImageData(this.image, 0, 0)
  }

  Tiles.prototype.close = function () {
    cancelAnimationFrame(this.raf)
    document.removeEventListener('keydown', this.onKey)
    this.root.remove()
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var holder = el('div', 'piet-holder')
    var programs = null, current = null, run = -1, fill = 0, tile = 0, innerRows = null, filling = null

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
      if (s.fill > fill) {
        fill = s.fill
        if (filling) filling.close()
        filling = new Fill(innerRows)
      }
      if (s.tile > tile) {
        tile = s.tile
        if (filling) filling.close()
        filling = new Tiles()
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
          innerRows = data.inner.rows
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
