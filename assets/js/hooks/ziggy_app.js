import * as d3 from "d3";

const NODE_COLORS = {
  goal: "#2563eb",
  decision: "#9333ea",
  option: "#64748b",
  action: "#ea580c",
  outcome: "#0891b2",
  observation: "#ca8a04",
};

function nodeColor(n) {
  if (n.node_type === "option") return n.status === "completed" ? "#16a34a" : NODE_COLORS.option;
  return NODE_COLORS[n.node_type] || "#888";
}

const LANE_COLORS = ["#9a2b1f", "#0891b2", "#166534", "#7c2d92", "#a16207", "#1e3a8a", "#be185d", "#525252"];
function laneColor(lane) {
  return LANE_COLORS[lane % LANE_COLORS.length];
}

// Client-only view state (chapter filter, tree/force mode, search query, the
// open node/character) lives in the query string directly — via replaceState,
// not LiveView — so it's restorable on load/share without extra round-trips
// for what's inherently local UI state.
function getQueryParam(key) {
  return new URL(window.location.href).searchParams.get(key);
}
function setQueryParam(key, value) {
  const url = new URL(window.location.href);
  if (value === null || value === undefined || value === "") url.searchParams.delete(key);
  else url.searchParams.set(key, value);
  window.history.replaceState(null, "", url.toString());
}

function chapterOf(n) {
  try {
    return JSON.parse(n.metadata_json || "{}").branch || "unfiled";
  } catch (e) {
    return "unfiled";
  }
}

function escapeHtml(s) {
  return (s || "").replace(/[&<>]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" }[c]));
}

function rawNode(d) {
  return d && d.data ? d.data : d;
}

function renderDesc(desc) {
  if (!desc) return "";
  const parts = desc.split(/\n\nSources:\n/);
  let html = escapeHtml(parts[0]).replace(/\n/g, "<br>");
  if (parts[1]) html += '<div class="src">' + escapeHtml(parts[1]).replace(/\n/g, "<br>") + "</div>";
  return html;
}

const ZiggyApp = {
  mounted() {
    this.data = JSON.parse(this.el.dataset.graph);
    this.nodeById = new Map(this.data.nodes.map((n) => [n.id, n]));
    this.plotChapterFilter = null;
    this._initialParams = {
      mode: getQueryParam("mode"),
      chapter: getQueryParam("chapter"),
      q: getQueryParam("q"),
      node: getQueryParam("node"),
      char: getQueryParam("char"),
    };

    this.setupInspector();
    this.setupNavParamForwarding();
    this.renderOverview();
    this.renderThemes();
    this.setupSearch();
    this.setActiveView(this.el.dataset.activeView);

    // Restoring from a shared/reloaded URL: both a node and chat may be open
    // at once here (that's what the link encoded), so skip the "auto-close
    // chat on narrow screens" exclusion that applies to live interaction.
    this._restoring = true;
    if (this._initialParams.node) {
      const n = this.nodeById.get(parseInt(this._initialParams.node, 10));
      if (n) this.openInspectorForNode(n);
    } else if (this._initialParams.char) {
      const c = this.data.characters.find((c) => c.name === this._initialParams.char);
      if (c) this.openInspectorForChar(c);
    }
    this._restoring = false;
  },

  updated() {
    this.setActiveView(this.el.dataset.activeView);
  },

  setActiveView(v) {
    this.el.querySelectorAll(".zge-view").forEach((el) => el.classList.remove("active"));
    const target = this.el.querySelector("#zge-" + v);
    if (target) target.classList.add("active");
    if (v === "plot" && !this._plotRendered) {
      this.renderPlot();
      this._plotRendered = true;
    }
    if (v === "characters" && !this._charRendered) {
      this.renderCharacterGraph();
      this._charRendered = true;
    }
  },

  themeNamesFor(nodeId) {
    const ids = this.data.node_themes.filter((nt) => nt.node_id === nodeId).map((nt) => nt.theme_id);
    return this.data.themes.filter((t) => ids.includes(t.id));
  },

  getHoverTip() {
    let tip = this.el.querySelector("#zge-hover-tip");
    if (!tip) {
      tip = document.createElement("div");
      tip.id = "zge-hover-tip";
      tip.className = "zge-hover-tip";
      this.el.appendChild(tip);
    }
    return tip;
  },

  showHoverTip(ev, n) {
    const tip = this.getHoverTip();
    const themes = this.themeNamesFor(n.id);
    const snippet = (n.description || "").split(/\n\nSources:/)[0].slice(0, 220);
    tip.innerHTML = `
      <span class="zge-badge" style="background:${nodeColor(n)}">${n.node_type}</span>
      <span class="zge-badge" style="background:#555">${chapterOf(n)}</span>
      <div class="tip-title">${escapeHtml(n.title)}</div>
      ${snippet ? `<div class="tip-desc">${escapeHtml(snippet)}${(n.description || "").length > 220 ? "…" : ""}</div>` : ""}
      ${themes.length ? `<div class="tip-themes">${themes.map((t) => `<span class="zge-badge" style="background:${t.color}">${t.name}</span>`).join("")}</div>` : ""}
    `;
    tip.style.display = "block";
    this.moveHoverTip(ev);
  },

  moveHoverTip(ev) {
    const tip = this.el.querySelector("#zge-hover-tip");
    if (!tip || tip.style.display === "none") return;
    const pad = 18;
    const tipW = tip.offsetWidth || 300;
    const tipH = tip.offsetHeight || 80;
    let x = ev.clientX + pad;
    let y = ev.clientY + pad;
    if (x + tipW > window.innerWidth) x = ev.clientX - tipW - pad;
    if (y + tipH > window.innerHeight) y = ev.clientY - tipH - pad;
    tip.style.left = `${Math.max(4, x)}px`;
    tip.style.top = `${Math.max(4, y)}px`;
  },

  hideHoverTip() {
    const tip = this.el.querySelector("#zge-hover-tip");
    if (tip) tip.style.display = "none";
  },

  setupInspector() {
    this.el.querySelector("#zge-inspector-close").addEventListener("click", () => {
      this.el.querySelector("#zge-inspector").classList.remove("open");
      setQueryParam("node", null);
      setQueryParam("char", null);
    });
    // Chat (bottom sheet on narrow/medium screens) and the inspector panel can
    // both be overlays fighting for the same space there — keep them mutually
    // exclusive below the width where chat stops being a side column.
    this.handleEvent("ziggy-close-inspector", () => {
      if (window.innerWidth <= 1300) this.el.querySelector("#zge-inspector").classList.remove("open");
    });
  },

  closeChatIfNarrow() {
    if (window.innerWidth <= 1300) this.pushEvent("close_chat", this.currentUrlParams());
  },

  // What the server should preserve when it rewrites the URL for a view/chat
  // change — this client-side state isn't otherwise visible to it.
  currentUrlParams() {
    const p = new URL(window.location.href).searchParams;
    return {
      chapter: p.get("chapter"),
      mode: p.get("mode"),
      q: p.get("q"),
      node: p.get("node"),
      char: p.get("char"),
    };
  },

  // Nav buttons (Overview/Plot/.../Chat) are plain server-rendered phx-click
  // bindings outside this ignored subtree. Stamping phx-value-* here, in the
  // capture phase, runs before LiveView's own delegated click handling reads
  // them off the target — so set_view/toggle_chat see the current params.
  setupNavParamForwarding() {
    const nav = document.querySelector(".zg-nav");
    if (!nav || nav._ziggyForwardSetup) return;
    nav._ziggyForwardSetup = true;
    nav.addEventListener(
      "click",
      (e) => {
        const btn = e.target.closest("button");
        if (!btn) return;
        const current = this.currentUrlParams();
        Object.entries(current).forEach(([k, v]) => {
          if (v) btn.setAttribute(`phx-value-${k}`, v);
          else btn.removeAttribute(`phx-value-${k}`);
        });
      },
      true
    );
  },

  openInspectorForNode(node) {
    const body = this.el.querySelector("#zge-inspector-body");
    const themes = this.themeNamesFor(node.id);
    const incoming = this.data.edges
      .filter((e) => e.to_node_id === node.id)
      .map((e) => ({ edge: e, other: this.nodeById.get(e.from_node_id) }));
    const outgoing = this.data.edges
      .filter((e) => e.from_node_id === node.id)
      .map((e) => ({ edge: e, other: this.nodeById.get(e.to_node_id) }));

    body.innerHTML = `
      <span class="zge-badge" style="background:${nodeColor(node)}">${node.node_type}</span>
      <span class="zge-badge" style="background:#555">${chapterOf(node)}</span>
      <h3>${escapeHtml(node.title)}</h3>
      <div class="desc">${renderDesc(node.description)}</div>
      ${themes.length ? `<div class="rel-title">Themes</div>` + themes.map((t) => `<span class="zge-badge" style="background:${t.color}">${t.name}</span>`).join("") : ""}
      ${outgoing.length ? `<div class="rel-title">Leads to</div>` + outgoing.map((r) => `<a class="rel" data-id="${r.other ? r.other.id : ""}"><span class="rtype">${r.edge.edge_type}</span>${escapeHtml(r.other ? r.other.title : "?")}</a>`).join("") : ""}
      ${incoming.length ? `<div class="rel-title">Follows from</div>` + incoming.map((r) => `<a class="rel" data-id="${r.other ? r.other.id : ""}"><span class="rtype">${r.edge.edge_type}</span>${escapeHtml(r.other ? r.other.title : "?")}</a>`).join("") : ""}
    `;
    body.querySelectorAll(".rel").forEach((el) => {
      el.addEventListener("click", () => {
        const n = this.nodeById.get(parseInt(el.dataset.id));
        if (n) this.openInspectorForNode(n);
      });
    });
    this.el.querySelector("#zge-inspector").classList.add("open");
    setQueryParam("node", node.id);
    setQueryParam("char", null);
    if (!this._restoring) this.closeChatIfNarrow();
    this.centerOnNode(node.id);
  },

  openInspectorForChar(c) {
    const body = this.el.querySelector("#zge-inspector-body");
    const mentionNodes = c.mention_ids.map((id) => this.nodeById.get(id)).filter(Boolean);
    body.innerHTML = `
      <span class="zge-badge" style="background:#9a2b1f">character</span>
      <h3>${escapeHtml(c.name)}</h3>
      ${c.trait ? `<div class="desc">${escapeHtml(c.trait)}</div>` : ""}
      <div class="rel-title">Appears in (${mentionNodes.length})</div>
      ${mentionNodes.map((n) => `<a class="rel" data-id="${n.id}"><span class="rtype">${chapterOf(n)}</span>${escapeHtml(n.title)}</a>`).join("")}
    `;
    body.querySelectorAll(".rel").forEach((el) => {
      el.addEventListener("click", () => {
        const n = this.nodeById.get(parseInt(el.dataset.id));
        if (n) this.openInspectorForNode(n);
      });
    });
    this.el.querySelector("#zge-inspector").classList.add("open");
    setQueryParam("char", c.name);
    setQueryParam("node", null);
    if (!this._restoring) this.closeChatIfNarrow();
  },

  renderOverview() {
    const wrap = this.el.querySelector("#zge-overview-content");
    const chapters = {};
    this.data.nodes.forEach((n) => {
      const c = chapterOf(n);
      chapters[c] = (chapters[c] || 0) + 1;
    });
    const chapterKeys = Object.keys(chapters).sort();
    const max = Math.max(...Object.values(chapters), 1);
    const typeCounts = {};
    this.data.nodes.forEach((n) => (typeCounts[n.node_type] = (typeCounts[n.node_type] || 0) + 1));

    wrap.innerHTML = `
      <h2>Story Graph</h2>
      <p style="color:var(--zg-ink-dim); font-size:.88rem; max-width:52ch">
        A live map of ${this.data.nodes.length} story beats and ${this.data.edges.length} connections,
        mapped from the manuscript chapter by chapter.
      </p>
      <div class="zge-stats">
        <div class="zge-stat"><div class="n">${this.data.nodes.length}</div><div class="l">nodes</div></div>
        <div class="zge-stat"><div class="n">${this.data.edges.length}</div><div class="l">edges</div></div>
        <div class="zge-stat"><div class="n">${this.data.themes.length}</div><div class="l">themes</div></div>
        <div class="zge-stat"><div class="n">${chapterKeys.length}</div><div class="l">chapters</div></div>
      </div>
      <div style="margin-bottom:1.4rem">
        ${Object.entries(typeCounts).map(([t, c]) => `<span class="zge-badge" style="background:${NODE_COLORS[t] || "#888"}">${t} · ${c}</span>`).join("")}
      </div>
      <h3 style="font-size:.8rem; text-transform:uppercase; letter-spacing:.05em; color:var(--zg-ink-dim)">By chapter</h3>
      <div id="zge-chapter-list"></div>
    `;
    const list = wrap.querySelector("#zge-chapter-list");
    chapterKeys.forEach((c) => {
      const row = document.createElement("div");
      row.className = "zge-chapter-row";
      row.innerHTML = `<span class="label">${c}</span><span class="bar" style="width:${((chapters[c] / max) * 220).toFixed(0)}px"></span><span class="count">${chapters[c]}</span>`;
      row.addEventListener("click", () => {
        this.pushEvent("set_view", { view: "plot" });
        setTimeout(() => this.setChapterFilter(c), 120);
      });
      list.appendChild(row);
    });
  },

  renderThemes() {
    const wrap = this.el.querySelector("#zge-themes-content");
    wrap.innerHTML = "<h2>Themes</h2>";
    this.data.themes.forEach((t) => {
      const count = this.data.node_themes.filter((nt) => nt.theme_id === t.id).length;
      const card = document.createElement("div");
      card.className = "zge-theme-card";
      card.style.borderLeftColor = t.color;
      card.innerHTML = `<h3>${escapeHtml(t.name)}</h3><p>${escapeHtml(t.description)}</p><div class="count">${count} node${count === 1 ? "" : "s"}</div>`;
      card.addEventListener("click", () => {
        this.pushEvent("set_view", { view: "search" });
        setTimeout(() => {
          const input = this.el.querySelector("#zge-search-input");
          input.value = t.name;
          this.runSearch(t.name);
        }, 120);
      });
      wrap.appendChild(card);
    });
  },

  setupSearch() {
    const input = this.el.querySelector("#zge-search-input");
    input.addEventListener("input", (e) => {
      setQueryParam("q", e.target.value);
      this.runSearch(e.target.value);
    });
    if (this._initialParams.q) {
      input.value = this._initialParams.q;
      this.runSearch(this._initialParams.q);
    }
  },

  runSearch(q) {
    const wrap = this.el.querySelector("#zge-search-results");
    const terms = (q || "")
      .toLowerCase()
      .split(/[^a-z0-9]+/)
      .filter((t) => t.length >= 3);

    if (terms.length === 0) {
      wrap.innerHTML = '<div style="color:var(--zg-ink-dim); font-size:.85rem; padding:1rem 0">Type at least a few letters to search story beats.</div>';
      return;
    }

    const scored = this.data.nodes
      .map((n) => {
        const text = (n.title + " " + (n.description || "")).toLowerCase();
        const score = terms.filter((t) => text.includes(t)).length;
        return { n, score };
      })
      .filter((r) => r.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 40);

    wrap.innerHTML = `<div style="font-size:.72rem; color:var(--zg-ink-dim); margin-bottom:.5rem">${scored.length} match${scored.length === 1 ? "" : "es"}</div>`;
    scored.forEach(({ n }) => {
      const card = document.createElement("div");
      card.className = "zge-result";
      const snippet = (n.description || "").slice(0, 160);
      card.innerHTML = `<h4><span class="zge-badge" style="background:${nodeColor(n)}; font-size:.6rem">${n.node_type}</span> ${escapeHtml(n.title)}</h4><p>${escapeHtml(snippet)}${(n.description || "").length > 160 ? "…" : ""}</p>`;
      card.addEventListener("click", () => this.openInspectorForNode(n));
      wrap.appendChild(card);
    });
  },

  setChapterFilter(c) {
    this.plotChapterFilter = this.plotChapterFilter === c ? null : c;
    setQueryParam("chapter", this.plotChapterFilter);
    this.el.querySelectorAll("#zge-plot-chips .zge-chip").forEach((chip) => {
      chip.classList.toggle("on", chip.dataset.ch === this.plotChapterFilter);
    });
    d3.select(this.el)
      .selectAll("#zge-plot-svg .zge-node")
      .style("opacity", (d) => (this.plotChapterFilter && chapterOf(rawNode(d)) !== this.plotChapterFilter ? 0.15 : 1));
    d3.select(this.el)
      .selectAll("#zge-plot-svg .zge-link")
      .style("opacity", (d) => {
        const s = rawNode(d.source),
          t = rawNode(d.target);
        if (!this.plotChapterFilter) return this._plotMode === "tree" ? 1 : 0.55;
        return chapterOf(s) !== this.plotChapterFilter && chapterOf(t) !== this.plotChapterFilter ? 0.06 : this._plotMode === "tree" ? 1 : 0.55;
      });
  },

  renderPlot() {
    this.buildChapterChips();
    this.buildPlotLegend();
    this.setupPlotModeToggle();
    this.setupZoomControls();
    this.applyPlotMode(this._initialParams.mode === "force" ? "force" : "tree");
    if (this._initialParams.chapter) this.setChapterFilter(this._initialParams.chapter);
  },

  setupZoomControls() {
    if (this._zoomSetup) return;
    this._zoomSetup = true;
    const toolbar = this.el.querySelector("#zge-plot-toolbar");
    const wrap = document.createElement("div");
    wrap.className = "zge-chips";
    wrap.style.marginBottom = ".5rem";
    wrap.innerHTML = `
      <span class="zge-chip" id="zge-zoom-out">−</span>
      <span class="zge-chip" id="zge-zoom-reset">100%</span>
      <span class="zge-chip" id="zge-zoom-in">+</span>
    `;
    toolbar.insertBefore(wrap, toolbar.firstChild);
    wrap.querySelector("#zge-zoom-out").addEventListener("click", () => this.zoomBy(0.8));
    wrap.querySelector("#zge-zoom-in").addEventListener("click", () => this.zoomBy(1.25));
    wrap.querySelector("#zge-zoom-reset").addEventListener("click", () => this.zoomReset());
  },

  // clientX/clientY (viewport coords) name the point that should stay under
  // the cursor/fingers as the scale changes. Omit them to zoom on-center.
  zoomBy(factor, clientX, clientY) {
    if (this._plotMode === "tree") {
      this.treeZoomBy(factor, clientX, clientY);
    } else if (this._forceZoomSel && this._forceZoomBehavior) {
      this._forceZoomSel.transition().duration(150).call(this._forceZoomBehavior.scaleBy, factor);
    }
  },

  zoomReset() {
    if (this._plotMode === "tree") {
      this.treeZoomBy(1 / (this._treeZoom || 1));
    } else if (this._forceZoomSel && this._forceZoomBehavior) {
      this._forceZoomSel.transition().duration(150).call(this._forceZoomBehavior.transform, d3.zoomIdentity);
    }
  },

  treeZoomBy(factor, clientX, clientY) {
    const holder = this.el.querySelector(".zge-svg-holder");
    if (!holder || !this._treeContentW) return;

    const oldScale = (this._treeBaseScale || 1) * (this._treeZoom || 1);
    const newZoom = Math.min(3, Math.max(0.4, (this._treeZoom || 1) * factor));
    const newScale = (this._treeBaseScale || 1) * newZoom;
    if (newScale === oldScale) return;

    // Anchor point in *viewport* pixels (relative to the holder) — default
    // to its center so button clicks zoom in place instead of jumping.
    const rect = holder.getBoundingClientRect();
    const vx = clientX != null ? clientX - rect.left : holder.clientWidth / 2;
    const vy = clientY != null ? clientY - rect.top : holder.clientHeight / 2;

    // Same content point, in content coordinates (scale-independent).
    const contentX = (holder.scrollLeft + vx) / oldScale;
    const contentY = (holder.scrollTop + vy) / oldScale;

    this._treeZoom = newZoom;
    this.applyTreeZoomSize();

    holder.scrollLeft = Math.max(0, contentX * newScale - vx);
    holder.scrollTop = Math.max(0, contentY * newScale - vy);
  },

  applyTreeZoomSize() {
    const svgEl = this.el.querySelector("#zge-plot-svg");
    if (!this._treeContentW) return;
    const scale = (this._treeBaseScale || 1) * (this._treeZoom || 1);
    svgEl.style.width = `${Math.round(this._treeContentW * scale)}px`;
    svgEl.style.height = `${Math.max(300, Math.round(this._treeContentH * scale))}px`;
  },

  touchDist(touches) {
    const dx = touches[0].clientX - touches[1].clientX;
    const dy = touches[0].clientY - touches[1].clientY;
    return Math.sqrt(dx * dx + dy * dy);
  },

  setupPinchZoom(holder) {
    if (holder._ziggyPinchSetup) return;
    holder._ziggyPinchSetup = true;
    let startDist = null;

    holder.addEventListener(
      "touchstart",
      (e) => {
        if (e.touches.length === 2) startDist = this.touchDist(e.touches);
      },
      { passive: true }
    );

    holder.addEventListener(
      "touchmove",
      (e) => {
        if (e.touches.length === 2 && startDist) {
          e.preventDefault();
          const dist = this.touchDist(e.touches);
          const midX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
          const midY = (e.touches[0].clientY + e.touches[1].clientY) / 2;
          this.zoomBy(dist / startDist, midX, midY);
          startDist = dist;
        }
      },
      { passive: false }
    );

    holder.addEventListener("touchend", (e) => {
      if (e.touches.length < 2) startDist = null;
    });

    // Trackpad pinch surfaces as wheel+ctrlKey in every major browser.
    holder.addEventListener(
      "wheel",
      (e) => {
        if (e.ctrlKey) {
          e.preventDefault();
          this.zoomBy(e.deltaY < 0 ? 1.08 : 0.93, e.clientX, e.clientY);
        }
      },
      { passive: false }
    );
  },

  setupDragPan(holder) {
    if (holder._ziggyDragSetup) return;
    holder._ziggyDragSetup = true;
    let dragging = false,
      moved = false,
      startX = 0,
      startY = 0,
      startLeft = 0,
      startTop = 0;

    holder.addEventListener("mousedown", (e) => {
      if (e.target.closest(".zge-node") || e.button !== 0) return;
      dragging = true;
      moved = false;
      startX = e.clientX;
      startY = e.clientY;
      startLeft = holder.scrollLeft;
      startTop = holder.scrollTop;
      holder.style.cursor = "grabbing";
      document.body.style.userSelect = "none";
      e.preventDefault();
    });

    window.addEventListener("mousemove", (e) => {
      if (!dragging) return;
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;
      if (Math.abs(dx) > 2 || Math.abs(dy) > 2) moved = true;
      holder.scrollLeft = startLeft - dx;
      holder.scrollTop = startTop - dy;
    });

    window.addEventListener("mouseup", () => {
      if (dragging) {
        dragging = false;
        holder.style.cursor = "grab";
        document.body.style.userSelect = "";
      }
    });

    // Suppress the click that would otherwise fire right after a drag (it
    // was landing on whatever node happened to end up under the cursor).
    holder.addEventListener(
      "click",
      (e) => {
        if (moved) {
          e.stopPropagation();
          e.preventDefault();
          moved = false;
        }
      },
      true
    );
  },

  centerOnNode(nodeId) {
    if (this._plotMode === "tree") this.centerTreeOn(nodeId);
    else if (this._plotMode === "force") this.centerForceOn(nodeId);
  },

  centerTreeOn(nodeId) {
    const holder = this.el.querySelector(".zge-svg-holder");
    const pos = this._treeNodePos && this._treeNodePos.get(nodeId);
    if (!holder || !pos) return;
    const scale = (this._treeBaseScale || 1) * (this._treeZoom || 1);
    holder.scrollTo({
      left: Math.max(0, pos.x * scale - holder.clientWidth / 2),
      top: Math.max(0, pos.y * scale - holder.clientHeight / 2),
      behavior: "smooth",
    });
  },

  centerForceOn(nodeId) {
    const n = this._forceNodesById && this._forceNodesById.get(nodeId);
    const svgEl = this.el.querySelector("#zge-plot-svg");
    if (!n || !svgEl || !this._forceZoomSel || !this._forceZoomBehavior) return;
    const w = svgEl.clientWidth || 800,
      h = svgEl.clientHeight || 600;
    const scale = 1.5;
    const t = d3.zoomIdentity.translate(w / 2, h / 2).scale(scale).translate(-n.x, -n.y);
    this._forceZoomSel.transition().duration(500).call(this._forceZoomBehavior.transform, t);
  },

  buildChapterChips() {
    const chips = this.el.querySelector("#zge-plot-chips");
    chips.innerHTML = "";
    const chapters = [...new Set(this.data.nodes.map(chapterOf))].sort();
    chapters.forEach((c) => {
      const chip = document.createElement("span");
      chip.className = "zge-chip";
      chip.textContent = c;
      chip.dataset.ch = c;
      chip.addEventListener("click", () => this.setChapterFilter(c));
      chips.appendChild(chip);
    });
  },

  buildPlotLegend() {
    const legend = this.el.querySelector("#zge-plot-legend");
    legend.innerHTML =
      Object.entries(NODE_COLORS)
        .map(([k, v]) => `<div class="row"><span class="sw" style="background:${v}"></span>${k}</div>`)
        .join("") +
      `<div class="row"><span class="sw" style="background:#16a34a"></span>option (chosen)</div>
       <div class="row" style="margin-top:.3rem; font-weight:700">Lines (Tree view)</div>
       <div class="row">colored line = a branch/lane, not a verdict</div>
       <div class="row"><span class="sw" style="background:#9a2b1f; border-radius:2px; width:14px; height:3px; opacity:.5"></span>requires (cross-ref)</div>
       <div class="row" style="margin-top:.3rem; font-weight:700">Lines (Force view)</div>
       <div class="row"><span class="sw" style="background:#16a34a; border-radius:2px; width:14px; height:3px"></span>chosen</div>
       <div class="row"><span class="sw" style="background:#94a3b8; border-radius:2px; width:14px; height:3px"></span>rejected</div>`;
  },

  setupPlotModeToggle() {
    if (this._modeSetup) return;
    this._modeSetup = true;
    const toolbar = this.el.querySelector("#zge-plot-toolbar");
    const modeWrap = document.createElement("div");
    modeWrap.innerHTML = `<div><strong>View</strong></div><div class="zge-chips" id="zge-plot-mode" style="margin-bottom:.5rem"></div>`;
    toolbar.insertBefore(modeWrap, toolbar.firstChild);
    ["tree", "force"].forEach((m) => {
      const chip = document.createElement("span");
      chip.className = "zge-chip";
      chip.textContent = m === "tree" ? "Tree" : "Force";
      chip.dataset.mode = m;
      chip.addEventListener("click", () => this.applyPlotMode(m));
      modeWrap.querySelector("#zge-plot-mode").appendChild(chip);
    });
  },

  applyPlotMode(mode) {
    this._plotMode = mode;
    setQueryParam("mode", mode === "force" ? "force" : null);
    this.el.querySelectorAll("#zge-plot-mode .zge-chip").forEach((c) => c.classList.toggle("on", c.dataset.mode === mode));
    this.plotChapterFilter = null;
    this.el.querySelectorAll("#zge-plot-chips .zge-chip").forEach((c) => c.classList.remove("on"));
    if (mode === "tree") this.renderPlotTree();
    else this.renderPlotForce();
  },

  // git-log style: one row per story beat, a dot in a narrow lane column,
  // the beat's title as inline text beside it — the "trunk" (each node's
  // first child) runs straight down a lane; every other child branches off
  // into a fresh lane exactly where it diverges, like `git log --graph`.
  renderPlotTree() {
    const svgEl = this.el.querySelector("#zge-plot-svg");
    const holder = this.el.querySelector(".zge-svg-holder");
    const svg = d3.select(svgEl);
    svg.selectAll("*").remove();

    holder.classList.add("tree-scroll");
    svgEl.removeAttribute("style");
    this.setupPinchZoom(holder);
    this.setupDragPan(holder);

    const nodeById = this.nodeById;

    const parentOf = new Map();
    const secondary = [];
    [...this.data.edges]
      .sort((a, b) => a.id - b.id)
      .forEach((e) => {
        if (e.edge_type === "requires") {
          secondary.push(e);
          return;
        }
        if (!parentOf.has(e.to_node_id)) parentOf.set(e.to_node_id, e.from_node_id);
        else secondary.push(e);
      });

    const childIds = new Map();
    this.data.nodes.forEach((n) => {
      const p = parentOf.get(n.id);
      if (p !== undefined) {
        if (!childIds.has(p)) childIds.set(p, []);
        childIds.get(p).push(n.id);
      }
    });

    const roots = this.data.nodes.filter((n) => !parentOf.has(n.id));

    let rowCounter = 0;
    let nextLane = 0;
    const rowOf = new Map(),
      laneOf = new Map();

    const walk = (startId, lane) => {
      let id = startId;
      while (id != null) {
        rowOf.set(id, rowCounter++);
        laneOf.set(id, lane);
        const kids = childIds.get(id) || [];
        if (kids.length === 0) {
          id = null;
        } else {
          for (let i = 1; i < kids.length; i++) walk(kids[i], nextLane++);
          id = kids[0];
        }
      }
    };
    roots.forEach((r) => walk(r.id, nextLane++));

    // Cap how far lanes can push things right — a lane number that's only
    // ever used once, far out, would otherwise blow the canvas out sideways
    // for no visual benefit. Anything past the cap reuses lane positions
    // modulo the cap (rare enough not to matter for readability).
    const maxLane = Math.max(0, ...Array.from(laneOf.values()));
    const laneCap = Math.min(maxLane, 14);
    const rowH = 17,
      laneW = 11,
      laneStartX = 8;
    const xOf = (lane) => laneStartX + (lane <= laneCap ? lane : laneCap + (lane % 3)) * laneW;
    const yOf = (id) => rowOf.get(id) * rowH + 12;
    const gapAfterLanes = 8;

    const contentW = xOf(laneCap) + gapAfterLanes + 480;
    const contentH = rowCounter * rowH + 24;

    this._treeContentW = contentW;
    this._treeContentH = contentH;
    this._treeBaseScale = Math.min(1, (holder.clientWidth || 800) / contentW);
    this._treeZoom = 1;
    svgEl.setAttribute("viewBox", `0 0 ${contentW} ${contentH}`);
    svgEl.style.display = "block";
    this.applyTreeZoomSize();

    // Each row's text sits right next to *its own* dot — text staircases
    // right with deeper branches instead of jumping to one shared column.
    this._treeNodePos = new Map();
    this.data.nodes.forEach((n) => {
      if (rowOf.has(n.id)) this._treeNodePos.set(n.id, { x: xOf(laneOf.get(n.id)), y: yOf(n.id) });
    });

    const g = svg.append("g");

    const links = [];
    childIds.forEach((kids, pid) => {
      const parentNode = nodeById.get(pid);
      kids.forEach((cid) => {
        links.push({ source: parentNode, target: nodeById.get(cid), lane: laneOf.get(cid) });
      });
    });

    g.append("g")
      .selectAll("path.zge-link")
      .data(links)
      .join("path")
      .attr("class", "zge-link")
      .attr("fill", "none")
      .attr("stroke", (d) => laneColor(d.lane))
      .attr("stroke-width", 1.6)
      .attr("d", (d) => {
        const x1 = xOf(laneOf.get(d.source.id)),
          y1 = yOf(d.source.id);
        const x2 = xOf(d.lane),
          y2 = yOf(d.target.id);
        if (x1 === x2) return `M${x1},${y1} L${x2},${y2}`;
        const my = (y1 + y2) / 2;
        return `M${x1},${y1} C${x1},${my} ${x2},${my} ${x2},${y2}`;
      });

    g.append("g")
      .selectAll("path.zge-req")
      .data(secondary.filter((e) => rowOf.has(e.from_node_id) && rowOf.has(e.to_node_id)))
      .join("path")
      .attr("fill", "none")
      .attr("stroke", "#9a2b1f")
      .attr("stroke-opacity", 0.3)
      .attr("stroke-dasharray", "1,4")
      .attr("stroke-width", 1)
      .attr("d", (e) => {
        const x1 = xOf(laneOf.get(e.from_node_id)) - 5,
          y1 = yOf(e.from_node_id);
        const x2 = xOf(laneOf.get(e.to_node_id)) - 5,
          y2 = yOf(e.to_node_id);
        const mx = Math.min(x1, x2) - 10;
        return `M${x1},${y1} C${mx},${y1} ${mx},${y2} ${x2},${y2}`;
      });

    const rows = g
      .append("g")
      .selectAll("g.zge-node")
      .data(this.data.nodes.filter((n) => rowOf.has(n.id)))
      .join("g")
      .attr("class", "zge-node")
      .attr("transform", (n) => `translate(0,${yOf(n.id)})`)
      .style("cursor", "pointer")
      .on("click", (ev, n) => {
        ev.stopPropagation();
        this.hideHoverTip();
        this.openInspectorForNode(n);
      })
      .on("mouseenter", (ev, n) => this.showHoverTip(ev, n))
      .on("mousemove", (ev) => this.moveHoverTip(ev))
      .on("mouseleave", () => this.hideHoverTip());

    rows
      .append("circle")
      .attr("cx", (n) => xOf(laneOf.get(n.id)))
      .attr("r", 3.5)
      .attr("fill", (n) => nodeColor(n))
      .style("stroke", "#fff")
      .style("stroke-width", "1px");

    rows
      .append("text")
      .attr("class", "zge-node-label")
      .attr("x", (n) => xOf(laneOf.get(n.id)) + gapAfterLanes)
      .attr("y", 3)
      .attr("text-anchor", "start")
      .text((n) => (n.title.length > 68 ? n.title.slice(0, 68) + "…" : n.title));
  },

  renderPlotForce() {
    const svgEl = this.el.querySelector("#zge-plot-svg");
    const holder = this.el.querySelector(".zge-svg-holder");
    holder.classList.remove("tree-scroll");
    svgEl.removeAttribute("viewBox");
    svgEl.removeAttribute("style");

    const svg = d3.select(svgEl);
    svg.selectAll("*").remove();
    const bbox = holder.getBoundingClientRect();
    const width = bbox.width || 800,
      height = bbox.height || 600;

    const g = svg.append("g");
    const nodes = this.data.nodes.map((n) => ({ ...n }));
    const links = this.data.edges.map((e) => ({ ...e, source: e.from_node_id, target: e.to_node_id }));
    this._forceNodesById = new Map(nodes.map((n) => [n.id, n]));

    const zoom = d3.zoom().scaleExtent([0.25, 4]).on("zoom", (ev) => g.attr("transform", ev.transform));
    svg.call(zoom);
    this._forceZoomSel = svg;
    this._forceZoomBehavior = zoom;

    const sim = d3
      .forceSimulation(nodes)
      .force("link", d3.forceLink(links).id((d) => d.id).distance(70).strength(0.5))
      .force("charge", d3.forceManyBody().strength(-220))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collide", d3.forceCollide(26));

    const link = g
      .append("g")
      .selectAll("line")
      .data(links)
      .join("line")
      .attr("class", "zge-link")
      .attr("stroke", (d) => (d.edge_type === "rejected" ? "#94a3b8" : d.edge_type === "chosen" ? "#16a34a" : d.edge_type === "requires" ? "#9a2b1f" : "#9a8f78"))
      .attr("stroke-width", 1.3)
      .attr("stroke-dasharray", (d) => (d.edge_type === "rejected" ? "2,3" : d.edge_type === "requires" ? "1,4" : null));

    const node = g
      .append("g")
      .selectAll("g")
      .data(nodes)
      .join("g")
      .attr("class", "zge-node")
      .call(
        d3
          .drag()
          .on("start", (ev, d) => {
            if (!ev.active) sim.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
          })
          .on("drag", (ev, d) => {
            d.fx = ev.x;
            d.fy = ev.y;
          })
          .on("end", (ev, d) => {
            if (!ev.active) sim.alphaTarget(0);
            d.fx = null;
            d.fy = null;
          })
      );

    node
      .append("circle")
      .attr("r", (d) => 5 + Math.min(6, this.data.edges.filter((e) => e.from_node_id === d.id || e.to_node_id === d.id).length))
      .attr("fill", (d) => nodeColor(d))
      .style("stroke", "var(--zg-bg)")
      .style("stroke-width", "1.5px")
      .style("cursor", "pointer")
      .on("click", (ev, d) => {
        ev.stopPropagation();
        this.openInspectorForNode(d);
      });

    node
      .append("text")
      .attr("class", "zge-node-label")
      .attr("dy", -12)
      .attr("text-anchor", "middle")
      .text((d) => (d.title.length > 34 ? d.title.slice(0, 34) + "…" : d.title));

    sim.on("tick", () => {
      link.attr("x1", (d) => d.source.x).attr("y1", (d) => d.source.y).attr("x2", (d) => d.target.x).attr("y2", (d) => d.target.y);
      node.attr("transform", (d) => `translate(${d.x},${d.y})`);
    });
  },

  renderCharacterGraph() {
    const svg = d3.select(this.el.querySelector("#zge-char-svg"));
    svg.selectAll("*").remove();
    const bbox = this.el.querySelector("#zge-characters .zge-svg-holder").getBoundingClientRect();
    const width = bbox.width || 800,
      height = bbox.height || 600;

    const chars = this.data.characters.filter((c) => c.mention_ids.length > 0);

    const legend = this.el.querySelector("#zge-char-legend");
    legend.innerHTML = `<div class="row"><span class="sw" style="background:#9a2b1f"></span>protagonist</div>
      <div class="row"><span class="sw" style="background:#64748b"></span>other</div>
      <div class="row" style="margin-top:.2rem; font-style:italic">edge weight = shared story beats</div>`;

    const roleColor = (c) => (c.name === "Garrett" ? "#9a2b1f" : "#64748b");

    const nodes = chars.map((c) => ({ ...c, id: c.name, count: c.mention_ids.length }));
    const edgeMap = new Map();
    for (let i = 0; i < chars.length; i++) {
      for (let j = i + 1; j < chars.length; j++) {
        const shared = chars[i].mention_ids.filter((id) => chars[j].mention_ids.includes(id)).length;
        if (shared > 0) edgeMap.set(`${chars[i].name}|${chars[j].name}`, shared);
      }
    }
    const links = [...edgeMap.entries()].map(([k, w]) => {
      const [a, b] = k.split("|");
      return { source: a, target: b, weight: w };
    });

    const g = svg.append("g");
    const zoom = d3.zoom().scaleExtent([0.25, 4]).on("zoom", (ev) => g.attr("transform", ev.transform));
    svg.call(zoom);

    const sim = d3
      .forceSimulation(nodes)
      .force("link", d3.forceLink(links).id((d) => d.id).distance((d) => 110 / Math.sqrt(d.weight)).strength(0.6))
      .force("charge", d3.forceManyBody().strength(-260))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collide", d3.forceCollide(34));

    const link = g
      .append("g")
      .selectAll("line")
      .data(links)
      .join("line")
      .attr("class", "zge-link")
      .attr("stroke", "#9a8f78")
      .attr("stroke-width", (d) => Math.min(6, 1 + d.weight * 0.8));

    const node = g
      .append("g")
      .selectAll("g")
      .data(nodes)
      .join("g")
      .attr("class", "zge-node")
      .call(
        d3
          .drag()
          .on("start", (ev, d) => {
            if (!ev.active) sim.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
          })
          .on("drag", (ev, d) => {
            d.fx = ev.x;
            d.fy = ev.y;
          })
          .on("end", (ev, d) => {
            if (!ev.active) sim.alphaTarget(0);
            d.fx = null;
            d.fy = null;
          })
      );

    node
      .append("circle")
      .attr("r", (d) => 10 + Math.min(16, d.count * 1.6))
      .attr("fill", roleColor)
      .style("cursor", "pointer")
      .on("click", (ev, d) => {
        ev.stopPropagation();
        this.openInspectorForChar(d);
      });

    node
      .append("text")
      .attr("dy", 4)
      .attr("text-anchor", "middle")
      .style("fill", "#fff")
      .style("font-weight", "700")
      .style("font-size", "11px")
      .style("pointer-events", "none")
      .text((d) => d.name);

    sim.on("tick", () => {
      link.attr("x1", (d) => d.source.x).attr("y1", (d) => d.source.y).attr("x2", (d) => d.target.x).attr("y2", (d) => d.target.y);
      node.attr("transform", (d) => `translate(${d.x},${d.y})`);
    });
  },
};

export default ZiggyApp;
