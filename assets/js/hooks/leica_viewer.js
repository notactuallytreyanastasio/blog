// Zoomable, pannable image viewer for large images
const LeicaViewer = {
  mounted() {
    const container = this.el;
    const img = container.querySelector(".leica-img");
    if (!img) return;

    let scale = 1;
    let minScale = 0.1;
    let panX = 0;
    let panY = 0;
    let isPanning = false;
    let startX = 0;
    let startY = 0;
    let startPanX = 0;
    let startPanY = 0;

    // Track pinch state
    let lastPinchDist = 0;
    let lastPinchCenterX = 0;
    let lastPinchCenterY = 0;

    const zoomLabel = container.querySelector(".leica-zoom-label");

    const updateTransform = () => {
      img.style.transform = `translate(${panX}px, ${panY}px) scale(${scale})`;
      if (zoomLabel) {
        zoomLabel.textContent = `${Math.round(scale * 100)}%`;
      }
    };

    // Fit image to container on load
    const fitToContainer = () => {
      const cw = container.clientWidth;
      const ch = container.clientHeight - 36; // minus controls bar
      const iw = img.naturalWidth || 30846;
      const ih = img.naturalHeight || 20550;
      minScale = Math.min(cw / iw, ch / ih, 1);
      scale = minScale;
      panX = (cw - iw * scale) / 2;
      panY = (ch - ih * scale) / 2;
      updateTransform();
    };

    const loadingOverlay = container.querySelector(".leica-loading");

    const onImageReady = () => {
      // Hide loading overlay, show image
      if (loadingOverlay) loadingOverlay.style.display = "none";
      img.style.opacity = "1";
      fitToContainer();
    };

    if (img.complete && img.naturalWidth > 0) {
      onImageReady();
    }
    img.addEventListener("load", onImageReady);

    // Mouse wheel zoom - zoom toward cursor
    container.addEventListener("wheel", (e) => {
      e.preventDefault();
      const rect = container.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;

      const prevScale = scale;
      const zoomFactor = e.deltaY < 0 ? 1.15 : 1 / 1.15;
      scale = Math.max(minScale, Math.min(scale * zoomFactor, 8));

      // Zoom toward mouse position
      panX = mouseX - (mouseX - panX) * (scale / prevScale);
      panY = mouseY - (mouseY - panY) * (scale / prevScale);

      updateTransform();
    }, { passive: false });

    // Mouse drag to pan
    container.addEventListener("mousedown", (e) => {
      if (e.button !== 0) return;
      isPanning = true;
      startX = e.clientX;
      startY = e.clientY;
      startPanX = panX;
      startPanY = panY;
      container.style.cursor = "grabbing";
      e.preventDefault();
    });

    const onMouseMove = (e) => {
      if (!isPanning) return;
      panX = startPanX + (e.clientX - startX);
      panY = startPanY + (e.clientY - startY);
      updateTransform();
    };

    const onMouseUp = () => {
      isPanning = false;
      container.style.cursor = "grab";
    };

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mouseup", onMouseUp);

    // Touch support: single finger pan, two finger pinch-zoom
    container.addEventListener("touchstart", (e) => {
      if (e.touches.length === 1) {
        isPanning = true;
        startX = e.touches[0].clientX;
        startY = e.touches[0].clientY;
        startPanX = panX;
        startPanY = panY;
      } else if (e.touches.length === 2) {
        isPanning = false;
        const dx = e.touches[0].clientX - e.touches[1].clientX;
        const dy = e.touches[0].clientY - e.touches[1].clientY;
        lastPinchDist = Math.sqrt(dx * dx + dy * dy);
        const rect = container.getBoundingClientRect();
        lastPinchCenterX = (e.touches[0].clientX + e.touches[1].clientX) / 2 - rect.left;
        lastPinchCenterY = (e.touches[0].clientY + e.touches[1].clientY) / 2 - rect.top;
      }
      e.preventDefault();
    }, { passive: false });

    container.addEventListener("touchmove", (e) => {
      if (e.touches.length === 1 && isPanning) {
        panX = startPanX + (e.touches[0].clientX - startX);
        panY = startPanY + (e.touches[0].clientY - startY);
        updateTransform();
      } else if (e.touches.length === 2) {
        const dx = e.touches[0].clientX - e.touches[1].clientX;
        const dy = e.touches[0].clientY - e.touches[1].clientY;
        const dist = Math.sqrt(dx * dx + dy * dy);

        const rect = container.getBoundingClientRect();
        const cx = (e.touches[0].clientX + e.touches[1].clientX) / 2 - rect.left;
        const cy = (e.touches[0].clientY + e.touches[1].clientY) / 2 - rect.top;

        if (lastPinchDist > 0) {
          const prevScale = scale;
          scale = Math.max(minScale, Math.min(scale * (dist / lastPinchDist), 8));
          panX = cx - (cx - panX) * (scale / prevScale);
          panY = cy - (cy - panY) * (scale / prevScale);
          updateTransform();
        }

        lastPinchDist = dist;
        lastPinchCenterX = cx;
        lastPinchCenterY = cy;
      }
      e.preventDefault();
    }, { passive: false });

    container.addEventListener("touchend", (e) => {
      if (e.touches.length < 2) {
        lastPinchDist = 0;
      }
      if (e.touches.length === 0) {
        isPanning = false;
      }
    });

    // Zoom button handlers
    const zoomInBtn = container.querySelector(".leica-zoom-in");
    const zoomOutBtn = container.querySelector(".leica-zoom-out");
    const fitBtn = container.querySelector(".leica-fit");

    if (zoomInBtn) {
      zoomInBtn.addEventListener("click", () => {
        const rect = container.getBoundingClientRect();
        const cx = rect.width / 2;
        const cy = (rect.height - 36) / 2;
        const prevScale = scale;
        scale = Math.min(scale * 1.5, 8);
        panX = cx - (cx - panX) * (scale / prevScale);
        panY = cy - (cy - panY) * (scale / prevScale);
        updateTransform();
      });
    }

    if (zoomOutBtn) {
      zoomOutBtn.addEventListener("click", () => {
        const rect = container.getBoundingClientRect();
        const cx = rect.width / 2;
        const cy = (rect.height - 36) / 2;
        const prevScale = scale;
        scale = Math.max(scale / 1.5, minScale);
        panX = cx - (cx - panX) * (scale / prevScale);
        panY = cy - (cy - panY) * (scale / prevScale);
        updateTransform();
      });
    }

    if (fitBtn) {
      fitBtn.addEventListener("click", fitToContainer);
    }

    // Cleanup refs
    this._cleanup = () => {
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("mouseup", onMouseUp);
    };

    container.style.cursor = "grab";
  },

  destroyed() {
    if (this._cleanup) this._cleanup();
  }
};

export default LeicaViewer;
