// The generative half of /piet, shared by /piet (its Fill the page and Tile
// the page buttons) and /piet/life, which is only this.
//
//   PietArt.Fill(rows, opts)  Conway's Life over the whole window, in Piet's
//                             colours, seeded with a Piet program's rows.
//   PietArt.Tiles(opts)       as many small games as fit, each its own Piet
//                             program, each run as one after every generation.
//
// opts.standalone: the layer is the page, so its card has no Close; it
// links back to /piet and offers the other mode (opts.onSwitch).
(function () {
  var RGB = ['#FFC0C0', '#FF0000', '#C00000', '#FFFFC0', '#FFFF00', '#C0C000', '#C0FFC0', '#00FF00', '#00C000',
    '#C0FFFF', '#00FFFF', '#00C0C0', '#C0C0FF', '#0000FF', '#0000C0', '#FFC0FF', '#FF00FF', '#C000C0']
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  function fmt(n) { return n.toLocaleString('en-US') }
  function el(tag, cls, text) {
    var e = document.createElement(tag)
    if (cls) e.className = cls
    if (text !== undefined) e.textContent = text
    return e
  }

  // The 130x3 Piet program that prints Piet!: piet-in-piet runs it, and
  // piet-programs/life plays Life on it. One letter a codel: a-r the
  // eighteen colours, K black.
  var INNER_ROWS = [
    'aKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKrK',
    'aaaaaaabbbbbbbbbbceaaaaaaaaaabbbbbbbbbbceeeeefieeeeeeeeeeffffffffffdigjiiiiiiiiiiggggggggggghjjjjjjknjjjjjkkkkkklnnnornnnooomrparK',
    'KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKrK'
  ]

  // Close, or on a page of its own, the other mode and the way back.
  function cardButtons(buttons, opts, switchLabel) {
    if (!opts.standalone) {
      var close = el('button', 'piet-fill-btn', 'Close (Esc)')
      close.type = 'button'
      buttons.appendChild(close)
      return close
    }
    var other = el('button', 'piet-fill-btn', switchLabel)
    other.type = 'button'
    other.onclick = function (e) { e.stopPropagation(); if (opts.onSwitch) opts.onSwitch() }
    buttons.appendChild(other)
    var back = el('a', 'piet-fill-btn', 'The four programs, at /piet')
    back.href = '/piet'
    buttons.appendChild(back)
    return null
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

  function Fill(rows, opts) {
    var self = this
    opts = opts || {}
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
    buttons.appendChild(hide)
    var close = cardButtons(buttons, opts, 'Many programs instead')
    ;[h, p1, p2, p3, this.stats, buttons].forEach(function (n) { card.appendChild(n) })
    this.root.appendChild(card)
    var peek = el('button', 'piet-fill-btn piet-fill-peek', 'What is this?')
    peek.type = 'button'
    peek.hidden = true
    this.root.appendChild(peek)
    hide.onclick = function (e) { e.stopPropagation(); card.hidden = true; peek.hidden = false }
    peek.onclick = function (e) { e.stopPropagation(); card.hidden = false; peek.hidden = true }
    if (close) close.onclick = function (e) { e.stopPropagation(); self.close() }
    card.onclick = function (e) { e.stopPropagation() }
    this.onKey = function (e) { if (e.key === 'Escape' && !opts.standalone) self.close() }
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

  function Tiles(opts) {
    var self = this
    opts = opts || {}
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
    buttons.appendChild(hide)
    var close = cardButtons(buttons, opts, 'One big board instead')
    card.appendChild(buttons)
    this.root.appendChild(card)
    var peek = el('button', 'piet-fill-btn piet-fill-peek', 'What is this?'); peek.type = 'button'; peek.hidden = true
    this.root.appendChild(peek)
    hide.onclick = function () { card.hidden = true; peek.hidden = false }
    peek.onclick = function () { card.hidden = false; peek.hidden = true }
    if (close) close.onclick = function () { self.close() }
    this.onKey = function (e) { if (e.key === 'Escape' && !opts.standalone) self.close() }
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

  window.PietArt = { Fill: Fill, Tiles: Tiles, runPiet: runPiet, drawProgram: drawProgram, lifeStep: lifeStep, INNER_ROWS: INNER_ROWS }
})()
