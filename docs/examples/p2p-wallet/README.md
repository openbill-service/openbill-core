# p2p-wallet

Status: ready

## Industry Summary

Кошелек с контурами пополнения, вывода и удержания комиссии платформы.

## Categories

- `UserWallet` — кошелёк пользователя.
- `TopupSource` — внешний источник пополнения.
- `WithdrawalSink` — счёт вывода средств.
- `PlatformFee` — счёт комиссии платформы.

## Policies

- `TopupSource -> UserWallet` (`возвращаемые`) — разрешён перевод из категории `TopupSource` в категорию `UserWallet` в рамках сценария.
- `UserWallet -> WithdrawalSink` (`невозвращаемые`) — разрешён перевод из категории `UserWallet` в категорию `WithdrawalSink` в рамках сценария.
- `UserWallet -> PlatformFee` (`невозвращаемые`) — разрешён перевод из категории `UserWallet` в категорию `PlatformFee` в рамках сценария.

## Typical Operations

1. Перевод: `TopupSource -> UserWallet`
2. Перевод: `UserWallet -> WithdrawalSink`
3. Перевод: `UserWallet -> PlatformFee`
4. Пример запрещённого маршрута: `UserWallet -> TopupSource`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/p2p-wallet/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/p2p-wallet/operations.sql)
