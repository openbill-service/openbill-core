-- Проверка валюты перенесена в R__005 (process_account_transaction).
-- Этот файл только удаляет устаревший триггер из существующих БД.

DROP TRIGGER IF EXISTS constraint_accounts_currency_in_transactions ON OPENBILL_TRANSFERS;
DROP FUNCTION IF EXISTS constraint_accounts_currency_in_transactions();
