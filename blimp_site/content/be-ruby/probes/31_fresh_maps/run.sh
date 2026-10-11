#!/bin/sh
# A map program written fresh, not taken from the functional suite, run
# on the js, py and ruby backends and diffed. Needs a built temper CLI:
#   sh run.sh /path/to/temper/cli/build/install/temper/bin/temper
cd "$(dirname "$0")"
for b in js py ruby; do
  "$1" run -w . --library fresh-maps -b "$b" > "$b.full" 2>&1
  sed 's/^## Stdout: //' "$b.full" | grep ': \[' | awk '!seen[$0]++' > "$b.out"
done
diff js.out ruby.out && echo "ruby agrees with js"
diff js.out py.out
rm -rf temper.out
