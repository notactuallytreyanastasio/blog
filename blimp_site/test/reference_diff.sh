#!/usr/bin/env bash
# Render the 15 live posts with src/10_markdown.blimp and diff each against
# test/reference/<slug>.html (the Phoenix/MDEx output).
#
# Two comparisons per post:
#   exact       the reference with <script>...</script> removed, since the
#               Blimp renderer strips scripts on purpose (the chess post's
#               Bluesky embeds). Nothing else is changed.
#   no-tokens   additionally drops lumis' token spans (<span > and every
#               </span>) inside <pre class="athl"> on both sides. The
#               renderer's highlighting is highlight.js's, not lumis's, so
#               its hljs-* spans are dropped the same way.
#
# Usage: test/reference_diff.sh [-v]   (-v prints the diffs)
set -uo pipefail
cd "$(dirname "$0")/.."
BLIMP="${BLIMP:-/Users/bg/code/blimp-for-blog/chunks/lang/zig-out/bin/blimp}"
POSTS="${POSTS:-../priv/static/posts}"
SLUGS="building-this-blog on-making-a-link-blog a-me-museum a-hilarious-shared-keyboard-key a-fun-experiment i-pulled-the-paul-tickets a-quick-typewriter-set-letter-project lets-write-letters whats-my-schtick nathan-fielder a-genstage-tutorial-and-reflection 327-years-of-tree-law-in-the-usa- vibe-coding-rescue-missions chess notes-on-dario-altman-elmo-and-the-frontier"

mkdir -p _build/out _build/cmp
: > _build/posts.txt
for s in $SLUGS; do
  f=$(ls "$POSTS" 2>/dev/null | grep -E "^[0-9]{4}(-[0-9]{2}){5}-${s}\.md$" | head -1)
  [ -z "$f" ] && { echo "missing post: $s"; exit 2; }
  f="$POSTS/$f"
  printf '%s\t%s\n' "$s" "$f" >> _build/posts.txt
done

# Only the text helpers (what the renderer uses of the Temper library,
# _build/temper.blimp, which build.sh makes) and the renderer: the other src
# files are other work in progress and are not what this compares.
./build.sh > /dev/null
R="src/05_actors.blimp src/10_markdown.blimp src/20_highlight.blimp test/render_posts.blimp"
{ perl temper/prune.pl _build/temper.blimp $R; cat $R; } > _build/render_posts.blimp
rm -f _build/out/*.html
/usr/bin/time -l "$BLIMP" _build/render_posts.blimp 2> _build/render_time.txt || { cat _build/render_time.txt; exit 2; }
awk '/real/{print "render all: " $1 "s"} /maximum resident/{printf "max RSS: %.1f MB\n", $1/1048576}' _build/render_time.txt

strip_scripts='undef $/; $_=<>; s/<script\b.*?<\/script>//gis; print'
strip_tokens='undef $/; $_=<>; s{(<pre class="athl">.*?</pre>)}{ my $b=$1; $b =~ s/<span >//g; $b =~ s/<span class="hljs-[^"]*">//g; $b =~ s/<\/span>//g; $b }gse; print'

status=0
for s in $SLUGS; do
  ref="test/reference/$s.html"; out="_build/out/$s.html"
  perl -e "$strip_scripts" "$ref" > "_build/cmp/$s.ref"
  perl -e "$strip_tokens" "_build/cmp/$s.ref" > "_build/cmp/$s.ref.nt"
  perl -e "$strip_tokens" "$out" > "_build/cmp/$s.out.nt"
  if cmp -s "_build/cmp/$s.ref" "$out"; then r="exact"
  elif cmp -s "_build/cmp/$s.ref.nt" "_build/cmp/$s.out.nt"; then r="match without token spans"
  else r="DIFFERS ($(diff "_build/cmp/$s.ref.nt" "_build/cmp/$s.out.nt" | grep -c '^[<>]') lines)"; status=1
    [ "${1:-}" = "-v" ] && diff "_build/cmp/$s.ref.nt" "_build/cmp/$s.out.nt" | head -40
  fi
  printf '%-45s %s\n' "$s" "$r"
done
exit $status
