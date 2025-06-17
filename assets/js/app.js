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
//# import * as THREE from 'three';

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

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
          .addTo(this.map)
          .bindPopup(popupContent, {
            minWidth: 300, // Ensure popup is wide enough for the 300px iframe
            // maxWidth: 320 // Optional: if you want to constrain it further than default
          });
        this.songMarkers.push(marker);
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
