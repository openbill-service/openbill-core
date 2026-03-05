#!/usr/bin/env sh

. ./tests/init.sh && \
. ./tests/2accounts.sh && \

export PGUSER=openbill-test

# Можно удалить пустой счёт (без transfers)
./tests/assert_result_include.sh "delete from OPENBILL_ACCOUNTS where id=$ACCOUNT1_UUID" 'DELETE 1' && \

# Пересоздаём счёт и делаем transfer, чтобы проверить запрет удаления
./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS (id, category_id) values ($ACCOUNT1_UUID, $CATEGORY_UUID)" 'INSERT 0 1' && \
./tests/assert_result_include.sh "insert into OPENBILL_TRANSFERS (amount, currency, from_account_id, to_account_id, idempotency_key, details) values (100, 'USD', $ACCOUNT1_UUID, $ACCOUNT2_UUID, 'gid://order1', 'test')" 'INSERT 0 1' && \

# Нельзя удалить счёт с transfers (FK RESTRICT)
./tests/assert_result_include.sh "delete from OPENBILL_ACCOUNTS where id=$ACCOUNT1_UUID" 'violates foreign key constraint' && \

# Можно обновлять details
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set details='some' where id=$ACCOUNT1_UUID" 'UPDATE 1' && \

# Нельзя менять баланс и timestamps напрямую
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set balance=123 where id=$ACCOUNT1_UUID" 'ERROR:  permission denied for table openbill_accounts' && \
./tests/assert_result_include.sh "update OPENBILL_ACCOUNTS set created_at=current_date where id=$ACCOUNT1_UUID" 'ERROR:  permission denied for table openbill_accounts'
