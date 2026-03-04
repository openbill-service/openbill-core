CREATE OR REPLACE FUNCTION process_account_transaction() RETURNS TRIGGER AS $process_transaction$
DECLARE
  v_from_account OPENBILL_ACCOUNTS%rowtype;
  v_to_currency character varying(8);
BEGIN
  -- Загружаем from-счёт одним запросом: валюта + блокировка
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.from_account_id INTO v_from_account;

  IF v_from_account.amount_currency <> NEW.amount_currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.from_account_id;
  END IF;

  IF v_from_account.locked_at IS NOT NULL THEN
    RAISE EXCEPTION 'Account (from #%) is hold from %', NEW.to_account_id, v_from_account.locked_at;
  END IF;

  -- Проверяем валюту to-счёта
  SELECT amount_currency FROM OPENBILL_ACCOUNTS WHERE id = NEW.to_account_id INTO v_to_currency;
  IF v_to_currency <> NEW.amount_currency THEN
    RAISE EXCEPTION 'Account (to #%) has wrong currency', NEW.to_account_id;
  END IF;

  -- Обновляем балансы (порядок по id для предотвращения deadlock)
  IF NEW.to_account_id > NEW.from_account_id THEN
    UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
    UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;
  ELSE
    UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;
    UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
  END IF;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS process_account_transaction ON OPENBILL_TRANSFERS;
CREATE TRIGGER process_account_transaction
  AFTER INSERT ON OPENBILL_TRANSFERS FOR EACH ROW EXECUTE PROCEDURE process_account_transaction();
