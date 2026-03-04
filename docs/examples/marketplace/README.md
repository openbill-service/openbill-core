# marketplace

Status: ready

## Industry Summary

Маркетплейс с escrow-контуром: деньги клиента сначала попадают на промежуточный
счёт, затем распределяются между мерчантом и платформенной комиссией.

## Categories

- `Customer`
- `Escrow`
- `Merchant`
- `PlatformFee`

## Policies

- `Customer -> Escrow` (`allow_reverse = true`)
- `Escrow -> Merchant` (`allow_reverse = false`)
- `Escrow -> PlatformFee` (`allow_reverse = false`)

## Typical Operations

1. Оплата заказа: `Customer -> Escrow`
2. Выплата мерчанту: `Escrow -> Merchant`
3. Удержание комиссии: `Escrow -> PlatformFee`
4. Возврат клиенту: reverse для исходной оплаты
5. Пример запрещённого маршрута: `Customer -> Merchant`

SQL-файлы:
- `categories-and-policies.sql`
- `operations.sql`
