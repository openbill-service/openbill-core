# gift-cards

Status: ready

## Industry Summary

Учёт обязательств по подарочным картам, активация и списание неиспользованного остатка.

## Categories

- `GiftLiability`
- `UserWallet`
- `BreakageIncome`

## Policies

- `GiftLiability -> UserWallet` (`allow_reverse = false`)
- `GiftLiability -> BreakageIncome` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `GiftLiability -> UserWallet`
2. Перевод: `GiftLiability -> BreakageIncome`
3. Пример запрещённого маршрута: `UserWallet -> GiftLiability`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
