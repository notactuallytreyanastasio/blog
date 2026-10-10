// /piet/life: Life on Piet programs, on a page of its own. Opens as many
// small games as fit, each its own Piet program (PietArt.Tiles), or one game
// the size of the window (PietArt.Fill). /piet/tiles and /piet/board are the
// same page opened on one or the other, so each has a link to share;
// /piet/life#board is the older link to the board. The card switches between
// them. static/piet/art.js says what each one does.
(function () {
  var current = null
  function open(mode) {
    var art = window.PietArt
    if (current) current.close()
    var opts = {
      standalone: true,
      onSwitch: function () {
        var other = mode === 'board' ? 'tiles' : 'board'
        history.replaceState(null, '', '/piet/' + other)
        open(other)
      }
    }
    current = mode === 'board' ? new art.Fill(art.INNER_ROWS, opts) : new art.Tiles(opts)
    var status = document.getElementById('piet-life-status')
    if (status) status.textContent = ''
  }
  open(location.pathname === '/piet/board' || location.hash === '#board' ? 'board' : 'tiles')
})()
