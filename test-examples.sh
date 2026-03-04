#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$ROOT_DIR"

shopt -s nullglob
scripts=(docs/examples/*/test.sh)

if [ ${#scripts[@]} -eq 0 ]; then
  echo "No example test scripts found under docs/examples/*/test.sh"
  exit 1
fi

passed=0
failed=0

for script in "${scripts[@]}"; do
  example_name="$(basename "$(dirname "$script")")"
  echo "==> [$example_name]"

  if "$script"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi

done

echo "Examples test summary: passed=$passed failed=$failed"

if [ "$failed" -gt 0 ]; then
  exit 1
fi
