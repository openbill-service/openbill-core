# payment-system-psp

Status: ready

## Industry Summary

Контур платёжной системы (PSP): деньги плательщика попадают в clearing, затем
распределяются на мерчанта, комиссию провайдера и резерв по чарджбекам.

## Categories

- `PayerSource`
- `PSPClearing`
- `MerchantSettlement`
- `PSPFee`
- `ChargebackReserve`

## Policies

- `PayerSource -> PSPClearing` (`allow_reverse = true`)
- `PSPClearing -> MerchantSettlement` (`allow_reverse = false`)
- `PSPClearing -> PSPFee` (`allow_reverse = false`)
- `PSPClearing -> ChargebackReserve` (`allow_reverse = false`)

## Typical Operations

1. Платёж клиента: `PayerSource -> PSPClearing`
2. Выплата мерчанту
3. Удержание комиссии PSP
4. Отчисление в chargeback reserve
5. Пример запрещённого маршрута: `PayerSource -> MerchantSettlement`

SQL-файлы:
- `categories-and-policies.sql`
- `operations.sql`
