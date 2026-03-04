# telecom-prepaid

Status: ready

## Industry Summary

Prepaid-контур телекома: пополнение абонента, потребление и комиссия.

## Categories

- `TopupSource`
- `SubscriberWallet`
- `ServiceConsumption`
- `TelecomFee`

## Policies

- `TopupSource -> SubscriberWallet` (`allow_reverse = true`)
- `SubscriberWallet -> ServiceConsumption` (`allow_reverse = false`)
- `SubscriberWallet -> TelecomFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `TopupSource -> SubscriberWallet`
2. Перевод: `SubscriberWallet -> ServiceConsumption`
3. Перевод: `SubscriberWallet -> TelecomFee`
4. Пример запрещённого маршрута: `SubscriberWallet -> TopupSource`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/telecom-prepaid/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/telecom-prepaid/operations.sql)
