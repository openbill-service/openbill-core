# Каталог Use Cases: `categories` + `policies`

Этот каталог показывает, как проектировать маршруты движения денег через
`OPENBILL_CATEGORIES` и `OPENBILL_POLICIES`.

## Быстрый принцип

1. `categories` задают роль счёта (кто это: клиент, escrow, комиссия и т.д.).
2. `policies` разрешают только нужные маршруты (`from -> to`).
3. Всё, что не описано политиками, отклоняется с `No policy for this transfer`.

## Перед запуском своих правил

По умолчанию в БД есть политика, разрешающая всё:

```sql
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';
```

## Каталог сценариев

| Use case | Краткое описание | Категории | Разрешённые маршруты |
|---|---|---|---|
| Маркетплейс (escrow) | Оплата клиента проходит через промежуточный escrow-счёт | `Customer`, `Escrow`, `Merchant`, `PlatformFee` | `Customer -> Escrow`, `Escrow -> Merchant`, `Escrow -> PlatformFee` |
| Подписки SaaS | Сбор выручки с последующим разносом на налоги и резервы | `Customer`, `Revenue`, `Tax`, `RefundReserve` | `Customer -> Revenue`, `Revenue -> Tax`, `Revenue -> RefundReserve` |
| P2P-кошелёк | Пополнение, вывод и удержание комиссии платформы | `UserWallet`, `TopupSource`, `WithdrawalSink`, `PlatformFee` | `TopupSource -> UserWallet`, `UserWallet -> WithdrawalSink`, `UserWallet -> PlatformFee` |
| Донаты | Сбор средств в кампанию и последующее распределение | `Donor`, `CampaignEscrow`, `Beneficiary`, `PlatformFee` | `Donor -> CampaignEscrow`, `CampaignEscrow -> Beneficiary`, `CampaignEscrow -> PlatformFee` |
| Gift Cards | Выпуск обязательства, активация в кошелёк, списание breakage | `GiftLiability`, `UserWallet`, `BreakageIncome` | `GiftLiability -> UserWallet`, `GiftLiability -> BreakageIncome` |
| Партнёрские выплаты | Начисление партнёру и отдельный этап фактической выплаты | `Revenue`, `AffiliatePayable`, `AffiliateWallet` | `Revenue -> AffiliatePayable`, `AffiliatePayable -> AffiliateWallet` |
| Игра: донаты и траты | Игрок пополняет баланс и тратит его в игре | `TopupSource`, `PlayerWallet`, `RewardPool`, `GameSink`, `PlatformFee` | `TopupSource -> PlayerWallet`, `RewardPool -> PlayerWallet`, `PlayerWallet -> GameSink`, `PlayerWallet -> PlatformFee` |
| Игра: рынок предметов (escrow) | Сделка между игроками проходит через гарантийный счёт | `BuyerWallet`, `SellerWallet`, `TradeEscrow`, `TradeFee` | `BuyerWallet -> TradeEscrow`, `TradeEscrow -> SellerWallet`, `TradeEscrow -> TradeFee` |
| Биржа spot (CEX) | Покупка/продажа через биржевые пулы и fee-счета | `User_USD`, `User_BTC`, `ExchangeVault_USD`, `ExchangeVault_BTC`, `Fee_USD`, `Fee_BTC` | `User_USD -> ExchangeVault_USD`, `ExchangeVault_BTC -> User_BTC`, `User_* -> Fee_*` |
| Биржа P2P | P2P-сделка с удержанием актива в escrow до подтверждения | `BuyerFiat`, `SellerCrypto`, `P2PEscrow`, `P2PFee` | `SellerCrypto -> P2PEscrow`, `P2PEscrow -> BuyerCrypto`, `P2PEscrow -> P2PFee` |
| Криптообменник (instant swap) | Мгновенный обмен одного актива на другой через пулы ликвидности | `User_BTC`, `User_ETH`, `SwapPool_BTC`, `SwapPool_ETH`, `SwapFee` | `User_BTC -> SwapPool_BTC`, `SwapPool_ETH -> User_ETH`, `User_* -> SwapFee` |
| Криптокастоди | Депозит, вывод и комплаенс-холд при проверках | `OnchainHot`, `UserCustody`, `WithdrawalQueue`, `ComplianceHold`, `NetworkFee` | `OnchainHot -> UserCustody`, `UserCustody -> WithdrawalQueue`, `UserCustody -> ComplianceHold`, `UserCustody -> NetworkFee` |
| Маржинальная биржа | Учёт залогов, PnL и ликвидаций в отдельных контурах | `UserCollateral`, `MarginPool`, `LiquidationPool`, `LiquidationFee`, `UserPnL` | `UserCollateral -> MarginPool`, `MarginPool -> UserPnL`, `MarginPool -> LiquidationPool`, `LiquidationPool -> LiquidationFee` |
| Стейкинг / Earn | Стейк, начисление наград и отложенный анстейк | `UserWallet`, `StakingPool`, `RewardPool`, `UnstakeQueue` | `UserWallet -> StakingPool`, `RewardPool -> UserWallet`, `StakingPool -> UnstakeQueue`, `UnstakeQueue -> UserWallet` |
| Банк (core banking) | Учёт клиентских счетов, списаний по картам и банковских комиссий | `ExternalClearing`, `ClientAccount`, `CardSettlement`, `BankFeeIncome`, `LoanRepayment` | `ExternalClearing -> ClientAccount`, `ClientAccount -> CardSettlement`, `ClientAccount -> BankFeeIncome`, `ClientAccount -> LoanRepayment` |
| Платёжная система (PSP) | Приём платежей, расчёты с мерчантами и резерв под чарджбеки | `PayerSource`, `PSPClearing`, `MerchantSettlement`, `PSPFee`, `ChargebackReserve` | `PayerSource -> PSPClearing`, `PSPClearing -> MerchantSettlement`, `PSPClearing -> PSPFee`, `PSPClearing -> ChargebackReserve` |

### Важно для обменников и бирж

`OPENBILL_TRANSFERS` работает в рамках одной валюты на операцию. Обмен
(`BTC -> ETH`, `USD -> BTC`) обычно моделируют двумя transfer-операциями
в одной бизнес-транзакции, связывая их через `idempotency_key`/`meta`.

## Практика по возвратам

Если нужен возврат, используйте `reverse_transaction_id` и в политике включайте
`allow_reverse = true` для нужного маршрута.

## Готовые SQL-примеры

Готовые вставки категорий и политик: [`use-cases.sql`](use-cases.sql).
