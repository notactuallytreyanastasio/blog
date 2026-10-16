#!/bin/sh
# A string program written fresh, not taken from the functional suite, run
# on the js, py and ruby backends and diffed. js.out, py.out and ruby.out
# are the results as of journal entry 9. Needs a built temper CLI:
#   sh run.sh /path/to/temper/cli/build/install/temper/bin/temper
set -e
cd "$(dirname "$0")"
for b in js py ruby; do
  "$1" run -w . --library fresh-strings -b "$b" 2>&1 | grep ': \[' > "$b.now"
done
diff js.now ruby.now && echo "ruby agrees with js"
diff js.now py.now || true
rm -rf temper.out js.now py.now ruby.now
