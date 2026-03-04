# travel-booking

Status: ready

## Industry Summary

Предоплата в booking escrow и дальнейшие выплаты поставщику и OTA-комиссии.

## Categories

- `Traveler` — счёт путешественника (плательщика).
- `BookingEscrow` — эскроу-счёт бронирований.
- `SupplierPayout` — счёт выплат поставщику.
- `OTAFee` — счёт комиссии OTA.

## Policies

- `Traveler -> BookingEscrow` (`возвращаемые`) — разрешён перевод из категории `Traveler` в категорию `BookingEscrow` в рамках сценария.
- `BookingEscrow -> SupplierPayout` (`невозвращаемые`) — разрешён перевод из категории `BookingEscrow` в категорию `SupplierPayout` в рамках сценария.
- `BookingEscrow -> OTAFee` (`невозвращаемые`) — разрешён перевод из категории `BookingEscrow` в категорию `OTAFee` в рамках сценария.

## Typical Operations

1. Перевод: `Traveler -> BookingEscrow`
2. Перевод: `BookingEscrow -> SupplierPayout`
3. Перевод: `BookingEscrow -> OTAFee`
4. Пример запрещённого маршрута: `BookingEscrow -> Traveler`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/travel-booking/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/travel-booking/operations.sql)
