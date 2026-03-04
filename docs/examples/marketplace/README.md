# marketplace

Status: ready

## Industry Summary

Маркетплейс с escrow-контуром: деньги клиента сначала попадают на промежуточный
счёт, затем распределяются между мерчантом и платформенной комиссией.

## Categories

- `Customer` — счёт клиента (источник оплаты).
- `Escrow` — промежуточный гарантийный счёт сделки.
- `Merchant` — счёт мерчанта (получателя выручки).
- `PlatformFee` — счёт комиссии платформы.

## Policies

- `Customer -> Escrow` (`возвращаемые`) — клиентская оплата переводится в escrow; reverse разрешён для возврата.
- `Escrow -> Merchant` (`невозвращаемые`) — расчёт с мерчантом после подтверждения сделки.
- `Escrow -> PlatformFee` (`невозвращаемые`) — удержание комиссии платформы из escrow.

## Typical Operations

1. Оплата заказа: `Customer -> Escrow`
2. Выплата мерчанту: `Escrow -> Merchant`
3. Удержание комиссии: `Escrow -> PlatformFee`
4. Возврат клиенту: reverse для исходной оплаты
5. Пример запрещённого маршрута: `Customer -> Merchant`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/marketplace/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/marketplace/operations.sql)
