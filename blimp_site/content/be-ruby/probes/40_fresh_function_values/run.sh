#!/bin/sh
# Functions used as values on the js, py and ruby backends and the
# interpreter; regenerates *.out.
#   sh run.sh /path/to/temper/cli/build/install/temper/bin/temper
cd "$(dirname "$0")"
for b in js py ruby interp; do
  "$1" run -w . --library fresh-function-values -b "$b" 2>&1 | sed -e 's/^## Stdout: //' -e 's,^-work//:,,' | grep ': \[.*\]$' | grep -v -- '-work//:' | awk '!seen[$0]++' > "$b.out"
done
diff js.out ruby.out && echo "ruby agrees with js"
diff interp.out ruby.out && echo "ruby agrees with the interpreter"
diff js.out py.out
rm -rf temper.out temper.keep
