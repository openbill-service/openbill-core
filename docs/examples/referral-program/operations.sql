-- Industry: referral-program
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1810001,
    (SELECT id FROM openbill_categories WHERE name = 'Revenue'),
    'Demo referral-program account: Revenue'
  ),
  (
    -1810002,
    (SELECT id FROM openbill_categories WHERE name = 'ReferralAccrual'),
    'Demo referral-program account: ReferralAccrual'
  ),
  (
    -1810003,
    (SELECT id FROM openbill_categories WHERE name = 'PartnerWallet'),
    'Demo referral-program account: PartnerWallet'
  ),
  (
    -1810004,
    (SELECT id FROM openbill_categories WHERE name = 'ReferralReversal'),
    'Demo referral-program account: ReferralReversal'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer Revenue -> ReferralAccrual
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1810101, -1810001, -1810002, 1000, 'USD', 'demo:referral-program:t01', 'Referral flow: Revenue -> ReferralAccrual')
ON CONFLICT DO NOTHING;

-- Step 3: transfer ReferralAccrual -> PartnerWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1810102, -1810002, -1810003, 100, 'USD', 'demo:referral-program:t02', 'Referral flow: ReferralAccrual -> PartnerWallet')
ON CONFLICT DO NOTHING;

-- Step 4: transfer ReferralAccrual -> ReferralReversal
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1810103, -1810002, -1810004, 10, 'USD', 'demo:referral-program:t03', 'Referral flow: ReferralAccrual -> ReferralReversal')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1810002, -1810001, 50, 'USD', 'demo:referral-program:blocked', 'Blocked route example');
