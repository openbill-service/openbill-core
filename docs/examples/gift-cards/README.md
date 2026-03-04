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
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/gift-cards/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/gift-cards/operations.sql)
