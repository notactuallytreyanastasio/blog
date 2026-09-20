// Mounts the game into a page that is not its own.
//
// index.html is the standalone version and owns its whole document. This one
// is embedded, which used to mean an iframe -- and an iframe was the bug the
// player felt: keydown goes to whichever document has focus, and a reader's
// focus is on the page, not on a frame inside it. Keys only arrived if you
// clicked the board first, and the page had to say so.
//
// Rendered into the host page directly, there is no boundary to cross. The
// container is marked phx-update="ignore" so LiveView leaves the subtree to
// the Blimp view host, which rewrites it every frame.
(function () {
  'use strict';

  var host = document.getElementById('snake-app');
  var status = document.getElementById('snake-status');
  if (!host || host.dataset.mounted) return;
  host.dataset.mounted = '1';

  var base = '/static/temper-snake/';
  var say = function (s) { if (status) status.textContent = s; };

  function fail(message) {
    host.innerHTML = '<pre class="blimp-error"></pre>';
    host.querySelector('.blimp-error').textContent = String(message);
  }

  new Blimp().init(base + 'blimp.wasm').then(function (blimp) {
    return Promise.all([
      fetch(base + 'snake.blimp').then(function (r) { return r.text(); }),
      fetch(base + 'harness.blimp').then(function (r) { return r.text(); }),
    ]).then(function (parts) {
      var source = parts[0] + '\n' + parts[1] + '\napp <- :view\n';
      var frames = 0, worst = 0, t0 = 0;
      var view = new BlimpView(blimp, host, {
        onError: function (e) { say('error: ' + e); },
        onSend: function () { t0 = performance.now(); },
        onRender: function () {
          if (!t0) return;
          var ms = performance.now() - t0;
          frames += 1;
          if (ms > worst) worst = ms;
          say(frames + ' frames · last ' + ms.toFixed(0) + 'ms · worst ' + worst.toFixed(0) + 'ms');
        },
      });
      var started = performance.now();
      var r = view.mount(source, 'app');
      if (r && r.ok) {
        say((source.length / 1024).toFixed(0) + 'KB loaded in ' +
            (performance.now() - started).toFixed(0) + 'ms');
      }
    });
  }).catch(function (e) { fail((e && e.message) || e); });
})();
