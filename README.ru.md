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
- Battle-tested в продакшене 10+ лет: через это бухгалтерское ядро прошло уже десятки миллиардов долларов
- Финансовая архитектура: категории задают план счетов (включая иерархию на уровне доменной модели), а policies обеспечивают жёсткие маршруты переводов между категориями и счетами

## Базовые Принципы

1. **Ledger в PostgreSQL**: переводы создаются и валидируются в SQL.
2. **Инварианты в БД**: правила корректности живут рядом с данными.
3. **Минимум инфраструктуры**: меньше движущихся частей и точек отказа.

## Зависимости

Нужна только одна зависимость:

- PostgreSQL 13+

Для ядра больше ничего не требуется: ни отдельный API-сервис, ни SDK, ни дополнительный рантайм.

### Почему не тип `money`?

В PostgreSQL есть встроенный тип `money`, но Openbill использует `numeric(36,18)`: тип `money` привязан к локали (`lc_monetary`), не хранит код валюты и теряет точность при делении. `numeric` не зависит от локали, поддерживает произвольную точность и является стандартом для ledger-систем.

## Преимущества

- Языко-независимая интеграция для любого стека с SQL-доступом.
- Детерминированное поведение: проверки идут в той же консистентной границе, что и запись.
- Прозрачная трассировка операций через таблицы ledger.
- Приложения подключаются напрямую к PostgreSQL, в котором реализовано ядро, без отдельного API-слоя, что снижает издержки на интеграцию и поддержку.

## Инварианты

Все правила защищены на уровне PostgreSQL (constraints, триггеры, GRANT). Ни одно приложение-клиент не может их обойти.

1. **Баланс системы всегда равен нулю.** Сумма всех средств на всех счетах, включая заблокированные, всегда равна нулю. Деньги не возникают из ниоткуда и не исчезают.
2. **Перевод возможен только в одной валюте.** Валюта перевода должна совпадать с валютой счёта-отправителя и счёта-получателя.
3. **Перевод возможен только между разными счетами.** Нельзя перевести средства со счёта на тот же самый счёт.
4. **Сумма перевода всегда положительна.** Направление движения средств определяется парой «откуда — куда», а не знаком суммы.
5. **Тип счёта ограничивает знак баланса.** Счёт с типом «положительный» не может уйти в минус, счёт с типом «отрицательный» — в плюс.
6. **Заблокированный счёт не может быть источником перевода.** Если счёт заблокирован — списание с него невозможно.
7. **Каждая операция идемпотентна.** Повторная отправка перевода или холда с тем же ключом идемпотентности невозможна — дубликаты отклоняются.
8. **Каждый перевод должен соответствовать политике.** Если не существует ни одной политики, разрешающей данное направление перевода — операция отклоняется.
9. **Возврат возможен только на полную сумму и между теми же счетами.** Реверсивная транзакция должна точно соответствовать исходной по сумме, валюте и паре счетов.
10. **Нельзя заблокировать больше, чем есть на счёте.** Аналогично — нельзя разблокировать больше, чем заблокировано.
11. **Баланс счёта изменяется только через операции.** Прямое изменение баланса невозможно — он пересчитывается только в результате переводов или холдов.
12. **Счёт нельзя удалить, если на него ссылаются операции.** Пока существуют связанные переводы или холды — удаление счёта запрещено.

Практические гарантии целостности:

- Openbill мультивалютный: балансы и инварианты считаются отдельно по `amount_currency`.
- Чтобы узнать баланс счета, не нужно пересобирать транзакции: актуальный баланс всегда в `openbill_accounts.amount_value`.
- Сумма балансов всех счетов (в разрезе валюты) всегда равна `0`.
- Это исключает возможность «взять деньги из ниоткуда» и сделать незаметное зачисление на баланс.

## Быстрый Старт (Для Пользователей)

Инициализация тестовой БД:

```shell
./tests/create.sh
```

Минимальный сценарий:

```sql
-- 1) Создаём два счёта
INSERT INTO openbill_accounts (id, category_id, details) VALUES (1, -1, 'Bob');
INSERT INTO openbill_accounts (id, category_id, details) VALUES (2, -1, 'Nikolas');

-- 2) Проверяем балансы до перевода
SELECT details, amount_value, amount_currency FROM openbill_accounts;
-- details | amount_value | amount_currency
-- --------+--------------+----------------
-- Bob     |         0.00 | USD
-- Nikolas |         0.00 | USD

-- 3) Регистрируем перевод
INSERT INTO openbill_transfers VALUES (2, 1, 500, 'USD', 'payment:demo:1', 'Demo payment')
-- Автообработка: process_account_transfer списывает 500 USD с Nikolas и зачисляет 500 USD на Bob (двойная запись).

-- 4) Проверяем балансы после перевода
SELECT details, amount_value, amount_currency FROM openbill_accounts;
-- details | amount_value | amount_currency
-- --------+--------------+----------------
-- Bob     |       500.00 | USD
-- Nikolas |      -500.00 | USD

-- Проверка целостности: сумма всех балансов должна оставаться 0.00, чтобы деньги не могли появиться или исчезнуть.
-- 5) Проверяем целостность (сумма всех балансов равна нулю)
SELECT SUM(amount_value) FROM openbill_accounts;
-- sum
-- ------
--  0.00
```

## Отраслевые Примеры

### Платежи И Кошельки

- [P2P Wallet](docs/examples/p2p-wallet/README.md)
- [Payment System (PSP)](docs/examples/payment-system-psp/README.md)
- [Remittance](docs/examples/remittance/README.md)
- [Telecom Prepaid](docs/examples/telecom-prepaid/README.md)
- [Gift Cards](docs/examples/gift-cards/README.md)
- [Card Issuer](docs/examples/card-issuer/README.md)

### Кредитование, Банки И Риск

- [Bank](docs/examples/bank/README.md)
- [Credit / BNPL](docs/examples/credit-bnpl/README.md)
- [Insurance](docs/examples/insurance/README.md)
- [Payroll](docs/examples/payroll/README.md)

### Коммерция И Монетизация Платформ

- [Marketplace](docs/examples/marketplace/README.md)
- [SaaS Subscriptions](docs/examples/saas-subscriptions/README.md)
- [Donations](docs/examples/donations/README.md)
- [Affiliate Payouts](docs/examples/affiliate-payouts/README.md)
- [Gaming](docs/examples/gaming/README.md)
- [Travel Booking](docs/examples/travel-booking/README.md)
- [Referral Program](docs/examples/referral-program/README.md)
- [Ad Network](docs/examples/ad-network/README.md)
- [Loyalty Bonuses](docs/examples/loyalty-bonuses/README.md)

### Крипто И Обмен

- [Exchange](docs/examples/exchange/README.md)
- [Crypto Custody](docs/examples/crypto-custody/README.md)

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

### Contributions

- Руководство разработчика: [DEVELOPMENT.md](DEVELOPMENT.md)

## Смежные Проекты

- https://github.com/openbill-service
- https://github.com/openbill-service/openbill-admin

## Лицензия

[Apache License 2.0](LICENSE)
