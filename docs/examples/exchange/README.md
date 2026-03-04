# exchange

Status: ready

## Industry Summary

Базовый spot-контур биржи с vault-счетами и комиссией по валютам.

## Categories

- `User_USD`
- `User_BTC`
- `ExchangeVault_USD`
- `ExchangeVault_BTC`
- `Fee_USD`
- `Fee_BTC`

## Policies

- `User_USD -> ExchangeVault_USD` (`allow_reverse = true`)
- `ExchangeVault_BTC -> User_BTC` (`allow_reverse = false`)
- `User_USD -> Fee_USD` (`allow_reverse = false`)
- `User_BTC -> Fee_BTC` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `User_USD -> ExchangeVault_USD`
2. Перевод: `ExchangeVault_BTC -> User_BTC`
3. Перевод: `User_USD -> Fee_USD`
4. Перевод: `User_BTC -> Fee_BTC`
5. Пример запрещённого маршрута: `ExchangeVault_USD -> User_USD`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
