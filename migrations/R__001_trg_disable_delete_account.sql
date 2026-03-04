-- Триггеры disable_update_account и disable_delete_account удалены:
-- - защиту от UPDATE обеспечивает колоночный GRANT UPDATE (locked_at, details)
-- - защиту от DELETE обеспечивают FK RESTRICT на OPENBILL_TRANSFERS и OPENBILL_HOLDS
-- - защиту от INSERT с ненулевым балансом обеспечивает колоночный GRANT INSERT (без amount_value, hold_value)

DROP TRIGGER IF EXISTS disable_delete_account ON OPENBILL_ACCOUNTS;
DROP TRIGGER IF EXISTS disable_update_account ON OPENBILL_ACCOUNTS;
DROP FUNCTION IF EXISTS disable_delete_account();
DROP FUNCTION IF EXISTS disable_update_account();
