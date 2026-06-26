#!/bin/bash
set -euo pipefail

# Deploy RevealSlides (the `slides` repo) as a static sidecar at
# slides.bobbby.online. The app is a Vite/React SPA: we build dist/ locally and
# rsync it to /opt/slides on the VPS, which Caddy bind-mounts read-only
# (see docker-compose.yml + the slides.bobbby.online block in Caddyfile).
#
# This script also pushes the Caddyfile + docker-compose.yml (config lives in
# this blog repo, the canonical source) and applies them, so the very first
# release works end-to-end from one command. Content-only redeploys just
# refresh /opt/slides and reload Caddy — no blog/app rebuild.
#
# Usage: ./deploy-slides.sh [user@host]
#   SLIDES_SRC   path to the slides checkout (default: $HOME/code/slides)
#   DEPLOY_HOST  target VPS (from .env, same as deploy.sh)

# Load .env for DEPLOY_HOST (shared with deploy.sh).
if [ -f "$(dirname "$0")/.env" ]; then
  set -a; source "$(dirname "$0")/.env"; set +a
fi

HOST="${1:-${DEPLOY_HOST:-root@5.161.181.91}}"
BLOG_DIR="/opt/blog"
SLIDES_SRC="${SLIDES_SRC:-$HOME/code/slides}"
SLIDES_DIR="/opt/slides"

if [ ! -f "$SLIDES_SRC/package.json" ]; then
  echo "!! slides source not found at $SLIDES_SRC (set SLIDES_SRC=...)" >&2
  exit 1
fi

echo "==> Building slides at $SLIDES_SRC..."
(
  cd "$SLIDES_SRC"
  if [ -f package-lock.json ]; then npm ci; else npm install; fi
  npm run build
)

echo "==> Publishing dist/ -> $HOST:$SLIDES_DIR..."
ssh "$HOST" "mkdir -p $SLIDES_DIR"
rsync -avz --delete --exclude '.DS_Store' "$SLIDES_SRC/dist/" "$HOST:$SLIDES_DIR/"

echo "==> Syncing Caddy config (Caddyfile, docker-compose.yml) -> $HOST:$BLOG_DIR..."
ssh "$HOST" "mkdir -p $BLOG_DIR"
rsync -avz "$(dirname "$0")/Caddyfile" "$(dirname "$0")/docker-compose.yml" "$HOST:$BLOG_DIR/"

echo "==> Applying on remote (recreate caddy if the mount is new, then reload)..."
ssh "$HOST" bash -s <<'REMOTE'
  set -euo pipefail
  cd /opt/blog
  # up -d caddy recreates the container only if its definition changed (e.g. the
  # new /opt/slides bind mount on first deploy). Harmless otherwise.
  docker compose up -d caddy
  # Reload picks up Caddyfile-only changes without a restart; fall back to a
  # restart if the admin reload isn't available.
  docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile \
    || docker compose restart caddy
  echo "==> slides live at https://slides.bobbby.online"
REMOTE

echo "==> Done."
