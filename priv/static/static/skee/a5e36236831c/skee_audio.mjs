// skee_audio.mjs: the speakers for shell/audio.march. Web Audio plumbing only;
// which commands to send, and what to restore when the speakers come up, is
// decided in March (Skee.SoundOut, Skee.SynthFeed).
//
//   - The AudioContext is made on the first user gesture (autoplay rules),
//     at the synth's 44100 Hz, and resumed on every later gesture while it
//     is not running (iOS "interrupted", a suspended tab).
//   - The synth runs in an AudioWorklet (skee_synth_worklet.mjs, the March
//     build of shell/synth_worklet.march), one 128-sample block per render
//     quantum. Commands go to it on the port.
//   - Where AudioWorklet is missing or fails to load (an insecure context,
//     an old browser), a ScriptProcessorNode runs SynthEngine.serve on the
//     main thread instead, between frames, 2048 samples a callback.
//   - Anything that throws leaves the game silent, never broken.
//   - mono -> a gain of 0.8 (SoundEngine's mainMixerNode.outputVolume) ->
//     the destination.
//
// For the playtest: <html data-audio="<state>" data-audio-path="worklet|
// script|off">, and window.__skeeAudio = { log, stats } with each batch of
// commands sent (performance time, audio time, the commands) and the audio
// frame at which the synth took it.

import { makePump, joinBatches } from "./skee_synth_cell.mjs";

const RATE = 44100;
const GAIN = 0.8;
const LOG_KEEP = 400;

let ctx = null;
let sink = null;          // (marchList) => void, once the synth is up
let path = "off";
let workletUrl = "";
let serveFn = null;
let readyFn = null;
let levels = null;

const debug = { log: [], stats: { peak: 0, frame: 0, path: "off", rate: 0, underruns: null } };
const awaiting = [];      // log entries whose batch the worklet has not taken yet
try { globalThis.__skeeAudio = debug; } catch (e) { }

function mark() {
  try {
    const el = document.documentElement;
    el.setAttribute("data-audio", ctx ? ctx.state : "none");
    el.setAttribute("data-audio-path", path);
  } catch (e) { }
}

// ---- The levels cell (Skee.SynthFeed.Levels), kept by shell/audio.march ----
export function audio_levels_get() { return levels; }
export function audio_levels_put(l) { levels = l; }

// ---- Describing a batch for the log: March values by constructor name ----
function arg(x) {
  if (x === undefined) return "";
  if (x !== null && typeof x === "object") return x.$ !== undefined ? x.$ + arg(x._0) : "";
  return "(" + String(x) + ")";
}
function describe(list) {
  const out = [];
  for (let n = list; n && n.$ === "Cons"; n = n._1) {
    const c = n._0;
    if (c.$ === "CmdPlay") out.push(c._0.$ + (c._0._0 !== undefined ? arg(c._0._0) : ""));
    else out.push(c.$ + "(" + String(c._0) + ")");
  }
  return out;
}

export function audio_send(list) {
  if (sink === null) return;
  try {
    const entry = { t: performance.now() / 1000, audio: ctx.currentTime, cmds: describe(list), frame: null };
    debug.log.push(entry);
    if (debug.log.length > LOG_KEEP) debug.log.splice(0, debug.log.length - LOG_KEEP);
    if (path === "worklet") awaiting.push(entry);
    sink(list);
  } catch (e) { }
}

function fromWorklet(e) {
  const d = e.data;
  if (!d) return;
  if (d.applied) {
    const done = awaiting.splice(0, d.applied);
    for (const entry of done) entry.frame = d.frame;
  }
  if (d.peak !== undefined) { debug.stats.peak = d.peak; debug.stats.frame = d.frame; }
  try {
    const ps = ctx && ctx.playbackStats;
    if (ps) debug.stats.underruns = { events: ps.underrunEvents, duration: ps.underrunDuration };
  } catch (err) { }
}

function up(name, send) {
  path = name;
  debug.stats.path = name;
  debug.stats.rate = ctx.sampleRate;
  sink = send;
  mark();
  try { readyFn._0(readyFn, 0); } catch (e) { }
}

function output() {
  const gain = ctx.createGain();
  gain.gain.value = GAIN;
  gain.connect(ctx.destination);
  return gain;
}

function startWorklet(gain) {
  return ctx.audioWorklet.addModule(workletUrl).then(() => {
    const node = new AudioWorkletNode(ctx, "skee-synth", {
      numberOfInputs: 0, numberOfOutputs: 1, outputChannelCount: [1],
    });
    node.port.onmessage = fromWorklet;
    node.connect(gain);
    up("worklet", (list) => node.port.postMessage(list));
  });
}

function startScript(gain) {
  const pending = [];
  const pump = makePump(serveFn, ctx.sampleRate, () => joinBatches(pending.splice(0, pending.length)));
  const node = ctx.createScriptProcessor(2048, 0, 1);
  let blocks = 0, peak = 0;
  node.onaudioprocess = (e) => {
    try {
      const out = e.outputBuffer.getChannelData(0);
      pump(out);
      for (let i = 0; i < out.length; i++) { const v = Math.abs(out[i]); if (v > peak) peak = v; }
      if ((++blocks & 31) === 0) { debug.stats.peak = peak; debug.stats.frame = blocks * out.length; peak = 0; }
    } catch (err) { }
  };
  node.connect(gain);
  up("script", (list) => pending.push(list));
}

function open() {
  const AC = globalThis.AudioContext || globalThis.webkitAudioContext;
  if (!AC) { mark(); return; }
  try {
    ctx = new AC({ sampleRate: RATE, latencyHint: "interactive" });
  } catch (e) {
    ctx = new AC();
  }
  ctx.onstatechange = mark;
  const p = ctx.resume();
  if (p && p.catch) p.catch(() => { });
  const gain = output();
  const fallback = () => { try { startScript(gain); } catch (e) { path = "off"; mark(); } };
  if (ctx.audioWorklet && typeof AudioWorkletNode === "function") {
    startWorklet(gain).catch(fallback);
  } else {
    fallback();
  }
  mark();
}

function unlock() {
  try {
    if (ctx === null) open();
    else if (ctx.state !== "running" && ctx.state !== "closed" && !document.hidden) {
      const p = ctx.resume();
      if (p && p.catch) p.catch(() => { });
    }
  } catch (e) { }
}

// The page hidden: the speakers stop, as an iOS app's audio stops in the
// background; shown again, they resume (or wait for the next gesture).
function visibility() {
  try {
    if (ctx === null || ctx.state === "closed") return;
    const p = document.hidden ? ctx.suspend() : ctx.resume();
    if (p && p.catch) p.catch(() => { });
  } catch (e) { }
}

// serve: SynthEngine.serve, for the fallback. ready: called once the synth
// is up, so March can restore the levels it kept.
export function audio_install(url, serve, ready) {
  // Next to this module, not the page: the blog serves the page at /skee and
  // the modules from /static/skee/<build>/.
  workletUrl = new URL(url, import.meta.url).href;
  serveFn = serve;
  readyFn = ready;
  try {
    for (const t of ["pointerdown", "pointerup", "touchend", "keydown", "click"]) {
      window.addEventListener(t, unlock, { capture: true, passive: true });
    }
    document.addEventListener("visibilitychange", visibility);
  } catch (e) { }
  mark();
}
