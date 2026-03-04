# affiliate-payouts

Status: ready

## Industry Summary

Контур начисления и выплаты партнёрских вознаграждений.

## Categories

- `Revenue` — счёт выручки.
- `AffiliatePayable` — счёт начислений партнёрам (к выплате).
- `AffiliateWallet` — кошелёк партнёра.

## Policies

- `Revenue -> AffiliatePayable` (`невозвращаемые`) — разрешён перевод из категории `Revenue` в категорию `AffiliatePayable` в рамках сценария.
- `AffiliatePayable -> AffiliateWallet` (`невозвращаемые`) — разрешён перевод из категории `AffiliatePayable` в категорию `AffiliateWallet` в рамках сценария.

## Typical Operations

1. Перевод: `Revenue -> AffiliatePayable`
2. Перевод: `AffiliatePayable -> AffiliateWallet`
3. Пример запрещённого маршрута: `AffiliatePayable -> Revenue`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/affiliate-payouts/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/affiliate-payouts/operations.sql)
