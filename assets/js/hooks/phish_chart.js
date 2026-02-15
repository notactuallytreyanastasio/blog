import * as d3 from "d3";

function esc(s) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function fmtDuration(ms) {
  if (ms <= 0) return "?";
  const m = Math.floor(ms / 60000);
  const s = Math.floor((ms % 60000) / 1000);
  return `${m}:${String(s).padStart(2, "0")}`;
}

const PhishChart = {
  mounted() {
    // Create tooltip
    this.tooltip = document.createElement("div");
    this.tooltip.className = "phish-tooltip";
    this.tooltip.style.display = "none";
    document.body.appendChild(this.tooltip);

    // Create modal container
    this.modal = document.createElement("div");
    this.modal.className = "phish-modal-overlay";
    this.modal.style.display = "none";
    document.body.appendChild(this.modal);
    this.modal.addEventListener("click", (e) => {
      if (e.target === this.modal) this.modal.style.display = "none";
    });

    this.handleEvent("song-data", (data) => this.renderChart(data));

    // Signal to server that hook is ready for data
    this.pushEvent("chart-mounted", {});
  },

  destroyed() {
    if (this.tooltip) this.tooltip.remove();
    if (this.modal) this.modal.remove();
  },

  renderChart({ song_name, tracks }) {
    const svg = d3.select(this.el).select("svg");
    svg.selectAll("*").remove();

    const validTracks = tracks.filter((t) => t.duration_ms > 0);
    if (validTracks.length === 0) {
      svg.attr("width", 960).attr("height", 100);
      svg
        .append("text")
        .attr("x", 480)
        .attr("y", 50)
        .attr("text-anchor", "middle")
        .style("fill", "#666")
        .style("font-size", "12px")
        .style("font-family", '"Chicago", "Geneva", "Helvetica", sans-serif')
        .text("No duration data available for this song");
      return;
    }

    const margin = { top: 60, right: 50, bottom: 100, left: 70 };
    const width = 960;
    const height = 520;

    svg
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", `0 0 ${width} ${height}`)
      .style("background", "#fff")
      .style("border", "1px solid #000");

    const parseDate = d3.timeParse("%Y-%m-%d");
    const durations = validTracks.map((t) => t.duration_ms / 60000);

    const x = d3
      .scaleTime()
      .domain(d3.extent(validTracks, (t) => parseDate(t.show_date)))
      .range([margin.left, width - margin.right]);

    const maxDur = d3.max(durations) || 30;
    const y = d3
      .scaleLinear()
      .domain([0, Math.ceil(maxDur / 5) * 5 + 5])
      .range([height - margin.bottom, margin.top]);

    const defs = svg.append("defs");

    // Grid lines
    svg
      .selectAll(".grid-line")
      .data(y.ticks(8))
      .join("line")
      .attr("x1", margin.left)
      .attr("x2", width - margin.right)
      .attr("y1", (d) => y(d))
      .attr("y2", (d) => y(d))
      .attr("stroke", "#ccc")
      .attr("stroke-width", 0.5);

    // Area
    const areaGen = d3
      .area()
      .x((t) => x(parseDate(t.show_date)))
      .y0(height - margin.bottom)
      .y1((t) => y(t.duration_ms / 60000))
      .curve(d3.curveMonotoneX);

    const areaGrad = defs
      .append("linearGradient")
      .attr("id", "area-grad")
      .attr("x1", "0%")
      .attr("y1", "0%")
      .attr("x2", "0%")
      .attr("y2", "100%");
    areaGrad
      .append("stop")
      .attr("offset", "0%")
      .attr("stop-color", "#ef4444")
      .attr("stop-opacity", 0.2);
    areaGrad
      .append("stop")
      .attr("offset", "100%")
      .attr("stop-color", "#ef4444")
      .attr("stop-opacity", 0.02);

    svg
      .append("path")
      .datum(validTracks)
      .attr("d", areaGen)
      .attr("fill", "url(#area-grad)");

    // Line
    const lineGen = d3
      .line()
      .x((t) => x(parseDate(t.show_date)))
      .y((t) => y(t.duration_ms / 60000))
      .curve(d3.curveMonotoneX);

    svg
      .append("path")
      .datum(validTracks)
      .attr("d", lineGen)
      .attr("fill", "none")
      .attr("stroke", "#ef4444")
      .attr("stroke-width", 2)
      .attr("stroke-linejoin", "round");

    // Dots
    svg
      .selectAll(".track-dot")
      .data(validTracks)
      .join("circle")
      .attr("class", "track-dot")
      .attr("cx", (t) => x(parseDate(t.show_date)))
      .attr("cy", (t) => y(t.duration_ms / 60000))
      .attr("r", (t) => (t.is_jamchart ? 8 : 5))
      .attr("fill", (t) => (t.is_jamchart ? "#ef4444" : "#e5e7eb"))
      .attr("stroke", (t) => (t.is_jamchart ? "#b91c1c" : "#999"))
      .attr("stroke-width", (t) => (t.is_jamchart ? 2 : 1.5))
      .style("cursor", "pointer");

    // Jamchart stars
    const starPath =
      "M0,-8 L2,-3 L7,-3 L3,1 L5,6 L0,3 L-5,6 L-3,1 L-7,-3 L-2,-3 Z";
    svg
      .selectAll(".jc-star")
      .data(validTracks.filter((t) => t.is_jamchart))
      .join("path")
      .attr("class", "jc-star")
      .attr("d", starPath)
      .attr("transform", (t) => {
        const cx = x(parseDate(t.show_date));
        const cy = y(t.duration_ms / 60000) - 16;
        return `translate(${cx},${cy}) scale(0.7)`;
      })
      .attr("fill", "#ef4444")
      .attr("opacity", 0.8)
      .style("pointer-events", "none");

    // Hover targets
    const tooltip = this.tooltip;
    const modal = this.modal;
    const self = this;

    svg
      .selectAll(".hover-target")
      .data(validTracks)
      .join("rect")
      .attr("class", "hover-target")
      .attr("x", (t) => x(parseDate(t.show_date)) - 18)
      .attr("y", margin.top)
      .attr("width", 36)
      .attr("height", height - margin.top - margin.bottom)
      .attr("fill", "transparent")
      .style("cursor", "pointer")
      .on("mousemove", (event, t) => {
        const dur = fmtDuration(t.duration_ms);
        const jcBadge = t.is_jamchart
          ? '<strong style="color:#ef4444">★ JAMCHART</strong><br/>'
          : "";
        tooltip.innerHTML =
          `<strong>${esc(t.show_date)}</strong><br/>` +
          `${esc(t.venue)}<br/>` +
          `${esc(t.location)}<br/><br/>` +
          `${jcBadge}` +
          `Duration: <strong>${dur}</strong><br/>` +
          `Set: ${esc(t.set_name)}, Position ${t.position}<br/>` +
          `Likes: ${t.likes}<br/>` +
          (t.jam_notes
            ? `<br/><div style="border-top:1px solid #999;padding-top:4px;margin-top:4px;font-size:10px;color:#666">${esc(t.jam_notes)}</div>`
            : "") +
          `<div style="margin-top:6px;padding-top:6px;border-top:1px solid #999;font-size:12px;font-weight:800;color:#22c55e;text-align:center">CLICK TO FIND JAM AND PLAY</div>`;
        tooltip.style.display = "block";
        tooltip.style.left = `${event.clientX + 12}px`;
        tooltip.style.top = `${event.clientY - 10}px`;
      })
      .on("mouseleave", () => {
        tooltip.style.display = "none";
      })
      .on("click", (_event, t) => {
        tooltip.style.display = "none";
        self.showModal(t);
      });

    // X axis
    const tickCount = Math.min(validTracks.length, 20);
    svg
      .append("g")
      .attr("transform", `translate(0,${height - margin.bottom})`)
      .call(
        d3
          .axisBottom(x)
          .ticks(tickCount)
          .tickFormat(d3.timeFormat("%b '%y"))
      )
      .selectAll("text")
      .style("font-size", "10px")
      .style("fill", "#333")
      .attr("transform", "rotate(-40)")
      .attr("text-anchor", "end");

    // Y axis
    svg
      .append("g")
      .attr("transform", `translate(${margin.left},0)`)
      .call(
        d3
          .axisLeft(y)
          .ticks(8)
          .tickFormat((d) => `${d}m`)
      )
      .selectAll("text")
      .style("font-size", "10px")
      .style("fill", "#333");

    // Y axis label
    svg
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("x", -(margin.top + height - margin.bottom) / 2)
      .attr("y", 18)
      .attr("text-anchor", "middle")
      .style("font-size", "11px")
      .style("fill", "#666")
      .style("font-weight", "600")
      .text("Duration (minutes)");

    // Title
    svg
      .append("text")
      .attr("x", width / 2)
      .attr("y", 24)
      .attr("text-anchor", "middle")
      .style("font-size", "14px")
      .style("fill", "#000")
      .style("font-weight", "700")
      .text(song_name);

    svg
      .append("text")
      .attr("x", width / 2)
      .attr("y", 42)
      .attr("text-anchor", "middle")
      .style("font-size", "10px")
      .style("fill", "#666")
      .text(
        `${validTracks.length} performances since ${validTracks[0].show_date}`
      );

    // Legend
    const legendX = width - margin.right - 180;
    const legendY = 18;
    svg
      .append("circle")
      .attr("cx", legendX)
      .attr("cy", legendY)
      .attr("r", 4)
      .attr("fill", "#e5e7eb")
      .attr("stroke", "#999");
    svg
      .append("text")
      .attr("x", legendX + 10)
      .attr("y", legendY + 4)
      .style("font-size", "10px")
      .style("fill", "#666")
      .text("Standard");
    svg
      .append("circle")
      .attr("cx", legendX + 80)
      .attr("cy", legendY)
      .attr("r", 6)
      .attr("fill", "#ef4444")
      .attr("stroke", "#b91c1c");
    svg
      .append("path")
      .attr("d", starPath)
      .attr(
        "transform",
        `translate(${legendX + 80},${legendY - 14}) scale(0.5)`
      )
      .attr("fill", "#ef4444");
    svg
      .append("text")
      .attr("x", legendX + 92)
      .attr("y", legendY + 4)
      .style("font-size", "10px")
      .style("fill", "#666")
      .text("Jamchart");

    // Annotate longest
    const longest = validTracks.reduce((a, b) =>
      a.duration_ms > b.duration_ms ? a : b
    );
    const lx = x(parseDate(longest.show_date));
    const ly = y(longest.duration_ms / 60000);
    svg
      .append("line")
      .attr("x1", lx + 12)
      .attr("y1", ly - 4)
      .attr("x2", lx + 40)
      .attr("y2", ly - 20)
      .attr("stroke", "#999")
      .attr("stroke-width", 1);
    svg
      .append("text")
      .attr("x", lx + 42)
      .attr("y", ly - 22)
      .style("font-size", "10px")
      .style("fill", "#333")
      .style("font-weight", "600")
      .text(`${fmtDuration(longest.duration_ms)} peak`);

    // Stats bar
    const statsY = height - 18;
    const avgDur = d3.mean(validTracks, (t) => t.duration_ms / 60000) || 0;
    const jcCount = validTracks.filter((t) => t.is_jamchart).length;
    const jcPct =
      validTracks.length > 0
        ? Math.round((100 * jcCount) / validTracks.length)
        : 0;
    const totalLikes = d3.sum(validTracks, (t) => t.likes);

    svg
      .append("text")
      .attr("x", width / 2)
      .attr("y", statsY)
      .attr("text-anchor", "middle")
      .style("font-size", "10px")
      .style("fill", "#666")
      .text(
        [
          `Avg: ${avgDur.toFixed(1)}m`,
          `Longest: ${fmtDuration(longest.duration_ms)}`,
          `Jamcharts: ${jcCount}/${validTracks.length} (${jcPct}%)`,
          `Total likes: ${totalLikes}`,
        ].join("    ")
      );
  },

  showModal(t) {
    const dur = fmtDuration(t.duration_ms);
    const jcBadge = t.is_jamchart
      ? '<div style="color:#ef4444;font-weight:700;font-size:12px;margin-bottom:6px">★ JAMCHART</div>'
      : "";
    const jamNotes = t.jam_notes
      ? `<div style="border-top:1px solid #000;padding-top:6px;margin-bottom:8px;font-size:11px;color:#666;line-height:1.4">${esc(t.jam_notes)}</div>`
      : "";
    const playBtn = t.jam_url
      ? `<button class="phish-modal-play-btn" data-url="${esc(t.jam_url)}" data-date="${esc(t.show_date)}" data-song="${esc(t.song_name)}">▶ Play Jam</button>`
      : '<div style="padding:10px;background:#eee;border:1px inset #999;text-align:center;font-size:11px;color:#999">No jam clip available</div>';

    this.modal.innerHTML = `
      <div class="phish-modal-dialog">
        <div class="os-titlebar" style="cursor: default;">
          <span class="os-titlebar-title" style="font-size: 11px;">${esc(t.show_date)} — ${esc(t.song_name)}</span>
        </div>
        <div style="padding: 12px;">
          <div style="font-size: 14px; font-weight: 700; margin-bottom: 2px;">${esc(t.show_date)}</div>
          <div style="color: #666; font-size: 12px;">${esc(t.venue)}</div>
          <div style="color: #999; font-size: 11px; margin-bottom: 8px;">${esc(t.location)}</div>
          ${jcBadge}
          <div style="display: flex; gap: 12px; font-size: 12px; color: #333; margin-bottom: 4px;">
            <span>Duration: <strong>${dur}</strong></span>
            <span>Set ${esc(t.set_name)}, #${t.position}</span>
          </div>
          <div style="font-size: 11px; color: #999; margin-bottom: 8px;">Likes: ${t.likes}</div>
          ${jamNotes}
          ${playBtn}
        </div>
      </div>
    `;
    this.modal.style.display = "flex";

    // Bind play button
    const btn = this.modal.querySelector(".phish-modal-play-btn");
    if (btn) {
      btn.addEventListener("click", () => {
        window.dispatchEvent(
          new CustomEvent("phish:play-jam", {
            detail: {
              url: btn.dataset.url,
              date: btn.dataset.date,
              song: btn.dataset.song,
            },
          })
        );
        this.modal.style.display = "none";
      });
    }
  },
};

export default PhishChart;
