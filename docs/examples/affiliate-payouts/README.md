# affiliate-payouts

Status: ready

## Industry Summary

Контур начисления и выплаты партнёрских вознаграждений.

## Categories

- `Revenue`
- `AffiliatePayable`
- `AffiliateWallet`

## Policies

- `Revenue -> AffiliatePayable` (`allow_reverse = false`)
- `AffiliatePayable -> AffiliateWallet` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `Revenue -> AffiliatePayable`
2. Перевод: `AffiliatePayable -> AffiliateWallet`
3. Пример запрещённого маршрута: `AffiliatePayable -> Revenue`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/affiliate-payouts/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/affiliate-payouts/operations.sql)
