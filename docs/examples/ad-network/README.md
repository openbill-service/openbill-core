# ad-network

Status: ready

## Industry Summary

Рекламная сеть: депозиты рекламодателей, escrow кампаний и выплаты паблишерам.

## Categories

- `AdvertiserDeposit` — депозитный счёт рекламодателя.
- `CampaignEscrow` — эскроу-счёт кампании.
- `PublisherPayout` — счёт выплат паблишеру.
- `NetworkFee` — счёт сетевых/инфраструктурных комиссий.

## Policies

- `AdvertiserDeposit -> CampaignEscrow` (`невозвращаемые`) — разрешён перевод из категории `AdvertiserDeposit` в категорию `CampaignEscrow` в рамках сценария.
- `CampaignEscrow -> PublisherPayout` (`невозвращаемые`) — разрешён перевод из категории `CampaignEscrow` в категорию `PublisherPayout` в рамках сценария.
- `CampaignEscrow -> NetworkFee` (`невозвращаемые`) — разрешён перевод из категории `CampaignEscrow` в категорию `NetworkFee` в рамках сценария.

## Typical Operations

1. Перевод: `AdvertiserDeposit -> CampaignEscrow`
2. Перевод: `CampaignEscrow -> PublisherPayout`
3. Перевод: `CampaignEscrow -> NetworkFee`
4. Пример запрещённого маршрута: `CampaignEscrow -> AdvertiserDeposit`

SQL-файлы:
- [`categories-and-policies.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/ad-network/categories-and-policies.sql)
- [`operations.sql`](https://github.com/openbill-service/openbill-core/blob/master/docs/examples/ad-network/operations.sql)
