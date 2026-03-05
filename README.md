# Openbill Core

Pure-PostgreSQL billing engine with database-level invariants for accounts, transfers, policies, and holds.

Русская версия: [README.ru.md](README.ru.md)

[![CI Functional](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml)
[![CI Multithread](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml)
[![SQL Style](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml)
[![Docs Pages](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml)

## What It Is

Openbill Core implements financial accounting directly in PostgreSQL.

- Ledger operations are plain SQL (`INSERT`/`SELECT`)
- Validation and correctness are enforced via constraints, functions, and triggers
- No mandatory API layer in the core

## Core Concepts

1. **Ledger in PostgreSQL**: transfers are written and validated in SQL.
2. **Invariants in the database**: correctness rules live with data.
3. **Minimal infrastructure**: fewer moving parts and failure points.

## Advantages

- Language-agnostic integration for any stack with SQL access.
- Deterministic behavior: checks run at the same consistency boundary as writes.
- Transparent traceability through ledger tables.

## Dependencies

Only one dependency:

- PostgreSQL 13+

Nothing else is required for the core: no separate API service, SDK, or extra runtime.

## Quick Start (Project Users)

Initialize the test database:

```shell
./tests/create.sh
```

Minimal scenario:

```sql
-- 1) Create two accounts
INSERT INTO openbill_accounts (category_id, details)
VALUES (-1, 'User wallet (readme)');

INSERT INTO openbill_accounts (category_id, details)
VALUES (-1, 'System income (readme)');

-- 2) Check balances before transfer
SELECT id, amount_value, amount_currency
FROM openbill_accounts
ORDER BY id;

-- 3) Register a transfer
WITH user_wallet AS (
  SELECT id FROM openbill_accounts
  WHERE details = 'User wallet (readme)'
  ORDER BY id DESC
  LIMIT 1
),
system_income AS (
  SELECT id FROM openbill_accounts
  WHERE details = 'System income (readme)'
  ORDER BY id DESC
  LIMIT 1
)
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
SELECT
  si.id,
  uw.id,
  500,
  'USD',
  'payment:demo:1',
  'Demo payment'
FROM user_wallet uw, system_income si
RETURNING id, from_account_id, to_account_id, amount_value, amount_currency;

-- 4) Check balances after transfer
SELECT id, amount_value, amount_currency
FROM openbill_accounts
ORDER BY id;

-- 5) Verify the invariant
SELECT amount_currency, SUM(amount_value)
FROM openbill_accounts
GROUP BY amount_currency;
```

Expected result: sum by each currency is `0`.

Example output for balances query on a fresh DB:

```text
-- before transfer
 id |     amount_value      | amount_currency
----+-----------------------+----------------
  1 | 0.000000000000000000  | USD
  2 | 0.000000000000000000  | USD

-- after transfer
 id |      amount_value      | amount_currency
----+------------------------+----------------
  1 | 500.000000000000000000 | USD
  2 | -500.000000000000000000 | USD
```

Why balances changed automatically: `INSERT` into `openbill_transfers` triggers database function `process_account_transfer`, which debits `from_account_id` and credits `to_account_id`.
Each transfer is double-entry: one debit and one credit for the same amount.

Why `category_id = -1`: migrations create default category `System` with `id = -1` for quick start. In production, create domain-specific categories and policies.

## Industry Examples

Examples by industry:

- [Marketplace](docs/examples/marketplace/README.md)
- [SaaS Subscriptions](docs/examples/saas-subscriptions/README.md)
- [P2P Wallet](docs/examples/p2p-wallet/README.md)
- [Donations](docs/examples/donations/README.md)
- [Gift Cards](docs/examples/gift-cards/README.md)
- [Affiliate Payouts](docs/examples/affiliate-payouts/README.md)
- [Gaming](docs/examples/gaming/README.md)
- [Exchange](docs/examples/exchange/README.md)
- [Crypto Custody](docs/examples/crypto-custody/README.md)
- [Bank](docs/examples/bank/README.md)
- [Payment System (PSP)](docs/examples/payment-system-psp/README.md)
- [Insurance](docs/examples/insurance/README.md)
- [Payroll](docs/examples/payroll/README.md)
- [Credit / BNPL](docs/examples/credit-bnpl/README.md)
- [Card Issuer](docs/examples/card-issuer/README.md)
- [Remittance](docs/examples/remittance/README.md)
- [Travel Booking](docs/examples/travel-booking/README.md)
- [Referral Program](docs/examples/referral-program/README.md)
- [Ad Network](docs/examples/ad-network/README.md)
- [Telecom Prepaid](docs/examples/telecom-prepaid/README.md)
- [Loyalty Bonuses](docs/examples/loyalty-bonuses/README.md)

## Documentation

- Documentation index: [docs/index.md](docs/index.md)
- Quick start: [docs/getting-started.md](docs/getting-started.md)
- Entities overview: [docs/entities/index.md](docs/entities/index.md)

## Benchmark Snapshot (2026-03-04)

Test setup: PostgreSQL 17.4, `pgbench -M prepared`, `16 clients`, `4 threads`, warmup `5s`, measure `15s`.
Benchmark server: Linux 6.8, Intel Core i7-2600K (8 vCPU), 31 GiB RAM.

| Scenario | Meaning | TPS |
|---|---|---:|
| Mass transactions (`account_pool`) | Random transfers across a pool of 200 accounts (closest to high-volume traffic) | 2074.320544 |
| Balance hold/unhold flow (`hold_cycle`) | Complex flow: `transfer -> hold -> transfer -> unhold -> transfer` | 68.129177 |
| Contention stress (`hot_pair`) | Transfers only between two hot accounts under high concurrency | 339.196934 |

Invariant check after benchmark:
`sum(amount_value) + sum(hold_value) = 0.000000000000000000`

## Key Entities

- [`openbill_accounts`](docs/entities/accounts.md) - accounts and balances
- [`openbill_transfers`](docs/entities/transfers.md) - fund movement between accounts
- [`openbill_holds`](docs/glossary.md#hold) - temporary fund locks
- [`openbill_categories`](docs/entities/categories.md) - account categories
- [`openbill_policies`](docs/entities/policy.md) - allowed transfer routes

## Audience Guide

### For Openbill Users

- Start here: [docs/getting-started.md](docs/getting-started.md)
- Entities reference: [docs/entities/index.md](docs/entities/index.md)
- Use-case catalog: [docs/examples/README.md](docs/examples/README.md)
- Run all examples: `./test-examples.sh`

### Contributins

- Developer guide: [DEVELOPMENT.md](DEVELOPMENT.md)

## Related Projects

- https://github.com/openbill-service
- https://github.com/openbill-service/openbill-admin

## License

[Apache License 2.0](LICENSE)
