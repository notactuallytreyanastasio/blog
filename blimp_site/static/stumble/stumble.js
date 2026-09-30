// /stumble's browser half, after app.js has mounted stumble.blimp
// (window.BlimpApp, actor `st`).
//
// A filter rule's select or input was a little form with a hidden rule_id,
// and phx-change sent the form: the rule and the new value together. An
// el() event carries only the value, so the program marks those fields
// data-send (the message) and data-rule (the rule's id), and this sends
// `st <- :rule_op(3, "lte")`: at once for a select, and for an input once
// typing has paused for 300ms, which was phx-debounce="300".
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var root = document.getElementById('blimp-app')
    function send(el) {
      var id = parseInt(el.getAttribute('data-rule'), 10)
      if (isNaN(id)) return
      app.view.send(el.getAttribute('data-send'), id + ', ' + literal(el.value))
    }
    root.addEventListener('change', function (e) {
      var el = e.target
      if (el.tagName === 'SELECT' && el.hasAttribute('data-send')) send(el)
    })
    root.addEventListener('input', function (e) {
      var el = e.target
      if (el.tagName !== 'INPUT' || !el.hasAttribute('data-send')) return
      clearTimeout(el._stumbleDebounce)
      el._stumbleDebounce = setTimeout(function () { send(el) }, 300)
    })
    return true
  }

  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
