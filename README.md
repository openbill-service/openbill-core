# Openbill Core (SQL scheme, functions and triggers)

[![Build Status](https://github.com/openbill-service/openbill-core/actions/workflows/github-actions-func.yml/badge.svg)](https://github.com/openbill-service/openbill-core/actions)

Ядро простого и надежного биллинга на хранимых процедурах для PostgreSQL.

Создан по принципу: "Меньше функций - больше надежности".

С 2015-го года используется в нескольких приложениях на PHP, Ruby, GoLang. За это время багов не найдено.

Чем обусловлена надежность данного решения:

1. Отсутствие прокладок в виде API: операции на перемещение денежных средств, создание счетов и выборка данных осуществляются через типовые SQL-запросы `insert, update, select` напрямую в базе.
2. Нет лишних сервисов, которые могут упасть или иметь потенциальные баги.
3. Защита состояния системы на уровне PostgreSQL-сервера. Программист, не знающий устройства данного биллинга, или хакер,
   получивший доступ к выполнению SQL-запросов, не сможет привести систему в испорченное состояние.
   Баланс всегда сходится и все операции отражены в истории.
4. Контроль доступа на уровне PostgreSQL.

# Цель проекта

Получить надёжную, простую, платформо- и языко-независимую систему учёта операций перемещения денежных средств между счетами.
Проверить насколько хорошо для этого подходит решение на уровне SQL.

# Принципы

1. В базу можно только добавлять новые операции и счета. Удалять или изменить
   финансовые операции не разрешается. Можно изменить описание счёта или название
   категории счетов.
2. Любая операция перемещения автоматически отражается на балансе задействованных счетов.
3. Баланс системы (сумма всех остатков по счетам) всегда равен нулю.
4. Типовой пользователь PostgreSQL не имеет доступа к изменению баланса счетами, кроме как произвести операцию перевода с одного счета на другой.

# Зависимости

* PostgreSQL версии не ниже 13
* Руки, глаза, мозг. При наличии работающего Neuralink - руки и глаза не обязательны.

# Сущности и операции

## Финансовые

* Таблица `OPENBILL_ACCOUNTS` - счёт. Имеет уникальный bigint-идентификатор. Несёт информацию о состоянии счёта (балансе), валюте (поля `amount_value` и `amount_currency`).
* Таблица `OPENBILL_TRANSFERS` - операция перемещения средств между счетами. Имеет уникальный идентификатор, идентификаторы входящего и исходящего счёта, сумму, описание. Дополнительные поля: `meta` (JSONB) для произвольных данных, `billing_date` для внешней даты операции.
* Таблица `OPENBILL_HOLDS` - операция блокировки средств на счёте. Имеет уникальный идентификатор, идентификатор счета, сумму блокировки, описание. Для разблокировки средств нужно добавить новую запись с отрицательной суммой, а в поле `hold_key` внести идентификатор операции блокировки.

## Дополнительные

* Таблица `OPENBILL_CATEGORIES` - категория счёта. Удобный способ группировать счета, например: пользовательские счета и системные счета, а также ограничивать операции.
* Таблица `OPENBILL_POLICIES` - политики переводов средств. С помощью этой таблицы можно ограничить перемещение средств между счетами. Например, разрешить с
пользовательских счетов списания только на системные.

## Перемещение средств

Основная операция, регистрация перемещения средств (транзакция в финансовом смысле),
делается через обычный SQL-запрос `INSERT INTO OPENBILL_TRANSFERS` и автоматически
изменяет остаток на затрагиваемых счетах.

# Устройство

Весь код проекта это SQL-файлы, которые находятся в каталоге `./migrations/`.
Файлы именуются по конвенции Flyway (хотя сам Flyway не используется):

* `V{номер}__{описание}.sql` - версионные миграции (схема, таблицы). Применяются один раз в порядке номера.
* `R__{описание}.sql` - повторяемые миграции (триггеры, функции, права). Идемпотентны, перезапускаются при каждом создании БД.

Файл `V000__initial_database.sql` содержит схему базы, остальные `V*` добавляют
таблицы и поля, а `R__*` добавляют функции, триггеры и права доступа.

# Установка и использование

## Требования

* PostgreSQL версии 13+
* Текущий пользователь системы должен иметь возможность подключаться к PostgreSQL как суперпользователь (`postgres`). Скрипт `tests/create.sh` создаёт роль `openbill-test`, базу и применяет миграции.

## Настройка доступа к PostgreSQL

Скрипт `tests/create.sh` выполняет команды от имени `PGUSER=postgres`. Для этого необходимо, чтобы peer- или password-аутентификация для пользователя `postgres` работала с вашей системной учёткой.

Типичные варианты:

**Вариант 1: ваш пользователь — суперпользователь PostgreSQL**

Если ваш системный пользователь является суперпользователем PostgreSQL, укажите его через `PG_SUPERUSER`:

```shell
PG_SUPERUSER=danil ./run_all_tests.sh
```

**Вариант 2: password auth (Docker, CI)**

Если PostgreSQL доступен по TCP с паролем (по умолчанию используются `PGHOST=127.0.0.1`, `PGPASSWORD=postgres`):

```shell
./run_all_tests.sh
```

**Вариант 3: peer auth через sudo (Linux, стандартный PostgreSQL из пакетов)**

```shell
sudo -u postgres ./tests/create.sh
sudo -u postgres ./tests/all.sh
```

## Создание базы

Все скрипты используют базу, указанную в переменной окружения `PGDATABASE`. По умолчанию — `openbill_test`.

```shell
# Тестовая база (по умолчанию)
./tests/create.sh

# Произвольная база
PGDATABASE=openbill ./tests/create.sh
```

Скрипт `create.sh`:
1. Создаёт роль `openbill-test` (если не существует)
2. Пересоздаёт базу
3. Применяет версионные миграции (`V???_*.sql`) — схема и таблицы
4. Применяет повторяемые миграции (`R__*.sql`) — триггеры, функции, права

Если скрипт завершился с успехом, значит вы имеете установленные таблицы,
функции и триггеры openbill в указанной базе. Проверим:

```shell
> psql openbill
openbill=# \dt openbill*
               List of relations
 Schema |         Name          | Type  | Owner
--------+-----------------------+-------+-------
 public | openbill_accounts     | table | danil
 public | openbill_categories   | table | danil
 public | openbill_holds        | table | danil
 public | openbill_policies     | table | danil
 public | openbill_transfers    | table | danil
(5 rows)
```

## Первоначальное состояние

При инициализации вы получаете базу без счетов и транзакций, но с одной
категорией и политикой, разрешающей операции между любыми счетами:

```shell
openbill=# select * from openbill_categories;
 id |  name
----+--------
 -1 | System
(1 row)

openbill=# select * from openbill_policies;
 id |          name          | from_category_id | to_category_id | from_account_id | to_account_id | allow_reverse
----+------------------------+------------------+----------------+-----------------+---------------+---------------
  1 | Allow any transactions |                  |                |                 |               | t
(1 row)
```

## Создание счетов

Можете приступать к созданию пользовательских счетов:

```shell
openbill=# insert into openbill_accounts (category_id, details) values (-1, 'Счёт Василия');
openbill=# insert into openbill_accounts (category_id, details) values (-1, 'Счёт Петра');
```

А теперь создадим системный счёт, через который будут приходить поступления на пользовательские счета. Например, это будет счёт приёма оплаты
через CloudPayments:

```shell
openbill=# insert into openbill_accounts (category_id, details) values (-1, 'CloudPayments income');
```

В итоге имеем счета:

```shell
openbill=# select id, details, amount_value, amount_currency from openbill_accounts;
 id |       details        | amount_value | amount_currency
----+----------------------+--------------+-----------------
  1 | Счёт Василия         |            0 | USD
  2 | Счёт Петра           |            0 | USD
  3 | CloudPayments income |            0 | USD
```

Проверяем общий баланс:

```shell
openbill=# select amount_currency, sum(amount_value) from openbill_accounts group by amount_currency;
 amount_currency | sum
-----------------+-----
 USD             |   0
(1 row)
```

## Регистрация операций

Предположим, что Василий внёс оплату 500$ в вашу систему через CloudPayments,
регистрируем операцию:

```shell
openbill=# insert into openbill_transfers (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
           values (3, 1, 500, 'USD', 'cloudpayments:12345', 'Поступление через CloudPayments 500$, транзакция N12345');
```

Обратите внимание, что поле `idempotency_key` содержит идентификатор транзакции от поставщика и служит защитным механизмом для избежания дублирования операций.
Поэтому для каждой транзакции необходимо создавать уникальный ключ.

Смотрим состояние счетов:

```shell
openbill=# select id, details, amount_value, amount_currency from openbill_accounts;
 id |       details        | amount_value | amount_currency
----+----------------------+--------------+-----------------
  1 | Счёт Василия         |          500 | USD
  2 | Счёт Петра           |            0 | USD
  3 | CloudPayments income |         -500 | USD
```

Общий баланс:

```shell
openbill=# select amount_currency, sum(amount_value) from openbill_accounts group by amount_currency;
 amount_currency | sum
-----------------+-----
 USD             |   0
(1 row)
```

## Обратные операции (возвраты)

Для возврата средств создаётся transfer с полем `reverse_transaction_id`, указывающим на исходную операцию. Обратная операция должна иметь ту же сумму, валюту и зеркальные счета:

```shell
-- Исходная операция (id = 1): счёт 3 → счёт 1, 500 USD
-- Возврат:
openbill=# insert into openbill_transfers
  (reverse_transaction_id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
  values (1, 1, 3, 500, 'USD', 'refund:12345', 'Возврат оплаты');
```

Триггер `process_reverse_transaction` проверяет, что исходная операция существует и параметры совпадают. Политики (`OPENBILL_POLICIES`) должны разрешать обратные операции (`allow_reverse = true`).

## Блокировка средств (HOLDS)

Блокировка замораживает часть баланса счёта. Заблокированные средства нельзя потратить через transfer, но они остаются на счёте.

```shell
-- На счёте 1 есть 500 USD. Блокируем 200:
openbill=# insert into openbill_holds
  (account_id, amount_value, amount_currency, idempotency_key, details)
  values (1, 200, 'USD', 'hold:order:789', 'Бронирование средств');
```

После блокировки: `amount_value = 300` (доступно), `hold_value = 200` (заморожено).

Для разблокировки — вставляется запись с отрицательной суммой и ссылкой на исходный hold через `hold_key`:

```shell
-- Разблокируем 200:
openbill=# insert into openbill_holds
  (account_id, amount_value, amount_currency, idempotency_key, hold_key, details)
  values (1, -200, 'USD', 'unhold:order:789', 'hold:order:789', 'Снятие брони');
```

### Capture (списание из холда)

Типичный платёжный сценарий: заблокировать средства, затем списать. Это делается в одной SQL-транзакции — разблокировка + transfer:

```sql
BEGIN;
  -- Разблокировать
  INSERT INTO openbill_holds
    (account_id, amount_value, amount_currency, idempotency_key, hold_key, details)
    VALUES (1, -200, 'USD', 'capture:order:789', 'hold:order:789', 'Capture');
  -- Списать
  INSERT INTO openbill_transfers
    (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
    VALUES (1, 2, 200, 'USD', 'payment:order:789', 'Оплата заказа #789');
COMMIT;
```

### TTL холдов

Openbill не управляет сроком жизни холдов — это ответственность приложения. Приложение должно отслеживать устаревшие холды (например, по полю `created_at`) и разблокировать их.

### Ограничения

* Нельзя заблокировать больше, чем доступно на счёте
* Нельзя разблокировать больше, чем заблокировано
* Разблокировка (`amount_value < 0`) обязана иметь `hold_key`
* Блокировка (`amount_value > 0`) не может иметь `hold_key`

## Уведомления (pg_notify)

При каждом INSERT в `OPENBILL_TRANSFERS` PostgreSQL отправляет уведомление в канал `openbill_transfers` с id операции в payload. Внешние приложения могут подписаться:

```shell
openbill=# LISTEN openbill_transfers;
-- при новом transfer:
-- Asynchronous notification "openbill_transfers" with payload "42" received from server
```

## Политика ограничений перемещений

Используя таблицу `OPENBILL_POLICIES` можно указать между какими именно счетами и
категориями счетов разрешается проводить операции. Если значение счета или
категории NULL - значит это правило действует для любой категории или счета.

Если проводимая транзакция не нашла соответствующего разрешения в
`OPENBILL_POLICIES`, то она отклоняется.

Больше примеров тут – `./tests/*`

## Контроль доступа

Типовой пользователь PostgreSQL (роль `public`) имеет ограниченный доступ к таблицам.

### Права (GRANT)

| Таблица | SELECT | INSERT | UPDATE | DELETE |
|-|-|-|-|-|
| `OPENBILL_CATEGORIES` | + | + | + (все колонки) | - |
| `OPENBILL_ACCOUNTS` | + | + | только `locked_at`, `details` | + (*) |
| `OPENBILL_TRANSFERS` | + | + | - | - |
| `OPENBILL_POLICIES` | + | + | + | + |
| `OPENBILL_HOLDS` | + | + | - | - |

(*) DELETE разрешён только для счетов без transfers (см. триггеры ниже).

### Защита триггерами

| Ограничение | Триггер |
|-|-|
| Нельзя удалить счёт, участвовавший в transfers | `disable_delete_account` |
| Баланс счёта меняется только через INSERT в TRANSFERS | `process_account_transaction` |
| Нельзя создать счёт с ненулевым балансом | `create_account` |
| Валюта transfer должна совпадать с валютой обоих счетов | `constraint_accounts_currency` |
| Нельзя списать с заблокированного счёта (`locked_at`) | `process_account_transaction` |
| Transfer должен соответствовать политике | `restrict_transaction` |

### Поле kind

Поле служит для определения типа счета.

* Баланс может быть 0 или меньше нуля (negative)
* Баланс может быть 0 или больше нуля (positive)
* Баланс может быть любой (any) - по умолчанию

# Тестирование

## Запуск всех тестов

```shell
./run_all_tests.sh
```

Этот скрипт пересоздаёт базу `openbill_test` и прогоняет все `tests/test_*.sh`. После каждого теста проверяется сходимость баланса (`assert_balance.sh`).

Если `PGUSER=postgres` peer auth не работает для вашего пользователя, используйте один из способов, описанных в разделе «Настройка доступа к PostgreSQL» выше.

## Запуск одного теста

```shell
./tests/test_successful_transaction.sh
```

Каждый тест самодостаточен: инициализирует БД, создаёт тестовые данные и проверяет результат.

## Параллельные тесты (нагрузочные)

Запускаются после `./run_all_tests.sh` (требуют Ruby):

```shell
PGUSER=postgres PGDATABASE=openbill_test ruby ./parallel_tests.rb \
  -s ./tests/benchmark_test_scenario0.sh \
  -a 1 \
  -u 2
```

# Прочее

Смежные проекты (админка, модули для ruby и т.п.) - https://github.com/openbill-service

## Другие решения

* http://balancedbilly.readthedocs.org/en/latest/getting_started.html#create-a-customer
* http://demo.opensourcebilling.org/invoices
