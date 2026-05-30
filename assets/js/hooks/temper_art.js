import { generate, render, GENERATORS } from '../../vendor/temper-engine.js';

// TemperArt — LiveView hook for the Temper-compiled generative art engine.
//
// The LiveView owns seed + generator state and pushes `draw` events when they
// change.  All rendering is client-side: the hook calls generate() (Temper JS
// engine) and render() (canvas 2D) synchronously on every draw event.

const TemperArt = {
  mounted() {
    this.canvas = this.el.querySelector('#art-canvas');
    this.ctx = this.canvas.getContext('2d');
    this.history = [];
    this.histIdx = -1;

    // Expose generator list to the LiveView immediately.
    this.pushEvent('generators_ready', { generators: GENERATORS });

    // Resize canvas to match its CSS size.
    this._resize();
    window.addEventListener('resize', () => this._resize());

    // Server pushes `draw` whenever seed or generator change.
    this.handleEvent('draw', ({ seed, generator }) => {
      this._draw(seed, generator, true);
    });

    // Keyboard shortcuts handled in the hook so they work without server round-trips.
    this._keydown = (e) => {
      if (e.target.tagName === 'INPUT') return;
      if (e.key === 'r' || e.key === 'R') this._random();
      if (e.key === 'ArrowLeft')  this._back();
      if (e.key === 'ArrowRight') this._forward();
    };
    document.addEventListener('keydown', this._keydown);
  },

  destroyed() {
    document.removeEventListener('keydown', this._keydown);
  },

  _resize() {
    const rect = this.canvas.getBoundingClientRect();
    this.canvas.width  = rect.width  || 800;
    this.canvas.height = rect.height || 600;
    // Re-render at new size if we have a scene.
    if (this._last) this._draw(this._last.seed, this._last.generator, false);
  },

  _draw(seed, generator, push) {
    const t0 = performance.now();
    const scene = generate(seed, generator, this.canvas.width, this.canvas.height);
    render(this.ctx, scene);
    const ms = (performance.now() - t0).toFixed(1);
    this._last = { seed, generator };
    if (push) {
      this.history = this.history.slice(0, this.histIdx + 1);
      this.history.push({ seed, generator });
      this.histIdx = this.history.length - 1;
    }
    this.pushEvent('render_done', { seed, generator, shapes: scene.shapes.length, ms });
  },

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
