// spin_glue.mjs: the browser calls the shell needs that March's stdlib
// (Js.Dom, Js.Canvas) does not have. Nothing here decides anything about the
// game: it paints the ops Spin.View made, reports which buttons are down, and
// makes the noise Spin.Game asked for. Values cross in March's JS shapes:
// variants { $: tag, _0, ... }, tuples { _0, _1, ... }, records as objects,
// lists as Cons/Nil, closures called as f._0(f, args...).

// ---- The shell's one mutable cell ----
let cell = null;
export function glue_cell_put(v) { cell = v; }
export function glue_cell_get() { return cell; }

export function glue_request_frame(cb) {
  requestAnimationFrame((ms) => { cb._0(cb, ms / 1000); });
}

export function glue_seed_limbs() {
  const a = new Uint32Array(2);
  crypto.getRandomValues(a);
  return { _0: a[0], _1: a[1] };
}

export function glue_load_best() {
  try { return Number(localStorage.getItem("spin.best") || 0) | 0; } catch (e) { return 0; }
}
export function glue_save_best(n) {
  try { localStorage.setItem("spin.best", String(n)); } catch (e) { }
}

export function glue_mark(name, value) {
  const el = document.documentElement;
  if (el.getAttribute(name) !== value) el.setAttribute(name, value);
}

// ---- Buttons ----
// Keys: Z, Left or left Shift for the left flipper; M, /, Right or right Shift
// for the right; Space, Down or Enter is the plunger (hold to pull, let go)
// and starts a game.
// Touch: tap the left half for the left flipper, the right half for the
// right one. While a ball waits, the LAUNCH button (Spin.View.launch_button)
// is the plunger: hold it to pull, let go to fire. Any tap starts a game.
const keys = new Set();
const fingers = new Map();   // pointerId -> "L" | "R" | "P" (plunger)
// A tap is often shorter than a frame. Each press holds its flipper for at
// least this long, so the game always sees it and the flipper goes all the
// way up instead of twitching.
const MIN_FLIP_MS = 110;
const until = { L: 0, R: 0 };
let touchMode = false;
// The launch button in world units, and whether it takes touches now (only
// while a ball waits: otherwise a thumb there is flipping, not launching).
let button = { x: 0, y: 0, r: 0, live: false };

export function glue_launch_button(x, y, r, live) { button = { x, y, r, live }; }

const LEFT = new Set(["KeyZ", "ArrowLeft", "ShiftLeft", "KeyA"]);
const RIGHT = new Set(["KeyM", "Slash", "ArrowRight", "ShiftRight", "KeyL"]);
const LAUNCH = new Set(["Space", "ArrowDown", "Enter"]);

export function glue_listen(canvas) {
  touchMode = window.matchMedia ? window.matchMedia("(pointer: coarse)").matches : false;
  window.addEventListener("keydown", (e) => {
    if (LEFT.has(e.code) || RIGHT.has(e.code) || LAUNCH.has(e.code)) e.preventDefault();
    if (e.repeat) return;
    keys.add(e.code);
    const now = performance.now();
    if (LEFT.has(e.code)) until.L = now + MIN_FLIP_MS;
    if (RIGHT.has(e.code)) until.R = now + MIN_FLIP_MS;
    touchMode = false;
    wake();
  });
  window.addEventListener("keyup", (e) => { keys.delete(e.code); });
  window.addEventListener("blur", () => { keys.clear(); fingers.clear(); });
  const where = (e) => {
    const r = canvas.getBoundingClientRect();
    const sx = e.clientX - r.left, sy = e.clientY - r.top;
    if (button.live) {
      // world point under the finger; a fat-finger margin of half a radius
      const wx = (sx - view.ox) / view.s, wy = (sy - view.oy) / view.s;
      if (Math.hypot(wx - button.x, wy - button.y) < button.r * 1.5) return "P";
    }
    return sx < r.width / 2 ? "L" : "R";
  };
  canvas.addEventListener("pointerdown", (e) => {
    e.preventDefault();
    try { canvas.setPointerCapture(e.pointerId); } catch (err) { }
    const side = where(e);
    fingers.set(e.pointerId, side);
    if (side !== "P") until[side] = performance.now() + MIN_FLIP_MS;
    if (e.pointerType !== "mouse") touchMode = true;
    wake();
  });
  const lift = (e) => { fingers.delete(e.pointerId); wake(); };
  canvas.addEventListener("pointerup", lift);
  canvas.addEventListener("pointercancel", lift);
  canvas.addEventListener("lostpointercapture", (e) => { fingers.delete(e.pointerId); });
  canvas.addEventListener("contextmenu", (e) => e.preventDefault());
  // iOS only lets audio start inside a touchend or click.
  window.addEventListener("touchend", wake, { passive: true });
  window.addEventListener("click", wake);
}

const any = (set) => { for (const k of keys) if (set.has(k)) return true; return false; };
const finger = (side) => { for (const v of fingers.values()) if (v === side) return true; return false; };

// (left, right, launch, start)
export function glue_input() {
  const now = performance.now();
  return {
    _0: any(LEFT) || finger("L") || now < until.L,
    _1: any(RIGHT) || finger("R") || now < until.R,
    _2: any(LAUNCH) || finger("P"),
    _3: any(LAUNCH) || fingers.size > 0,
  };
}

export function glue_touch() { return touchMode; }

// ---- The screen ----
// The canvas fills the window at device pixels (at most 2x: a 3x phone
// canvas costs fill rate and looks no different). The world box (x, y, w, h)
// is scaled to fit inside the safe area, away from notches and the home bar,
// and centred there. Every op after Clear is in world units.
let view = { s: 1, ox: 0, oy: 0, dpr: 1, w: 1, h: 1 };
let probe = null;

function insets() {
  if (!probe) {
    probe = document.createElement("div");
    probe.style.cssText = "position:fixed;left:0;top:0;width:0;height:0;visibility:hidden;pointer-events:none;" +
      "padding:env(safe-area-inset-top) env(safe-area-inset-right) env(safe-area-inset-bottom) env(safe-area-inset-left)";
    document.body.appendChild(probe);
  }
  const c = getComputedStyle(probe);
  return { t: parseFloat(c.paddingTop) || 0, r: parseFloat(c.paddingRight) || 0, b: parseFloat(c.paddingBottom) || 0, l: parseFloat(c.paddingLeft) || 0 };
}

export function glue_fit(canvas, x, y, w, h) {
  const cw = window.innerWidth, ch = window.innerHeight;
  const dpr = Math.min(2, window.devicePixelRatio || 1);
  const bw = Math.max(1, Math.round(cw * dpr)), bh = Math.max(1, Math.round(ch * dpr));
  if (canvas.width !== bw) canvas.width = bw;
  if (canvas.height !== bh) canvas.height = bh;
  canvas.style.width = cw + "px";
  canvas.style.height = ch + "px";
  const i = insets();
  const aw = Math.max(1, cw - i.l - i.r), ah = Math.max(1, ch - i.t - i.b);
  const s = Math.min(aw / w, ah / h);
  view = { s, ox: i.l + (aw - w * s) / 2 - x * s, oy: i.t + (ah - h * s) / 2 - y * s, dpr, w: bw, h: bh };
}

function world(ctx) {
  const k = view.s * view.dpr;
  ctx.setTransform(k, 0, 0, k, view.ox * view.dpr, view.oy * view.dpr);
}

function each(list, f) {
  for (let l = list; l && l.$ === "Cons"; l = l._1) f(l._0);
}

export function glue_paint(ctx, ops) {
  ctx.save();
  ctx.lineCap = "round";
  ctx.lineJoin = "round";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  world(ctx);
  each(ops, (op) => {
    switch (op.$) {
      case "Clear":
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.globalCompositeOperation = "source-over";
        ctx.fillStyle = op._0;
        ctx.fillRect(0, 0, view.w, view.h);
        world(ctx);
        break;
      case "Disc":
        ctx.beginPath(); ctx.arc(op._0, op._1, Math.max(0, op._2), 0, Math.PI * 2);
        ctx.fillStyle = op._3; ctx.fill();
        break;
      case "Ring":
        ctx.beginPath(); ctx.arc(op._0, op._1, Math.max(0, op._2), 0, Math.PI * 2);
        ctx.lineWidth = op._3; ctx.strokeStyle = op._4; ctx.stroke();
        break;
      case "Line":
        ctx.beginPath(); ctx.moveTo(op._0, op._1); ctx.lineTo(op._2, op._3);
        ctx.lineWidth = op._4; ctx.strokeStyle = op._5; ctx.stroke();
        break;
      case "Poly": {
        ctx.beginPath();
        let first = true;
        each(op._0, (p) => { if (first) { ctx.moveTo(p.x, p.y); first = false; } else ctx.lineTo(p.x, p.y); });
        ctx.closePath(); ctx.fillStyle = op._1; ctx.fill();
        break;
      }
      case "Box":
        ctx.fillStyle = op._4; ctx.fillRect(op._0, op._1, op._2, op._3);
        break;
      case "Glow": {
        const g = ctx.createRadialGradient(op._0, op._1, 0, op._0, op._1, Math.max(1, op._2));
        g.addColorStop(0, op._3); g.addColorStop(1, "rgba(0,0,0,0)");
        ctx.globalCompositeOperation = "lighter";
        ctx.fillStyle = g;
        ctx.beginPath(); ctx.arc(op._0, op._1, Math.max(1, op._2), 0, Math.PI * 2); ctx.fill();
        ctx.globalCompositeOperation = "source-over";
        break;
      }
      case "Label":
        if (op._0 === "") break;
        ctx.font = "900 " + op._3 + "px Nunito, system-ui, sans-serif";
        ctx.fillStyle = op._4; ctx.fillText(op._0, op._1, op._2);
        break;
      case "ClipBox":
        ctx.save(); ctx.beginPath(); ctx.rect(op._0, op._1, op._2, op._3); ctx.clip();
        break;
      case "Unclip":
        ctx.restore();
        break;
      case "Fade":
        ctx.globalAlpha = Math.min(1, Math.max(0, op._0));
        break;
      default:
        throw new Error("spin_glue: unknown draw op " + JSON.stringify(op.$));
    }
  });
  ctx.restore();
  sideways(ctx);
}

// A phone held sideways gets a table half the size. Say so in the margin,
// where nothing is drawn, rather than rotating or squeezing the table.
function sideways(ctx) {
  const cw = window.innerWidth, ch = window.innerHeight;
  if (!touchMode || cw <= ch * 1.2) return;
  const margin = view.ox + 0 * view.s;
  if (margin < 120) return;
  ctx.save();
  ctx.setTransform(view.dpr, 0, 0, view.dpr, 0, 0);
  ctx.textAlign = "center"; ctx.textBaseline = "middle";
  ctx.fillStyle = "rgba(255,211,107,0.85)";
  ctx.font = "900 18px Nunito, system-ui, sans-serif";
  ctx.fillText("turn your phone", margin / 2, ch / 2 - 12);
  ctx.fillText("upright", margin / 2, ch / 2 + 12);
  ctx.restore();
}

// ---- Sound: every noise is synthesised here, at the moment it is asked for ----
let audio = null;
function wake() {
  if (!audio) {
    try { audio = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { audio = null; }
  }
  if (audio && audio.state === "suspended") audio.resume();
}

function tone(freq, dur, type, vol, slideTo, at) {
  if (!audio) return;
  const t0 = audio.currentTime + (at || 0);
  const o = audio.createOscillator(), g = audio.createGain();
  o.type = type;
  o.frequency.setValueAtTime(freq, t0);
  if (slideTo) o.frequency.exponentialRampToValueAtTime(Math.max(20, slideTo), t0 + dur);
  g.gain.setValueAtTime(0.0001, t0);
  g.gain.exponentialRampToValueAtTime(vol, t0 + 0.005);
  g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
  o.connect(g).connect(audio.destination);
  o.start(t0); o.stop(t0 + dur + 0.02);
}

function noise(dur, vol, at, lowpass) {
  if (!audio) return;
  const t0 = audio.currentTime + (at || 0);
  const n = Math.max(1, Math.floor(audio.sampleRate * dur));
  const buf = audio.createBuffer(1, n, audio.sampleRate);
  const d = buf.getChannelData(0);
  for (let i = 0; i < n; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / n);
  const src = audio.createBufferSource(), g = audio.createGain(), f = audio.createBiquadFilter();
  src.buffer = buf; f.type = "lowpass"; f.frequency.value = lowpass || 2000;
  g.gain.value = vol;
  src.connect(f).connect(g).connect(audio.destination);
  src.start(t0);
}

const SCALE = [523.25, 587.33, 659.25, 783.99, 880, 1046.5, 1174.66, 1318.5];
let lastThud = 0;

export function glue_sound(name, x) {
  if (!audio || name === "") return;
  switch (name) {
    case "flip": noise(0.04, 0.25, 0, 900); tone(110, 0.05, "square", 0.05); break;
    case "bumper": tone(620, 0.12, "sine", 0.22, 240); noise(0.03, 0.2, 0, 3000); break;
    case "sling": tone(320, 0.08, "triangle", 0.2, 140); break;
    case "load": {
      const base = 3 + Math.min(4, x);
      tone(SCALE[base - 3], 0.08, "square", 0.08);
      tone(SCALE[base - 1], 0.08, "square", 0.08, 0, 0.07);
      tone(SCALE[base], 0.14, "square", 0.08, 0, 0.14);
      break;
    }
    case "lane": tone(880, 0.09, "sine", 0.15); tone(1320, 0.09, "sine", 0.1, 0, 0.06); break;
    case "spinner": for (let i = 0; i < 8; i++) tone(1800 - i * 120, 0.025, "square", 0.06, 0, i * 0.035); break;
    case "reelstart": tone(160, 0.35, "sawtooth", 0.05, 420); break;
    case "reelstop": tone(200 - x * 25, 0.06, "square", 0.12, 90); noise(0.03, 0.15, 0, 1200); break;
    case "win": {
      const n = Math.min(14, 2 + Math.floor(x / 2));
      for (let i = 0; i < n; i++) tone(SCALE[i % SCALE.length] * (i >= SCALE.length ? 2 : 1), 0.09, "square", 0.07, 0, i * 0.06);
      break;
    }
    case "jackpot":
      for (let r = 0; r < 3; r++) for (let i = 0; i < 8; i++) tone(SCALE[i] * (1 + r * 0.5), 0.1, "square", 0.07, 0, r * 0.5 + i * 0.055);
      tone(130.8, 1.6, "sawtooth", 0.06);
      break;
    case "miss": tone(392, 0.12, "triangle", 0.12); tone(330, 0.2, "triangle", 0.12, 0, 0.12); break;
    case "nudge": tone(700, 0.04, "square", 0.08); noise(0.02, 0.1, 0, 1500); break;
    case "drain": tone(420, 0.6, "sawtooth", 0.1, 60); break;
    case "saved": tone(523, 0.1, "sine", 0.15); tone(784, 0.18, "sine", 0.15, 0, 0.1); break;
    case "launch": noise(0.25, 0.25, 0, 1600); tone(90, 0.2, "sine", 0.15, 220); break;
    case "burn": if (x <= 10) tone(1500, 0.03, "square", 0.05); else tone(2200, 0.012, "sine", 0.025); break;
    case "bust": tone(392, 0.35, "sawtooth", 0.1); tone(370, 0.35, "sawtooth", 0.1, 0, 0.35); tone(349, 0.35, "sawtooth", 0.1, 0, 0.7); tone(330, 0.9, "sawtooth", 0.1, 300, 1.05); break;
    case "start": tone(1046, 0.06, "square", 0.08); tone(1568, 0.12, "square", 0.08, 0, 0.06); noise(0.08, 0.1, 0.02, 5000); break;
    case "thud": {
      const now = performance.now();
      if (now - lastThud < 45) break;
      lastThud = now;
      tone(85, 0.06, "sine", Math.min(0.25, x / 5000));
      break;
    }
    default: break;
  }
}
