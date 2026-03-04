# card-issuer

Status: ready

## Industry Summary

Карточный контур эмитента: авторизация, расчёт с мерчантом, комиссии и chargeback reserve.

## Categories

- `CardholderAccount`
- `CardAuthHold`
- `MerchantSettlement`
- `CardFeeIncome`
- `ChargebackReserve`

## Policies

- `CardholderAccount -> CardAuthHold` (`allow_reverse = false`)
- `CardAuthHold -> MerchantSettlement` (`allow_reverse = false`)
- `CardholderAccount -> CardFeeIncome` (`allow_reverse = false`)
- `CardAuthHold -> ChargebackReserve` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `CardholderAccount -> CardAuthHold`
2. Перевод: `CardAuthHold -> MerchantSettlement`
3. Перевод: `CardholderAccount -> CardFeeIncome`
4. Перевод: `CardAuthHold -> ChargebackReserve`
5. Пример запрещённого маршрута: `CardAuthHold -> CardholderAccount`

SQL-файлы:
- `categories-and-policies.sql`
- `operations.sql`
