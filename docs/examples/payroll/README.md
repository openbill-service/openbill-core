# payroll

Status: ready

## Industry Summary

Payroll clearing: фондирование работодателем, выплаты сотрудникам и налоги.

## Categories

- `EmployerFunding`
- `PayrollClearing`
- `EmployeeAccount`
- `TaxAccount`

## Policies

- `EmployerFunding -> PayrollClearing` (`allow_reverse = false`)
- `PayrollClearing -> EmployeeAccount` (`allow_reverse = false`)
- `PayrollClearing -> TaxAccount` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `EmployerFunding -> PayrollClearing`
2. Перевод: `PayrollClearing -> EmployeeAccount`
3. Перевод: `PayrollClearing -> TaxAccount`
4. Пример запрещённого маршрута: `PayrollClearing -> EmployerFunding`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
