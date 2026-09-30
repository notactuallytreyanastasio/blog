#!/usr/bin/env bash
# How long the site takes to become ready, to render every post, and to test.
#
#   ./bench.sh            every measure, 3 runs each, the best of them
#   RUNS=5 ./bench.sh
#   DATABASE_URL=postgres://user:pw@localhost:5432/blog_dev ./bench.sh
#                         also time a boot against Postgres (museum from
#                         the database plus the Moon Phish warm-up)
#
# No socket is needed. A boot is timed on _build/site.blimp cut just before
# `site = spawn Site` (the line that listens on :4100), so the program runs
# every step `blimp --serve` runs before it could answer, then exits:
#
#   load   the sources up to main.blimp's `t_boot = now_ms()`: parsing, and
#          every top-level binding of src/*.blimp
#   boot   the whole cut file: load, then posts rendered, routes built,
#          museum loaded
#   render the 15 reference posts through the renderer alone
#          (test/render_posts.blimp, as test/reference_diff.sh runs it)
#   tests  ./build.sh test, every test file
set -euo pipefail
cd "$(dirname "$0")"
BLIMP="${BLIMP:-/Users/bg/code/blimp-for-blog/chunks/lang/zig-out/bin/blimp}"
RUNS="${RUNS:-3}"
export BLIMP

ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }

# best of $RUNS wall-clock runs of "$@", in ms
best() {
  local b=""
  for _ in $(seq "$RUNS"); do
    local t0 t1
    t0=$(ms); "$@" > /dev/null 2>&1 || { echo "failed: $*" >&2; "$@" 2>&1 | tail -5 >&2; exit 1; }; t1=$(ms)
    local d=$((t1 - t0))
    if [ -z "$b" ] || [ "$d" -lt "$b" ]; then b=$d; fi
  done
  echo "$b"
}

./build.sh > /dev/null
line=$(grep -n '^t_boot = now_ms()' _build/site.blimp | cut -d: -f1)
[ -n "$line" ] || { echo "no t_boot line in _build/site.blimp" >&2; exit 1; }
head -n $((line - 1)) _build/site.blimp > _build/bench_load.blimp
spawn=$(grep -n '^site = spawn Site' _build/site.blimp | cut -d: -f1)
[ -n "$spawn" ] || { echo "no 'site = spawn Site' line in _build/site.blimp" >&2; exit 1; }
head -n $((spawn - 1)) _build/site.blimp > _build/bench_boot.blimp

# the manifest render_posts.blimp reads, as test/reference_diff.sh writes it
POSTS=../priv/static/posts
: > _build/posts.txt
for s in building-this-blog on-making-a-link-blog a-me-museum a-hilarious-shared-keyboard-key a-fun-experiment i-pulled-the-paul-tickets a-quick-typewriter-set-letter-project lets-write-letters whats-my-schtick nathan-fielder a-genstage-tutorial-and-reflection 327-years-of-tree-law-in-the-usa- vibe-coding-rescue-missions chess notes-on-dario-altman-elmo-and-the-frontier; do
  f=$(ls "$POSTS" | grep -E "^[0-9]{4}(-[0-9]{2}){5}-${s}\.md$" | head -1)
  printf '%s\t%s\n' "$s" "$POSTS/$f" >> _build/posts.txt
done
mkdir -p _build/out
if [ -f src/00_text.blimp ]; then
  cat src/00_text.blimp src/05_actors.blimp src/10_markdown.blimp test/render_posts.blimp > _build/bench_render.blimp
else
  R="src/05_actors.blimp src/10_markdown.blimp test/render_posts.blimp"
  { perl temper/prune.pl _build/temper.blimp $R; cat $R; } > _build/bench_render.blimp
fi

db="${DATABASE_URL:-}"
printf '%-24s %6s ms\n' "load" "$(env -u DATABASE_URL "$BLIMP" _build/bench_load.blimp >/dev/null; best env -u DATABASE_URL "$BLIMP" _build/bench_load.blimp)"
printf '%-24s %6s ms\n' "boot (data/*.tsv)" "$(best env -u DATABASE_URL "$BLIMP" _build/bench_boot.blimp)"
if [ -n "$db" ]; then
  printf '%-24s %6s ms\n' "boot (postgres + moon)" "$(best env DATABASE_URL="$db" "$BLIMP" _build/bench_boot.blimp)"
fi
printf '%-24s %6s ms\n' "render 15 posts" "$(best "$BLIMP" _build/bench_render.blimp)"
printf '%-24s %6s ms\n' "tests" "$(RUNS=1 best ./build.sh test)"
wc -c _build/site.blimp | awk '{printf "%-24s %6d bytes\n", "site.blimp", $1}'
