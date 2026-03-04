# payment-system-psp

Status: ready

## Industry Summary

Контур платёжной системы (PSP): деньги плательщика попадают в clearing, затем
распределяются на мерчанта, комиссию провайдера и резерв по чарджбекам.

## Categories

- `PayerSource` — счёт источника платежа плательщика.
- `PSPClearing` — клиринговый счёт PSP.
- `MerchantSettlement` — счёт расчётов с мерчантами.
- `PSPFee` — счёт комиссии PSP.
- `ChargebackReserve` — резерв под chargeback.

## Policies

- `PayerSource -> PSPClearing` (`возвращаемые`) — разрешён перевод из категории `PayerSource` в категорию `PSPClearing` в рамках сценария.
- `PSPClearing -> MerchantSettlement` (`невозвращаемые`) — разрешён перевод из категории `PSPClearing` в категорию `MerchantSettlement` в рамках сценария.
- `PSPClearing -> PSPFee` (`невозвращаемые`) — разрешён перевод из категории `PSPClearing` в категорию `PSPFee` в рамках сценария.
- `PSPClearing -> ChargebackReserve` (`невозвращаемые`) — разрешён перевод из категории `PSPClearing` в категорию `ChargebackReserve` в рамках сценария.

## Typical Operations

1. Платёж клиента: `PayerSource -> PSPClearing`
2. Выплата мерчанту
3. Удержание комиссии PSP
4. Отчисление в chargeback reserve
5. Пример запрещённого маршрута: `PayerSource -> MerchantSettlement`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/payment-system-psp/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/payment-system-psp/operations.sql)
