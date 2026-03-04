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
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
