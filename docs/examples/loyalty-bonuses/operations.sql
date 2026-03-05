-- Industry: loyalty-bonuses
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -2110001,
    (SELECT id FROM openbill_categories WHERE name = 'BonusLiability'),
    'Demo loyalty-bonuses account: BonusLiability'
  ),
  (
    -2110002,
    (SELECT id FROM openbill_categories WHERE name = 'UserBonusWallet'),
    'Demo loyalty-bonuses account: UserBonusWallet'
  ),
  (
    -2110003,
    (SELECT id FROM openbill_categories WHERE name = 'RedemptionSink'),
    'Demo loyalty-bonuses account: RedemptionSink'
  ),
  (
    -2110004,
    (SELECT id FROM openbill_categories WHERE name = 'ExpiredBonusIncome'),
    'Demo loyalty-bonuses account: ExpiredBonusIncome'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer BonusLiability -> UserBonusWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-2110101, -2110001, -2110002, 1000, 'USD', 'demo:loyalty-bonuses:t01', 'Loyalty flow: BonusLiability -> UserBonusWallet')
ON CONFLICT DO NOTHING;

-- Step 3: transfer UserBonusWallet -> RedemptionSink
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-2110102, -2110002, -2110003, 100, 'USD', 'demo:loyalty-bonuses:t02', 'Loyalty flow: UserBonusWallet -> RedemptionSink')
ON CONFLICT DO NOTHING;

-- Step 4: transfer BonusLiability -> ExpiredBonusIncome
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-2110103, -2110001, -2110004, 10, 'USD', 'demo:loyalty-bonuses:t03', 'Loyalty flow: BonusLiability -> ExpiredBonusIncome')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-2110002, -2110001, 50, 'USD', 'demo:loyalty-bonuses:blocked', 'Blocked route example');
