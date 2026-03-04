# credit-bnpl

Status: ready

## Industry Summary

Выдача кредита и последующее погашение тела, процентов и штрафов.

## Categories

- `LenderFund`
- `BorrowerAccount`
- `PrincipalRepayment`
- `InterestIncome`
- `PenaltyIncome`

## Policies

- `LenderFund -> BorrowerAccount` (`allow_reverse = false`)
- `BorrowerAccount -> PrincipalRepayment` (`allow_reverse = false`)
- `BorrowerAccount -> InterestIncome` (`allow_reverse = false`)
- `BorrowerAccount -> PenaltyIncome` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `LenderFund -> BorrowerAccount`
2. Перевод: `BorrowerAccount -> PrincipalRepayment`
3. Перевод: `BorrowerAccount -> InterestIncome`
4. Перевод: `BorrowerAccount -> PenaltyIncome`
5. Пример запрещённого маршрута: `BorrowerAccount -> LenderFund`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
