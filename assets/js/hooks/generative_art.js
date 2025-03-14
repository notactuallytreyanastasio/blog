const GenerativeArt = {
  mounted() {
    this.canvas = this.el.querySelector("#bezier-canvas");
    this.ctx = this.canvas.getContext("2d");
    this.allTriangles = []; // Store all triangles to keep them on screen
    this.animationId = null;
    this.lastTimestamp = 0;
    this.currentCurves = [];
    this.gridCells = {}; // Track which grid cells have been used

    // Set up resize observer
    const resizeObserver = new ResizeObserver(entries => {
      for (let entry of entries) {
        const { width, height } = entry.contentRect;
        this.canvas.width = width;
        this.canvas.height = height;
        this.pushEvent("viewport_resize", { width: width.toString(), height: height.toString() });
      }
    });

    resizeObserver.observe(this.el);

    // Start animation loop
    this.animate();

    // Handle bezier data updates
    this.handleEvent("updated", ({ bezier }) => {
      if (bezier) {
        this.bezierData = bezier;
      }
    });
  },

  updated() {
    const bezierDataStr = this.el.querySelector("#bezier-canvas").dataset.bezier;
    if (bezierDataStr) {
      const bezierData = JSON.parse(bezierDataStr);

      // If reset flag is true, clear all triangles
      if (bezierData.reset) {
        this.allTriangles = [];
        this.gridCells = {};
      }

      // If draw flag is true and progress is 0, generate new curves
      if (bezierData.draw && bezierData.progress === 0) {
        this.generateCurves(bezierData.width, bezierData.height);
      }

      this.bezierData = bezierData;
    }
  },

  generateCurves(width, height) {
    this.currentCurves = [];
    const numCurves = 8 + Math.floor(Math.random() * 4); // Generate 8-12 curves for better coverage

    // Create a 5x5 grid for better distribution
    const gridSize = 5;
    const cellWidth = width / gridSize;
    const cellHeight = height / gridSize;

    // Generate curves with different strategies for full screen coverage
    for (let i = 0; i < numCurves; i++) {
      let startPoint, endPoint, controlPoint1, controlPoint2;

      // Different curve generation strategies
      const strategy = Math.floor(Math.random() * 5);

      switch (strategy) {
        case 0: // Grid-based curves
          // Find an unused grid cell for the start point
          let startCell = this.getUnusedGridCell(gridSize, gridSize);
          let endCell = this.getUnusedGridCell(gridSize, gridSize);

          // Mark cells as used
          this.gridCells[`${startCell.x},${startCell.y}`] = true;
          this.gridCells[`${endCell.x},${endCell.y}`] = true;

          // Convert grid cells to actual coordinates
          startPoint = {
            x: (startCell.x + 0.5) * cellWidth + (Math.random() - 0.5) * cellWidth * 0.5,
            y: (startCell.y + 0.5) * cellHeight + (Math.random() - 0.5) * cellHeight * 0.5
          };

          endPoint = {
            x: (endCell.x + 0.5) * cellWidth + (Math.random() - 0.5) * cellWidth * 0.5,
            y: (endCell.y + 0.5) * cellHeight + (Math.random() - 0.5) * cellHeight * 0.5
          };

          // Random control points
          controlPoint1 = {
            x: Math.random() * width,
            y: Math.random() * height
          };

          controlPoint2 = {
            x: Math.random() * width,
            y: Math.random() * height
          };
          break;

        case 1: // Horizontal full-screen curves
          startPoint = { x: 0, y: Math.random() * height };
          endPoint = { x: width, y: Math.random() * height };
          controlPoint1 = {
            x: width * 0.33,
            y: Math.random() > 0.5 ? Math.random() * height * 0.3 : height - Math.random() * height * 0.3
          };
          controlPoint2 = {
            x: width * 0.66,
            y: Math.random() > 0.5 ? Math.random() * height * 0.3 : height - Math.random() * height * 0.3
          };
          break;

        case 2: // Vertical full-screen curves
          startPoint = { x: Math.random() * width, y: 0 };
          endPoint = { x: Math.random() * width, y: height };
          controlPoint1 = {
            x: Math.random() > 0.5 ? Math.random() * width * 0.3 : width - Math.random() * width * 0.3,
            y: height * 0.33
          };
          controlPoint2 = {
            x: Math.random() > 0.5 ? Math.random() * width * 0.3 : width - Math.random() * width * 0.3,
            y: height * 0.66
          };
          break;

        case 3: // Diagonal full-screen curves
          if (Math.random() > 0.5) {
            startPoint = { x: 0, y: 0 };
            endPoint = { x: width, y: height };
          } else {
            startPoint = { x: 0, y: height };
            endPoint = { x: width, y: 0 };
          }

          controlPoint1 = {
            x: width * (0.2 + Math.random() * 0.3),
            y: height * (0.2 + Math.random() * 0.6)
          };

          controlPoint2 = {
            x: width * (0.5 + Math.random() * 0.3),
            y: height * (0.2 + Math.random() * 0.6)
          };
          break;

        case 4: // Corner-to-random curves
          // Start from a corner
          const corners = [
            { x: 0, y: 0 },
            { x: width, y: 0 },
            { x: 0, y: height },
            { x: width, y: height }
          ];

          startPoint = corners[Math.floor(Math.random() * corners.length)];

          // End at a random point
          endPoint = {
            x: width * (0.2 + Math.random() * 0.6),
            y: height * (0.2 + Math.random() * 0.6)
          };

          // Control points that create interesting curves
          controlPoint1 = {
            x: Math.random() * width,
            y: Math.random() * height
          };

          controlPoint2 = {
            x: Math.random() * width,
            y: Math.random() * height
          };
          break;
      }

      // Generate a super vibrant color for this curve
      const hue = Math.floor(Math.random() * 360);
      const saturation = 90 + Math.floor(Math.random() * 10); // Very high saturation (90-100%)
      const lightness = 55 + Math.floor(Math.random() * 25); // Brighter lightness (55-80%)
      const baseColor = `hsl(${hue}, ${saturation}%, ${lightness}%)`;

      // Calculate how many triangles to generate for this curve
      const triangleCount = 100 + Math.floor(Math.random() * 200); // 100-300 triangles per curve

      // Create the curve object
      this.currentCurves.push({
        startPoint,
        endPoint,
        controlPoint1,
        controlPoint2,
        color: baseColor,
        triangleCount,
        triangles: [] // Will be populated during drawing
      });
    }

    // Add some immediate triangles for instant visual feedback
    this.addRandomTriangles(width, height, 100); // Increased from 50 to 100
  },

  // Add some random triangles immediately for instant visual feedback
  addRandomTriangles(width, height, count) {
    for (let i = 0; i < count; i++) {
      const x = Math.random() * width;
      const y = Math.random() * height;
      const size = Math.min(width, height) / (1.5 + Math.random() * 2.5); // Even larger triangles
      const rotation = Math.random() * Math.PI * 2;
      const hue = Math.floor(Math.random() * 360);

      this.allTriangles.push({
        x,
        y,
        size,
        rotation,
        color: `hsla(${hue}, 100%, 65%, ${0.8 + Math.random() * 0.2})`, // Extremely bright, highly opaque triangles
        timestamp: Date.now()
      });
    }
  },

  // Get an unused grid cell
  getUnusedGridCell(gridWidth, gridHeight) {
    // Try to find an unused cell
    let attempts = 0;
    let cell;

    do {
      cell = {
        x: Math.floor(Math.random() * gridWidth),
        y: Math.floor(Math.random() * gridHeight)
      };
      attempts++;

      // If we've tried too many times, just return any cell
      if (attempts > 20) {
        return cell;
      }
    } while (this.gridCells[`${cell.x},${cell.y}`]);

    return cell;
  },

  animate(timestamp = 0) {
    this.animationId = requestAnimationFrame(this.animate.bind(this));

    // Limit frame rate for performance
    if (timestamp - this.lastTimestamp < 16) { // ~60fps
      return;
    }
    this.lastTimestamp = timestamp;

    // Clear canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    // Draw all stored triangles
    this.drawAllTriangles();

    // If we have bezier data and it's set to draw
    if (this.bezierData && this.bezierData.draw) {
      // Increment progress slightly for a slower animation
      const progressIncrement = 0.003; // Slower animation
      const newProgress = Math.min(1, this.bezierData.progress + progressIncrement);

      // Draw the current curves up to the current progress
      this.drawCurves(newProgress);

      // Update progress
      this.pushEvent("drawing_progress", { progress: newProgress });

      // If we've reached the end, notify the server
      if (newProgress >= 1) {
        this.pushEvent("drawing_complete", {});
        this.bezierData.draw = false;
      }
    }
  },

  drawCurves(progress) {
    // Draw each curve up to the current progress
    this.currentCurves.forEach((curve, curveIndex) => {
      // Only draw if we've reached this curve's turn
      const curveProgress = (progress * this.currentCurves.length - curveIndex);

      if (curveProgress <= 0) return; // Not time for this curve yet

      const actualProgress = Math.min(1, curveProgress);

      // Generate points along the curve
      const pointCount = 400; // More points for smoother curves
      const pointsToGenerate = Math.floor(pointCount * actualProgress);

      // Only generate triangles if we haven't already for this progress level
      if (pointsToGenerate > curve.triangles.length) {
        for (let i = curve.triangles.length; i < pointsToGenerate; i++) {
          const t = i / pointCount;

          // Calculate point on the Bezier curve
          const point = this.getBezierPoint(
            curve.startPoint,
            curve.controlPoint1,
            curve.controlPoint2,
            curve.endPoint,
            t
          );

          // Only generate a triangle with some probability to avoid overcrowding
          if (i % 2 === 0 || Math.random() < 0.7) {
            // Calculate triangle size - larger at the beginning, smaller at the end
            const triangleSize = Math.min(this.canvas.width, this.canvas.height) /
                                (1.5 + Math.random() * 2.5) * (0.9 - 0.1 * t + Math.random() * 0.3);

            // Add some jitter to the position
            const jitter = triangleSize * 0.5; // Increased jitter for better spread
            const x = point.x + (Math.random() - 0.5) * jitter;
            const y = point.y + (Math.random() - 0.5) * jitter;

            // Random rotation
            const rotation = Math.random() * Math.PI * 2;

            // Color variation based on the base color - make more vibrant
            const hue = parseInt(curve.color.match(/hsl\((\d+)/)[1]);
            const hueVariation = hue + (Math.random() - 0.5) * 30;
            const opacity = 0.8 + Math.random() * 0.2; // Higher opacity (80-100%)
            const color = `hsla(${hueVariation}, 100%, 65%, ${opacity})`; // Maximum saturation, high lightness

            // Create triangle and add to the curve's triangles
            const triangle = { x, y, size: triangleSize, rotation, color, timestamp: Date.now() };
            curve.triangles.push(triangle);

            // Also add to the global triangle list
            this.allTriangles.push(triangle);
          }
        }
      }
    });
  },

  drawAllTriangles() {
    // Draw all triangles
    this.allTriangles.forEach(triangle => {
      this.drawTriangle(
        triangle.x,
        triangle.y,
        triangle.size,
        triangle.rotation,
        triangle.color
      );
    });

    // Limit the number of triangles to prevent performance issues
    const maxTriangles = 3000; // Increased from 2000 to 3000
    if (this.allTriangles.length > maxTriangles) {
      // Sort by timestamp and remove oldest
      this.allTriangles.sort((a, b) => a.timestamp - b.timestamp);
      this.allTriangles = this.allTriangles.slice(this.allTriangles.length - maxTriangles);
    }
  },

  drawTriangle(x, y, size, rotation, color) {
    this.ctx.save();
    this.ctx.translate(x, y);
    this.ctx.rotate(rotation);

    this.ctx.beginPath();
    this.ctx.moveTo(0, -size / 2);
    this.ctx.lineTo(size / 2, size / 2);
    this.ctx.lineTo(-size / 2, size / 2);
    this.ctx.closePath();

    this.ctx.fillStyle = color;
    this.ctx.fill();

    // Add a more visible white stroke to make triangles pop against black
    this.ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)'; // Increased opacity from 0.3 to 0.5
    this.ctx.lineWidth = 1.5; // Increased from 1 to 1.5
    this.ctx.stroke();

    this.ctx.restore();
  },

  getBezierPoint(p0, p1, p2, p3, t) {
    const oneMinusT = 1 - t;
    const oneMinusTSquared = oneMinusT * oneMinusT;
    const oneMinusTCubed = oneMinusTSquared * oneMinusT;
    const tSquared = t * t;
    const tCubed = tSquared * t;

    return {
      x: oneMinusTCubed * p0.x + 3 * oneMinusTSquared * t * p1.x + 3 * oneMinusT * tSquared * p2.x + tCubed * p3.x,
      y: oneMinusTCubed * p0.y + 3 * oneMinusTSquared * t * p1.y + 3 * oneMinusT * tSquared * p2.y + tCubed * p3.y
    };
  },

  destroyed() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
  }
};

export default GenerativeArt;