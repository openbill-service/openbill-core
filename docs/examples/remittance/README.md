# remittance

Status: ready

## Industry Summary

Трансграничный перевод через escrow с отдельным учётом FX-комиссии.

## Categories

- `SenderSource`
- `RemitEscrow`
- `RecipientPayout`
- `FXFee`

## Policies

- `SenderSource -> RemitEscrow` (`allow_reverse = true`)
- `RemitEscrow -> RecipientPayout` (`allow_reverse = false`)
- `RemitEscrow -> FXFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `SenderSource -> RemitEscrow`
2. Перевод: `RemitEscrow -> RecipientPayout`
3. Перевод: `RemitEscrow -> FXFee`
4. Пример запрещённого маршрута: `RemitEscrow -> SenderSource`

SQL-файлы:
- `categories-and-policies.sql`
- `operations.sql`
