// Blinks service worker. Served at /blinks-sw.js (scope /blinks) so a
// home-screen install of bobbby.online/blinks can receive Web Push. It does
// not intercept fetches — LiveView keeps its own websocket — it only turns
// pushes into notifications and opens the link when tapped.

self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));

self.addEventListener("push", (event) => {
  let data = {};
  try { data = event.data ? event.data.json() : {}; } catch (_) { data = { body: event.data && event.data.text() }; }

  const title = data.title || "new blink";
  const options = {
    body: data.body || "",
    icon: "/static/blinks-pwa/icon-192.png",
    badge: "/static/blinks-pwa/icon-192.png",
    tag: data.tag || (data.blink_id ? "blink-" + data.blink_id : undefined),
    data: { url: data.url || "/blinks", blink_id: data.blink_id || null },
    // Stay on screen until dismissed where the platform allows it (Chrome,
    // Android). iOS ignores this: its banner timing is a per-app OS setting.
    requireInteraction: true,
    renotify: false,
  };

  // iOS requires every push to show a notification (userVisibleOnly).
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const url = (event.notification.data && event.notification.data.url) || "/blinks";

  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then((wins) => {
      const inScope = wins.find((w) => w.url && w.url.includes("/blinks"));
      if (inScope && "focus" in inScope) {
        inScope.focus();
        return inScope.navigate ? inScope.navigate(url) : null;
      }
      return self.clients.openWindow(url);
    })
  );
});
