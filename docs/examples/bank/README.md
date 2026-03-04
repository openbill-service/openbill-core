# bank

Status: ready

## Industry Summary

Базовый банковский контур: внешние зачисления на клиентские счета, списания по
картам, банковские комиссии и отдельный поток погашения кредита.

## Categories

- `ExternalClearing`
- `ClientAccount`
- `CardSettlement`
- `BankFeeIncome`
- `LoanRepayment`

## Policies

- `ExternalClearing -> ClientAccount` (`allow_reverse = true`)
- `ClientAccount -> CardSettlement` (`allow_reverse = false`)
- `ClientAccount -> BankFeeIncome` (`allow_reverse = false`)
- `ClientAccount -> LoanRepayment` (`allow_reverse = false`)

## Typical Operations

1. Внешнее зачисление на счёт клиента
2. Покупка по карте (клиент -> card settlement)
3. Списание ежемесячной банковской комиссии
4. Погашение кредита
5. Пример запрещённого маршрута: `ClientAccount -> ExternalClearing`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
