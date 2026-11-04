"""Fetch a project's unresolved Sentry issues and apply the determinism rule.

    python3 -I triage.py --config <sentry.toml> [--max N] [--skip ID,ID] [--out report.json]

Read-only against Sentry. Prints a Markdown table of every issue with its
verdict to stdout and writes the full report (candidates with the inputs a
test can be written from, rejected with reasons) as JSON to --out.

Endpoints, from Sentry's API reference:

    GET {base}/api/0/projects/{org}/{project}/issues/?query=is:unresolved&limit=100
        (marked deprecated in favour of /api/0/organizations/{org}/issues/?project=<id>;
        still served; used here because it takes the project slug)
    GET {base}/api/0/organizations/{org}/issues/{id}/events/?full=true
        (full=true includes entries[] with the stacktrace; page capped at 10)

The rule, clause by clause (SKILL.md states it in prose):

  1. same culprit and same top in-app frame (filename, function, lineNo)
     across every fetched event, and at least min_events events;
  2. the exception type and value do not match the timeout / network /
     resource patterns (TRANSIENT_TYPE, TRANSIENT_VALUE below);
  3. a unit test written from the event's arguments reaches the failing
     line. This script cannot decide clause 3; it emits what a test would
     be written from (vars, context lines, the exception value) and the
     skill decides, and rejects with "no unit test reaches the line" when
     it cannot.

Anything failing 1 or 2 is in `rejected` with the clause and the evidence.
"""
import argparse
import datetime as dt
import json
import os
import re
import sys
import tomllib
import urllib.error
import urllib.parse
import urllib.request

TRANSIENT_TYPE = re.compile(
    r"(?i)timeout|timedout|connection(error|refused|reset|closed|lost)|econn|etimedout|"
    r"eai_again|nxdomain|socket|network|dns|unavailable|ratelimit|rate_limit|toomanyrequests|"
    r"outofmemory|memoryerror|enospc|enomem|resourceexhausted|circuitbreaker|pool|checkout|"
    r"gateway|\b50[234]\b|transporterror|httperror|mint\.|finch|hackney|httpoison"
)
TRANSIENT_VALUE = re.compile(
    r"(?i)timed? ?out|timeout|connection (refused|reset|closed|lost)|econnre|etimedout|"
    r"nxdomain|no space left|out of memory|too many connections|rate.?limit|unreachable|"
    r"temporarily unavailable|service unavailable|bad gateway|checkout|pool"
)


def load_config(path: str) -> dict:
    with open(path, "rb") as f:
        return tomllib.load(f)


def http_get(base: str, path: str, token: str, params: dict | None = None) -> object:
    url = base.rstrip("/") + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
        "User-Agent": "sentry-patch/triage.py",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        body = e.read().decode(errors="replace")[:500]
        sys.exit(f"triage.py: GET {url} -> {e.code}: {body}")


def exception_of(event: dict) -> dict | None:
    """The raised exception: the last value of the exception entry."""
    for entry in event.get("entries", []):
        if entry.get("type") == "exception":
            values = entry.get("data", {}).get("values") or []
            if values:
                return values[-1]
    return None


def top_in_app_frame(exc: dict, prefixes: list[str]) -> dict | None:
    """Frames run caller first; the last in-app frame is where it raised."""
    frames = (exc.get("stacktrace") or {}).get("frames") or []
    in_app = [f for f in frames if f.get("inApp")]
    if not in_app and prefixes:
        in_app = [f for f in frames if any((f.get("filename") or "").startswith(p) for p in prefixes)]
    return in_app[-1] if in_app else None


def frame_key(frame: dict | None) -> tuple | None:
    if frame is None:
        return None
    return (frame.get("filename"), frame.get("function"), frame.get("lineNo"))


def judge(issue: dict, events: list[dict], cfg: dict) -> dict:
    short = issue.get("shortId") or issue.get("id")
    out = {
        "short_id": short,
        "id": issue.get("id"),
        "title": issue.get("title"),
        "culprit": issue.get("culprit"),
        "permalink": issue.get("permalink"),
        "count": issue.get("count"),
        "events_fetched": len(events),
    }
    min_events = int(cfg.get("min_events", 2))
    if len(events) < min_events:
        out.update(verdict="rejected", clause=1,
                   reason=f"only {len(events)} event(s) fetched; min_events is {min_events}")
        return out

    excs = [exception_of(e) for e in events]
    if any(x is None for x in excs):
        out.update(verdict="rejected", clause=1, reason="an event has no exception entry (message-only event)")
        return out

    culprits = {e.get("culprit") for e in events}
    if len(culprits) != 1:
        out.update(verdict="rejected", clause=1, reason=f"culprit differs across events: {sorted(c or '' for c in culprits)}")
        return out

    frames = [top_in_app_frame(x, cfg.get("in_app_prefixes", [])) for x in excs]
    if any(f is None for f in frames):
        out.update(verdict="rejected", clause=1, reason="no in-app frame in at least one event; nothing of ours to test")
        return out
    keys = {frame_key(f) for f in frames}
    if len(keys) != 1:
        out.update(verdict="rejected", clause=1,
                   reason="top in-app frame differs across events: " + "; ".join(f"{k[0]}:{k[2]} {k[1]}" for k in sorted(keys, key=str)))
        return out

    types = {x.get("type") or "" for x in excs}
    values = {x.get("value") or "" for x in excs}
    for t in types:
        if TRANSIENT_TYPE.search(t):
            out.update(verdict="rejected", clause=2, reason=f"exception type {t!r} matches the timeout/network/resource pattern")
            return out
    for v in values:
        if TRANSIENT_VALUE.search(v):
            out.update(verdict="rejected", clause=2, reason=f"exception value {v[:80]!r} matches the timeout/network/resource pattern")
            return out

    frame = frames[-1]
    exc = excs[-1]
    out.update(
        verdict="candidate",
        exception={"type": exc.get("type"), "value": exc.get("value"), "module": exc.get("module")},
        frame={
            "filename": frame.get("filename"),
            "function": frame.get("function"),
            "lineNo": frame.get("lineNo"),
            "context": frame.get("context"),
            "vars": frame.get("vars"),
        },
        distinct_values=sorted(values),
        latest_event_id=events[0].get("eventID"),
        tags={t["key"]: t["value"] for t in events[0].get("tags", []) if "key" in t},
        needs="clause 3: a unit test from frame.vars / exception.value that reaches frame.lineNo and fails with exception.type",
    )
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--config", required=True)
    ap.add_argument("--max", type=int, help="cap on candidates (default: max_prs from config)")
    ap.add_argument("--skip", default="", help="comma-separated short ids that already have a branch or PR")
    ap.add_argument("--out", help="write the JSON report here")
    args = ap.parse_args()

    cfg = load_config(args.config)
    for k in ("base_url", "org", "project", "token_env"):
        if not cfg.get(k) or str(cfg[k]).startswith("your-"):
            sys.exit(f"triage.py: {k} is missing or still a placeholder in {args.config}")
    token = os.environ.get(cfg["token_env"], "")
    if not token:
        sys.exit(f"triage.py: ${cfg['token_env']} is not set; no request made")

    base, org, project = cfg["base_url"], cfg["org"], cfg["project"]
    cap = args.max if args.max is not None else int(cfg.get("max_prs", 3))
    skip = {s.strip() for s in args.skip.split(",") if s.strip()}

    issues = http_get(base, f"/api/0/projects/{org}/{project}/issues/",
                      token, {"query": "is:unresolved", "limit": 100})
    if not isinstance(issues, list):
        sys.exit("triage.py: issue list is not a JSON array")

    results = []
    for issue in issues:
        short = issue.get("shortId") or issue.get("id")
        if short in skip:
            results.append({"short_id": short, "id": issue.get("id"), "title": issue.get("title"),
                            "permalink": issue.get("permalink"), "verdict": "skipped",
                            "reason": "a sentry/ branch or PR already exists for it"})
            continue
        events = http_get(base, f"/api/0/organizations/{org}/issues/{issue['id']}/events/",
                          token, {"full": "true", "per_page": int(cfg.get("events_per_issue", 10))})
        if not isinstance(events, list):
            sys.exit(f"triage.py: events for {short} is not a JSON array")
        results.append(judge(issue, events, cfg))

    n = 0
    for r in results:
        if r["verdict"] == "candidate":
            n += 1
            if n > cap:
                r.update(verdict="rejected", clause=0, reason=f"over the per-run cap of {cap}; next run")

    report = {
        "run_at": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
        "source": f"{base} org={org} project={project}",
        "cap": cap,
        "issues_fetched": len(issues),
        "candidates": [r for r in results if r["verdict"] == "candidate"],
        "rejected": [r for r in results if r["verdict"] == "rejected"],
        "skipped": [r for r in results if r["verdict"] == "skipped"],
    }
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)

    print(f"| issue | title | verdict | why |")
    print(f"|---|---|---|---|")
    for r in results:
        why = r.get("reason") or (f"{r['frame']['filename']}:{r['frame']['lineNo']} {r['frame']['function']} raises {r['exception']['type']} in all {r['events_fetched']} events" if r["verdict"] == "candidate" else "")
        print(f"| [{r['short_id']}]({r['permalink']}) | {r['title']} | {r['verdict']} | {why} |")
    print()
    print(f"{len(issues)} unresolved; {len(report['candidates'])} candidate(s) under the cap of {cap}; "
          f"{len(report['rejected'])} rejected; {len(report['skipped'])} skipped"
          + (f"; report at {args.out}" if args.out else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
