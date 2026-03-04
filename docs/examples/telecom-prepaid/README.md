# telecom-prepaid

Status: ready

## Industry Summary

Prepaid-контур телекома: пополнение абонента, потребление и комиссия.

## Categories

- `TopupSource` — внешний источник пополнения.
- `SubscriberWallet` — кошелёк абонента.
- `ServiceConsumption` — счёт списаний за услуги.
- `TelecomFee` — счёт комиссии оператора.

## Policies

- `TopupSource -> SubscriberWallet` (`возвращаемые`) — разрешён перевод из категории `TopupSource` в категорию `SubscriberWallet` в рамках сценария.
- `SubscriberWallet -> ServiceConsumption` (`невозвращаемые`) — разрешён перевод из категории `SubscriberWallet` в категорию `ServiceConsumption` в рамках сценария.
- `SubscriberWallet -> TelecomFee` (`невозвращаемые`) — разрешён перевод из категории `SubscriberWallet` в категорию `TelecomFee` в рамках сценария.

## Typical Operations

1. Перевод: `TopupSource -> SubscriberWallet`
2. Перевод: `SubscriberWallet -> ServiceConsumption`
3. Перевод: `SubscriberWallet -> TelecomFee`
4. Пример запрещённого маршрута: `SubscriberWallet -> TopupSource`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/telecom-prepaid/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/telecom-prepaid/operations.sql)
