// /phish_lab's pointer, after app.js has mounted phish_lab.blimp
// (window.BlimpApp, actor `lab`). The program draws the chart -- its points
// are one draw() canvas -- but a draw() canvas does not report the mouse,
// so this does:
//
//  - the chart's width, and the screen's pixel ratio, whenever its box
//    changes: `lab <- :resize(w, dpr * 100)`, which redraws;
//  - what is under the pointer. The program answers `lab <- :targets` with
//    every point's place (or every bar's box) once per chart, and this
//    searches them as the hook did: the nearest point within 14px
//    (d3.quadtree().find(x, y, 14)), or the bar whose box holds the
//    pointer. When that changes it asks `lab <- :tip(serial, i)` for the
//    tooltip. Every send to the program ends in a copy of its heap, 30 ms
//    with the performances loaded, so it is asked when the answer can
//    change, not on every move;
//  - a click on a point: `lab <- :pick(serial, i)`, which opens its file.
//
// The tooltip is the hook's .plab-tooltip, placed as the hook placed it.
(function () {
  var CELL = 14

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var tip = document.createElement('div')
    tip.className = 'plab-tooltip'
    document.body.appendChild(tip)

    function chart() { return document.getElementById('plab-chart') }
    function stage() { var c = chart(); return c && c.querySelector('.plab-stage') }
    function canvas() { var s = stage(); return s && s.querySelector('canvas.blimp-draw') }

    function ask(msg, args) {
      var r = app.blimp.send('lab', msg, args)
      return r.ok ? r.value : null
    }

    // -- the chart's size ----------------------------------------------------

    var lastW = -1, lastD = -1
    function resize() {
      var c = chart()
      if (!c) return
      var w = c.clientWidth
      var d = Math.round((window.devicePixelRatio || 1) * 100)
      if (w === lastW && d === lastD) return
      lastW = w; lastD = d
      view.send('resize', w + ', ' + d)
    }

    // -- what can be pointed at ------------------------------------------------

    var targets = null, grid = null
    function current() {
      var s = stage()
      var serial = s && s.dataset.serial
      if (!serial) return null
      if (!targets || String(targets.serial) !== serial) {
        targets = ask('targets')
        grid = targets && targets.kind === 'points' ? index(targets) : null
      }
      return targets && String(targets.serial) === serial ? targets : null
    }

    function index(t) {
      var g = new Map()
      for (var i = 0; i < t.x.length; i++) {
        var k = Math.floor(t.x[i] / CELL) + ',' + Math.floor(t.y[i] / CELL)
        var list = g.get(k)
        if (list) list.push(i); else g.set(k, [i])
      }
      return g
    }

    // d3's quadtree.find(x, y, 14): the nearest point less than 14px away
    function nearest(t, x, y) {
      var cx = Math.floor(x / CELL), cy = Math.floor(y / CELL)
      var best = -1, bestD = CELL * CELL
      for (var a = cx - 1; a <= cx + 1; a++) {
        for (var b = cy - 1; b <= cy + 1; b++) {
          var list = grid.get(a + ',' + b)
          if (!list) continue
          for (var j = 0; j < list.length; j++) {
            var i = list[j], dx = t.x[i] - x, dy = t.y[i] - y, d = dx * dx + dy * dy
            if (d < bestD) { bestD = d; best = i }
          }
        }
      }
      return best
    }

    // the hook's walk over the bins: the first whose bar holds the pointer
    function bin(t, x, y) {
      for (var i = 0; i < t.boxes.length; i++) {
        var b = t.boxes[i]
        if (x >= b[0] && x <= b[1] && y >= b[2] && y <= b[3]) return i
      }
      return -1
    }

    function under(e) {
      var cv = canvas()
      if (!cv || e.target !== cv) return null
      var t = current()
      if (!t) return null
      var r = cv.getBoundingClientRect()
      var x = e.clientX - r.left, y = e.clientY - r.top
      var i = t.kind === 'points' ? nearest(t, x, y) : bin(t, x, y)
      return i < 0 ? null : { serial: t.serial, i: i, kind: t.kind }
    }

    // -- the tooltip -----------------------------------------------------------

    var shown = null
    function hide() { tip.style.display = 'none'; shown = null }
    function text(s) { var d = document.createElement('div'); d.textContent = s; return d.innerHTML }

    document.addEventListener('mousemove', function (e) {
      var cv = canvas()
      var hit = under(e)
      if (!hit) { hide(); if (cv) cv.style.cursor = 'default'; return }
      cv.style.cursor = 'pointer'
      var key = hit.serial + ':' + hit.i
      if (shown !== key) {
        var t = ask('tip', hit.serial + ', ' + hit.i)
        if (!t) return hide()
        tip.innerHTML = '<b>' + text(t.t) + '</b>' + t.l.map(text).join('<br>')
        shown = key
      }
      tip.style.display = 'block'
      var left = Math.min(e.clientX + 14, window.innerWidth - tip.offsetWidth - 8)
      tip.style.left = left + 'px'
      tip.style.top = (e.clientY + 14) + 'px'
    })
    document.addEventListener('mouseout', function (e) { if (e.target === canvas()) hide() })
    document.addEventListener('click', function (e) {
      var hit = under(e)
      if (hit && hit.kind === 'points') view.send('pick', hit.serial + ', ' + hit.i)
    })

    // -- watching the box ------------------------------------------------------

    var observed = null
    var ro = new ResizeObserver(resize)
    function watch() {
      var c = chart()
      if (c && c !== observed) { observed = c; ro.observe(c) }
      resize()
    }
    window.addEventListener('resize', resize)
    watch()
    // #plab-chart comes with the program's first render; should a render
    // ever replace it, this watches the new one
    new MutationObserver(watch).observe(document.getElementById('blimp-app'), { childList: true, subtree: true })
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start)
})()
