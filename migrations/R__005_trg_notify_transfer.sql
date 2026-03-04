CREATE OR REPLACE FUNCTION notify_transfer() RETURNS TRIGGER AS $notify_transfer$
BEGIN
  PERFORM pg_notify('openbill_transfers', CAST(NEW.id AS text));

  return NEW;
END

$notify_transfer$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS notify_transfer ON openbill_transfers;
CREATE TRIGGER notify_transfer
  AFTER INSERT ON openbill_transfers FOR EACH ROW EXECUTE PROCEDURE notify_transfer();
