CREATE TYPE account_kind AS ENUM ('negative', 'positive', 'any');

CREATE TABLE openbill_categories (
    id bigserial PRIMARY KEY,
    name character varying(256) NOT NULL
);

COMMENT ON TABLE openbill_categories IS 'Account category. A convenient way to group accounts, for example: user accounts and system accounts, and also restrict transactions.';
COMMENT ON COLUMN openbill_categories.id IS 'Account category id';
COMMENT ON COLUMN openbill_categories.name IS 'Account category name';

CREATE UNIQUE INDEX index_openbill_categories_name ON openbill_categories USING btree (name);

INSERT INTO openbill_categories (name, id) VALUES ('System', -1);

CREATE TABLE openbill_accounts (
    id bigserial PRIMARY KEY,
    category_id bigint NOT NULL,
    amount_value numeric(36, 18) NOT NULL DEFAULT 0,
    amount_currency character varying(8) NOT NULL DEFAULT 'USD',
    details text,
    transactions_count integer NOT NULL DEFAULT 0,
    meta jsonb NOT NULL DEFAULT '{}'::jsonb,
    hold_value numeric(36, 18) NOT NULL DEFAULT 0,
    locked_at timestamp without time zone NULL,
    kind account_kind NOT NULL DEFAULT 'any',
    created_at timestamp without time zone DEFAULT current_timestamp,
    updated_at timestamp without time zone DEFAULT current_timestamp,
    FOREIGN KEY (category_id) REFERENCES openbill_categories (id) ON DELETE RESTRICT,
    CONSTRAINT openbill_accounts_kind CHECK ((kind = 'positive' AND amount_value >= 0) OR (kind = 'negative' AND amount_value <= 0) OR kind = 'any')
);
COMMENT ON TABLE openbill_accounts IS 'Account. Has a unique bigint identifier. Has information about the state of the account (balance), currency';
COMMENT ON COLUMN openbill_accounts.id IS 'Account unique id';
COMMENT ON COLUMN openbill_accounts.category_id IS 'Account category id, references table OPENBILL_CATEGORIES. Use for grouping accounts';
COMMENT ON COLUMN openbill_accounts.amount_value IS 'Account balance';
COMMENT ON COLUMN openbill_accounts.amount_currency IS 'Account currency';
COMMENT ON COLUMN openbill_accounts.details IS 'Account description';
COMMENT ON COLUMN openbill_accounts.transactions_count IS 'Number of transactions per account';
COMMENT ON COLUMN openbill_accounts.meta IS 'Account description in json format';
COMMENT ON COLUMN openbill_accounts.hold_value IS 'Hold amount';
COMMENT ON COLUMN openbill_accounts.locked_at IS 'The date the funds were holded. If the value is NULL there is no blocking';
COMMENT ON COLUMN openbill_accounts.kind IS 'Account type';
COMMENT ON COLUMN openbill_accounts.created_at IS 'Date time of account creation';
COMMENT ON COLUMN openbill_accounts.updated_at IS 'Date time of account modification';

CREATE INDEX index_accounts_on_meta ON openbill_accounts USING gin (meta);
CREATE INDEX index_accounts_on_created_at ON openbill_accounts USING btree (created_at);

CREATE TABLE openbill_transfers (
    id bigserial PRIMARY KEY,
    billing_date date DEFAULT current_date NOT NULL,
    created_at timestamp without time zone DEFAULT current_timestamp,
    from_account_id bigint NOT NULL,
    to_account_id bigint NOT NULL CONSTRAINT different_accounts CHECK (to_account_id <> from_account_id),
    amount_value numeric(36, 18) NOT NULL CONSTRAINT positive CHECK (amount_value > 0),
    amount_currency character varying(8) NOT NULL DEFAULT 'USD',
    idempotency_key character varying(256) NOT NULL,
    details text NOT NULL,
    meta jsonb NOT NULL DEFAULT '{}'::jsonb,
    reverse_transaction_id bigint,
    FOREIGN KEY (from_account_id) REFERENCES openbill_accounts (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (to_account_id) REFERENCES openbill_accounts (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT reverse_transaction_foreign_key FOREIGN KEY (reverse_transaction_id) REFERENCES openbill_transfers (id)
);
COMMENT ON TABLE openbill_transfers IS 'The operation of transferring funds between accounts. Has a unique identifier, identifiers of incoming and outgoing accounts, transfer amount, description.';
COMMENT ON COLUMN openbill_transfers.id IS 'Transfer unique id';
COMMENT ON COLUMN openbill_transfers.billing_date IS 'Foreign date time of transfer creation';
COMMENT ON COLUMN openbill_transfers.created_at IS 'Date time of transfer creation';
COMMENT ON COLUMN openbill_transfers.from_account_id IS 'Account from which the funds are transferred';
COMMENT ON COLUMN openbill_transfers.to_account_id IS 'Account to which funds are transferred';
COMMENT ON COLUMN openbill_transfers.amount_value IS 'Transfer amount';
COMMENT ON COLUMN openbill_transfers.amount_currency IS 'Transfer currency';
COMMENT ON COLUMN openbill_transfers.details IS 'Transfer description';
COMMENT ON COLUMN openbill_transfers.meta IS 'Transfer description in json format';
COMMENT ON COLUMN openbill_transfers.idempotency_key IS 'Human readable unique transfer key';

CREATE UNIQUE INDEX index_transfers_on_key ON openbill_transfers USING btree (idempotency_key);
CREATE INDEX index_transfers_on_meta ON openbill_transfers USING gin (meta);
CREATE INDEX index_transfers_on_created_at ON openbill_transfers USING btree (created_at);

CREATE TABLE openbill_policies (
    id bigserial PRIMARY KEY,
    name character varying(256) NOT NULL,
    from_category_id bigint,
    to_category_id bigint,
    from_account_id bigint,
    to_account_id bigint,
    allow_reverse boolean NOT NULL DEFAULT true,

    FOREIGN KEY (from_category_id) REFERENCES openbill_categories (id),
    FOREIGN KEY (to_category_id) REFERENCES openbill_categories (id),
    FOREIGN KEY (from_account_id) REFERENCES openbill_accounts (id),
    FOREIGN KEY (to_account_id) REFERENCES openbill_accounts (id)
);

COMMENT ON TABLE openbill_policies IS 'Funds transfer policies. Using this table, you can restrict the movement of funds between accounts. For example, allow write-offs from user accounts only to system ones.';
COMMENT ON COLUMN openbill_policies.id IS 'Policy unique id';
COMMENT ON COLUMN openbill_policies.name IS 'Policy name';
COMMENT ON COLUMN openbill_policies.from_category_id IS 'Category of accounts from which transfers are possible (NULL for all)';
COMMENT ON COLUMN openbill_policies.to_category_id IS 'Category of accounts to which transfers are possible (NULL for all)';
COMMENT ON COLUMN openbill_policies.to_account_id IS 'Accounts to which transfers are possible (NULL for all)';
COMMENT ON COLUMN openbill_policies.from_account_id IS 'Accounts from which transfers are possible (NULL for all)';

CREATE UNIQUE INDEX index_openbill_policies_name ON openbill_policies USING btree (name);

INSERT INTO openbill_policies (name) VALUES ('Allow any transactions');

CREATE TABLE openbill_holds (
    id bigserial PRIMARY KEY,
    date date DEFAULT current_date NOT NULL,
    created_at timestamp without time zone DEFAULT current_timestamp,
    account_id bigint NOT NULL,
    amount_value numeric(36, 18) NOT NULL,
    amount_currency character varying(8) NOT NULL DEFAULT 'USD',
    idempotency_key character varying(256) UNIQUE NOT NULL,
    details text NOT NULL,
    meta jsonb NOT NULL DEFAULT '{}'::jsonb,
    hold_key character varying(256),
    FOREIGN KEY (hold_key) REFERENCES openbill_holds (idempotency_key) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (account_id) REFERENCES openbill_accounts (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CHECK ((amount_value < 0 AND hold_key IS NOT NULL) OR (amount_value > 0 AND hold_key IS NULL))
);

CREATE INDEX index_holds_on_meta ON openbill_holds USING gin (meta);

COMMENT ON TABLE openbill_holds IS 'Operation of blocking funds on the account. Has a unique identifier, account identifier, blocking amount, description.';
COMMENT ON COLUMN openbill_holds.id IS 'Hold unique id';
COMMENT ON COLUMN openbill_holds.date IS 'Foreign date time of hold creation';
COMMENT ON COLUMN openbill_holds.created_at IS 'Date time of hold creation';
COMMENT ON COLUMN openbill_holds.account_id IS 'Account which the funds are holded';
COMMENT ON COLUMN openbill_holds.amount_value IS 'Hold amount';
COMMENT ON COLUMN openbill_holds.amount_currency IS 'Hold currency';
COMMENT ON COLUMN openbill_holds.details IS 'Hold description';
COMMENT ON COLUMN openbill_holds.meta IS 'Hold description in json format';
COMMENT ON COLUMN openbill_holds.idempotency_key IS 'Human readable unique hold key';
