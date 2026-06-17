#!/bin/bash
set -euo pipefail

# Deploy blog + nathan to Hetzner VPS
# Usage: ./deploy.sh [user@host]

# Load .env if present
if [ -f "$(dirname "$0")/.env" ]; then
  set -a; source "$(dirname "$0")/.env"; set +a
fi

HOST="${1:-${DEPLOY_HOST:-root@5.161.181.91}}"
BLOG_DIR="/opt/blog"
NATHAN_DIR="/opt/nathan"
NATHAN_SRC="${NATHAN_SRC:-$HOME/code/nathan_for_us}"

# blimp.bobbby.online is a static site (the blimp repo's docs/ dir). Rather than
# require a local checkout, the remote host clones/pulls the public repo and
# rsyncs docs/ -> /opt/blimp (which Caddy bind-mounts read-only). Override the
# repo with BLIMP_REPO if it ever moves.
BLIMP_REPO="${BLIMP_REPO:-https://github.com/notactuallytreyanastasio/blimp.git}"
BLIMP_SRC_DIR="/opt/blimp-src"
BLIMP_DIR="/opt/blimp"

echo "==> Deploying blog to $HOST..."

# Sync blog project files
rsync -avz --delete \
  --exclude '_build' \
  --exclude 'deps' \
  --exclude 'node_modules' \
  --exclude '.env' \
  --exclude '.git' \
  --exclude '.elixir_ls' \
  --exclude '.deciduous' \
  "$PWD/" "$HOST:$BLOG_DIR/"

echo "==> Deploying nathan to $HOST..."

# Sync nathan_for_us project files
rsync -avz --delete \
  --exclude '_build' \
  --exclude 'deps' \
  --exclude 'node_modules' \
  --exclude '.env' \
  --exclude '.git' \
  --exclude '.elixir_ls' \
  --exclude '.deciduous' \
  --exclude 'gigalixir_db_dump.backup' \
  --exclude '.claude' \
  "$NATHAN_SRC/" "$HOST:$NATHAN_DIR/"

echo "==> Deploying blimp static site on $HOST..."

# Host-side: clone/pull the blimp repo, then publish its docs/ to /opt/blimp.
# -L follows the docs/tutorial/exercises -> ../../exercises symlink so the
# tutorial's stub/solution .blimp fetches resolve. Caddy serves /opt/blimp
# read-only, so refreshed files go live immediately (no container restart).
ssh "$HOST" bash -s "$BLIMP_REPO" "$BLIMP_SRC_DIR" "$BLIMP_DIR" <<'REMOTE'
  set -euo pipefail
  BLIMP_REPO="$1"; BLIMP_SRC_DIR="$2"; BLIMP_DIR="$3"

  if [ -d "$BLIMP_SRC_DIR/.git" ]; then
    git -C "$BLIMP_SRC_DIR" fetch --depth 1 origin main
    git -C "$BLIMP_SRC_DIR" reset --hard origin/main
  else
    rm -rf "$BLIMP_SRC_DIR"
    git clone --depth 1 "$BLIMP_REPO" "$BLIMP_SRC_DIR"
  fi

  mkdir -p "$BLIMP_DIR"
  rsync -aL --delete --exclude '.DS_Store' "$BLIMP_SRC_DIR/docs/" "$BLIMP_DIR/"

  echo "==> blimp published to $BLIMP_DIR ($(git -C "$BLIMP_SRC_DIR" rev-parse --short HEAD))"
REMOTE

echo "==> Building and starting on remote..."

ssh "$HOST" bash -s <<'REMOTE'
  set -euo pipefail
  cd /opt/blog

  # Build and restart all services
  docker compose build
  docker compose up -d

  # Run blog migrations
  docker compose exec app /app/bin/migrate

  # Seed sky profiles (546K Bluesky user profiles)
  docker compose exec app /app/bin/seed_profiles

  # Run nathan migrations
  docker compose exec nathan /app/bin/migrate

  echo "==> Deploy complete!"
  docker compose ps
REMOTE
