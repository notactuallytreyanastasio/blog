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

  BlimpPageCanvas.prototype.feed = function () {
    var self = this
    if (this.pending) return
    this.pending = setTimeout(function () {
      self.pending = null
      var state = self.blimp.getState()
      self.viz.feed(state, null)
      self.sent += (state.messages || []).length
      var n = (state.actors || []).length
      self.status.textContent = n + (n === 1 ? ' actor' : ' actors') + ', ' + self.sent + ' messages while you watched'
    }, 200)
  }

  window.BlimpPageCanvas = BlimpPageCanvas
})()
