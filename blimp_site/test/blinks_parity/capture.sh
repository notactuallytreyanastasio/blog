#!/usr/bin/env bash
# Recapture the blinks parity fixtures from production. Read-only: every
# request is a GET. Run from anywhere; writes next to this script.
#
#   blimp_site/test/blinks_parity/capture.sh            # https://bobbby.online
#   BASE=http://localhost:4100 .../capture.sh /tmp/out  # the same set from a Blimp build
#
# Each fixture is two files: NAME.<ext> (the body, byte for byte) and
# NAME.head (status line and response headers, CRs stripped, Date and the
# per-request headers removed). The query string of every fixture is in
# INDEX, which is the list this script walks.
set -euo pipefail
BASE="${BASE:-https://bobbby.online}"
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-$HERE}"
mkdir -p "$OUT"

grep -v '^#' "$HERE/INDEX" | while read -r name path; do
  [ -n "$name" ] || continue
  curl -s --max-time 30 -D "$OUT/$name.head.raw" -o "$OUT/$name" -A "blinks-parity/1 (+capture.sh)" "$BASE$path"
  tr -d '\r' < "$OUT/$name.head.raw" \
    | grep -v -i -E '^(date|x-request-id|set-cookie|alt-svc|via|server|content-length|x-envoy|cf-[a-z-]+|age|report-to|nel):' \
    > "$OUT/$name.head"
  rm "$OUT/$name.head.raw"
  printf '%s %s %s\n' "$(head -1 "$OUT/$name.head" | cut -d' ' -f2)" "$name" "$path"
done
