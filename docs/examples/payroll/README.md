# payroll

Status: ready

## Industry Summary

Payroll clearing: фондирование работодателем, выплаты сотрудникам и налоги.

## Categories

- `EmployerFunding` — счёт фондирования работодателя.
- `PayrollClearing` — клиринговый payroll-счёт.
- `EmployeeAccount` — счёт сотрудника.
- `TaxAccount` — налоговый счёт.

## Policies

- `EmployerFunding -> PayrollClearing` (`невозвращаемые`) — разрешён перевод из категории `EmployerFunding` в категорию `PayrollClearing` в рамках сценария.
- `PayrollClearing -> EmployeeAccount` (`невозвращаемые`) — разрешён перевод из категории `PayrollClearing` в категорию `EmployeeAccount` в рамках сценария.
- `PayrollClearing -> TaxAccount` (`невозвращаемые`) — разрешён перевод из категории `PayrollClearing` в категорию `TaxAccount` в рамках сценария.

## Typical Operations

1. Перевод: `EmployerFunding -> PayrollClearing`
2. Перевод: `PayrollClearing -> EmployeeAccount`
3. Перевод: `PayrollClearing -> TaxAccount`
4. Пример запрещённого маршрута: `PayrollClearing -> EmployerFunding`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/payroll/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/payroll/operations.sql)
