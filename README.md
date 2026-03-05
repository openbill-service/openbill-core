# Openbill Core

Pure-PostgreSQL billing engine with database-level invariants for accounts, transfers, policies, and holds.

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

## Quick Start (Project Users)

Requirements:

- PostgreSQL 13+

Initialize the test database:

```shell
./tests/create.sh
```

Minimal scenario:

```sql
-- 1) Create two accounts
INSERT INTO openbill_accounts (category_id, details) VALUES (-1, 'User wallet');
INSERT INTO openbill_accounts (category_id, details) VALUES (-1, 'System income');

-- 2) Register a transfer
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (2, 1, 500, 'USD', 'payment:demo:1', 'Demo payment');

-- 3) Verify the invariant
SELECT amount_currency, SUM(amount_value)
FROM openbill_accounts
GROUP BY amount_currency;
```

Expected result: sum by each currency is `0`.

## Documentation

- Documentation site: https://openbill-service.github.io/openbill-core/
- Quick start: https://openbill-service.github.io/openbill-core/getting-started/
- Entities overview: https://openbill-service.github.io/openbill-core/entities/
- Performance:
  - https://openbill-service.github.io/openbill-core/benchmark_transfers_design/
  - https://openbill-service.github.io/openbill-core/pgbench_benchmark_report_2026-03-04/

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

### For openbill-core Developers

- Developer guide: [DEVELOPMENT.md](DEVELOPMENT.md)

## Industry Examples

Full catalog:

- [Examples Catalog](docs/examples/README.md)

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

## Related Projects

- https://github.com/openbill-service

## License

[Apache License 2.0](LICENSE)
