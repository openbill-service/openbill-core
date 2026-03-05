# Каталог отраслевых примеров

Каталог показывает готовые сценарии маршрутизации переводов через `openbill_categories` и `openbill_policies`.

Каждый сценарий содержит:

- `README.md` — доменная модель и типовые операции
- `categories-and-policies.sql` — категории и политики маршрутов
- `operations.sql` — демонстрационные операции
- `test.sh` — автоматический прогон сценария с проверкой выполнения SQL

## Как пользоваться каталогом

1. Выберите сценарий в таблице ниже.
2. Запустите `./docs/examples/<scenario>/test.sh` из корня репозитория.
3. При необходимости откройте локальные SQL-файлы (`categories-and-policies.sql`, `operations.sql`) и адаптируйте под свой домен.

## Быстрый выбор сценария

| Ваша задача | Рекомендуемый пример | Почему начать с него |
|---|---|---|
| Маркетплейс с escrow и комиссией | [marketplace](marketplace/README.md) | Понятный базовый поток `оплата -> расчёт -> комиссия` |
| Подписки и распределение выручки | [saas-subscriptions](saas-subscriptions/README.md) | Регулярные платежи + налоги + резерв на возвраты |
| P2P-кошелёк с вводом/выводом | [p2p-wallet](p2p-wallet/README.md) | Классический wallet-контур для финтеха |
| Платёжный провайдер (PSP) | [payment-system-psp](payment-system-psp/README.md) | Клиринг, мерчантские выплаты, fee и chargeback reserve |
| Кредитный контур / BNPL | [credit-bnpl](credit-bnpl/README.md) | Выдача и погашение: тело, проценты, штрафы |
| Тестовый «самый простой» старт | [donations](donations/README.md) | Минимальный сценарий для первого запуска |

## Все доступные отрасли

- [marketplace](marketplace/README.md)
- [saas-subscriptions](saas-subscriptions/README.md)
- [p2p-wallet](p2p-wallet/README.md)
- [donations](donations/README.md)
- [gift-cards](gift-cards/README.md)
- [affiliate-payouts](affiliate-payouts/README.md)
- [gaming](gaming/README.md)
- [exchange](exchange/README.md)
- [crypto-custody](crypto-custody/README.md)
- [bank](bank/README.md)
- [payment-system-psp](payment-system-psp/README.md)
- [insurance](insurance/README.md)
- [payroll](payroll/README.md)
- [credit-bnpl](credit-bnpl/README.md)
- [card-issuer](card-issuer/README.md)
- [remittance](remittance/README.md)
- [travel-booking](travel-booking/README.md)
- [referral-program](referral-program/README.md)
- [ad-network](ad-network/README.md)
- [telecom-prepaid](telecom-prepaid/README.md)
- [loyalty-bonuses](loyalty-bonuses/README.md)

## Полезные команды

Запуск одного сценария:

```bash
./docs/examples/marketplace/test.sh
```

Запуск всех сценариев:

```bash
./test-examples.sh
```
