#!/bin/sh
# Async ordering on the interpreter and the js, py and ruby backends;
# regenerates *.out.
#   sh run.sh /path/to/temper/cli/build/install/temper/bin/temper
cd "$(dirname "$0")"
# the interpreter prefixes each line with -work//: and then prints every
# line again run together, which the second grep drops
"$1" run -w . --library fresh-async -b interp 2>&1 | grep '^-work//:\[' | grep -v '\]-work' | sed 's/^-work\/\/://' > interp.out
for b in js py ruby; do
  "$1" run -w . --library fresh-async -b "$b" 2>&1 | sed 's/^## Stdout: //' | grep '^\[.*\]$' | awk '!seen[$0]++' > "$b.out"
done
diff interp.out ruby.out && echo "ruby agrees with the interpreter"
diff interp.out js.out
rm -rf temper.out temper.keep
