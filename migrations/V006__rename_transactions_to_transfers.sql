-- Переименование таблицы
ALTER TABLE OPENBILL_TRANSACTIONS RENAME TO OPENBILL_TRANSFERS;

-- Переименование колонки в OPENBILL_TRANSFERS
ALTER TABLE OPENBILL_TRANSFERS RENAME COLUMN remote_idempotency_key TO idempotency_key;

-- Переименование колонки в OPENBILL_HOLDS
ALTER TABLE OPENBILL_HOLDS RENAME COLUMN remote_idempotency_key TO idempotency_key;

-- Переименование sequence
ALTER SEQUENCE openbill_transactions_id_seq RENAME TO openbill_transfers_id_seq;

-- Переименование индексов
ALTER INDEX index_transactions_on_key RENAME TO index_transfers_on_key;
ALTER INDEX index_transactions_on_meta RENAME TO index_transfers_on_meta;
ALTER INDEX index_transactions_on_created_at RENAME TO index_transfers_on_created_at;

-- Переименование индекса в HOLDS
ALTER INDEX index_holds_on_key RENAME TO index_holds_on_idempotency_key;
