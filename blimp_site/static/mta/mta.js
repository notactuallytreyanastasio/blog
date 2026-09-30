// /mta-bus-map's hook, after app.js has mounted mta.blimp (window.BlimpApp,
// actor `mta`). What is left of the MtaBusMap hook is what only JavaScript
// can do:
//
//  - the map: Leaflet in #mta-bus-map, on the Lower East Side at zoom 14,
//    the "show my location" button, and the "You" marker when the browser
//    says where it is.
//  - the markers: every 100ms, `mta <- :markers(epoch)` answers every bus
//    when they have changed, each with its key (route and vehicle), place,
//    icon HTML and popup HTML, all made by the program (Temper's
//    mta_icon_html and mta_popup_html). A marker is moved, not remade,
//    when its bus comes back, as the hook's markersByBusId did.
//  - the socket: /live/mta. Every frame goes to `mta <- :frame(json)`; each
//    (re)connection is `mta <- :connected`, so the server hears again what
//    this page watches; `mta <- :outbox` says what to send up.
//  - the status bar and the tab's title, from `mta <- :status`.
//
// The tiles are OpenStreetMap's. The hook asked CARTO's basemaps
// (light_all), which now answer every request with a tile saying
// "API KEY REQUIRED".
(function () {
  var POLL_MS = 100
  var TILES = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
  var ATTRIBUTION = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  var YOU = '<div style="display: flex; align-items: center; gap: 4px; pointer-events: none;">' +
    '<div style="background-color: #FF4081; width: 16px; height: 16px; border-radius: 50%; border: 3px solid white; box-shadow: 0 0 4px rgba(0,0,0,0.5);"></div>' +
    '<div style="background-color: white; padding: 2px 6px; border-radius: 4px; font-size: 12px; font-weight: bold; box-shadow: 0 0 4px rgba(0,0,0,0.2); color: #FF4081;">You</div></div>'

  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var blimp = app.blimp

    var map = L.map('mta-bus-map', { center: [40.7185, -73.9835], zoom: 14, zoomControl: true, scrollWheelZoom: true })
    L.tileLayer(TILES, { attribution: ATTRIBUTION, maxZoom: 19 }).addTo(map)

    var Locate = L.Control.extend({
      options: { position: 'topleft' },
      onAdd: function (m) {
        var box = L.DomUtil.create('div', 'leaflet-bar leaflet-control')
        var button = L.DomUtil.create('a', 'leaflet-control-zoom-in', box)
        button.innerHTML = '📍'
        button.title = 'Show my location'
        button.style.fontSize = '18px'
        L.DomEvent.on(button, 'click', function (e) {
          L.DomEvent.stopPropagation(e)
          L.DomEvent.preventDefault(e)
          m.locate({ setView: true, maxZoom: 16 })
        })
        return box
      }
    })
    map.addControl(new Locate())
    map.locate({ setView: true, maxZoom: 16 })

    var you = null
    map.on('locationfound', function (e) {
      if (you) you.setLatLng(e.latlng)
      else you = L.marker(e.latlng, { icon: L.divIcon({ className: 'custom-div-icon', html: YOU, iconSize: [80, 20], iconAnchor: [8, 10] }) }).addTo(map)
    })
    map.on('locationerror', function (e) {
      console.warn('Error getting location:', e.message)
      var el = document.getElementById('mta-bus-map')
      if (!el || el.querySelector('.mta-location-hint')) return
      var hint = document.createElement('div')
      hint.className = 'mta-location-hint'
      hint.textContent = 'Location unavailable — showing default view'
      hint.style.cssText = 'position:absolute;top:10px;left:50%;transform:translateX(-50%);z-index:1000;background:rgba(0,0,0,0.7);color:#fff;padding:6px 12px;border-radius:6px;font-size:12px;pointer-events:none;'
      el.appendChild(hint)
      setTimeout(function () { hint.remove() }, 4000)
    })

    // A send made while the view is rendering is dropped, so an event
    // waits for the stack to unwind.
    function tell(msg, args) { setTimeout(function () { view.send(msg, args) }, 0) }

    var ws = null
    var wait = 500
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/mta')
      ws.onopen = function () { wait = 500; tell('connected') }
      ws.onmessage = function (ev) { tell('frame', literal(ev.data)) }
      ws.onclose = function () {
        ws = null
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }

    // key -> {marker, icon, popup}
    var markers = new Map()
    var epoch = -1
    var statusRoutes = document.getElementById('mta-status-routes')
    var statusBorough = document.getElementById('mta-status-borough')

    function draw(list) {
      var live = new Set()
      list.forEach(function (b) {
        live.add(b.key)
        var m = markers.get(b.key)
        if (m) {
          m.marker.setLatLng([b.lat, b.lng])
          if (m.icon !== b.icon) { m.marker.setIcon(L.divIcon({ className: 'custom-div-icon', html: b.icon, iconSize: [120, 50], iconAnchor: [6, 25] })); m.icon = b.icon }
          if (m.popup !== b.popup) { m.marker.setPopupContent(b.popup); m.popup = b.popup }
          if (!m.marker._map) m.marker.addTo(map)
        } else {
          var marker = L.marker([b.lat, b.lng], { icon: L.divIcon({ className: 'custom-div-icon', html: b.icon, iconSize: [120, 50], iconAnchor: [6, 25] }) })
            .bindPopup(b.popup)
            .addTo(map)
          markers.set(b.key, { marker: marker, icon: b.icon, popup: b.popup })
        }
      })
      markers.forEach(function (m, key) { if (!live.has(key)) m.marker.remove() })
    }

    function poll() {
      var out = blimp.send('mta', 'outbox')
      if (out.ok && Array.isArray(out.value) && ws && ws.readyState === 1) out.value.forEach(function (f) { ws.send(f) })
      var got = blimp.send('mta', 'markers', String(epoch))
      if (got.ok && got.value) { epoch = got.value.epoch; draw(got.value.markers) }
      var st = blimp.send('mta', 'status')
      if (st.ok && st.value) {
        statusRoutes.textContent = st.value.routes
        statusBorough.textContent = st.value.borough
        if (document.title !== st.value.title) document.title = st.value.title
      }
    }

    setInterval(poll, POLL_MS)
    connect()
    setTimeout(function () { map.invalidateSize() }, 100)
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
