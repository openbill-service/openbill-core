-- Industry: affiliate-payouts
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -810001,
    (SELECT id FROM openbill_categories WHERE name = 'Revenue'),
    'Demo affiliate-payouts account: Revenue'
  ),
  (
    -810002,
    (SELECT id FROM openbill_categories WHERE name = 'AffiliatePayable'),
    'Demo affiliate-payouts account: AffiliatePayable'
  ),
  (
    -810003,
    (SELECT id FROM openbill_categories WHERE name = 'AffiliateWallet'),
    'Demo affiliate-payouts account: AffiliateWallet'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer Revenue -> AffiliatePayable
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-810101, -810001, -810002, 1000, 'USD', 'demo:affiliate-payouts:t01', 'Affiliate flow: Revenue -> AffiliatePayable')
ON CONFLICT DO NOTHING;

-- Step 3: transfer AffiliatePayable -> AffiliateWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-810102, -810002, -810003, 100, 'USD', 'demo:affiliate-payouts:t02', 'Affiliate flow: AffiliatePayable -> AffiliateWallet')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-810002, -810001, 50, 'USD', 'demo:affiliate-payouts:blocked', 'Blocked route example');
