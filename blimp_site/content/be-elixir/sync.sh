#!/bin/sh
# Copies the be-elixir journal into this directory from one commit of
# temper-blimp, and records which commit in COMMIT. The pages at
# /be-elixir are rendered from these files at boot (src/97_journal.blimp).
#
#   content/be-elixir/sync.sh [ref]    default: origin/elixir-04-hello-world
#
# TEMPER_BLIMP points at a temper-blimp checkout (default ~/code/temper-blimp).
set -eu
REPO=${TEMPER_BLIMP:-$HOME/code/temper-blimp}
REF=${1:-origin/elixir-04-hello-world}
DEST=$(cd "$(dirname "$0")" && pwd)
git -C "$REPO" fetch -q origin
SHA=$(git -C "$REPO" rev-parse --verify "$REF^{commit}")
find "$DEST" -mindepth 1 -not -name sync.sh -delete
git -C "$REPO" archive "$SHA" journal | tar -x -C "$DEST" --strip-components=1
echo "$SHA" > "$DEST/COMMIT"
echo "be-elixir journal at $SHA:"
find "$DEST" -type f -not -name sync.sh | sed "s|$DEST/||" | sort
