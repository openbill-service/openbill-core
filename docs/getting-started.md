# Быстрый старт

Этот раздел для пользователей Openbill Core (интеграция ledger в своё приложение).

## Что нужно

- PostgreSQL 13+
- Доступ к `psql`

## 1. Инициализировать базу

```shell
./tests/create.sh
```

Скрипт:

1. Создаёт роль `openbill-test` (если отсутствует)
2. Пересоздаёт БД
3. Применяет `V*` миграции (схема)
4. Применяет `R__*` миграции (функции, триггеры, права)

Проверка:

```shell
psql openbill_test -c "\dt openbill*"
```

## 2. Проверить стартовое состояние

По умолчанию есть:

- категория `System` (`id = -1`)
- политика `Allow any transactions`

```sql
SELECT * FROM openbill_categories;
SELECT * FROM openbill_policies;
```

## 3. Создать счета

```sql
INSERT INTO openbill_accounts (category_id, details) VALUES (-1, 'User wallet');
INSERT INTO openbill_accounts (category_id, details) VALUES (-1, 'System income');
```

## 4. Провести перевод

```sql
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (2, 1, 500, 'USD', 'payment:demo:1', 'Demo payment');
```

`idempotency_key` должен быть уникальным для каждой бизнес-операции.

## 5. Проверить инвариант

```sql
SELECT currency, SUM(balance)
FROM openbill_accounts
GROUP BY currency;
```

Сумма по каждой валюте должна быть `0`.

## Возвраты (reverse transfer)

Для возврата указывайте `reverse_transaction_id` на исходный перевод.

```sql
INSERT INTO openbill_transfers
  (reverse_transaction_id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (1, 1, 2, 500, 'USD', 'refund:demo:1', 'Refund for demo payment');
```

## Holds (блокировка средств)

Блокировка:

```sql
INSERT INTO openbill_holds
  (account_id, amount, currency, idempotency_key, details)
VALUES
  (1, 200, 'USD', 'hold:order:1', 'Reserve');
```

Разблокировка:

```sql
INSERT INTO openbill_holds
  (account_id, amount, currency, idempotency_key, hold_key, details)
VALUES
  (1, -200, 'USD', 'unhold:order:1', 'hold:order:1', 'Unreserve');
```

## Ограничение маршрутов переводов

Для production-сценария обычно сначала удаляют дефолтное разрешение:

```sql
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';
```

Дальше настраивают `categories` и `policies` под доменную модель.

См. каталог примеров:

- [Use cases](use-cases.md)
- [Отраслевые examples](examples/README.md)

## Что читать дальше

- [Use Cases: categories + policies](use-cases.md)
- [Benchmark design](benchmark_transfers_design.md)
- [Pgbench report](pgbench_benchmark_report_2026-03-04.md)
- Для разработчиков ядра: `DEVELOPMENT.md` в корне репозитория
