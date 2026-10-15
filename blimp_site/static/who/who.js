// /who: the socket beside the Blimp program. The program (static/who/who.blimp)
// draws the page and decides what to send; this holds the WebSocket to
// /live/who, hands the program every frame (`who <- :frame(json)`), tells
// it each (re)connection (`:connected`) and each loss (`:offline`), and
// after every render sends up whatever `who <- :outbox` returns. Nothing
// else: Enter in the chat box and the chat body's scrolling are the view
// runtime's (submit_on_enter, scroll: :end).
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"';
  }

  var ws = null;

  function start() {
    var app = window.BlimpApp;
    if (!app || start.done) return false;
    start.done = true;
    var view = app.view;
    var blimp = app.blimp;

    // A send made while the view is rendering is dropped, so an event
    // waits for the stack to unwind.
    function tell(msg, args) { setTimeout(function () { view.send(msg, args); }, 0); }

    function flush() {
      var out = blimp.send('who', 'outbox');
      if (!out.ok || !Array.isArray(out.value)) return;
      out.value.forEach(function (m) { if (ws && ws.readyState === 1) ws.send(m); });
    }

    var render = view.render;
    view.render = function (tree) {
      var r = render.apply(this, arguments);
      try { flush(); } catch (e) { console.error(e); }
      return r;
    };

    var wait = 500;
    (function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://';
      ws = new WebSocket(scheme + location.host + '/live/who');
      ws.onopen = function () { wait = 500; tell('connected'); };
      ws.onmessage = function (ev) { tell('frame', literal(ev.data)); };
      ws.onclose = function () {
        tell('offline');
        setTimeout(connect, wait);
        wait = Math.min(wait * 2, 10000);
      };
    })();
    return true;
  }

  if (!start()) document.addEventListener('blimp-app-mounted', start);
})();
