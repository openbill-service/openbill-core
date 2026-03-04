# donations

Status: ready

## Industry Summary

Сбор донатов через escrow с последующим распределением в пользу получателя и платформы.

## Categories

- `Donor` — счёт донора.
- `CampaignEscrow` — эскроу-счёт кампании.
- `Beneficiary` — счёт бенефициара.
- `PlatformFee` — счёт комиссии платформы.

## Policies

- `Donor -> CampaignEscrow` (`возвращаемые`) — разрешён перевод из категории `Donor` в категорию `CampaignEscrow` в рамках сценария.
- `CampaignEscrow -> Beneficiary` (`невозвращаемые`) — разрешён перевод из категории `CampaignEscrow` в категорию `Beneficiary` в рамках сценария.
- `CampaignEscrow -> PlatformFee` (`невозвращаемые`) — разрешён перевод из категории `CampaignEscrow` в категорию `PlatformFee` в рамках сценария.

## Typical Operations

1. Перевод: `Donor -> CampaignEscrow`
2. Перевод: `CampaignEscrow -> Beneficiary`
3. Перевод: `CampaignEscrow -> PlatformFee`
4. Пример запрещённого маршрута: `CampaignEscrow -> Donor`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/donations/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/donations/operations.sql)
