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
  function play(which) {
    try {
      audio = audio || new (window.AudioContext || window.webkitAudioContext)();
      if (audio.state === 'suspended') audio.resume();
      if (which === 'signon') { tone(523, 0, 0.18, 0.12); tone(784, 0.12, 0.3, 0.12); }
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

    var name = remembered();
    if (name) tell('remembered', literal(name));

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
