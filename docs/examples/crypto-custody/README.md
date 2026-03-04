# crypto-custody

Status: ready

## Industry Summary

Кастоди-контур с депозитами, очередью вывода, комплаенс-холдом и сетевой комиссией.

## Categories

- `OnchainHot` — горячий on-chain счёт.
- `UserCustody` — кастодиальный счёт пользователя.
- `WithdrawalQueue` — очередь вывода средств.
- `ComplianceHold` — счёт комплаенс-блокировок.
- `NetworkFee` — счёт сетевых/инфраструктурных комиссий.

## Policies

- `OnchainHot -> UserCustody` (`возвращаемые`) — разрешён перевод из категории `OnchainHot` в категорию `UserCustody` в рамках сценария.
- `UserCustody -> WithdrawalQueue` (`невозвращаемые`) — разрешён перевод из категории `UserCustody` в категорию `WithdrawalQueue` в рамках сценария.
- `UserCustody -> ComplianceHold` (`невозвращаемые`) — разрешён перевод из категории `UserCustody` в категорию `ComplianceHold` в рамках сценария.
- `UserCustody -> NetworkFee` (`невозвращаемые`) — разрешён перевод из категории `UserCustody` в категорию `NetworkFee` в рамках сценария.

## Typical Operations

1. Перевод: `OnchainHot -> UserCustody`
2. Перевод: `UserCustody -> WithdrawalQueue`
3. Перевод: `UserCustody -> ComplianceHold`
4. Перевод: `UserCustody -> NetworkFee`
5. Пример запрещённого маршрута: `UserCustody -> OnchainHot`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/crypto-custody/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/crypto-custody/operations.sql)
