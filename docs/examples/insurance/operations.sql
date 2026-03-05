-- Industry: insurance
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1210001,
    (SELECT id FROM openbill_categories WHERE name = 'PremiumInflow'),
    'Demo insurance account: PremiumInflow'
  ),
  (
    -1210002,
    (SELECT id FROM openbill_categories WHERE name = 'InsuranceReserve'),
    'Demo insurance account: InsuranceReserve'
  ),
  (
    -1210003,
    (SELECT id FROM openbill_categories WHERE name = 'ClaimsPayout'),
    'Demo insurance account: ClaimsPayout'
  ),
  (
    -1210004,
    (SELECT id FROM openbill_categories WHERE name = 'InsuranceFee'),
    'Demo insurance account: InsuranceFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer PremiumInflow -> InsuranceReserve
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1210101, -1210001, -1210002, 1000, 'USD', 'demo:insurance:t01', 'Insurance flow: PremiumInflow -> InsuranceReserve')
ON CONFLICT DO NOTHING;

-- Step 3: transfer InsuranceReserve -> ClaimsPayout
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1210102, -1210002, -1210003, 100, 'USD', 'demo:insurance:t02', 'Insurance flow: InsuranceReserve -> ClaimsPayout')
ON CONFLICT DO NOTHING;

-- Step 4: transfer InsuranceReserve -> InsuranceFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1210103, -1210002, -1210004, 10, 'USD', 'demo:insurance:t03', 'Insurance flow: InsuranceReserve -> InsuranceFee')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1210002, -1210001, 50, 'USD', 'demo:insurance:blocked', 'Blocked route example');
