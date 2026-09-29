// SunflowerBackground as it was in assets/js/app.js (lines 52-184 at af784de),
// kept verbatim as the reference the Blimp port is tested against.
const GOLDEN_ANGLE = Math.PI * (3 - Math.sqrt(5));

const SunflowerBackground = {
  mounted() {
    const canvas = this.el;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let width = window.innerWidth;
    let height = window.innerHeight;
    let time = 0;

    const resize = () => {
      width = window.innerWidth;
      height = window.innerHeight;
      canvas.width = width;
      canvas.height = height;
    };

    resize();
    window.addEventListener('resize', resize);
    this.resizeHandler = resize;

    const colors = ['#ff00ff', '#00ffff', '#ffff00', '#ff6600', '#00ff00', '#ff0099', '#9933ff', '#00ffcc'];
    const getColor = (i) => colors[i % colors.length];

    const animate = () => {
      time += 0.005;

      ctx.fillStyle = 'rgba(26, 26, 46, 0.03)';
      ctx.fillRect(0, 0, width, height);

      const centerX = width / 2;
      const centerY = height * 0.4;
      const numSeeds = 250;
      const scale = Math.min(width, height) * 0.35;
      const pulseScale = 1 + Math.sin(time * 2) * 0.1;

      // Draw seeds
      for (let i = 0; i < numSeeds; i++) {
        const angle = i * GOLDEN_ANGLE + time;
        const radius = Math.sqrt(i) * (scale / Math.sqrt(numSeeds)) * pulseScale;
        const waveX = Math.sin(time * 3 + i * 0.05) * 15;
        const waveY = Math.cos(time * 2 + i * 0.03) * 15;
        const x = centerX + Math.cos(angle) * radius + waveX;
        const y = centerY + Math.sin(angle) * radius + waveY;
        const colorIndex = Math.floor(i + time * 50);
        const color = getColor(colorIndex);
        const size = 2 + Math.sin(time * 4 + i * 0.1) * 1.5 + (i / numSeeds) * 3;

        ctx.save();
        ctx.shadowBlur = 20;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.globalAlpha = 0.5 + Math.sin(time * 3 + i * 0.2) * 0.3;
        ctx.beginPath();
        ctx.arc(x, y, size, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
      }

      // Spiral arms
      for (let arm = 0; arm < 5; arm++) {
        ctx.save();
        const armColor = getColor(arm + Math.floor(time * 5));
        ctx.strokeStyle = armColor;
        ctx.lineWidth = 2;
        ctx.shadowBlur = 15;
        ctx.shadowColor = armColor;
        ctx.globalAlpha = 0.25;
        ctx.beginPath();
        for (let t = 0; t < 40; t++) {
          const spiralAngle = t * 0.2 + arm * (Math.PI * 2 / 5) + time;
          const spiralRadius = t * 6 + 40;
          const sx = centerX + Math.cos(spiralAngle) * spiralRadius;
          const sy = centerY + Math.sin(spiralAngle) * spiralRadius;
          if (t === 0) ctx.moveTo(sx, sy);
          else ctx.lineTo(sx, sy);
        }
        ctx.stroke();
        ctx.restore();
      }

      // Stem
      ctx.save();
      const stemColor = '#00ff44';
      ctx.strokeStyle = stemColor;
      ctx.lineWidth = 6 + Math.sin(time) * 2;
      ctx.shadowBlur = 20;
      ctx.shadowColor = '#33ff77';
      ctx.globalAlpha = 0.7;
      ctx.lineCap = 'round';
      const stemStartY = centerY + scale * 0.35;
      const stemEndY = height + 50;
      const stemWave = Math.sin(time * 0.5) * 20;
      ctx.beginPath();
      ctx.moveTo(centerX, stemStartY);
      ctx.bezierCurveTo(
        centerX + stemWave, stemStartY + (stemEndY - stemStartY) * 0.3,
        centerX - stemWave, stemStartY + (stemEndY - stemStartY) * 0.6,
        centerX + stemWave * 0.5, stemEndY
      );
      ctx.stroke();

      // Leaves
      for (let leaf = 0; leaf < 3; leaf++) {
        const leafY = stemStartY + (stemEndY - stemStartY) * (0.15 + leaf * 0.2);
        const leafSide = leaf % 2 === 0 ? 1 : -1;
        const leafWave = Math.sin(time * 2 + leaf) * 5;
        const leafX = centerX + leafSide * (15 + leafWave);
        ctx.fillStyle = stemColor;
        ctx.globalAlpha = 0.6;
        ctx.beginPath();
        ctx.ellipse(leafX + leafSide * 20, leafY, 25 + Math.sin(time + leaf) * 4, 10, leafSide * (0.4 + Math.sin(time * 0.5) * 0.1), 0, Math.PI * 2);
        ctx.fill();
      }
      ctx.restore();

      this.animationId = requestAnimationFrame(animate);
    };

    animate();
  },

  destroyed() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
    if (this.resizeHandler) {
      window.removeEventListener('resize', this.resizeHandler);
    }
  }
};

module.exports = { SunflowerBackground };
