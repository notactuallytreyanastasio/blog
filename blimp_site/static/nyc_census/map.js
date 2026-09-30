// The map on /nyc_census_and_pluto: Leaflet, Leaflet.draw and Leaflet.heat,
// as the NycMap hook drew them. What the hook asked the LiveView for, it
// asks the page's Blimp program instead (static/nyc_census/census.blimp,
// `census`, mounted by /blimp/app.js): the heatmap's points, the URL of the
// lots in a shape's bounding box, and the markers for them. This file
// fetches and draws; it computes nothing.
(function () {
  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function whenMounted(f) {
    if (window.BlimpApp) return f(window.BlimpApp)
    document.addEventListener('blimp-app-mounted', function () { f(window.BlimpApp) })
  }

  function load(tag, attrs) {
    return new Promise(function (resolve) {
      var el = document.createElement(tag)
      Object.keys(attrs).forEach(function (k) { el[k] = attrs[k] })
      el.onload = function () { resolve() }
      document.head.appendChild(el)
    })
  }

  function loadLeaflet() {
    if (window.L && window.L.Draw) return Promise.resolve()
    load('link', { rel: 'stylesheet', href: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css' })
    load('link', { rel: 'stylesheet', href: 'https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.css' })
    return load('script', { src: 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js' }).then(function () {
      return load('script', { src: 'https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js' })
    })
  }

  function loadHeat() {
    if (window.L && window.L.heatLayer) return Promise.resolve()
    return load('script', { src: 'https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js' })
  }

  var map, drawnItems, markers, heatLayer, heatVisible = false, app, drawn = 0, tractsReady

  // One message to `census` that changes what the panel shows: send it,
  // then have the view render. The reply is the message's answer.
  function tell(msg, args) {
    var r = app.blimp.send(app.actor, msg, args)
    app.view.send('shown')
    if (!r.ok) throw new Error(r.error)
    return r.value
  }

  function fetchText(url) {
    return fetch(url, { credentials: 'same-origin' }).then(function (res) {
      return res.text().then(function (body) { return res.status + ', ' + literal(body) })
    })
  }

  function initMap() {
    map = L.map('nyc-map', { center: [40.7128, -74.006], zoom: 12, zoomControl: true })
    // The hook used CARTO's light_all tiles, which now answer every
    // request with a picture saying API KEY REQUIRED (production shows
    // nothing else). OpenStreetMap's own tiles instead, as /map does.
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
    }).addTo(map)
    drawnItems = new L.FeatureGroup()
    map.addLayer(drawnItems)
    markers = new L.LayerGroup()
    map.addLayer(markers)
    map.addControl(new L.Control.Draw({
      draw: {
        polygon: { allowIntersection: false, shapeOptions: { color: '#3b82f6', weight: 2 } },
        rectangle: { shapeOptions: { color: '#3b82f6', weight: 2 } },
        circle: false, circlemarker: false, marker: false, polyline: false,
      },
      edit: { featureGroup: drawnItems },
    }))
    map.on(L.Draw.Event.CREATED, function (e) {
      drawnItems.clearLayers()
      markers.clearLayers()
      drawnItems.addLayer(e.layer)
      estimate(e.layer.getLatLngs()[0].map(function (ll) { return [ll.lat, ll.lng] }))
    })
    map.on(L.Draw.Event.DELETED, function () {
      markers.clearLayers()
      drawn++
      tell('clear')
    })
  }

  // shape_drawn. A later shape wins over an earlier one still loading.
  function estimate(polygon) {
    var mine = ++drawn
    var url
    try { url = tell('drawn', literal(JSON.stringify(polygon))) } catch (e) { return }
    Promise.all([tractsReady, fetchText(url)]).then(function (got) {
      if (mine !== drawn) return
      var lots = tell('lots', got[1])
      markers.clearLayers()
      lots.forEach(function (m) {
        L.circleMarker([m[0], m[1]], { radius: m[2], fillColor: m[3], color: '#333', weight: 0.5, fillOpacity: 0.7 })
          .bindPopup(m[4]).addTo(markers)
      })
    }).catch(function (e) {
      if (mine === drawn) tell('failed', literal('Estimation failed: ' + (e.message || e)))
    })
  }

  function buildHeatmap(points) {
    if (!points || !points.length) return
    heatLayer = L.heatLayer(points, {
      radius: 14, blur: 8, maxZoom: 18,
      max: Math.max.apply(null, points.map(function (p) { return p[2] })),
      gradient: {
        0.1: '#312e81', 0.2: '#3b82f6', 0.3: '#06b6d4', 0.4: '#10b981', 0.5: '#22c55e',
        0.6: '#84cc16', 0.7: '#eab308', 0.8: '#f97316', 0.9: '#ef4444', 1.0: '#991b1b',
      },
    })
    var btn = document.getElementById('heatmap-toggle')
    if (!btn) return
    btn.addEventListener('click', function () {
      if (heatVisible) {
        map.removeLayer(heatLayer)
      } else {
        heatLayer.setOptions({ opacity: 0.35 })
        heatLayer.addTo(map)
      }
      heatVisible = !heatVisible
      btn.classList.toggle('active', heatVisible)
      btn.textContent = heatVisible ? 'Hide Density Heatmap' : 'Show Density Heatmap'
    })
  }

  // Onboarding: the first visit is shown what to do, then a demo shape.

  function maybeShowOnboarding() {
    try { if (localStorage.getItem('hmplh_visited')) return } catch (e) { return }
    var overlay = document.createElement('div')
    overlay.className = 'onboarding-overlay'
    overlay.innerHTML =
      '<div class="onboarding-modal">' +
      '<h2>How Many People Live Here?</h2>' +
      '<p>Estimate the population of any area in New York City.</p>' +
      '<ol>' +
      '<li>Use the <strong>draw tools</strong> (top-left of map) to draw a rectangle or polygon</li>' +
      '<li>We\'ll find every tax lot inside your shape and <strong>estimate the population</strong></li>' +
      '<li>Click on any dot to see details about that building</li>' +
      '</ol>' +
      '<p class="modal-note">Data from NYC PLUTO tax lots and the 2020 US Census.</p>' +
      '<button class="onboarding-btn">Got it!</button>' +
      '</div>'
    document.body.appendChild(overlay)
    overlay.querySelector('.onboarding-btn').addEventListener('click', function () {
      try { localStorage.setItem('hmplh_visited', '1') } catch (e) {}
      overlay.classList.add('fade-out')
      setTimeout(function () { overlay.remove(); runDemo() }, 300)
    })
  }

  function runDemo() {
    var bounds = [[40.733, -74.003], [40.737, -73.997]]
    map.flyTo([40.735, -74.000], 16, { duration: 1.2 })
    map.once('moveend', function () {
      drawnItems.addLayer(L.rectangle(bounds, { color: '#3b82f6', weight: 2 }))
      estimate([
        [bounds[0][0], bounds[0][1]],
        [bounds[0][0], bounds[1][1]],
        [bounds[1][0], bounds[1][1]],
        [bounds[1][0], bounds[0][1]],
      ])
      setTimeout(function () {
        drawnItems.clearLayers()
        markers.clearLayers()
        drawn++
        tell('clear')
        map.flyTo([40.7128, -74.006], 12, { duration: 1.2 })
      }, 3500)
    })
  }

  whenMounted(function (a) {
    app = a
    tractsReady = fetchText('/nyc_census_and_pluto/tracts.json').then(function (args) { return tell('tracts', args) })
    loadLeaflet().then(function () {
      initMap()
      maybeShowOnboarding()
      return Promise.all([tractsReady, loadHeat()])
    }).then(function (got) { buildHeatmap(got[0]) })
  })
})()
