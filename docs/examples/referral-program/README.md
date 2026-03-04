# referral-program

Status: ready

## Industry Summary

Начисление реферальных бонусов, выплата партнёрам и реверс бонусов.

## Categories

- `Revenue` — счёт выручки.
- `ReferralAccrual` — счёт начислений по реферальной программе.
- `PartnerWallet` — кошелёк партнёра.
- `ReferralReversal` — счёт реверсов/корректировок рефералок.

## Policies

- `Revenue -> ReferralAccrual` (`невозвращаемые`) — разрешён перевод из категории `Revenue` в категорию `ReferralAccrual` в рамках сценария.
- `ReferralAccrual -> PartnerWallet` (`невозвращаемые`) — разрешён перевод из категории `ReferralAccrual` в категорию `PartnerWallet` в рамках сценария.
- `ReferralAccrual -> ReferralReversal` (`невозвращаемые`) — разрешён перевод из категории `ReferralAccrual` в категорию `ReferralReversal` в рамках сценария.

## Typical Operations

1. Перевод: `Revenue -> ReferralAccrual`
2. Перевод: `ReferralAccrual -> PartnerWallet`
3. Перевод: `ReferralAccrual -> ReferralReversal`
4. Пример запрещённого маршрута: `ReferralAccrual -> Revenue`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/referral-program/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/referral-program/operations.sql)
