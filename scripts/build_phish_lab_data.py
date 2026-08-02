#!/usr/bin/env python3
"""Build the /phish_lab datasets.

Merges three sources:
  1. ../phish_analysis/data/relisten/<date>.json  — full show records (setlists,
     durations, fan ratings, venue geo, tours) for every show with circulating audio
  2. priv/static/data/tracks.json                 — likes / jamchart flags (2009+)
  3. ../phish_analysis/web/data.json              — 15-dim jam style scores (the
     phishjustjams "scorecard") for 2,235 curated jams

Outputs:
  priv/static/data/phish_lab.json        {meta, styles, shows, songs, leaderboards}
  priv/static/data/phish_lab_perfs.json  {perfs}  (one row per song performance)

Run from the blog repo root:  python3 scripts/build_phish_lab_data.py
"""

import json
import math
import re
import statistics
from collections import Counter, defaultdict
from datetime import date
from pathlib import Path

BLOG = Path(__file__).resolve().parent.parent
PA = BLOG.parent / "phish_analysis"
RELISTEN = PA / "data" / "relisten"
PJJ_DATA = PA / "web" / "data.json"
TRACKS = BLOG / "priv" / "static" / "data" / "tracks.json"
OUT_MAIN = BLOG / "priv" / "static" / "data" / "phish_lab.json"
OUT_PERFS = BLOG / "priv" / "static" / "data" / "phish_lab_perfs.json"

LIKES_ERA_START = "2009-01-01"  # tracks.json coverage starts here


def norm(title):
    return re.sub(r"[^a-z0-9]", "", (title or "").lower())


def era_of(d):
    if d <= "2000-10-07":
        return "1.0"
    if d <= "2004-08-15":
        return "2.0"
    if d <= "2020-02-23":
        return "3.0"
    return "4.0"


def parse_date(d):
    return date(*[int(x) for x in d.split("-")])


def rnd(x, n=3):
    return None if x is None else round(x, n)


def zscores(pairs):
    """pairs: list of (key, value). Returns {key: z} using population stddev."""
    vals = [v for _, v in pairs if v is not None]
    if len(vals) < 3:
        return {}
    mu = statistics.mean(vals)
    sd = statistics.pstdev(vals)
    if sd == 0:
        return {}
    return {k: (v - mu) / sd for k, v in pairs if v is not None}


def main():
    # ------------------------------------------------------------- load shows
    shows_raw = {}
    for f in sorted(RELISTEN.glob("*.json")):
        with open(f) as fh:
            shows_raw[f.stem] = json.load(fh)
    print(f"relisten shows: {len(shows_raw)}")

    # ------------------------------------------------- likes / jamcharts join
    likes_by_key = {}
    with open(TRACKS) as fh:
        for t in json.load(fh):
            likes_by_key[(t["show_date"], norm(t["song_name"]))] = {
                "likes": t.get("likes") or 0,
                "jc": 1 if t.get("is_jamchart") else 0,
                "jam_notes": (t.get("jam_notes") or "")[:200],
            }

    # ------------------------------------------------------- jam style scores
    with open(PJJ_DATA) as fh:
        pjj = json.load(fh)
    styles = pjj["styles"]
    jams_by_date = defaultdict(list)
    for t in pjj["tracks"]:
        full_title = (t.get("full") or {}).get("title") or t["title"]
        jams_by_date[t["date"]].append(
            {"title": t["title"], "full_title": full_title,
             "dur": t["dur"], "scores": t["scores"]}
        )

    # ------------------------------------------------------ per-performance
    perfs = []
    for d, show in shows_raw.items():
        sources = show.get("sources") or []
        if not sources:
            continue
        src = sources[0]
        for st in src.get("sets") or []:
            set_name = st.get("name") or ""
            for tr in st.get("tracks") or []:
                title = tr.get("title") or ""
                dur = tr.get("duration")
                if not title or not dur:
                    continue
                perfs.append({
                    "d": d, "s": title, "sn": norm(title),
                    "set": set_name, "pos": tr.get("track_position"),
                    "dur": round(dur),
                })
    print(f"performances: {len(perfs)}")

    # canonical display name per normalized song key (most common raw form)
    name_votes = defaultdict(Counter)
    for p in perfs:
        name_votes[p["sn"]][p["s"]] += 1
    display = {sn: c.most_common(1)[0][0] for sn, c in name_votes.items()}

    # attach likes / jamchart
    for p in perfs:
        info = likes_by_key.get((p["d"], p["sn"]))
        p["likes"] = info["likes"] if info else None
        p["jc"] = info["jc"] if info else (0 if p["d"] >= LIKES_ERA_START else None)

    # duration stats per song -> z, pct; gaps
    by_song = defaultdict(list)
    for p in perfs:
        by_song[p["sn"]].append(p)
    for sn, plist in by_song.items():
        plist.sort(key=lambda p: (p["d"], p["pos"] or 0))
        durs = [p["dur"] for p in plist]
        mu = statistics.mean(durs)
        sd = statistics.pstdev(durs) if len(durs) >= 5 else None
        prev_date = None
        for p in plist:
            p["z"] = rnd((p["dur"] - mu) / sd, 2) if sd else None
            p["pct"] = rnd(p["dur"] / mu, 2) if mu else None
            pd = parse_date(p["d"])
            p["gap"] = (pd - prev_date).days if prev_date and pd != prev_date else (
                0 if prev_date == pd else None)
            if prev_date is None or pd > prev_date:
                prev_date = pd

    # ------------------------------------------------------------ songs table
    songs = []
    for sn, plist in by_song.items():
        durs = [p["dur"] for p in plist]
        plays = len(plist)
        # distinct show dates for gap math (same-show reprises don't count)
        dates = sorted({p["d"] for p in plist})
        maxgap = None
        maxgap_span = None
        for a, b in zip(dates, dates[1:]):
            g = (parse_date(b) - parse_date(a)).days
            if maxgap is None or g > maxgap:
                maxgap, maxgap_span = g, (a, b)
        p2009 = [p for p in plist if p["d"] >= LIKES_ERA_START]
        jc_ct = sum(p["jc"] or 0 for p in p2009)
        likes_vals = [p["likes"] for p in p2009 if p["likes"] is not None]
        songs.append({
            "s": display[sn], "sn": sn, "plays": plays,
            "first": dates[0], "last": dates[-1],
            "avg": round(statistics.mean(durs)),
            "med": round(statistics.median(durs)),
            "max": max(durs),
            "max_d": max(plist, key=lambda p: p["dur"])["d"],
            "sd": round(statistics.pstdev(durs)) if plays >= 5 else None,
            "cv": rnd(statistics.pstdev(durs) / statistics.mean(durs), 3)
                  if plays >= 5 and statistics.mean(durs) > 0 else None,
            "maxgap": maxgap,
            "maxgap_from": maxgap_span[0] if maxgap_span else None,
            "maxgap_to": maxgap_span[1] if maxgap_span else None,
            "jc_ct": jc_ct,
            "jc_rate": rnd(jc_ct / len(p2009), 3) if p2009 else None,
            "likes_avg": rnd(statistics.mean(likes_vals), 1) if likes_vals else None,
        })

    # song style profiles from PJJ jams (match jam -> song by full title)
    song_jams = defaultdict(list)
    show_jams = defaultdict(list)
    unmatched_jams = 0
    for d, jams in jams_by_date.items():
        for j in jams:
            show_jams[d].append(j)
            key = norm(j["full_title"])
            if key not in by_song:
                key2 = norm(j["title"])
                key = key2 if key2 in by_song else None
            if key:
                song_jams[key].append(j)
            else:
                unmatched_jams += 1
    print(f"jams matched to songs: {sum(len(v) for v in song_jams.values())}, "
          f"unmatched: {unmatched_jams}")

    for s in songs:
        jams = song_jams.get(s["sn"], [])
        s["njams"] = len(jams)
        if jams:
            prof = {st: rnd(statistics.mean(j["scores"][st] for j in jams))
                    for st in styles}
            s["styles"] = prof
            s["top_style"] = max(prof, key=prof.get)
        else:
            s["styles"] = None
            s["top_style"] = None

    # ------------------------------------------------------------ shows table
    n_shows = len(shows_raw)
    plays_of = {s["sn"]: s["plays"] for s in songs}
    shows = []
    for d, show in shows_raw.items():
        sources = show.get("sources") or []
        src = sources[0] if sources else {}
        venue = show.get("venue") or {}
        splist = [p for p in perfs if p["d"] == d]
        # soundchecks / partial recordings (e.g. the 2024-08-14 Mondegreen
        # soundcheck is a single 44-min "Soundcheck" track) aren't shows
        if len(splist) < 5:
            continue
        durs = [p["dur"] for p in splist]
        longest = max(splist, key=lambda p: p["dur"])
        p2009 = [p for p in splist if p["d"] >= LIKES_ERA_START]
        likes_vals = [p["likes"] for p in p2009 if p["likes"] is not None]
        jams = show_jams.get(d, [])
        style_max = ({st: rnd(max(j["scores"][st] for j in jams)) for st in styles}
                     if jams else None)
        rarity = rnd(100 * statistics.mean(1.0 / plays_of[p["sn"]] for p in splist), 2)
        shows.append({
            "d": d, "year": int(d[:4]), "era": era_of(d),
            "venue": venue.get("name"),
            "loc": venue.get("location"),
            "lat": venue.get("latitude"), "lon": venue.get("longitude"),
            "tour": (show.get("tour") or {}).get("name"),
            "rating": rnd(show.get("avg_rating"), 2) or None,
            "nrat": src.get("num_ratings"),
            "dur": round(src.get("duration") or sum(durs)),
            "nsongs": len(splist),
            "nsets": len(src.get("sets") or []),
            "avg_song": round(statistics.mean(durs)),
            "max_song": longest["dur"], "max_song_t": longest["s"],
            "rarity": rarity,
            "jc_ct": sum(p["jc"] or 0 for p in p2009) if p2009 else None,
            "likes": sum(likes_vals) if likes_vals else None,
            "njams": len(jams),
            "styles": style_max,
            "top_style": max(style_max, key=style_max.get) if style_max else None,
        })

    # relative z-scores: rating vs year, avg song duration vs era
    for group_key, src_key, out_key in [("year", "rating", "rating_z"),
                                        ("era", "avg_song", "jam_z")]:
        groups = defaultdict(list)
        for s in shows:
            groups[s[group_key]].append((s["d"], s[src_key]))
        for g, pairs in groups.items():
            zs = zscores(pairs)
            for s in shows:
                if s[group_key] == g:
                    s[out_key] = rnd(zs.get(s["d"]), 2)
    for s in shows:
        s.setdefault("rating_z", None)
        s.setdefault("jam_z", None)
        parts = [abs(v) for v in (s["rating_z"], s["jam_z"]) if v is not None]
        rz = zscores([(x["d"], x["rarity"]) for x in shows]).get(s["d"])
        if rz is not None:
            parts.append(abs(rz))
        s["uniq"] = rnd(statistics.mean(parts), 2) if parts else None

    # ---------------------------------------------------------- leaderboards
    def top(rows, key, n=10, reverse=True, min_filter=None):
        pool = [r for r in rows if r.get(key) is not None]
        if min_filter:
            pool = [r for r in pool if min_filter(r)]
        return sorted(pool, key=lambda r: r[key], reverse=reverse)[:n]

    def show_entry(s, val):
        return {"d": s["d"], "label": f'{s["venue"]}, {s["loc"]}', "value": val}

    def song_entry(s, val, detail=None):
        return {"s": s["s"], "label": s["s"], "value": val, "detail": detail}

    def perf_entry(p, val, detail=None):
        return {"d": p["d"], "s": p["s"], "label": f'{p["s"]} — {p["d"]}',
                "value": val, "detail": detail}

    fmt_min = lambda sec: f"{sec // 60}:{sec % 60:02d}"

    leaderboards = {
        "shows_jammiest": {
            "title": "Jammiest Shows (avg song length vs era)",
            "entries": [show_entry(s, f'{s["jam_z"]:+.1f}σ · avg {fmt_min(s["avg_song"])}')
                        for s in top(shows, "jam_z")]},
        "shows_rarest": {
            "title": "Weirdest Setlists (rarity index)",
            "entries": [show_entry(s, f'{s["rarity"]:.1f}')
                        for s in top(shows, "rarity")]},
        "shows_overachievers": {
            "title": "Rated Above Their Year",
            "entries": [show_entry(s, f'{s["rating_z"]:+.1f}σ · {s["rating"]:.1f}/10')
                        for s in top(shows, "rating_z",
                                     min_filter=lambda r: (r["nrat"] or 0) >= 10)]},
        "shows_longest": {
            "title": "Longest Shows",
            "entries": [show_entry(s, fmt_min(s["dur"]))
                        for s in top(shows, "dur")]},
        "shows_most_unique": {
            "title": "Most Anomalous Overall",
            "entries": [show_entry(s, f'{s["uniq"]:.2f}')
                        for s in top(shows, "uniq")]},
        "songs_variable": {
            "title": "Most Unpredictable Songs (duration CV, 10+ plays)",
            "entries": [song_entry(s, f'{s["cv"]:.2f}',
                                   f'{fmt_min(s["avg"])} avg → {fmt_min(s["max"])} max')
                        for s in top(songs, "cv",
                                     min_filter=lambda r: r["plays"] >= 10)]},
        "songs_bustouts": {
            "title": "Biggest Bustouts (longest shelf time)",
            "entries": [song_entry(s, f'{s["maxgap"] // 365}y {s["maxgap"] % 365 // 30}m',
                                   f'{s["maxgap_from"]} → {s["maxgap_to"]}')
                        for s in top(songs, "maxgap",
                                     min_filter=lambda r: r["plays"] >= 3)]},
        "songs_jam_vehicles": {
            "title": "Jam Vehicles (avg length, 10+ plays)",
            "entries": [song_entry(s, fmt_min(s["avg"]), f'{s["plays"]} plays')
                        for s in top(songs, "avg",
                                     min_filter=lambda r: r["plays"] >= 10)]},
        "perfs_outliers": {
            "title": "Most Outlier Versions (σ above song's own average)",
            "entries": [perf_entry(p, f'{p["z"]:+.1f}σ',
                                   f'{fmt_min(p["dur"])} vs usual')
                        for p in top(perfs, "z",
                                     min_filter=lambda r: plays_of[r["sn"]] >= 10)]},
        "perfs_longest": {
            "title": "Longest Versions, Period",
            "entries": [perf_entry(p, fmt_min(p["dur"]))
                        for p in top(perfs, "dur")]},
    }

    # per-style definers: top song by mean score (3+ matched jams)
    style_definers = []
    for st in styles:
        pool = [s for s in songs if s["njams"] >= 3 and s["styles"]]
        if not pool:
            continue
        best = max(pool, key=lambda s: s["styles"][st])
        style_definers.append({"style": st, "s": best["s"],
                               "value": f'{best["styles"][st]:.2f}',
                               "detail": f'{best["njams"]} jams scored'})
    leaderboards["style_definers"] = {
        "title": "Style-Defining Songs (per PJJ scorecard)",
        "entries": style_definers}

    # ---------------------------------------------------------------- output
    for p in perfs:
        del p["sn"]
    for s in songs:
        del s["sn"]

    meta = {
        "n_shows": len(shows), "n_perfs": len(perfs), "n_songs": len(songs),
        "n_jams": sum(len(v) for v in jams_by_date.values()),
        "date_min": min(s["d"] for s in shows),
        "date_max": max(s["d"] for s in shows),
        "likes_era_start": LIKES_ERA_START,
    }
    OUT_MAIN.write_text(json.dumps(
        {"meta": meta, "styles": styles, "shows": shows,
         "songs": songs, "leaderboards": leaderboards},
        separators=(",", ":")))
    OUT_PERFS.write_text(json.dumps({"perfs": perfs}, separators=(",", ":")))
    print(f"wrote {OUT_MAIN} ({OUT_MAIN.stat().st_size // 1024}K)")
    print(f"wrote {OUT_PERFS} ({OUT_PERFS.stat().st_size // 1024}K)")
    print(json.dumps(meta, indent=2))


if __name__ == "__main__":
    main()
