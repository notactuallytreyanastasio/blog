// /sky's map, after app.js has mounted sky.blimp (window.BlimpApp, actor
// `sky`). deck.gl (static/sky/deck.gl-9.2.9.min.js, npm's deck.gl@9.2.9
// dist.min.js unchanged) draws 545,173 points; this file is the part of
// SkyLive's SkyMap hook that is about points and the camera:
//
//  - the points are /sky/points.json.gz (static/sky/build_points.blimp);
//  - which communities, where and in what colour is the program's to say
//    (`sky <- :discs`, laid out by Temper at build time); which one is lit,
//    and when to fly to it, too (`sky <- :scene`, read after every render);
//  - every account's place in its disc (a golden-angle spiral, the hook's
//    clusterByCommunity), the median of those places (where the label
//    goes: recomputeCentroids), the selection ring (the 92nd percentile of
//    their distances) and the camera are here, because they are per point,
//    and half a million of anything is not a job for an interpreter;
//  - clicks and hovers on the map go to the program: a disc or label is
//    `sky <- :select(i)`, an account `sky <- :point(handle, i)`.
(function () {
  var GOLDEN_ANGLE = 2.399963

  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view

    // deck.gl draws into a div of its own, kept in #sky-map; should a render
    // ever replace #sky-map, the div moves to the new one.
    var host = document.createElement('div')
    host.style.cssText = 'position:relative;width:100%;height:100%;'
    var tip = document.createElement('div')
    tip.className = 'sky-tip'
    host.appendChild(tip)
    function place() {
      var el = document.getElementById('sky-map')
      if (el && host.parentNode !== el) el.appendChild(host)
      return el
    }
    place()

    var viewState = { target: [0, 0, 0], zoom: 3 }
    var deckgl = new deck.Deck({
      parent: host,
      views: new deck.OrthographicView({ id: 'ortho', flipY: true }),
      initialViewState: { ortho: viewState },
      controller: { scrollZoom: true, dragPan: true, doubleClickZoom: true },
      onViewStateChange: function (e) { viewState = e.viewState },
      getTooltip: function () { return null },
      layers: []
    })

    var grouped = null    // community index -> its points, in the file's order
    var points = []       // what is drawn: the visible communities' points
    var discs = []        // the program's discs, with centroid_x/y added
    var byIndex = {}
    var mode = null, lit = null, focus = 0, told = false

    function ask(msg) {
      var r = app.blimp.send('sky', msg)
      return r.ok ? r.value : null
    }

    function sync() {
      place()
      var s = ask('scene')
      if (!s || !s.ready || !grouped) return
      var rebuilt = false
      if (s.mode !== mode) {
        mode = s.mode
        rebuild(ask('discs') || [])
        rebuilt = true
      }
      var focusNow = s.focus !== focus
      if (rebuilt || s.lit !== lit) { lit = s.lit; layers() }
      focus = s.focus
      if (focusNow && lit !== null && lit !== undefined) zoomTo(lit)
      if (!told) { told = true; setTimeout(function () { view.send('loaded') }, 0) }
    }

    // clusterByCommunity and recomputeCentroids, for the discs the program
    // placed, in its order (largest first).
    function rebuild(ds) {
      points = []
      byIndex = {}
      discs = ds.map(function (d) {
        var members = grouped[d.i] || []
        var n = members.length
        var color = d.rgb
        var xs = new Float64Array(n), ys = new Float64Array(n)
        for (var k = 0; k < n; k++) {
          var angle = k * GOLDEN_ANGLE
          var dist = d.r * Math.sqrt(k / n) * 0.9
          var m = members[k]
          var p = {
            x: d.x + Math.cos(angle) * dist,
            y: d.y + Math.sin(angle) * dist,
            community_index: d.i,
            handle: m.h,
            followers_count: m.f,
            community_label: d.l || '',
            _color: color
          }
          xs[k] = p.x
          ys[k] = p.y
          points.push(p)
        }
        xs.sort()
        ys.sort()
        var mid = Math.floor(n / 2)
        var c = {
          community_index: d.i, label: d.l, member_count: d.m, disc_r: d.r, color: color,
          centroid_x: n ? xs[mid] : d.x, centroid_y: n ? ys[mid] : d.y
        }
        byIndex[d.i] = c
        return c
      })
      fitBounds()
    }

    function ring(i) {
      var c = byIndex[i]
      if (!c) return []
      var dists = []
      for (var k = 0; k < points.length; k++) {
        var p = points[k]
        if (p.community_index === i) dists.push(Math.sqrt(Math.pow(p.x - c.centroid_x, 2) + Math.pow(p.y - c.centroid_y, 2)))
      }
      if (!dists.length) return []
      dists.sort(function (a, b) { return a - b })
      var r90 = dists[Math.floor(dists.length * 0.92)] || dists[dists.length - 1]
      return [{ x: c.centroid_x, y: c.centroid_y, radius: r90 * 1.15 }]
    }

    function showTip(x, y, html) {
      tip.style.display = 'block'
      tip.style.left = x + 12 + 'px'
      tip.style.top = y + 12 + 'px'
      tip.innerHTML = html
    }

    function esc(s) {
      return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    }

    function layers() {
      var selected = lit
      var has = selected !== null && selected !== undefined
      var pick = function (info) { if (info.object) view.send('select', String(info.object.community_index)) }

      var hover = new deck.ScatterplotLayer({
        id: 'community-hover',
        data: discs,
        getPosition: function (d) { return [d.centroid_x, d.centroid_y] },
        getRadius: function (d) { return d.disc_r || 0.1 },
        getFillColor: [0, 0, 0, 0],
        pickable: true,
        onHover: function (info) {
          if (!info.object) { tip.style.display = 'none'; return }
          showTip(info.x, info.y, '<b>' + esc(info.object.label || 'Community ' + info.object.community_index) + '</b>' +
            '<br/>' + (info.object.member_count || 0).toLocaleString() + ' members')
        },
        onClick: pick
      })

      var users = new deck.ScatterplotLayer({
        id: 'users',
        data: points,
        getPosition: function (d) { return [d.x, d.y] },
        getRadius: function (d) {
          var base = Math.sqrt(Math.min(d.followers_count || 10, 5000)) / 25
          if (has) return d.community_index === selected ? base * 1.2 : base * 0.5
          return base
        },
        getFillColor: function (d) {
          var c = d._color
          if (has && d.community_index !== selected) return [c[0], c[1], c[2], 30]
          return [c[0], c[1], c[2], 200]
        },
        radiusMinPixels: 0.5,
        radiusMaxPixels: 5,
        pickable: true,
        onHover: function (info) {
          if (!info.object) { tip.style.display = 'none'; return }
          var tc = info.object._color
          showTip(info.x, info.y, '<b>' + esc(info.object.handle || 'unknown') + '</b>' +
            '<br/><span style="color:rgb(' + tc[0] + ',' + tc[1] + ',' + tc[2] + ')">' + esc(info.object.community_label || '') + '</span>')
        },
        onClick: function (info) {
          if (info.object) view.send('point', literal(info.object.handle) + ', ' + info.object.community_index)
        },
        updateTriggers: { getFillColor: [selected], getRadius: [selected] }
      })

      var selection = new deck.ScatterplotLayer({
        id: 'selection-ring',
        data: has ? ring(selected) : [],
        getPosition: function (d) { return [d.x, d.y] },
        getRadius: function (d) { return d.radius },
        getFillColor: [0, 0, 0, 0],
        getLineColor: [0, 0, 0, 200],
        stroked: true,
        filled: false,
        lineWidthMinPixels: 2,
        lineWidthMaxPixels: 3,
        updateTriggers: { data: [selected] }
      })

      var labels = new deck.TextLayer({
        id: 'community-labels',
        data: discs.filter(function (c) { return c.disc_r > 0 }),
        getPosition: function (d) { return [d.centroid_x, d.centroid_y] },
        getText: function (d) { return d.label || 'Community ' + d.community_index },
        getSize: function (d) { return Math.max(d.disc_r * 0.28, 0.15) },
        sizeUnits: 'common',
        sizeMinPixels: 10,
        sizeMaxPixels: 50,
        getColor: function (d) {
          if (has && d.community_index !== selected) return [0, 0, 0, 30]
          if (has && d.community_index === selected) return [0, 0, 0, 255]
          return [0, 0, 0, 200]
        },
        fontFamily: 'Chicago, Geneva, Helvetica, sans-serif',
        fontWeight: 'bold',
        getTextAnchor: 'middle',
        getAlignmentBaseline: 'center',
        background: true,
        getBackgroundColor: function (d) {
          if (has && d.community_index === selected) return [255, 255, 255, 220]
          return [255, 255, 255, 160]
        },
        backgroundPadding: [4, 2],
        maxWidth: 180,
        wordBreak: 'break-word',
        pickable: true,
        onClick: pick,
        updateTriggers: { getColor: [selected], getBackgroundColor: [selected] }
      })

      deckgl.setProps({ layers: [hover, users, selection, labels] })
    }

    function animate(target, zoom) {
      viewState = { target: target, zoom: zoom, transitionDuration: 600 }
      deckgl.setProps({ initialViewState: { ortho: viewState } })
    }

    function zoomTo(i) {
      var c = byIndex[i]
      if (c) animate([c.centroid_x, c.centroid_y, 0], 7)
    }

    function fitBounds() {
      if (!points.length) return
      var minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity
      for (var k = 0; k < points.length; k++) {
        var p = points[k]
        if (p.x < minX) minX = p.x
        if (p.x > maxX) maxX = p.x
        if (p.y < minY) minY = p.y
        if (p.y > maxY) maxY = p.y
      }
      var el = place() || host
      var zoom = Math.log2(Math.min(el.clientWidth / (maxX - minX || 1), el.clientHeight / (maxY - minY || 1))) - 1
      animate([(minX + maxX) / 2, (minY + maxY) / 2, 0], Math.max(zoom, -2))
    }

    // Every render the program makes, then sync(): the view is patched
    // first, so the map reads the state the page now shows.
    var render = view.render
    view.render = function (v) {
      var out = render.call(view, v)
      sync()
      return out
    }

    // static/sky/build_points.blimp: {runs: [[community, count], ...], h, f},
    // the hook's points grouped by community, gzipped.
    fetch('/sky/points.json.gz')
      .then(function (r) {
        if (!r.ok) throw new Error('/sky/points.json.gz is ' + r.status)
        return new Response(r.body.pipeThrough(new DecompressionStream('gzip'))).json()
      })
      .then(function (data) {
        grouped = {}
        var k = 0
        data.runs.forEach(function (run) {
          var members = new Array(run[1])
          for (var j = 0; j < run[1]; j++, k++) members[j] = { h: data.h[k], f: data.f[k] }
          grouped[run[0]] = members
        })
        sync()
      })
      .catch(function (e) { console.error('[sky] failed to load the points:', e) })

    sync()
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
