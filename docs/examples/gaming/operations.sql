-- Industry: gaming
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -910001,
    (SELECT id FROM openbill_categories WHERE name = 'TopupSource'),
    'Demo gaming account: TopupSource'
  ),
  (
    -910002,
    (SELECT id FROM openbill_categories WHERE name = 'PlayerWallet'),
    'Demo gaming account: PlayerWallet'
  ),
  (
    -910003,
    (SELECT id FROM openbill_categories WHERE name = 'RewardPool'),
    'Demo gaming account: RewardPool'
  ),
  (
    -910004,
    (SELECT id FROM openbill_categories WHERE name = 'GameSink'),
    'Demo gaming account: GameSink'
  ),
  (
    -910005,
    (SELECT id FROM openbill_categories WHERE name = 'PlatformFee'),
    'Demo gaming account: PlatformFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer TopupSource -> PlayerWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-910101, -910001, -910002, 1000, 'USD', 'demo:gaming:t01', 'Gaming flow: TopupSource -> PlayerWallet')
ON CONFLICT DO NOTHING;

-- Step 3: transfer RewardPool -> PlayerWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-910102, -910003, -910002, 100, 'USD', 'demo:gaming:t02', 'Gaming flow: RewardPool -> PlayerWallet')
ON CONFLICT DO NOTHING;

-- Step 4: transfer PlayerWallet -> GameSink
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-910103, -910002, -910004, 10, 'USD', 'demo:gaming:t03', 'Gaming flow: PlayerWallet -> GameSink')
ON CONFLICT DO NOTHING;

-- Step 5: transfer PlayerWallet -> PlatformFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-910104, -910002, -910005, 5, 'USD', 'demo:gaming:t04', 'Gaming flow: PlayerWallet -> PlatformFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-910199, -910101, -910002, -910001, 1000, 'USD', 'demo:gaming:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-910002, -910001, 50, 'USD', 'demo:gaming:blocked', 'Blocked route example');
