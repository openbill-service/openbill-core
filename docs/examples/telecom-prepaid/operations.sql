-- Industry: telecom-prepaid
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -2010001,
    (SELECT id FROM openbill_categories WHERE name = 'TopupSource'),
    'Demo telecom-prepaid account: TopupSource'
  ),
  (
    -2010002,
    (SELECT id FROM openbill_categories WHERE name = 'SubscriberWallet'),
    'Demo telecom-prepaid account: SubscriberWallet'
  ),
  (
    -2010003,
    (SELECT id FROM openbill_categories WHERE name = 'ServiceConsumption'),
    'Demo telecom-prepaid account: ServiceConsumption'
  ),
  (
    -2010004,
    (SELECT id FROM openbill_categories WHERE name = 'TelecomFee'),
    'Demo telecom-prepaid account: TelecomFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer TopupSource -> SubscriberWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-2010101, -2010001, -2010002, 1000, 'USD', 'demo:telecom-prepaid:t01', 'Telecom flow: TopupSource -> SubscriberWallet')
ON CONFLICT DO NOTHING;

-- Step 3: transfer SubscriberWallet -> ServiceConsumption
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-2010102, -2010002, -2010003, 100, 'USD', 'demo:telecom-prepaid:t02', 'Telecom flow: SubscriberWallet -> ServiceConsumption')
ON CONFLICT DO NOTHING;

-- Step 4: transfer SubscriberWallet -> TelecomFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-2010103, -2010002, -2010004, 10, 'USD', 'demo:telecom-prepaid:t03', 'Telecom flow: SubscriberWallet -> TelecomFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-2010199, -2010101, -2010002, -2010001, 1000, 'USD', 'demo:telecom-prepaid:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-2010002, -2010001, 50, 'USD', 'demo:telecom-prepaid:blocked', 'Blocked route example');
