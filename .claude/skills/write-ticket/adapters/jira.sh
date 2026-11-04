#!/usr/bin/env bash
# write-ticket adapter: Jira Cloud, REST API v3.
#
#   bash jira.sh <tracker.toml> <title-file> <body-file> [label,label,...]
#
# Creates one issue with POST /rest/api/3/issue and prints its browse URL.
# Config keys (under [jira]): base_url, project_key, issue_type or
# issue_type_id, token_env, email_env (empty for Bearer auth).
#
# The description is sent as Atlassian Document Format (adf.py); v3 rejects a
# plain string there. Labels in Jira cannot contain spaces; they are sent as
# given and Jira returns 400 naming the field if one is invalid.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
cfg=$1; title_file=$2; body_file=$3; labels=${4:-}

get() { python3 -I "$here/toml-get.py" "$cfg" "jira.$1" "${2-}"; }

base_url=$(get base_url)
project_key=$(get project_key)
issue_type=$(get issue_type "")
issue_type_id=$(get issue_type_id "")
token_env=$(get token_env)
email_env=$(get email_env "")

base_url=${base_url%/}
case "$base_url" in
  *your-domain.atlassian.net*) echo "jira.sh: base_url is still the placeholder" >&2; exit 2;;
esac

token=${!token_env:-}
[ -n "$token" ] || { echo "jira.sh: \$$token_env is not set; no request made" >&2; exit 2; }

auth=()
if [ -n "$email_env" ]; then
  email=${!email_env:-}
  [ -n "$email" ] || { echo "jira.sh: \$$email_env is not set; no request made" >&2; exit 2; }
  auth=(-u "$email:$token")
else
  auth=(-H "Authorization: Bearer $token")
fi

# Build the request body. adf.py turns the Markdown-ish body into ADF; the
# rest is assembled here so the title is JSON-escaped properly.
payload=$(python3 -I - "$title_file" "$body_file" "$project_key" "$issue_type" "$issue_type_id" "$labels" "$here" <<'EOF'
import json, subprocess, sys
title_file, body_file, project_key, issue_type, issue_type_id, labels, here = sys.argv[1:8]
title = open(title_file, encoding="utf-8").read().strip()
adf = json.loads(subprocess.check_output(
    [sys.executable, "-I", f"{here}/adf.py", body_file], text=True))
fields = {
    "project": {"key": project_key},
    "summary": title,
    "description": adf,
}
if issue_type_id:
    fields["issuetype"] = {"id": issue_type_id}
elif issue_type:
    fields["issuetype"] = {"name": issue_type}
else:
    sys.exit("jira.sh: set issue_type or issue_type_id")
if labels.strip():
    fields["labels"] = [l.strip() for l in labels.split(",") if l.strip()]
json.dump({"fields": fields}, sys.stdout)
EOF
)

response_file=$(mktemp)
trap 'rm -f "$response_file"' EXIT
status=$(curl -sS -o "$response_file" -w '%{http_code}' \
  -X POST "$base_url/rest/api/3/issue" \
  "${auth[@]}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  --data "$payload")

if [ "$status" != "201" ]; then
  echo "jira.sh: POST $base_url/rest/api/3/issue returned $status" >&2
  cat "$response_file" >&2; echo >&2
  exit 1
fi

key=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["key"])' "$response_file")
echo "$base_url/browse/$key"
