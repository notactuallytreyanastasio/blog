// /curate's drag, after app.js has mounted the page's Blimp program
// (window.BlimpApp) and admin.js has taken the outbox. A tile
// (.cu-list [data-path]) dragged over another is dropped before or after
// it; over a card's empty space, at that card's end. The program is sent
// `:moved(path, target, after, group)` (target "" for the end) and redraws
// the cards itself; nothing is moved here.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view

    // BlimpView drops a send made while another is being handled
    var queue = []
    function send(msg, args) { queue.push([msg, args]); setTimeout(drain, 0) }
    function drain() {
      while (queue.length) {
        var m = queue[0]
        if (view.send(m[0], m[1]) === false && view._sending) { setTimeout(drain, 5); return }
        queue.shift()
      }
    }

    var dragPath = null, overEl = null, overList = null, after = false
    function tile(t) { return t && t.closest ? t.closest('.cu-list [data-path]') : null }
    function list(t) { return t && t.closest ? t.closest('.cu-list') : null }
    function mark(el, below) {
      if (overEl && overEl !== el) overEl.classList.remove('cu-before', 'cu-after')
      overEl = el
      after = below
      if (el) {
        el.classList.toggle('cu-after', below)
        el.classList.toggle('cu-before', !below)
      }
    }
    function markList(l) {
      if (overList && overList !== l) overList.classList.remove('cu-over')
      overList = l
      if (l) l.classList.add('cu-over')
    }
    document.addEventListener('dragstart', function (e) {
      var r = tile(e.target)
      if (!r) return
      dragPath = r.dataset.path
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData('text/plain', '')
      r.classList.add('cu-dragging')
    })
    document.addEventListener('dragover', function (e) {
      if (dragPath === null) return
      var l = list(e.target)
      if (!l) { mark(null, false); markList(null); return }
      e.preventDefault()
      e.dataTransfer.dropEffect = 'move'
      markList(l)
      var r = tile(e.target)
      if (!r || r.dataset.path === dragPath) return mark(null, false)
      var rect = r.getBoundingClientRect()
      mark(r, e.clientY >= rect.top + rect.height / 2)
    })
    document.addEventListener('drop', function (e) { if (dragPath !== null) e.preventDefault() })
    document.addEventListener('dragend', function () {
      if (dragPath === null) return
      var moved = dragPath, target = overEl, below = after, l = overList
      Array.prototype.forEach.call(document.querySelectorAll('.cu-tile'), function (r) {
        r.classList.remove('cu-dragging', 'cu-before', 'cu-after')
      })
      Array.prototype.forEach.call(document.querySelectorAll('.cu-list'), function (u) { u.classList.remove('cu-over') })
      dragPath = null
      overEl = null
      overList = null
      if (target) {
        send('moved', literal(moved) + ', ' + literal(target.dataset.path) + ', ' + (below ? 1 : 0) + ', ' + literal(target.dataset.group))
      } else if (l) {
        send('moved', literal(moved) + ', "", 1, ' + literal(l.dataset.group))
      }
    })
    return true
  }

  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
