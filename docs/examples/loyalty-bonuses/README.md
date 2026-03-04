# loyalty-bonuses

Status: ready

## Industry Summary

Бонусный контур: начисления, трата и учёт сгорания бонусных обязательств.

## Categories

- `BonusLiability` — счёт обязательств по бонусам.
- `UserBonusWallet` — бонусный кошелёк пользователя.
- `RedemptionSink` — счёт списания бонусов при использовании.
- `ExpiredBonusIncome` — счёт дохода от сгоревших бонусов.

## Policies

- `BonusLiability -> UserBonusWallet` (`невозвращаемые`) — разрешён перевод из категории `BonusLiability` в категорию `UserBonusWallet` в рамках сценария.
- `UserBonusWallet -> RedemptionSink` (`невозвращаемые`) — разрешён перевод из категории `UserBonusWallet` в категорию `RedemptionSink` в рамках сценария.
- `BonusLiability -> ExpiredBonusIncome` (`невозвращаемые`) — разрешён перевод из категории `BonusLiability` в категорию `ExpiredBonusIncome` в рамках сценария.

## Typical Operations

1. Перевод: `BonusLiability -> UserBonusWallet`
2. Перевод: `UserBonusWallet -> RedemptionSink`
3. Перевод: `BonusLiability -> ExpiredBonusIncome`
4. Пример запрещённого маршрута: `UserBonusWallet -> BonusLiability`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/loyalty-bonuses/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/loyalty-bonuses/operations.sql)
