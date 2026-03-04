# insurance

Status: ready

## Industry Summary

Страховой контур: сбор премий, резерв и выплаты по страховым случаям.

## Categories

- `PremiumInflow`
- `InsuranceReserve`
- `ClaimsPayout`
- `InsuranceFee`

## Policies

- `PremiumInflow -> InsuranceReserve` (`allow_reverse = false`)
- `InsuranceReserve -> ClaimsPayout` (`allow_reverse = false`)
- `InsuranceReserve -> InsuranceFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `PremiumInflow -> InsuranceReserve`
2. Перевод: `InsuranceReserve -> ClaimsPayout`
3. Перевод: `InsuranceReserve -> InsuranceFee`
4. Пример запрещённого маршрута: `InsuranceReserve -> PremiumInflow`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
