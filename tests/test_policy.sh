#!/usr/bin/env sh

TRANSACTION_UUID="200"

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

./tests/assert_result_include.sh "delete from OPENBILL_POLICIES" 'DELETE 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'No policy for this transaction' && \
./tests/assert_result_include.sh "insert into OPENBILL_POLICIES (name, from_account_id, to_account_id) VALUES ('test', $ACCOUNT1_UUID, $ACCOUNT2_UUID)" 'INSERT 0 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (id, amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values ($TRANSACTION_UUID, 100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'INSERT 0 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order3', 'test')" 'No policy for this transaction' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (reverse_transaction_id, amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values ($TRANSACTION_UUID, 100, 'USD', $ACCOUNT2_UUID, $ACCOUNT1_UUID, 'gid://order3', 'test')" 'INSERT 0 1' && \
./tests/assert_result_include.sh "delete from OPENBILL_POLICIES" 'DELETE 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_POLICIES (name, from_category_id) VALUES ('test', $CATEGORY_UUID)" 'INSERT 0 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSACTIONS (amount_value, amount_currency, from_account_id, to_account_id, remote_idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order2', 'test')" 'INSERT 0 1'
