export default {
  mounted() {
    console.log("BezierTriangles hook mounted");
    this.canvas = this.el.querySelector("canvas");
    this.ctx = this.canvas.getContext("2d");

    // Force canvas size to match container
    const rect = this.el.getBoundingClientRect();
    this.canvas.width = rect.width;
    this.canvas.height = rect.height;

    // Set up resize observer to handle window size changes
    this.resizeObserver = new ResizeObserver(entries => {
      for (const entry of entries) {
        const { width, height } = entry.contentRect;
        this.handleResize(width, height);
      }
    });

    this.resizeObserver.observe(this.el);

    // Start animation loop with full bezier features
    this.animationFrame = requestAnimationFrame(() => this.render());

    console.log("Canvas dimensions:", {
      width: this.canvas.width,
      height: this.canvas.height
    });
  },

  handleResize(width, height) {
    console.log(`Resizing canvas to ${width}x${height}`);
    // Update canvas size
    this.canvas.width = width;
    this.canvas.height = height;

    // Notify LiveView of the resize
    this.pushEvent("viewport_resize", { width: Math.floor(width), height: Math.floor(height) });
  },

  render() {
    // Continue animation loop
    this.animationFrame = requestAnimationFrame(() => this.render());

    // Clear canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    try {
      // Parse data from HTML attributes
      const backgroundLines = JSON.parse(this.canvas.dataset.backgroundLines || "[]");
      const curves = JSON.parse(this.canvas.dataset.curves || "[]");
      const triangles = JSON.parse(this.canvas.dataset.triangles || "[]");

      // Draw background
      this.ctx.fillStyle = "#1a202c"; // Dark background
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

      // Draw background lines
      this.drawBackgroundLines(backgroundLines);

      // Draw bezier curves
      this.drawBezierCurves(curves);

      // Draw triangles
      this.drawTriangles(triangles, curves);

      // Draw a small indicator to show rendering is working
      this.ctx.font = "14px Arial";
      this.ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
      this.ctx.fillText("✓ Canvas rendering", 10, 20);

    } catch (error) {
      console.error("Error rendering canvas:", error);

      // If there's an error, fall back to simple animation
      this.renderSimpleFallback();
    }
  },

  // Fallback render method in case of errors
  renderSimpleFallback() {
    const time = performance.now() / 1000;

    // Draw background
    this.ctx.fillStyle = "#1a202c";
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    // Draw a simple animation of moving circles
    for (let i = 0; i < 10; i++) {
      const x = this.canvas.width * 0.5 + Math.cos(time + i * 0.5) * 100;
      const y = this.canvas.height * 0.5 + Math.sin(time + i * 0.5) * 100;

      this.ctx.beginPath();
      this.ctx.arc(x, y, 20, 0, Math.PI * 2);
      this.ctx.fillStyle = `hsl(${(i * 36 + time * 30) % 360}, 80%, 60%)`;
      this.ctx.fill();
    }

    // Draw text to show there was an error
    this.ctx.font = "18px Arial";
    this.ctx.fillStyle = "white";
    this.ctx.fillText("Error rendering bezier animations - fallback mode", 20, 40);
  },

  drawBackgroundLines(lines) {
    if (!lines || !lines.length) return;

    this.ctx.lineWidth = 1;

    lines.forEach(line => {
      this.ctx.beginPath();
      this.ctx.moveTo(line.from.x, line.from.y);
      this.ctx.lineTo(line.to.x, line.to.y);
      this.ctx.strokeStyle = line.color || "rgba(255, 255, 255, 0.1)";
      this.ctx.stroke();
    });
  },

  drawBezierCurves(curves) {
    if (!curves || !curves.length) return;

    curves.forEach(curve => {
      if (curve.points && curve.points.length >= 4) {
        const [start, control1, control2, end] = curve.points;

        this.ctx.beginPath();
        this.ctx.moveTo(start.x, start.y);
        this.ctx.bezierCurveTo(
          control1.x, control1.y,
          control2.x, control2.y,
          end.x, end.y
        );

        this.ctx.strokeStyle = curve.color || "rgba(255, 255, 255, 0.4)";
        this.ctx.lineWidth = 2;
        this.ctx.stroke();
      }
    });
  },

  drawTriangles(triangles, curves) {
    if (!triangles || !triangles.length) return;

    triangles.forEach(triangle => {
      // Get the bezier curve for this triangle
      const curve = curves[triangle.curve_index];
      if (!curve || !curve.points || curve.points.length < 4) return;

      // Determine position along the curve
      const [p0, p1, p2, p3] = curve.points;
      const t = triangle.t;

      // Calculate the position along the bezier curve
      const pos = this.bezierPoint(p0, p1, p2, p3, t);

      // Draw triangle at the calculated position
      this.ctx.save();
      this.ctx.translate(pos.x, pos.y);
      this.ctx.rotate(triangle.rotation);

      this.ctx.beginPath();
      this.ctx.moveTo(0, -triangle.size / 2);
      this.ctx.lineTo(triangle.size / 2, triangle.size / 2);
      this.ctx.lineTo(-triangle.size / 2, triangle.size / 2);
      this.ctx.closePath();

      this.ctx.fillStyle = triangle.color || "#FFFFFF";
      this.ctx.fill();

      this.ctx.restore();
    });
  },

  // Calculate point along a cubic bezier curve at parameter t
  bezierPoint(p0, p1, p2, p3, t) {
    const invT = 1 - t;
    const invT2 = invT * invT;
    const invT3 = invT2 * invT;
    const t2 = t * t;
    const t3 = t2 * t;

    return {
      x: invT3 * p0.x + 3 * invT2 * t * p1.x + 3 * invT * t2 * p2.x + t3 * p3.x,
      y: invT3 * p0.y + 3 * invT2 * t * p1.y + 3 * invT * t2 * p2.y + t3 * p3.y
    };
  },

  beforeDestroy() {
    console.log("BezierTriangles hook destroyed");
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame);
    }
  }
}