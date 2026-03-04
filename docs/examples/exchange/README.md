# exchange

Status: ready

## Industry Summary

Базовый spot-контур биржи с vault-счетами и комиссией по валютам.

## Categories

- `User_USD` — USD-счёт пользователя.
- `User_BTC` — BTC-счёт пользователя.
- `ExchangeVault_USD` — USD-резерв (vault) биржи.
- `ExchangeVault_BTC` — BTC-резерв (vault) биржи.
- `Fee_USD` — USD-счёт комиссий биржи.
- `Fee_BTC` — BTC-счёт комиссий биржи.

## Policies

- `User_USD -> ExchangeVault_USD` (`возвращаемые`) — разрешён перевод из категории `User_USD` в категорию `ExchangeVault_USD` в рамках сценария.
- `ExchangeVault_BTC -> User_BTC` (`невозвращаемые`) — разрешён перевод из категории `ExchangeVault_BTC` в категорию `User_BTC` в рамках сценария.
- `User_USD -> Fee_USD` (`невозвращаемые`) — разрешён перевод из категории `User_USD` в категорию `Fee_USD` в рамках сценария.
- `User_BTC -> Fee_BTC` (`невозвращаемые`) — разрешён перевод из категории `User_BTC` в категорию `Fee_BTC` в рамках сценария.

## Typical Operations

1. Перевод: `User_USD -> ExchangeVault_USD`
2. Перевод: `ExchangeVault_BTC -> User_BTC`
3. Перевод: `User_USD -> Fee_USD`
4. Перевод: `User_BTC -> Fee_BTC`
5. Пример запрещённого маршрута: `ExchangeVault_USD -> User_USD`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/exchange/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/exchange/operations.sql)
