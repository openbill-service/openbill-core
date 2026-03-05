CREATE OR REPLACE FUNCTION process_reverse_transfer() RETURNS TRIGGER AS $process_transfer$
BEGIN
  IF NEW.reverse_transaction_id IS NOT NULL THEN
    PERFORM * FROM OPENBILL_TRANSFERS
      WHERE amount = NEW.amount
        AND currency = NEW.currency
        AND from_account_id = NEW.to_account_id
        AND to_account_id = NEW.from_account_id
        AND id = NEW.reverse_transaction_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Not found reverse transfer with same accounts and amount (#%)', NEW.reverse_transaction_id;
    END IF;

  END IF;

  RETURN NEW;
END

$process_transfer$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS process_reverse_transfer ON openbill_transfers;
CREATE TRIGGER process_reverse_transfer
AFTER INSERT ON openbill_transfers FOR EACH ROW EXECUTE PROCEDURE process_reverse_transfer();
