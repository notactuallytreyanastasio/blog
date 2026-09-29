// The Blimp window, for a page whose program runs in the browser: Blimp's
// canvas drawing that program -- its actors, and a ray for every message
// sent to them -- rather than the server (runtime.js draws the server, on
// the pages the server renders).
//
//   var pc = new BlimpPageCanvas(blimp)   // then, after every render:
//   pc.feed()
//
// A game renders thirty times a second; the canvas is fed at most five,
// with whatever messages piled up in between (getState() hands over the
// messages since its last call).
(function () {
  function BlimpPageCanvas(blimp) {
    this.blimp = blimp
    this.pending = null
    var closed = document.createElement('span')
    closed.id = 'blimp-pg-closed'
    var box = document.createElement('div')
    box.id = 'blimp-page'
    box.className = 'blimp-window blimp-runtime'
    box.innerHTML =
      '<div class="mac-title-bar"><a href="#blimp-pg-closed" class="mac-close-box" title="close"></a>' +
      '<div class="mac-title">Blimp: this page’s program, running</div></div>' +
      '<div id="blimp-pg-wrap"><canvas id="blimp-pg"></canvas></div>' +
      '<div id="blimp-pg-status" class="blimp-status">starting...</div>'
    document.body.appendChild(closed)
    document.body.appendChild(box)
    this.status = document.getElementById('blimp-pg-status')
    this.viz = new BlimpCanvas(document.getElementById('blimp-pg'))
    this.sent = 0
  }

  // Past this many actors, draw the ones in use: those a message went to or
  // came from since the last feed, and those a top-level name holds. Snake,
  // compiled from Temper, makes an actor of every point: about 500 a frame,
  // and none go away.
  var MAX_DRAWN = 300

  BlimpPageCanvas.prototype.feed = function () {
    var self = this
    if (this.pending) return
    this.pending = setTimeout(function () {
      self.pending = null
      var t0 = performance.now()
      var state = self.blimp.getState()
      var cost = performance.now() - t0
      var actors = state.actors || []
      var messages = state.messages || []
      var shown = actors
      if (actors.length > MAX_DRAWN) {
        var busy = {}
        messages.forEach(function (m) { busy[m.target] = true; if (m.from) busy[m.from] = true })
        ;(state.vars || []).forEach(function (v) { if (v.value && v.value.indexOf('ref<') === 0) busy[v.value] = true })
        shown = actors.filter(function (a) { return busy[a.ref] }).slice(0, MAX_DRAWN)
      }
      self.viz.feed({ vars: state.vars, actors: shown, messages: messages }, null)
      self.sent += messages.length
      var n = actors.length
      self.status.textContent = n + (n === 1 ? ' actor' : ' actors') +
        (shown.length < n ? ' (drawing the ' + shown.length + ' in use)' : '') +
        ', ' + self.sent + ' messages while you watched'
      // building the state costs what the program is; a big one is read less often
      self.every = Math.min(10000, Math.max(200, cost * 30))
    }, this.every || 200)
  }

  window.BlimpPageCanvas = BlimpPageCanvas
})()
