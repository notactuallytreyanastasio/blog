import * as d3 from "d3";

/* ============================================================================
   Explorer for "The RootedInGood(TM) Method" decision graph.

   Same shape as the Ziggy and Lolly explorers — overview / plot / themes /
   search, an inspector panel, and URL-synced client state. The parts here are
   the manuscript's thirteen chapters plus its framing, spine, arcs and
   alignment layers, and the second graph tab is the AI_NOTE commentary layer.
   ========================================================================== */

const NODE_COLORS = {
  goal: "#2563eb",
  decision: "#9333ea",
  option: "#64748b",
  action: "#ea580c",
  outcome: "#0891b2",
  observation: "#ca8a04",
};
const NOTE_COLOR = "#db2777";
const CHOSEN_COLOR = "#16a34a";

const NOTE_PREFIX = "AI_NOTE:";
const isNote = (n) => (n.title || "").trim().startsWith(NOTE_PREFIX);
const displayTitle = (n) => (isNote(n) ? n.title.trim().replace(/^AI_NOTE:\s*/, "") : n.title);

function nodeColor(n) {
  if (isNote(n)) return NOTE_COLOR;
  if (n.node_type === "option") return n.status === "completed" ? CHOSEN_COLOR : NODE_COLORS.option;
  return NODE_COLORS[n.node_type] || "#888";
}

const LANE_COLORS = ["#9a2b1f", "#0891b2", "#166534", "#7c2d92", "#a16207", "#1e3a8a", "#be185d", "#525252"];
function laneColor(lane) {
  return LANE_COLORS[lane % LANE_COLORS.length];
}

// Client-only view state (part filter, tree/force mode, search query, the open
// node) lives in the query string directly — via replaceState, not LiveView —
// so it's restorable on load/share without extra round-trips for what is
// inherently local UI state.
function getQueryParam(key) {
  return new URL(window.location.href).searchParams.get(key);
}
function setQueryParam(key, value) {
  const url = new URL(window.location.href);
  if (value === null || value === undefined || value === "") url.searchParams.delete(key);
  else url.searchParams.set(key, value);
  window.history.replaceState(null, "", url.toString());
}

function partOf(n) {
  try {
    return JSON.parse(n.metadata_json || "{}").branch || "unfiled";
  } catch (e) {
    return "unfiled";
  }
}

const PART_LABELS = {
  book: "This exploration",
  spine: "Book spine",
  front: "Framing & promise",
  arcs: "Arcs across chapters",
  alignment: "Promises vs. content",
  "ai-notes": "AI commentary",
  unfiled: "Unfiled",
};
for (let i = 1; i <= 13; i++) PART_LABELS["ch-" + i] = "Chapter " + i;
const partLabel = (p) => PART_LABELS[p] || p;

const PART_ORDER = [
  "book", "spine", "front",
  "ch-1", "ch-2", "ch-3", "ch-4", "ch-5", "ch-6", "ch-7",
  "ch-8", "ch-9", "ch-10", "ch-11", "ch-12", "ch-13",
  "arcs", "alignment", "ai-notes", "unfiled",
];
const partRank = (p) => {
  const i = PART_ORDER.indexOf(p);
  return i === -1 ? 99 : i;
};

function escapeHtml(s) {
  return (s || "").replace(/[&<>]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" }[c]));
}

function rawNode(d) {
  return d && d.data ? d.data : d;
}

// Content nodes carry their verbatim book quotes in a trailing "Sources:"
// block; render it as a quieter footnote rather than body text.
function renderDesc(desc) {
  if (!desc) return "";
  const parts = desc.split(/\n+Sources:\s*\n/);
  let html = escapeHtml(parts[0]).replace(/\n/g, "<br>");
  if (parts[1]) html += '<div class="src">' + escapeHtml(parts[1]).replace(/\n/g, "<br>") + "</div>";
  return html;
}

const RootedApp = {
  mounted() {
    this.data = JSON.parse(this.el.dataset.graph);
    this.nodeById = new Map(this.data.nodes.map((n) => [n.id, n]));
    this.plotPartFilter = null;
    this._initialParams = {
      mode: getQueryParam("mode"),
      part: getQueryParam("part"),
      q: getQueryParam("q"),
      node: getQueryParam("node"),
    };

    this.setupInspector();
    this.setupNavParamForwarding();
    this.renderOverview();
    this.renderThemes();
    this.renderNotes();
    this.setupSearch();
    this.setActiveView(this.el.dataset.activeView);

    // Restoring from a shared/reloaded URL: both a node and chat may be open
    // at once here (that's what the link encoded), so skip the "auto-close
    // chat on narrow screens" exclusion that applies to live interaction.
    this._restoring = true;
    if (this._initialParams.node) {
      const n = this.nodeById.get(parseInt(this._initialParams.node, 10));
      if (n) this.openInspectorForNode(n);
    }
    this._restoring = false;
  },

  updated() {
    this.setActiveView(this.el.dataset.activeView);
  },

  setActiveView(v) {
    this.el.querySelectorAll(".rge-view").forEach((el) => el.classList.remove("active"));
    const target = this.el.querySelector("#rge-" + v);
    if (target) target.classList.add("active");
    if (v === "plot" && !this._plotRendered) {
      this.renderPlot();
      this._plotRendered = true;
    }
  },

  themeNamesFor(nodeId) {
    const ids = this.data.node_themes.filter((nt) => nt.node_id === nodeId).map((nt) => nt.theme_id);
    return this.data.themes.filter((t) => ids.includes(t.id));
  },

  /* ---------------- hover tip ---------------- */

  getHoverTip() {
    let tip = this.el.querySelector("#rge-hover-tip");
    if (!tip) {
      tip = document.createElement("div");
      tip.id = "rge-hover-tip";
      tip.className = "rge-hover-tip";
      this.el.appendChild(tip);
    }
    return tip;
  },

  showHoverTip(ev, n) {
    const tip = this.getHoverTip();
    const themes = this.themeNamesFor(n.id);
    const snippet = (n.description || "").split(/\n+Sources:/)[0].slice(0, 220);
    tip.innerHTML = `
      <span class="rge-badge" style="background:${nodeColor(n)}">${isNote(n) ? "ai note" : n.node_type}</span>
      <span class="rge-badge" style="background:#555">${escapeHtml(partLabel(partOf(n)))}</span>
      <div class="tip-title">${escapeHtml(displayTitle(n))}</div>
      ${snippet ? `<div class="tip-desc">${escapeHtml(snippet)}${(n.description || "").length > 220 ? "…" : ""}</div>` : ""}
      ${themes.length ? `<div class="tip-themes">${themes.map((t) => `<span class="rge-badge" style="background:${t.color}">${escapeHtml(t.name)}</span>`).join("")}</div>` : ""}
    `;
    tip.style.display = "block";
    this.moveHoverTip(ev);
  },

  moveHoverTip(ev) {
    const tip = this.el.querySelector("#rge-hover-tip");
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
    const tip = this.el.querySelector("#rge-hover-tip");
    if (tip) tip.style.display = "none";
  },

  /* ---------------- inspector ---------------- */

  setupInspector() {
    this.el.querySelector("#rge-inspector-close").addEventListener("click", () => {
      this.el.querySelector("#rge-inspector").classList.remove("open");
      setQueryParam("node", null);
    });
    // Chat (bottom sheet on narrow/medium screens) and the inspector panel can
    // both be overlays fighting for the same space there — keep them mutually
    // exclusive below the width where chat stops being a side column.
    this.handleEvent("rooted-close-inspector", () => {
      if (window.innerWidth <= 1300) this.el.querySelector("#rge-inspector").classList.remove("open");
    });
  },

  closeChatIfNarrow() {
    if (window.innerWidth <= 1300) this.pushEvent("close_chat", this.currentUrlParams());
  },

  // What the server should preserve when it rewrites the URL for a view/chat
  // change — this client-side state isn't otherwise visible to it.
  currentUrlParams() {
    const p = new URL(window.location.href).searchParams;
    return { part: p.get("part"), mode: p.get("mode"), q: p.get("q"), node: p.get("node") };
  },

  // Nav buttons (Overview/Plot/.../Chat) are plain server-rendered phx-click
  // bindings outside this ignored subtree. Stamping phx-value-* here, in the
  // capture phase, runs before LiveView's own delegated click handling reads
  // them off the target — so set_view/toggle_chat see the current params.
  setupNavParamForwarding() {
    const nav = document.querySelector(".rg-nav");
    if (!nav || nav._rootedForwardSetup) return;
    nav._rootedForwardSetup = true;
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
    const body = this.el.querySelector("#rge-inspector-body");
    const themes = this.themeNamesFor(node.id);
    const incoming = this.data.edges
      .filter((e) => e.to_node_id === node.id)
      .map((e) => ({ edge: e, other: this.nodeById.get(e.from_node_id) }))
      .filter((r) => r.other);
    const outgoing = this.data.edges
      .filter((e) => e.from_node_id === node.id)
      .map((e) => ({ edge: e, other: this.nodeById.get(e.to_node_id) }))
      .filter((r) => r.other);
    const meta = (() => {
      try {
        return JSON.parse(node.metadata_json || "{}");
      } catch (e) {
        return {};
      }
    })();

    const rel = (r) =>
      `<a class="rel" data-id="${r.other.id}"><span class="rtype">${r.edge.edge_type}</span>${escapeHtml(displayTitle(r.other))}</a>`;

    body.innerHTML = `
      <span class="rge-badge" style="background:${nodeColor(node)}">${isNote(node) ? "ai note" : node.node_type}</span>
      <span class="rge-badge" style="background:#555">${escapeHtml(partLabel(partOf(node)))}</span>
      ${meta.confidence != null ? `<span class="rge-badge" style="background:#777">${meta.confidence}%</span>` : ""}
      <h3>${escapeHtml(displayTitle(node))}</h3>
      <div class="desc">${renderDesc(node.description)}</div>
      ${meta.prompt ? `<div class="rel-title">Originating prompt</div><div class="prompt">${escapeHtml(meta.prompt)}</div>` : ""}
      ${themes.length ? `<div class="rel-title">Themes</div>${themes.map((t) => `<span class="rge-badge" style="background:${t.color}">${escapeHtml(t.name)}</span>`).join("")}` : ""}
      ${outgoing.length ? `<div class="rel-title">Leads to</div>${outgoing.map(rel).join("")}` : ""}
      ${incoming.length ? `<div class="rel-title">Follows from</div>${incoming.map(rel).join("")}` : ""}
    `;

    body.querySelectorAll(".rel").forEach((el) => {
      el.addEventListener("click", () => {
        const n = this.nodeById.get(parseInt(el.dataset.id, 10));
        if (n) this.openInspectorForNode(n);
      });
    });

    this.el.querySelector("#rge-inspector").classList.add("open");
    setQueryParam("node", node.id);
    if (!this._restoring) this.closeChatIfNarrow();
    this.centerOnNode(node.id);
  },

  /* ---------------- overview ---------------- */

  renderOverview() {
    const wrap = this.el.querySelector("#rge-overview-content");
    const parts = {};
    this.data.nodes.forEach((n) => {
      const p = partOf(n);
      parts[p] = (parts[p] || 0) + 1;
    });
    const partKeys = Object.keys(parts).sort((a, b) => partRank(a) - partRank(b));
    const max = Math.max(...Object.values(parts), 1);
    const typeCounts = {};
    this.data.nodes.forEach((n) => (typeCounts[n.node_type] = (typeCounts[n.node_type] || 0) + 1));
    const noteCount = this.data.nodes.filter(isNote).length;

    wrap.innerHTML = `
      <h2>Method Graph</h2>
      <p style="color:var(--rg-ink-dim); font-size:.88rem; max-width:54ch">
        Every premise, choice, practice and claim in <em>The RootedInGood&trade; Method</em>, read
        chapter by chapter and wired into one graph — a goal opens onto options, an option is chosen,
        the choice becomes something a parent actually does, and doing it has an outcome. Pink nodes
        are commentary written on top of the book, not drawn from it.
      </p>
      <div class="rge-stats">
        <div class="rge-stat"><div class="n">${this.data.nodes.length}</div><div class="l">nodes</div></div>
        <div class="rge-stat"><div class="n">${this.data.edges.length}</div><div class="l">edges</div></div>
        <div class="rge-stat"><div class="n">${this.data.themes.length}</div><div class="l">themes</div></div>
        <div class="rge-stat"><div class="n">${noteCount}</div><div class="l">ai notes</div></div>
      </div>
      <div style="margin-bottom:1.4rem">
        ${Object.keys(NODE_COLORS)
          .filter((t) => typeCounts[t])
          .map((t) => `<span class="rge-badge" style="background:${NODE_COLORS[t]}">${t} · ${typeCounts[t]}</span>`)
          .join("")}
      </div>
      <h3 style="font-size:.8rem; text-transform:uppercase; letter-spacing:.05em; color:var(--rg-ink-dim)">The spine of the book</h3>
      <div class="rge-spine" id="rge-spine"></div>
      <h3 style="font-size:.8rem; text-transform:uppercase; letter-spacing:.05em; color:var(--rg-ink-dim); margin-top:1.4rem">By part</h3>
      <div id="rge-part-list"></div>
    `;

    const TYPE_ORDER = ["goal", "option", "decision", "action", "outcome", "observation"];
    const strip = wrap.querySelector("#rge-spine");
    const spineNodes = this.data.nodes
      .filter((n) => partOf(n) === "spine" && !isNote(n))
      .sort((a, b) => TYPE_ORDER.indexOf(a.node_type) - TYPE_ORDER.indexOf(b.node_type) || a.id - b.id);

    if (!spineNodes.length) {
      strip.innerHTML = '<div style="color:var(--rg-ink-dim); font-size:.82rem">No book-level spine in this export.</div>';
    } else {
      spineNodes.forEach((n) => {
        const step = document.createElement("div");
        step.className = "rge-step";
        step.innerHTML = `<div class="t" style="color:${nodeColor(n)}">${n.node_type}</div>${escapeHtml(n.title)}`;
        step.addEventListener("click", () => this.openInspectorForNode(n));
        strip.appendChild(step);
      });
    }

    const list = wrap.querySelector("#rge-part-list");
    partKeys.forEach((p) => {
      const row = document.createElement("div");
      row.className = "rge-part-row";
      row.innerHTML = `<span class="label">${escapeHtml(partLabel(p))}</span><span class="bar" style="width:${((parts[p] / max) * 220).toFixed(0)}px"></span><span class="count">${parts[p]}</span>`;
      row.addEventListener("click", () => {
        this.pushEvent("set_view", { view: "plot" });
        setTimeout(() => this.setPartFilter(p), 120);
      });
      list.appendChild(row);
    });
  },

  /* ---------------- themes ---------------- */

  renderThemes() {
    const wrap = this.el.querySelector("#rge-themes-content");
    wrap.innerHTML = "<h2>Themes</h2><p style='color:var(--rg-ink-dim); font-size:.86rem; max-width:54ch'>Convictions the method returns to across chapters. Click one to see every node carrying it.</p>";
    this.data.themes
      .slice()
      .sort(
        (a, b) =>
          this.data.node_themes.filter((nt) => nt.theme_id === b.id).length -
          this.data.node_themes.filter((nt) => nt.theme_id === a.id).length
      )
      .forEach((t) => {
        const count = this.data.node_themes.filter((nt) => nt.theme_id === t.id).length;
        const card = document.createElement("div");
        card.className = "rge-theme-card";
        card.style.borderLeftColor = t.color;
        card.innerHTML = `<h3>${escapeHtml(t.name)}</h3><p>${escapeHtml(t.description)}</p><div class="count">${count} node${count === 1 ? "" : "s"}</div>`;
        card.addEventListener("click", () => {
          this.pushEvent("set_view", { view: "search" });
          setTimeout(() => {
            const input = this.el.querySelector("#rge-search-input");
            input.value = t.name;
            this.runSearch(t.name);
          }, 120);
        });
        wrap.appendChild(card);
      });
  },

  /* ---------------- AI notes ---------------- */

  renderNotes() {
    const wrap = this.el.querySelector("#rge-notes-content");
    const notes = this.data.nodes.filter(isNote).sort((a, b) => a.id - b.id);
    wrap.innerHTML = `
      <h2>AI Notes</h2>
      <p style="color:var(--rg-ink-dim); font-size:.88rem; max-width:54ch">
        A commentary layer sitting on top of the book rather than inside it: unstated assumptions,
        gaps between chapters, places the advice could be misapplied, and strengths that are easy to
        miss. These are read off the book — they are not claims the book makes.
      </p>
      <div style="font-size:.72rem; color:var(--rg-ink-dim); margin-bottom:.8rem">${notes.length} notes</div>
    `;
    notes.forEach((n) => {
      const about = this.data.edges
        .filter((e) => e.from_node_id === n.id)
        .map((e) => this.nodeById.get(e.to_node_id))
        .filter(Boolean);
      const card = document.createElement("div");
      card.className = "rge-note-card";
      const body = (n.description || "").split(/\n+Sources:/)[0];
      card.innerHTML =
        `<h3>${escapeHtml(displayTitle(n))}</h3><p>${escapeHtml(body)}</p>` +
        (about.length
          ? `<div class="count">on: ${about.map((a) => escapeHtml(displayTitle(a))).join(" · ")}</div>`
          : "");
      card.addEventListener("click", () => this.openInspectorForNode(n));
      wrap.appendChild(card);
    });
  },

  /* ---------------- search ---------------- */

  setupSearch() {
    const input = this.el.querySelector("#rge-search-input");
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
    const wrap = this.el.querySelector("#rge-search-results");
    const terms = (q || "")
      .toLowerCase()
      .split(/[^a-z0-9]+/)
      .filter((t) => t.length >= 3);

    if (terms.length === 0) {
      wrap.innerHTML = '<div style="color:var(--rg-ink-dim); font-size:.85rem; padding:1rem 0">Type at least a few letters to search the manuscript.</div>';
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

    wrap.innerHTML = `<div style="font-size:.72rem; color:var(--rg-ink-dim); margin-bottom:.5rem">${scored.length} match${scored.length === 1 ? "" : "es"}</div>`;
    scored.forEach(({ n }) => {
      const card = document.createElement("div");
      card.className = "rge-result";
      const snippet = (n.description || "").split(/\n+Sources:/)[0].slice(0, 170);
      card.innerHTML =
        `<h4><span class="rge-badge" style="background:${nodeColor(n)}; font-size:.6rem">${isNote(n) ? "ai note" : n.node_type}</span> ${escapeHtml(displayTitle(n))}</h4>` +
        `<p>${escapeHtml(snippet)}${(n.description || "").length > 170 ? "…" : ""}</p>` +
        `<div class="where">${escapeHtml(partLabel(partOf(n)))}</div>`;
      card.addEventListener("click", () => this.openInspectorForNode(n));
      wrap.appendChild(card);
    });
  },

  /* ---------------- plot: shared ---------------- */

  setPartFilter(p) {
    this.plotPartFilter = this.plotPartFilter === p ? null : p;
    setQueryParam("part", this.plotPartFilter);
    this.el.querySelectorAll("#rge-plot-chips .rge-chip").forEach((chip) => {
      chip.classList.toggle("on", chip.dataset.part === this.plotPartFilter);
    });
    d3.select(this.el)
      .selectAll("#rge-plot-svg .rge-node")
      .style("opacity", (d) => (this.plotPartFilter && partOf(rawNode(d)) !== this.plotPartFilter ? 0.15 : 1));
    d3.select(this.el)
      .selectAll("#rge-plot-svg .rge-link")
      .style("opacity", (d) => {
        const s = rawNode(d.source),
          t = rawNode(d.target);
        if (!this.plotPartFilter) return this._plotMode === "tree" ? 1 : 0.55;
        return partOf(s) !== this.plotPartFilter && partOf(t) !== this.plotPartFilter
          ? 0.06
          : this._plotMode === "tree"
            ? 1
            : 0.55;
      });
  },

  renderPlot() {
    this.buildPartChips();
    this.buildPlotLegend();
    this.setupPlotModeToggle();
    this.setupZoomButtons();
    this.applyPlotMode(this._initialParams.mode === "force" ? "force" : "tree");
    if (this._initialParams.part) this.setPartFilter(this._initialParams.part);
  },

  buildPartChips() {
    const chips = this.el.querySelector("#rge-plot-chips");
    chips.innerHTML = "";
    [...new Set(this.data.nodes.map(partOf))]
      .sort((a, b) => partRank(a) - partRank(b))
      .forEach((p) => {
        const chip = document.createElement("span");
        chip.className = "rge-chip";
        chip.textContent = partLabel(p);
        chip.dataset.part = p;
        chip.addEventListener("click", () => this.setPartFilter(p));
        chips.appendChild(chip);
      });
  },

  buildPlotLegend() {
    const legend = this.el.querySelector("#rge-plot-legend");
    legend.innerHTML =
      Object.entries(NODE_COLORS)
        .map(([k, v]) => `<div class="row"><span class="sw" style="background:${v}"></span>${k}</div>`)
        .join("") +
      `<div class="row"><span class="sw" style="background:${CHOSEN_COLOR}"></span>option (chosen)</div>
       <div class="row"><span class="sw" style="background:${NOTE_COLOR}"></span>AI note</div>
       <div class="row" style="margin-top:.3rem; font-weight:700">Lines (Tree view)</div>
       <div class="row">colored line = a branch/lane, not a verdict</div>
       <div class="row"><span class="sw bar" style="background:#9a2b1f; opacity:.5"></span>requires (cross-ref)</div>
       <div class="row" style="margin-top:.3rem; font-weight:700">Lines (Force view)</div>
       <div class="row"><span class="sw bar" style="background:${CHOSEN_COLOR}"></span>chosen</div>
       <div class="row"><span class="sw bar" style="background:#94a3b8"></span>rejected</div>`;
  },

  setupPlotModeToggle() {
    if (this._modeSetup) return;
    this._modeSetup = true;
    const wrap = this.el.querySelector("#rge-plot-mode");
    ["tree", "force"].forEach((m) => {
      const chip = document.createElement("span");
      chip.className = "rge-chip";
      chip.textContent = m === "tree" ? "Tree" : "Force";
      chip.dataset.mode = m;
      chip.addEventListener("click", () => this.applyPlotMode(m));
      wrap.appendChild(chip);
    });
  },

  setupZoomButtons() {
    if (this._zoomSetup) return;
    this._zoomSetup = true;
    this.el.querySelector("#rge-zoom-out").addEventListener("click", () => this.zoomBy(0.8));
    this.el.querySelector("#rge-zoom-in").addEventListener("click", () => this.zoomBy(1.25));
    this.el.querySelector("#rge-zoom-reset").addEventListener("click", () => this.zoomReset());
  },

  applyPlotMode(mode) {
    this._plotMode = mode;
    setQueryParam("mode", mode === "force" ? "force" : null);
    this.el.querySelectorAll("#rge-plot-mode .rge-chip").forEach((c) => c.classList.toggle("on", c.dataset.mode === mode));
    this.plotPartFilter = null;
    this.el.querySelectorAll("#rge-plot-chips .rge-chip").forEach((c) => c.classList.remove("on"));
    if (mode === "tree") this.renderPlotTree();
    else this.renderPlotForce();
  },

  /* ---------------- plot: tree (git log --graph) ---------------- */

  // One row per node, a dot in a narrow lane column, the node's title as
  // inline text beside it — the "trunk" (each node's first child) runs
  // straight down a lane; every other child branches off into a fresh lane
  // exactly where it diverges, like `git log --graph`.
  renderPlotTree() {
    const svgEl = this.el.querySelector("#rge-plot-svg");
    const holder = this.el.querySelector(".rge-svg-holder");
    const svg = d3.select(svgEl);
    svg.selectAll("*").remove();

    holder.classList.add("tree-scroll");
    svgEl.removeAttribute("style");
    this.setupPinchZoom(holder);
    this.setupDragPan(holder);

    const nodeById = this.nodeById;

    // `requires` edges are cross-references, not parentage — they'd otherwise
    // yank a node out of the lesson it belongs to. The first remaining edge
    // into a node (by edge id, i.e. creation order) is its parent; any extra
    // incoming edge is drawn as a secondary cross-link instead.
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
        if (rowOf.has(id)) return; // guard: a cycle would otherwise spin here
        rowOf.set(id, rowCounter++);
        laneOf.set(id, lane);
        const kids = (childIds.get(id) || []).filter((k) => !rowOf.has(k));
        if (kids.length === 0) {
          id = null;
        } else {
          for (let i = 1; i < kids.length; i++) walk(kids[i], nextLane++);
          id = kids[0];
        }
      }
    };
    roots.forEach((r) => walk(r.id, nextLane++));
    // Anything left unvisited (only reachable through a cycle) still gets a row.
    this.data.nodes.forEach((n) => {
      if (!rowOf.has(n.id)) walk(n.id, nextLane++);
    });

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

    const contentW = xOf(laneCap) + gapAfterLanes + 560;
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
      if (!parentNode || !rowOf.has(pid)) return;
      kids.forEach((cid) => {
        if (rowOf.has(cid)) links.push({ source: parentNode, target: nodeById.get(cid), lane: laneOf.get(cid) });
      });
    });

    g.append("g")
      .selectAll("path.rge-link")
      .data(links)
      .join("path")
      .attr("class", "rge-link")
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
      .selectAll("path.rge-req")
      .data(secondary.filter((e) => rowOf.has(e.from_node_id) && rowOf.has(e.to_node_id)))
      .join("path")
      .attr("class", "rge-req")
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
      .selectAll("g.rge-node")
      .data(this.data.nodes.filter((n) => rowOf.has(n.id)))
      .join("g")
      .attr("class", "rge-node")
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
      .attr("class", "rge-node-label")
      .attr("x", (n) => xOf(laneOf.get(n.id)) + gapAfterLanes)
      .attr("y", 3)
      .attr("text-anchor", "start")
      .text((n) => {
        const t = displayTitle(n);
        return t.length > 78 ? t.slice(0, 78) + "…" : t;
      });
  },

  /* ---------------- plot: force ---------------- */

  renderPlotForce() {
    const svgEl = this.el.querySelector("#rge-plot-svg");
    const holder = this.el.querySelector(".rge-svg-holder");
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

    const zoom = d3.zoom().scaleExtent([0.15, 4]).on("zoom", (ev) => g.attr("transform", ev.transform));
    svg.call(zoom);
    this._forceZoomSel = svg;
    this._forceZoomBehavior = zoom;

    // Anchor each part of the book to its own spot on a ring (the spine in
    // the middle) so the lessons read as clusters instead of one hairball.
    const ringParts = [...new Set(nodes.map(partOf))].sort((a, b) => partRank(a) - partRank(b));
    const spokes = ringParts.filter((p) => p !== "spine" && p !== "book");
    const R = Math.min(width, height) * 0.36;
    const anchor = new Map();
    ringParts.forEach((p) => {
      if (p === "spine" || p === "book") {
        anchor.set(p, [width / 2, height / 2]);
        return;
      }
      const a = (spokes.indexOf(p) / Math.max(1, spokes.length)) * 2 * Math.PI - Math.PI / 2;
      anchor.set(p, [width / 2 + R * Math.cos(a), height / 2 + R * Math.sin(a)]);
    });
    const ax = (d) => (anchor.get(partOf(d)) || [width / 2, height / 2])[0];
    const ay = (d) => (anchor.get(partOf(d)) || [width / 2, height / 2])[1];

    const sim = d3
      .forceSimulation(nodes)
      .force("link", d3.forceLink(links).id((d) => d.id).distance((d) => (d.edge_type === "requires" ? 110 : 70)).strength(0.25))
      .force("charge", d3.forceManyBody().strength(-260).distanceMax(500))
      .force("x", d3.forceX(ax).strength(0.16))
      .force("y", d3.forceY(ay).strength(0.16))
      .force("collide", d3.forceCollide(26));

    const link = g
      .append("g")
      .selectAll("line")
      .data(links)
      .join("line")
      .attr("class", "rge-link")
      .attr("stroke", (d) =>
        d.edge_type === "rejected" ? "#94a3b8" : d.edge_type === "chosen" ? CHOSEN_COLOR : d.edge_type === "requires" ? "#9a2b1f" : "#9a8f78"
      )
      .attr("stroke-width", 1.3)
      .attr("stroke-dasharray", (d) => (d.edge_type === "rejected" ? "2,3" : d.edge_type === "requires" ? "1,4" : null));

    const degree = new Map();
    links.forEach((l) => {
      degree.set(l.source, (degree.get(l.source) || 0) + 1);
      degree.set(l.target, (degree.get(l.target) || 0) + 1);
    });

    const node = g
      .append("g")
      .selectAll("g")
      .data(nodes)
      .join("g")
      .attr("class", "rge-node")
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
      .attr("r", (d) => 4.5 + Math.min(7, degree.get(d.id) || 0))
      .attr("fill", (d) => nodeColor(d))
      .style("cursor", "pointer")
      .on("click", (ev, d) => {
        ev.stopPropagation();
        this.hideHoverTip();
        this.openInspectorForNode(this.nodeById.get(d.id));
      })
      .on("mouseenter", (ev, d) => this.showHoverTip(ev, d))
      .on("mousemove", (ev) => this.moveHoverTip(ev))
      .on("mouseleave", () => this.hideHoverTip());

    // Hundreds of labels at once is unreadable; label the hubs and reveal the rest on hover.
    node
      .append("text")
      .attr("class", "rge-node-label")
      .attr("dy", -11)
      .attr("text-anchor", "middle")
      .style("pointer-events", "none")
      .attr("opacity", (d) => ((degree.get(d.id) || 0) >= 6 ? 1 : 0))
      .text((d) => {
        const t = displayTitle(d);
        return t.length > 38 ? t.slice(0, 38) + "…" : t;
      });
    node
      .on("mouseenter.label", function () {
        d3.select(this).select("text").attr("opacity", 1);
      })
      .on("mouseleave.label", function (ev, d) {
        if ((degree.get(d.id) || 0) < 6) d3.select(this).select("text").attr("opacity", 0);
      });

    const paint = () => {
      link.attr("x1", (d) => d.source.x).attr("y1", (d) => d.source.y).attr("x2", (d) => d.target.x).attr("y2", (d) => d.target.y);
      node.attr("transform", (d) => `translate(${d.x},${d.y})`);
    };
    sim.on("tick", paint);

    // Run the layout to convergence up front rather than animating 329 nodes
    // out of a random start; dragging a node restarts the simulation.
    sim.stop();
    for (let i = 0; i < 320; i++) sim.tick();
    paint();

    const xs = nodes.map((n) => n.x),
      ys = nodes.map((n) => n.y);
    const x0 = Math.min(...xs),
      x1 = Math.max(...xs),
      y0 = Math.min(...ys),
      y1 = Math.max(...ys);
    const pad = 60;
    const k = Math.min(3, Math.max(0.15, Math.min((width - pad * 2) / Math.max(1, x1 - x0), (height - pad * 2) / Math.max(1, y1 - y0))));
    svg.call(zoom.transform, d3.zoomIdentity.translate(width / 2 - (k * (x0 + x1)) / 2, height / 2 - (k * (y0 + y1)) / 2).scale(k));
  },

  /* ---------------- zoom / pan ---------------- */

  centerOnNode(nodeId) {
    if (this._plotMode === "tree") this.centerTreeOn(nodeId);
    else this.centerForceOn(nodeId);
  },

  centerTreeOn(nodeId) {
    const holder = this.el.querySelector(".rge-svg-holder");
    const pos = this._treeNodePos && this._treeNodePos.get(nodeId);
    if (!holder || !pos || !holder.classList.contains("tree-scroll")) return;
    const scale = (this._treeBaseScale || 1) * (this._treeZoom || 1);
    holder.scrollTop = Math.max(0, pos.y * scale - holder.clientHeight / 2);
    holder.scrollLeft = Math.max(0, pos.x * scale - holder.clientWidth / 3);
  },

  centerForceOn(nodeId) {
    const n = this._forceNodesById && this._forceNodesById.get(nodeId);
    const svgEl = this.el.querySelector("#rge-plot-svg");
    if (!n || !svgEl || !this._forceZoomSel || !this._forceZoomBehavior) return;
    const w = svgEl.clientWidth || 800,
      h = svgEl.clientHeight || 600;
    const t = d3.zoomIdentity.translate(w / 2, h / 2).scale(1.5).translate(-n.x, -n.y);
    this._forceZoomSel.transition().duration(500).call(this._forceZoomBehavior.transform, t);
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
    const holder = this.el.querySelector(".rge-svg-holder");
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
    const svgEl = this.el.querySelector("#rge-plot-svg");
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
    if (holder._rootedPinchSetup) return;
    holder._rootedPinchSetup = true;
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
    if (holder._rootedDragSetup) return;
    holder._rootedDragSetup = true;
    let dragging = false,
      startX = 0,
      startY = 0,
      startLeft = 0,
      startTop = 0;

    holder.addEventListener("mousedown", (e) => {
      if (e.target.closest(".rge-node") || e.button !== 0) return;
      dragging = true;
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
      holder.scrollLeft = startLeft - (e.clientX - startX);
      holder.scrollTop = startTop - (e.clientY - startY);
    });

    window.addEventListener("mouseup", () => {
      if (!dragging) return;
      dragging = false;
      holder.style.cursor = "";
      document.body.style.userSelect = "";
    });
  },
};

export default RootedApp;
