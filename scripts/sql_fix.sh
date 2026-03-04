#!/usr/bin/env bash
set -euo pipefail

SQLFLUFF_BIN="${SQLFLUFF_BIN:-sqlfluff}"

if ! command -v "$SQLFLUFF_BIN" >/dev/null 2>&1; then
  echo "sqlfluff not found. Install it first (pip install sqlfluff==3.4.1)."
  exit 127
fi

mapfile -t sql_files < <(git ls-files '*.sql')
if [[ ${#sql_files[@]} -eq 0 ]]; then
  echo "No SQL files found."
  exit 0
fi

"$SQLFLUFF_BIN" fix --config .sqlfluff "${sql_files[@]}"
