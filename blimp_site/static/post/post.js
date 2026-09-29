// The Blimp window on a post page. A worker renders this post again with the
// site's own Blimp renderer; Blimp's canvas draws the program doing it (a
// Post asks Markdown to render, Markdown asks the Highlighter once per code
// block); and the result is compared, byte for byte, with the HTML the
// server sent.
(function () {
  var box = document.getElementById("blimp-window")
  if (!box || !window.Worker) return
  var slug = box.dataset.slug
  var status = document.getElementById("blimp-status")
  function say(text, cls) {
    status.textContent = text
    status.className = "blimp-status " + (cls || "")
  }
  var viz = new BlimpCanvas(document.getElementById("blimp-viz"))

  // The server's HTML for this post, exactly as sent: re-read the page (from
  // cache) and cut out the article, rather than trust innerHTML to give back
  // the same bytes.
  var served = fetch(location.pathname).then(function (r) { return r.text() }).then(function (page) {
    var open = '<div id="post-content" class="article-content">'
    var start = page.indexOf(open) + open.length
    var end = page.indexOf('</div><div class="post-footer">', start)
    return page.slice(start, end)
  })

  var worker = new Worker("/blimp/post-worker.js")
  worker.onmessage = function (ev) {
    var m = ev.data
    if (m.step === "error") return say("Blimp stopped: " + m.error, "bad")
    viz.feed(m.state, null)
    if (m.step === "loaded") return say("rendering this post in Blimp...")
    if (m.step === "rendered") {
      served.then(function (html) {
        var kb = (m.html.length / 1024).toFixed(1)
        if (m.html === html) say("rendered " + kb + "KB in " + m.ms + "ms, the same bytes the server sent", "good")
        else say("rendered " + kb + "KB in " + m.ms + "ms, and it differs from what the server sent", "bad")
      })
    }
  }
  say("loading Blimp...")
  worker.postMessage({ slug: slug })
})()
