CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;

CREATE                TABLE OPENBILL_ACCOUNTS (
  id                  BIGSERIAL PRIMARY KEY,
  category            character varying(256) not null default 'common',
  key                 character varying(256) not null,
  amount_cents        numeric not null default 0,
  amount_currency     char(3) not null default 'USD',
  details             text,
  transactions_count  integer not null default 0,
  last_transaction_id integer,
  last_transaction_at timestamp without time zone,
  available_incoming  boolean not null default true,
  available_outgoing  boolean not null default true,
  meta                hstore not null default ''::hstore,
  created_at          timestamp without time zone default current_timestamp,
  updated_at          timestamp without time zone default current_timestamp
);

ALTER TABLE OPENBILL_ACCOUNTS ADD constraint some_availables CHECK (available_incoming OR available_outgoing);

CREATE UNIQUE INDEX index_accounts_on_id ON OPENBILL_ACCOUNTS USING btree (id);
CREATE UNIQUE INDEX index_accounts_on_key ON OPENBILL_ACCOUNTS USING btree (category, key);
CREATE INDEX index_accounts_on_meta ON OPENBILL_ACCOUNTS USING gin (meta);
CREATE INDEX index_accounts_on_created_at ON OPENBILL_ACCOUNTS USING btree (created_at);

CREATE TABLE OPENBILL_TRANSACTIONS (
  id              BIGSERIAL PRIMARY KEY,
  username        character varying(255) not null,
  created_at      timestamp without time zone default current_timestamp,
  from_account_id integer not null,
  to_account_id   integer not null,
  amount_cents    numeric not null CONSTRAINT positive CHECK (amount_cents>0),
  amount_currency char(3) not null,
  key             character varying(256) not null,
  details         text not null,
  meta            hstore not null default ''::hstore,
  foreign key (from_account_id) REFERENCES OPENBILL_ACCOUNTS (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  foreign key (to_account_id) REFERENCES OPENBILL_ACCOUNTS (id)
);

CREATE UNIQUE INDEX index_transactions_on_key ON OPENBILL_TRANSACTIONS USING btree (key);
CREATE INDEX index_transactions_on_meta ON OPENBILL_TRANSACTIONS USING gin (meta);
CREATE INDEX index_transactions_on_created_at ON OPENBILL_TRANSACTIONS USING btree (created_at);
ALTER TABLE OPENBILL_ACCOUNTS ADD FOREIGN KEY(last_transaction_id) REFERENCES OPENBILL_TRANSACTIONS(id) ON DELETE RESTRICT ON UPDATE RESTRICT;
