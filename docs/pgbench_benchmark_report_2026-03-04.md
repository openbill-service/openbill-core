# Отчёт: benchmark transfer-пути через pgbench

Дата: 2026-03-04  
Инструмент: `pgbench` (PostgreSQL 17.4)

## Характеристики машины

- Hostname: `office`
- OS/Kernel: `Linux 6.8.0-100-generic x86_64 GNU/Linux`
- CPU: `Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz`
- vCPU: `8`
- RAM: `31Gi`
- PostgreSQL: `17.4 (Ubuntu 17.4-1.pgdg24.04+2)`

## Что запускалось

Бенч запускался напрямую через `pgbench` c custom SQL-скриптами:

- `tests/bench/scenarios/hot_pair.sql`
- `tests/bench/scenarios/account_pool.sql`
- `tests/bench/scenarios/hold_cycle.sql`

Параметры запусков:

- Warmup: `5s`
- Measure: `15s`
- Clients: `16`
- Threads: `4`
- Mode: `-M prepared`
- Латентность по транзакциям: `-l --log-prefix ...`

## Команды

```bash
# hot_pair
PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared \
  -f ./tests/bench/scenarios/hot_pair.sql \
  -D hot_from=1 -D hot_to=2 -D max_amount=1000 \
  -c 16 -j 4 -T 5

PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared -l \
  --log-prefix ./log/pgbench-direct/hot_pair/pgbench_log \
  -f ./tests/bench/scenarios/hot_pair.sql \
  -D hot_from=1 -D hot_to=2 -D max_amount=1000 \
  -c 16 -j 4 -T 15

# account_pool
PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared \
  -f ./tests/bench/scenarios/account_pool.sql \
  -D account_base=1001 -D account_count=200 -D max_amount=1000 \
  -c 16 -j 4 -T 5

PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared -l \
  --log-prefix ./log/pgbench-direct/account_pool/pgbench_log \
  -f ./tests/bench/scenarios/account_pool.sql \
  -D account_base=1001 -D account_count=200 -D max_amount=1000 \
  -c 16 -j 4 -T 15

# hold_cycle
PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared \
  -f ./tests/bench/scenarios/hold_cycle.sql \
  -D hot_from=3001 -D hot_to=3002 -D max_amount=1000 \
  -c 16 -j 4 -T 5

PGHOST=127.0.0.1 PGUSER=openbill-test PGPASSWORD=postgres PGDATABASE=openbill_test \
pgbench -n -M prepared -l \
  --log-prefix ./log/pgbench-direct/hold_cycle/pgbench_log \
  -f ./tests/bench/scenarios/hold_cycle.sql \
  -D hot_from=3001 -D hot_to=3002 -D max_amount=1000 \
  -c 16 -j 4 -T 15
```

## Результаты

| Scenario | TPS | Lat avg (ms) | p50 (ms) | p95 (ms) | p99 (ms) | Failed tx | Processed tx |
|---|---:|---:|---:|---:|---:|---:|---:|
| `hot_pair` | 339.196934 | 47.170 | 30.297 | 147.327 | 240.419 | 0 | 5098 |
| `account_pool` | 2074.320544 | 7.713 | 6.135 | 14.791 | 28.067 | 0 | 31086 |
| `hold_cycle` | 68.129177 | 234.848 | 171.936 | 614.437 | 956.725 | 0 | 1025 |

Проверка инварианта баланса Openbill после прогона:

- `sum(balance) + sum(hold_amount) = 0.000000000000000000`

## Артефакты

- `log/pgbench-direct/hot_pair/run.out`
- `log/pgbench-direct/hot_pair/run.err`
- `log/pgbench-direct/hot_pair/pgbench_log.*`
- `log/pgbench-direct/account_pool/run.out`
- `log/pgbench-direct/account_pool/run.err`
- `log/pgbench-direct/account_pool/pgbench_log.*`
- `log/pgbench-direct/hold_cycle/run.out`
- `log/pgbench-direct/hold_cycle/run.err`
- `log/pgbench-direct/hold_cycle/pgbench_log.*`
