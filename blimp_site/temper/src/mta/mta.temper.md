# The MTA bus map's logic

What `/mta-bus-map` computes rather than fetches, shared by the server
(`src/99_mta.blimp`, which asks MTA Bus Time where the buses are) and the
page's program (`static/mta/mta.blimp`, which draws the controls and hands
Leaflet its markers). A port of `Blog.Mta.Routes`, the value-shaping half of
`Blog.Mta.Client`, the route lists of `BlogWeb.MTAComponents` and the
colours and marker HTML of the `MtaBusMap` hook. Walking the decoded JSON
stays Blimp: a Temper function takes strings and numbers, not a Blimp map.

## The routes

`Blog.Mta.Routes` kept three maps, display name to line reference, for 189
routes. Every line reference is the display name with `-SBS` written `+`
and `-LTD` written `L`, after `MTA NYCT_`, so only the names are kept here
and the reference is made from the name.

    export let mta_line_ref(route: String): String {
      let sbs = route.split("-SBS").join("+") { (p): String => p };
      let ltd = sbs.split("-LTD").join("L") { (p): String => p };
      "MTA NYCT_${ltd}"
    }

The same, as it goes in a query string: the space and the `+` escaped, as
Req escaped them.

    export let mta_line_param(route: String): String {
      let ref = mta_line_ref(route);
      let a = ref.split(" ").join("%20") { (p): String => p };
      a.split("+").join("%2B") { (p): String => p }
    }

The request `Blog.Mta.Client.fetch_route/1` made for one route, less one
parameter. `vehicle-monitoring.json` now answers with a 302 to
`vehicle-monitoring-v2.json`, which Req followed; the server's HTTP client
does not follow redirects, so this asks the new address itself. The
redirect drops `version=2`, and it has to: the v2 address answers a
request that carries it with a 200 whose body is an HTML "404 Not Found"
page (`test/fixtures/mta/version_404.html`, 2026-09-29). The key is the
server's, from its environment.

    export let mta_url(key: String, route: String): String {
      "https://bustime.mta.info/api/siri/vehicle-monitoring-v2.json?key=${key}&LineRef=${mta_line_param(route)}&OperatorRef=MTA%20NYCT&VehicleMonitoringDetailLevel=normal"
    }

The route chooser listed each borough's routes in groups, each group the
routes whose names passed a test. Manhattan's groups came out in the order
an Elixir map of more than 32 keys iterates in, which is its hash order:
production's page, read on 2026-09-29, lists them as below. Brooklyn's and
Queens' were sorted, as strings, so `B100` comes before `B11`.

Crosstown was every name containing one of fourteen prefixes (`M14`, `M21`,
`M22`, `M23`, `M34`, `M42`, `M50`, `M66`, `M72`, `M79`, `M86`, `M96`,
`M106`, `M116`).

    export let mta_crosstown: List<String> = [
      "M23-SBS", "M14A-SBS", "M86-SBS", "M22", "M79-SBS", "M96", "M50", "M14D-SBS",
      "M66", "M34A-SBS", "M21", "M106", "M116", "M42", "M72", "M34-SBS"
    ];

North-South was `^M([1-9]|1[0-5]|98|100|101|102|103|104|60-SBS)$`.

    export let mta_north_south: List<String> = [
      "M102", "M7", "M103", "M2", "M11", "M101", "M4", "M3", "M9", "M15",
      "M98", "M60-SBS", "M1", "M5", "M10", "M100", "M104", "M8", "M12"
    ];

Limited & Express was every name containing `-LTD`.

    export let mta_limited: List<String> = [
      "M4-LTD", "M3-LTD", "M2-LTD", "M1-LTD", "M101-LTD", "M5-LTD", "M102-LTD", "M103-LTD", "M15-LTD"
    ];

Six Manhattan routes pass none of the three tests, so the chooser never
showed them: `M15-SBS`, `M20`, `M31`, `M35`, `M55` and `M57`. They were
still Manhattan routes, picked by "Select All Manhattan Routes" and
"Select All". The port keeps that: they are here, and not in any group.

    export let mta_manhattan_unlisted: List<String> = ["M15-SBS", "M20", "M31", "M35", "M55", "M57"];

Brooklyn: `^B\d+$`, then `-SBS`.

    export let mta_brooklyn_local: List<String> = [
      "B1", "B100", "B103", "B11", "B12", "B13", "B14", "B15", "B16", "B17", "B2", "B24", "B25",
      "B26", "B3", "B31", "B32", "B35", "B36", "B37", "B38", "B39", "B4", "B41", "B43", "B44",
      "B45", "B46", "B47", "B48", "B49", "B52", "B54", "B57", "B6", "B60", "B61", "B62", "B63",
      "B64", "B65", "B67", "B68", "B69", "B7", "B70", "B74", "B8", "B82", "B83", "B84", "B9"
    ];

    export let mta_brooklyn_sbs: List<String> = ["B44-SBS", "B46-SBS", "B82-SBS"];

Queens: `^Q\d+[A-Z]?$`, then `-SBS`.

    export let mta_queens_local: List<String> = [
      "Q1", "Q10", "Q100", "Q101", "Q102", "Q103", "Q104", "Q11", "Q110", "Q111", "Q112", "Q113",
      "Q12", "Q13", "Q15", "Q15A", "Q16", "Q17", "Q18", "Q19", "Q2", "Q20A", "Q20B", "Q21", "Q22",
      "Q23", "Q24", "Q25", "Q26", "Q27", "Q28", "Q29", "Q3", "Q30", "Q31", "Q32", "Q33", "Q34",
      "Q35", "Q36", "Q37", "Q38", "Q39", "Q4", "Q40", "Q41", "Q42", "Q43", "Q44", "Q46", "Q47",
      "Q48", "Q49", "Q5", "Q50", "Q52", "Q53", "Q54", "Q55", "Q56", "Q58", "Q59", "Q6", "Q60",
      "Q64", "Q65", "Q66", "Q67", "Q69", "Q7", "Q70", "Q72", "Q76", "Q77", "Q8", "Q83", "Q84",
      "Q85", "Q88", "Q9"
    ];

    export let mta_queens_sbs: List<String> = ["Q44-SBS", "Q52-SBS", "Q53-SBS", "Q70-SBS"];

What a page shows before anyone chooses: the LiveView's `initial_selected`.

    export let mta_initial: List<String> = ["M14A-SBS", "M14D-SBS", "M21", "M34-SBS"];

Whether a name is one of the 189. The server asks this of every route a
page says it watches, so a page cannot make it ask Bus Time for anything
else.

    let mta_in(xs: List<String>, s: String): Boolean {
      xs.filter { (x): Boolean => x == s }.length > 0
    }

    export let mta_known(route: String): Boolean {
      mta_in(mta_crosstown, route) || mta_in(mta_north_south, route) || mta_in(mta_limited, route) ||
        mta_in(mta_manhattan_unlisted, route) || mta_in(mta_brooklyn_local, route) ||
        mta_in(mta_brooklyn_sbs, route) || mta_in(mta_queens_local, route) || mta_in(mta_queens_sbs, route)
    }

## Boroughs

The borough keys the page's buttons send, and their names
(`Routes.borough_name/1`).

    export let mta_borough_name(borough: String): String {
      if (borough == "manhattan") {
        "Manhattan"
      } else if (borough == "brooklyn") {
        "Brooklyn"
      } else if (borough == "queens") {
        "Queens"
      } else {
        "All Boroughs"
      }
    }

    export let mta_title(borough: String): String { "${mta_borough_name(borough)} MTA Bus Tracker" }

    export let mta_select_borough_label(borough: String): String { "Select All ${mta_borough_name(borough)} Routes" }

The chooser's own button said "Select All" and then the borough, or
nothing for All Routes.

    export let mta_modal_select_label(borough: String): String {
      if (borough == "all") { "Select All" } else { "Select All ${mta_borough_name(borough)}" }
    }

## Colours

Every route's colour, from the hook's `ROUTE_COLORS`; black for anything
else, as there.

    let mta_colors: List<List<String>> = [
      ["M14A-SBS", "#E31837"], ["M14D-SBS", "#FF6B00"], ["M21", "#4CAF50"], ["M22", "#2196F3"],
      ["M23-SBS", "#9C27B0"], ["M34-SBS", "#673AB7"], ["M34A-SBS", "#5E35B1"], ["M42", "#4527A0"],
      ["M50", "#311B92"], ["M66", "#1A237E"], ["M72", "#0D47A1"], ["M79-SBS", "#01579B"],
      ["M86-SBS", "#006064"], ["M96", "#004D40"], ["M106", "#1B5E20"], ["M116", "#33691E"],
      ["M1", "#FF1744"], ["M2", "#F50057"], ["M3", "#D500F9"], ["M4", "#651FFF"],
      ["M5", "#3D5AFE"], ["M7", "#2979FF"], ["M8", "#00B0FF"], ["M9", "#00E5FF"],
      ["M10", "#1DE9B6"], ["M11", "#00E676"], ["M12", "#76FF03"], ["M15", "#FFEA00"],
      ["M15-SBS", "#FFC400"], ["M20", "#FF9100"], ["M31", "#FF3D00"], ["M35", "#795548"],
      ["M55", "#607D8B"], ["M57", "#FF8A80"], ["M60-SBS", "#FF80AB"], ["M98", "#EA80FC"],
      ["M100", "#B388FF"], ["M101", "#8C9EFF"], ["M102", "#82B1FF"], ["M103", "#80D8FF"],
      ["M104", "#84FFFF"], ["M15-LTD", "#A7FFEB"], ["M101-LTD", "#B9F6CA"], ["M102-LTD", "#CCFF90"],
      ["M103-LTD", "#F4FF81"], ["M1-LTD", "#FFE57F"], ["M2-LTD", "#FFD180"], ["M3-LTD", "#FF9E80"],
      ["M4-LTD", "#D7CCC8"], ["M5-LTD", "#CFD8DC"], ["B1", "#C62828"], ["B2", "#AD1457"],
      ["B3", "#6A1B9A"], ["B4", "#4527A0"], ["B6", "#283593"], ["B7", "#1565C0"],
      ["B8", "#0277BD"], ["B9", "#00838F"], ["B11", "#00695C"], ["B12", "#2E7D32"],
      ["B13", "#558B2F"], ["B14", "#9E9D24"], ["B15", "#F9A825"], ["B16", "#FF8F00"],
      ["B17", "#EF6C00"], ["B24", "#D84315"], ["B25", "#BF360C"], ["B26", "#880E4F"],
      ["B31", "#4A148C"], ["B32", "#311B92"], ["B35", "#1A237E"], ["B36", "#0D47A1"],
      ["B37", "#01579B"], ["B38", "#006064"], ["B39", "#004D40"], ["B41", "#1B5E20"],
      ["B43", "#33691E"], ["B44", "#827717"], ["B44-SBS", "#FF0000"], ["B45", "#FF3D00"],
      ["B46", "#795548"], ["B46-SBS", "#D50000"], ["B47", "#616161"], ["B48", "#455A64"],
      ["B49", "#E91E63"], ["B52", "#9C27B0"], ["B54", "#673AB7"], ["B57", "#3F51B5"],
      ["B60", "#2196F3"], ["B61", "#03A9F4"], ["B62", "#00BCD4"], ["B63", "#009688"],
      ["B64", "#4CAF50"], ["B65", "#8BC34A"], ["B67", "#CDDC39"], ["B68", "#FFEB3B"],
      ["B69", "#FFC107"], ["B70", "#FF9800"], ["B74", "#FF5722"], ["B82", "#795548"],
      ["B82-SBS", "#A52A2A"], ["B83", "#9E9E9E"], ["B84", "#607D8B"], ["B100", "#D32F2F"],
      ["B103", "#C2185B"], ["Q1", "#00C853"], ["Q2", "#00E676"], ["Q3", "#69F0AE"],
      ["Q4", "#B9F6CA"], ["Q5", "#1B5E20"], ["Q6", "#2E7D32"], ["Q7", "#388E3C"],
      ["Q8", "#43A047"], ["Q9", "#4CAF50"], ["Q10", "#66BB6A"], ["Q11", "#81C784"],
      ["Q12", "#A5D6A7"], ["Q13", "#00C853"], ["Q15", "#00E676"], ["Q15A", "#69F0AE"],
      ["Q16", "#B9F6CA"], ["Q17", "#1B5E20"], ["Q18", "#2E7D32"], ["Q19", "#388E3C"],
      ["Q20A", "#43A047"], ["Q20B", "#4CAF50"], ["Q21", "#66BB6A"], ["Q22", "#81C784"],
      ["Q23", "#A5D6A7"], ["Q24", "#00C853"], ["Q25", "#00E676"], ["Q26", "#69F0AE"],
      ["Q27", "#B9F6CA"], ["Q28", "#1B5E20"], ["Q29", "#2E7D32"], ["Q30", "#388E3C"],
      ["Q31", "#43A047"], ["Q32", "#4CAF50"], ["Q33", "#66BB6A"], ["Q34", "#81C784"],
      ["Q35", "#A5D6A7"], ["Q36", "#00C853"], ["Q37", "#00E676"], ["Q38", "#69F0AE"],
      ["Q39", "#B9F6CA"], ["Q40", "#1B5E20"], ["Q41", "#2E7D32"], ["Q42", "#388E3C"],
      ["Q43", "#43A047"], ["Q44", "#4CAF50"], ["Q44-SBS", "#00E676"], ["Q46", "#66BB6A"],
      ["Q47", "#81C784"], ["Q48", "#A5D6A7"], ["Q49", "#00C853"], ["Q50", "#00E676"],
      ["Q52", "#69F0AE"], ["Q52-SBS", "#64DD17"], ["Q53", "#B9F6CA"], ["Q53-SBS", "#AEEA00"],
      ["Q54", "#1B5E20"], ["Q55", "#2E7D32"], ["Q56", "#388E3C"], ["Q58", "#43A047"],
      ["Q59", "#4CAF50"], ["Q60", "#66BB6A"], ["Q64", "#81C784"], ["Q65", "#A5D6A7"],
      ["Q66", "#00C853"], ["Q67", "#00E676"], ["Q69", "#69F0AE"], ["Q70", "#B9F6CA"],
      ["Q70-SBS", "#76FF03"], ["Q72", "#1B5E20"], ["Q76", "#2E7D32"], ["Q77", "#388E3C"],
      ["Q83", "#43A047"], ["Q84", "#4CAF50"], ["Q85", "#66BB6A"], ["Q88", "#81C784"],
      ["Q100", "#A5D6A7"], ["Q101", "#00C853"], ["Q102", "#00E676"], ["Q103", "#69F0AE"],
      ["Q104", "#B9F6CA"], ["Q110", "#1B5E20"], ["Q111", "#2E7D32"], ["Q112", "#388E3C"],
      ["Q113", "#43A047"]
    ];

    let mta_color_from(route: String, i: Int): String {
      if (i >= mta_colors.length) {
        "#000000"
      } else if (mta_colors[i][0] == route) {
        mta_colors[i][1]
      } else {
        mta_color_from(route, i + 1)
      }
    }

    export let mta_route_color(route: String): String { mta_color_from(route, 0) }

## A bus on the map

The hook drew each bus as a dot and three labels (the route, where it is
going, which way) and gave it a popup. It put the destination, which comes
from Bus Time, into both as HTML without escaping it; here it is escaped.

    export let mta_escape(s: String): String {
      let s1 = s.split("&").join("&amp;") { (p): String => p };
      let s2 = s1.split("<").join("&lt;") { (p): String => p };
      let s3 = s2.split(">").join("&gt;") { (p): String => p };
      let s4 = s3.split("\"").join("&quot;") { (p): String => p };
      s4.split("'").join("&#039;") { (p): String => p }
    }

Bus Time's `DirectionRef` is `"0"` or `"1"`. The hook called `"1"`
Northbound and everything else Southbound, which is also what it called a
crosstown bus going east or west.

    export let mta_direction(ref: String): String {
      if (ref == "1") { "Northbound" } else { "Southbound" }
    }

`${bus.speed || 'N/A'}`: `Velocity`, which Bus Time's v2 answers no longer
carry, so it is 0 and the popup says N/A.

    export let mta_speed(speed: Float64): String {
      if (speed == 0.0) { "N/A" } else { speed.toString() }
    }

`toFixed(6)`, for the popup's coordinates. Bus Time sends six places, so
this only pads.

    let mta_pad6(n: Int): String {
      let s = n.toString();
      if (n < 10) {
        "00000${s}"
      } else if (n < 100) {
        "0000${s}"
      } else if (n < 1000) {
        "000${s}"
      } else if (n < 10000) {
        "00${s}"
      } else if (n < 100000) {
        "0${s}"
      } else {
        s
      }
    }

    export let mta_fixed6(x: Float64): String {
      let k = (x * 1000000.0).round().toInt32Unsafe();
      let a = if (k < 0) { 0 - k } else { k };
      let sign = if (k < 0) { "-" } else { "" };
      let whole = (a / 1000000) orelse 0;
      let frac = (a % 1000000) orelse 0;
      "${sign}${whole.toString()}.${mta_pad6(frac)}"
    }

The marker's icon, the hook's `L.divIcon` HTML with its styles unchanged
and its whitespace squeezed.

    let mta_label(color: String, size: String, text: String): String {
      "<div style=\"background-color: white; padding: 2px 4px; border-radius: 4px; font-size: ${size}; line-height: 1; box-shadow: 0 0 4px rgba(0,0,0,0.2); color: ${color}; max-width: 120px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;\">${text}</div>"
    }

    export let mta_icon_html(route: String, destination: String, direction_ref: String): String {
      let color = mta_route_color(route);
      let dot = "<div style=\"background-color: ${color}; width: 12px; height: 12px; border-radius: 50%; border: 2px solid white; box-shadow: 0 0 4px rgba(0,0,0,0.5);\"></div>";
      let name = "<div style=\"background-color: white; padding: 2px 4px; border-radius: 4px; font-size: 12px; font-weight: bold; box-shadow: 0 0 4px rgba(0,0,0,0.2); color: ${color};\">${mta_escape(route)}</div>";
      let dest = if (destination.isEmpty) { "N/A" } else { mta_escape(destination) };
      "<div style=\"display: flex; flex-direction: column; align-items: flex-start; gap: 2px; pointer-events: none;\"><div style=\"display: flex; align-items: center; gap: 4px;\">${dot}${name}</div>${mta_label(color, "10px", dest)}${mta_label(color, "10px", mta_direction(direction_ref))}</div>"
    }

    export let mta_popup_html(route: String, id: String, speed: Float64, destination: String, direction_ref: String, lat: Float64, lng: Float64): String {
      let dest = if (destination.isEmpty) { "N/A" } else { mta_escape(destination) };
      "<div class=\"p-2\"><strong>${mta_escape(route)} Bus ${mta_escape(id)}</strong><br>Speed: ${mta_speed(speed)} mph<br>Destination: ${dest}<br>Direction: ${mta_direction(direction_ref)}<br>Location: ${mta_fixed6(lat)}, ${mta_fixed6(lng)}</div>"
    }

A marker is kept from one update to the next by route and vehicle, as the
hook's `markersByBusId` kept it.

    export let mta_bus_key(route: String, id: String): String { "${route}-${id}" }

## The status bar

    export let mta_routes_status(n: Int): String { "Routes: ${n.toString()}" }

    export let mta_borough_status(borough: String): String { "Borough: ${mta_borough_name(borough)}" }
