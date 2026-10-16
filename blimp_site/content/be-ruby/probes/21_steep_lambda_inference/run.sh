#!/bin/sh
# Run from this directory: sh run.sh
# Empty arrays, and lambdas passed to generic methods: which ones Steep can type.
# The numbered lines in lib/g.rb are the cases; errors name their lines.
cd "$(dirname "$0")"
ruby lib/g.rb
steep check 2>&1 | grep -E '\[(error|warning)\]'
