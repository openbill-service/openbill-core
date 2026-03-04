# card-issuer

Status: ready

## Industry Summary

Карточный контур эмитента: авторизация, расчёт с мерчантом, комиссии и chargeback reserve.

## Categories

- `CardholderAccount` — счёт держателя карты.
- `CardAuthHold` — счёт авторизационных hold по картам.
- `MerchantSettlement` — счёт расчётов с мерчантами.
- `CardFeeIncome` — счёт дохода от карточных комиссий.
- `ChargebackReserve` — резерв под chargeback.

## Policies

- `CardholderAccount -> CardAuthHold` (`невозвращаемые`) — разрешён перевод из категории `CardholderAccount` в категорию `CardAuthHold` в рамках сценария.
- `CardAuthHold -> MerchantSettlement` (`невозвращаемые`) — разрешён перевод из категории `CardAuthHold` в категорию `MerchantSettlement` в рамках сценария.
- `CardholderAccount -> CardFeeIncome` (`невозвращаемые`) — разрешён перевод из категории `CardholderAccount` в категорию `CardFeeIncome` в рамках сценария.
- `CardAuthHold -> ChargebackReserve` (`невозвращаемые`) — разрешён перевод из категории `CardAuthHold` в категорию `ChargebackReserve` в рамках сценария.

## Typical Operations

1. Перевод: `CardholderAccount -> CardAuthHold`
2. Перевод: `CardAuthHold -> MerchantSettlement`
3. Перевод: `CardholderAccount -> CardFeeIncome`
4. Перевод: `CardAuthHold -> ChargebackReserve`
5. Пример запрещённого маршрута: `CardAuthHold -> CardholderAccount`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/card-issuer/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/card-issuer/operations.sql)
