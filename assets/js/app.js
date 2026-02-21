// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Highlight from "./hooks/highlight"
import CursorTracker from "./hooks/cursor_tracker"
import FocusInput from "./hooks/focus_input"
import GenerativeArt from "./hooks/generative_art"
import Blackjack from "./hooks/blackjack"
import MarkdownEditor, { MarkdownInput } from "./hooks/markdown_editor"
import BezierTriangles from "./hooks/bezier_triangles"
import MtaBusMap from "./hooks/mta_bus_map"
import BubbleGame from "./hooks/bubble_game"
import FlipCard from "./hooks/flip_card"
import PhishChart from "./hooks/phish_chart"
import PhishAudio from "./hooks/phish_audio"
import NycMap from "./hooks/nyc_map"
//# import * as THREE from 'three';

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

// CardGrid hook for 2-row display
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

    cards.forEach(card => card.style.display = '');

    requestAnimationFrame(() => {
      const firstCard = cards[0];
      const firstTop = firstCard.offsetTop;

      let cardsPerRow = 0;
      for (const card of cards) {
        if (card.offsetTop === firstTop) {
          cardsPerRow++;
        } else {
          break;
        }
      }

      const showCount = cardsPerRow * 2;
      cards.forEach((card, i) => {
        card.style.display = i < showCount ? '' : 'none';
      });
    });
  }
};

// Joyride hook - bridges DOM position reading to Elixir (minimal JS)
const Joyride = {
  mounted() {
    this.target = null;

    // Listen for goto events from Elixir
    this.handleEvent("joyride:goto", ({ target }) => {
      this.target = target;
      this.findAndReport();
    });

    // Update position on resize/scroll
    this.onResize = () => this.reportPosition();
    window.addEventListener("resize", this.onResize);
    window.addEventListener("scroll", this.onResize, true);
  },

  destroyed() {
    window.removeEventListener("resize", this.onResize);
    window.removeEventListener("scroll", this.onResize, true);
  },

  findAndReport() {
    if (!this.target) return;

    const el = document.querySelector(`[data-joyride="${this.target}"]`);
    if (!el) {
      console.warn("[Joyride] Element not found:", this.target);
      return;
    }

    // Scroll into view if needed
    const rect = el.getBoundingClientRect();
    if (rect.top < 50 || rect.bottom > window.innerHeight - 50) {
      el.scrollIntoView({ behavior: "smooth", block: "center" });
      setTimeout(() => this.reportPosition(), 350);
    } else {
      this.reportPosition();
    }
  },

  reportPosition() {
    if (!this.target) return;

    const el = document.querySelector(`[data-joyride="${this.target}"]`);
    if (!el) return;

    const rect = el.getBoundingClientRect();
    this.pushEventTo(this.el, "rect", {
      rect: { x: rect.x, y: rect.y, width: rect.width, height: rect.height },
      window: { width: window.innerWidth, height: window.innerHeight }
    });
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Attempt to capture Leaflet extensions early
let capturedMarkerClusterGroupFn = null;
if (window.L && typeof window.L.markerClusterGroup === 'function') {
  capturedMarkerClusterGroupFn = window.L.markerClusterGroup;
  console.log('app.js top-level: Successfully captured L.markerClusterGroup function.');
} else {
  console.error('app.js top-level: FAILED to capture L.markerClusterGroup function. window.L:', window.L, 'typeof L.markerClusterGroup:', window.L ? typeof window.L.markerClusterGroup : 'L is undefined');
}

// Hook for scrolling to top when new skeets are loaded
let Hooks = {}

Hooks.MapHook = {
  map: null,
  songMarkers: [], // To keep track of Leaflet marker instances

  mounted() {
    // Ensure Leaflet (L) is available
    if (typeof L === 'undefined') {
      console.error("Leaflet is not loaded! Make sure it's included before app.js or globally available.");
      this.el.innerHTML = "<p style='color:red; text-align:center;'>Error: Leaflet library not found.</p>";
      return;
    }

    console.log(`MapHook mounted. Target element (this.el):`, this.el);
    console.log(`Target element ID: ${this.el.id}`);
    
    if (!document.getElementById(this.el.id)) {
      console.error(`CRITICAL: Element with ID ${this.el.id} NOT FOUND in DOM at map init time!`);
      return; // Stop if element isn't there
    }
    console.log("Attempting L.map('mapid', ...);");
    try {
      this.map = L.map(this.el.id).setView([39.8283, -98.5795], 4); // Default to US view
      console.log("L.map() call successful. Map object:", this.map);
    } catch (e) {
      console.error("CRITICAL ERROR during L.map() initialization:", e);
      this.el.innerHTML = `<p style='color:red; text-align:center;'>CRITICAL ERROR: Map initialization failed: ${e.message}</p>`;
      return; // Stop if L.map fails
    }

    console.log("Attempting to add CartoDB tile layer...");
    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
      subdomains: 'abcd',
      maxZoom: 19
    }).addTo(this.map);

    console.log("Map object created, CartoDB tiles added.");
    this.songMarkers = []; // Initialize array to store song markers
    console.log("MapHook.mounted: Checking L object and captured function.");
    console.log("MapHook.mounted: typeof window.L.markerClusterGroup (direct check):", typeof window.L.markerClusterGroup);
    console.log("MapHook.mounted: typeof capturedMarkerClusterGroupFn (captured check):", typeof capturedMarkerClusterGroupFn);

    if (typeof capturedMarkerClusterGroupFn === 'function') {
      console.log("MapHook.mounted: Using capturedMarkerClusterGroupFn.");
      this.markersClusterGroup = capturedMarkerClusterGroupFn(); // Use the captured function
    } else {
      console.error("MapHook.mounted: capturedMarkerClusterGroupFn is NOT a function. Falling back to direct check or failing.");
      if (typeof window.L.markerClusterGroup === 'function') {
        console.warn("MapHook.mounted: Direct window.L.markerClusterGroup IS a function now, but captured one was not. This is odd.");
        this.markersClusterGroup = window.L.markerClusterGroup();
      } else {
        console.error("MapHook.mounted: Both captured and direct L.markerClusterGroup are not functions. Cannot create cluster group.");
        // this.el.innerHTML = "<p style='color:red;'>Error: Marker clustering library not available.</p>"; // Optional: inform user
        return; // Stop if still not usable
      }
    }
    // this.markersClusterGroup = window.L.markerClusterGroup(); // Original attempt
    this.map.addLayer(this.markersClusterGroup); // Add cluster group to map

    // Handle map click
    this.map.on('click', (e) => {
      console.log("Map clicked at: ", e.latlng);
      this.pushEvent("map_clicked", { lat: e.latlng.lat, lng: e.latlng.lng });
    });

    // Handle location found
    this.map.on('locationfound', (e) => {
      console.log("Leaflet 'locationfound' event: ", e);
      const { lat, lng } = e.latlng;
      console.log(`Location found: Lat: ${lat}, Lng: ${lng}. Manually setting view.`);
      this.map.setView(e.latlng, 16); // Manually set view to zoom level 16
      console.log("Manual setView called.");
      // Delay pushing the event slightly to allow map to potentially settle after setView
      setTimeout(() => {
        console.log("Delayed: Pushing 'got_location' to server.");
        this.pushEvent("got_location", { lat: lat, lng: lng });
      }, 100); // 100ms delay, can be adjusted
    });

    // Handle location error
    this.map.on('locationerror', (e) => {
      console.error("Leaflet 'locationerror' event: ", e.message);
      // Consider providing user feedback here if location is critical and fails
      // For example, by pushing an event to the server or showing a message on the client.
    });

    // Add event listener for a new geolocation button
    const locateButton = document.getElementById('locate-me-button');
    if (locateButton) {
      locateButton.addEventListener('click', () => {
        console.log("'Locate Me' button clicked. Requesting location...");
        this.map.locate({setView: true, maxZoom: 16}); // setView: true to move map
      });
    } else {
      console.warn("'locate-me-button' not found in the DOM.");
    }

    // Load initial markers (if any)
    try {
      const initialMarkersData = JSON.parse(this.el.dataset.markers || "[]");
      if (initialMarkersData.length > 0) {
        console.log("Loading initial markers: ", initialMarkersData);
        initialMarkersData.forEach(markerData => this.addSongMarkerToMap(markerData));
      }
    } catch (e) {
      console.error("Error parsing initial markers data:", e);
    }

    // Listen for new_marker events pushed from the server (via PubSub)
    this.handleEvent("new_marker", (markerData) => {
      console.log("Received 'new_marker' event from server: ", markerData);
      this.addSongMarkerToMap(markerData);
    });
    
    // Force a resize after a short delay to ensure proper rendering, especially if map div was hidden/resized
    setTimeout(() => {
      if (this.map) {
        console.log("Forcing map.invalidateSize() after timeout...");
        this.map.invalidateSize();
      }
    }, 150); // A slight delay
  },

  // Helper function to escape HTML special characters for security
  escapeHtml(unsafe) {
    if (unsafe === null || typeof unsafe === 'undefined') return '';
    return unsafe
         .toString()
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
  },

  addSongMarkerToMap(markerData) {
    if (markerData && typeof markerData.lat === 'number' && typeof markerData.lng === 'number') {
      // A very basic check to prevent adding the exact same marker if data is identical
      // For a robust solution, markers should have unique IDs.
      const existing = this.songMarkers.find(m =>
        m.getLatLng().lat === markerData.lat &&
        m.getLatLng().lng === markerData.lng &&
        m.getPopup().getContent().includes(markerData.link || "#") // Check link as well
      );

      if (!existing) {
        let popupContent;
        if (markerData.embed_url) {
          // Spotify compact embed is 80px high, or 152px for a taller version. Let's use 152px.
          // Width can be 100% of popup, Leaflet default max-width for popups is 300px.
          // The iframe needs a unique title for accessibility if multiple are on the page.
          const userName = markerData.name || "Anonymous";
          const noteContent = markerData.note ? `<p style="margin-bottom: 5px; white-space: pre-wrap;">${this.escapeHtml(markerData.note)}</p>` : "";
          
          let spotifyContent;
          if (markerData.embed_url) {
            const uniqueTitle = `Spotify Embed ${userName} ${Date.now()}`;
            spotifyContent = 
              `<iframe title="${uniqueTitle}" style="border-radius:12px" ` +
              `src="${markerData.embed_url}" ` +
              `width="300" height="152" frameBorder="0" allowfullscreen="" ` +
              `allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>`;
          } else {
            spotifyContent = `<a href="${markerData.link || "#"}" target="_blank" rel="noopener noreferrer">Listen on Spotify</a>`;
          }

          popupContent = 
            `<div style="margin-bottom: 8px;"><strong>${this.escapeHtml(userName)}</strong></div>` +
            noteContent +
            spotifyContent;
        } else {
          // Fallback for very old markers or if data is incomplete (should ideally not happen with new structure)
          popupContent = `<b>${markerData.name || "Anonymous"}</b><br><a href="${markerData.link || "#"}" target="_blank" rel="noopener noreferrer">Listen on Spotify</a>`;
        }

        const marker = L.marker([markerData.lat, markerData.lng])
          // .addTo(this.map) // Markers are added to the cluster group
          .bindPopup(popupContent, {
            minWidth: 300, // Ensure popup is wide enough for the 300px iframe
            // maxWidth: 320 // Optional: if you want to constrain it further than default
          });
        this.markersClusterGroup.addLayer(marker); // Add the marker to the cluster group
        this.songMarkers.push(marker); // Still keep track if needed for other purposes
        console.log("Added new marker to map with embed/link.");
      } else {
        console.log("Marker already exists, not adding duplicate.", markerData);
      }
    } else {
      console.warn("Received invalid marker data:", markerData);
    }
  },

  destroyed() {
    if (this.map) {
      this.map.remove();
      this.map = null;
    }
    this.songMarkers = []; // Clear the array of marker instances
  }
};
Hooks.PsychedelicTree = {
  mounted() {
    const canvas = this.el;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const container = canvas.parentElement;
    let width = container.offsetWidth;
    let height = container.offsetHeight;
    let time = 0;

    const resize = () => {
      width = container.offsetWidth;
      height = container.offsetHeight;
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

      // Clear with transparency to show background through
      ctx.clearRect(0, 0, width, height);

      const centerX = width / 2;
      const centerY = height * 0.35;
      const numSeeds = 200;
      const scale = Math.min(width, height) * 0.3;
      const pulseScale = 1 + Math.sin(time * 2) * 0.1;

      // Draw seeds (flower head)
      for (let i = 0; i < numSeeds; i++) {
        const angle = i * (Math.PI * (3 - Math.sqrt(5))) + time;
        const radius = Math.sqrt(i) * (scale / Math.sqrt(numSeeds)) * pulseScale;
        const waveX = Math.sin(time * 3 + i * 0.05) * 10;
        const waveY = Math.cos(time * 2 + i * 0.03) * 10;
        const x = centerX + Math.cos(angle) * radius + waveX;
        const y = centerY + Math.sin(angle) * radius + waveY;
        const colorIndex = Math.floor(i + time * 50);
        const color = getColor(colorIndex);
        const size = 2 + Math.sin(time * 4 + i * 0.1) * 1.5 + (i / numSeeds) * 2;

        ctx.save();
        ctx.shadowBlur = 15;
        ctx.shadowColor = color;
        ctx.fillStyle = color;
        ctx.globalAlpha = 0.6 + Math.sin(time * 3 + i * 0.2) * 0.3;
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
        ctx.shadowBlur = 12;
        ctx.shadowColor = armColor;
        ctx.globalAlpha = 0.3;
        ctx.beginPath();
        for (let t = 0; t < 30; t++) {
          const spiralAngle = t * 0.2 + arm * (Math.PI * 2 / 5) + time;
          const spiralRadius = t * 5 + 30;
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
      ctx.lineWidth = 5 + Math.sin(time) * 2;
      ctx.shadowBlur = 15;
      ctx.shadowColor = '#33ff77';
      ctx.globalAlpha = 0.8;
      ctx.lineCap = 'round';
      const stemStartY = centerY + scale * 0.4;
      const stemEndY = height + 20;
      const stemWave = Math.sin(time * 0.5) * 15;
      ctx.beginPath();
      ctx.moveTo(centerX, stemStartY);
      ctx.bezierCurveTo(
        centerX + stemWave, stemStartY + (stemEndY - stemStartY) * 0.3,
        centerX - stemWave, stemStartY + (stemEndY - stemStartY) * 0.6,
        centerX + stemWave * 0.5, stemEndY
      );
      ctx.stroke();
      ctx.restore();

      this.animationId = requestAnimationFrame(animate);
    };

    animate();
  },
  destroyed() {
    if (this.animationId) cancelAnimationFrame(this.animationId);
    if (this.resizeHandler) window.removeEventListener('resize', this.resizeHandler);
  }
};

Hooks.ChatScroll = {
  mounted() {
    this.scrollToBottom();
  },
  updated() {
    this.scrollToBottom();
  },
  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight;
  }
};

Hooks.Draggable = {
  mounted() {
    const el = this.el;
    const titleBar = el.querySelector('.title-bar, .aim-chat-titlebar, .aim-name-dialog-titlebar, .os-titlebar');
    if (!titleBar) return;

    let isDragging = false;
    let startX, startY, initialX, initialY;

    // Make element positioned if not already
    const style = window.getComputedStyle(el);
    if (style.position === 'static') {
      el.style.position = 'relative';
    }

    titleBar.style.cursor = 'grab';

    const onMouseDown = (e) => {
      // Don't drag if clicking buttons
      if (e.target.closest('button, a, .close-box, .aim-control-btn, .os-btn-close')) return;

      isDragging = true;
      titleBar.style.cursor = 'grabbing';

      startX = e.clientX;
      startY = e.clientY;

      const rect = el.getBoundingClientRect();
      initialX = rect.left;
      initialY = rect.top;

      // Convert to fixed positioning for dragging
      el.style.position = 'fixed';
      el.style.transform = 'none';
      el.style.left = initialX + 'px';
      el.style.top = initialY + 'px';
      el.style.right = 'auto';
      el.style.bottom = 'auto';
      el.style.zIndex = '1000';

      e.preventDefault();
    };

    const onMouseMove = (e) => {
      if (!isDragging) return;

      const dx = e.clientX - startX;
      const dy = e.clientY - startY;

      el.style.left = (initialX + dx) + 'px';
      el.style.top = (initialY + dy) + 'px';
    };

    const onMouseUp = () => {
      if (!isDragging) return;
      isDragging = false;
      titleBar.style.cursor = 'grab';
    };

    titleBar.addEventListener('mousedown', onMouseDown);
    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);

    // Touch support for mobile
    titleBar.addEventListener('touchstart', (e) => {
      if (e.target.closest('button, a, .close-box, .aim-control-btn, .os-btn-close')) return;
      const touch = e.touches[0];
      onMouseDown({ clientX: touch.clientX, clientY: touch.clientY, target: e.target, preventDefault: () => {} });
    }, { passive: true });

    document.addEventListener('touchmove', (e) => {
      if (!isDragging) return;
      const touch = e.touches[0];
      onMouseMove({ clientX: touch.clientX, clientY: touch.clientY });
    }, { passive: true });

    document.addEventListener('touchend', onMouseUp);

    this.cleanup = () => {
      titleBar.removeEventListener('mousedown', onMouseDown);
      document.removeEventListener('mousemove', onMouseMove);
      document.removeEventListener('mouseup', onMouseUp);
    };
  },
  destroyed() {
    if (this.cleanup) this.cleanup();
  }
};

Hooks.ScrollToTop = {
  mounted() {
    this.handleEvent("scroll-to-top", () => {
      // Use requestAnimationFrame to ensure DOM is updated before scrolling
      requestAnimationFrame(() => {
        // First try to focus on the anchor element
        const anchor = document.getElementById('skeet-anchor');
        if (anchor) {
          anchor.scrollIntoView({behavior: 'auto', block: 'start'});
        } else {
          // Fallback to absolute top
          window.scrollTo(0, 0);
        }

        // Double-check with a slight delay to ensure it worked
        setTimeout(() => {
          if (window.scrollY > 10) {
            window.scrollTo(0, 0);
          }
        }, 50);
      });
    });
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {
    Highlight,
    CursorTracker,
    FocusInput,
    GenerativeArt,
    Blackjack,
    MarkdownEditor,
    MarkdownInput,
    BezierTriangles,
    MtaBusMap,
    BubbleGame,
    FlipCard,
    SunflowerBackground,
    CardGrid,
    Joyride,
    PhishChart,
    PhishAudio,
    NycMap,
    ...Hooks
  }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

//window.THREE = THREE;
