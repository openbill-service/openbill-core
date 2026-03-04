#!/usr/bin/env bash

test -z "$PGDATABASE" && PGDATABASE='openbill_test'
test -z "$PG_SUPERUSER" && PG_SUPERUSER=postgres
export PGUSER=$PG_SUPERUSER

TESTUSER=openbill-test

LOGS_DIR='./log/'; test -d $LOGS_DIR || mkdir $LOGS_DIR

LOGFILE="$LOGS_DIR/create.log"

message="Recreate database ${PGDATABASE}"

echo $message
echo $message > $LOGFILE

dropuser --if-exists $TESTUSER && psql -c "CREATE USER \"$TESTUSER\" WITH PASSWORD 'postgres';" && \
dropdb --if-exists $PGDATABASE >> $LOGFILE &&  createdb $PGDATABASE >> $LOGFILE && \
  cat ./migrations/V???_*.sql | psql -1 $PGDATABASE >> $LOGFILE && \
  cat ./migrations/R__*.sql | psql -1 $PGDATABASE >> $LOGFILE
