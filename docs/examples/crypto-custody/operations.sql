-- Industry: crypto-custody
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1110001,
    (SELECT id FROM openbill_categories WHERE name = 'OnchainHot'),
    'Demo crypto-custody account: OnchainHot'
  ),
  (
    -1110002,
    (SELECT id FROM openbill_categories WHERE name = 'UserCustody'),
    'Demo crypto-custody account: UserCustody'
  ),
  (
    -1110003,
    (SELECT id FROM openbill_categories WHERE name = 'WithdrawalQueue'),
    'Demo crypto-custody account: WithdrawalQueue'
  ),
  (
    -1110004,
    (SELECT id FROM openbill_categories WHERE name = 'ComplianceHold'),
    'Demo crypto-custody account: ComplianceHold'
  ),
  (
    -1110005,
    (SELECT id FROM openbill_categories WHERE name = 'NetworkFee'),
    'Demo crypto-custody account: NetworkFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer OnchainHot -> UserCustody
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1110101, -1110001, -1110002, 1000, 'USD', 'demo:crypto-custody:t01', 'Custody flow: OnchainHot -> UserCustody')
ON CONFLICT DO NOTHING;

-- Step 3: transfer UserCustody -> WithdrawalQueue
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1110102, -1110002, -1110003, 100, 'USD', 'demo:crypto-custody:t02', 'Custody flow: UserCustody -> WithdrawalQueue')
ON CONFLICT DO NOTHING;

-- Step 4: transfer UserCustody -> ComplianceHold
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1110103, -1110002, -1110004, 10, 'USD', 'demo:crypto-custody:t03', 'Custody flow: UserCustody -> ComplianceHold')
ON CONFLICT DO NOTHING;

-- Step 5: transfer UserCustody -> NetworkFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1110104, -1110002, -1110005, 5, 'USD', 'demo:crypto-custody:t04', 'Custody flow: UserCustody -> NetworkFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1110199, -1110101, -1110002, -1110001, 1000, 'USD', 'demo:crypto-custody:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-1110002, -1110001, 50, 'USD', 'demo:crypto-custody:blocked', 'Blocked route example');
