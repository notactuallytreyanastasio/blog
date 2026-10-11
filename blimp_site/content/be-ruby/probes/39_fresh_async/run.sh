#!/bin/sh
# Async ordering on the js, py and ruby backends; regenerates *.out.
#   sh run.sh /path/to/temper/cli/build/install/temper/bin/temper
cd "$(dirname "$0")"
for b in js py ruby; do
  "$1" run -w . --library fresh-async -b "$b" 2>&1 | sed 's/^## Stdout: //' | grep '^\[.*\]$' | awk '!seen[$0]++' > "$b.out"
done
diff js.out ruby.out && echo "ruby agrees with js"
diff js.out py.out
rm -rf temper.out temper.keep
