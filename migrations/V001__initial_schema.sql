CREATE TYPE account_kind AS ENUM ('negative', 'positive', 'any');

CREATE                TABLE OPENBILL_CATEGORIES (
  id                  bigserial PRIMARY KEY,
  name                character varying(256) not null
);

COMMENT ON TABLE OPENBILL_CATEGORIES IS 'Account category. A convenient way to group accounts, for example: user accounts and system accounts, and also restrict transactions.';
COMMENT ON COLUMN OPENBILL_CATEGORIES.id IS 'Account category id';
COMMENT ON COLUMN OPENBILL_CATEGORIES.name IS 'Account category name';

CREATE UNIQUE INDEX index_openbill_categories_name ON OPENBILL_CATEGORIES USING btree (name);

INSERT INTO OPENBILL_CATEGORIES  (name, id) values ('System', -1);

CREATE                TABLE OPENBILL_ACCOUNTS (
  id                  bigserial PRIMARY KEY,
  category_id         bigint not null,
  amount_value        numeric(36,18) not null default 0,
  amount_currency     character varying(8) not null default 'USD',
  details             text,
  transactions_count  integer not null default 0,
  meta                jsonb not null default '{}'::jsonb,
  hold_value          numeric(36,18) not null default 0,
  locked_at           timestamp without time zone null,
  kind                account_kind NOT NULL DEFAULT 'any',
  created_at          timestamp without time zone default current_timestamp,
  updated_at          timestamp without time zone default current_timestamp,
  foreign key (category_id) REFERENCES OPENBILL_CATEGORIES (id) ON DELETE RESTRICT,
  CONSTRAINT openbill_accounts_kind CHECK ( (kind = 'positive' AND amount_value >=0) OR (kind = 'negative' AND amount_value<=0) OR kind = 'any' )
);
COMMENT ON TABLE OPENBILL_ACCOUNTS IS 'Account. Has a unique bigint identifier. Has information about the state of the account (balance), currency';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.id IS 'Account unique id';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.category_id IS 'Account category id, references table OPENBILL_CATEGORIES. Use for grouping accounts';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.amount_value IS 'Account balance';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.amount_currency IS 'Account currency';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.details IS 'Account description';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.transactions_count IS 'Number of transactions per account';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.meta IS 'Account description in json format';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.hold_value IS 'Hold amount';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.locked_at IS 'The date the funds were holded. If the value is NULL there is no blocking';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.kind IS 'Account type';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.created_at IS 'Date time of account creation';
COMMENT ON COLUMN OPENBILL_ACCOUNTS.updated_at IS 'Date time of account modification';

CREATE INDEX index_accounts_on_meta ON OPENBILL_ACCOUNTS USING gin (meta);
CREATE INDEX index_accounts_on_created_at ON OPENBILL_ACCOUNTS USING btree (created_at);

CREATE TABLE OPENBILL_TRANSFERS (
  id              bigserial PRIMARY KEY,
  billing_date    date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  from_account_id bigint not null,
  to_account_id   bigint not null CONSTRAINT different_accounts CHECK (to_account_id<>from_account_id),
  amount_value    numeric(36,18) not null CONSTRAINT positive CHECK (amount_value>0),
  amount_currency character varying(8) not null default 'USD',
  idempotency_key character varying(256) not null,
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  reverse_transaction_id bigint,
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT reverse_transaction_foreign_key FOREIGN KEY (reverse_transaction_id) REFERENCES OPENBILL_TRANSFERS (id)
);
COMMENT ON TABLE OPENBILL_TRANSFERS IS 'The operation of transferring funds between accounts. Has a unique identifier, identifiers of incoming and outgoing accounts, transfer amount, description.';
COMMENT ON COLUMN OPENBILL_TRANSFERS.id IS 'Transfer unique id';
COMMENT ON COLUMN OPENBILL_TRANSFERS.billing_date IS 'Foreign date time of transfer creation';
COMMENT ON COLUMN OPENBILL_TRANSFERS.created_at IS 'Date time of transfer creation';
COMMENT ON COLUMN OPENBILL_TRANSFERS.from_account_id IS 'Account from which the funds are transferred';
COMMENT ON COLUMN OPENBILL_TRANSFERS.to_account_id IS 'Account to which funds are transferred';
COMMENT ON COLUMN OPENBILL_TRANSFERS.amount_value IS 'Transfer amount';
COMMENT ON COLUMN OPENBILL_TRANSFERS.amount_currency IS 'Transfer currency';
COMMENT ON COLUMN OPENBILL_TRANSFERS.details IS 'Transfer description';
COMMENT ON COLUMN OPENBILL_TRANSFERS.meta IS 'Transfer description in json format';
COMMENT ON COLUMN OPENBILL_TRANSFERS.idempotency_key IS 'Human readable unique transfer key';

CREATE UNIQUE INDEX index_transfers_on_key ON OPENBILL_TRANSFERS USING btree (idempotency_key);
CREATE INDEX index_transfers_on_meta ON OPENBILL_TRANSFERS USING gin (meta);
CREATE INDEX index_transfers_on_created_at ON OPENBILL_TRANSFERS USING btree (created_at);

CREATE                TABLE OPENBILL_POLICIES (
  id                  bigserial PRIMARY KEY,
  name                character varying(256) not null,
  from_category_id    bigint,
  to_category_id      bigint,
  from_account_id     bigint,
  to_account_id       bigint,
  allow_reverse       boolean not null default true,

  foreign key (from_category_id) REFERENCES OPENBILL_CATEGORIES (id),
  foreign key (to_category_id) REFERENCES OPENBILL_CATEGORIES (id),
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id),
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id)
);

COMMENT ON TABLE OPENBILL_POLICIES IS 'Funds transfer policies. Using this table, you can restrict the movement of funds between accounts. For example, allow write-offs from user accounts only to system ones.';
COMMENT ON COLUMN OPENBILL_POLICIES.id IS 'Policy unique id';
COMMENT ON COLUMN OPENBILL_POLICIES.name IS 'Policy name';
COMMENT ON COLUMN OPENBILL_POLICIES.from_category_id IS 'Category of accounts from which transfers are possible (NULL for all)';
COMMENT ON COLUMN OPENBILL_POLICIES.to_category_id IS 'Category of accounts to which transfers are possible (NULL for all)';
COMMENT ON COLUMN OPENBILL_POLICIES.to_account_id IS 'Accounts to which transfers are possible (NULL for all)';
COMMENT ON COLUMN OPENBILL_POLICIES.from_account_id IS 'Accounts from which transfers are possible (NULL for all)';

CREATE UNIQUE INDEX index_openbill_policies_name ON OPENBILL_POLICIES USING btree (name);

INSERT INTO OPENBILL_POLICIES (name) VALUES ('Allow any transactions');

CREATE TABLE OPENBILL_HOLDS (
  id              bigserial PRIMARY KEY,
  date            date default current_date not null,
  created_at      timestamp without time zone default current_timestamp,
  account_id bigint not null,
  amount_value    numeric(36,18) not null,
  amount_currency character varying(8) not null default 'USD',
  idempotency_key             character varying(256) UNIQUE not null,
  details         text not null,
  meta            jsonb not null default '{}'::jsonb,
  hold_key   character varying(256),
  foreign key (hold_key) REFERENCES OPENBILL_HOLDS (idempotency_key) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CHECK ((amount_value < 0 AND hold_key is NOT NULL) or (amount_value >0 AND hold_key is NULL))
);

CREATE INDEX index_holds_on_meta ON OPENBILL_HOLDS USING gin (meta);

COMMENT ON TABLE OPENBILL_HOLDS IS 'Operation of blocking funds on the account. Has a unique identifier, account identifier, blocking amount, description.';
COMMENT ON COLUMN OPENBILL_HOLDS.id IS 'Hold unique id';
COMMENT ON COLUMN OPENBILL_HOLDS.date IS 'Foreign date time of hold creation';
COMMENT ON COLUMN OPENBILL_HOLDS.created_at IS 'Date time of hold creation';
COMMENT ON COLUMN OPENBILL_HOLDS.account_id IS 'Account which the funds are holded';
COMMENT ON COLUMN OPENBILL_HOLDS.amount_value IS 'Hold amount';
COMMENT ON COLUMN OPENBILL_HOLDS.amount_currency IS 'Hold currency';
COMMENT ON COLUMN OPENBILL_HOLDS.details IS 'Hold description';
COMMENT ON COLUMN OPENBILL_HOLDS.meta IS 'Hold description in json format';
COMMENT ON COLUMN OPENBILL_HOLDS.idempotency_key IS 'Human readable unique hold key';
