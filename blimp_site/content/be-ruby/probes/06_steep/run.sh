#!/bin/sh
# What Steep 2.1 reports for three kinds of mistake, and what it exits with.
# Run from this directory: sh run.sh
cd "$(dirname "$0")"
steep check 2>&1 | grep -E '\[(error|warning)\]'
steep check >/dev/null 2>&1; echo "exit: $?"
# the `D` shorthand from older docs is gone in Steep 2
printf 'target :t do\n  configure_code_diagnostics(D::Ruby.strict)\nend\n' > /tmp/Steepfile.d-probe
steep check --steepfile=/tmp/Steepfile.d-probe 2>&1 | grep -m1 -o "uninitialized constant [A-Za-z:]*"
# a warning alone still fails the check
(cd warning_only && steep check 2>&1 | grep -cE '\[warning\]' | sed 's/^/warnings: /'; steep check >/dev/null 2>&1; echo "warning only, exit: $?")
