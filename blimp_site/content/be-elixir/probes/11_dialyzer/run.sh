#!/bin/bash
# Negative controls for the typespec check of fork PR #7.
#
#   TEMPER=~/code/temper-be-elixir ./run.sh
#
# TEMPER is a checkout of notactuallytreyanastasio/temper at 94efe3e0 with
# `./gradlew :cli:installDist` run in it. Needs JDK 21 (JAVA_HOME) and
# Elixir 1.19 / OTP 28 on the PATH. Builds fixture/ and passthru/ with
# `temper build -b elixir`, then for each variant copies the generated
# library, puts temper-core from the named commit beside it, applies one
# edit, and runs the backend's own dialyze.exs. Prints each SPEC warning.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
: "${TEMPER:?set TEMPER to a fork checkout at 94efe3e0}"
out="$here/out"; mkdir -p "$out"
plt="$out/base.plt"
dialyze="$TEMPER/be-elixir/src/commonTest/resources/lang/temper/be/elixir/dialyze.exs"
core=be-elixir/src/commonMain/resources/lang/temper/be/elixir/temper-core

for lib in fixture passthru; do
  (cd "$here/$lib" && rm -rf temper.out && "$TEMPER/cli/build/install/temper/bin/temper" build -b elixir -w . >/dev/null)
done

variant() { # name lib core-rev [edit]
  local name=$1 lib=$2 rev=$3 edit=${4:-} d="$out/$1"
  rm -rf "$d"; mkdir -p "$d/temper-core"
  cp -R "$here/$lib/temper.out/elixir/$lib" "$d/fixture"
  rm -rf "$d/fixture/_build" "$d/fixture/deps"
  (cd "$TEMPER" && git archive "$rev" "$core") | tar -x -C "$d/temper-core" --strip-components=9
  if [ -n "$edit" ]; then (cd "$d" && python3 "$here/edits/$edit"); fi
  elixir "$dialyze" "$plt" "$d/fixture" > "$out/$name.txt" 2>&1
  echo "### $name"; grep '^SPEC' "$out/$name.txt" | cut -c1-120
}

variant base           fixture  94efe3e0
variant false8         fixture  94efe3e0 falsespecs.py
variant false8-entryfn fixture  94efe3e0 false_entryfn.py
variant false8-core62  fixture  62dddaef falsespecs.py
variant total-defp     fixture  94efe3e0 totaldefp.py
variant boolint        fixture  94efe3e0 boolint.py
variant ifnil          fixture  94efe3e0 ifnil.py
variant passthru       passthru 94efe3e0
