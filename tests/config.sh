export PGDATABASE='openbill_test'
test -z "$PGHOST" && export PGHOST=127.0.0.1
test -z "$PGPASSWORD" && export PGPASSWORD=postgres
export _ACCOUNT1_UUID="1"
export ACCOUNT1_UUID="$_ACCOUNT1_UUID"
export ACCOUNT2_UUID="2"
export ACCOUNT3_UUID="3"
export CATEGORY_UUID="-1"
