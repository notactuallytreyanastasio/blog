// /collage/:token's pan and zoom: CollageViewerLive's CollageViewer hook,
// run on page load instead of on mount. The hook laid every cropped square
// out at its place in the grid; a collage made in the browser has no
// squares in the bucket, only the collage, whose cells are those squares
// pixel for pixel, so here it is one <img> the grid's size.
(function () {
  var el = document.getElementById('collage-viewer')
  if (!el) return
  var V = {
    el: el,
    mounted: function () {
      var config = { src: this.el.dataset.src, canvasWidth: +this.el.dataset.width, canvasHeight: +this.el.dataset.height }
      this.scale = 1
      this.minScale = 0.1
      this.maxScale = 8
      this.translateX = 0
      this.translateY = 0
      this.isDragging = false
      this.startX = 0
      this.startY = 0

      this.inner = document.createElement('div')
      this.inner.style.cssText = 'width: ' + config.canvasWidth + 'px; height: ' + config.canvasHeight + 'px; position: relative; transform-origin: 0 0; background: #c0c0c0;'
      this.el.style.overflow = 'hidden'
      this.el.style.position = 'relative'
      this.el.appendChild(this.inner)

      var img = document.createElement('img')
      img.src = config.src
      img.alt = 'Collage'
      img.draggable = false
      img.style.cssText = 'position: absolute; left: 0; top: 0; width: ' + config.canvasWidth + 'px; height: ' + config.canvasHeight + 'px;'
      this.inner.appendChild(img)

      var containerW = this.el.clientWidth
      var containerH = this.el.clientHeight
      this.scale = Math.min(containerW / config.canvasWidth, containerH / config.canvasHeight, 1)
      this.translateX = (containerW - config.canvasWidth * this.scale) / 2
      this.translateY = (containerH - config.canvasHeight * this.scale) / 2
      this.initialScale = this.scale
      this.initialX = this.translateX
      this.initialY = this.translateY
      this.updateTransform()

      this.setupMouseEvents()
      this.setupTouchEvents()
      this.setupKeyEvents()
    },

    updateTransform: function () {
    this.inner.style.transform = `translate(${this.translateX}px, ${this.translateY}px) scale(${this.scale})`;
    },

    setupMouseEvents: function () {
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

    setupTouchEvents: function () {
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

    setupKeyEvents: function () {
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
    }
  }
  V.mounted()
})()
