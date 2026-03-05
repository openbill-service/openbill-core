CREATE OR REPLACE FUNCTION openbill_holds_insert() RETURNS TRIGGER AS $process_hold$
DECLARE
 v_account OPENBILL_ACCOUNTS%rowtype;
 v_hold_amount numeric(36,18);
 v_release_funds_amount numeric(36,18);
BEGIN
  SELECT * FROM OPENBILL_ACCOUNTS WHERE id = NEW.account_id FOR UPDATE INTO v_account;
  -- У всех счетов и транзакции должна быть одинаковая валюта

  IF v_account.currency <> NEW.currency THEN
    RAISE EXCEPTION 'Account (from #%) has wrong currency', NEW.account_id;
  END IF;
  -- Нельзя заблокировать больше чем есть на счете
  IF NEW.amount > 0 AND NEW.amount > v_account.balance THEN
    RAISE EXCEPTION 'It is impossible to block the amount more than is on the account';
  END IF;

  -- Нельзя разблокировать больше чем есть на счете
  IF NEW.amount < 0 THEN
    SELECT amount FROM OPENBILL_HOLDS WHERE idempotency_key = NEW.hold_key INTO v_hold_amount;
    SELECT SUM(amount) FROM OPENBILL_HOLDS WHERE hold_key = NEW.hold_key INTO v_release_funds_amount;
    v_hold_amount = v_hold_amount + v_release_funds_amount;
    IF v_hold_amount < -NEW.amount OR v_account.hold_amount < -NEW.amount THEN
      RAISE EXCEPTION 'It is impossible to unblock the amount more than is on the account';
    END IF;
  END IF;


  UPDATE OPENBILL_ACCOUNTS SET balance = balance - NEW.amount, hold_amount = hold_amount + NEW.amount WHERE id = NEW.account_id;

  RETURN NEW;
END

$process_hold$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS openbill_holds_insert ON openbill_holds;
CREATE TRIGGER openbill_holds_insert
BEFORE INSERT ON openbill_holds FOR EACH ROW EXECUTE PROCEDURE openbill_holds_insert();
