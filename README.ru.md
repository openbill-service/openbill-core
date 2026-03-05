# Openbill Core (SQL scheme, functions and triggers)

[![CI Functional](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml)
[![CI Multithread](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml)
[![SQL Style](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml)
[![Docs Pages](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml)

Openbill Core — SQL-ядро биллинга на PostgreSQL.

Проект реализует учёт движения денег на уровне базы данных (счета, переводы, политики, холды) и защищает инварианты через функции и триггеры.

## Документация

- Сайт документации: https://openbill-service.github.io/openbill-core/
- Быстрый старт для пользователей: https://openbill-service.github.io/openbill-core/getting-started/
- Каталог сценариев (`categories` + `policies`): https://openbill-service.github.io/openbill-core/use-cases/
- Производительность:
  - https://openbill-service.github.io/openbill-core/benchmark_transfers_design/
  - https://openbill-service.github.io/openbill-core/pgbench_benchmark_report_2026-03-04/

## Отраслевые примеры

Полный каталог:

- [Examples Catalog](docs/examples/README.md)

Примеры по отраслям:

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

## Краткая концепция

Openbill строится вокруг трёх базовых идей:

1. **Ledger в PostgreSQL**: операции проводятся обычными SQL-запросами.
2. **Инварианты в БД**: корректность обеспечивается триггерами и ограничениями, а не только кодом приложения.
3. **Минимум инфраструктуры**: без отдельного API-слоя в ядре.

## Ключевые сущности

- `openbill_accounts` — счета и остатки.
- `openbill_transfers` — операции перемещения между счетами.
- `openbill_holds` — временная блокировка средств.
- `openbill_categories` — категории счетов.
- `openbill_policies` — разрешённые маршруты переводов.

## Преимущества подхода

- Языко-независимая интеграция: любой стек, умеющий SQL.
- Детеминированное поведение: проверки проводятся на уровне БД.
- Простой операционный контур: меньше сервисов и точек отказа.
- Прозрачная трассировка финансовых операций через таблицы ledger.

## Быстрый старт (для пользователей проекта)

Требования:

- PostgreSQL 13+

Инициализация тестовой БД:

```shell
./tests/create.sh
```

Минимальный сценарий:

```sql
-- 1) Создаём два счёта
INSERT INTO openbill_accounts (category_id, details) VALUES (-1, 'User wallet');
INSERT INTO openbill_accounts (category_id, details) VALUES (-1, 'System income');

-- 2) Регистрируем перевод
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (2, 1, 500, 'USD', 'payment:demo:1', 'Demo payment');

-- 3) Проверяем инвариант системы
SELECT amount_currency, SUM(amount_value)
FROM openbill_accounts
GROUP BY amount_currency;
```

Ожидаемо: сумма по каждой валюте должна быть `0`.

## Разделение по аудиториям

### Для пользователей Openbill

- Start here: [docs/getting-started.md](docs/getting-started.md)
- Use cases (by industries): [docs/examples/README.md](docs/examples/README.md)
- Запуск всех examples: `./test-examples.sh`

### Для разработчиков openbill-core

- Руководство разработчика: [DEVELOPMENT.md](DEVELOPMENT.md)

## Смежные проекты

- https://github.com/openbill-service

## License

[Apache License 2.0](LICENSE)
