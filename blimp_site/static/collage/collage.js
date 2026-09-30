// /collage-maker's pixels, after app.js has mounted collage.blimp
// (window.BlimpApp, actor `collage`). Blimp's view has no file input and
// no canvas it can read back, so this is the part of the page that cannot
// be the program, and the part of Phoenix's ImageProcessor that ran
// ImageMagick on the server:
//
//   identify -format "%w %h"                          -> createImageBitmap's size
//   convert -gravity center -crop SxS+0+0 +repage
//           -resize NxN! -quality 92                  -> drawImage of the centred
//                                                        square into its cell
//   convert -size WxH xc:#c0c0c0 ... -composite       -> one canvas, grey first,
//                                                        the last row centred
//
// and the JPEG is canvas.toBlob at 0.92. The files stay in this page
// (#cm-files), and the program is told what is picked with :files(json).
// The program asks for work by drawing <i data-op> nodes in #cm-outbox:
// remove (a), clear, and make (a columns, b the order as JSON, c the
// captcha); make answers :progress(text) as it goes and :done(n, status,
// body) with the POST's answer, or status 0 and the reason when the
// browser could not do it. Nothing here makes a stand-in image: a photo
// that does not decode, or a canvas the browser will not encode, stops the
// collage and says which.
(function () {
  var MAX_FILES = 36
  var MAX_FILE_SIZE = 20000000
  var MAX_CELL = 2048
  // Safari's canvas limit; Chrome's and Firefox's are larger
  var MAX_AREA = 16777216
  // WEB_MAX_UPLOAD in src/41_web.blimp
  var MAX_UPLOAD = 10485760
  var ACCEPT = /\.(jpe?g|png|webp)$/i

  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var csrf = document.getElementById('blimp-app').dataset.csrf || ''
    var input = document.getElementById('cm-files')

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

    var files = []
    function report(rejected) {
      var summary = files.map(function (f) { return { name: f.name, size: f.size } })
      send('files', literal(JSON.stringify({ files: summary, rejected: rejected || [] })))
    }
    // allow_upload's accept, max_entries and max_file_size, with its
    // messages (and the right number: the LiveView said "max 50")
    function add(list) {
      var rejected = []
      Array.prototype.forEach.call(list, function (f) {
        if (!ACCEPT.test(f.name)) rejected.push(f.name + ': Invalid file type')
        else if (f.size > MAX_FILE_SIZE) rejected.push(f.name + ': File too large (max 20MB)')
        else if (files.length >= MAX_FILES) rejected.push(f.name + ': Too many files (max 36)')
        else files.push(f)
      })
      report(rejected)
    }
    input.addEventListener('change', function () { add(input.files); input.value = '' })
    function inDrop(e) { return e.target && e.target.closest && e.target.closest('#cm-drop') }
    document.addEventListener('dragover', function (e) { if (inDrop(e)) e.preventDefault() })
    document.addEventListener('drop', function (e) {
      if (!inDrop(e)) return
      e.preventDefault()
      add(e.dataTransfer.files)
    })

    function progress(text) { send('progress', literal(text)) }
    function answer(n, status, body) { send('done', n + ', ' + status + ', ' + literal(body || '')) }
    function failed(n, message) { answer(n, 0, JSON.stringify({ error: 'browser', message: message })) }

    async function decode(f) {
      try {
        // EXIF orientation applied (imageOrientation defaults to from-image)
        return await createImageBitmap(f)
      } catch (e) {
        throw new Error('Could not read ' + f.name + ' as an image (' + (e && e.message || e) + ')')
      }
    }

    // compute_positions/4
    function position(pos, total, columns, rows, cell) {
      var row = Math.floor(pos / columns)
      var col = pos % columns
      var inLast = total - (rows - 1) * columns
      var x = col * cell
      if (row === rows - 1 && inLast < columns) x += Math.floor((columns - inLast) * cell / 2)
      return { x: x, y: row * cell }
    }

    async function make(n, columns, order, captcha) {
      var total = files.length
      try {
        if (total < 2) throw new Error('Upload at least 2 images.')
        // Pass one: sizes only, one photo decoded at a time (36 decoded
        // 12 MP photos at once is 1.7 GB).
        var minDim = Infinity
        for (var i = 0; i < total; i++) {
          progress('Analyzing image ' + (i + 1) + '/' + total + '...')
          var b = await decode(files[i])
          minDim = Math.min(minDim, b.width, b.height)
          b.close()
        }
        var rows = Math.ceil(total / columns)
        // compute_cell_size/1, and the canvas limit
        var cell = Math.min(minDim, MAX_CELL, Math.floor(Math.sqrt(MAX_AREA / (columns * rows))))
        var canvas = document.createElement('canvas')
        canvas.width = columns * cell
        canvas.height = rows * cell
        var ctx = canvas.getContext('2d')
        if (!ctx) throw new Error('This browser will not make a ' + canvas.width + 'x' + canvas.height + ' canvas')
        ctx.fillStyle = '#c0c0c0'
        ctx.fillRect(0, 0, canvas.width, canvas.height)
        ctx.imageSmoothingEnabled = true
        ctx.imageSmoothingQuality = 'high'
        // Pass two: file i goes to square order[i], as the LiveView put
        // upload i at position shuffled_order[i].
        for (var j = 0; j < total; j++) {
          progress('Cropping image ' + (j + 1) + '/' + total + '...')
          var bm = await decode(files[j])
          var s = Math.min(bm.width, bm.height)
          var p = position(order[j], total, columns, rows, cell)
          ctx.drawImage(bm, Math.floor((bm.width - s) / 2), Math.floor((bm.height - s) / 2), s, s, p.x, p.y, cell, cell)
          bm.close()
        }
        progress('Stitching collage...')
        var blob = await new Promise(function (resolve) { canvas.toBlob(resolve, 'image/jpeg', 0.92) })
        canvas.width = 0
        canvas.height = 0
        if (!blob) throw new Error('This browser could not encode a ' + columns * cell + 'x' + rows * cell + ' JPEG')
        if (blob.size > MAX_UPLOAD) throw new Error('The collage is ' + (blob.size / 1048576).toFixed(1) + ' MB; the limit is 10 MB. Try fewer or smaller photos.')
        progress('Uploading collage...')
        var form = new FormData()
        form.append('columns', String(columns))
        form.append('image_count', String(total))
        form.append('cell_size', String(cell))
        form.append('answer', captcha.answer || '')
        form.append('token', captcha.token || '')
        form.append('collage', blob, 'collage.jpg')
        var res = await fetch('/collage-maker/collages', { method: 'POST', headers: { 'x-csrf-token': csrf }, body: form, credentials: 'same-origin' })
        answer(n, res.status, await res.text())
      } catch (e) {
        failed(n, String(e && e.message || e))
      }
    }

    var done = {}
    function run(i) {
      var n = i.dataset.n, op = i.dataset.op
      if (done[n]) return
      done[n] = true
      if (op === 'remove') {
        files.splice(parseInt(i.dataset.a, 10), 1)
        report([])
      } else if (op === 'clear') {
        files = []
        report([])
      } else if (op === 'make') {
        make(n, parseInt(i.dataset.a, 10), JSON.parse(i.dataset.b), JSON.parse(i.dataset.c))
      } else {
        failed(n, 'no such op ' + op)
      }
    }
    function scan() {
      var box = document.getElementById('cm-outbox')
      if (box) Array.prototype.forEach.call(box.querySelectorAll('i[data-op]'), run)
    }
    var render = view.render
    view.render = function (v) { var out = render.call(view, v); scan(); return out }
    scan()
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
