GRANT SELECT, INSERT, UPDATE ON openbill_categories TO public;
GRANT SELECT, DELETE ON openbill_accounts TO public;
GRANT INSERT (id, category_id, currency, details, meta, kind) ON openbill_accounts TO public;
GRANT UPDATE (locked_at, details) ON openbill_accounts TO public;
GRANT SELECT, INSERT ON openbill_transfers TO public;
GRANT SELECT, INSERT, UPDATE, DELETE ON openbill_policies TO public;

GRANT SELECT, INSERT ON openbill_holds TO public;

GRANT USAGE ON openbill_transfers_id_seq TO public;
GRANT USAGE ON openbill_accounts_id_seq TO public;
GRANT USAGE ON openbill_holds_id_seq TO public;
GRANT USAGE ON openbill_policies_id_seq TO public;
