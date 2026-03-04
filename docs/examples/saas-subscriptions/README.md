# saas-subscriptions

Status: ready

## Industry Summary

Контур подписочной выручки: оплата клиента, выделение налогов и резервов на возвраты.

## Categories

- `Customer`
- `Revenue`
- `Tax`
- `RefundReserve`

## Policies

- `Customer -> Revenue` (`allow_reverse = true`)
- `Revenue -> Tax` (`allow_reverse = false`)
- `Revenue -> RefundReserve` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `Customer -> Revenue`
2. Перевод: `Revenue -> Tax`
3. Перевод: `Revenue -> RefundReserve`
4. Пример запрещённого маршрута: `Revenue -> Customer`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/saas-subscriptions/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/saas-subscriptions/operations.sql)
