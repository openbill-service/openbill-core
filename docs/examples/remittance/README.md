# remittance

Status: ready

## Industry Summary

Трансграничный перевод через escrow с отдельным учётом FX-комиссии.

## Categories

- `SenderSource` — счёт отправителя.
- `RemitEscrow` — эскроу-счёт ремиттанса.
- `RecipientPayout` — счёт выплаты получателю.
- `FXFee` — счёт FX-комиссии.

## Policies

- `SenderSource -> RemitEscrow` (`возвращаемые`) — разрешён перевод из категории `SenderSource` в категорию `RemitEscrow` в рамках сценария.
- `RemitEscrow -> RecipientPayout` (`невозвращаемые`) — разрешён перевод из категории `RemitEscrow` в категорию `RecipientPayout` в рамках сценария.
- `RemitEscrow -> FXFee` (`невозвращаемые`) — разрешён перевод из категории `RemitEscrow` в категорию `FXFee` в рамках сценария.

## Typical Operations

1. Перевод: `SenderSource -> RemitEscrow`
2. Перевод: `RemitEscrow -> RecipientPayout`
3. Перевод: `RemitEscrow -> FXFee`
4. Пример запрещённого маршрута: `RemitEscrow -> SenderSource`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/remittance/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/remittance/operations.sql)
