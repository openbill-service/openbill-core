# loyalty-bonuses

Status: ready

## Industry Summary

Бонусный контур: начисления, трата и учёт сгорания бонусных обязательств.

## Categories

- `BonusLiability`
- `UserBonusWallet`
- `RedemptionSink`
- `ExpiredBonusIncome`

## Policies

- `BonusLiability -> UserBonusWallet` (`allow_reverse = false`)
- `UserBonusWallet -> RedemptionSink` (`allow_reverse = false`)
- `BonusLiability -> ExpiredBonusIncome` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `BonusLiability -> UserBonusWallet`
2. Перевод: `UserBonusWallet -> RedemptionSink`
3. Перевод: `BonusLiability -> ExpiredBonusIncome`
4. Пример запрещённого маршрута: `UserBonusWallet -> BonusLiability`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
