#!/usr/bin/env bash
# Collect what a PR body is written from.
#
#   bash gather.sh [branch] [--base <branch>]
#
# Prints sections to stdout: base and why, commits, diff stat, diff (inline
# up to pr.toml's diff_inline_limit, then the path of the full diff in the
# scratch dir), decision-graph nodes on the branch (local db), the existing
# PR if any, and the body/title file paths. Read-only: it writes nothing but
# the diff file under $TMPDIR.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
cfg="$here/pr.toml"
root=$(git rev-parse --show-toplevel)
get() { python3 -I "$here/../write-ticket/adapters/toml-get.py" "$cfg" "$1" "${2-}"; }

branch=""
base_override=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base) base_override=$2; shift 2;;
    --base=*) base_override=${1#--base=}; shift;;
    -*) echo "gather.sh: unknown flag $1" >&2; exit 2;;
    *) branch=$1; shift;;
  esac
done
[ -n "$branch" ] || branch=$(git rev-parse --abbrev-ref HEAD)
git rev-parse --verify -q "$branch" >/dev/null || { echo "gather.sh: no branch $branch" >&2; exit 2; }

default_base=$(get base main)
body_dir=$(get body_dir .prs)
limit=$(get diff_inline_limit 60000)

# Stacked chapter? The last path component is NN-slug; the previous chapter
# is the highest MM-* with MM < NN under the same prefix, local or origin.
leaf=${branch##*/}
prefix=""
[ "$leaf" != "$branch" ] && prefix=${branch%/*}/
base=""
why=""
if [ -n "$base_override" ]; then
  base=$base_override; why="given with --base"
elif [[ $leaf =~ ^([0-9]+)-(.+)$ ]]; then
  n=$((10#${BASH_REMATCH[1]}))
  prev=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin \
    | sed 's#^origin/##' | sort -u \
    | { if [ -n "$prefix" ]; then grep -F "$prefix" | grep -E "^${prefix//./\\.}[0-9]+-"; else grep -E '^[0-9]+-'; fi; } \
    | python3 -I -c '
import re, sys
n = int(sys.argv[1]); best = None
for line in sys.stdin:
    b = line.strip(); leaf = b.rsplit("/", 1)[-1]
    m = re.match(r"^(\d+)-", leaf)
    if not m: continue
    k = int(m.group(1))
    if k < n and (best is None or k > best[0]): best = (k, b)
print(best[1] if best else "")' "$n")
  if [ -n "$prev" ]; then base=$prev; why="previous chapter of $leaf (highest MM-* with MM < $n under '${prefix:-/}')"
  else base=$default_base; why="$leaf is chapter $n but no lower-numbered chapter branch exists; pr.toml base"; fi
else
  base=$default_base; why="branch is not NN-slug; pr.toml base"
fi
# Prefer origin's copy of the base: a local main that is behind origin makes
# every merged commit since look like part of this branch.
if git rev-parse --verify -q "origin/$base" >/dev/null; then base_ref="origin/$base"
elif git rev-parse --verify -q "$base" >/dev/null; then base_ref=$base
else echo "gather.sh: base $base does not exist locally or on origin" >&2; exit 2; fi

echo "## branch"
echo "$branch"
echo
echo "## base"
echo "$base  ($why)"
echo
echo "## commits ($base_ref..$branch)"
git log --format='%h %s%n%b' --reverse "$base_ref..$branch" | sed '/^$/N;/^\n$/D'
echo
echo "## diff stat ($base_ref...$branch)"
git diff --stat "$base_ref...$branch" | tail -40
echo
tmp=${TMPDIR:-/tmp}
diff_file="$tmp/write-pr-$(printf '%s' "$branch" | tr '/' '_').diff"
git diff "$base_ref...$branch" > "$diff_file"
size=$(wc -c < "$diff_file" | tr -d ' ')
echo "## diff ($size bytes; full copy at $diff_file)"
if [ "$size" -le "$limit" ]; then cat "$diff_file"; else head -c "$limit" "$diff_file"; echo; echo "[... truncated at $limit bytes; read $diff_file]"; fi
echo
echo "## decision graph nodes on $branch (local db: deciduous nodes -b)"
deciduous nodes -b "$branch" 2>/dev/null | grep -v '^Update available' || echo "(deciduous not available or no local db)"
echo "(also run MCP query_nodes with branch=\"$branch\"; nodes written through the remote may not be here)"
echo
echo "## existing PR"
gh pr list --head "$branch" --state all --json number,url,baseRefName,title,state 2>/dev/null || echo "(gh not available)"
echo
echo "## files"
echo "body:  $root/$body_dir/$leaf.md"
echo "title: $root/$body_dir/$leaf.title"
echo "ignored: $(git -C "$root" check-ignore -q "$body_dir/x.md" && echo yes || echo "NO; open.sh will add $body_dir/ to .git/info/exclude")"
