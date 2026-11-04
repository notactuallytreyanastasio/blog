#!/usr/bin/env bash
# Dispatch a ticket to the adapter named in tracker.toml.
#
#   bash file.sh <title-file> <body-file> [label,label,...]
#
# Prints the created ticket's URL on stdout. Everything else goes to stderr.
# Config: tracker.local.toml next to this file if it exists, else
# tracker.toml; TRACKER_CONFIG=<path> overrides both.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)

if [ $# -lt 2 ]; then
  echo "usage: file.sh <title-file> <body-file> [labels]" >&2
  exit 2
fi
title_file=$1
body_file=$2
labels=${3:-}

cfg=${TRACKER_CONFIG:-}
if [ -z "$cfg" ]; then
  if [ -f "$here/tracker.local.toml" ]; then
    cfg="$here/tracker.local.toml"
  else
    cfg="$here/tracker.toml"
  fi
fi
[ -f "$cfg" ] || { echo "file.sh: no config at $cfg" >&2; exit 2; }
[ -f "$title_file" ] || { echo "file.sh: no title file at $title_file" >&2; exit 2; }
[ -f "$body_file" ] || { echo "file.sh: no body file at $body_file" >&2; exit 2; }

adapter=$(python3 -I "$here/adapters/toml-get.py" "$cfg" adapter)
script="$here/adapters/$adapter.sh"
[ -f "$script" ] || { echo "file.sh: adapter '$adapter' has no $script" >&2; exit 2; }

echo "file.sh: adapter=$adapter config=$cfg" >&2
exec bash "$script" "$cfg" "$title_file" "$body_file" "$labels"
