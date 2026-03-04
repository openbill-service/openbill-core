# saas-subscriptions

Status: ready

## Industry Summary

Контур подписочной выручки: оплата клиента, выделение налогов и резервов на возвраты.

## Categories

- `Customer` — счёт клиента (источник оплаты).
- `Revenue` — счёт выручки.
- `Tax` — налоговый счёт.
- `RefundReserve` — резерв под возвраты.

## Policies

- `Customer -> Revenue` (`возвращаемые`) — разрешён перевод из категории `Customer` в категорию `Revenue` в рамках сценария.
- `Revenue -> Tax` (`невозвращаемые`) — разрешён перевод из категории `Revenue` в категорию `Tax` в рамках сценария.
- `Revenue -> RefundReserve` (`невозвращаемые`) — разрешён перевод из категории `Revenue` в категорию `RefundReserve` в рамках сценария.

## Typical Operations

1. Перевод: `Customer -> Revenue`
2. Перевод: `Revenue -> Tax`
3. Перевод: `Revenue -> RefundReserve`
4. Пример запрещённого маршрута: `Revenue -> Customer`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/saas-subscriptions/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/saas-subscriptions/operations.sql)
