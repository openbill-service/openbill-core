# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Что это

Openbill Core — биллинговая система на чистом PostgreSQL (PL/pgSQL). Вся бизнес-логика реализована в триггерах и хранимых функциях, без прикладного кода. Используется из приложений на PHP, Ruby, GoLang через обычные SQL-запросы.

## Команды

### Тесты (требуют локальный PostgreSQL)

```bash
# Все тесты (пересоздаёт БД openbill_test, запускает все test*.sh)
./run_all_tests.sh

# Только пересоздать БД
./tests/create.sh

# Один тест
./tests/test_successful_transaction.sh

# Watch-режим (требует bundle install)
guard
```

Тесты используют `PGDATABASE=openbill_test`, `PGUSER=openbill-test`. Настройки в `tests/config.sh`.

### Линтинг

Отсутствует.

## Архитектура

### Принцип двойной записи

Баланс системы (сумма `amount_value` всех счетов) всегда равен нулю. Каждая транзакция списывает с `from_account_id` и зачисляет на `to_account_id`. Это инвариант, проверяемый после каждого теста (`tests/assert_balance.sh`).

### Миграции (`migrations/`)

Применяются через `cat | psql` в `tests/create.sh`:
1. Сначала `V???_*.sql` — версионные (схема, таблицы). Порядок по номеру.
2. Затем `R__*.sql` — повторяемые (триггеры, функции, права). Идемпотентны (`CREATE OR REPLACE`, `DROP TRIGGER IF EXISTS`).

Именование по Flyway-конвенции, но Flyway не используется.

### Ключевые таблицы

| Таблица | Назначение |
|-|-|
| `OPENBILL_CATEGORIES` | Группировка счетов (bigserial PK) |
| `OPENBILL_ACCOUNTS` | Счета с балансом (`amount_value`/`amount_currency`), поле `kind`: negative/positive/any |
| `OPENBILL_TRANSACTIONS` | Операции перемещения средств. `INSERT` — единственный способ создать транзакцию |
| `OPENBILL_POLICIES` | Ограничения на допустимые направления переводов между категориями/счетами |
| `OPENBILL_HOLDS` | Блокировка средств на счёте |

### Ключевые триггеры (в `R__*.sql`)

- `process_account_transaction` (R__005) — главный триггер: при INSERT в TRANSACTIONS обновляет балансы обоих счетов. Порядок UPDATE определяется по id (предотвращение deadlock).
- `process_reverse_transaction` (R__008) — обратная транзакция.
- `trg_constraint_account_currency` (R__003) — запрет изменения валюты/баланса напрямую.
- `trg_transaction_delete` (R__002) / `trg_transaction_update` (R__004) — запрет удаления/изменения транзакций.
- `trg_create_account` (R__010) — валидация при создании счёта (баланс = 0).
- `pem_databasepermissions` (R__pem) — права для роли `openbill-test`.

### Защитные механизмы

- Транзакции нельзя удалить или изменить (триггеры).
- Баланс счёта нельзя изменить напрямую — только через INSERT в TRANSACTIONS.
- `remote_idempotency_key` — уникальный ключ для идемпотентности.
- `locked_at` на счёте блокирует списание с него.
- Политики (`OPENBILL_POLICIES`) ограничивают допустимые направления переводов.
- Функции объявлены как `SECURITY DEFINER`.

### Тесты (`tests/`)

Bash-скрипты. Каждый `test*.sh` — самодостаточный сценарий, который:
1. Инициализирует БД (`. ./tests/init.sh`)
2. Создаёт тестовые счета (`. ./tests/2accounts.sh`)
3. Выполняет SQL и проверяет результат через `assert_result.sh` / `assert_value.sh` / `assert_result_include.sh`

После каждого теста `all.sh` проверяет сходимость баланса через `assert_balance.sh`.

## Соглашения при написании миграций

- Версионные: `V{номер}__{описание}.sql` — для изменений схемы (CREATE TABLE, ALTER, etc.)
- Повторяемые: `R__{описание}.sql` — для триггеров и функций (идемпотентны, перезапускаются при каждом создании БД)
- Все идентификаторы таблиц — UPPER_CASE (`OPENBILL_ACCOUNTS`)
- PK — `bigserial`, не UUID
