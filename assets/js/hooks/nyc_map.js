const NycMap = {
  mounted() {
    this.loadLeaflet().then(() => {
      this.initMap()
      this.maybeShowOnboarding()
    })

    this.handleEvent("estimation_results", (data) => {
      this.clearMarkers()
      this.renderMarkers(data.lots)
    })

    this.handleEvent("heatmap_data", (data) => {
      this.loadHeatPlugin().then(() => {
        this.buildHeatmap(data.points)
      })
    })
  },

  loadLeaflet() {
    return new Promise((resolve) => {
      const loadDraw = () => {
        if (window.L && window.L.Draw) { resolve(); return }

        const drawCss = document.createElement("link")
        drawCss.rel = "stylesheet"
        drawCss.href = "https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.css"
        document.head.appendChild(drawCss)

        const drawScript = document.createElement("script")
        drawScript.src = "https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js"
        drawScript.onload = () => resolve()
        document.head.appendChild(drawScript)
      }

      if (window.L) { loadDraw(); return }

      const css = document.createElement("link")
      css.rel = "stylesheet"
      css.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      document.head.appendChild(css)

      const script = document.createElement("script")
      script.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
      script.onload = () => loadDraw()
      document.head.appendChild(script)
    })
  },

  initMap() {
    this.map = L.map("nyc-map", {
      center: [40.7128, -74.006],
      zoom: 12,
      zoomControl: true,
    })

    L.tileLayer(
      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
      {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> &copy; <a href="https://carto.com/">CARTO</a>',
        maxZoom: 19,
      }
    ).addTo(this.map)

    this.drawnItems = new L.FeatureGroup()
    this.map.addLayer(this.drawnItems)

    this.markers = new L.LayerGroup()
    this.map.addLayer(this.markers)

    const drawControl = new L.Control.Draw({
      draw: {
        polygon: { allowIntersection: false, shapeOptions: { color: "#3b82f6", weight: 2 } },
        rectangle: { shapeOptions: { color: "#3b82f6", weight: 2 } },
        circle: false,
        circlemarker: false,
        marker: false,
        polyline: false,
      },
      edit: { featureGroup: this.drawnItems },
    })
    this.map.addControl(drawControl)

    this.map.on(L.Draw.Event.CREATED, (e) => {
      this.drawnItems.clearLayers()
      this.clearMarkers()
      this.drawnItems.addLayer(e.layer)

      const latlngs = e.layer.getLatLngs()[0]
      const polygon = latlngs.map((ll) => [ll.lat, ll.lng])
      this.pushEvent("shape_drawn", { polygon })
    })

    this.map.on(L.Draw.Event.DELETED, () => {
      this.clearMarkers()
      this.pushEvent("clear_shape", {})
    })
  },

  // Onboarding

  maybeShowOnboarding() {
    if (localStorage.getItem("hmplh_visited")) return
    this.showModal()
  },

  showModal() {
    const overlay = document.createElement("div")
    overlay.className = "onboarding-overlay"
    overlay.innerHTML = `
      <div class="onboarding-modal">
        <h2>How Many People Live Here?</h2>
        <p>Estimate the population of any area in New York City.</p>
        <ol>
          <li>Use the <strong>draw tools</strong> (top-left of map) to draw a rectangle or polygon</li>
          <li>We'll find every tax lot inside your shape and <strong>estimate the population</strong></li>
          <li>Click on any dot to see details about that building</li>
        </ol>
        <p class="modal-note">Data from NYC PLUTO tax lots and the 2020 US Census.</p>
        <button class="onboarding-btn">Got it!</button>
      </div>
    `
    document.body.appendChild(overlay)

    overlay.querySelector(".onboarding-btn").addEventListener("click", () => {
      localStorage.setItem("hmplh_visited", "1")
      overlay.classList.add("fade-out")
      setTimeout(() => {
        overlay.remove()
        this.runDemo()
      }, 300)
    })
  },

  runDemo() {
    const bounds = [[40.733, -74.003], [40.737, -73.997]]

    this.map.flyTo([40.735, -74.000], 16, { duration: 1.2 })

    this.map.once("moveend", () => {
      const rect = L.rectangle(bounds, { color: "#3b82f6", weight: 2 })
      this.drawnItems.addLayer(rect)

      const polygon = [
        [bounds[0][0], bounds[0][1]],
        [bounds[0][0], bounds[1][1]],
        [bounds[1][0], bounds[1][1]],
        [bounds[1][0], bounds[0][1]],
      ]
      this.pushEvent("shape_drawn", { polygon })

      setTimeout(() => {
        this.drawnItems.clearLayers()
        this.clearMarkers()
        this.pushEvent("clear_shape", {})
        this.map.flyTo([40.7128, -74.006], 12, { duration: 1.2 })
      }, 3500)
    })
  },

  // Markers

  clearMarkers() {
    if (this.markers) this.markers.clearLayers()
  },

  renderMarkers(lots) {
    if (!lots || !lots.length) return

    const maxPop = Math.max(...lots.map((l) => l.estimated_pop || 0), 1)

    lots.forEach((lot) => {
      if (!lot.lat || !lot.lng) return

      const pop = lot.estimated_pop || 0
      const intensity = Math.min(pop / maxPop, 1)
      const radius = 3 + intensity * 12
      const color = this.popColor(intensity)

      const marker = L.circleMarker([lot.lat, lot.lng], {
        radius,
        fillColor: color,
        color: "#333",
        weight: 0.5,
        fillOpacity: 0.7,
      })

      const address = lot.address || "Unknown"
      const units = lot.units || 0
      marker.bindPopup(
        `<strong>${address}</strong><br/>` +
        `Est. population: <strong>${Math.round(pop)}</strong><br/>` +
        `Residential units: ${units}<br/>` +
        `BBL: ${lot.bbl || "N/A"}`
      )

      this.markers.addLayer(marker)
    })
  },

  // Heatmap

  loadHeatPlugin() {
    return new Promise((resolve) => {
      if (window.L && window.L.heatLayer) { resolve(); return }

      const script = document.createElement("script")
      script.src = "https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js"
      script.onload = () => resolve()
      document.head.appendChild(script)
    })
  },

  buildHeatmap(points) {
    if (!points || !points.length) return

    this.heatLayer = L.heatLayer(points, {
      radius: 25,
      blur: 20,
      maxZoom: 15,
      max: Math.max(...points.map((p) => p[2])),
      gradient: { 0.2: "#3b82f6", 0.4: "#06b6d4", 0.6: "#22c55e", 0.8: "#eab308", 1.0: "#ef4444" },
    })
    this.heatmapVisible = false

    this.addHeatmapControl()
  },

  addHeatmapControl() {
    const HeatmapToggle = L.Control.extend({
      options: { position: "bottomright" },
      onAdd: () => {
        const container = L.DomUtil.create("div", "leaflet-bar nyc-heatmap-toggle")
        container.innerHTML = '<a href="#" title="Toggle population heatmap">&#x1f525;</a>'
        container.querySelector("a").addEventListener("click", (e) => {
          e.preventDefault()
          e.stopPropagation()
          this.toggleHeatmap()
          container.classList.toggle("active", this.heatmapVisible)
        })
        L.DomEvent.disableClickPropagation(container)
        return container
      },
    })
    this.map.addControl(new HeatmapToggle())
  },

  toggleHeatmap() {
    if (!this.heatLayer) return
    if (this.heatmapVisible) {
      this.map.removeLayer(this.heatLayer)
    } else {
      this.heatLayer.setOptions({ opacity: 0.3 })
      this.heatLayer.addTo(this.map)
    }
    this.heatmapVisible = !this.heatmapVisible
  },

  popColor(intensity) {
    if (intensity < 0.5) {
      const t = intensity * 2
      const r = Math.round(65 + t * 190)
      const g = Math.round(105 + t * 150)
      const b = Math.round(225 - t * 200)
      return `rgb(${r},${g},${b})`
    } else {
      const t = (intensity - 0.5) * 2
      const r = Math.round(255)
      const g = Math.round(255 - t * 200)
      const b = Math.round(25 - t * 25)
      return `rgb(${r},${g},${b})`
    }
  },
}

export default NycMap
