// /piet/life: Life on Piet programs, on a page of its own. Opens as many
// small games as fit, each its own Piet program (PietArt.Tiles), or with
// #board one game the size of the window (PietArt.Fill); the card switches
// between them. static/piet/art.js says what each one does.
(function () {
  var current = null
  function open(mode) {
    var art = window.PietArt
    if (current) current.close()
    var opts = {
      standalone: true,
      onSwitch: function () {
        var other = mode === 'board' ? 'tiles' : 'board'
        history.replaceState(null, '', other === 'board' ? '#board' : location.pathname)
        open(other)
      }
    }
    current = mode === 'board' ? new art.Fill(art.INNER_ROWS, opts) : new art.Tiles(opts)
    var status = document.getElementById('piet-life-status')
    if (status) status.textContent = ''
  }
  open(location.hash === '#board' ? 'board' : 'tiles')
})()
