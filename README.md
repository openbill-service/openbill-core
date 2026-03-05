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
- Financial architecture: categories model a chart of accounts (including hierarchical taxonomy at domain level), and policies enforce strict transfer routes between categories/accounts

## Core Concepts

1. **Ledger in PostgreSQL**: transfers are written and validated in SQL.
2. **Invariants in the database**: correctness rules live with data.
3. **Minimal infrastructure**: fewer moving parts and failure points.

## Dependencies

Only one dependency:

- PostgreSQL 13+

Nothing else is required for the core: no separate API service, SDK, or extra runtime.

### Why not the `money` type?

PostgreSQL has a built-in `money` type, but Openbill uses `numeric(36,18)` instead because `money` is locale-dependent (`lc_monetary`), has no currency field, and loses precision on division. `numeric` is locale-safe, supports arbitrary precision, and is the standard choice for ledger systems.

## Advantages

- Language-agnostic integration for any stack with SQL access.
- Deterministic behavior: checks run at the same consistency boundary as writes.
- Transparent traceability through ledger tables.
- Applications connect directly to PostgreSQL where the core is implemented, without a separate API layer, which reduces integration overhead and support costs.

## Invariants

All rules are enforced at the PostgreSQL level (constraints, triggers, GRANT). No client application can bypass them.

1. **System balance is always zero.** The sum of all funds across all accounts, including held amounts, is always zero. Money cannot appear from nowhere or disappear.
2. **Transfers are single-currency only.** The transfer currency must match the currency of both the source and destination accounts.
3. **Transfers are only between different accounts.** You cannot transfer funds from an account to itself.
4. **Transfer amount is always positive.** The direction of fund movement is determined by the source/destination pair, not by the sign of the amount.
5. **Account type restricts balance sign.** A "positive" account cannot go negative; a "negative" account cannot go positive.
6. **A locked account cannot be a transfer source.** If an account is locked, debiting from it is impossible.
7. **Every operation is idempotent.** A duplicate transfer or hold with the same idempotency key is rejected.
8. **Every transfer must match a policy.** If no policy permits the given transfer direction, the operation is rejected.
9. **Reversals must match the original exactly.** A reverse transaction must have the same amount, currency, and account pair (in the opposite direction) as the original.
10. **You cannot hold more than the account balance.** Likewise, you cannot release more than what is held.
11. **Account balance changes only through operations.** Direct balance modification is impossible — it is recalculated only as a result of transfers or holds.
12. **An account cannot be deleted while referenced by operations.** As long as related transfers or holds exist, account deletion is forbidden.

Practical integrity guarantees:

- Openbill is multi-currency: balances and invariants are tracked per `amount_currency`.
- To get an account balance, read `openbill_accounts.amount_value`; no transfer replay is needed.
- The sum of balances across all accounts (per currency) is always `0`.
- This makes money creation from nowhere impossible and prevents unnoticed balance injections.

## Quick Start (Project Users)

Initialize the test database:

```shell
./tests/create.sh
```

Minimal scenario:

```sql
-- 1) Create two accounts
INSERT INTO openbill_accounts (id, category_id, details) VALUES (1, -1, 'Bob');
INSERT INTO openbill_accounts (id, category_id, details) VALUES (2, -1, 'Nikolas');

-- 2) Check balances before transfer
SELECT details, amount_value, amount_currency FROM openbill_accounts;
-- details | amount_value | amount_currency
-- --------+--------------+----------------
-- Bob     |         0.00 | USD
-- Nikolas |         0.00 | USD

-- 3) Register a transfer
INSERT INTO openbill_transfers VALUES (2, 1, 500, 'USD', 'payment:demo:1', 'Demo payment')

-- 4) Check balances after transfer
SELECT details, amount_value, amount_currency FROM openbill_accounts;
-- details | amount_value | amount_currency
-- --------+--------------+----------------
-- Bob     |       500.00 | USD
-- Nikolas |      -500.00 | USD
```

Why balances changed automatically: `INSERT` into `openbill_transfers` triggers database function `process_account_transfer`, which debits `from_account_id` and credits `to_account_id`.
Each transfer is double-entry: one debit and one credit for the same amount.

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
