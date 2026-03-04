# gift-cards

Status: ready

## Industry Summary

Учёт обязательств по подарочным картам, активация и списание неиспользованного остатка.

## Categories

- `GiftLiability` — счёт обязательств по подарочным картам.
- `UserWallet` — кошелёк пользователя.
- `BreakageIncome` — счёт дохода от неиспользованных gift card.

## Policies

- `GiftLiability -> UserWallet` (`невозвращаемые`) — разрешён перевод из категории `GiftLiability` в категорию `UserWallet` в рамках сценария.
- `GiftLiability -> BreakageIncome` (`невозвращаемые`) — разрешён перевод из категории `GiftLiability` в категорию `BreakageIncome` в рамках сценария.

## Typical Operations

1. Перевод: `GiftLiability -> UserWallet`
2. Перевод: `GiftLiability -> BreakageIncome`
3. Пример запрещённого маршрута: `UserWallet -> GiftLiability`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/gift-cards/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/gift-cards/operations.sql)
