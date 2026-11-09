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
  try { return Number(localStorage.getItem("spin.best_cash") || 0) | 0; } catch (e) { return 0; }
}
// #stage=N starts every game at stage N (1 is the first), to look at the
// later tables without earning them.
export function glue_start_stage() {
  const m = /stage=(\d+)/.exec(location.hash || "");
  return m ? Math.max(0, Number(m[1]) - 1) : 0;
}
export function glue_save_best(n) {
  try { localStorage.setItem("spin.best_cash", String(n)); } catch (e) { }
}

export function glue_mark(name, value) {
  const el = document.documentElement;
  if (el.getAttribute(name) !== value) {
    el.setAttribute(name, value);
    if (name === "data-mode") modeChanged(value);
  }
}

// ---- Buttons ----
// Keys: Z, Left or left Shift for the left flipper; M, /, Right or right Shift
// for the right; Space, Down or Enter is the plunger (hold to pull, let go)
// and starts a game; with no ball waiting it shakes the machine. C held is
// CASH OUT; 1, 3 and 5 pick the line mode between games.
// Touch: tap the left half for the left flipper, the right half for the
// right one. The LAUNCH button (Spin.View.launch_button) is the plunger
// while a ball waits and SHAKE otherwise. Spin.View.buttons lists the rest
// (CASH OUT, the line chips) each frame. A tap anywhere else starts a game.
const keys = new Set();
const fingers = new Map();   // pointerId -> "L" | "R" | "P" | button id (number)
// A tap is often shorter than a frame. Each press holds its flipper for at
// least this long, so the game always sees it and the flipper goes all the
// way up instead of twitching.
const MIN_FLIP_MS = 110;
const until = { L: 0, R: 0 };
let touchMode = false;
let launchBtn = { x: 0, y: 0, r: 0, live: false, margin: 1 };
let buttons = [];

export function glue_launch_button(x, y, r, live, margin) { launchBtn = { x, y, r, live, margin }; }
export function glue_buttons(list) {
  const out = [];
  each(list, (t) => out.push({ id: t._0, x: t._1, y: t._2, w: t._3, h: t._4 }));
  buttons = out;
}

const LEFT = new Set(["KeyZ", "ArrowLeft", "ShiftLeft", "KeyA"]);
const RIGHT = new Set(["KeyM", "Slash", "ArrowRight", "ShiftRight", "KeyL"]);
const LAUNCH = new Set(["Space", "ArrowDown", "Enter"]);
const PICKS = { Digit1: 1, Digit3: 3, Digit5: 5, Numpad1: 1, Numpad3: 3, Numpad5: 5 };

let canvasRef = null;
export function glue_listen(canvas) {
  canvasRef = canvas;
  touchMode = window.matchMedia ? window.matchMedia("(pointer: coarse)").matches : false;
  window.addEventListener("keydown", (e) => {
    if (overlayOpen()) return;
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
    // world point under the finger
    const wx = (sx - view.ox) / view.s, wy = (sy - view.oy) / view.s;
    for (const b of buttons) {
      if (wx >= b.x && wx <= b.x + b.w && wy >= b.y && wy <= b.y + b.h) return b.id;
    }
    if (launchBtn.live && Math.hypot(wx - launchBtn.x, wy - launchBtn.y) < launchBtn.r * launchBtn.margin) return "P";
    return sx < r.width / 2 ? "L" : "R";
  };
  canvas.addEventListener("pointerdown", (e) => {
    e.preventDefault();
    try { canvas.setPointerCapture(e.pointerId); } catch (err) { }
    const side = where(e);
    fingers.set(e.pointerId, side);
    if (side === "L" || side === "R") until[side] = performance.now() + MIN_FLIP_MS;
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

// (left, right, launch, start, cash, pick)
export function glue_input() {
  const now = performance.now();
  let pick = 0;
  for (const k of keys) if (PICKS[k]) pick = PICKS[k];
  for (const v of fingers.values()) if (v === 1 || v === 3 || v === 5) pick = v;
  let starting = false;
  for (const v of fingers.values()) if (v === "L" || v === "R" || v === "P") starting = true;
  return {
    _0: any(LEFT) || finger("L") || now < until.L,
    _1: any(RIGHT) || finger("R") || now < until.R,
    _2: any(LAUNCH) || finger("P"),
    _3: any(LAUNCH) || starting,
    _4: keys.has("KeyC") || finger(9),
    _5: pick,
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

let shift = { x: 0, y: 0 };
function world(ctx) {
  const k = view.s * view.dpr;
  ctx.setTransform(k, 0, 0, k, (view.ox + shift.x * view.s) * view.dpr, (view.oy + shift.y * view.s) * view.dpr);
}

function each(list, f) {
  for (let l = list; l && l.$ === "Cons"; l = l._1) f(l._0);
}

export function glue_paint(ctx, ops) {
  shift = { x: 0, y: 0 };
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
      case "Shift":
        shift = { x: op._0, y: op._1 };
        world(ctx);
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
    case "stage":
      for (let i = 0; i < 6; i++) tone(SCALE[i] / 2, 0.12, "sawtooth", 0.06, 0, i * 0.08);
      tone(SCALE[5], 0.6, "square", 0.07, SCALE[7], 0.5);
      noise(0.4, 0.12, 0.45, 6000);
      break;
    case "buff":
      for (let i = 0; i < 3 + x * 2; i++) tone(SCALE[(i * 2) % SCALE.length] * 2, 0.06, "triangle", 0.09, 0, i * 0.045);
      break;
    case "shake": noise(0.18, 0.3, 0, 400); tone(70, 0.2, "sine", 0.2, 45); break;
    case "tilt": tone(220, 0.25, "square", 0.12); tone(220, 0.25, "square", 0.12, 0, 0.35); tone(110, 0.8, "sawtooth", 0.1, 0, 0.7); break;
    case "cashout": for (let i = 0; i < 16; i++) tone(1200 + (i % 4) * 300, 0.05, "square", 0.05, 0, i * 0.05); noise(0.6, 0.08, 0, 7000); break;
    case "pick": tone(660 + x * 60, 0.07, "triangle", 0.12); break;
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

// ---- Wallet, badges, leaderboard ----
// Cashed-out credits go into a wallet on this device (localStorage). They
// buy badges, which show next to the best cash-out on the panel and next to
// the player's initials on the leaderboard. Nothing here is checked by a
// server: the wallet, the badges and the score posted are what this browser
// says. The leaderboard API caps and rate-limits, and that is all.
const BADGES = [
  { id: "cherry", glyph: "🍒", name: "Cherry", price: 25 },
  { id: "lemon", glyph: "🍋", name: "Lemon", price: 60 },
  { id: "bell", glyph: "🔔", name: "Bell", price: 120 },
  { id: "bar", glyph: "🎰", name: "Bar", price: 250 },
  { id: "seven", glyph: "7️⃣", name: "Lucky 7", price: 500 },
  { id: "star", glyph: "⭐", name: "Star", price: 900 },
  { id: "crown", glyph: "👑", name: "Crown", price: 1600 },
  { id: "diamond", glyph: "💎", name: "Diamond", price: 3000 },
];
const store = {
  get(k, d) { try { const v = localStorage.getItem(k); return v === null ? d : JSON.parse(v); } catch (e) { return d; } },
  set(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch (e) { } },
};
const wallet = () => Number(store.get("spin.wallet", 0)) | 0;
const owned = () => { const o = store.get("spin.badges", []); return Array.isArray(o) ? o : []; };
const glyphs = (ids) => BADGES.filter((b) => ids.includes(b.id)).map((b) => b.glyph).join("");
let badgeText = null;

export function glue_badges() {
  if (badgeText === null) badgeText = glyphs(owned());
  return badgeText;
}

let pending = null;   // { score, stage, lines } waiting to be posted
export function glue_cashed(n, stage, lines) {
  store.set("spin.wallet", wallet() + n);
  pending = { score: n, stage, lines };
  setTimeout(() => openOverlay(), 900);
}

let overlay = null;
// Open only while shown: before its first opening the element's inline
// display is "", and reading that as open swallowed every key.
const overlayOpen = () => overlay !== null && overlay.style.display === "flex";
const esc = (t) => String(t).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

function css() {
  if (document.getElementById("spin-ui-css")) return;
  const st = document.createElement("style");
  st.id = "spin-ui-css";
  st.textContent = `
  #spin-ui { position: fixed; inset: 0; display: none; align-items: flex-start; justify-content: center; overflow-y: auto;
    background: rgba(7,4,15,0.82); z-index: 10; font-family: Nunito, system-ui, sans-serif; font-weight: 800; color: #efe8ff;
    padding: max(16px, env(safe-area-inset-top)) 16px max(16px, env(safe-area-inset-bottom)); box-sizing: border-box; }
  #spin-ui .card { width: 100%; max-width: 420px; background: #1a0c30; border: 3px solid #ffd36b; border-radius: 18px; padding: 18px; box-sizing: border-box; }
  #spin-ui h2 { margin: 0 0 4px; font-weight: 900; font-size: 26px; color: #7dff7a; }
  #spin-ui h3 { margin: 18px 0 8px; font-weight: 900; font-size: 15px; color: #ffd36b; letter-spacing: 1px; }
  #spin-ui .muted { color: #a898d0; font-size: 13px; }
  #spin-ui .row { display: flex; gap: 8px; align-items: center; }
  #spin-ui input { width: 92px; font: inherit; font-weight: 900; font-size: 22px; letter-spacing: 6px; text-transform: uppercase; text-align: center;
    background: #0b0614; color: #ffd36b; border: 2px solid #5a4a80; border-radius: 10px; padding: 6px; }
  #spin-ui button { font: inherit; font-weight: 900; font-size: 15px; border: 0; border-radius: 10px; padding: 10px 14px; cursor: pointer;
    background: #ff3fa4; color: #fff; }
  #spin-ui button:disabled { background: #3a2350; color: #8a7ab0; cursor: default; }
  #spin-ui .shop { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; }
  #spin-ui .badge { background: #0b0614; border: 2px solid #3a2350; border-radius: 12px; padding: 8px 4px; text-align: center; }
  #spin-ui .badge .g { font-size: 26px; line-height: 1.2; }
  #spin-ui .badge .n { font-size: 11px; color: #d8ccff; }
  #spin-ui .badge button { margin-top: 6px; padding: 5px 8px; font-size: 12px; background: #5cf2ff; color: #07040f; }
  #spin-ui .badge.have { border-color: #7dff7a; }
  #spin-ui ol { margin: 0; padding: 0; list-style: none; }
  #spin-ui li { display: flex; gap: 8px; padding: 6px 4px; border-bottom: 1px solid #2b1645; font-size: 15px; }
  #spin-ui li .rk { width: 26px; color: #8a7ab0; } #spin-ui li .who { flex: 1; } #spin-ui li .sc { color: #7dff7a; }
  #spin-ui li.me { background: rgba(255,211,107,0.12); }
  #spin-ui .err { color: #ff3b4e; font-size: 13px; }
  #spin-open { position: fixed; left: 0; top: 0; transform: translate(-50%, -50%); z-index: 5; display: none; white-space: nowrap;
    font: 900 13px Nunito, system-ui, sans-serif; background: #1f1035; color: #ffd36b; border: 2px solid #ffd36b; border-radius: 999px; padding: 7px 12px; cursor: pointer; }
  `;
  document.head.appendChild(st);
}

function ensureOverlay() {
  if (overlay) return overlay;
  css();
  overlay = document.createElement("div");
  overlay.id = "spin-ui";
  overlay.addEventListener("pointerdown", (e) => e.stopPropagation());
  document.body.appendChild(overlay);
  const open = document.createElement("button");
  open.id = "spin-open";
  open.textContent = "🏆 SCORES & SHOP";
  open.addEventListener("click", (e) => { e.stopPropagation(); openOverlay(); });
  document.body.appendChild(open);
  return overlay;
}

let board = { state: "loading", rows: [], error: "", mine: null };

async function loadBoard() {
  board = { ...board, state: "loading" };
  render();
  try {
    const r = await fetch("/api/pinball/scores", { headers: { accept: "application/json" } });
    if (!r.ok) throw new Error("the leaderboard answered " + r.status);
    const j = await r.json();
    board = { ...board, state: "ok", rows: j.scores || [] };
  } catch (e) {
    board = { ...board, state: "error", error: String(e.message || e) };
  }
  render();
}

async function post() {
  const input = overlay.querySelector("#spin-initials");
  const initials = (input.value || "").toUpperCase().replace(/[^A-Z]/g, "").slice(0, 3);
  if (initials.length !== 3) { board = { ...board, error: "three letters, A to Z" }; render(); return; }
  store.set("spin.initials", initials);
  const body = { initials, score: pending.score, stage: pending.stage, lines: pending.lines, badges: owned() };
  try {
    const r = await fetch("/api/pinball/scores", { method: "POST", headers: { "content-type": "application/json", accept: "application/json" }, body: JSON.stringify(body) });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j.error || ("the leaderboard answered " + r.status));
    board = { state: "ok", rows: j.scores || board.rows, error: "", mine: j.id || null };
    pending = null;
  } catch (e) {
    board = { ...board, error: String(e.message || e) };
  }
  render();
}

function buy(id) {
  const b = BADGES.find((x) => x.id === id);
  if (!b || owned().includes(id) || wallet() < b.price) return;
  store.set("spin.wallet", wallet() - b.price);
  store.set("spin.badges", [...owned(), id]);
  badgeText = glyphs(owned());
  render();
}

function render() {
  if (!overlay) return;
  const have = owned();
  const head = pending
    ? `<h2>CASHED OUT ${pending.score}</h2><div class="muted">banked to your wallet · stage ${pending.stage} · ${pending.lines} line${pending.lines === 1 ? "" : "s"}</div>
       <h3>PUT IT ON THE BOARD</h3>
       <div class="row"><input id="spin-initials" maxlength="3" autocomplete="off" autocapitalize="characters" value="${esc(store.get("spin.initials", ""))}" placeholder="AAA">
       <button id="spin-post">POST ${pending.score}</button></div>`
    : `<h2 style="color:#ffd36b">SCORES &amp; SHOP</h2><div class="muted">cash out a game to post a score and fill your wallet</div>`;
  const shop = BADGES.map((b) => {
    const mine = have.includes(b.id);
    return `<div class="badge${mine ? " have" : ""}"><div class="g">${b.glyph}</div><div class="n">${esc(b.name)}</div>
      ${mine ? `<div class="n" style="color:#7dff7a">OWNED</div>` : `<button data-buy="${b.id}" ${wallet() < b.price ? "disabled" : ""}>${b.price}</button>`}</div>`;
  }).join("");
  const rows = board.state === "loading" ? `<div class="muted">loading…</div>`
    : board.state === "error" ? `<div class="err">leaderboard unavailable: ${esc(board.error)}</div>`
    : board.rows.length === 0 ? `<div class="muted">no scores yet. be the first.</div>`
    : `<ol>${board.rows.map((r, i) => `<li class="${r.id === board.mine ? "me" : ""}"><span class="rk">${i + 1}</span><span class="who">${esc(r.initials)} ${glyphs(r.badges || [])}</span><span class="muted">st ${r.stage} · ${r.lines}L</span><span class="sc">${r.score}</span></li>`).join("")}</ol>`;
  overlay.innerHTML = `<div class="card">${head}
    ${board.error && board.state !== "error" ? `<div class="err">${esc(board.error)}</div>` : ""}
    <h3>WALLET · ${wallet()} CREDITS</h3><div class="shop">${shop}</div>
    <h3>TOP 10 CASH-OUTS</h3>${rows}
    <div class="row" style="margin-top:18px; justify-content:flex-end"><button id="spin-close" style="background:#ffd36b;color:#07040f">BACK TO THE TABLE</button></div></div>`;
  const p = overlay.querySelector("#spin-post"); if (p) p.addEventListener("click", post);
  overlay.querySelector("#spin-close").addEventListener("click", closeOverlay);
  overlay.querySelectorAll("[data-buy]").forEach((el) => el.addEventListener("click", () => buy(el.getAttribute("data-buy"))));
}

function openOverlay() {
  ensureOverlay();
  keys.clear(); fingers.clear();
  overlay.style.display = "flex";
  render();
  loadBoard();
}

function closeOverlay() {
  if (overlay) overlay.style.display = "none";
  keys.clear(); fingers.clear();
}

// The scores button shows between games, where Spin.View.scores_at puts
// it (table units, mapped through the same fit as the canvas).
export function glue_scores_at(show, x, y) {
  ensureOverlay();
  const b = document.getElementById("spin-open");
  const want = show ? "block" : "none";
  if (b.style.display !== want) b.style.display = want;
  if (show) {
    const r = canvasRef ? canvasRef.getBoundingClientRect() : { left: 0, top: 0 };
    b.style.left = (r.left + view.ox + x * view.s) + "px";
    b.style.top = (r.top + view.oy + y * view.s) + "px";
  }
}

function modeChanged(mode) {
  if (mode === "playing") closeOverlay();
}
