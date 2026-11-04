#!/usr/bin/env bash
# Runs every kept workflow in order, one browser after another, and prints
# the report path for each. Same environment variables as a single run:
#
#   WALKTHROUGH_BASE_URL=http://localhost:4010 ./walk-all.sh
#   WALKTHROUGH_HEADLESS=1 WALKTHROUGH_PACE=fast ./walk-all.sh   # dry run
#
# A failing workflow does not stop the tour; the summary at the end says
# which ones failed.
set -u -o pipefail   # pipefail: the grep below must not hide Playwright's exit code
cd "$(dirname "$0")"

failed=()
for workflow in workflows/*.json; do
  case "$workflow" in
    */leave_a_comment.json) continue ;;   # writes to the database; run it on its own
    */who_unlocked.json) continue ;;      # needs WHO_CHAT_PASSWORD and spends model credit
  esac
  echo
  echo "=== $workflow"
  if ! WALKTHROUGH_FILE="$workflow" npx playwright test --reporter=list 2>&1 | grep -v '^$' | grep -v 'Running 1 test\|Error Context\|^  [0-9]* \(passed\|failed\)'; then
    failed+=("$workflow")
  fi
done

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "All workflows passed."
else
  echo "Failed: ${failed[*]}"
  exit 1
fi
