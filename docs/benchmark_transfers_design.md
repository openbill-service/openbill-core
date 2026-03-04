# Дизайн-док: скрипт бенчмарка производительности transfer-операций

Статус: Draft  
Дата: 2026-03-04  
Проект: openbill-core

## 1. Контекст

Сейчас в репозитории есть нагрузочный запуск через `parallel_tests.rb` + `tests/benchmark_test_scenario0.sh`.  
Этого достаточно для грубой проверки "всё работает под параллельной нагрузкой", но недостаточно для стабильного perf-бенчмарка:

- нет percentiles (`p50/p95/p99`) по latency;
- нет стандартного JSON/CSV-отчёта для сравнения запусков;
- нет формального PASS/FAIL по регрессии производительности;
- нет чёткого разделения этапов `prepare -> warmup -> measure -> verify -> report`.

## 2. Цель

Сделать единый CLI-скрипт для воспроизводимого benchmark-а transfer-пути в PostgreSQL с автоматическим отчётом и проверкой инвариантов Openbill.

## 3. Не-цели

- Не измеряем сетевые задержки внешних API (их в openbill-core нет).
- Не делаем auto-tuning PostgreSQL внутри скрипта.
- Не заменяем функциональные тесты (`tests/test_*.sh`).
- Не делаем "универсальный" фреймворк под любые типы нагрузок.

## 4. Основные метрики

| Метрика | Назначение | Источник |
|---|---|---|
| `tps_success` | Пропускная способность успешных операций | `pgbench` result |
| `latency_ms_p50/p95/p99` | Пользовательская latency | `pgbench --log` + агрегация |
| `error_rate_pct` | Доля неуспешных операций | `pgbench` + SQL-верификация |
| `deadlocks_count` | Фиксация деградации при конкуренции | логи ошибок `pgbench` |
| `balance_delta` | Инвариант суммы балансов | `tests/assert_balance.sh` / SQL |
| `rows_inserted` | Факт объёма нагрузки | `COUNT(*)` по transfer за run |

## 5. Нагрузочные сценарии

### S1: `hot_pair`

Максимальная конкуренция на двух счетах (одна "горячая" пара).  
Нужен для выявления contention/locking проблем.

### S2: `account_pool`

Случайные переводы в пуле из N счетов.  
Нужен для оценки более реалистичного throughput при меньшем lock contention.

### S3: `hold_cycle`

Цикл `transfer -> hold -> transfer -> unhold -> transfer` (по смыслу текущего `benchmark_test_scenario0.sh`).  
Нужен для нагрузки пути с `OPENBILL_HOLDS`.

## 6. Предлагаемая реализация

### 6.1 Инструменты

- Обёртка: Bash (`tests/benchmark_transfers.sh`)
- Генератор нагрузки: `pgbench` (custom SQL scripts)
- Верификация и служебные запросы: `psql`
- Агрегация отчёта: `awk` + `jq` (если доступен; при отсутствии — plain text fallback)

### 6.2 Структура файлов

```text
tests/benchmark_transfers.sh
tests/bench/scenarios/hot_pair.sql
tests/bench/scenarios/account_pool.sql
tests/bench/scenarios/hold_cycle.sql
tests/bench/lib/metrics.sh
tests/bench/lib/verify.sh
tests/bench/baseline/*.json
log/benchmarks/<run_id>/
```

### 6.3 Этапы пайплайна

1. `preflight`
Проверка доступности `psql`, `pgbench`, переменных подключения.

2. `prepare`
Подготовка тестовых данных:
- создать/очистить benchmark-аккаунты;
- зафиксировать policy для разрешённых transfer;
- инициализировать стартовые балансы.

3. `warmup`
Прогрев без учёта в итоговых метриках.

4. `measure`
Основной запуск `pgbench` с нужным сценарием, логированием latency и ошибок.

5. `verify`
Проверка финансовых инвариантов после нагрузки:
- глобальная сумма балансов = 0;
- отсутствие неконсистентных hold/transfer состояний.

6. `report`
Сбор `summary.json`, `samples.csv`, `raw.log`, сравнение с baseline.

## 7. CLI-контракт

```bash
./tests/benchmark_transfers.sh \
  --scenario hot_pair \
  --clients 64 \
  --threads 8 \
  --duration 120 \
  --warmup 20 \
  --accounts 2000 \
  --repeats 3 \
  --compare-baseline ./tests/bench/baseline/hot_pair.json \
  --max-regression-pct 10 \
  --out-dir ./log/benchmarks
```

### Параметры

| Флаг | По умолчанию | Описание |
|---|---|---|
| `--scenario` | `hot_pair` | `hot_pair`, `account_pool`, `hold_cycle` |
| `--clients` | `32` | Число клиентских сессий |
| `--threads` | `4` | Потоки `pgbench` |
| `--duration` | `60` | Длительность измерения (сек) |
| `--warmup` | `10` | Длительность прогрева (сек) |
| `--accounts` | `1000` | Размер пула счетов для `account_pool` |
| `--repeats` | `3` | Кол-во независимых прогонов |
| `--compare-baseline` | empty | JSON с baseline-метриками |
| `--max-regression-pct` | `10` | Порог регрессии (в процентах) |
| `--out-dir` | `./log/benchmarks` | Каталог артефактов |

## 8. Методика измерения

- Использовать prepared mode: `pgbench -M prepared`.
- Для latency-перцентилей использовать `--log` и post-processing логов.
- Выполнять не менее 3 повторов и брать медиану по `tps_success` и `p95`.
- Запускать на "тихой" БД (без параллельных ручных тестов/нагрузки).
- Версия PostgreSQL и параметры запуска фиксируются в отчёте.

## 9. Формат артефактов

Каталог одного запуска:

```text
log/benchmarks/20260304T191500Z_hot_pair/
  summary.json
  samples.csv
  pgbench.stdout.log
  pgbench.stderr.log
  verify.log
  compare.log
```

Пример `summary.json`:

```json
{
  "run_id": "20260304T191500Z_hot_pair",
  "scenario": "hot_pair",
  "clients": 64,
  "threads": 8,
  "duration_sec": 120,
  "tps_success": 18450.21,
  "latency_ms": {
    "p50": 2.1,
    "p95": 5.8,
    "p99": 9.4
  },
  "error_rate_pct": 0.0,
  "deadlocks_count": 0,
  "balance_delta": "0.000000000000000000",
  "status": "PASS"
}
```

## 10. Правила PASS/FAIL

`PASS`, если одновременно:

- `balance_delta == 0`;
- `error_rate_pct <= 0.1` (или ниже заданного порога);
- нет deadlock/fatal ошибок;
- при наличии baseline нет регрессии выше `--max-regression-pct` по `tps_success` и `p95`.

Иначе `FAIL` с ненулевым exit code.

Предлагаемые exit codes:

- `0`: PASS
- `1`: ошибка инфраструктуры запуска (нет `pgbench`, нет БД, невалидные аргументы)
- `2`: инвариант Openbill нарушен
- `3`: perf-регрессия относительно baseline

## 11. План внедрения

### Этап 1 (MVP)

- `tests/benchmark_transfers.sh`
- сценарий `hot_pair`
- `summary.json` + инвариант баланса

### Этап 2

- сценарии `account_pool`, `hold_cycle`
- повторы (`--repeats`) и percentile-агрегация

### Этап 3

- baseline-сравнение и PASS/FAIL по регрессии
- удобный markdown/plain-text summary для PR/CI

### Этап 4

- интеграция в nightly CI job
- хранение baseline per branch / per PostgreSQL version

## 12. Критерии готовности design -> implementation

- документ покрывает сценарии, метрики, контракт CLI и артефакты;
- есть чёткие правила верификации финансовых инвариантов;
- есть измеримый PASS/FAIL для регрессии производительности;
- реализация может быть сделана без дополнительных архитектурных решений.
