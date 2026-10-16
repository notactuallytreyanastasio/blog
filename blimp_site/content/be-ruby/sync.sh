#!/bin/sh
# Copies the be-ruby journal into this directory from one commit of the
# temper checkout be-ruby is written in, and records which commit in
# COMMIT. The pages at /be-ruby are rendered from these files at boot
# (src/97_journal.blimp).
#
#   content/be-ruby/sync.sh [ref]    default: HEAD
#
# TEMPER_BE_RUBY points at that checkout (default ~/code/temper-be-ruby).
# It is a local worktree, not yet pushed anywhere, so nothing is fetched.
set -eu
REPO=${TEMPER_BE_RUBY:-$HOME/code/temper-be-ruby}
REF=${1:-HEAD}
DEST=$(cd "$(dirname "$0")" && pwd)
SHA=$(git -C "$REPO" rev-parse --verify "$REF^{commit}")
find "$DEST" -mindepth 1 -not -name sync.sh -delete
git -C "$REPO" archive "$SHA" be-ruby/journal | tar -x -C "$DEST" --strip-components=2
echo "$SHA" > "$DEST/COMMIT"
echo "be-ruby journal at $SHA:"
find "$DEST" -type f -not -name sync.sh | sed "s|$DEST/||" | sort
