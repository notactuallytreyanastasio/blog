#!/bin/sh
# Run from this directory: sh run.sh
cd "$(dirname "$0")"
ruby lib/l.rb
steep check 2>&1 | grep -E '\[(error|warning)\]'
