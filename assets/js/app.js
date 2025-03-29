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
