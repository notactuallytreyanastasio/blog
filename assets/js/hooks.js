import BreakoutGame from "./hooks/breakout_game";
import GameAnimations from "./hooks/game_animations";
import BezierTriangles from "./hooks/bezier_triangles";
import MtaBusMap from "./hooks/mta_bus_map";
import BubbleGame from "./hooks/bubble_game";
import { Joyride } from "../../deps/live_joyride/assets/js";

// Sunflower Background Animation
const GOLDEN_ANGLE = Math.PI * (3 - Math.sqrt(5));

const SunflowerBackground = {
  mounted() {
    const canvas = this.el;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let width = window.innerWidth;
    let height = window.innerHeight;
    let time = 0;
    let animationId = null;

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

      animationId = requestAnimationFrame(animate);
    };

    animate();
    this.animationId = animationId;
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

const PostExpander = {
  mounted() {
    this.handleEvent("toggle_post", ({slug}) => {
      const postCard = document.getElementById(`post-${slug}`);
      const content = document.getElementById(`content-${slug}`);

      if (postCard && content) {
        postCard.classList.toggle('expanded');
      }
    });
  }
};

const CardGrid = {
  mounted() {
    this.adjustGrid();
    this.resizeObserver = new ResizeObserver(() => this.adjustGrid());
    this.resizeObserver.observe(this.el);
  },
  updated() {
    this.adjustGrid();
  },
  destroyed() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
  },
  adjustGrid() {
    const cards = this.el.querySelectorAll('.card-wrapper');
    if (cards.length === 0) return;

    // First, show all cards to measure properly
    cards.forEach(card => card.style.display = '');

    // Wait for layout, then measure
    requestAnimationFrame(() => {
      const firstCard = cards[0];
      const firstTop = firstCard.offsetTop;

      // Find how many cards are in the first row
      let cardsPerRow = 0;
      for (const card of cards) {
        if (card.offsetTop === firstTop) {
          cardsPerRow++;
        } else {
          break;
        }
      }

      // Show exactly 2 rows worth
      const showCount = cardsPerRow * 2;
      cards.forEach((card, i) => {
        card.style.display = i < showCount ? '' : 'none';
      });
    });
  }
};

const TourSpotlight = {
  mounted() {
    this.positionElements();
  },
  updated() {
    this.positionElements();
  },
  positionElements() {
    const targetId = this.el.dataset.target;
    if (!targetId) return;

    const target = document.getElementById(targetId);
    if (!target) return;

    const rect = target.getBoundingClientRect();
    const padding = 8;

    // Position spotlight
    this.el.style.top = `${rect.top - padding}px`;
    this.el.style.left = `${rect.left - padding}px`;
    this.el.style.width = `${rect.width + padding * 2}px`;
    this.el.style.height = `${rect.height + padding * 2}px`;

    // Position tooltip
    const tooltip = document.getElementById('tour-tooltip');
    if (!tooltip) return;

    const tooltipRect = tooltip.getBoundingClientRect();
    const position = tooltip.className.split(' ').find(c => ['bottom', 'top', 'right', 'center'].includes(c));

    if (position === 'bottom') {
      tooltip.style.top = `${rect.bottom + 20}px`;
      tooltip.style.left = `${Math.max(20, rect.left + rect.width / 2 - tooltipRect.width / 2)}px`;
    } else if (position === 'top') {
      tooltip.style.top = `${rect.top - tooltipRect.height - 20}px`;
      tooltip.style.left = `${Math.max(20, rect.left + rect.width / 2 - tooltipRect.width / 2)}px`;
    } else if (position === 'right') {
      tooltip.style.top = `${rect.top + rect.height / 2 - tooltipRect.height / 2}px`;
      tooltip.style.left = `${rect.right + 20}px`;
    }

    // Scroll target into view if needed
    if (rect.top < 100 || rect.bottom > window.innerHeight - 100) {
      target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }
};

export default {
  BreakoutGame,
  GameAnimations,
  BezierTriangles,
  MtaBusMap,
  BubbleGame,
  PostExpander,
  TourSpotlight,
  CardGrid,
  SunflowerBackground,
  Joyride
};