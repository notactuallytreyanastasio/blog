# The MTA bus map's logic

What `/mta-bus-map` computes rather than fetches, shared by the server
(`src/99_mta.blimp`, which asks MTA Bus Time where the buses are) and the
page's program (`static/mta/mta.blimp`, which draws the controls and hands
Leaflet its markers). The routes themselves are `routes.temper.md`, written
from Bus Time's own lists. Walking the decoded JSON stays Blimp: a Temper
function takes strings and numbers, not a Blimp map.

## Asking Bus Time

A line reference is Bus Time's id for a route, as it goes in a query string:
the space and the `+` escaped. It is not worked out from the route's name,
because it cannot be: `Q6` is `MTABC_Q06`, `Q10` is `MTABC_Q10` and `M21` is
`MTA NYCT_M21`.

    export let mta_line_param(ref: String): String {
      let a = ref.split(" ").join("%20") { (p): String => p };
      a.split("+").join("%2B") { (p): String => p }
    }

`vehicle-monitoring-v2.json`, asked directly because the server's HTTP client
does not follow redirects. Never with `version=2`: this address answers a
request that carries it with a 200 whose body is an HTML "404 Not Found" page
(`test/fixtures/mta/version_404.html`, 2026-09-29). The key is the server's,
from its environment.

    export let mta_url(key: String, ref: String): String {
      "https://bustime.mta.info/api/siri/vehicle-monitoring-v2.json?key=${key}&LineRef=${mta_line_param(ref)}&VehicleMonitoringDetailLevel=normal"
    }

What a page shows before anyone chooses.

    export let mta_initial: List<String> = ["M14A-SBS", "M14D-SBS", "M21", "M34-SBS"];

## Boroughs

The keys the page's buttons send, and their names. Express buses cross
boroughs, so they are a tab of their own.

    export let mta_borough_name(borough: String): String {
      if (borough == "manhattan") {
        "Manhattan"
      } else if (borough == "brooklyn") {
        "Brooklyn"
      } else if (borough == "queens") {
        "Queens"
      } else if (borough == "bronx") {
        "The Bronx"
      } else if (borough == "staten") {
        "Staten Island"
      } else if (borough == "express") {
        "Express"
      } else {
        "All Boroughs"
      }
    }

    export let mta_title(borough: String): String { "${mta_borough_name(borough)} MTA Bus Tracker" }

    export let mta_select_label(borough: String): String {
      if (borough == "all") { "Show every route" } else { "Show all of ${mta_borough_name(borough)}" }
    }

## A bus on the map

A dot and the route's name. Labels for where a bus is going and which way
sat under every bus and piled up into an unreadable stack at any zoom, so
they are the popup's now and the stylesheet drops the name too when the map
is far out. `turn` is how far to rotate the dot's arrow, in CSS degrees, or
empty for a bus that is not going anywhere.

Bus Time's destination goes into this HTML, so it is escaped.

    export let mta_escape(s: String): String {
      let s1 = s.split("&").join("&amp;") { (p): String => p };
      let s2 = s1.split("<").join("&lt;") { (p): String => p };
      let s3 = s2.split(">").join("&gt;") { (p): String => p };
      let s4 = s3.split("\"").join("&quot;") { (p): String => p };
      s4.split("'").join("&#039;") { (p): String => p }
    }

    export let mta_icon_html(route: String, color: String, turn: String): String {
      let dot = if (turn.isEmpty) {
        "<span class=\"mta-dot\"></span>"
      } else {
        "<span class=\"mta-dot mta-moving\" style=\"transform:rotate(${turn}deg)\"></span>"
      };
      "<div class=\"mta-bus\" style=\"--route:${color}\">${dot}<span class=\"mta-name\">${mta_escape(route)}</span></div>"
    }

`next` and `detail` are lines already in words, either possibly empty.

    let mta_line(class: String, text: String): String {
      if (text.isEmpty) { "" } else { "<div class=\"${class}\">${mta_escape(text)}</div>" }
    }

    export let mta_popup_html(route: String, color: String, description: String, destination: String, next: String, detail: String): String {
      let to = if (destination.isEmpty) { "" } else { "To ${destination}" };
      "<div class=\"mta-pop\" style=\"--route:${color}\"><div class=\"mta-pop-route\">${mta_escape(route)}</div>${mta_line("mta-pop-desc", description)}${mta_line("mta-pop-to", to)}${mta_line("mta-pop-next", next)}${mta_line("mta-pop-meta", detail)}</div>"
    }

A marker is kept from one update to the next by route and vehicle.

    export let mta_bus_key(route: String, id: String): String { "${route}-${id}" }
