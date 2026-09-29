// node --test assets/test/*.test.mjs
//
// The Blimp sunflower, played by BlimpCanvas, must make the same canvas calls
// as the JavaScript hook it replaced, in the same order with the same numbers.
// Both draw into a recording context and the two logs are compared.
import test from "node:test"
import assert from "node:assert"
import fs from "node:fs"
import path from "node:path"
import { createRequire } from "node:module"
import { fileURLToPath } from "node:url"
import { play, loadBlimp } from "../js/hooks/blimp_canvas.js"

const here = path.dirname(fileURLToPath(import.meta.url))
const root = path.join(here, "..", "..")
const require = createRequire(import.meta.url)

function recorder() {
  const log = []
  const target = {}
  const ctx = new Proxy(target, {
    set(_, key, value) { log.push(["set", key, value]); return true },
    get(_, key) { return (...args) => { log.push(["call", key, ...args]) } },
  })
  return { ctx, log }
}

// Run the original hook for `frames` animation frames at w x h.
function originalFrames(frames, w, h) {
  const { SunflowerBackground } = require("./fixtures/sunflower_original.js")
  const { ctx, log } = recorder()
  const queue = []
  globalThis.window = { innerWidth: w, innerHeight: h, addEventListener() {}, removeEventListener() {} }
  globalThis.requestAnimationFrame = (f) => { queue.push(f); return queue.length }
  const hook = Object.create(SunflowerBackground)
  hook.el = { getContext: () => ctx, set width(_) {}, set height(_) {} }
  hook.mounted()              // draws frame 1 and queues frame 2
  for (let i = 1; i < frames; i++) queue.shift()()
  return log
}

async function blimpFrames(frames, w, h) {
  const blimp = await loadBlimp(fs.readFileSync(path.join(root, "priv/static/static/blimp/blimp.wasm")))
  blimp.eval(fs.readFileSync(path.join(root, "priv/static/static/blimp/sunflower.blimp"), "utf8"))
  const { ctx, log } = recorder()
  for (let i = 0; i < frames; i++) play(ctx, blimp.send("app", "frame", `${w}, ${h}`))
  return log
}

function close(a, b) {
  if (typeof a === "number" && typeof b === "number") return Math.abs(a - b) <= 1e-9 * Math.max(1, Math.abs(a))
  return a === b
}

test("the Blimp sunflower makes the same canvas calls as the JavaScript one", async () => {
  const frames = 30
  const expected = originalFrames(frames, 1280, 800)
  const actual = await blimpFrames(frames, 1280, 800)
  assert.ok(expected.length > 40000, `only ${expected.length} calls recorded`)
  assert.strictEqual(actual.length, expected.length, "different number of canvas calls")
  for (let i = 0; i < expected.length; i++) {
    const e = expected[i], a = actual[i]
    const same = e.length === a.length && e.every((v, k) => close(v, a[k]))
    if (!same) assert.fail(`call ${i} differs:\n  js:    ${JSON.stringify(e)}\n  blimp: ${JSON.stringify(a)}`)
  }
})

test("an unknown command stops the frame and names itself", () => {
  const { ctx } = recorder()
  assert.throws(() => play(ctx, [["fill", "#000"], ["sparkle", 1]]), /unknown draw command "sparkle"/)
})
