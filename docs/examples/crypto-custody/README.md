# crypto-custody

Status: ready

## Industry Summary

Кастоди-контур с депозитами, очередью вывода, комплаенс-холдом и сетевой комиссией.

## Categories

- `OnchainHot`
- `UserCustody`
- `WithdrawalQueue`
- `ComplianceHold`
- `NetworkFee`

## Policies

- `OnchainHot -> UserCustody` (`allow_reverse = true`)
- `UserCustody -> WithdrawalQueue` (`allow_reverse = false`)
- `UserCustody -> ComplianceHold` (`allow_reverse = false`)
- `UserCustody -> NetworkFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `OnchainHot -> UserCustody`
2. Перевод: `UserCustody -> WithdrawalQueue`
3. Перевод: `UserCustody -> ComplianceHold`
4. Перевод: `UserCustody -> NetworkFee`
5. Пример запрещённого маршрута: `UserCustody -> OnchainHot`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/crypto-custody/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/crypto-custody/operations.sql)
