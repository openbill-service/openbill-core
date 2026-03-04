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
| `OPENBILL_TRANSFERS` | Операции перемещения средств. `INSERT` — единственный способ создать транзакцию |
| `OPENBILL_POLICIES` | Ограничения на допустимые направления переводов между категориями/счетами |
| `OPENBILL_HOLDS` | Блокировка средств на счёте |

### Ключевые триггеры (в `R__*.sql`)

- `process_account_transfer` (R__003) — главный триггер: при INSERT в TRANSFERS проверяет валюту и блокировку, обновляет балансы обоих счетов. Порядок UPDATE определяется по id (предотвращение deadlock).
- `process_reverse_transfer` (R__006) — обратная транзакция.
- `openbill_transfer_delete` (R__001) / `openbill_transfer_update` (R__002) — пересчёт балансов при удалении/изменении транзакций.
- `openbill_holds_insert` (R__004) — блокировка/разблокировка средств.
- `restrict_transfer` (R__007) — проверка политик переводов.
- `notify_transfer` (R__005) — pg_notify при INSERT в TRANSFERS.
- `pem_databasepermissions` (R__pem) — права для роли `public`.

### Защитные механизмы

- Транзакции нельзя удалить или изменить (триггеры).
- Счёт нельзя удалить, если на него ссылаются transfers или holds (FK RESTRICT).
- Баланс счёта нельзя изменить напрямую — только через INSERT в TRANSFERS (колоночные GRANT на INSERT и UPDATE).
- `idempotency_key` — уникальный ключ для идемпотентности.
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
