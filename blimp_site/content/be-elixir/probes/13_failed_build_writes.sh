#!/bin/sh
# Does a failed `temper build -b elixir` leave generated Elixir behind?
#
#   TEMPER=path/to/temper sh 13_failed_build_writes.sh
#
# It does: the build exits 1 and prints the diagnostic, and
# temper.out/elixir/probe/lib/temper_main.ex is written anyway, with the
# ill-typed expression translated as written. A script that builds straight
# into the directory an app depends on hands the app that code.
set -u
TEMPER=${TEMPER:-temper}
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
mkdir -p "$dir/probe/src"
printf '# probe\n\n    export let name = "probe";\n' > "$dir/probe/config.temper.md"
cat > "$dir/probe/src/main.temper.md" <<'T'
# main

    @imu export class Stats(public words: Int, public readingSeconds: Int) {}

    export let stats(words: Int): Stats {
      new Stats(words, "slow")
    }
T
cd "$dir"
"$TEMPER" build -b elixir -w . > build.log 2>&1
echo "exit=$?"
grep ']@[A-Z]:' build.log
grep -n 'Stats.new(' temper.out/elixir/probe/lib/temper_main.ex
