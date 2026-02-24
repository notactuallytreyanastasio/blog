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
