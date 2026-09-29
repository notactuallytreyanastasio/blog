// /temper-snake: the game (snake.blimp, compiled from Temper) and its
// Blimp runner (harness.blimp), mounted into the page as the temper_snake
// repo's embed.js does -- same sources, same frame counter -- on the site's
// own copy of Blimp, with the Blimp window drawing the game as it runs.
(function () {
  'use strict'
  var host = document.getElementById('snake-app')
  var status = document.getElementById('snake-status')
  if (!host || host.dataset.mounted) return
  host.dataset.mounted = '1'
  var base = '/static/temper-snake/'
  var say = function (s) { if (status) status.textContent = s }
  function fail(message) {
    host.innerHTML = '<pre class="blimp-error"></pre>'
    host.querySelector('.blimp-error').textContent = String(message)
  }
  new Blimp().init('/blimp/blimp.wasm').then(function (blimp) {
    return Promise.all([
      fetch(base + 'snake.blimp').then(function (r) { return r.text() }),
      fetch(base + 'harness.blimp').then(function (r) { return r.text() }),
    ]).then(function (parts) {
      var source = parts[0] + '\n' + parts[1] + '\napp <- :view\n'
      var frames = 0, worst = 0, t0 = 0
      var canvas = window.BlimpPageCanvas ? new BlimpPageCanvas(blimp) : null
      // send, not eval: eval rebuilds the whole state after every frame,
      // and this program has tens of thousands of actors after a minute.
      // The canvas asks for the state itself, when it can afford to.
      var view = new BlimpView(blimp, host, {
        send: true,
        onError: function (e) { say('error: ' + e) },
        onSend: function () { t0 = performance.now() },
        onRender: function () {
          if (canvas) canvas.feed()
          if (!t0) return
          var ms = performance.now() - t0
          frames += 1
          if (ms > worst) worst = ms
          say(frames + ' frames · last ' + ms.toFixed(0) + 'ms · worst ' + worst.toFixed(0) + 'ms')
        },
      })
      var started = performance.now()
      var r = view.mount(source, 'app')
      if (r && r.ok) say((source.length / 1024).toFixed(0) + 'KB loaded in ' + (performance.now() - started).toFixed(0) + 'ms')
    })
  }).catch(function (e) { fail((e && e.message) || e) })
})()
