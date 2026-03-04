CREATE OR REPLACE FUNCTION openbill_transfer_delete() RETURNS TRIGGER  AS $process_transfer$
BEGIN
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value - OLD.amount_value, transactions_count = transactions_count - 1 WHERE id = OLD.to_account_id;
  UPDATE OPENBILL_ACCOUNTS SET amount_value = amount_value + OLD.amount_value, transactions_count = transactions_count - 1 WHERE id = OLD.from_account_id;

  return OLD;
END

$process_transfer$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS openbill_transfer_delete ON OPENBILL_TRANSFERS;
CREATE TRIGGER openbill_transfer_delete
  BEFORE DELETE ON OPENBILL_TRANSFERS FOR EACH ROW EXECUTE PROCEDURE openbill_transfer_delete();
