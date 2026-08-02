import * as d3 from "d3";

// Era palette — CVD-validated (see scripts/build_phish_lab_data.py page).
// Fixed assignment order; never cycled.
const ERA_ORDER = ["1.0", "2.0", "3.0", "4.0"];
const ERA_COLORS = {
  "1.0": "#3355cc",
  "2.0": "#cc6600",
  "3.0": "#00998f",
  "4.0": "#aa3377",
};
const DEFAULT_COLOR = "#3a5fbf";
const NULL_COLOR = "#c8c8c8";
const HIGHLIGHT_FILL = "#ffd400";
const seqRamp = d3.interpolateRgb("#dbe4f7", "#16265c");

function eraOf(dateStr) {
  if (dateStr <= "2000-10-07") return "1.0";
  if (dateStr <= "2004-08-15") return "2.0";
  if (dateStr <= "2020-02-23") return "3.0";
  return "4.0";
}

function fmtSec(s) {
  s = Math.round(s);
  const m = Math.floor(s / 60);
  return `${m}:${String(s % 60).padStart(2, "0")}`;
}

function fmtVal(v, fmt) {
  if (v == null) return "—";
  if (v instanceof Date) return d3.timeFormat("%Y-%m-%d")(v);
  switch (fmt) {
    case "sec":
      return fmtSec(v);
    case "sigma":
      return `${v > 0 ? "+" : ""}${(+v).toFixed(1)}σ`;
    case "days":
      return v >= 365 ? `${(v / 365).toFixed(1)}y` : `${v}d`;
    case "date":
      return String(v);
    default:
      return typeof v === "number" ? +(+v).toFixed(3) + "" : String(v);
  }
}

function tickFormatter(fmt, scale) {
  if (fmt === "date") return null; // d3's time formatter is fine
  if (fmt === "sec") return (v) => fmtSec(v);
  if (fmt === "sigma") return (v) => `${v > 0 ? "+" : ""}${v}σ`;
  if (fmt === "days") return (v) => (v >= 365 ? `${Math.round(v / 365)}y` : `${v}d`);
  return scale.tickFormat ? scale.tickFormat() : (v) => v;
}

const PhishLab = {
  mounted() {
    this.stage = this.el.querySelector(".plab-stage");
    this.legendEl = this.el.querySelector(".plab-legend");

    this.svg = d3
      .select(this.stage)
      .append("svg")
      .attr("class", "plab-axes")
      .style("font-family", '"MS Sans Serif", "Tahoma", sans-serif');

    this.canvas = document.createElement("canvas");
    this.canvas.style.top = "0";
    this.canvas.style.left = "0";
    this.stage.appendChild(this.canvas);

    this.tooltip = document.createElement("div");
    this.tooltip.className = "plab-tooltip";
    document.body.appendChild(this.tooltip);

    this.cache = {};
    this.cfg = null;
    this.hiddenEras = new Set();
    this.hover = null;

    this.canvas.addEventListener("mousemove", (e) => this.onMove(e));
    this.canvas.addEventListener("mouseleave", () => this.hideTooltip());
    this.canvas.addEventListener("click", (e) => this.onClick(e));

    this.resizer = new ResizeObserver(() => {
      cancelAnimationFrame(this._raf);
      this._raf = requestAnimationFrame(() => this.render());
    });
    this.resizer.observe(this.el);

    this.handleEvent("lab:config", (cfg) => {
      this.cfg = cfg;
      this.hiddenEras.clear();
      this.load(cfg.ds).then(() => this.render());
    });

    this.pushEvent("chart-mounted", {});
  },

  destroyed() {
    this.tooltip?.remove();
    this.resizer?.disconnect();
  },

  load(ds) {
    if (ds === "perfs") {
      this.cache.perfsP ||= fetch("/data/phish_lab_perfs.json")
        .then((r) => r.json())
        .then((j) => {
          this.cache.perfs = j.perfs.map((p, i) => ({ ...p, __i: i }));
        });
      return this.cache.perfsP;
    }
    this.cache.mainP ||= fetch("/data/phish_lab.json")
      .then((r) => r.json())
      .then((j) => {
        this.cache.shows = j.shows;
        this.cache.songs = j.songs;
      });
    return this.cache.mainP;
  },

  rows() {
    return this.cache[this.cfg.ds] || [];
  },

  value(row, axis) {
    const k = axis.key;
    if (k === "none") return null;
    if (k === "era") return eraOf(row.d || row.first);
    if (k.startsWith("style:")) return row.styles ? row.styles[k.slice(6)] : null;
    if (axis.fmt === "date") {
      const v = row[k];
      return v ? d3.timeParse("%Y-%m-%d")(v) : null;
    }
    return row[k];
  },

  keyOf(row) {
    const ds = this.cfg.ds;
    if (ds === "shows") return row.d;
    if (ds === "songs") return row.s;
    return row.__i;
  },

  titleOf(row) {
    const ds = this.cfg.ds;
    if (ds === "shows") return `${row.d} — ${row.venue || ""}`;
    if (ds === "songs") return row.s;
    return `${row.s} — ${row.d}`;
  },

  isHighlighted(row) {
    const h = this.cfg.highlight;
    if (!h || (!h.d && !h.s)) return false;
    const ds = this.cfg.ds;
    if (ds === "shows") return row.d === h.d;
    if (ds === "songs") return row.s === h.s;
    return (!h.d || row.d === h.d) && (!h.s || row.s === h.s);
  },

  // ------------------------------------------------------------------ render

  render() {
    if (!this.cfg || !this.stage.clientWidth) return;
    const cfg = this.cfg;
    const isHist = cfg.chart === "hist";
    const width = Math.max(320, this.el.clientWidth);
    const height = Math.max(300, Math.min(500, Math.round(width * 0.52)));
    const m = { top: 16, right: 20, bottom: 46, left: 66 };
    const dpr = window.devicePixelRatio || 1;

    this.svg.attr("width", width).attr("height", height).selectAll("*").remove();
    this.canvas.width = width * dpr;
    this.canvas.height = height * dpr;
    this.canvas.style.width = `${width}px`;
    this.canvas.style.height = `${height}px`;
    const ctx = this.canvas.getContext("2d");
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, width, height);

    const logOk = (v) => v != null && v > 0;
    const xa = cfg.x;
    const ya = cfg.y;
    const useLogX = cfg.logx && xa.fmt !== "date";
    const useLogY = cfg.logy && ya.fmt !== "date";

    let rows = this.rows().filter((r) => {
      const xv = this.value(r, xa);
      if (xv == null || (useLogX && !logOk(xv))) return false;
      if (!isHist) {
        const yv = this.value(r, ya);
        if (yv == null || (useLogY && !logOk(yv))) return false;
      }
      if (this.hiddenEras.size && cfg.color.key === "era" && this.hiddenEras.has(eraOf(r.d || r.first))) return false;
      return true;
    });

    const total = this.rows().length;
    if (isHist) this.renderHist(ctx, rows, width, height, m, useLogX);
    else this.renderScatter(ctx, rows, width, height, m, useLogX, useLogY);

    const statusEl = document.getElementById("plab-status-n");
    if (statusEl) {
      const noun = { shows: "shows", songs: "songs", perfs: "performances" }[cfg.ds];
      const dropped = total - rows.length - (this.hiddenEras.size ? 0 : 0);
      statusEl.textContent =
        `${rows.length.toLocaleString()} ${noun} plotted` +
        (rows.length < total ? ` (${(total - rows.length).toLocaleString()} lack data for these axes)` : "");
    }
  },

  makeScale(axis, useLog, domainValues, range) {
    if (axis.fmt === "date") {
      return d3.scaleTime().domain(d3.extent(domainValues)).range(range).nice();
    }
    const ext = d3.extent(domainValues);
    if (useLog) return d3.scaleLog().domain(ext).range(range).nice();
    const pad = (ext[1] - ext[0] || 1) * 0.04;
    return d3.scaleLinear().domain([ext[0] - pad, ext[1] + pad]).range(range).nice();
  },

  drawAxes(x, y, xa, ya, width, height, m, yLabel) {
    const gGrid = this.svg.append("g");
    gGrid
      .selectAll("line")
      .data(y.ticks(6))
      .join("line")
      .attr("x1", m.left)
      .attr("x2", width - m.right)
      .attr("y1", (d) => y(d))
      .attr("y2", (d) => y(d))
      .attr("stroke", "#e4e4e4");

    const xAxis = d3.axisBottom(x).ticks(Math.min(10, Math.floor(width / 90)));
    const xFmt = tickFormatter(xa.fmt, x);
    if (xFmt) xAxis.tickFormat(xFmt);
    const yAxis = d3.axisLeft(y).ticks(6);
    const yFmt = tickFormatter(ya ? ya.fmt : "num", y);
    if (yFmt && ya) yAxis.tickFormat(yFmt);

    const gx = this.svg.append("g").attr("transform", `translate(0,${height - m.bottom})`).call(xAxis);
    const gy = this.svg.append("g").attr("transform", `translate(${m.left},0)`).call(yAxis);
    for (const g of [gx, gy]) {
      g.selectAll("text").style("font-size", "10px").style("fill", "#333");
      g.selectAll("line,path").attr("stroke", "#888");
    }

    this.svg
      .append("text")
      .attr("x", m.left + (width - m.left - m.right) / 2)
      .attr("y", height - 8)
      .attr("text-anchor", "middle")
      .style("font-size", "10px")
      .style("fill", "#000")
      .text(xa.label);

    this.svg
      .append("text")
      .attr("transform", `translate(12,${m.top + (height - m.top - m.bottom) / 2}) rotate(-90)`)
      .attr("text-anchor", "middle")
      .style("font-size", "10px")
      .style("fill", "#000")
      .text(yLabel);
  },

  renderScatter(ctx, rows, width, height, m, useLogX, useLogY) {
    const cfg = this.cfg;
    const xa = cfg.x;
    const ya = cfg.y;
    const x = this.makeScale(xa, useLogX, rows.map((r) => this.value(r, xa)), [m.left, width - m.right]);
    const y = this.makeScale(ya, useLogY, rows.map((r) => this.value(r, ya)), [height - m.bottom, m.top]);
    this.drawAxes(x, y, xa, ya, width, height, m, ya.label);

    // color
    const ca = cfg.color;
    let colorOf = () => DEFAULT_COLOR;
    let colorExt = null;
    if (ca.key === "era") {
      colorOf = (r) => ERA_COLORS[eraOf(r.d || r.first)] || DEFAULT_COLOR;
    } else if (ca.key !== "none") {
      const vals = rows.map((r) => this.value(r, ca)).filter((v) => v != null && !(v instanceof Date));
      if (vals.length) {
        colorExt = d3.extent(vals);
        const cs = d3.scaleSequential(seqRamp).domain(colorExt);
        colorOf = (r) => {
          const v = this.value(r, ca);
          return v == null ? NULL_COLOR : cs(v);
        };
      }
    }

    // size
    const sa = cfg.size;
    const n = rows.length;
    const baseR = n > 5000 ? 2 : n > 1000 ? 2.6 : 3.6;
    let rOf = () => baseR;
    if (sa.key !== "none") {
      const vals = rows.map((r) => this.value(r, sa)).filter((v) => v != null);
      if (vals.length) {
        const rs = d3.scaleSqrt().domain(d3.extent(vals)).range([1.8, Math.max(6, baseR * 2.6)]);
        rOf = (r) => {
          const v = this.value(r, sa);
          return v == null ? 1.5 : rs(v);
        };
      }
    }

    ctx.globalAlpha = n > 5000 ? 0.55 : n > 1000 ? 0.75 : 0.9;
    const pts = [];
    const highlights = [];
    for (const r of rows) {
      const px = x(this.value(r, xa));
      const py = y(this.value(r, ya));
      const pr = rOf(r);
      pts.push({ px, py, r, pr });
      if (this.isHighlighted(r)) {
        highlights.push({ px, py, pr });
        continue;
      }
      ctx.beginPath();
      ctx.arc(px, py, pr, 0, Math.PI * 2);
      ctx.fillStyle = colorOf(r);
      ctx.fill();
      ctx.lineWidth = 0.6;
      ctx.strokeStyle = "rgba(255,255,255,0.9)";
      ctx.stroke();
    }

    // highlighted marks: yellow fill, dashed black ring, drawn on top
    ctx.globalAlpha = 1;
    for (const h of highlights) {
      ctx.beginPath();
      ctx.arc(h.px, h.py, Math.max(h.pr, 4), 0, Math.PI * 2);
      ctx.fillStyle = HIGHLIGHT_FILL;
      ctx.fill();
      ctx.lineWidth = 1.4;
      ctx.strokeStyle = "#000";
      ctx.stroke();
      ctx.setLineDash([3, 2]);
      ctx.beginPath();
      ctx.arc(h.px, h.py, Math.max(h.pr, 4) + 5, 0, Math.PI * 2);
      ctx.stroke();
      ctx.setLineDash([]);
    }

    this.quadtree = d3
      .quadtree()
      .x((p) => p.px)
      .y((p) => p.py)
      .addAll(pts);
    this.hist = null;
    this.renderLegend(colorExt);
  },

  renderHist(ctx, rows, width, height, m, useLogX) {
    const cfg = this.cfg;
    const xa = cfg.x;
    const vals = rows.map((r) => this.value(r, xa)).filter((v) => v != null);
    const x = this.makeScale(xa, useLogX, vals, [m.left, width - m.right]);
    const bin = d3
      .bin()
      .domain(x.domain())
      .thresholds(x.ticks(Math.min(40, Math.max(12, Math.floor(width / 24)))));
    const bins = bin(vals);
    const y = d3
      .scaleLinear()
      .domain([0, d3.max(bins, (b) => b.length) || 1])
      .range([height - m.bottom, m.top])
      .nice();
    this.drawAxes(x, y, xa, null, width, height, m, "count");

    // win95 dither fill
    const pat = document.createElement("canvas");
    pat.width = pat.height = 4;
    const pctx = pat.getContext("2d");
    pctx.fillStyle = "#1084d0";
    pctx.fillRect(0, 0, 4, 4);
    pctx.fillStyle = "#000080";
    pctx.fillRect(0, 0, 2, 2);
    pctx.fillRect(2, 2, 2, 2);
    const pattern = ctx.createPattern(pat, "repeat");

    this.hist = { bins, x, y, baseY: height - m.bottom };
    ctx.globalAlpha = 1;
    for (const b of bins) {
      const bx = x(b.x0) + 1;
      const bw = Math.max(1, x(b.x1) - x(b.x0) - 2);
      const by = y(b.length);
      const bh = height - m.bottom - by;
      if (bh <= 0) continue;
      ctx.beginPath();
      if (ctx.roundRect) ctx.roundRect(bx, by, bw, bh, [2, 2, 0, 0]);
      else ctx.rect(bx, by, bw, bh);
      ctx.fillStyle = pattern;
      ctx.fill();
      ctx.strokeStyle = "#000080";
      ctx.lineWidth = 0.75;
      ctx.stroke();
    }
    this.quadtree = null;
    this.renderLegend(null);
  },

  renderLegend(colorExt) {
    const cfg = this.cfg;
    const el = this.legendEl;
    el.innerHTML = "";
    if (cfg.chart === "hist") {
      el.innerHTML = `<span>distribution of <b>${cfg.x.label}</b></span>`;
      return;
    }
    if (cfg.color.key === "era") {
      for (const era of ERA_ORDER) {
        const chip = document.createElement("button");
        chip.type = "button";
        chip.className = "plab-legend-chip";
        chip.dataset.off = this.hiddenEras.has(era) ? "1" : "";
        chip.innerHTML = `<span class="plab-legend-swatch" style="background:${ERA_COLORS[era]}"></span>${era}`;
        chip.title = `toggle era ${era}`;
        chip.addEventListener("click", () => {
          this.hiddenEras.has(era) ? this.hiddenEras.delete(era) : this.hiddenEras.add(era);
          this.render();
        });
        el.appendChild(chip);
      }
    } else if (cfg.color.key !== "none" && colorExt) {
      const span = document.createElement("span");
      span.style.display = "inline-flex";
      span.style.alignItems = "center";
      span.style.gap = "5px";
      span.innerHTML =
        `${fmtVal(colorExt[0], cfg.color.fmt)} ` +
        `<span class="plab-legend-grad" style="background:linear-gradient(90deg, #dbe4f7, #16265c)"></span>` +
        ` ${fmtVal(colorExt[1], cfg.color.fmt)} — ${cfg.color.label}`;
      el.appendChild(span);
    }
    if (cfg.size.key !== "none") {
      const s = document.createElement("span");
      s.textContent = `⌀ sized by ${cfg.size.label}`;
      el.appendChild(s);
    }
  },

  // ------------------------------------------------------------- interaction

  pick(e) {
    const rect = this.canvas.getBoundingClientRect();
    const mx = e.clientX - rect.left;
    const my = e.clientY - rect.top;
    if (this.quadtree) {
      const p = this.quadtree.find(mx, my, 14);
      return p ? { kind: "point", p } : null;
    }
    if (this.hist) {
      const { bins, x, y } = this.hist;
      for (const b of bins) {
        if (mx >= x(b.x0) && mx <= x(b.x1) && my >= y(b.length) && my <= this.hist.baseY) {
          return { kind: "bin", b };
        }
      }
    }
    return null;
  },

  onMove(e) {
    const hit = this.pick(e);
    if (!hit) {
      this.hideTooltip();
      this.canvas.style.cursor = "default";
      return;
    }
    this.canvas.style.cursor = "pointer";
    const cfg = this.cfg;
    let html;
    if (hit.kind === "point") {
      const r = hit.p.r;
      const lines = [
        `${cfg.x.label}: ${fmtVal(this.value(r, cfg.x), cfg.x.fmt)}`,
        `${cfg.y.label}: ${fmtVal(this.value(r, cfg.y), cfg.y.fmt)}`,
      ];
      if (cfg.color.key !== "none" && cfg.color.key !== "era")
        lines.push(`${cfg.color.label}: ${fmtVal(this.value(r, cfg.color), cfg.color.fmt)}`);
      if (cfg.size.key !== "none" && cfg.size.key !== cfg.color.key)
        lines.push(`${cfg.size.label}: ${fmtVal(this.value(r, cfg.size), cfg.size.fmt)}`);
      html = `<b>${this.titleOf(r)}</b>${lines.join("<br>")}`;
    } else {
      const b = hit.b;
      html = `<b>${fmtVal(b.x0, cfg.x.fmt)} – ${fmtVal(b.x1, cfg.x.fmt)}</b>${b.length} in bin`;
    }
    this.tooltip.innerHTML = html;
    this.tooltip.style.display = "block";
    const tw = this.tooltip.offsetWidth;
    const left = Math.min(e.clientX + 14, window.innerWidth - tw - 8);
    this.tooltip.style.left = `${left}px`;
    this.tooltip.style.top = `${e.clientY + 14}px`;
  },

  hideTooltip() {
    this.tooltip.style.display = "none";
  },

  onClick(e) {
    const hit = this.pick(e);
    if (hit?.kind === "point") {
      this.pushEvent("inspect", { ds: this.cfg.ds, key: this.keyOf(hit.p.r) });
    }
  },
};

export default PhishLab;
