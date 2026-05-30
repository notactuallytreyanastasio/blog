import { generate, render, GENERATORS } from '../../vendor/temper-engine.js';

const TemperArt = {
  mounted() {
    this.canvas = this.el.querySelector('#art-canvas');
    this.ctx = this.canvas.getContext('2d');
    this.history = [];
    this.histIdx = -1;
    this._last = null;

    this.pushEvent('generators_ready', { generators: GENERATORS });

    this._resize();
    this._ro = new ResizeObserver(() => this._resize());
    this._ro.observe(this.canvas);

    this.handleEvent('draw', ({ seed, generator }) => this._draw(seed, generator, true));

    this._keydown = (e) => {
      if (e.target.tagName === 'INPUT') return;
      if (e.key === 'r' || e.key === 'R') this._random();
      if (e.key === 'ArrowLeft')  this._back();
      if (e.key === 'ArrowRight') this._forward();
      if (e.key === 'Escape')     this._closeModal();
    };
    document.addEventListener('keydown', this._keydown);

    // tap/click canvas → open fullscreen modal
    this.canvas.addEventListener('click', () => this._openModal());
  },

  destroyed() {
    document.removeEventListener('keydown', this._keydown);
    this._ro?.disconnect();
    this._closeModal();
  },

  // ── sizing ──────────────────────────────────────────────────────────────────

  _dpr() { return Math.min(window.devicePixelRatio || 1, 3); },

  _resize() {
    const dpr  = this._dpr();
    const rect = this.canvas.getBoundingClientRect();
    const cssW = rect.width  || this.canvas.offsetWidth  || 800;
    const cssH = rect.height || this.canvas.offsetHeight || 600;
    const physW = Math.round(cssW * dpr);
    const physH = Math.round(cssH * dpr);

    if (this.canvas.width === physW && this.canvas.height === physH) return;

    this.canvas.width  = physW;
    this.canvas.height = physH;
    // ctx scale is reset on dimension change — re-apply DPR scale
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

    if (this._last) this._draw(this._last.seed, this._last.generator, false);
  },

  // ── rendering ───────────────────────────────────────────────────────────────

  _draw(seed, generator, push) {
    const dpr  = this._dpr();
    const cssW = this.canvas.width  / dpr;
    const cssH = this.canvas.height / dpr;

    const t0    = performance.now();
    const scene = generate(seed, generator, Math.round(cssW), Math.round(cssH));
    render(this.ctx, scene);
    const ms = (performance.now() - t0).toFixed(1);

    this._last = { seed, generator };

    if (push) {
      this.history = this.history.slice(0, this.histIdx + 1);
      this.history.push({ seed, generator });
      this.histIdx = this.history.length - 1;
    }

    this.pushEvent('render_done', { seed, generator, shapes: scene.shapes.length, ms });

    // keep modal in sync if open
    if (this._modalCanvas) this._renderModal(scene);
  },

  // ── fullscreen modal ─────────────────────────────────────────────────────────

  _openModal() {
    if (this._modal) return;
    if (!this._last) return;

    const overlay = document.createElement('div');
    overlay.style.cssText = `
      position:fixed; inset:0; background:rgba(0,0,0,.92); z-index:9999;
      display:flex; flex-direction:column; align-items:center; justify-content:center;
      touch-action:none;
    `;

    const mc = document.createElement('canvas');
    mc.style.cssText = 'max-width:100vw; max-height:100vh; object-fit:contain; cursor:zoom-out;';
    this._modalCanvas = mc;
    this._modalCtx = mc.getContext('2d');

    // render at full screen resolution
    const sw = screen.width  * window.devicePixelRatio;
    const sh = screen.height * window.devicePixelRatio;
    mc.width  = sw;
    mc.height = sh;
    mc.style.width  = Math.min(screen.width, window.innerWidth) + 'px';
    mc.style.height = Math.min(screen.height, window.innerHeight) + 'px';

    const dpr = this._dpr();
    this._modalCtx.setTransform(window.devicePixelRatio, 0, 0, window.devicePixelRatio, 0, 0);

    const scene = generate(
      this._last.seed, this._last.generator,
      Math.round(sw / window.devicePixelRatio),
      Math.round(sh / window.devicePixelRatio)
    );
    render(this._modalCtx, scene);

    // toolbar
    const bar = document.createElement('div');
    bar.style.cssText = `
      position:absolute; bottom:16px; left:50%; transform:translateX(-50%);
      display:flex; gap:8px; font-family:'Chicago','Geneva',sans-serif;
    `;

    const btn = (label, fn) => {
      const b = document.createElement('button');
      b.textContent = label;
      b.style.cssText = `
        padding:6px 14px; border:1px solid #fff; background:rgba(0,0,0,.6);
        color:#fff; cursor:pointer; font-size:13px; font-family:inherit;
      `;
      b.addEventListener('click', fn);
      return b;
    };

    bar.appendChild(btn('↺ Random', () => { this._random(); this._closeModal(); }));
    bar.appendChild(btn('⬇ Save PNG', () => {
      const a = document.createElement('a');
      a.download = `temper-art-${this._last.generator}-${this._last.seed}.png`;
      a.href = mc.toDataURL('image/png');
      a.click();
    }));
    bar.appendChild(btn('✕ Close', () => this._closeModal()));

    overlay.appendChild(mc);
    overlay.appendChild(bar);
    overlay.addEventListener('click', (e) => { if (e.target === overlay) this._closeModal(); });
    document.body.appendChild(overlay);
    document.body.style.overflow = 'hidden';
    this._modal = overlay;
  },

  _renderModal(scene) {
    if (!this._modalCtx) return;
    render(this._modalCtx, scene);
  },

  _closeModal() {
    if (!this._modal) return;
    this._modal.remove();
    this._modal = null;
    this._modalCanvas = null;
    this._modalCtx = null;
    document.body.style.overflow = '';
  },

  // ── navigation ───────────────────────────────────────────────────────────────

  _random() {
    const seed = Math.floor(Math.random() * 2147483647);
    const gen  = this._last?.generator ?? GENERATORS[0];
    this._draw(seed, gen, true);
    this.pushEvent('seed_changed', { seed, generator: gen });
  },

  _back() {
    if (this.histIdx > 0) {
      this.histIdx--;
      const e = this.history[this.histIdx];
      this._draw(e.seed, e.generator, false);
      this.pushEvent('seed_changed', { seed: e.seed, generator: e.generator });
    }
  },

  _forward() {
    if (this.histIdx < this.history.length - 1) {
      this.histIdx++;
      const e = this.history[this.histIdx];
      this._draw(e.seed, e.generator, false);
      this.pushEvent('seed_changed', { seed: e.seed, generator: e.generator });
    }
  },
};

export default TemperArt;
