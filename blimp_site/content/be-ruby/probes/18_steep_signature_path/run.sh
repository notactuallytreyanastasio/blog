#!/bin/sh
# Run from anywhere: sh run.sh
# The same Steepfile twice, naming core/sig by absolute and by relative
# path. Steep 2.1 silently loads nothing from the absolute one.
cd "$(dirname "$0")"
for p in "$(pwd)/core/sig" "../core/sig"; do
  printf 'target :lib do\n  signature "sig", "%s"\n  check "lib"\n  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)\nend\n' "$p" > lib1/Steepfile
  echo "== $p"
  (cd lib1 && steep check 2>&1 | grep -E '\[(error|warning)\]|No type error')
done
rm lib1/Steepfile
