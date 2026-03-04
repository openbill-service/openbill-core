# gaming

Status: ready

## Industry Summary

Игровая экономика: пополнения, награды, списания в игровой sink и комиссия платформы.

## Categories

- `TopupSource`
- `PlayerWallet`
- `RewardPool`
- `GameSink`
- `PlatformFee`

## Policies

- `TopupSource -> PlayerWallet` (`allow_reverse = true`)
- `RewardPool -> PlayerWallet` (`allow_reverse = false`)
- `PlayerWallet -> GameSink` (`allow_reverse = false`)
- `PlayerWallet -> PlatformFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `TopupSource -> PlayerWallet`
2. Перевод: `RewardPool -> PlayerWallet`
3. Перевод: `PlayerWallet -> GameSink`
4. Перевод: `PlayerWallet -> PlatformFee`
5. Пример запрещённого маршрута: `PlayerWallet -> TopupSource`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
