const CollageViewer = {
  mounted() {
    const config = JSON.parse(this.el.dataset.config);
    this.scale = 1;
    this.minScale = 0.1;
    this.maxScale = 8;
    this.translateX = 0;
    this.translateY = 0;
    this.isDragging = false;
    this.startX = 0;
    this.startY = 0;

    // Create inner container
    this.inner = document.createElement('div');
    this.inner.style.cssText = `
      width: ${config.canvasWidth}px;
      height: ${config.canvasHeight}px;
      position: relative;
      transform-origin: 0 0;
      background: #c0c0c0;
    `;
    this.el.style.overflow = 'hidden';
    this.el.style.position = 'relative';
    this.el.appendChild(this.inner);

    // Place images
    config.images.forEach(img => {
      const el = document.createElement('img');
      el.src = img.url;
      el.loading = 'lazy';
      el.draggable = false;
      el.style.cssText = `
        position: absolute;
        left: ${img.x}px;
        top: ${img.y}px;
        width: ${config.cellSize}px;
        height: ${config.cellSize}px;
        object-fit: cover;
      `;
      this.inner.appendChild(el);
    });

    // Fit to container initially
    const containerW = this.el.clientWidth;
    const containerH = this.el.clientHeight;
    this.scale = Math.min(containerW / config.canvasWidth, containerH / config.canvasHeight, 1);
    this.translateX = (containerW - config.canvasWidth * this.scale) / 2;
    this.translateY = (containerH - config.canvasHeight * this.scale) / 2;
    this.initialScale = this.scale;
    this.initialX = this.translateX;
    this.initialY = this.translateY;
    this.updateTransform();

    this.setupMouseEvents();
    this.setupTouchEvents();
    this.setupKeyEvents();
  },

  updateTransform() {
    this.inner.style.transform = `translate(${this.translateX}px, ${this.translateY}px) scale(${this.scale})`;
  },

  setupMouseEvents() {
    // Wheel zoom
    this.el.addEventListener('wheel', (e) => {
      e.preventDefault();
      const rect = this.el.getBoundingClientRect();
      const mouseX = e.clientX - rect.left;
      const mouseY = e.clientY - rect.top;

      const prevScale = this.scale;
      const delta = e.deltaY > 0 ? 0.9 : 1.1;
      this.scale = Math.max(this.minScale, Math.min(this.maxScale, this.scale * delta));

      // Zoom toward cursor
      this.translateX = mouseX - (mouseX - this.translateX) * (this.scale / prevScale);
      this.translateY = mouseY - (mouseY - this.translateY) * (this.scale / prevScale);
      this.updateTransform();
    }, { passive: false });

    // Drag pan
    this.el.addEventListener('mousedown', (e) => {
      if (e.button !== 0) return;
      this.isDragging = true;
      this.startX = e.clientX - this.translateX;
      this.startY = e.clientY - this.translateY;
      this.el.style.cursor = 'grabbing';
    });

    window.addEventListener('mousemove', this._onMouseMove = (e) => {
      if (!this.isDragging) return;
      this.translateX = e.clientX - this.startX;
      this.translateY = e.clientY - this.startY;
      this.updateTransform();
    });

    window.addEventListener('mouseup', this._onMouseUp = () => {
      this.isDragging = false;
      this.el.style.cursor = 'grab';
    });

    // Double-click reset
    this.el.addEventListener('dblclick', () => {
      this.scale = this.initialScale;
      this.translateX = this.initialX;
      this.translateY = this.initialY;
      this.inner.style.transition = 'transform 0.3s ease';
      this.updateTransform();
      setTimeout(() => { this.inner.style.transition = ''; }, 300);
    });
  },

  setupTouchEvents() {
    let lastTouchDist = 0;
    let lastTouchCenter = null;

    this.el.addEventListener('touchstart', (e) => {
      if (e.touches.length === 1) {
        this.isDragging = true;
        this.startX = e.touches[0].clientX - this.translateX;
        this.startY = e.touches[0].clientY - this.translateY;
      } else if (e.touches.length === 2) {
        this.isDragging = false;
        lastTouchDist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
        lastTouchCenter = {
          x: (e.touches[0].clientX + e.touches[1].clientX) / 2,
          y: (e.touches[0].clientY + e.touches[1].clientY) / 2
        };
      }
    }, { passive: false });

    this.el.addEventListener('touchmove', (e) => {
      e.preventDefault();
      if (e.touches.length === 1 && this.isDragging) {
        this.translateX = e.touches[0].clientX - this.startX;
        this.translateY = e.touches[0].clientY - this.startY;
        this.updateTransform();
      } else if (e.touches.length === 2) {
        const dist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
        const center = {
          x: (e.touches[0].clientX + e.touches[1].clientX) / 2,
          y: (e.touches[0].clientY + e.touches[1].clientY) / 2
        };

        const rect = this.el.getBoundingClientRect();
        const cx = center.x - rect.left;
        const cy = center.y - rect.top;

        const prevScale = this.scale;
        this.scale = Math.max(this.minScale, Math.min(this.maxScale, this.scale * (dist / lastTouchDist)));

        this.translateX = cx - (cx - this.translateX) * (this.scale / prevScale);
        this.translateY = cy - (cy - this.translateY) * (this.scale / prevScale);

        lastTouchDist = dist;
        lastTouchCenter = center;
        this.updateTransform();
      }
    }, { passive: false });

    this.el.addEventListener('touchend', () => {
      this.isDragging = false;
    });
  },

  setupKeyEvents() {
    this._onKeyDown = (e) => {
      if (!this.el.matches(':hover')) return;
      const step = 50;
      switch (e.key) {
        case '+': case '=':
          this.scale = Math.min(this.maxScale, this.scale * 1.2);
          this.updateTransform();
          break;
        case '-':
          this.scale = Math.max(this.minScale, this.scale * 0.8);
          this.updateTransform();
          break;
        case '0':
          this.scale = this.initialScale;
          this.translateX = this.initialX;
          this.translateY = this.initialY;
          this.updateTransform();
          break;
      }
    };
    document.addEventListener('keydown', this._onKeyDown);
  },

  destroyed() {
    if (this._onMouseMove) window.removeEventListener('mousemove', this._onMouseMove);
    if (this._onMouseUp) window.removeEventListener('mouseup', this._onMouseUp);
    if (this._onKeyDown) document.removeEventListener('keydown', this._onKeyDown);
  }
};

export default CollageViewer;
