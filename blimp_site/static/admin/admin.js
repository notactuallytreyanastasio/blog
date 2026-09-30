// /admin/museum and /admin/finder's transport, after app.js has mounted the
// page's Blimp program (window.BlimpApp). A Blimp program in the browser can
// GET and nothing else, so it draws what it wants done as hidden
// <i data-op> nodes in #adm-outbox, numbered, and this does each once and
// answers `:done(n, status, body)` (static/admin/common.blimp lists them):
//
//   op        data-a      data-b     data-c   answers
//   http      method      url        JSON     status, body; with the page's
//                                             CSRF token as x-csrf-token
//   confirm   question                        1 | 0
//
// and one thing the Sortable hook did: a row with data-sort-id dragged
// over another in #adm-sortable is dropped before or after it, and the
// program is sent the new order as `:reorder("[\"3\",\"1\",...]")`. The
// rows are not moved here; the program redraws them in the order it is sent.
// Like the hook, every drag sends the order, even one dropped where it began.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var csrf = document.getElementById('blimp-app').dataset.csrf || ''

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

    var done = {}
    function answer(n, status, body) { send('done', n + ', ' + status + ', ' + literal(body || '')) }
    function run(i) {
      var n = i.dataset.n, op = i.dataset.op, a = i.dataset.a || '', b = i.dataset.b || '', c = i.dataset.c || ''
      if (done[n]) return
      done[n] = true
      if (op === 'http') {
        var headers = { 'x-csrf-token': csrf }
        if (c) headers['content-type'] = 'application/json'
        fetch(b, { method: a, headers: headers, body: c || undefined, credentials: 'same-origin' })
          .then(function (res) { return res.text().then(function (text) { answer(n, res.status, text) }) })
          .catch(function (e) { answer(n, 0, String(e)) })
      } else if (op === 'confirm') {
        answer(n, window.confirm(a) ? 1 : 0, '')
      } else {
        answer(n, 400, 'no such op ' + op)
      }
    }
    function scan() {
      var box = document.getElementById('adm-outbox')
      if (box) Array.prototype.forEach.call(box.querySelectorAll('i[data-op]'), run)
    }
    var render = view.render
    view.render = function (v) { var out = render.call(view, v); scan(); return out }
    scan()

    // -- drag to reorder ------------------------------------------------------
    var dragId = null, overEl = null, after = false
    function row(t) { return t && t.closest ? t.closest('#adm-sortable [data-sort-id]') : null }
    function mark(el, below) {
      if (overEl && overEl !== el) overEl.style.boxShadow = ''
      overEl = el
      after = below
      if (el) el.style.boxShadow = below ? 'inset 0 -3px 0 #4a90d9' : 'inset 0 3px 0 #4a90d9'
    }
    document.addEventListener('dragstart', function (e) {
      var r = row(e.target)
      if (!r) return
      dragId = r.dataset.sortId
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData('text/plain', '')
      r.style.opacity = '0.4'
    })
    document.addEventListener('dragover', function (e) {
      if (dragId === null) return
      var r = row(e.target)
      e.preventDefault()
      if (!r || r.dataset.sortId === dragId) return mark(null, false)
      var rect = r.getBoundingClientRect()
      mark(r, e.clientY >= rect.top + rect.height / 2)
    })
    document.addEventListener('drop', function (e) { if (dragId !== null) e.preventDefault() })
    document.addEventListener('dragend', function (e) {
      if (dragId === null) return
      var rows = Array.prototype.slice.call(document.querySelectorAll('#adm-sortable [data-sort-id]'))
      rows.forEach(function (r) { r.style.opacity = ''; r.style.boxShadow = '' })
      var target = overEl, below = after, moved = dragId
      dragId = null
      overEl = null
      // the hook sent the order on every dragend, moved or not, and
      // bulk_reorder/1 renumbers every row 0, 1, 2, ... either way
      var ids = rows.map(function (r) { return r.dataset.sortId })
      if (target) {
        ids = ids.filter(function (id) { return id !== moved })
        var at = ids.indexOf(target.dataset.sortId)
        ids.splice(below ? at + 1 : at, 0, moved)
      }
      send('reorder', literal(JSON.stringify(ids)))
    })
    return true
  }

  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
