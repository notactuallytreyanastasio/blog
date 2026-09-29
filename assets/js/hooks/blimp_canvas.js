// BlimpCanvas: a canvas whose drawing is decided by a Blimp program.
//
//   <canvas phx-hook="BlimpCanvas" id="x" data-src="/static/blimp/sunflower.blimp"></canvas>
//
// The program is evaluated once in its own Blimp interpreter (WebAssembly),
// and must bind an actor to `app` with a handler `on :frame(w: Int, h: Int)`.
// On every animation frame this hook sends `app <- :frame(w, h)` and plays
// the reply, a list of commands, onto the canvas. That is all it does: no
// drawing decision is made here, so nothing in this file is about any one
// picture.
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

const WASM_URL = "/static/blimp/blimp.wasm"

export function play(ctx, commands) {
  for (const c of commands) {
    switch (c[0]) {
      case "save": ctx.save(); break
      case "restore": ctx.restore(); break
      case "fill": ctx.fillStyle = c[1]; break
      case "stroke": ctx.strokeStyle = c[1]; break
      case "alpha": ctx.globalAlpha = c[1]; break
      case "shadow": ctx.shadowBlur = c[1]; ctx.shadowColor = c[2]; break
      case "line_width": ctx.lineWidth = c[1]; break
      case "line_cap": ctx.lineCap = c[1]; break
      case "rect": ctx.fillRect(c[1], c[2], c[3], c[4]); break
      case "circle":
        ctx.beginPath()
        ctx.arc(c[1], c[2], c[3], 0, Math.PI * 2)
        ctx.fill()
        break
      case "ellipse":
        ctx.beginPath()
        ctx.ellipse(c[1], c[2], c[3], c[4], c[5], 0, Math.PI * 2)
        ctx.fill()
        break
      case "polyline": {
        const p = c[1]
        ctx.beginPath()
        for (let i = 0; i < p.length; i += 2) {
          if (i === 0) ctx.moveTo(p[i], p[i + 1])
          else ctx.lineTo(p[i], p[i + 1])
        }
        ctx.stroke()
        break
      }
      case "bezier":
        ctx.beginPath()
        ctx.moveTo(c[1], c[2])
        ctx.bezierCurveTo(c[3], c[4], c[5], c[6], c[7], c[8])
        ctx.stroke()
        break
      default:
        throw new Error(`BlimpCanvas: unknown draw command ${JSON.stringify(c[0])}`)
    }
  }
}

// One interpreter per canvas: programs are top-level Blimp and would share
// one namespace otherwise.
export async function loadBlimp(wasmBytesOrUrl) {
  let mem
  const text = (p, n) => new TextDecoder().decode(new Uint8Array(mem.buffer, p, n))
  const env = {
    blimp_js_print: (p, n) => console.log("[blimp]", text(p, n)),
    blimp_js_error: (p, n) => console.error("[blimp]", text(p, n)),
  }
  const { instance } = typeof wasmBytesOrUrl === "string"
    ? await WebAssembly.instantiateStreaming(fetch(wasmBytesOrUrl), { env })
    : await WebAssembly.instantiate(wasmBytesOrUrl, { env })
  const x = instance.exports
  mem = x.memory
  x.blimp_init()

  const put = (s) => {
    const bytes = new TextEncoder().encode(s)
    if (bytes.length === 0) return [0, 0]
    const p = x.blimp_alloc(bytes.length)
    new Uint8Array(mem.buffer, p, bytes.length).set(bytes)
    return [p, bytes.length]
  }
  const free = (...pairs) => { for (const [p, n] of pairs) if (n) x.blimp_free(p, n) }
  const error = () => text(x.blimp_get_error_ptr(), x.blimp_get_error_len())

  return {
    eval(source) {
      const s = put(source)
      const status = x.blimp_eval(s[0], s[1])
      free(s)
      if (status !== 0) throw new Error(`Blimp: ${error()}`)
    },
    send(target, message, args) {
      const t = put(target), m = put(message), a = put(args)
      const status = x.blimp_send(t[0], t[1], m[0], m[1], a[0], a[1])
      free(t, m, a)
      if (status !== 0) throw new Error(`Blimp: ${error()}`)
      return JSON.parse(text(x.blimp_get_reply_ptr(), x.blimp_get_reply_len()))
    },
  }
}

const BlimpCanvas = {
  async mounted() {
    const canvas = this.el
    const ctx = canvas.getContext("2d")
    if (!ctx) return
    this.alive = true

    try {
      const [blimp, source] = await Promise.all([
        loadBlimp(WASM_URL),
        fetch(canvas.dataset.src).then((r) => {
          if (!r.ok) throw new Error(`BlimpCanvas: ${canvas.dataset.src} is ${r.status}`)
          return r.text()
        }),
      ])
      blimp.eval(source)
      this.blimp = blimp
    } catch (e) {
      console.error(e)
      return
    }
    if (!this.alive) return

    const resize = () => {
      canvas.width = canvas.clientWidth
      canvas.height = canvas.clientHeight
    }
    resize()
    this.onResize = resize
    window.addEventListener("resize", resize)

    const frame = () => {
      try {
        play(ctx, this.blimp.send("app", "frame", `${canvas.width}, ${canvas.height}`))
      } catch (e) {
        console.error(e)
        return
      }
      if (this.alive) this.raf = requestAnimationFrame(frame)
    }
    frame()
  },

  destroyed() {
    this.alive = false
    if (this.raf) cancelAnimationFrame(this.raf)
    if (this.onResize) window.removeEventListener("resize", this.onResize)
  },
}

export default BlimpCanvas
