#!/bin/sh
# Run from this directory: sh run.sh
# lib/s.rb: Steep splats ->(a) when a is an Array, and only that spelling.
# lib/t.rb: the spellings that pass do really type a (both lines should error).
cd "$(dirname "$0")"
ruby lib/s.rb
steep check 2>&1 | grep -E '\[(error|warning)\]'
