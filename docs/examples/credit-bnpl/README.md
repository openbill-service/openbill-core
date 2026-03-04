# credit-bnpl

Status: ready

## Industry Summary

Выдача кредита и последующее погашение тела, процентов и штрафов.

## Categories

- `LenderFund` — счёт фонда кредитора.
- `BorrowerAccount` — счёт заёмщика.
- `PrincipalRepayment` — счёт погашения основного долга.
- `InterestIncome` — счёт процентного дохода.
- `PenaltyIncome` — счёт дохода от штрафов.

## Policies

- `LenderFund -> BorrowerAccount` (`невозвращаемые`) — разрешён перевод из категории `LenderFund` в категорию `BorrowerAccount` в рамках сценария.
- `BorrowerAccount -> PrincipalRepayment` (`невозвращаемые`) — разрешён перевод из категории `BorrowerAccount` в категорию `PrincipalRepayment` в рамках сценария.
- `BorrowerAccount -> InterestIncome` (`невозвращаемые`) — разрешён перевод из категории `BorrowerAccount` в категорию `InterestIncome` в рамках сценария.
- `BorrowerAccount -> PenaltyIncome` (`невозвращаемые`) — разрешён перевод из категории `BorrowerAccount` в категорию `PenaltyIncome` в рамках сценария.

## Typical Operations

1. Перевод: `LenderFund -> BorrowerAccount`
2. Перевод: `BorrowerAccount -> PrincipalRepayment`
3. Перевод: `BorrowerAccount -> InterestIncome`
4. Перевод: `BorrowerAccount -> PenaltyIncome`
5. Пример запрещённого маршрута: `BorrowerAccount -> LenderFund`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/credit-bnpl/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/credit-bnpl/operations.sql)
