#!/usr/bin/env bash
# Blimp has no imports, so the site is one file: what it uses of the Temper
# library compiled to Blimp (_build/temper.blimp), every src/*.blimp in name
# order, then main.blimp. `./build.sh test` builds one file per test instead,
# each the same sources followed by that test, and runs them.
#
# The Temper library is temper/src: config.temper.md and one directory per
# module. It is compiled with the Blimp backend of temper-blimp, which needs
# a JVM here but not on the server: what ships is _build/site.blimp, Blimp
# through and through (see deploy.sh).
#
#   TEMPER            the temper CLI (default: temper-blimp's branch 112)
#   TEMPER_JAVA_HOME  the JDK it runs on (default: Homebrew's openjdk@21)
set -euo pipefail
cd "$(dirname "$0")"
BLIMP="${BLIMP:-blimp}"
TEMPER="${TEMPER:-/Users/bg/code/temper-blimp-112/temper/cli/build/install/temper/bin/temper}"
TEMPER_JAVA_HOME="${TEMPER_JAVA_HOME:-/opt/homebrew/opt/openjdk@21}"
mkdir -p _build

# temper/src -> _build/temper.blimp: temper-core once, then every module.
# Rebuilt when anything under temper/src (a file, or a directory, which is
# how an added or deleted file shows) is newer than the last output, or the
# CLI is. `temper build` writes main.blimp even when it fails, so only its
# exit status says whether the file is any good.
temper_build() {
  local out=_build/temper.blimp
  if [ -f "$out" ] && [ -z "$(find temper/src "$TEMPER" -newer "$out" | head -1)" ]; then
    return 0
  fi
  [ -x "$TEMPER" ] || { echo "no temper CLI at $TEMPER (set TEMPER)" >&2; exit 1; }
  rm -rf temper/temper.out "$out"
  if ! JAVA_HOME="$TEMPER_JAVA_HOME" "$TEMPER" build -b blimp -w temper > _build/temper.log 2>&1; then
    cat _build/temper.log >&2
    echo "temper build failed; see above (also _build/temper.log)" >&2
    exit 1
  fi
  cp temper/temper.out/blimp/site/main.blimp "$out"
}
temper_build

# Every program built here gets the part of _build/temper.blimp it uses, not
# all of it. temper-core alone is about 130KB, which a browser would download
# for nothing; and on the server every top-level name costs time, because the
# interpreter copies every binding in sight into each closure it makes. All
# of temper-core in front of the site made rendering the posts 4.6s -> 7.6s
# with not one of its functions called. temper/prune.pl follows names from
# the program's own files to a fixed point.
# Before the files are joined, temper/dupes.pl refuses a program that makes
# a top-level name twice, because Blimp keeps the later one without a word
# (two bkp_body defs came out of a merge that way). The Temper part is
# checked with the rest; on a refusal $out.temper stays, for its line numbers.
#   with_temper OUT FILE...   OUT = the Temper FILE... uses, then FILE...
with_temper() {
  local out="$1"; shift
  perl temper/prune.pl _build/temper.blimp "$@" > "$out.temper"
  perl temper/dupes.pl "$out.temper" "$@" || { echo "not building $out" >&2; exit 1; }
  cat "$out.temper" "$@" > "$out"
  rm -f "$out.temper"
}

if [ -f main.blimp ]; then
  with_temper _build/site.blimp src/*.blimp main.blimp
fi
# The program a post page runs in the browser: the server's own renderer,
# file for file, and a Post actor to drive it.
with_temper _build/post-renderer.blimp src/05_actors.blimp src/10_markdown.blimp static/post/tail.blimp
# The Markdown editor: the same renderer, with the editor after it.
with_temper _build/editor.blimp src/05_actors.blimp src/10_markdown.blimp static/editor/editor.blimp
# phangraphs: the site's own list logic (src/97_phish.blimp, checked against
# the Elixir), with the page after it.
with_temper _build/phish.blimp src/40_http.blimp src/97_phish.blimp static/phish/phish.blimp
with_temper _build/moon.blimp static/moon/moon.blimp
# 2048: the rules are Temper (temper/src/twenty48), the actor and view Blimp.
with_temper _build/twenty48.blimp static/twenty48/twenty48.blimp
# Wordle: the rules are Temper (temper/src/wordle), the actor and view Blimp.
with_temper _build/wordle.blimp static/wordle/wordle.blimp
with_temper _build/wordle-god.blimp static/wordle/god.blimp
# Cursor tracker: the arithmetic is Temper (temper/src/cursor_tracker), the view Blimp.
with_temper _build/cursors.blimp static/cursors/cursors.blimp
# Temper Art: the engine is Temper (temper/src/art), the studio Blimp; the
# URL is read with the server's query_param.
with_temper _build/art.blimp src/40_http.blimp static/art/art.blimp
# Chess-9: the rules and the bot are Temper (temper/src/chess_lv), the actor,
# the view and the bot's root loop Blimp.
with_temper _build/chess_lv.blimp static/chess_lv/chess_lv.blimp
# Tag a Wook: embeds, validation and popups are Temper (temper/src/map), the view Blimp.
with_temper _build/map.blimp static/map/map.blimp
# How many people live here: the arithmetic is Temper (temper/src/nyc_census),
# the loops, the state and the panel Blimp; the map is Leaflet (map.js).
with_temper _build/nyc_census.blimp static/nyc_census/census.blimp
# The firehose pages: id extraction, matching and cutting are Temper (temper/src/firehose), the views Blimp.
with_temper _build/fh-youtube.blimp static/firehose/youtube.blimp
with_temper _build/fh-skeets.blimp static/firehose/skeets.blimp
with_temper _build/fh-compare.blimp static/firehose/compare.blimp
# The MTA bus map: routes, colours and markers are Temper (temper/src/mta), the
# controls Blimp; the map is Leaflet (static/mta/mta.js).
with_temper _build/mta.blimp static/mta/mta.blimp
# /stack: the graph, its layout, lineage and search are Temper (temper/src/stack), the view Blimp.
with_temper _build/stack.blimp static/stack/stack.blimp
# Fill The Sky: where every community's disc goes is Temper (temper/src/sky),
# run here rather than in the browser or at boot because the All view is
# 1.1 million overlap tests, seconds even natively. It is a function of
# the communities file and the program, so it runs again only when one of
# them changes. The page's own program is the sidebar.
with_temper _build/sky-layout.blimp.new static/sky/layout.blimp static/sky/build_layout.blimp
cmp -s _build/sky-layout.blimp.new _build/sky-layout.blimp || mv _build/sky-layout.blimp.new _build/sky-layout.blimp
rm -f _build/sky-layout.blimp.new
if [ ! -f _build/sky_layout.json ] || [ -n "$(find _build/sky-layout.blimp ../priv/static/data/sky_communities.json -newer _build/sky_layout.json)" ]; then
  "$BLIMP" _build/sky-layout.blimp || { echo "the sky layout failed" >&2; exit 1; }
fi
# The map's points, smaller (static/sky/build_points.blimp says why), gzipped
# for the browser to unpack: 37.7MB -> 4.8MB.
if [ ! -f _build/sky_points.json.gz ] || [ -n "$(find static/sky/build_points.blimp ../priv/static/data/sky_points.json -newer _build/sky_points.json.gz)" ]; then
  "$BLIMP" static/sky/build_points.blimp || { echo "the sky points failed" >&2; exit 1; }
  gzip -9 -n -f _build/sky_points.json
fi
with_temper _build/sky.blimp static/sky/sky.blimp
# Phish Lab: scales, ticks, bins, colours and number formats are Temper
# (temper/src/phish_lab), the chart's loops, actor and view Blimp.
with_temper _build/phish_lab.blimp static/phish_lab/phish_lab.blimp
# The Ziggy Account: the prompts, search words, character titles and the
# reply sanitiser are Temper (temper/src/ziggy), the window and chat Blimp;
# the explorer is d3 (static/ziggy/ziggy.js). query_param is the server's.
with_temper _build/ziggy.blimp src/40_http.blimp static/ziggy/ziggy.blimp
# The graph is the Phoenix app's (priv/ziggy, copied from the tim_blausey
# repo after a `deciduous sync`); the image has only priv/static, so the
# server reads a copy here.
cp ../priv/ziggy/graph-data.json _build/ziggy-graph.json
# Role Call: the tab, the sets, the tour and the printing are Temper
# (temper/src/role_call), the actor and view Blimp; query_param is the server's.
with_temper _build/role_call.blimp src/40_http.blimp static/role_call/role_call.blimp
# Stumble: the menus, rules, sort key and cutting are Temper
# (temper/src/stumble), the actor and view Blimp.
with_temper _build/stumble.blimp static/stumble/stumble.blimp
# The Camera Browser: the facets, the URL, the printing and the dupe key
# are Temper (temper/src/cameras), the rows, the counting and the view
# Blimp; query_param is the server's.
with_temper _build/cameras.blimp src/40_http.blimp static/cameras/cameras.blimp

if [ "${1:-}" = "test" ]; then
  status=0
  for t in test/*_test.blimp; do
    name=$(basename "$t" .blimp)
    # A test of a program the browser runs names it: `# needs: static/pong/pong.blimp`
    needs=$(sed -n 's/^# needs: //p' "$t")
    with_temper "_build/$name.blimp" src/*.blimp $needs "$t"
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
