#!/usr/bin/env bash
# Blimp has no imports, so the site is one file: every src/*.blimp in name
# order, then main.blimp. `./build.sh test` builds one file per test instead,
# each the sources followed by that test, and runs them.
set -euo pipefail
cd "$(dirname "$0")"
BLIMP="${BLIMP:-blimp}"
mkdir -p _build

if [ -f main.blimp ]; then
  cat src/*.blimp main.blimp > _build/site.blimp
fi

if [ "${1:-}" = "test" ]; then
  status=0
  for t in test/*_test.blimp; do
    name=$(basename "$t" .blimp)
    cat src/*.blimp "$t" > "_build/$name.blimp"
    printf '%-28s ' "$name"
    out=$("$BLIMP" "_build/$name.blimp" --test 2>&1) || true
    summary=$(printf '%s\n' "$out" | grep -E 'passed|failed' | tail -1)
    printf '%s\n' "$summary"
    if ! printf '%s' "$summary" | grep -q 'tests passed'; then
      printf '%s\n' "$out" | grep -E 'FAIL|left:|right:|error|Error' -A2 | head -40
      status=1
    fi
  done
  exit $status
fi
