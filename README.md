# Openbill Core (SQL scheme, functions and triggers)

[![CI Functional](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml)
[![CI Multithread](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml)
[![SQL Style](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml)
[![Docs Pages](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml)

Openbill Core is a pure-PostgreSQL billing engine.

The project implements financial accounting at the database level (accounts, transfers, policies, holds) and enforces invariants through functions and triggers.

## Documentation

- Documentation site: https://openbill-service.github.io/openbill-core/
- Quick start for users: https://openbill-service.github.io/openbill-core/getting-started/
- Use-case catalog (`categories` + `policies`): https://openbill-service.github.io/openbill-core/use-cases/
- Performance:
  - https://openbill-service.github.io/openbill-core/benchmark_transfers_design/
  - https://openbill-service.github.io/openbill-core/pgbench_benchmark_report_2026-03-04/

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

## Core Concept

Openbill is built around three fundamental ideas:

1. **Ledger in PostgreSQL**: transactions are executed via plain SQL queries.
2. **Invariants in the database**: correctness is enforced by triggers and constraints, not just application code.
3. **Minimal infrastructure**: no separate API layer in the core.

## Key Entities

- `openbill_accounts` — accounts and balances.
- `openbill_transfers` — fund movement operations between accounts.
- `openbill_holds` — temporary fund locks.
- `openbill_categories` — account categories.
- `openbill_policies` — allowed transfer routes.

## Advantages

- Language-agnostic integration: any stack that speaks SQL.
- Deterministic behavior: validations happen at the database level.
- Simple operational footprint: fewer services and failure points.
- Transparent financial operation tracing through ledger tables.

## Quick Start (for project users)

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

-- 3) Verify the system invariant
SELECT amount_currency, SUM(amount_value)
FROM openbill_accounts
GROUP BY amount_currency;
```

Expected: the sum for each currency should be `0`.

## Audience Guide

### For Openbill Users

- Start here: [docs/getting-started.md](docs/getting-started.md)
- Use cases (by industry): [docs/examples/README.md](docs/examples/README.md)
- Run all examples: `./test-examples.sh`

### For openbill-core Developers

- Developer guide: [DEVELOPMENT.md](DEVELOPMENT.md)

## Related Projects

- https://github.com/openbill-service

## License

[Apache License 2.0](LICENSE)
