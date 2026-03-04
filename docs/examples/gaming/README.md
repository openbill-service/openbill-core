# gaming

Status: ready

## Industry Summary

Игровая экономика: пополнения, награды, списания в игровой sink и комиссия платформы.

## Categories

- `TopupSource` — внешний источник пополнения.
- `PlayerWallet` — кошелёк игрока.
- `RewardPool` — пул вознаграждений.
- `GameSink` — счёт списаний за внутриигровые траты.
- `PlatformFee` — счёт комиссии платформы.

## Policies

- `TopupSource -> PlayerWallet` (`возвращаемые`) — разрешён перевод из категории `TopupSource` в категорию `PlayerWallet` в рамках сценария.
- `RewardPool -> PlayerWallet` (`невозвращаемые`) — разрешён перевод из категории `RewardPool` в категорию `PlayerWallet` в рамках сценария.
- `PlayerWallet -> GameSink` (`невозвращаемые`) — разрешён перевод из категории `PlayerWallet` в категорию `GameSink` в рамках сценария.
- `PlayerWallet -> PlatformFee` (`невозвращаемые`) — разрешён перевод из категории `PlayerWallet` в категорию `PlatformFee` в рамках сценария.

## Typical Operations

1. Перевод: `TopupSource -> PlayerWallet`
2. Перевод: `RewardPool -> PlayerWallet`
3. Перевод: `PlayerWallet -> GameSink`
4. Перевод: `PlayerWallet -> PlatformFee`
5. Пример запрещённого маршрута: `PlayerWallet -> TopupSource`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/gaming/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/gaming/operations.sql)
