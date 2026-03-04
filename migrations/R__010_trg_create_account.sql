-- Триггер create_account удалён:
-- защиту от INSERT с ненулевым балансом обеспечивает колоночный GRANT INSERT
-- (без amount_value, hold_value, transactions_count)

DROP TRIGGER IF EXISTS create_account ON OPENBILL_ACCOUNTS;
DROP FUNCTION IF EXISTS create_account();
