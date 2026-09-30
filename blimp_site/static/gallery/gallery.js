// /gallery's viewer: assets/js/hooks/gallery_ambient.js (the GalleryAmbient
// LiveView hook), run as a page script. The server renders the grid
// (src/99_gallery.blimp); this owns the viewer window, the deck, the fades
// and the mosaic, as the hook did. What LiveView carried is now the page's:
//
//   phx-click="open" on a cell     -> a click on [data-guid]
//   phx-click="slideshow"          -> a click on [data-gal="slideshow"]
//   PubSub {:gallery, :updated}    -> every REFRESH_MS, /gallery is read
//                                     again; a changed album replaces the
//                                     grid and is merged into the deck
//
// The hook's embedded mode (data-embedded, for the homepage's photo window)
// is left in; nothing sets it, since the Blimp desktop has no photo window.

const REFRESH_MS = 5 * 60 * 1000

const SLIDE_MS = 9000
// Fading through black rather than dissolving directly. A straight crossfade
// blends two unrelated photos into mud for a full second; going out to black
// first costs half a beat and keeps every frame legible.
const FADE_OUT_MS = 550
const FADE_IN_MS = 850
const PRELOAD_AHEAD = 2

// Full-screen mosaic. Several photos at once in unequal cells, each tile
// swapping on its own stagger, and the whole layout rotating every so often so
// a photo that was a thumbnail last round comes back as the big one.
//
// Each entry is [column, row, columnSpan, rowSpan]; every layout tiles its
// grid exactly, so there are never gaps.
const MOSAIC_LANDSCAPE = [
  [[1,1,2,2],[3,1,1,1],[4,1,1,2],[3,2,1,1],[1,3,1,1],[2,3,2,1],[4,3,1,1]],
  [[1,1,1,2],[2,1,2,1],[4,1,1,1],[2,2,1,1],[3,2,2,2],[1,3,1,1],[2,3,1,1]],
  [[1,1,2,1],[3,1,1,2],[4,1,1,1],[1,2,1,2],[2,2,1,1],[4,2,1,2],[2,3,2,1]],
]
const MOSAIC_PORTRAIT = [
  [[1,1,2,1],[1,2,1,2],[2,2,1,1],[2,3,1,1]],
  [[1,1,1,2],[2,1,1,1],[2,2,1,1],[1,3,2,1]],
  [[1,1,1,1],[2,1,1,2],[1,2,1,2],[2,3,1,1]],
]
const MOSAIC_COLS = { landscape: 4, portrait: 2 }
const TILE_SWAP_MS = 7000      // how often one tile changes
const TILE_STAGGER_MS = 1100   // offset between neighbouring tiles
const LAYOUT_ROTATE_MS = 48000 // how often everyone changes size

const shuffle = (arr) => {
  const a = arr.slice()
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

const GalleryAmbient = {
  mounted() {
    this.photos = this.readPhotos()
    this.deck = []
    this.deckPos = 0
    this.current = null
    this.front = "a"
    this.playing = false
    this.timer = null
    this.wakeLock = null
    this.reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    // Embedded: the viewer sits inside a window the server owns (the homepage
    // desktop), so this hook must not show/hide it, and must not grab keys on
    // a page that already has a terminal and a chat input.
    this.embedded = this.el.dataset.embedded === "true"

    const q = (sel) => this.el.querySelector(`[data-gal="${sel}"]`)
    const qa = (sel) => Array.from(this.el.querySelectorAll(`[data-gal="${sel}"]`))

    this.viewer = this.el.querySelector("#gal-viewer")
    this.ui = {
      title: q("title"),
      counter: q("counter"),
      caption: q("caption"),
      backdrop: q("backdrop"),
      stage: q("stage"),
      toggle: q("toggle"),
      layers: { a: q("layer-a"), b: q("layer-b") }
    }

    qa("prev").forEach((b) => b.addEventListener("click", () => this.step(-1)))
    qa("next").forEach((b) => b.addEventListener("click", () => this.step(1)))
    qa("close").forEach((b) => b.addEventListener("click", (e) => { e.preventDefault(); this.close() }))
    if (this.ui.toggle) this.ui.toggle.addEventListener("click", () => this.toggle())
    qa("fullscreen").forEach((b) => b.addEventListener("click", () => this.enterMosaic()))
    const sh = q("shuffle")
    if (sh) sh.addEventListener("click", () => { this.reshuffle(); this.step(1) })

    if (!this.embedded) {
      this.onKey = (e) => this.handleKey(e)
      window.addEventListener("keydown", this.onKey)
    }

    // What the LiveView's events were: a cell opens its photo, the
    // Slideshow button opens the viewer playing.
    this.el.addEventListener("click", (e) => {
      const cell = e.target.closest("[data-guid]")
      if (cell && this.el.contains(cell)) { this.showGuid(cell.dataset.guid); return }
      if (e.target.closest('[data-gal="slideshow"]')) { this.open(); this.play() }
    })
    this.refresher = setInterval(() => this.refresh(), REFRESH_MS)

    this.initScrollbar()

    // Land with a window already open on a random photo, drifting.
    if (this.photos.length) {
      this.reshuffle()
      this.open()
      this.show(this.deck[0])
      this.play()
    }
  },

  // The album as the server has it now. The grid, the count and the
  // buttons are swapped for the server's; the deck folds new photos in
  // without disturbing the slide on screen, as updated() did.
  async refresh() {
    let html
    try {
      const res = await fetch("/gallery", { cache: "no-store" })
      if (!res.ok) return
      html = await res.text()
    } catch (_e) {
      return
    }
    const doc = new DOMParser().parseFromString(html, "text/html")
    const fresh = doc.getElementById("gal-desktop")
    if (!fresh || fresh.dataset.photos === this.el.dataset.photos) return
    this.el.dataset.photos = fresh.dataset.photos
    const swap = (sel) => {
      const mine = this.el.querySelector(sel)
      const theirs = fresh.querySelector(sel)
      if (mine && theirs) mine.innerHTML = theirs.innerHTML
    }
    swap('[data-gal="scroll"]')
    swap('[data-gal="count"]')
    this.el.querySelectorAll(".gal-infobar .gal-btn").forEach((b) => { b.disabled = fresh.querySelector(".gal-infobar .gal-btn").disabled })
    this.merge(this.readPhotos())
    this.syncScrollbar()
  },

  // ----------------------------------------------------------- scroll bar

  // A working System 7 elevator. The native bar is hidden in CSS because
  // overlay scrollbars ignore ::-webkit rules, so the window would otherwise
  // have no visible scroll bar at all — the one piece of chrome the era is
  // most recognisable by.
  initScrollbar() {
    const q = (sel) => this.el.querySelector(`[data-gal="${sel}"]`)
    this.sb = {
      bar: q("sbar"),
      scroll: q("scroll"),
      track: q("sb-track"),
      thumb: q("sb-thumb"),
      up: q("sb-up"),
      down: q("sb-down")
    }
    if (!this.sb.bar || !this.sb.scroll) return

    const { scroll, track, thumb, up, down } = this.sb

    scroll.addEventListener("scroll", () => this.syncScrollbar(), { passive: true })
    this.ro = new ResizeObserver(() => this.syncScrollbar())
    this.ro.observe(scroll)

    // Arrows scroll a line at a time, and repeat while held.
    const nudge = (dir) => {
      let timer = null
      const tick = () => { scroll.scrollTop += dir * 48 }
      const start = (e) => {
        e.preventDefault()
        tick()
        timer = setInterval(tick, 90)
        const stop = () => { clearInterval(timer); window.removeEventListener("mouseup", stop) }
        window.addEventListener("mouseup", stop)
      }
      return start
    }
    if (up) up.addEventListener("mousedown", nudge(-1))
    if (down) down.addEventListener("mousedown", nudge(1))

    // Clicking the track pages toward the click, as the original did.
    if (track) {
      track.addEventListener("mousedown", (e) => {
        if (e.target === thumb) return
        const r = thumb.getBoundingClientRect()
        scroll.scrollTop += (e.clientY < r.top ? -1 : 1) * scroll.clientHeight * 0.9
      })
    }

    if (thumb) {
      thumb.addEventListener("mousedown", (e) => {
        e.preventDefault()
        const startY = e.clientY
        const startTop = scroll.scrollTop
        const range = track.clientHeight - thumb.offsetHeight
        const scrollable = scroll.scrollHeight - scroll.clientHeight
        const onMove = (ev) => {
          if (range <= 0) return
          scroll.scrollTop = startTop + ((ev.clientY - startY) / range) * scrollable
        }
        const onUp = () => {
          window.removeEventListener("mousemove", onMove)
          window.removeEventListener("mouseup", onUp)
        }
        window.addEventListener("mousemove", onMove)
        window.addEventListener("mouseup", onUp)
      })
    }

    this.syncScrollbar()
  },

  syncScrollbar() {
    if (!this.sb || !this.sb.bar || !this.sb.scroll) return
    const { bar, scroll, track, thumb } = this.sb
    const scrollable = scroll.scrollHeight - scroll.clientHeight

    if (scrollable <= 1) {
      bar.classList.add("idle")
      return
    }
    bar.classList.remove("idle")

    const trackH = track.clientHeight
    const height = Math.max(18, trackH * (scroll.clientHeight / scroll.scrollHeight))
    const top = (scroll.scrollTop / scrollable) * (trackH - height)
    thumb.style.height = `${Math.round(height)}px`
    thumb.style.top = `${Math.round(top)}px`
  },

  // ------------------------------------------------------------------ data

  readPhotos() {
    try {
      return JSON.parse(this.el.dataset.photos || "[]")
    } catch (_e) {
      return []
    }
  },

  merge(photos) {
    if (!photos || !photos.length) return
    const known = new Set(this.photos.map((p) => p.guid))
    const added = photos.filter((p) => !known.has(p.guid))
    if (!added.length && photos.length === this.photos.length) return

    this.photos = photos
    const byGuid = new Set(photos.map((p) => p.guid))

    // Keep the deck's remaining order, drop anything deleted from the album,
    // and scatter new arrivals through the part not yet shown.
    this.deck = this.deck.filter((i) => byGuid.has(i))
    added.forEach((p) => {
      const at = this.deckPos + 1 + Math.floor(Math.random() * Math.max(1, this.deck.length - this.deckPos))
      this.deck.splice(at, 0, p.guid)
    })

    if (!this.deck.length) this.reshuffle()
    if (!this.current && this.photos.length) {
      this.open()
      this.show(this.deck[0])
      this.play()
    }
  },

  photoFor(guid) {
    return this.photos.find((p) => p.guid === guid)
  },

  reshuffle() {
    const guids = this.photos.map((p) => p.guid)
    this.deck = shuffle(guids)
    // Don't let a reshuffle immediately repeat the photo already on screen.
    if (this.current && this.deck.length > 1 && this.deck[0] === this.current) {
      this.deck.push(this.deck.shift())
    }
    this.deckPos = 0
  },

  // ------------------------------------------------------------- navigation

  step(delta) {
    if (!this.deck.length) return
    this.deckPos += delta
    if (this.deckPos >= this.deck.length) {
      this.reshuffle()
    } else if (this.deckPos < 0) {
      this.deckPos = this.deck.length - 1
    }
    this.show(this.deck[this.deckPos])
    if (this.playing) this.schedule()
  },

  showGuid(guid) {
    const at = this.deck.indexOf(guid)
    if (at >= 0) this.deckPos = at
    this.open()
    this.show(guid)
    // An explicit click means they want to look at that one, not be moved on.
    if (!this.embedded) this.pause()
  },

  show(guid) {
    const photo = this.photoFor(guid)
    if (!photo) return
    this.current = guid

    // Every show gets a ticket; a slow load that resolves after the user has
    // moved on is dropped rather than yanking the stage back.
    const ticket = (this.ticket = (this.ticket || 0) + 1)

    const nextKey = this.front === "a" ? "b" : "a"
    const incoming = this.ui.layers[nextKey]
    const outgoing = this.ui.layers[this.front]
    const src = `/gallery/img/${guid}/display`
    const first = !outgoing.classList.contains("on")

    const fadeIn = () => {
      if (ticket !== this.ticket) return
      incoming.style.transitionDuration = `${FADE_IN_MS}ms`
      incoming.classList.add("on")
      this.front = nextKey

      if (!this.reduced) {
        incoming.classList.remove("drift")
        // Without the reflow the class re-add is a no-op and the drift stalls.
        void incoming.offsetWidth
        incoming.style.setProperty("--gal-dx", `${(Math.random() * 3 - 1.5).toFixed(2)}%`)
        incoming.style.setProperty("--gal-dy", `${(Math.random() * 3 - 1.5).toFixed(2)}%`)
        incoming.style.setProperty("--gal-dur", `${(SLIDE_MS + FADE_IN_MS) / 1000}s`)
        incoming.classList.add("drift")
      }

      if (this.ui.backdrop) {
        this.ui.backdrop.style.backgroundImage = `url("${src}")`
        this.ui.backdrop.style.opacity = "1"
      }
    }

    const ready = () => {
      if (ticket !== this.ticket) return
      if (first) return fadeIn()

      outgoing.style.transitionDuration = `${FADE_OUT_MS}ms`
      outgoing.classList.remove("on")
      outgoing.classList.remove("drift")
      if (this.ui.backdrop) this.ui.backdrop.style.opacity = "0"
      setTimeout(fadeIn, FADE_OUT_MS)
    }

    // Swap only once the bytes are in, so a slow photo never leaves the stage
    // sitting empty mid-transition.
    const probe = new Image()
    probe.decoding = "async"
    probe.onload = ready
    probe.onerror = () => { if (ticket === this.ticket && this.playing) this.step(1) }
    probe.src = src
    incoming.src = src
    if (probe.complete) ready()

    this.paint(photo)
    this.preload()
  },

  paint(photo) {
    const n = this.deck.indexOf(this.current)
    if (this.ui.title) this.ui.title.textContent = photo.date || "Photo"
    if (this.ui.counter) {
      this.ui.counter.textContent = `${n >= 0 ? n + 1 : 1} of ${this.photos.length}`
    }
    if (this.ui.caption) this.ui.caption.textContent = photo.caption || ""
  },

  preload() {
    for (let i = 1; i <= PRELOAD_AHEAD; i++) {
      const guid = this.deck[this.deckPos + i]
      if (!guid) continue
      const img = new Image()
      img.decoding = "async"
      img.src = `/gallery/img/${guid}/display`
    }
  },

  // ------------------------------------------------------------- mosaic

  // The mosaic's DOM and CSS are created here rather than in either page's
  // template, so /gallery and the homepage window get the identical thing
  // from one definition.
  ensureMosaic() {
    if (this.mosaic) return this.mosaic

    if (!document.getElementById("gal-mosaic-style")) {
      const style = document.createElement("style")
      style.id = "gal-mosaic-style"
      style.textContent = `
        .gal-mosaic { position: fixed; inset: 0; background: #000; display: none; }
        .gal-mosaic:fullscreen { display: block; }
        .gal-mosaic-grid {
          position: absolute; inset: 0; display: grid; gap: 3px; padding: 3px;
          grid-auto-flow: dense;
        }
        .gal-tile { position: relative; overflow: hidden; background: #0a0a0a; }
        .gal-tile img {
          position: absolute; inset: 0; width: 100%; height: 100%;
          object-fit: cover; opacity: 0; transition: opacity 900ms ease;
        }
        .gal-tile img.on { opacity: 1; }
        .gal-mosaic-exit {
          position: absolute; top: 14px; right: 16px; z-index: 5;
          font: 12px/20px "Chicago", "Geneva", Helvetica, sans-serif;
          background: #fff; color: #000; border: 1px solid #000;
          box-shadow: 1px 1px 0 #000; padding: 1px 10px; cursor: pointer; opacity: 0;
          transition: opacity 200ms;
        }
        .gal-mosaic:hover .gal-mosaic-exit { opacity: 1; }
        @media (prefers-reduced-motion: reduce) {
          .gal-tile img { transition: opacity 200ms ease; }
        }
      `
      document.head.appendChild(style)
    }

    const el = document.createElement("div")
    el.className = "gal-mosaic"
    const grid = document.createElement("div")
    grid.className = "gal-mosaic-grid"
    el.appendChild(grid)

    const exit = document.createElement("button")
    exit.className = "gal-mosaic-exit"
    exit.textContent = "Close"
    exit.addEventListener("click", () => this.exitMosaic())
    el.appendChild(exit)

    document.body.appendChild(el)
    this.mosaic = { el, grid, tiles: [], timers: [], layout: 0 }
    return this.mosaic
  },

  mosaicLayouts() {
    return window.innerWidth >= window.innerHeight
      ? { set: MOSAIC_LANDSCAPE, cols: MOSAIC_COLS.landscape }
      : { set: MOSAIC_PORTRAIT, cols: MOSAIC_COLS.portrait }
  },

  buildMosaic() {
    const m = this.ensureMosaic()
    const { set, cols } = this.mosaicLayouts()
    const layout = set[m.layout % set.length]
    const rows = Math.max(...layout.map(([, r, , rs]) => r + rs - 1))

    m.grid.style.gridTemplateColumns = `repeat(${cols}, 1fr)`
    m.grid.style.gridTemplateRows = `repeat(${rows}, 1fr)`

    // Reuse tiles across layout rotations so the photos already on screen stay
    // put and simply change size — rebuilding would flash the whole wall.
    while (m.tiles.length < layout.length) {
      const tile = document.createElement("div")
      tile.className = "gal-tile"
      const a = document.createElement("img")
      const b = document.createElement("img")
      a.alt = ""; b.alt = ""
      tile.append(a, b)
      m.grid.appendChild(tile)
      m.tiles.push({ el: tile, imgs: [a, b], front: 0, guid: null })
    }
    m.tiles.forEach((t, i) => {
      const spec = layout[i]
      t.el.style.display = spec ? "" : "none"
      if (!spec) return
      const [c, r, cs, rs] = spec
      t.el.style.gridColumn = `${c} / span ${cs}`
      t.el.style.gridRow = `${r} / span ${rs}`
    })
    return m
  },

  fillTile(tile) {
    if (!this.deck.length) return
    this.deckPos = (this.deckPos + 1) % this.deck.length
    if (this.deckPos === 0) this.reshuffle()
    const guid = this.deck[this.deckPos]
    if (!guid || guid === tile.guid) return
    tile.guid = guid

    const next = tile.imgs[1 - tile.front]
    const cur = tile.imgs[tile.front]
    const src = `/gallery/img/${guid}/display`
    const probe = new Image()
    probe.decoding = "async"
    probe.onload = () => {
      next.src = src
      next.classList.add("on")
      cur.classList.remove("on")
      tile.front = 1 - tile.front
    }
    probe.src = src
  },

  async enterMosaic() {
    if (!this.photos.length) return
    const m = this.buildMosaic()
    this.pause()

    try {
      await m.el.requestFullscreen()
    } catch (_e) {
      // Fullscreen can be refused (no user gesture, iOS Safari). Show it as a
      // fixed overlay instead rather than doing nothing at all.
      m.el.style.display = "block"
      m.el.style.zIndex = "9999"
    }

    m.tiles.forEach((t, i) => {
      if (t.el.style.display === "none") return
      setTimeout(() => this.fillTile(t), i * 120)
      m.timers.push(setInterval(() => this.fillTile(t), TILE_SWAP_MS + i * TILE_STAGGER_MS))
    })
    m.timers.push(setInterval(() => { m.layout++; this.buildMosaic() }, LAYOUT_ROTATE_MS))

    this.onFsChange = () => { if (!document.fullscreenElement) this.exitMosaic() }
    document.addEventListener("fullscreenchange", this.onFsChange)
    this.lockScreen()
  },

  exitMosaic() {
    const m = this.mosaic
    if (!m) return
    m.timers.forEach(clearInterval)
    m.timers = []
    m.el.style.display = ""
    m.el.style.zIndex = ""
    if (this.onFsChange) {
      document.removeEventListener("fullscreenchange", this.onFsChange)
      this.onFsChange = null
    }
    if (document.fullscreenElement) document.exitFullscreen().catch(() => {})
    this.play()
  },

  // ---------------------------------------------------------------- playback

  open() {
    if (!this.embedded && this.viewer) this.viewer.hidden = false
  },

  close() {
    this.pause()
    if (!this.embedded && this.viewer) this.viewer.hidden = true
  },

  play() {
    this.playing = true
    if (this.ui.toggle) this.ui.toggle.textContent = "Pause"
    this.schedule()
    this.lockScreen()
  },

  pause() {
    this.playing = false
    if (this.ui.toggle) this.ui.toggle.textContent = "Play"
    clearTimeout(this.timer)
    this.releaseScreen()
  },

  toggle() {
    this.playing ? this.pause() : this.play()
  },

  schedule() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.step(1), SLIDE_MS)
  },

  // Keep the display awake — the whole point is leaving this up on a screen.
  async lockScreen() {
    if (!("wakeLock" in navigator) || this.wakeLock) return
    try {
      this.wakeLock = await navigator.wakeLock.request("screen")
      this.wakeLock.addEventListener("release", () => { this.wakeLock = null })
    } catch (_e) {
      this.wakeLock = null
    }
  },

  releaseScreen() {
    if (this.wakeLock) {
      this.wakeLock.release().catch(() => {})
      this.wakeLock = null
    }
  },

  handleKey(e) {
    if (this.viewer && this.viewer.hidden) return
    if (e.target.matches("input, textarea")) return

    switch (e.key) {
      case "ArrowRight": e.preventDefault(); this.step(1); break
      case "ArrowLeft": e.preventDefault(); this.step(-1); break
      case " ": e.preventDefault(); this.toggle(); break
      case "Escape": this.close(); break
    }
  }
}

GalleryAmbient.el = document.getElementById("gal-desktop")
if (GalleryAmbient.el) GalleryAmbient.mounted()
