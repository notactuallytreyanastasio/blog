// /role-call's browser half, after app.js has mounted role_call.blimp
// (window.BlimpApp, actor `rc`). The program owns the page; this does what
// a program in WebAssembly cannot reach:
//
//  - localStorage. The LiveView's inline script read role_call_liked,
//    role_call_hidden and role_call_tour_completed when the page loaded and
//    pushed them to the server; this sends them as one message,
//    `rc <- :restore(liked, hidden, completed)`, ids comma-joined. It wrote
//    them back on the server's store_liked, store_hidden and tour_completed
//    events; this writes them back when the program's #rc-store says
//    something else, and not before the program has read them.
//  - CardGrid: the card grid's width, `rc <- :grid(w)`, whenever it changes.
//    How many cards make two rows is the program's arithmetic.
//  - TourSpotlight: where the tour's target is. The program answers
//    `rc <- :place(...)` with where the spotlight and tooltip go.
//  - a poster that fails to load: the card's onerror, which hid the image
//    and showed the placeholder after it.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  // a Blimp Float: 12 is an Int to Blimp, 12.0 is not
  function float(x) {
    var s = String(+x || 0)
    return /[.e]/.test(s) ? s : s + '.0'
  }

  function read(key) {
    try { return localStorage.getItem(key) } catch (e) { return null }
  }

  function write(key, value) {
    try { localStorage.setItem(key, value) } catch (e) {}
  }

  function ids(key) {
    try {
      var v = JSON.parse(read(key) || '[]')
      return Array.isArray(v) ? v.filter(function (x) { return typeof x === 'string' }).join(',') : ''
    } catch (e) {
      return ''
    }
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var root = document.getElementById('blimp-app')

    // -- localStorage ----------------------------------------------------------

    view.send('restore', literal(ids('role_call_liked')) + ', ' + literal(ids('role_call_hidden')) + ', ' +
      (read('role_call_tour_completed') === 'true' ? 'true' : 'false'))

    var stored = { liked: null, hidden: null }
    function save() {
      var s = document.getElementById('rc-store')
      if (!s || s.dataset.ready !== '1') return
      ;['liked', 'hidden'].forEach(function (k) {
        var v = s.dataset[k] || ''
        if (stored[k] === v) return
        stored[k] = v
        write('role_call_' + k, JSON.stringify(v === '' ? [] : v.split(',')))
      })
      if (s.dataset.tourDone === '1' && read('role_call_tour_completed') !== 'true') write('role_call_tour_completed', 'true')
    }

    // -- the card grid ---------------------------------------------------------

    var lastW = -1, grid = null
    var ro = new ResizeObserver(measure)
    function measure() {
      var g = document.getElementById('tour-cards')
      if (g !== grid) { if (grid) ro.unobserve(grid); grid = g; if (g) ro.observe(g) }
      if (!g) return
      var w = Math.round(g.getBoundingClientRect().width)
      if (w === lastW || w === 0) return
      lastW = w
      view.send('grid', String(w))
    }

    // -- the tour --------------------------------------------------------------

    function place() {
      var tip = document.getElementById('tour-tooltip')
      if (!tip) return
      var spot = document.getElementById('tour-spotlight')
      var target = spot && document.getElementById(spot.dataset.target)
      if (!spot || !target) {
        // a centred step: the stylesheet places it (and a step before may
        // have left a place here)
        tip.style.top = ''
        tip.style.left = ''
        return
      }
      var r = target.getBoundingClientRect()
      var t = tip.getBoundingClientRect()
      var position = ['bottom', 'top', 'right', 'center'].filter(function (c) { return tip.classList.contains(c) })[0] || ''
      var res = app.blimp.send('rc', 'place', [literal(position), float(r.top), float(r.left), float(r.width), float(r.height),
        float(t.width), float(t.height), float(window.innerHeight)].join(', '))
      if (!res.ok) return console.error('rc <- :place: ' + res.error)
      var p = res.value
      spot.style.top = p.spot[0] + 'px'
      spot.style.left = p.spot[1] + 'px'
      spot.style.width = p.spot[2] + 'px'
      spot.style.height = p.spot[3] + 'px'
      if (p.tip.length === 2) {
        tip.style.top = p.tip[0] + 'px'
        tip.style.left = p.tip[1] + 'px'
      }
      // as the hook did: placed first, then scrolled, and not placed again
      // after, so a step whose target was near an edge points where the
      // target was (placed after the scroll, step 3's tooltip, above a
      // target taller than the window, lands off the top with its Next
      // button)
      if (p.scroll) target.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }

    // -- after every render ----------------------------------------------------

    var queued = false
    function rendered() {
      if (queued) return
      queued = true
      requestAnimationFrame(function () {
        queued = false
        save()
        measure()
        place()
      })
    }
    // not `style`: this sets it, and would hear itself
    new MutationObserver(rendered).observe(root, { childList: true, subtree: true, characterData: true, attributes: true,
      attributeFilter: ['class', 'id', 'data-target', 'data-ready', 'data-liked', 'data-hidden', 'data-tour-done'] })
    window.addEventListener('resize', function () { measure(); place() })
    rendered()

    // -- a broken poster -------------------------------------------------------

    root.addEventListener('error', function (e) {
      var img = e.target
      if (!img || img.tagName !== 'IMG' || !img.parentNode || !img.parentNode.classList.contains('card-image')) return
      img.style.display = 'none'
      if (img.nextElementSibling) img.nextElementSibling.style.display = 'flex'
    }, true)
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start)
})()
