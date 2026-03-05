#!/usr/bin/env bash

. ./tests/init.sh && \

# Нельзя указать balance при INSERT (нет GRANT на колонку)
./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id, balance) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 100)" 'ERROR:  permission denied for table openbill_accounts' && \

# Нельзя указать hold_amount при INSERT (нет GRANT на колонку)
./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id, hold_amount) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 100)" 'ERROR:  permission denied for table openbill_accounts' && \

# Нельзя указать transactions_count при INSERT (нет GRANT на колонку)
./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id, transactions_count) values ($ACCOUNT1_UUID, $CATEGORY_UUID, 5)" 'ERROR:  permission denied for table openbill_accounts' && \

# Можно создать счёт с разрешёнными колонками (баланс = 0 по DEFAULT)
./tests/assert_result_include.sh "insert into OPENBILL_ACCOUNTS  (id, category_id) values ($ACCOUNT1_UUID, $CATEGORY_UUID)" 'INSERT 0 1'
