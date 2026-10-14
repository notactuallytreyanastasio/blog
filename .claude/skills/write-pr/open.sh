#!/usr/bin/env bash
# Open a PR from a title file and a body file, or update the one that exists.
#
#   bash open.sh <branch> <title-file> <body-file> [--base <branch>] [--draft]
#
# Runs lint-body.py first and refuses to open on a failure. Makes sure the
# body directory is ignored (adds it to .git/info/exclude when it is not,
# since a body on disk in a fresh clone would otherwise be an untracked file
# waiting for a careless `git add`). Pushes the branch if origin does not
# have it. Prints the PR URL.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
cfg="$here/pr.toml"
root=$(git rev-parse --show-toplevel)
get() { python3 -I "$here/../write-ticket/adapters/toml-get.py" "$cfg" "$1" "${2-}"; }

[ $# -ge 3 ] || { echo "usage: open.sh <branch> <title-file> <body-file> [--base <branch>] [--draft]" >&2; exit 2; }
branch=$1; title_file=$2; body_file=$3; shift 3
base=""; draft=()
while [ $# -gt 0 ]; do
  case "$1" in
    --base) base=$2; shift 2;;
    --base=*) base=${1#--base=}; shift;;
    --draft) draft=(--draft); shift;;
    *) echo "open.sh: unknown argument $1" >&2; exit 2;;
  esac
done
[ -f "$title_file" ] || { echo "open.sh: no title file $title_file" >&2; exit 2; }
[ -f "$body_file" ] || { echo "open.sh: no body file $body_file" >&2; exit 2; }
title=$(<"$title_file")

python3 -I "$here/lint-body.py" "$body_file" "$cfg" || { echo "open.sh: body failed lint; not opening" >&2; exit 1; }

body_dir=$(get body_dir .prs)
if ! git -C "$root" check-ignore -q "$body_dir/x.md"; then
  exclude="$(git -C "$root" rev-parse --git-common-dir)/info/exclude"
  echo "$body_dir/" >> "$exclude"
  echo "open.sh: added $body_dir/ to $exclude" >&2
fi

if [ -z "$base" ]; then
  base=$(bash "$here/gather.sh" "$branch" | sed -n '/^## base$/{n;p;}' | cut -d' ' -f1)
fi

if ! git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  echo "open.sh: pushing $branch to origin" >&2
  git push -u origin "$branch" >&2
fi

existing=$(gh pr list --head "$branch" --state open --json number --jq '.[0].number // empty')
if [ -n "$existing" ]; then
  gh pr edit "$existing" --title "$title" --body-file "$body_file" >/dev/null
  echo "open.sh: updated #$existing" >&2
  gh pr view "$existing" --json url --jq .url
else
  gh pr create --base "$base" --head "$branch" --title "$title" --body-file "$body_file" "${draft[@]}"
fi
