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
//  - windows are dragged by their title bars, and the last one touched is
//    in front.
//  - /aim?msg=SmarterChild opens its window on signing on (`:want`).
//  - the dial-up screen after Sign On: a tick a second or so while
//    `:where` says it is dialing, its noise, and "skip it next time"
//    remembered here.
//
// The sounds are made here with Web Audio, after AIM's: its recordings are
// AOL's, so these are imitations, not copies. A door creaks open when a
// buddy signs on (and when you do), creaks and slams when one signs off;
// a sent message goes "bloop" down, a received one "bloo-deep" up.
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
  // A wooden door's creak is stick-slip: the hinge catches and lets go
  // dozens of times a second, and each release rings the wood. So: a train
  // of clicks whose rate glides from `r0` to `r1` per second, each click a
  // few decaying resonances, the whole thing swelling and fading. Rendered
  // once into a buffer and kept.
  var creaks = {};
  function creak(key, len, r0, r1, gain) {
    if (creaks[key]) return creaks[key];
    var sr = audio.sampleRate, n = Math.floor(sr * len);
    var buf = audio.createBuffer(1, n, sr), d = buf.getChannelData(0);
    var modes = [[310, 0.012, 1], [740, 0.007, 0.6], [1650, 0.004, 0.35], [2900, 0.002, 0.2]];
    var t = 0.01, seed = 7;
    function rnd() { seed = (seed * 16807) % 2147483647; return seed / 2147483647; }
    while (t < len - 0.02) {
      var x = t / len;
      // rate rises then sags, with a little jitter, as a hand pushes a door
      var rate = r0 + (r1 - r0) * Math.sin(Math.PI * Math.min(1, x * 1.2) / 2);
      rate *= 0.85 + 0.3 * rnd();
      var env = Math.sin(Math.PI * Math.min(1, x / 0.15) / 2) * (1 - Math.pow(x, 3));
      var amp = gain * env * (0.7 + 0.6 * rnd());
      var at = Math.floor(t * sr), pitch = 0.9 + 0.35 * x;
      for (var m = 0; m < modes.length; m++) {
        var f = modes[m][0] * pitch, tau = modes[m][1], a = amp * modes[m][2];
        var end = Math.min(n, at + Math.floor(tau * 6 * sr));
        for (var i = at; i < end; i++) {
          var dt = (i - at) / sr;
          d[i] += a * Math.exp(-dt / tau) * Math.sin(2 * Math.PI * f * dt);
        }
      }
      t += 1 / rate;
    }
    creaks[key] = buf;
    return buf;
  }
  function playBuffer(buf, at, gain) {
    var src = audio.createBufferSource(), g = audio.createGain();
    src.buffer = buf; g.gain.value = gain;
    src.connect(g); g.connect(audio.destination);
    src.start(audio.currentTime + at);
  }
  function doorOpen() {
    playBuffer(creak('open', 0.85, 38, 140, 0.5), 0, 0.5);
  }
  function doorClose() {
    playBuffer(creak('close', 0.32, 90, 150, 0.5), 0, 0.45);
    // the slam: a low thud and a burst of rattle
    var t = audio.currentTime + 0.3;
    var o = audio.createOscillator(), g = audio.createGain();
    o.type = 'sine'; o.frequency.setValueAtTime(95, t); o.frequency.exponentialRampToValueAtTime(48, t + 0.25);
    g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(0.5, t + 0.005); g.gain.exponentialRampToValueAtTime(0.0001, t + 0.35);
    o.connect(g); g.connect(audio.destination); o.start(t); o.stop(t + 0.4);
    var n = Math.floor(audio.sampleRate * 0.18), nb = audio.createBuffer(1, n, audio.sampleRate), nd = nb.getChannelData(0);
    for (var i = 0; i < n; i++) nd[i] = (Math.random() * 2 - 1) * Math.exp(-i / (audio.sampleRate * 0.03));
    var ns = audio.createBufferSource(), lp = audio.createBiquadFilter(), ng = audio.createGain();
    ns.buffer = nb; lp.type = 'lowpass'; lp.frequency.value = 900; ng.gain.value = 0.35;
    ns.connect(lp); lp.connect(ng); ng.connect(audio.destination); ns.start(t);
  }
  // a sine whose pitch slides, for the message blips
  function slide(f0, f1, at, dur, gain) {
    var t = audio.currentTime + at;
    var o = audio.createOscillator(), g = audio.createGain();
    o.type = 'sine';
    o.frequency.setValueAtTime(f0, t); o.frequency.exponentialRampToValueAtTime(f1, t + dur * 0.8);
    g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(gain, t + 0.008);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    o.connect(g); g.connect(audio.destination); o.start(t); o.stop(t + dur + 0.02);
  }
  function imSent() { slide(1250, 420, 0, 0.13, 0.32); }
  function imReceived() { slide(520, 780, 0, 0.09, 0.3); slide(880, 1560, 0.085, 0.16, 0.3); }
  function play(which) {
    try {
      audio = audio || new (window.AudioContext || window.webkitAudioContext)();
      if (audio.state === 'suspended') audio.resume();
      if (which === 'dial') dialup();
      else if (which === 'signon' || which === 'door_open') doorOpen();
      else if (which === 'door_close') doorClose();
      else if (which === 'sent') imSent();
      else if (which === 'received') imReceived();
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
    var lastLog = 0, lastRoom = 0;

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
      // keep the transcripts at the bottom when they grow
      var log = document.getElementById('aim-log');
      if (log && log.scrollHeight !== lastLog) {
        lastLog = log.scrollHeight;
        log.scrollTop = log.scrollHeight;
      }
      var room = document.getElementById('aim-party-log');
      if (room && room.scrollHeight !== lastRoom) {
        lastRoom = room.scrollHeight;
        room.scrollTop = room.scrollHeight;
      }
      var input = document.querySelector('.aim-input');
      if (input && !input.disabled && !readerOpen && document.activeElement === document.body && window.innerWidth > 700) input.focus();
    }

    var render = view.render;
    view.render = function () {
      var r = render.apply(this, arguments);
      try { sync(); place(); } catch (e) { console.error(e); }
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

    // Windows move by their title bars. The offset is the CSS `translate`
    // property, which adds to the `transform` each window centres itself
    // with rather than replacing it. Offsets are kept per kind of window
    // (aim-buddies, aim-im, ...) and put back after every render, because
    // a render may rebuild a window's element. Phones stack the windows,
    // so there is nothing to drag there.
    var moved = {}, front = null, drag = null;
    function kind(win) {
      for (var i = 0; i < win.classList.length; i++) {
        var c = win.classList[i];
        if (c !== 'aim-win' && c.indexOf('aim-') === 0) return c;
      }
      return null;
    }
    var shown = {};
    function place() {
      var wins = document.querySelectorAll('.aim-win');
      // a window that has just opened comes to the front
      var now = {};
      for (var j = 0; j < wins.length; j++) {
        var kj = kind(wins[j]);
        now[kj] = true;
        if (!shown[kj] && kj !== 'aim-reader' && Object.keys(shown).length) front = kj;
      }
      shown = now;
      for (var i = 0; i < wins.length; i++) {
        var k = kind(wins[i]), m = moved[k];
        if (k === 'aim-reader') continue;
        wins[i].style.translate = m ? m.x + 'px ' + m.y + 'px' : '';
        wins[i].style.zIndex = k === front ? '4' : '';
      }
    }
    function stacked() { return window.matchMedia('(max-width: 760px)').matches; }
    document.addEventListener('pointerdown', function (e) {
      var bar = e.target.closest && e.target.closest('.aim-titlebar');
      var win = bar && bar.closest('.aim-win');
      if (!win) {
        var w = e.target.closest && e.target.closest('.aim-win');
        if (w && kind(w) !== 'aim-reader') { front = kind(w); place(); }
        return;
      }
      var k = kind(win);
      if (k === 'aim-reader' || stacked() || e.button !== 0 || e.target.closest('button')) return;
      front = k;
      var m = moved[k] || { x: 0, y: 0 };
      var r = win.getBoundingClientRect();
      drag = { k: k, sx: e.clientX, sy: e.clientY, x: m.x, y: m.y, left: r.left, top: r.top, w: r.width };
      bar.setPointerCapture && bar.setPointerCapture(e.pointerId);
      e.preventDefault();
      place();
    });
    document.addEventListener('pointermove', function (e) {
      if (!drag) return;
      var dx = e.clientX - drag.sx, dy = e.clientY - drag.sy;
      // keep at least 60px of the title bar on screen, and its top below 0
      dx = Math.max(60 - drag.left - drag.w, Math.min(window.innerWidth - 60 - drag.left, dx));
      dy = Math.max(-drag.top, Math.min(window.innerHeight - 60 - drag.top, dy));
      moved[drag.k] = { x: drag.x + dx, y: drag.y + dy };
      place();
    });
    function drop() { drag = null; }
    document.addEventListener('pointerup', drop);
    document.addEventListener('pointercancel', drop);

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
