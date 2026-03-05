-- Industry: bank
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -210001,
    (SELECT id FROM openbill_categories WHERE name = 'ExternalClearing'),
    'External clearing'
  ),
  (
    -220001,
    (SELECT id FROM openbill_categories WHERE name = 'ClientAccount'),
    'Client current account'
  ),
  (
    -230001,
    (SELECT id FROM openbill_categories WHERE name = 'CardSettlement'),
    'Card settlement account'
  ),
  (
    -240001,
    (SELECT id FROM openbill_categories WHERE name = 'BankFeeIncome'),
    'Bank fee income'
  ),
  (
    -250001,
    (SELECT id FROM openbill_categories WHERE name = 'LoanRepayment'),
    'Loan repayment account'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: incoming transfer from external clearing to client
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-920001, -210001, -220001, 1000, 'USD', 'demo:bank:incoming:920001', 'Incoming transfer')
ON CONFLICT DO NOTHING;

-- Step 3: client card payment
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-920002, -220001, -230001, 120, 'USD', 'demo:bank:card:920002', 'Card purchase settlement')
ON CONFLICT DO NOTHING;

-- Step 4: monthly bank fee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-920003, -220001, -240001, 5, 'USD', 'demo:bank:fee:920003', 'Monthly account fee')
ON CONFLICT DO NOTHING;

-- Step 5: loan repayment
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-920004, -220001, -250001, 200, 'USD', 'demo:bank:loan:920004', 'Loan repayment')
ON CONFLICT DO NOTHING;

-- Step 6: blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-220001, -210001, 50, 'USD', 'demo:bank:blocked', 'Direct client payout to clearing is forbidden');
