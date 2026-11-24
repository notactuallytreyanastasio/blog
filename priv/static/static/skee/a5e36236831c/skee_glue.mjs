// skee_glue.mjs: the browser calls Skee's shell needs that March's stdlib
// (Js.Dom, Js.Canvas) does not have. Each export is one platform call with no
// game logic; shell/glue.march declares them as externs. Values cross in
// March's JS shapes: variants { $: tag, _0, ... }, tuples { _0, _1, ... },
// lists as Cons/Nil, closures called as f._0(f, args...).

const NIL = { $: "Nil" };

function listOf(arr) {
  let l = NIL;
  for (let i = arr.length - 1; i >= 0; i--) l = { $: "Cons", _0: arr[i], _1: l };
  return l;
}

// ---- One clock, in seconds: performance.now() / 1000. rAF's time and every
// pointer event's timeStamp are on it (both are DOMHighResTimeStamps from
// the time origin).
export function glue_now() { return performance.now() / 1000; }

export function glue_request_frame(cb) {
  requestAnimationFrame((ms) => { cb._0(cb, ms / 1000); });
}

// ---- The window ----
export function glue_view_size() {
  return { _0: window.innerWidth, _1: window.innerHeight };
}
export function glue_device_pixel_ratio() { return window.devicePixelRatio || 1; }

// Backing store at device pixels, laid out at CSS pixels.
export function glue_size_canvas(canvas, w, h, dpr) {
  const bw = Math.max(1, Math.round(w * dpr)), bh = Math.max(1, Math.round(h * dpr));
  if (canvas.width !== bw) canvas.width = bw;
  if (canvas.height !== bh) canvas.height = bh;
  canvas.style.width = w + "px";
  canvas.style.height = h + "px";
}

// Two random 32-bit limbs for the launch seed.
export function glue_seed_limbs() {
  const a = new Uint32Array(2);
  crypto.getRandomValues(a);
  return { _0: a[0], _1: a[1] };
}

export function glue_on_visibility(cb) {
  document.addEventListener("visibilitychange", () => {
    cb._0(cb, document.visibilityState === "visible");
  });
}

export function glue_vibrate(ms) {
  try { if (navigator.vibrate) navigator.vibrate(ms); } catch (e) { }
}

// ---- The thumb ----
// One pointer at a time, as ThrowPad (isMultipleTouchEnabled = false): the
// first pointer down is followed until it lifts or is cancelled; others are
// ignored. down, move and up get lists of (t, x, y) triples: seconds and
// CSS pixels in the canvas. move and up include the coalesced samples
// (coalescedTouches in Swift). cancel(0) when the pointer is lost.
export function glue_on_pointer(canvas, down, move, up, cancel) {
  let active = null;
  const sample = (e) => {
    const r = canvas.getBoundingClientRect();
    return { _0: e.timeStamp / 1000, _1: e.clientX - r.left, _2: e.clientY - r.top };
  };
  const samples = (e) => {
    const all = (typeof e.getCoalescedEvents === "function") ? e.getCoalescedEvents() : [];
    return listOf((all.length > 0 ? all : [e]).map(sample));
  };
  canvas.addEventListener("pointerdown", (e) => {
    if (active !== null) return;
    if (e.pointerType === "mouse" && e.button !== 0) return;
    active = e.pointerId;
    try { canvas.setPointerCapture(e.pointerId); } catch (err) { }
    e.preventDefault();
    down._0(down, listOf([sample(e)]));
  });
  canvas.addEventListener("pointermove", (e) => {
    if (e.pointerId !== active) return;
    e.preventDefault();
    move._0(move, samples(e));
  });
  canvas.addEventListener("pointerup", (e) => {
    if (e.pointerId !== active) return;
    active = null;
    e.preventDefault();
    up._0(up, samples(e));
  });
  const lost = (e) => {
    if (e.pointerId !== active) return;
    active = null;
    cancel._0(cancel, 0);
  };
  canvas.addEventListener("pointercancel", lost);
  canvas.addEventListener("lostpointercapture", lost);
  canvas.addEventListener("contextmenu", (e) => e.preventDefault());
}

// ---- HUD drag handles (the lever's knob) ----
// A pointer that goes down on an element marked data-drag inside the HUD's
// root is followed, one at a time, until it lifts or is lost. It is captured
// on the root, which stays put: the knob itself is rewritten as it moves.
// down, move and up get (x, y) in CSS pixels; lost(0) on cancel.
export function glue_on_drag(root, down, move, up, lost) {
  let active = null;
  const at = (e) => ({ _0: e.clientX, _1: e.clientY });
  root.addEventListener("pointerdown", (e) => {
    if (active !== null) return;
    if (e.pointerType === "mouse" && e.button !== 0) return;
    const t = e.target;
    if (!(t instanceof Element) || t.closest("[data-drag]") === null) return;
    active = e.pointerId;
    try { root.setPointerCapture(e.pointerId); } catch (err) { }
    e.preventDefault();
    down._0(down, at(e));
  });
  root.addEventListener("pointermove", (e) => {
    if (e.pointerId !== active) return;
    e.preventDefault();
    move._0(move, at(e));
  });
  root.addEventListener("pointerup", (e) => {
    if (e.pointerId !== active) return;
    active = null;
    e.preventDefault();
    up._0(up, at(e));
  });
  const gone = (e) => {
    if (e.pointerId !== active) return;
    active = null;
    lost._0(lost, 0);
  };
  root.addEventListener("pointercancel", gone);
  root.addEventListener("lostpointercapture", gone);
}

// ---- The shell's one mutable cell: the current model and handles, so that
// event callbacks and the frame loop see the same state.
let cell = null;
export function glue_cell_put(v) { cell = v; }
export function glue_cell_get() { return cell; }

// ---- Canvas 2D calls Js.Canvas lacks ----
export function glue_set_transform(ctx, a, b, c, d, e, f) { ctx.setTransform(a, b, c, d, e, f); }
export function glue_composite(ctx, op) { ctx.globalCompositeOperation = op; }
export function glue_fill_rule(ctx, evenodd) { ctx.fill(evenodd ? "evenodd" : "nonzero"); }
export function glue_clip_rule(ctx, evenodd) { ctx.clip(evenodd ? "evenodd" : "nonzero"); }
export function glue_line_cap(ctx, cap) { ctx.lineCap = cap; }
export function glue_line_join(ctx, join) { ctx.lineJoin = join; }
export function glue_text_centred(ctx) { ctx.textAlign = "center"; ctx.textBaseline = "middle"; }
export function glue_arc_full(ctx, x, y, r, sweep) { ctx.arc(x, y, r, 0, sweep); }
// The gradient being built: radial, its stops, then fill_gradient sets it.
let gradient = null;
export function glue_radial(ctx, x0, y0, r0, x1, y1, r1) {
  gradient = ctx.createRadialGradient(x0, y0, Math.max(0, r0), x1, y1, Math.max(0, r1));
}
export function glue_gradient_stop(at, css) { gradient.addColorStop(Math.min(1, Math.max(0, at)), css); }
export function glue_fill_gradient(ctx) { ctx.fillStyle = gradient; }

// ---- Taps queued by HUD buttons, drained once a frame (Hud.render) ----
const taps = [];
export function glue_queue_tap(i) { taps.push(i); }
export function glue_drain_taps() { return listOf(taps.splice(0, taps.length)); }

// ---- Read-only state for tests and the playtest: data-* on <html> ----
export function glue_mark(name, value) {
  const el = document.documentElement;
  if (el.getAttribute(name) !== value) el.setAttribute(name, value);
}

// ---- The host's relay: one same-origin POST per call ----
// reply({ status, body }) when an HTTP answer came back, whatever its status;
// fail(reason) when none did. The callbacks run outside the fetch's promise
// chain, so an error in the game is never reported as a network failure.
export function glue_host_post(body, timeoutMs, reply, fail) {
  let signal;
  try { signal = AbortSignal.timeout(timeoutMs); } catch (e) { signal = undefined; }
  fetch("/skee-host/chat", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body,
    cache: "no-store",
    signal,
  }).then(
    (r) => r.text().then((text) => ({ ok: true, status: r.status, text }), (e) => ({ ok: false, e })),
    (e) => ({ ok: false, e }),
  ).then((res) => {
    if (res.ok) {
      reply._0(reply, { _0: res.status, _1: res.text });
    } else {
      const e = res.e;
      const why = e && e.name === "TimeoutError"
        ? "no answer from the host's relay in " + Math.round(timeoutMs / 1000) + " s"
        : "could not reach the host's relay" + (e && e.message ? ": " + e.message : "");
      fail._0(fail, why);
    }
  });
}

// ---- HUD text fields ----
// A pane rewritten under a text field would drop what was typed, the focus
// and the caret: this keeps all three for fields with an id.
export function glue_set_html_keeping(pane, html) {
  const active = document.activeElement;
  const focused = active && pane.contains(active) && active.id ? active.id : null;
  let caret = null;
  if (focused && typeof active.selectionStart === "number") caret = [active.selectionStart, active.selectionEnd];
  const values = new Map();
  for (const f of pane.querySelectorAll("input[id], textarea[id]")) values.set(f.id, f.value);
  pane.innerHTML = html;
  for (const [id, v] of values) {
    const f = document.getElementById(id);
    if (f && pane.contains(f)) f.value = v;
  }
  if (focused) {
    const f = document.getElementById(focused);
    if (f && pane.contains(f) && !f.disabled) {
      f.focus({ preventScroll: true });
      if (caret) { try { f.setSelectionRange(caret[0], caret[1]); } catch (e) { } }
    }
  }
}

// typed(value) on every edit of a field marked data-draft; Enter in a field
// marked data-enter queues its code with the HUD's taps.
export function glue_on_fields(root, typed) {
  root.addEventListener("input", (e) => {
    const t = e.target;
    if (t instanceof HTMLInputElement && t.hasAttribute("data-draft")) typed._0(typed, t.value);
  });
  root.addEventListener("keydown", (e) => {
    const t = e.target;
    if (e.key !== "Enter" || e.isComposing || !(t instanceof HTMLInputElement)) return;
    const code = Number(t.getAttribute("data-enter"));
    e.preventDefault();
    if (t.hasAttribute("data-enter") && Number.isInteger(code)) taps.push(code);
  });
}
