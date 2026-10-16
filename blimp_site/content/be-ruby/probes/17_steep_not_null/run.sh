#!/bin/sh
# Run from this directory: sh run.sh
# Three ways to write [T] (T?) -> T. Only case/when gets past Steep.
cd "$(dirname "$0")"
steep check 2>&1 | grep -E '\[(error|warning)\]'
