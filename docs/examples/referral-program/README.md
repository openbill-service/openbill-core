# referral-program

Status: ready

## Industry Summary

Начисление реферальных бонусов, выплата партнёрам и реверс бонусов.

## Categories

- `Revenue`
- `ReferralAccrual`
- `PartnerWallet`
- `ReferralReversal`

## Policies

- `Revenue -> ReferralAccrual` (`allow_reverse = false`)
- `ReferralAccrual -> PartnerWallet` (`allow_reverse = false`)
- `ReferralAccrual -> ReferralReversal` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `Revenue -> ReferralAccrual`
2. Перевод: `ReferralAccrual -> PartnerWallet`
3. Перевод: `ReferralAccrual -> ReferralReversal`
4. Пример запрещённого маршрута: `ReferralAccrual -> Revenue`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/referral-program/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/referral-program/operations.sql)
