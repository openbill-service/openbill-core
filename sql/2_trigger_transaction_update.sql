CREATE OR REPLACE FUNCTION openbill_transaction_update() RETURNS TRIGGER SECURITY DEFINER AS $process_transaction$
BEGIN

  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - OLD.amount_cents, transactions_count = transactions_count - 1 WHERE id = OLD.to_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents + NEW.amount_cents, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;

  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents + OLD.amount_cents, transactions_count = transactions_count - 1 WHERE id = OLD.from_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_cents = amount_cents - NEW.amount_cents, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;

  UPDATE OPENBILL_INVOICES SET paid_cents = paid_cents - OLD.amount_cents + NEW.amount_cents WHERE id = NEW.invoice_id;

  return NEW;
END

$process_transaction$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS openbill_transaction_update ON OPENBILL_TRANSACTIONS;
CREATE TRIGGER openbill_transaction_update
  AFTER UPDATE ON OPENBILL_TRANSACTIONS FOR EACH ROW EXECUTE PROCEDURE openbill_transaction_update();
