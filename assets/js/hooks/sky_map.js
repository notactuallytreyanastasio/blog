import {Deck, OrthographicView} from "@deck.gl/core"
import {ScatterplotLayer, TextLayer} from "@deck.gl/layers"

const SkyMap = {
  mounted() {
    this.points = []
    this.communities = []
    this.selectedCommunity = null
    this.currentViewState = {target: [0, 0, 0], zoom: 3}

    // Tooltip element
    this.tooltipEl = document.createElement("div")
    this.tooltipEl.style.cssText =
      "position:absolute;z-index:10;pointer-events:none;background:#000;" +
      "color:#fff;padding:4px 8px;font-size:11px;font-family:Chicago,Geneva,Helvetica,sans-serif;" +
      "border:1px solid #000;box-shadow:2px 2px 0 #000;display:none;max-width:240px;"
    this.el.appendChild(this.tooltipEl)

    this.deck = new Deck({
      parent: this.el,
      views: new OrthographicView({id: "ortho", flipY: true}),
      initialViewState: {"ortho": this.currentViewState},
      controller: {scrollZoom: true, dragPan: true, doubleClickZoom: true},
      onViewStateChange: ({viewState}) => {
        this.currentViewState = viewState
      },
      getTooltip: () => null,
      layers: [],
    })

    // Load data from static JSON
    this.loadData()

    // Listen for community selection from sidebar
    this.handleEvent("select_community", ({index}) => {
      this.selectedCommunity = index
      this.updateLayers()
      if (index !== null && index !== undefined) {
        this.zoomToCommunity(index)
      }
    })

    // Listen for view mode changes
    this.handleEvent("set_view_mode", ({mode}) => {
      this.viewMode = mode
      this.rebuildVisibleData()
    })

    this.viewMode = "big"
  },

  async loadData() {
    try {
      const [pointsRes, commRes] = await Promise.all([
        fetch("/data/sky_points.json"),
        fetch("/data/sky_communities.json"),
      ])
      const rawPoints = await pointsRes.json()
      const rawCommunities = await commRes.json()

      // Expand compact keys to full names
      this.allCommunities = rawCommunities.map((c) => ({
        community_index: c.i,
        label: c.l,
        member_count: c.m,
        centroid_x: c.cx,
        centroid_y: c.cy,
      }))

      this.allPoints = rawPoints.map((p) => ({
        x: p.x,
        y: p.y,
        community_index: p.c,
        handle: p.h,
        followers_count: p.f,
      }))

      this.rebuildVisibleData()
      this.pushEvent("map_loaded", {})
    } catch (e) {
      console.error("[SkyMap] Failed to load data:", e)
    }
  },

  rebuildVisibleData() {
    const mode = this.viewMode || "big"
    const BIG = 500

    // Filter communities by view mode
    let communities = this.allCommunities
    if (mode === "big") {
      communities = communities.filter((c) => (c.member_count || 0) >= BIG)
    } else if (mode === "niche") {
      communities = communities.filter((c) => (c.member_count || 0) < BIG)
    }

    // Recompute centroids from points
    this.communities = this.recomputeCentroids(communities, this.allPoints)

    // Cluster layout
    const visibleIndices = new Set(this.communities.map((c) => c.community_index))
    const filteredPoints = this.allPoints.filter((p) => visibleIndices.has(p.community_index))

    const {points: clusteredPoints, placed} = this.clusterByCommunity(filteredPoints, this.communities)

    // Recompute centroids after clustering
    this.communities = this.recomputeCentroids(this.communities, clusteredPoints)

    // Merge disc radius
    const discLookup = {}
    for (const p of placed) {
      discLookup[p.community_index] = p.r
    }
    this.communities = this.communities.map((c) => ({
      ...c,
      disc_r: discLookup[c.community_index] || 0,
    }))

    // Generate colors
    this.colorMap = generateCommunityColors(this.communities)
    this.communities = this.communities.map((c) => {
      const rgb = this.colorMap[c.community_index] || [100, 100, 255]
      return {...c, color: `rgb(${rgb[0]},${rgb[1]},${rgb[2]})`}
    })

    this.points = clusteredPoints.map((p) => ({
      ...p,
      _color: this.colorMap[p.community_index] || [100, 100, 255],
    }))

    this.updateLayers()
    this.fitBounds()
  },

  updateLayers() {
    const selected = this.selectedCommunity
    const hasSelection = selected !== null && selected !== undefined

    // Community hover layer
    const communityHoverLayer = new ScatterplotLayer({
      id: "community-hover",
      data: this.communities,
      getPosition: (d) => [d.centroid_x, d.centroid_y],
      getRadius: (d) => d.disc_r || 0.1,
      getFillColor: [0, 0, 0, 0],
      pickable: true,
      onHover: ({object, x, y}) => {
        if (object) {
          const rgb = this.colorMap[object.community_index] || [100, 100, 255]
          this.tooltipEl.style.display = "block"
          this.tooltipEl.style.left = x + 12 + "px"
          this.tooltipEl.style.top = y + 12 + "px"
          this.tooltipEl.innerHTML =
            `<b>${object.label || "Community " + object.community_index}</b>` +
            `<br/>${(object.member_count || 0).toLocaleString()} members`
        } else {
          this.tooltipEl.style.display = "none"
        }
      },
      onClick: ({object}) => {
        if (object) {
          this.pushEvent("select_community", {index: object.community_index})
        }
      },
    })

    // User scatter points
    const scatterLayer = new ScatterplotLayer({
      id: "users",
      data: this.points,
      getPosition: (d) => [d.x, d.y],
      getRadius: (d) => {
        const base = Math.sqrt(Math.min(d.followers_count || 10, 5000)) / 25
        if (hasSelection) {
          return d.community_index === selected ? base * 1.2 : base * 0.5
        }
        return base
      },
      getFillColor: (d) => {
        const c = d._color || [100, 100, 255]
        if (hasSelection && d.community_index !== selected) {
          return [c[0], c[1], c[2], 30]
        }
        return [c[0], c[1], c[2], 200]
      },
      radiusMinPixels: 0.5,
      radiusMaxPixels: 5,
      pickable: true,
      onHover: ({object, x, y}) => {
        if (object) {
          this.tooltipEl.style.display = "block"
          this.tooltipEl.style.left = x + 12 + "px"
          this.tooltipEl.style.top = y + 12 + "px"
          const tc = object._color || [100, 100, 255]
          this.tooltipEl.innerHTML =
            `<b>${object.handle || "unknown"}</b>` +
            `<br/><span style="color:rgb(${tc[0]},${tc[1]},${tc[2]})">${object.community_label || ""}</span>`
        } else {
          this.tooltipEl.style.display = "none"
        }
      },
      onClick: ({object}) => {
        if (object) {
          this.pushEvent("point_clicked", {handle: object.handle, community_index: object.community_index})
        }
      },
      updateTriggers: {
        getFillColor: [selected],
        getRadius: [selected],
      },
    })

    // Selection ring
    const selectionRing = new ScatterplotLayer({
      id: "selection-ring",
      data: hasSelection ? this.getSelectionRingData(selected) : [],
      getPosition: (d) => [d.x, d.y],
      getRadius: (d) => d.radius,
      getFillColor: [0, 0, 0, 0],
      getLineColor: [0, 0, 0, 200],
      stroked: true,
      filled: false,
      lineWidthMinPixels: 2,
      lineWidthMaxPixels: 3,
      updateTriggers: {data: [selected]},
    })

    // World-space labels inside community circles (sized to fit disc)
    const labelCommunities = this.communities.filter((c) => c.disc_r > 0)

    const labelLayer = new TextLayer({
      id: "community-labels",
      data: labelCommunities,
      getPosition: (d) => [d.centroid_x, d.centroid_y],
      getText: (d) => d.label || `Community ${d.community_index}`,
      getSize: (d) => Math.max(d.disc_r * 0.28, 0.15),
      sizeUnits: "common",
      sizeMinPixels: 10,
      sizeMaxPixels: 50,
      getColor: (d) => {
        if (hasSelection && d.community_index !== selected) return [0, 0, 0, 30]
        if (hasSelection && d.community_index === selected) return [0, 0, 0, 255]
        return [0, 0, 0, 200]
      },
      fontFamily: "Chicago, Geneva, Helvetica, sans-serif",
      fontWeight: "bold",
      getTextAnchor: "middle",
      getAlignmentBaseline: "center",
      background: true,
      getBackgroundColor: (d) => {
        if (hasSelection && d.community_index === selected) return [255, 255, 255, 220]
        return [255, 255, 255, 160]
      },
      backgroundPadding: [4, 2],
      maxWidth: 180,
      wordBreak: "break-word",
      pickable: true,
      onClick: ({object}) => {
        if (object) {
          this.pushEvent("select_community", {index: object.community_index})
        }
      },
      updateTriggers: {
        getColor: [selected],
        getBackgroundColor: [selected],
      },
    })

    this.deck.setProps({
      layers: [communityHoverLayer, scatterLayer, selectionRing, labelLayer],
    })
  },

  zoomToCommunity(communityIndex) {
    const community = this.communities.find(
      (c) => c.community_index === communityIndex
    )
    if (!community) return
    this.animateView([community.centroid_x, community.centroid_y, 0], 7)
  },

  fitBounds() {
    const bounds = this.computeBounds(this.points)
    if (!bounds) return
    const width = this.el.clientWidth
    const height = this.el.clientHeight
    const dataWidth = bounds.maxX - bounds.minX || 1
    const dataHeight = bounds.maxY - bounds.minY || 1
    const zoom = Math.log2(Math.min(width / dataWidth, height / dataHeight)) - 1
    this.animateView([bounds.cx, bounds.cy, 0], Math.max(zoom, -2))
  },

  animateView(endTarget, endZoom) {
    const newState = {target: endTarget, zoom: endZoom, transitionDuration: 600}
    this.currentViewState = newState
    this.deck.setProps({initialViewState: {"ortho": newState}})
  },

  computeBounds(points) {
    if (!points || points.length === 0) return null
    let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity
    for (const p of points) {
      if (p.x < minX) minX = p.x
      if (p.x > maxX) maxX = p.x
      if (p.y < minY) minY = p.y
      if (p.y > maxY) maxY = p.y
    }
    return {minX, maxX, minY, maxY, cx: (minX + maxX) / 2, cy: (minY + maxY) / 2}
  },

  getSelectionRingData(communityIndex) {
    const community = this.communities.find(
      (c) => c.community_index === communityIndex
    )
    if (!community) return []
    const cx = community.centroid_x
    const cy = community.centroid_y
    const dists = this.points
      .filter((p) => p.community_index === communityIndex)
      .map((p) => Math.sqrt((p.x - cx) ** 2 + (p.y - cy) ** 2))
      .sort((a, b) => a - b)
    if (dists.length === 0) return []
    const r90 = dists[Math.floor(dists.length * 0.92)] || dists[dists.length - 1]
    return [{x: cx, y: cy, radius: r90 * 1.15}]
  },

  clusterByCommunity(points, communities) {
    const grouped = {}
    for (const p of points) {
      if (!grouped[p.community_index]) grouped[p.community_index] = []
      grouped[p.community_index].push(p)
    }

    const sorted = [...communities]
      .filter((c) => grouped[c.community_index]?.length > 0)
      .sort((a, b) => (b.member_count || 0) - (a.member_count || 0))

    const radii = {}
    for (const c of sorted) {
      radii[c.community_index] = Math.sqrt(c.member_count || 1) * 0.08
    }

    const placed = []
    const GOLDEN_ANGLE = 2.399963

    for (const c of sorted) {
      const r = radii[c.community_index]
      let cx, cy

      if (placed.length === 0) {
        cx = 0
        cy = 0
      } else {
        let angle = placed.length * GOLDEN_ANGLE
        let dist = r + placed[0].r
        let attempts = 0

        while (attempts < 500) {
          cx = Math.cos(angle) * dist
          cy = Math.sin(angle) * dist
          const overlaps = placed.some((p) => {
            const d = Math.sqrt((cx - p.x) ** 2 + (cy - p.y) ** 2)
            return d < (r + p.r) * 1.15
          })
          if (!overlaps) break
          dist += r * 0.3
          angle += 0.2
          attempts++
        }
      }

      placed.push({x: cx, y: cy, r, community_index: c.community_index})
    }

    const positions = {}
    for (const p of placed) {
      positions[p.community_index] = {x: p.x, y: p.y, r: p.r}
    }

    const result = []
    for (const c of sorted) {
      const members = grouped[c.community_index] || []
      const pos = positions[c.community_index]
      if (!pos) continue

      const n = members.length
      for (let i = 0; i < n; i++) {
        const frac = i / n
        const angle = i * GOLDEN_ANGLE
        const dist = pos.r * Math.sqrt(frac) * 0.9

        result.push({
          ...members[i],
          x: pos.x + Math.cos(angle) * dist,
          y: pos.y + Math.sin(angle) * dist,
          community_label: communities.find((cm) => cm.community_index === members[i].community_index)?.label || "",
        })
      }
    }

    return {points: result, placed}
  },

  recomputeCentroids(communities, points) {
    const grouped = {}
    for (const p of points) {
      const idx = p.community_index
      if (!grouped[idx]) grouped[idx] = {xs: [], ys: []}
      grouped[idx].xs.push(p.x)
      grouped[idx].ys.push(p.y)
    }

    return communities.map((c) => {
      const g = grouped[c.community_index]
      if (!g || g.xs.length === 0) return c
      g.xs.sort((a, b) => a - b)
      g.ys.sort((a, b) => a - b)
      const mid = Math.floor(g.xs.length / 2)
      return {...c, centroid_x: g.xs[mid], centroid_y: g.ys[mid]}
    })
  },

  destroyed() {
    if (this.deck) {
      this.deck.finalize()
    }
  },
}

// Generate maximally distinct colors using golden angle
function generateCommunityColors(communities) {
  const GOLDEN_ANGLE = 137.508
  const sorted = [...communities].sort(
    (a, b) => (b.member_count || 0) - (a.member_count || 0)
  )
  const colorMap = {}
  sorted.forEach((c, i) => {
    const hue = (i * GOLDEN_ANGLE) % 360
    const lightness = 0.45 + (i % 3) * 0.1
    const saturation = 0.7 + (i % 2) * 0.15
    const [r, g, b] = hslToRgb(hue / 360, saturation, lightness)
    colorMap[c.community_index] = [r, g, b]
  })
  return colorMap
}

function hslToRgb(h, s, l) {
  let r, g, b
  if (s === 0) {
    r = g = b = l
  } else {
    const hue2rgb = (p, q, t) => {
      if (t < 0) t += 1
      if (t > 1) t -= 1
      if (t < 1 / 6) return p + (q - p) * 6 * t
      if (t < 1 / 2) return q
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
      return p
    }
    const q = l < 0.5 ? l * (1 + s) : l + s - l * s
    const p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  }
  return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)]
}

export default SkyMap
