# Openbill Core

SQL-ядро биллинга на PostgreSQL с инвариантами на уровне базы данных для счетов, переводов, политик и холдов.

English version: [README.md](README.md)

[![CI Functional](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml)
[![CI Multithread](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/github-action-multithread.yml)
[![SQL Style](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/sql-style.yml)
[![Docs Pages](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions/workflows/docs-pages.yml)

## Что Это

Openbill Core реализует финансовый учёт напрямую в PostgreSQL.

- Операции ledger выполняются обычным SQL (`INSERT`/`SELECT`)
- Проверки корректности обеспечиваются ограничениями, функциями и триггерами
- В ядре нет обязательного отдельного API-слоя
- Финансовая архитектура: категории задают план счетов (включая иерархию на уровне доменной модели), а policies обеспечивают жёсткие маршруты переводов между категориями и счетами

## Базовые Принципы

1. **Ledger в PostgreSQL**: переводы создаются и валидируются в SQL.
2. **Инварианты в БД**: правила корректности живут рядом с данными.
3. **Минимум инфраструктуры**: меньше движущихся частей и точек отказа.

## Преимущества

- Языко-независимая интеграция для любого стека с SQL-доступом.
- Детерминированное поведение: проверки идут в той же консистентной границе, что и запись.
- Прозрачная трассировка операций через таблицы ledger.

## Зависимости

Нужна только одна зависимость:

- PostgreSQL 13+

Для ядра больше ничего не требуется: ни отдельный API-сервис, ни SDK, ни дополнительный рантайм.

## Быстрый Старт (Для Пользователей)

Инициализация тестовой БД:

```shell
./tests/create.sh
```

Минимальный сценарий:

```sql
-- 1) Создаём два счёта
INSERT INTO openbill_accounts (category_id, details)
VALUES (-1, 'User wallet (readme)');

INSERT INTO openbill_accounts (category_id, details)
VALUES (-1, 'System income (readme)');

-- 2) Проверяем балансы до перевода
SELECT id, amount_value, amount_currency
FROM openbill_accounts
ORDER BY id;

-- 3) Регистрируем перевод
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

-- 4) Проверяем балансы после перевода
SELECT id, amount_value, amount_currency
FROM openbill_accounts
ORDER BY id;

-- 5) Проверяем инвариант
SELECT amount_currency, SUM(amount_value)
FROM openbill_accounts
GROUP BY amount_currency;
```

Ожидаемый результат: сумма по каждой валюте равна `0`.

Пример вывода запроса балансов на свежей БД:

```text
-- до перевода
 id |     amount_value      | amount_currency
----+-----------------------+----------------
  1 | 0.000000000000000000  | USD
  2 | 0.000000000000000000  | USD

-- после перевода
 id |      amount_value      | amount_currency
----+------------------------+----------------
  1 | 500.000000000000000000 | USD
  2 | -500.000000000000000000 | USD
```

Почему баланс меняется автоматически: `INSERT` в `openbill_transfers` запускает функцию БД `process_account_transfer`, которая списывает сумму с `from_account_id` и зачисляет на `to_account_id`.
Каждый transfer работает по принципу двойной записи: одно списание и одно зачисление на одну и ту же сумму.

Гарантии целостности данных:

- Openbill мультивалютный: балансы и инварианты считаются отдельно по `amount_currency`.
- Чтобы узнать баланс счета, не нужно пересобирать транзакции: актуальный баланс всегда в `openbill_accounts.amount_value`.
- Сумма балансов всех счетов (в разрезе валюты) всегда равна `0`.
- Это исключает возможность «взять деньги из ниоткуда» и сделать незаметное зачисление на баланс.

Почему `category_id = -1`: в миграциях создаётся дефолтная категория `System` с `id = -1` для быстрого старта. В production обычно создают свои доменные категории и policy.

## Отраслевые Примеры

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

## Документация

- Индекс документации: [docs/index.md](docs/index.md)
- Быстрый старт: [docs/getting-started.md](docs/getting-started.md)
- Обзор сущностей: [docs/entities/index.md](docs/entities/index.md)

## Краткий Отчёт По Бенчмаркам (2026-03-04)

Параметры теста: PostgreSQL 17.4, `pgbench -M prepared`, `16 clients`, `4 threads`, warmup `5s`, измерение `15s`.
Сервер замеров: Linux 6.8, Intel Core i7-2600K (8 vCPU), 31 GiB RAM.

| Сценарий | Что это значит | TPS |
|---|---|---:|
| Массовые транзакции (`account_pool`) | Случайные переводы между пулом из 200 счетов (ближе всего к потоку массовых операций) | 2074.320544 |
| Удержание/разблокировка баланса (`hold_cycle`) | Сложный цикл: `transfer -> hold -> transfer -> unhold -> transfer` | 68.129177 |
| Узкое место по блокировкам (`hot_pair`) | Переводы только между двумя \"горячими\" счетами при высокой конкуренции | 339.196934 |

Проверка инварианта после прогона:
`sum(amount_value) + sum(hold_value) = 0.000000000000000000`

## Ключевые Сущности

- [`openbill_accounts`](docs/entities/accounts.md) - счета и балансы
- [`openbill_transfers`](docs/entities/transfers.md) - перемещение средств между счетами
- [`openbill_holds`](docs/glossary.md#hold) - временная блокировка средств
- [`openbill_categories`](docs/entities/categories.md) - категории счетов
- [`openbill_policies`](docs/entities/policy.md) - разрешённые маршруты переводов

## Разделение По Аудиториям

### Для Пользователей Openbill

- Старт: [docs/getting-started.md](docs/getting-started.md)
- Справочник по сущностям: [docs/entities/index.md](docs/entities/index.md)
- Каталог сценариев: [docs/examples/README.md](docs/examples/README.md)
- Запуск всех примеров: `./test-examples.sh`

### Contributins

- Руководство разработчика: [DEVELOPMENT.md](DEVELOPMENT.md)

## Смежные Проекты

- https://github.com/openbill-service
- https://github.com/openbill-service/openbill-admin

## Лицензия

[Apache License 2.0](LICENSE)
