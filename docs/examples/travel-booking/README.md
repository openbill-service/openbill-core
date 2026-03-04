# travel-booking

Status: ready

## Industry Summary

Предоплата в booking escrow и дальнейшие выплаты поставщику и OTA-комиссии.

## Categories

- `Traveler`
- `BookingEscrow`
- `SupplierPayout`
- `OTAFee`

## Policies

- `Traveler -> BookingEscrow` (`allow_reverse = true`)
- `BookingEscrow -> SupplierPayout` (`allow_reverse = false`)
- `BookingEscrow -> OTAFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `Traveler -> BookingEscrow`
2. Перевод: `BookingEscrow -> SupplierPayout`
3. Перевод: `BookingEscrow -> OTAFee`
4. Пример запрещённого маршрута: `BookingEscrow -> Traveler`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/travel-booking/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/travel-booking/operations.sql)
