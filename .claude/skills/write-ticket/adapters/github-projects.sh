#!/usr/bin/env bash
# write-ticket adapter: GitHub issue added to a Projects v2 board.
#
#   bash github-projects.sh <tracker.toml> <title-file> <body-file> [label,...]
#
# Four GraphQL calls through `gh api graphql`:
#   1. repository id and label ids          (query)
#   2. createIssue                          (mutation)  -> issue id, url
#   3. project id + the status field's option ids (query, needs read:project)
#   4. addProjectV2ItemById, then updateProjectV2ItemFieldValue (mutations)
# Prints the issue URL. If step 3 or 4 fails the issue already exists; the
# error says so and the URL is still printed, on stderr, so it is not lost.
#
# Config keys (under [github-projects]): owner, owner_type, project_number,
# repo, status_field, status_value, token_env (empty = gh's own token).
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
cfg=$1; title_file=$2; body_file=$3; labels=${4:-}

get() { python3 -I "$here/toml-get.py" "$cfg" "github-projects.$1" "${2-}"; }

owner=$(get owner)
owner_type=$(get owner_type "user")
project_number=$(get project_number)
repo=$(get repo)
status_field=$(get status_field "Status")
status_value=$(get status_value "")
token_env=$(get token_env "")

[ "$owner" != "your-login" ] || { echo "github-projects.sh: owner is still the placeholder" >&2; exit 2; }
case "$owner_type" in user|organization) ;; *) echo "github-projects.sh: owner_type must be user or organization" >&2; exit 2;; esac
if [ -n "$token_env" ]; then
  [ -n "${!token_env:-}" ] || { echo "github-projects.sh: \$$token_env is not set; no request made" >&2; exit 2; }
  export GH_TOKEN=${!token_env}
fi

repo_owner=${repo%%/*}
repo_name=${repo#*/}
title=$(<"$title_file")
body=$(<"$body_file")

gql() { gh api graphql "$@"; }
jpath() { python3 -I -c '
import json, sys
d = json.load(sys.stdin)
if d.get("errors"):
    sys.exit("graphql errors: " + json.dumps(d["errors"]))
for p in sys.argv[1].split("."):
    d = d[int(p)] if p.isdigit() else d[p]
print(d if not isinstance(d, (dict, list)) else json.dumps(d))' "$1"; }

# 1. repository id and label ids
repo_json=$(gql -f query='query($o:String!,$n:String!){ repository(owner:$o,name:$n){ id labels(first:100){ nodes{ id name } } } }' -f o="$repo_owner" -f n="$repo_name")
repo_id=$(printf '%s' "$repo_json" | jpath data.repository.id)
# One label id per line. gh's array syntax is `-f 'l[]=<id>'` repeated; a
# JSON array given to -F is sent as one string (checked live, see README).
label_args=()
while IFS= read -r id; do
  [ -n "$id" ] && label_args+=(-f "l[]=$id")
done < <(printf '%s' "$repo_json" | python3 -I -c '
import json, sys
want = [l.strip() for l in sys.argv[1].split(",") if l.strip()]
have = {n["name"]: n["id"] for n in json.load(sys.stdin)["data"]["repository"]["labels"]["nodes"]}
missing = [w for w in want if w not in have]
if missing:
    sys.exit("github-projects.sh: labels not in repo: " + ", ".join(missing))
print("\n".join(have[w] for w in want))' "$labels")

# 2. create the issue ($l is nullable; with no labels it is simply not sent)
issue_json=$(gql -f query='mutation($r:ID!,$t:String!,$b:String!,$l:[ID!]){ createIssue(input:{repositoryId:$r,title:$t,body:$b,labelIds:$l}){ issue{ id number url } } }' \
  -f r="$repo_id" -f t="$title" -f b="$body" ${label_args[@]+"${label_args[@]}"})   # bash 3.2 + set -u: empty array is "unbound"
issue_id=$(printf '%s' "$issue_json" | jpath data.createIssue.issue.id)
issue_url=$(printf '%s' "$issue_json" | jpath data.createIssue.issue.url)

board_fail() {
  echo "github-projects.sh: issue created at $issue_url but $1" >&2
  echo "$issue_url"
  exit 1
}

# 3. project id and the status field's options. ProjectV2.field(name:) returns
# a ProjectV2FieldConfiguration union; only the single-select member has options.
proj_json=$(gql -f query="query(\$o:String!,\$n:Int!,\$f:String!){ $owner_type(login:\$o){ projectV2(number:\$n){ id field(name:\$f){ ... on ProjectV2SingleSelectField{ id options{ id name } } } } } }" \
  -f o="$owner" -F n="$project_number" -f f="$status_field") || board_fail "the project lookup failed (token needs read:project)"
project_id=$(printf '%s' "$proj_json" | jpath "data.$owner_type.projectV2.id") || board_fail "the project lookup returned errors"
option_id=""
if [ -n "$status_value" ]; then
  option_id=$(printf '%s' "$proj_json" | python3 -I -c '
import json, sys
d = json.load(sys.stdin)["data"][sys.argv[1]]["projectV2"]["field"]
opts = {o["name"]: o["id"] for o in (d or {}).get("options", [])}
if sys.argv[2] not in opts:
    sys.exit(f"status option {sys.argv[2]!r} not in {sorted(opts)}")
print(opts[sys.argv[2]])' "$owner_type" "$status_value") || board_fail "the status option was not found"
fi

# 4. add to the board, then set the status
item_json=$(gql -f query='mutation($p:ID!,$c:ID!){ addProjectV2ItemById(input:{projectId:$p,contentId:$c}){ item{ id } } }' -f p="$project_id" -f c="$issue_id") || board_fail "adding it to the project failed (token needs project scope)"
item_id=$(printf '%s' "$item_json" | jpath data.addProjectV2ItemById.item.id) || board_fail "addProjectV2ItemById returned errors"

if [ -n "$option_id" ]; then
  field_id=$(printf '%s' "$proj_json" | jpath "data.$owner_type.projectV2.field.id")
  gql -f query='mutation($p:ID!,$i:ID!,$f:ID!,$v:String!){ updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:{singleSelectOptionId:$v}}){ projectV2Item{ id } } }' \
    -f p="$project_id" -f i="$item_id" -f f="$field_id" -f v="$option_id" >/dev/null || board_fail "setting $status_field=$status_value failed"
fi

echo "$issue_url"
