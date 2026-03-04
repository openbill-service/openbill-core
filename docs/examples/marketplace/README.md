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

### Описание категорий

- `Customer` — счёт клиента (источник оплаты).
- `Escrow` — промежуточный гарантийный счёт сделки.
- `Merchant` — счёт мерчанта (получателя выручки).
- `PlatformFee` — счёт комиссии платформы.

## Policies

- `Customer -> Escrow` (`allow_reverse = true`)
- `Escrow -> Merchant` (`allow_reverse = false`)
- `Escrow -> PlatformFee` (`allow_reverse = false`)

### Описание правил (policies)

- `Customer -> Escrow` — клиентская оплата переводится в escrow; разрешён reverse для возврата.
- `Escrow -> Merchant` — расчёт с мерчантом после подтверждения сделки.
- `Escrow -> PlatformFee` — удержание комиссии платформы из escrow.

## Typical Operations

1. Оплата заказа: `Customer -> Escrow`
2. Выплата мерчанту: `Escrow -> Merchant`
3. Удержание комиссии: `Escrow -> PlatformFee`
4. Возврат клиенту: reverse для исходной оплаты
5. Пример запрещённого маршрута: `Customer -> Merchant`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
