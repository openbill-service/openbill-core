# Операции

Операция (Operation) — бизнес-действие, выраженное через один или несколько transfers и holds Openbill.

Здесь описаны **виды операций** — повторяющиеся паттерны, которые встречаются в разных отраслях. Конкретные примеры по отраслям — в разделе [Отраслевые примеры](examples/README.md).

!!! note "Вид vs факт"
    **Вид операции** (Operation Type) — шаблон: «Пополнение», «Удержание комиссии», «Возврат».
    **Факт операции** (Operation Instance) — конкретное исполнение: «Оплата заказа #123 на 100 USD».
    Один бизнес-сценарий может включать несколько видов. Например, расчёт по заказу = Settlement + Fee.

Все SQL-примеры ниже используют домен **Marketplace** с категориями: `Customer`, `Escrow`, `Merchant`, `PlatformFee`.

---

## Deposit (пополнение)

Зачисление средств из внешнего источника на внутренний счёт.

**Маршрут:** источник → получатель

```sql
-- Клиент оплачивает заказ — средства поступают на escrow
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:customer_id, :escrow_id, 100, 'USD', 'order:pay:123', 'Order #123 payment');
```

**Где встречается:** marketplace (оплата заказа), банк (входящий перевод), gaming (пополнение кошелька), telecom (пополнение баланса).

---

## Withdrawal (вывод средств)

Перемещение средств с внутреннего счёта во внешний контур.

**Маршрут:** внутренний счёт → внешний приёмник

```sql
-- Вывод средств мерчантом (в примере marketplace такой маршрут запрещён policy,
-- но в p2p-wallet или gaming — типичный сценарий)
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:wallet_id, :withdrawal_sink_id, 50, 'USD', 'withdraw:456', 'Withdrawal request #456');
```

**Где встречается:** p2p-wallet, gaming, crypto-custody, telecom-prepaid.

---

## Settlement (расчёт)

Распределение средств из промежуточного (escrow) счёта конечному получателю.

**Маршрут:** escrow → получатель

```sql
-- Выплата мерчанту после подтверждения доставки
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:escrow_id, :merchant_id, 95, 'USD', 'order:settle:123', 'Merchant payout for order #123');
```

**Где встречается:** marketplace (выплата мерчанту), PSP (расчёт с мерчантом), donations (выплата бенефициару), travel-booking (оплата поставщику), remittance (выплата получателю).

---

## Fee (удержание комиссии)

Списание комиссии платформы в отдельный счёт.

**Маршрут:** источник → счёт комиссий

```sql
-- Удержание комиссии маркетплейса
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:escrow_id, :platform_fee_id, 5, 'USD', 'order:fee:123', 'Platform fee for order #123');
```

!!! tip "Settlement + Fee как составная операция"
    Расчёт по заказу на маркетплейсе — это два transfer:
    Settlement (95 USD на мерчанта) + Fee (5 USD на комиссию) = 100 USD из escrow.

**Где встречается:** marketplace, PSP, банк, exchange, crypto-custody, card-issuer, telecom, travel-booking, remittance, ad-network.

---

## Refund (возврат)

Отмена ранее проведённого transfer через reverse transfer.

**Маршрут:** обратный к исходному transfer

```sql
-- Возврат клиенту (reverse для исходной оплаты)
INSERT INTO openbill_transfers
  (reverse_transaction_id, from_account_id, to_account_id,
   amount_value, amount_currency, idempotency_key, details)
VALUES
  (:original_transfer_id, :escrow_id, :customer_id,
   100, 'USD', 'order:refund:123', 'Refund for order #123');
```

!!! warning "Policy и возвраты"
    Возврат возможен только если в policy для исходного маршрута `allow_reverse = true`.
    В marketplace: `Customer → Escrow` разрешает reverse, а `Escrow → Merchant` — нет.

**Где встречается:** marketplace, PSP, SaaS, donations, travel-booking.

---

## Reserve allocation (отчисление в резерв)

Перемещение части средств в резервный счёт для покрытия будущих обязательств.

**Маршрут:** рабочий счёт → резервный счёт

```sql
-- Отчисление в резерв на возвраты (SaaS-сценарий, адаптировано под marketplace)
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:escrow_id, :reserve_id, 10, 'USD', 'order:reserve:123', 'Refund reserve for order #123');
```

**Где встречается:** SaaS (резерв на возвраты), PSP (chargeback reserve), insurance (страховой резерв), card-issuer (chargeback reserve).

---

## Hold / Unhold (блокировка / разблокировка)

Резервирование средств на счёте без перемещения. Не создаёт transfers — использует таблицу holds.

```sql
-- Блокировка средств под заказ
INSERT INTO openbill_holds
  (account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:customer_id, 100, 'USD', 'hold:order:123', 'Hold for order #123');

-- Разблокировка после отмены заказа
INSERT INTO openbill_holds
  (account_id, amount_value, amount_currency, idempotency_key, hold_key, details)
VALUES
  (:customer_id, -100, 'USD', 'unhold:order:123', 'hold:order:123', 'Release hold for order #123');
```

**Где встречается:** marketplace (резерв под заказ), card-issuer (авторизация карты), exchange (резерв под ордер).

---

## Disbursement (выдача средств)

Выдача кредита, займа или иного обязательства — перемещение средств от кредитора к заёмщику.

**Маршрут:** фонд/кредитор → получатель

```sql
-- Выдача кредита покупателю (BNPL-сценарий, адаптировано под marketplace)
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:lender_fund_id, :customer_id, 100, 'USD', 'loan:disburse:789', 'BNPL disbursement for order #789');
```

**Где встречается:** credit-BNPL (выдача кредита), payroll (выплата зарплаты), affiliate-payouts (выплата партнёру).

---

## Repayment (погашение)

Возврат заёмных средств кредитору. Может включать несколько transfers: тело долга, проценты, штрафы.

**Маршрут:** заёмщик → кредитор (+ проценты, штрафы)

```sql
-- Погашение кредита: тело долга
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:customer_id, :principal_id, 25, 'USD', 'loan:repay:789:1', 'Loan #789 principal payment 1/4');
```

**Где встречается:** credit-BNPL (погашение кредита), банк (погашение займа).

---

## Reward (начисление вознаграждения)

Начисление бонусов, кешбэка или реферального вознаграждения.

**Маршрут:** пул вознаграждений → получатель

```sql
-- Начисление бонуса за покупку
INSERT INTO openbill_transfers
  (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (:reward_pool_id, :customer_id, 5, 'USD', 'bonus:order:123', 'Cashback for order #123');
```

**Где встречается:** loyalty-bonuses (кешбэк), referral-program (реферальное вознаграждение), gaming (награда за достижение).
