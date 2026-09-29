#!/usr/bin/env bash
# Copy Blimp's browser runtime (interpreter, loader, view host, canvas) and
# Blimp Tetris from a Blimp checkout. Everything comes from one commit, which
# BLIMP_COMMIT records; nothing here or in static/tetris is edited by hand.
#
#   BLIMP_SRC=~/code/blimp ./static/blimp/sync.sh
set -euo pipefail
cd "$(dirname "$0")"
SRC="${BLIMP_SRC:?set BLIMP_SRC to a Blimp checkout}"
LANG_DIR="$SRC/chunks/lang"
cp "$LANG_DIR/examples/tetris.blimp" ../tetris/tetris.blimp
cp "$LANG_DIR/web/blimp.wasm" blimp.wasm
cp "$LANG_DIR/web/blimp.js" blimp.js
cp "$LANG_DIR/web/blimp-view.js" blimp-view.js
cp "$LANG_DIR/web/canvas.js" canvas.js
(cd "$SRC" && git rev-parse HEAD) > BLIMP_COMMIT
grep -q 'blimp_send' blimp.js || { echo "this blimp.js has no send(); need Blimp with the view host's send mode" >&2; exit 1; }
wc -c ../tetris/tetris.blimp blimp.wasm blimp.js blimp-view.js canvas.js
cat BLIMP_COMMIT
