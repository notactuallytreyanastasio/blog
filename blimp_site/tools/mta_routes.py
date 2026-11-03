#!/usr/bin/env python3
"""Write temper/src/mta/routes.temper.md from Bus Time's own route lists.

    MTA_API_KEY=... tools/mta_routes.py

Run it when the MTA changes its routes. The list used to be copied by hand,
and it went wrong the way a copy does: 60 of 189 routes showed no buses. The
line reference cannot be worked out from the name (Q6 is MTABC_Q06, Q10 is
MTABC_Q10, M21 is MTA NYCT_M21), so it is kept, as Bus Time gives it.

A route this cannot place in a group stops it: a route on no tab would be a
route nobody can pick.
"""
import json
import os
import re
import sys
import urllib.parse
import urllib.request

AGENCIES = ["MTA NYCT", "MTABC"]
OUT = os.path.join(os.path.dirname(__file__), "..", "temper", "src", "mta", "routes.temper.md")
# GTFS extended route type 711: a shuttle standing in for a subway line that
# is out of service. They come and go with track work; they are not routes.
SUBWAY_SHUTTLE = 711
GROUPS = [
    (r"^(X|SIM|QM|BM|BxM|BXM)\d", "express"),
    (r"^(Bx|BX)\d", "bronx"),
    (r"^M\d", "manhattan"),
    (r"^B\d", "brooklyn"),
    (r"^Q\d", "queens"),
    (r"^S\d", "staten"),
]
ORDER = ["manhattan", "brooklyn", "queens", "bronx", "staten", "express"]


def group(name):
    for pattern, key in GROUPS:
        if re.match(pattern, name):
            return key
    sys.exit(f"no group for route {name!r}: add it to GROUPS")


def natural(name):
    return [int(p) if p.isdigit() else p for p in re.split(r"(\d+)", name)]


def temper(s):
    return json.dumps(s, ensure_ascii=False).replace("$", "\\$")


def main():
    key = os.environ.get("MTA_API_KEY") or sys.exit("set MTA_API_KEY")
    rows = []
    for agency in AGENCIES:
        url = f"https://bustime.mta.info/api/where/routes-for-agency/{urllib.parse.quote(agency)}.json?key={key}"
        for r in json.load(urllib.request.urlopen(url, timeout=30))["data"]["list"]:
            if r["type"] == SUBWAY_SHUTTLE:
                continue
            name = r["shortName"]
            rows.append((group(name), name, r["id"], "#" + r["color"], r["longName"].strip()))
    names = [r[1] for r in rows]
    dupes = sorted({n for n in names if names.count(n) > 1})
    if dupes:
        sys.exit(f"two agencies claim {dupes}: a name must pick one line reference")
    rows.sort(key=lambda r: (ORDER.index(r[0]), natural(r[1])))
    with open(OUT, "w") as f:
        f.write("# Every bus route\n\n")
        f.write("Written by `tools/mta_routes.py` from Bus Time's `routes-for-agency`; do\n")
        f.write("not edit it. Each row is group, name, line reference, colour, description.\n\n")
        f.write("    export let mta_routes: List<List<String>> = [\n")
        f.write(",\n".join("      [" + ", ".join(temper(c) for c in r) + "]" for r in rows))
        f.write("\n    ];\n")
    counts = {k: sum(1 for r in rows if r[0] == k) for k in ORDER}
    print(len(rows), counts)


main()
