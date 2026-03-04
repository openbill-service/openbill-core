# donations

Status: ready

## Industry Summary

Сбор донатов через escrow с последующим распределением в пользу получателя и платформы.

## Categories

- `Donor`
- `CampaignEscrow`
- `Beneficiary`
- `PlatformFee`

## Policies

- `Donor -> CampaignEscrow` (`allow_reverse = true`)
- `CampaignEscrow -> Beneficiary` (`allow_reverse = false`)
- `CampaignEscrow -> PlatformFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `Donor -> CampaignEscrow`
2. Перевод: `CampaignEscrow -> Beneficiary`
3. Перевод: `CampaignEscrow -> PlatformFee`
4. Пример запрещённого маршрута: `CampaignEscrow -> Donor`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/donations/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/donations/operations.sql)
