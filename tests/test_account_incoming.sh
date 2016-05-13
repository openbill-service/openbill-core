#!/usr/bin/env sh

. ./tests/init.sh && \

echo "insert into OPENBILL_ACCOUNTS  (key, available_incoming, available_outgoing) values ('gid://owner1', true, false)" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (key, available_incoming, available_outgoing) values ('gid://owner2', false, true )" | ./tests/sql.sh && \
echo "insert into OPENBILL_ACCOUNTS  (key, available_incoming, available_outgoing) values ('gid://owner3', true, true )" | ./tests/sql.sh && \

./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', 1, 2, 'gid://order1', 'test')" 'ERROR:  Account (from #1) does not allow outgoing transactions' && \
./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', 3, 2, 'gid://order2', 'test')" 'ERROR:  Account (to #2) does not allow incoming transactions' && \
./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', 2, 1, 'gid://order3', 'test')" 'INSERT 0 1' && \
./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', 2, 3, 'gid://order4', 'test')" 'INSERT 0 1' && \
./tests/assert_result.sh "insert into OPENBILL_TRANSACTIONS (amount_cents, amount_currency, from_account_id, to_account_id, key, details) values (100, 'USD', 3, 1, 'gid://order5', 'test')" 'INSERT 0 1'

# ./tests/assert_result.sh "update OPENBILL_TRANSACTIONS set amount_cents=1 where id=1" 'ERROR:  Cannot update or delete transaction' && \
# ./tests/assert_result.sh "delete from OPENBILL_TRANSACTIONS where id=1" 'ERROR:  Cannot update or delete transaction'
