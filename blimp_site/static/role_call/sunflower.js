// The sunflower behind /role-call: a canvas whose drawing is decided by a
// Blimp program, static/role_call/sunflower.blimp.
//
// This is the BlimpCanvas hook from blog #46 (assets/js/hooks/blimp_canvas.js),
// without LiveView: the program is evaluated once in an interpreter of its
// own (a second Blimp, beside the page's; both programs are top-level Blimp
// and would share one namespace otherwise), and on every animation frame
// this sends `app <- :frame(w, h)` and plays the reply, a list of commands,
// onto #sunflower-bg. No drawing decision is made here.
//
// Commands, each a tuple whose first element names it:
//
//   {:save}  {:restore}
//   {:fill, css}  {:stroke, css}  {:alpha, a}  {:shadow, blur, css}
//   {:line_width, w}  {:line_cap, "round" | "butt" | "square"}
//   {:rect, x, y, w, h}                          fillRect
//   {:circle, x, y, r}                           filled arc
//   {:ellipse, x, y, rx, ry, rotation}           filled ellipse
//   {:polyline, [x0, y0, x1, y1, ...]}           stroked open path
//   {:bezier, x0, y0, c1x, c1y, c2x, c2y, x, y}  stroked cubic curve
//
// An unknown command stops the animation and says which, rather than being
// skipped: a picture with a piece silently missing looks like it worked.
//
// The canvas is an element of the page's program's view. The program keeps
// it (its parents keep their number of children, so they are patched, not
// rebuilt), but should a render ever replace it, the next frame draws on
// the new one.
(function () {
  function play(ctx, commands) {
    for (var i = 0; i < commands.length; i++) {
      var c = commands[i]
      switch (c[0]) {
        case 'save': ctx.save(); break
        case 'restore': ctx.restore(); break
        case 'fill': ctx.fillStyle = c[1]; break
        case 'stroke': ctx.strokeStyle = c[1]; break
        case 'alpha': ctx.globalAlpha = c[1]; break
        case 'shadow': ctx.shadowBlur = c[1]; ctx.shadowColor = c[2]; break
        case 'line_width': ctx.lineWidth = c[1]; break
        case 'line_cap': ctx.lineCap = c[1]; break
        case 'rect': ctx.fillRect(c[1], c[2], c[3], c[4]); break
        case 'circle':
          ctx.beginPath()
          ctx.arc(c[1], c[2], c[3], 0, Math.PI * 2)
          ctx.fill()
          break
        case 'ellipse':
          ctx.beginPath()
          ctx.ellipse(c[1], c[2], c[3], c[4], c[5], 0, Math.PI * 2)
          ctx.fill()
          break
        case 'polyline':
          var p = c[1]
          ctx.beginPath()
          for (var j = 0; j < p.length; j += 2) {
            if (j === 0) ctx.moveTo(p[j], p[j + 1])
            else ctx.lineTo(p[j], p[j + 1])
          }
          ctx.stroke()
          break
        case 'bezier':
          ctx.beginPath()
          ctx.moveTo(c[1], c[2])
          ctx.bezierCurveTo(c[3], c[4], c[5], c[6], c[7], c[8])
          ctx.stroke()
          break
        default:
          throw new Error('sunflower: unknown draw command ' + JSON.stringify(c[0]))
      }
    }
  }

  async function start() {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    await blimp.init('/blimp/blimp.wasm')
    var res = await fetch('/role-call/sunflower.blimp')
    if (!res.ok) throw new Error('/role-call/sunflower.blimp is ' + res.status)
    var loaded = blimp.eval(await res.text())
    if (!loaded.ok) throw new Error(loaded.error)

    var canvas = null, ctx = null
    function frame() {
      var el = document.getElementById('sunflower-bg')
      if (!el) return requestAnimationFrame(frame)
      if (el !== canvas) { canvas = el; ctx = el.getContext('2d') }
      // the hook sized the canvas on resize; this checks every frame, which
      // also covers a canvas that arrives after the first frame
      if (canvas.width !== canvas.clientWidth) canvas.width = canvas.clientWidth
      if (canvas.height !== canvas.clientHeight) canvas.height = canvas.clientHeight
      var r = blimp.send('app', 'frame', canvas.width + ', ' + canvas.height)
      if (!r.ok) return console.error('sunflower: ' + r.error)
      try {
        play(ctx, r.value)
      } catch (e) {
        return console.error(e)
      }
      requestAnimationFrame(frame)
    }
    frame()
  }

  start().catch(function (e) { console.error(e) })
})()
