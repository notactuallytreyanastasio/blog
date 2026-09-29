// Blimp, off the page's thread. Loads the interpreter and the site's own
// renderer (the same Blimp files the server rendered this post with), then
// renders the post's markdown again and reports each step: the runtime's
// actors and message log for the canvas, and the HTML for the page to
// compare with what the server sent.
importScripts("/blimp/blimp.js")

// A Blimp string literal holding `s`: the escapes Blimp reads, plus \#{ so
// Elixir's own #{...} in a code block is text, not interpolation.
function literal(s) {
  return '"' + s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/#\{/g, "\\#{") + '"'
}

self.onmessage = async function (ev) {
  var slug = ev.data.slug
  try {
    var blimp = new Blimp()
    blimp.onPrint(function () {})
    await blimp.init("/blimp/blimp.wasm")
    var [program, source] = await Promise.all([
      fetch("/blimp/post-renderer.blimp").then(function (r) { return r.text() }),
      fetch("/post/" + slug + ".md").then(function (r) {
        if (!r.ok) throw new Error("/post/" + slug + ".md is " + r.status)
        return r.text()
      }),
    ])
    var loaded = blimp.eval(program)
    if (!loaded.ok) throw new Error(loaded.error)
    self.postMessage({ step: "loaded", state: blimp.getState() })

    var t0 = Date.now()
    var rendered = blimp.eval("post <- :render(" + literal(source) + ")")
    if (!rendered.ok) throw new Error(rendered.error)
    var ms = Date.now() - t0
    var html = blimp.send("post", "html")
    if (!html.ok) throw new Error(html.error)
    self.postMessage({ step: "rendered", state: blimp.getState(), html: html.value, ms: ms })
  } catch (e) {
    self.postMessage({ step: "error", error: String(e.message || e) })
  }
}
