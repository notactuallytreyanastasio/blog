// /aim: what the page's program (static/aim/aim.blimp) cannot do itself.
//
//  - the socket to /live/aim: every frame goes to `aim <- :frame(json)`,
//    each (re)connection is `aim <- :connected`, and after every render
//    what `aim <- :outbox` returns goes up.
//  - after every render, `aim <- :where` says which sound to play, whether
//    the reader is open, and the screen name, which is remembered here for
//    the next visit.
//  - keys: Enter sends (Shift+Enter is a new line), Escape closes the
//    reader, the arrow keys page through it.
//  - the transcript stays scrolled to the bottom; the taskbar has a clock.
//  - /aim?msg=SmarterChild opens its window on signing on (`:want`).
//  - the dial-up screen after Sign On: a tick a second or so while
//    `:where` says it is dialing, its noise, and "skip it next time"
//    remembered here.
//
// The sounds are made here with Web Audio, not AIM's recordings: a rising
// pair for a door opening, one blip for sent, two for received.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"';
  }

  var KEY = 'aim.screen_name';
  function remembered() { try { return localStorage.getItem(KEY) || ''; } catch (e) { return ''; } }
  function remember(n) { try { localStorage.setItem(KEY, n); } catch (e) {} }
  var SKIP = 'aim.skip_dialup';
  function skipDial() { try { return localStorage.getItem(SKIP) === '1'; } catch (e) { return false; } }
  function rememberSkip(v) { try { if (v) localStorage.setItem(SKIP, '1'); else localStorage.removeItem(SKIP); } catch (e) {} }

  var audio = null;
  function tone(freq, at, dur, gain) {
    var t = audio.currentTime + at;
    var o = audio.createOscillator(), g = audio.createGain();
    o.type = 'triangle';
    o.frequency.setValueAtTime(freq, t);
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(gain, t + 0.01);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    o.connect(g); g.connect(audio.destination);
    o.start(t); o.stop(t + dur + 0.02);
  }
  // A 56k handshake, shortened: seven touch-tone digits, the answer tone,
  // then the warbling hiss of two modems agreeing. About four seconds, quiet.
  function dialup() {
    var t0 = audio.currentTime + 0.05;
    var rows = [697, 770, 852, 941], cols = [1209, 1336, 1477];
    var digits = [[0, 1], [3, 1], [2, 0], [1, 2], [0, 0], [2, 2], [1, 1]];
    digits.forEach(function (d, i) {
      [rows[d[0]], cols[d[1]]].forEach(function (f) { beep(f, t0 + i * 0.13, 0.09, 0.03, 'sine'); });
    });
    var t1 = t0 + digits.length * 0.13 + 0.3;
    beep(2100, t1, 0.7, 0.025, 'sine');
    var t2 = t1 + 0.8;
    var len = 2.2, n = Math.floor(audio.sampleRate * len);
    var buf = audio.createBuffer(1, n, audio.sampleRate), data = buf.getChannelData(0);
    for (var i = 0; i < n; i++) data[i] = Math.random() * 2 - 1;
    var src = audio.createBufferSource(), bp = audio.createBiquadFilter(), g = audio.createGain();
    src.buffer = buf; bp.type = 'bandpass'; bp.Q.value = 3;
    bp.frequency.setValueAtTime(1800, t2);
    for (var k = 0; k < 10; k++) bp.frequency.linearRampToValueAtTime(k % 2 ? 2400 : 1100, t2 + (k + 1) * len / 10);
    g.gain.setValueAtTime(0.0001, t2); g.gain.exponentialRampToValueAtTime(0.05, t2 + 0.1);
    g.gain.setValueAtTime(0.05, t2 + len - 0.3); g.gain.exponentialRampToValueAtTime(0.0001, t2 + len);
    src.connect(bp); bp.connect(g); g.connect(audio.destination);
    src.start(t2); src.stop(t2 + len);
    beep(980, t2 + 0.2, 1.4, 0.02, 'square');
  }
  function beep(freq, at, dur, gain, type) {
    var o = audio.createOscillator(), g = audio.createGain();
    o.type = type; o.frequency.setValueAtTime(freq, at);
    g.gain.setValueAtTime(0.0001, at);
    g.gain.exponentialRampToValueAtTime(gain, at + 0.01);
    g.gain.setValueAtTime(gain, at + dur - 0.02);
    g.gain.exponentialRampToValueAtTime(0.0001, at + dur);
    o.connect(g); g.connect(audio.destination);
    o.start(at); o.stop(at + dur + 0.02);
  }
  function play(which) {
    try {
      audio = audio || new (window.AudioContext || window.webkitAudioContext)();
      if (audio.state === 'suspended') audio.resume();
      if (which === 'dial') dialup();
      else if (which === 'signon') { tone(523, 0, 0.18, 0.12); tone(784, 0.12, 0.3, 0.12); }
      else if (which === 'sent') { tone(880, 0, 0.09, 0.08); }
      else if (which === 'received') { tone(988, 0, 0.1, 0.1); tone(1319, 0.11, 0.16, 0.1); }
    } catch (e) {}
  }

  var ws = null;

  function start() {
    var app = window.BlimpApp;
    if (!app || start.done) return false;
    start.done = true;
    var view = app.view;
    var blimp = app.blimp;
    var readerOpen = false;
    var lastLog = 0;

    // A send made while the view is rendering is dropped, so an event
    // waits for the stack to unwind.
    function tell(msg, args) { setTimeout(function () { view.send(msg, args); }, 0); }

    function sync() {
      var out = blimp.send('aim', 'outbox');
      if (out.ok && Array.isArray(out.value)) {
        out.value.forEach(function (m) { if (ws && ws.readyState === 1) ws.send(m); });
      }
      var w = blimp.send('aim', 'where');
      if (!w.ok || !w.value) return;
      if (w.value.sound) play(String(w.value.sound).replace(/^:/, ''));
      if (w.value.signed_on === true && w.value.name) remember(String(w.value.name));
      dialing = w.value.dialing === true;
      rememberSkip(w.value.dial_skip === true);
      var wasOpen = readerOpen;
      readerOpen = w.value.reader === true;
      if (readerOpen && !wasOpen) {
        var page = document.getElementById('aim-reader-page');
        if (page) { page.scrollTop = 0; page.focus && page.focus(); }
      }
      // keep the transcript at the bottom when it grows
      var log = document.getElementById('aim-log');
      if (log && log.scrollHeight !== lastLog) {
        lastLog = log.scrollHeight;
        log.scrollTop = log.scrollHeight;
      }
      var input = document.querySelector('.aim-input');
      if (input && !input.disabled && !readerOpen && document.activeElement === document.body && window.innerWidth > 700) input.focus();
    }

    var render = view.render;
    view.render = function () {
      var r = render.apply(this, arguments);
      try { sync(); } catch (e) { console.error(e); }
      return r;
    };

    var dialing = false;
    var name = remembered();
    if (name) tell('remembered', literal(name));
    if (skipDial()) tell('remembered_dial', 'true');
    var msg = new URLSearchParams(location.search).get('msg');
    if (msg) tell('want', literal(msg));
    // the dial-up screen's steps, one every 1.1s
    setInterval(function () { if (dialing) tell('dial_tick'); }, 1100);

    var wait = 500;
    (function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://';
      ws = new WebSocket(scheme + location.host + '/live/aim');
      ws.onopen = function () { wait = 500; tell('connected'); };
      ws.onmessage = function (ev) { tell('frame', literal(ev.data)); };
      ws.onclose = function () {
        tell('offline');
        setTimeout(connect, wait);
        wait = Math.min(wait * 2, 10000);
      };
    })();

    document.addEventListener('keydown', function (e) {
      var el = e.target;
      if (el.classList && el.classList.contains('aim-input') && e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        if (el.value.trim() !== '' && el.form) el.form.requestSubmit();
        return;
      }
      if (!readerOpen) return;
      if (e.key === 'Escape') tell('close_reader');
      else if (e.key === 'ArrowLeft') tell('reader_step', '-1');
      else if (e.key === 'ArrowRight') tell('reader_step', '1');
    });

    // a click on the dimmed desktop behind the reader closes it
    document.addEventListener('click', function (e) {
      if (e.target.classList && e.target.classList.contains('aim-reader-scrim')) tell('close_reader');
    });

    function tick() {
      var c = document.getElementById('aim-clock');
      if (c) c.textContent = new Date().toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    }
    tick();
    setInterval(tick, 15000);
    return true;
  }

  if (!start()) document.addEventListener('blimp-app-mounted', start);
})();
