#!/usr/bin/env bash
# Build, test, stage and ship the Blimp blog to the box.
#
#   ./deploy.sh stage     build + test + stage into _build/dist (no network)
#   ./deploy.sh ship      stage, rsync to $HOST:/opt/blimp-blog, rebuild the
#                         blimp-blog compose service
#
# BLIMP_SRC is a checkout of blimp's main, which has every language fix this
# site needs since blimp#35-#44 were merged. The interpreter is
# cross-compiled here and shipped as a static binary; bin/BLIMP_COMMIT says
# which commit.
#
# `ship` needs the blimp-blog compose service and the Caddy route in front of
# it to exist already; deploy/ has both, and where they go.
set -euo pipefail
cd "$(dirname "$0")"
HOST="${DEPLOY_HOST:-root@5.161.181.91}"
BLIMP_SRC="${BLIMP_SRC:-$HOME/code/blimp-for-blog}"
LANG_DIR="$BLIMP_SRC/chunks/lang"
DIST=_build/dist

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }

stage() {
  say "native interpreter for the tests"
  (cd "$LANG_DIR" && zig build interp)
  say "tests"
  BLIMP="$LANG_DIR/zig-out/bin/blimp" ./build.sh test

  say "linux interpreter"
  local linux_out="$PWD/_build/linux"
  (cd "$LANG_DIR" && zig build interp -Dtarget=x86_64-linux-musl --prefix "$linux_out" >/dev/null)
  local linux_bin="$linux_out/bin/blimp"
  file "$linux_bin" | grep -q 'x86-64.*statically linked' || { echo "not a static x86-64 binary: $linux_bin" >&2; exit 1; }

  say "staging $DIST"
  rm -rf "$DIST"
  mkdir -p "$DIST/bin" "$DIST/blimp_site/_build" "$DIST/priv/static"
  cp "$linux_bin" "$DIST/bin/blimp"
  (cd "$BLIMP_SRC" && git rev-parse HEAD) > "$DIST/bin/BLIMP_COMMIT"
  cp _build/site.blimp "$DIST/blimp_site/_build/site.blimp"
  cp _build/post-renderer.blimp "$DIST/blimp_site/_build/post-renderer.blimp"
  cp _build/editor.blimp "$DIST/blimp_site/_build/editor.blimp"
  cp _build/phish.blimp "$DIST/blimp_site/_build/phish.blimp"
  cp _build/moon.blimp "$DIST/blimp_site/_build/moon.blimp"
  cp _build/twenty48.blimp "$DIST/blimp_site/_build/twenty48.blimp"
  cp _build/wordle.blimp "$DIST/blimp_site/_build/wordle.blimp"
  cp _build/wordle-god.blimp "$DIST/blimp_site/_build/wordle-god.blimp"
  cp _build/cursors.blimp "$DIST/blimp_site/_build/cursors.blimp"
  cp _build/art.blimp "$DIST/blimp_site/_build/art.blimp"
  cp _build/chess_lv.blimp "$DIST/blimp_site/_build/chess_lv.blimp"
  cp _build/map.blimp "$DIST/blimp_site/_build/map.blimp"
  cp _build/nyc_census.blimp "$DIST/blimp_site/_build/nyc_census.blimp"
  cp -R assets data static content "$DIST/blimp_site/"
  cp Dockerfile "$DIST/Dockerfile"
  cp -R ../priv/static/posts ../priv/static/images "$DIST/priv/static/"
  mkdir -p "$DIST/priv/static/static"
  cp -R ../priv/static/static/temper-snake "$DIST/priv/static/static/"
  cp ../priv/static/favicon.ico ../priv/static/robots.txt "$DIST/priv/static/"
  du -sh "$DIST"
}

case "${1:-stage}" in
  stage) stage ;;
  ship)
    stage
    say "rsync to $HOST:/opt/blimp-blog"
    rsync -a --delete "$DIST/" "$HOST:/opt/blimp-blog/"
    say "rebuild blimp-blog"
    ssh "$HOST" 'cd /opt/blog && docker compose up -d --build blimp-blog && sleep 2 && docker compose logs --tail 5 blimp-blog'
    ;;
  *) echo "usage: $0 [stage|ship]" >&2; exit 2 ;;
esac
