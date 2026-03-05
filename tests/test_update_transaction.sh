#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

export PGUSER=postgres
./tests/assert_result_include.sh "insert into OPENBILL_TRANSFERS (amount, currency, from_account_id, to_account_id, idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'INSERT 0 1' && \

./tests/assert_value.sh "select balance from OPENBILL_ACCOUNTS  where id=$ACCOUNT1_UUID" '-100.000000000000000000' && \
./tests/assert_value.sh "select balance from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '100.000000000000000000'

./tests/assert_result_include.sh "update OPENBILL_TRANSFERS set amount=200" 'UPDATE 1' && \

./tests/assert_value.sh "select balance from OPENBILL_ACCOUNTS  where id=$ACCOUNT1_UUID" '-200.000000000000000000' && \
./tests/assert_value.sh "select balance from OPENBILL_ACCOUNTS  where id=$ACCOUNT2_UUID" '200.000000000000000000'
