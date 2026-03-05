CREATE OR REPLACE FUNCTION process_account_transfer() RETURNS TRIGGER AS $process_transfer$
DECLARE
  v_from_account OPENBILL_ACCOUNTS%rowtype;
  v_to_currency character varying(8);
BEGIN
  -- Загружаем from-счёт одним запросом: валюта + блокировка
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.from_account_id INTO v_from_account;

  IF v_from_account.currency <> NEW.currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.from_account_id;
  END IF;

  IF v_from_account.locked_at IS NOT NULL THEN
    RAISE EXCEPTION 'Account (from #%) is hold from %', NEW.to_account_id, v_from_account.locked_at;
  END IF;

  -- Проверяем валюту to-счёта
  SELECT currency FROM OPENBILL_ACCOUNTS WHERE id = NEW.to_account_id INTO v_to_currency;
  IF v_to_currency <> NEW.currency THEN
    RAISE EXCEPTION 'Account (to #%) has wrong currency', NEW.to_account_id;
  END IF;

  -- Обновляем балансы (порядок по id для предотвращения deadlock)
  IF NEW.to_account_id > NEW.from_account_id THEN
    UPDATE OPENBILL_ACCOUNTS SET balance = balance - NEW.amount, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
    UPDATE OPENBILL_ACCOUNTS SET balance = balance + NEW.amount, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;
  ELSE
    UPDATE OPENBILL_ACCOUNTS SET balance = balance + NEW.amount, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;
    UPDATE OPENBILL_ACCOUNTS SET balance = balance - NEW.amount, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;
  END IF;

  RETURN NEW;
END

$process_transfer$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS process_account_transfer ON openbill_transfers;
CREATE TRIGGER process_account_transfer
AFTER INSERT ON openbill_transfers FOR EACH ROW EXECUTE PROCEDURE process_account_transfer();
