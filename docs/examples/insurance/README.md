# insurance

Status: ready

## Industry Summary

Страховой контур: сбор премий, резерв и выплаты по страховым случаям.

## Categories

- `PremiumInflow` — счёт поступления страховых премий.
- `InsuranceReserve` — страховой резерв.
- `ClaimsPayout` — счёт страховых выплат.
- `InsuranceFee` — счёт страховой комиссии.

## Policies

- `PremiumInflow -> InsuranceReserve` (`невозвращаемые`) — разрешён перевод из категории `PremiumInflow` в категорию `InsuranceReserve` в рамках сценария.
- `InsuranceReserve -> ClaimsPayout` (`невозвращаемые`) — разрешён перевод из категории `InsuranceReserve` в категорию `ClaimsPayout` в рамках сценария.
- `InsuranceReserve -> InsuranceFee` (`невозвращаемые`) — разрешён перевод из категории `InsuranceReserve` в категорию `InsuranceFee` в рамках сценария.

## Typical Operations

1. Перевод: `PremiumInflow -> InsuranceReserve`
2. Перевод: `InsuranceReserve -> ClaimsPayout`
3. Перевод: `InsuranceReserve -> InsuranceFee`
4. Пример запрещённого маршрута: `InsuranceReserve -> PremiumInflow`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/insurance/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/insurance/operations.sql)
