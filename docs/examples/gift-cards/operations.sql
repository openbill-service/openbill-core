-- Industry: gift-cards
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -710001,
    (SELECT id FROM openbill_categories WHERE name = 'GiftLiability'),
    'Demo gift-cards account: GiftLiability'
  ),
  (
    -710002,
    (SELECT id FROM openbill_categories WHERE name = 'UserWallet'),
    'Demo gift-cards account: UserWallet'
  ),
  (
    -710003,
    (SELECT id FROM openbill_categories WHERE name = 'BreakageIncome'),
    'Demo gift-cards account: BreakageIncome'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer GiftLiability -> UserWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-710101, -710001, -710002, 1000, 'USD', 'demo:gift-cards:t01', 'GiftCards flow: GiftLiability -> UserWallet')
ON CONFLICT DO NOTHING;

-- Step 3: transfer GiftLiability -> BreakageIncome
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-710102, -710001, -710003, 100, 'USD', 'demo:gift-cards:t02', 'GiftCards flow: GiftLiability -> BreakageIncome')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-710002, -710001, 50, 'USD', 'demo:gift-cards:blocked', 'Blocked route example');
