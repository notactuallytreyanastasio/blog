// /map's hook, after app.js has mounted map.blimp (window.BlimpApp, actor
// `wook`). Leaflet is a JavaScript library and Blimp's view has no pointer
// events, so this is the part of MapLive's MapHook a program cannot be:
//
//  - the map: Leaflet in #mapid, centred on the US at zoom 4, pins in a
//    marker cluster group. A tap on the map is `wook <- :clicked(json)`;
//    the browser's location, once Leaflet finds it, `wook <- :located(json)`.
//  - the pins: every 100ms, `wook <- :pins(epoch, n)` answers the pins not
//    drawn yet, each with its popup made by the program (Temper's
//    map_popup_html). A new epoch means a new socket sent every tag again,
//    and they are all drawn again.
//  - the socket: every frame from /live/map goes to `wook <- :frame(json)`;
//    every 100ms `wook <- :outbox` says what to send up, or that the
//    Locate Me button was pressed, which only Leaflet can act on.
//
// The tiles are OpenStreetMap's. MapHook asked CARTO's basemaps
// (light_all), which now answer every request, whatever its Referer, with
// a tile saying "API KEY REQUIRED".
(function () {
  var POLL_MS = 100
  var TILES = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
  var ATTRIBUTION = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'

  function literal(s) {
    return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/#\{/g, '\\#{') + '"'
  }

  function start() {
    var app = window.BlimpApp
    if (!app) return false
    var view = app.view
    var blimp = app.blimp

    var map = L.map('mapid').setView([39.8283, -98.5795], 4)
    L.tileLayer(TILES, { attribution: ATTRIBUTION, maxZoom: 19 }).addTo(map)
    var cluster = L.markerClusterGroup()
    map.addLayer(cluster)

    // A send made while the view is rendering is dropped, so an event
    // waits for the stack to unwind.
    function tell(msg, args) { setTimeout(function () { view.send(msg, args) }, 0) }
    function at(latlng) { return literal(JSON.stringify({ lat: latlng.lat, lng: latlng.lng })) }

    map.on('click', function (e) { tell('clicked', at(e.latlng)) })
    map.on('locationfound', function (e) {
      map.setView(e.latlng, 16)
      setTimeout(function () { tell('located', at(e.latlng)) }, 100)
    })
    map.on('locationerror', function (e) { console.error("Leaflet 'locationerror' event: ", e.message) })

    // what the page wrote while the socket was down, sent when it is up
    var queued = []
    function up(frame) {
      if (ws && ws.readyState === 1) ws.send(frame)
      else queued.push(frame)
    }

    var ws = null
    var wait = 500
    function connect() {
      var scheme = location.protocol === 'https:' ? 'wss://' : 'ws://'
      ws = new WebSocket(scheme + location.host + '/live/map')
      ws.onopen = function () { wait = 500; queued.splice(0).forEach(up) }
      ws.onmessage = function (ev) { tell('frame', literal(ev.data)) }
      ws.onclose = function () {
        ws = null
        setTimeout(connect, wait)
        wait = Math.min(wait * 2, 10000)
      }
    }

    var epoch = -1
    var drawn = 0
    function poll() {
      var out = blimp.send('wook', 'outbox')
      if (out.ok && Array.isArray(out.value)) out.value.forEach(function (o) {
        if (o.to === 'map' && o.what === 'locate') map.locate({ setView: true, maxZoom: 16 })
        else if (o.to === 'server') up(o.frame)
      })
      var got = blimp.send('wook', 'pins', epoch + ', ' + drawn)
      if (!got.ok || !got.value) return
      var p = got.value
      if (p.epoch !== epoch) { cluster.clearLayers(); epoch = p.epoch; drawn = 0 }
      if (p.from !== drawn) return
      p.pins.forEach(function (pin) {
        cluster.addLayer(L.marker([pin.lat, pin.lng]).bindPopup(pin.popup, { minWidth: 300 }))
        drawn++
      })
    }

    setInterval(poll, POLL_MS)
    connect()
    setTimeout(function () { map.invalidateSize() }, 150)
    return true
  }
  if (!start()) document.addEventListener('blimp-app-mounted', start, { once: true })
})()
