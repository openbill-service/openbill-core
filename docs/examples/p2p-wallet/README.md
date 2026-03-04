# p2p-wallet

Status: ready

## Industry Summary

Кошелек с контурами пополнения, вывода и удержания комиссии платформы.

## Categories

- `UserWallet`
- `TopupSource`
- `WithdrawalSink`
- `PlatformFee`

## Policies

- `TopupSource -> UserWallet` (`allow_reverse = true`)
- `UserWallet -> WithdrawalSink` (`allow_reverse = false`)
- `UserWallet -> PlatformFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `TopupSource -> UserWallet`
2. Перевод: `UserWallet -> WithdrawalSink`
3. Перевод: `UserWallet -> PlatformFee`
4. Пример запрещённого маршрута: `UserWallet -> TopupSource`

SQL-файлы:
- `categories-and-policies.sql`
- `operations.sql`
