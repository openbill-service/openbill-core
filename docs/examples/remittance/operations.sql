-- Industry: remittance
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1610001,
    (SELECT id FROM openbill_categories WHERE name = 'SenderSource'),
    'Demo remittance account: SenderSource'
  ),
  (
    -1610002,
    (SELECT id FROM openbill_categories WHERE name = 'RemitEscrow'),
    'Demo remittance account: RemitEscrow'
  ),
  (
    -1610003,
    (SELECT id FROM openbill_categories WHERE name = 'RecipientPayout'),
    'Demo remittance account: RecipientPayout'
  ),
  (
    -1610004,
    (SELECT id FROM openbill_categories WHERE name = 'FXFee'),
    'Demo remittance account: FXFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer SenderSource -> RemitEscrow
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1610101, -1610001, -1610002, 1000, 'USD', 'demo:remittance:t01', 'Remittance flow: SenderSource -> RemitEscrow')
ON CONFLICT DO NOTHING;

-- Step 3: transfer RemitEscrow -> RecipientPayout
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1610102, -1610002, -1610003, 100, 'USD', 'demo:remittance:t02', 'Remittance flow: RemitEscrow -> RecipientPayout')
ON CONFLICT DO NOTHING;

-- Step 4: transfer RemitEscrow -> FXFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1610103, -1610002, -1610004, 10, 'USD', 'demo:remittance:t03', 'Remittance flow: RemitEscrow -> FXFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1610199, -1610101, -1610002, -1610001, 1000, 'USD', 'demo:remittance:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1610002, -1610001, 50, 'USD', 'demo:remittance:blocked', 'Blocked route example');
