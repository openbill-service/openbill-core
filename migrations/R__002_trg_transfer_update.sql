CREATE OR REPLACE FUNCTION openbill_transfer_update() RETURNS TRIGGER AS $process_transfer$
BEGIN

  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - OLD.amount_value, transactions_count = transactions_count - 1 WHERE id = OLD.to_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.to_account_id;

  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + OLD.amount_value, transactions_count = transactions_count - 1 WHERE id = OLD.from_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - NEW.amount_value, transactions_count = transactions_count + 1 WHERE id = NEW.from_account_id;


  RETURN NEW;
END

$process_transfer$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS openbill_transfer_update ON openbill_transfers;
CREATE TRIGGER openbill_transfer_update
AFTER UPDATE ON openbill_transfers FOR EACH ROW EXECUTE PROCEDURE openbill_transfer_update();
