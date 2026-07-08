#!/bin/bash
set -euo pipefail

# Deploy RevealSlides (the `slides` repo) as a static sidecar at
# slides.bobbby.online. The app is a Vite/React SPA: we build dist/ locally and
# rsync it to /opt/slides on the VPS, which Caddy bind-mounts read-only
# (see docker-compose.yml + the slides.bobbby.online block in Caddyfile).
#
# It also deploys the phone-remote WebSocket relay (the slides repo's
# server/relay.mjs): relay.mjs + the pure-JS `ws` package are rsynced to
# /opt/slides-relay and run in the `slides-relay` container (node:20-alpine,
# bind-mounted — no image build). Caddy proxies wss://slides.bobbby.online/relay
# to it; the SPA is built with VITE_RELAY_URL pointing there.
#
# This script also pushes the Caddyfile + docker-compose.yml (config lives in
# this blog repo, the canonical source) and applies them, so the very first
# release works end-to-end from one command. Content-only redeploys just
# refresh /opt/slides and reload Caddy — no blog/app rebuild.
#
# Usage: ./deploy-slides.sh [user@host]
#   SLIDES_SRC   path to the slides checkout (default: $HOME/code/slides)
#   RELAY_URL    wss:// URL the SPA dials for the phone remote
#                (default: wss://slides.bobbby.online/relay)
#   DEPLOY_HOST  target VPS (from .env, same as deploy.sh)

# Load .env for DEPLOY_HOST (shared with deploy.sh).
if [ -f "$(dirname "$0")/.env" ]; then
  set -a; source "$(dirname "$0")/.env"; set +a
fi

HOST="${1:-${DEPLOY_HOST:-root@5.161.181.91}}"
BLOG_DIR="/opt/blog"
SLIDES_SRC="${SLIDES_SRC:-$HOME/code/slides}"
SLIDES_DIR="/opt/slides"
RELAY_DIR="/opt/slides-relay"
RELAY_URL="${RELAY_URL:-wss://slides.bobbby.online/relay}"

if [ ! -f "$SLIDES_SRC/package.json" ]; then
  echo "!! slides source not found at $SLIDES_SRC (set SLIDES_SRC=...)" >&2
  exit 1
fi

echo "==> Building slides at $SLIDES_SRC (relay: $RELAY_URL)..."
(
  cd "$SLIDES_SRC"
  if [ -f package-lock.json ]; then npm ci; else npm install; fi
  VITE_RELAY_URL="$RELAY_URL" npm run build
)

if [ ! -f "$SLIDES_SRC/node_modules/ws/package.json" ]; then
  echo "!! ws package missing under $SLIDES_SRC/node_modules (run npm install)" >&2
  exit 1
fi

echo "==> Publishing dist/ -> $HOST:$SLIDES_DIR..."
ssh "$HOST" "mkdir -p $SLIDES_DIR"
rsync -avz --delete --exclude '.DS_Store' "$SLIDES_SRC/dist/" "$HOST:$SLIDES_DIR/"

echo "==> Publishing relay (server/relay.mjs + ws) -> $HOST:$RELAY_DIR..."
ssh "$HOST" "mkdir -p $RELAY_DIR/node_modules"
rsync -avz --exclude '.DS_Store' "$SLIDES_SRC/server/relay.mjs" "$HOST:$RELAY_DIR/relay.mjs"
rsync -avz --delete "$SLIDES_SRC/node_modules/ws/" "$HOST:$RELAY_DIR/node_modules/ws/"

echo "==> Syncing Caddy config (Caddyfile, docker-compose.yml) -> $HOST:$BLOG_DIR..."
ssh "$HOST" "mkdir -p $BLOG_DIR"
rsync -avz "$(dirname "$0")/Caddyfile" "$(dirname "$0")/docker-compose.yml" "$HOST:$BLOG_DIR/"

echo "==> Applying on remote (start relay, recreate caddy if needed, then reload)..."
ssh "$HOST" bash -s <<'REMOTE'
  set -euo pipefail
  cd /opt/blog
  # Start (or recreate, if its definition changed) the phone-remote relay, and
  # restart it so a refreshed relay.mjs in the bind mount takes effect.
  docker compose up -d slides-relay
  docker compose restart slides-relay
  # up -d caddy recreates the container only if its definition changed (e.g. the
  # new /opt/slides bind mount on first deploy). Harmless otherwise.
  docker compose up -d caddy
  # Reload picks up Caddyfile-only changes without a restart; fall back to a
  # restart if the admin reload isn't available.
  docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile \
    || docker compose restart caddy
  echo "==> slides live at https://slides.bobbby.online (relay at /relay)"
REMOTE

echo "==> Done."
