// Wires the phx:page-loading-start/stop lifecycle (fired by LiveView on
// every navigation and connected form submit) to a topbar progress bar, and
// reports a GA4 page_view on the way back down.
//
// Extracted from app.js so it can be unit tested without booting a
// LiveSocket or a browser DOM: `target` just needs addEventListener/
// dispatchEvent (window in production, a plain EventTarget in tests).
export function wireTopbarProgress(
  target,
  topbar,
  { getGtag = () => undefined, getPath = () => "", getTitle = () => "" } = {}
) {
  target.addEventListener("phx:page-loading-start", () => topbar.show(300));

  target.addEventListener("phx:page-loading-stop", () => {
    topbar.hide();

    // Read gtag at event time, not wiring time: the GA snippet can still be
    // loading (or blocked) when app.js first runs, and this listener fires
    // on every LiveView nav for the lifetime of the page.
    const gtag = getGtag();
    if (typeof gtag === "function") {
      gtag("event", "page_view", {
        page_path: getPath(),
        page_title: getTitle()
      });
    }
  });
}
