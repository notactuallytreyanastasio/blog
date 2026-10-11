#!/bin/sh
# DenseBitVector and Deque edge cases on the js, py and ruby backends.
#   sh run.sh /path/to/temper/cli/build/install/temper/bin/temper
cd "$(dirname "$0")"
for b in js py ruby; do
  echo "== $b"
  "$1" run -w . --library fresh-bits -b "$b" 2>&1 | sed 's/^## Stdout: //' |
    grep -E ': \[|Error|Panic' | awk '!seen[$0]++' | sed 's/^.*temper_core.rb:[0-9]*:in //'
done
rm -rf temper.out
