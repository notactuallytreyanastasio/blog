#!/bin/bash
set -euo pipefail

# Deploy to the Hetzner box, doing only the work that is actually needed.
#
# The old version rsynced everything and then ran a bare `docker compose
# build`, which rebuilds all four built services — app, nathan, and also
# blinks and soldat, whose sources live only on the box and which this script
# never touches. A one-line blog change cost a full four-image rebuild.
#
# This one figures out what changed (a dry-run rsync is the source of truth),
# then builds and restarts only the affected services, migrates only when a
# migration arrived, and checks the public url afterwards.
#
# Usage:
#   ./deploy.sh                    everything that changed
#   ./deploy.sh blog               one target (blog nathan blimp downloader blinks soldat)
#   ./deploy.sh -n                 dry run: print the plan, change nothing
#   ./deploy.sh -f blog            act even if nothing changed
#   ./deploy.sh --host user@host   override the target box

HOST="${DEPLOY_HOST:-root@5.161.181.91}"
BLOG_DIR="/opt/blog"
NATHAN_DIR="/opt/nathan"
NATHAN_SRC="${NATHAN_SRC:-$HOME/code/nathan_for_us}"
BLIMP_REPO="${BLIMP_REPO:-https://github.com/notactuallytreyanastasio/blimp.git}"
BLIMP_SRC_DIR="/opt/blimp-src"
BLIMP_DIR="/opt/blimp"

DRY=0
FORCE=0
TARGETS=()

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY=1 ;;
    -f|--force)   FORCE=1 ;;
    --host)       HOST="$2"; shift ;;
    -h|--help)    sed -n '3,25p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)           echo "unknown flag: $1" >&2; exit 2 ;;
    *)            TARGETS+=("$1") ;;
  esac
  shift
done

# Default set. blinks and soldat build from box-local sources this script does
# not sync, so they are opt-in: asking for them means "rebuild from whatever is
# on the box right now".
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=(blog nathan blimp downloader)

wants() { printf '%s\n' "${TARGETS[@]}" | grep -qx "$1"; }

say()  { printf '\033[1m==>\033[0m %s\n' "$*"; }
skip() { printf '    \033[2m·\033[0m %s\n' "$*"; }
did()  { printf '    \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$*"; }

# Load .env for DEPLOY_HOST etc. Deliberately after flag parsing so --host wins.
if [ -f "$(dirname "$0")/.env" ]; then
  set -a; source "$(dirname "$0")/.env"; set +a
fi

EXCLUDES=(
  --exclude '_build' --exclude 'deps' --exclude 'node_modules'
  --exclude '.env' --exclude '.git' --exclude '.elixir_ls'
  --exclude '.deciduous' --exclude '.claude'
  # Written on the box by this script; it has no local counterpart, so without
  # this --delete would wipe the stamp on the very next deploy.
  --exclude '.deployed'
)

# Dry-run rsync, listing only paths that would actually change. `<` means a
# transfer to the remote; `*deleting` is a removal. Attribute-only lines start
# with `.` and are noise.
probe() {
  local src="$1" dst="$2"; shift 2
  # ${a[@]+"${a[@]}"} — bash 3.2 (the macOS default) treats an empty array as
  # unbound under `set -u`, so an unguarded "$@" here breaks every no-extras call.
  rsync -ain --delete "${EXCLUDES[@]}" ${@+"$@"} "$src/" "$HOST:$dst/" 2>/dev/null \
    | grep -E '^(<|\*deleting)' \
    | sed -E 's/^[^[:space:]]+[[:space:]]+//' || true
}

push() {
  local src="$1" dst="$2"; shift 2
  rsync -az --delete "${EXCLUDES[@]}" ${@+"$@"} "$src/" "$HOST:$dst/"
}

touches() { grep -qE "$2" <<<"$1"; }

# Does this change list affect what goes into the image? Docs, tests and the
# decision graph do not, so a README edit should not cost a rebuild.
IMAGE_PATHS='^(lib/|assets/|priv/|config/|rel/|mix\.(exs|lock)$|Dockerfile$)'

# ---------------------------------------------------------------- blog

BLOG_CHANGES=""
if wants blog; then
  say "blog → $HOST:$BLOG_DIR"
  BLOG_CHANGES=$(probe "$PWD" "$BLOG_DIR")
  n=$(grep -c . <<<"$BLOG_CHANGES" || true)

  if [ -z "$BLOG_CHANGES" ] && [ $FORCE -eq 0 ]; then
    skip "no changes"
  else
    [ -n "$BLOG_CHANGES" ] && sed 's/^/      /' <<<"$BLOG_CHANGES" | head -12
    [ "${n:-0}" -gt 12 ] && skip "… and $((n - 12)) more"

    rebuild=0; migrate=0; caddy=0
    touches "$BLOG_CHANGES" "$IMAGE_PATHS"         && rebuild=1
    touches "$BLOG_CHANGES" '^priv/repo/migrations/' && migrate=1
    touches "$BLOG_CHANGES" '^Caddyfile$'          && caddy=1
    touches "$BLOG_CHANGES" '^docker-compose\.yml$' && rebuild=1
    [ $FORCE -eq 1 ] && { rebuild=1; migrate=1; }

    if [ $DRY -eq 1 ]; then
      warn "dry run: would sync$([ $rebuild = 1 ] && echo ', rebuild app')$([ $migrate = 1 ] && echo ', migrate')$([ $caddy = 1 ] && echo ', reload caddy')"
    else
      push "$PWD" "$BLOG_DIR"
      did "synced"

      if [ $rebuild -eq 1 ]; then
        ssh "$HOST" "cd $BLOG_DIR && docker compose build app && docker compose up -d app" >/dev/null
        did "rebuilt + restarted app"
      else
        skip "no image-relevant change — app left running"
      fi

      if [ $migrate -eq 1 ]; then
        # `docker compose exec` attaches stdin by default, and this script can
        # arrive over ssh stdin — -T </dev/null keeps it from eating the rest.
        ssh "$HOST" "cd $BLOG_DIR && docker compose exec -T app /app/bin/migrate" </dev/null
        did "migrated"
      else
        skip "no new migrations"
      fi

      if [ $caddy -eq 1 ]; then
        ssh "$HOST" "cd $BLOG_DIR && docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile" </dev/null
        did "reloaded caddy"
      fi

      # Provenance: what revision is actually on the box right now.
      rev=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
      git diff --quiet 2>/dev/null || rev="$rev+dirty"
      ssh "$HOST" "echo '$rev  $(date -u +%FT%TZ)' > $BLOG_DIR/.deployed"
    fi
  fi
fi

# ---------------------------------------------------------------- nathan

if wants nathan; then
  say "nathan → $HOST:$NATHAN_DIR"
  if [ ! -d "$NATHAN_SRC" ]; then
    warn "no checkout at $NATHAN_SRC — skipping"
  else
    CHANGES=$(probe "$NATHAN_SRC" "$NATHAN_DIR" --exclude 'gigalixir_db_dump.backup')
    if [ -z "$CHANGES" ] && [ $FORCE -eq 0 ]; then
      skip "no changes"
    elif [ $DRY -eq 1 ]; then
      warn "dry run: would sync $(grep -c . <<<"$CHANGES") path(s) and rebuild nathan"
    else
      push "$NATHAN_SRC" "$NATHAN_DIR" --exclude 'gigalixir_db_dump.backup'
      did "synced"
      if touches "$CHANGES" "$IMAGE_PATHS" || [ $FORCE -eq 1 ]; then
        ssh "$HOST" "cd $BLOG_DIR && docker compose build nathan && docker compose up -d nathan" >/dev/null
        did "rebuilt + restarted nathan"
        ssh "$HOST" "cd $BLOG_DIR && docker compose exec -T nathan /app/bin/migrate" </dev/null
        did "migrated"
      else
        skip "no image-relevant change"
      fi
      # The Framecut Grabber landing page ships inside nathan (site/).
      if touches "$CHANGES" '^site/'; then
        ssh "$HOST" "mkdir -p /opt/downloader && rsync -a --delete $NATHAN_DIR/site/ /opt/downloader/"
        did "republished downloader"
      fi
    fi
  fi
fi

# ------------------------------------------------------- box-local rebuilds

for svc in blinks soldat; do
  if wants "$svc"; then
    say "$svc (builds from box-local source)"
    if [ $DRY -eq 1 ]; then
      warn "dry run: would rebuild $svc"
    else
      ssh "$HOST" "cd $BLOG_DIR && docker compose build $svc && docker compose up -d $svc" >/dev/null
      did "rebuilt + restarted $svc"
    fi
  fi
done

# ---------------------------------------------------------------- blimp

if wants blimp; then
  say "blimp static site"
  if [ $DRY -eq 1 ]; then
    warn "dry run: would pull $BLIMP_REPO and publish docs/"
  else
    ssh "$HOST" bash -s "$BLIMP_REPO" "$BLIMP_SRC_DIR" "$BLIMP_DIR" <<'REMOTE'
      set -euo pipefail
      BLIMP_REPO="$1"; BLIMP_SRC_DIR="$2"; BLIMP_DIR="$3"
      if [ -d "$BLIMP_SRC_DIR/.git" ]; then
        before=$(git -C "$BLIMP_SRC_DIR" rev-parse HEAD)
        git -C "$BLIMP_SRC_DIR" fetch --depth 1 -q origin main
        git -C "$BLIMP_SRC_DIR" reset --hard -q origin/main
        after=$(git -C "$BLIMP_SRC_DIR" rev-parse HEAD)
        [ "$before" = "$after" ] && { echo "    · already at ${after:0:7}"; exit 0; }
      else
        rm -rf "$BLIMP_SRC_DIR"
        git clone --depth 1 -q "$BLIMP_REPO" "$BLIMP_SRC_DIR"
      fi
      mkdir -p "$BLIMP_DIR"
      # -L follows docs/tutorial/exercises -> ../../exercises so the tutorial's
      # stub/solution .blimp fetches resolve.
      rsync -aL --delete --exclude '.DS_Store' "$BLIMP_SRC_DIR/docs/" "$BLIMP_DIR/"
      echo "    ✓ published $(git -C "$BLIMP_SRC_DIR" rev-parse --short HEAD)"
REMOTE
  fi
fi

# ---------------------------------------------------------------- downloader

if wants downloader && ! wants nathan; then
  say "downloader static site"
  if [ $DRY -eq 1 ]; then
    warn "dry run: would republish /opt/nathan/site → /opt/downloader"
  else
    ssh "$HOST" "mkdir -p /opt/downloader && rsync -a --delete $NATHAN_DIR/site/ /opt/downloader/"
    did "republished"
  fi
fi

# ---------------------------------------------------------------- health

[ $DRY -eq 1 ] && { say "dry run — nothing changed"; exit 0; }

say "health"
check() {
  local name="$1" url="$2" code
  for attempt in 1 2 3 4 5 6; do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$url" || echo 000)
    [ "$code" = "200" ] && { did "$name $code"; return 0; }
    sleep 3
  done
  warn "$name $code  ($url)"
  return 1
}

rc=0
wants blog       && { check "bobbby.online   " https://bobbby.online/ || rc=1; }
wants blog       && { check "/gallery        " https://bobbby.online/gallery || rc=1; }
wants nathan     && { check "gifmaker        " https://gifmaker.bobbby.online/ || rc=1; }
wants blinks     && { check "links           " https://links.bobbby.online/ || rc=1; }
wants soldat     && { check "soldat          " https://soldat.bobbby.online/ || rc=1; }
wants blimp      && { check "blimp           " https://blimp.bobbby.online/ || rc=1; }
wants downloader && { check "downloader      " https://downloader.bobbby.online/ || rc=1; }

[ $rc -eq 0 ] && say "deploy complete" || { say "deploy finished with failing health checks"; exit 1; }
