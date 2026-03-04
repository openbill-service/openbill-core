# ad-network

Status: ready

## Industry Summary

Рекламная сеть: депозиты рекламодателей, escrow кампаний и выплаты паблишерам.

## Categories

- `AdvertiserDeposit`
- `CampaignEscrow`
- `PublisherPayout`
- `NetworkFee`

## Policies

- `AdvertiserDeposit -> CampaignEscrow` (`allow_reverse = false`)
- `CampaignEscrow -> PublisherPayout` (`allow_reverse = false`)
- `CampaignEscrow -> NetworkFee` (`allow_reverse = false`)

## Typical Operations

1. Перевод: `AdvertiserDeposit -> CampaignEscrow`
2. Перевод: `CampaignEscrow -> PublisherPayout`
3. Перевод: `CampaignEscrow -> NetworkFee`
4. Пример запрещённого маршрута: `CampaignEscrow -> AdvertiserDeposit`

SQL-файлы:
- [`categories-and-policies.sql`](categories-and-policies.sql)
- [`operations.sql`](operations.sql)
