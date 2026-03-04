# bank

Status: ready

## Industry Summary

Базовый банковский контур: внешние зачисления на клиентские счета, списания по
картам, банковские комиссии и отдельный поток погашения кредита.

## Categories

- `ExternalClearing` — внешний расчётный счёт.
- `ClientAccount` — клиентский счёт.
- `CardSettlement` — счёт карточных расчётов.
- `BankFeeIncome` — счёт доходов от банковских комиссий.
- `LoanRepayment` — счёт погашения кредита.

## Policies

- `ExternalClearing -> ClientAccount` (`возвращаемые`) — разрешён перевод из категории `ExternalClearing` в категорию `ClientAccount` в рамках сценария.
- `ClientAccount -> CardSettlement` (`невозвращаемые`) — разрешён перевод из категории `ClientAccount` в категорию `CardSettlement` в рамках сценария.
- `ClientAccount -> BankFeeIncome` (`невозвращаемые`) — разрешён перевод из категории `ClientAccount` в категорию `BankFeeIncome` в рамках сценария.
- `ClientAccount -> LoanRepayment` (`невозвращаемые`) — разрешён перевод из категории `ClientAccount` в категорию `LoanRepayment` в рамках сценария.

## Typical Operations

1. Внешнее зачисление на счёт клиента
2. Покупка по карте (клиент -> card settlement)
3. Списание ежемесячной банковской комиссии
4. Погашение кредита
5. Пример запрещённого маршрута: `ClientAccount -> ExternalClearing`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/bank/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/bank/operations.sql)
