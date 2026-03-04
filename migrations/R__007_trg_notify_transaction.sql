CREATE OR REPLACE FUNCTION notify_transaction() RETURNS TRIGGER AS $notify_transaction$
BEGIN
  PERFORM pg_notify('openbill_transfers', CAST(NEW.id AS text));

  return NEW;
END

$notify_transaction$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS notify_transaction ON OPENBILL_TRANSFERS;
CREATE TRIGGER notify_transaction
  AFTER INSERT ON OPENBILL_TRANSFERS FOR EACH ROW EXECUTE PROCEDURE notify_transaction();
