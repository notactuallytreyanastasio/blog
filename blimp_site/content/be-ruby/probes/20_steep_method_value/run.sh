#!/bin/sh
# Run from this directory: sh run.sh
# A module function as a value: method(:f) runs, and Steep will not take it
# as a proc type; a lambda that calls f is both.
cd "$(dirname "$0")"
ruby lib/m.rb
steep check 2>&1 | grep -E '\[(error|warning)\]'
