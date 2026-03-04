#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../.." >/dev/null 2>&1 && pwd)"
EXAMPLE_NAME="$(basename "$SCRIPT_DIR")"

cd "$ROOT_DIR"

: "${PGDATABASE:=openbill_test}"
: "${PG_SUPERUSER:=postgres}"
: "${PGHOST:=127.0.0.1}"
: "${PGPASSWORD:=postgres}"

printf '[%s] recreate database %s\n' "$EXAMPLE_NAME" "$PGDATABASE"
PGDATABASE="$PGDATABASE" PG_SUPERUSER="$PG_SUPERUSER" PGHOST="$PGHOST" PGPASSWORD="$PGPASSWORD" ./tests/create.sh >/dev/null

printf '[%s] apply categories-and-policies.sql\n' "$EXAMPLE_NAME"
PGDATABASE="$PGDATABASE" PGHOST="$PGHOST" PGPASSWORD="$PGPASSWORD" psql --set ON_ERROR_STOP=1 -f "$SCRIPT_DIR/categories-and-policies.sql" >/dev/null

printf '[%s] run operations.sql\n' "$EXAMPLE_NAME"
PGDATABASE="$PGDATABASE" PGHOST="$PGHOST" PGPASSWORD="$PGPASSWORD" psql --set ON_ERROR_STOP=1 -f "$SCRIPT_DIR/operations.sql" >/dev/null

printf '[%s] OK\n' "$EXAMPLE_NAME"
