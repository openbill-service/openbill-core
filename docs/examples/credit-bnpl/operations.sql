-- Industry: credit-bnpl
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1410001,
    (SELECT id FROM openbill_categories WHERE name = 'LenderFund'),
    'Demo credit-bnpl account: LenderFund'
  ),
  (
    -1410002,
    (SELECT id FROM openbill_categories WHERE name = 'BorrowerAccount'),
    'Demo credit-bnpl account: BorrowerAccount'
  ),
  (
    -1410003,
    (SELECT id FROM openbill_categories WHERE name = 'PrincipalRepayment'),
    'Demo credit-bnpl account: PrincipalRepayment'
  ),
  (
    -1410004,
    (SELECT id FROM openbill_categories WHERE name = 'InterestIncome'),
    'Demo credit-bnpl account: InterestIncome'
  ),
  (
    -1410005,
    (SELECT id FROM openbill_categories WHERE name = 'PenaltyIncome'),
    'Demo credit-bnpl account: PenaltyIncome'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer LenderFund -> BorrowerAccount
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1410101, -1410001, -1410002, 1000, 'USD', 'demo:credit-bnpl:t01', 'Credit flow: LenderFund -> BorrowerAccount')
ON CONFLICT DO NOTHING;

-- Step 3: transfer BorrowerAccount -> PrincipalRepayment
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1410102, -1410002, -1410003, 100, 'USD', 'demo:credit-bnpl:t02', 'Credit flow: BorrowerAccount -> PrincipalRepayment')
ON CONFLICT DO NOTHING;

-- Step 4: transfer BorrowerAccount -> InterestIncome
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1410103, -1410002, -1410004, 10, 'USD', 'demo:credit-bnpl:t03', 'Credit flow: BorrowerAccount -> InterestIncome')
ON CONFLICT DO NOTHING;

-- Step 5: transfer BorrowerAccount -> PenaltyIncome
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1410104, -1410002, -1410005, 5, 'USD', 'demo:credit-bnpl:t04', 'Credit flow: BorrowerAccount -> PenaltyIncome')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-1410002, -1410001, 50, 'USD', 'demo:credit-bnpl:blocked', 'Blocked route example');
