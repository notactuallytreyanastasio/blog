#!/usr/bin/env bash
# Take the pages that were LiveViews with no server behaviour (and the two
# that were already files) from a running Phoenix site, as the HTML it sent,
# and keep them here as what the Blimp server serves from now on.
#
# What is removed, and only that:
#   - the LiveView client script (/assets/app-*.js): these pages have no
#     server events, so it had nothing to do but open a socket;
#   - the CSRF meta tag: a token frozen into a file is not a token;
#   - the data-phx-session / data-phx-static attributes and the stylesheet
#     link's phx-track-static, which only that client reads.
# And one rename: a bare /assets/app.css (nathan links it by hand) becomes
# the digested name, so the Blimp site never answers for the un-digested URL
# Phoenix's own pages may one day ask for and get a frozen copy of.
# Every other byte, the page's own scripts included, is what Phoenix sent.
#
#   ORIGIN=https://bobbby.online ./content/snapshot.sh
set -euo pipefail
cd "$(dirname "$0")"
ORIGIN="${ORIGIN:-https://bobbby.online}"
# ./content/snapshot.sh              the seven kept pages
# ./content/snapshot.sh directory    just the ones named
pages="${*:-privacy terms trees nathan knicks frontier chess}"
for page in $pages; do
  curl -fsS "$ORIGIN/$page" -o "pages/$page.raw.html"
  python3 - "pages/$page.raw.html" "pages/$page.html" <<'PY'
import re, sys
s = open(sys.argv[1], encoding="utf-8").read()
before = len(s)
s = re.sub(r'<script defer phx-track-static type="text/javascript" src="/assets/app-[0-9a-f]+\.js\?vsn=d"></script>\s*', '', s)
s = re.sub(r'<meta name="csrf-token" content="[^"]*"\s*/?>\s*', '', s)
s = re.sub(r' data-phx-session="[^"]*"', '', s)
s = re.sub(r' data-phx-static="[^"]*"', '', s)
s = s.replace('<link phx-track-static rel="stylesheet"', '<link rel="stylesheet"')
assert '/assets/app-' not in s or '.js' not in re.findall(r'/assets/app-[0-9a-f]+\.(\w+)', s), "a LiveView client script is left"
css = re.search(r'/assets/app-[0-9a-f]+\.css', s)
if css: s = s.replace('href="/assets/app.css"', f'href="{css.group(0)}"')
open(sys.argv[2], "w", encoding="utf-8").write(s)
print(f"{sys.argv[2]}: {before} -> {len(s)} bytes")
PY
  rm "pages/$page.raw.html"
done
# The stylesheet those pages link, by the digested name they link it by.
css=$(grep -o '/assets/app-[0-9a-f]*\.css' pages/privacy.html | head -1)
curl -fsS "$ORIGIN$css" -o "assets/$(basename "$css")"
echo "assets/$(basename "$css")"
