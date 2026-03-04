# DEVELOPMENT

Руководство для разработчиков `openbill-core`.

## Цели проекта

- Хранить финансовый учёт (ledger) в PostgreSQL.
- Гарантировать корректность операций на уровне SQL-функций/триггеров.
- Поддерживать простой и проверяемый код миграций.

## Структура репозитория

- `migrations/`
  - `V*__*.sql` — версионные миграции (схема, таблицы)
  - `R__*.sql` — повторяемые миграции (триггеры, функции, права)
- `tests/` — функциональные тесты и утилиты
- `tests/bench/scenarios/` — pgbench-сценарии
- `docs/` — пользовательская и инженерная документация

## Локальные требования

- PostgreSQL 13+
- `psql`
- (опционально) Ruby для `parallel_tests.rb`
- (опционально) Python для `sqlfluff`/pre-commit

## Подготовка БД

По умолчанию скрипты используют:

- `PGDATABASE=openbill_test`
- суперпользователя PostgreSQL (`postgres` или `PG_SUPERUSER`)

Создать/пересоздать БД с миграциями:

```shell
./tests/create.sh
```

Если нужен другой суперпользователь:

```shell
PG_SUPERUSER=danil ./tests/create.sh
```

## Тесты

Запуск всех функциональных тестов:

```shell
./run_all_tests.sh
```

Запуск одного теста:

```shell
./tests/test_successful_transaction.sh
```

Параллельный нагрузочный прогон (legacy сценарий):

```shell
PGUSER=postgres PGDATABASE=openbill_test ruby ./parallel_tests.rb \
  -s ./tests/benchmark_test_scenario0.sh \
  -a 1 \
  -u 2
```

## SQL стиль

В проекте используется `sqlfluff`.

Локально через `mise`:

```shell
mise run lint
mise run fix
```

Через pre-commit:

```shell
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

CI-линт в workflow: `.github/workflows/sql-style.yml`.

## Бенчмарки

Рекомендуемый путь — `pgbench` + custom сценарии:

- `tests/bench/scenarios/hot_pair.sql`
- `tests/bench/scenarios/account_pool.sql`
- `tests/bench/scenarios/hold_cycle.sql`

Пример:

```shell
PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared -l \
  --log-prefix ./log/pgbench-direct/hot_pair/pgbench_log \
  -f ./tests/bench/scenarios/hot_pair.sql \
  -D hot_from=1 -D hot_to=2 -D max_amount=1000 \
  -c 16 -j 4 -T 15
```

Артефакты складываются в `log/pgbench-direct/`.

## CI Workflows

- `github-actions-func.yml` — функциональные тесты
- `github-action-multithread.yml` — многопоточный прогон
- `sql-style.yml` — SQL style checks
- `docs-pages.yml` — сборка и деплой документации

## Для контрибьюторов

Перед PR желательно:

1. Прогнать `./run_all_tests.sh`.
2. Прогнать SQL-линт.
3. Если менялись docs — проверить `mkdocs build --strict`.
