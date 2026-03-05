-- Industry: marketplace
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -110001,
    (SELECT id FROM openbill_categories WHERE name = 'Customer'),
    'Demo customer wallet'
  ),
  (
    -120001,
    (SELECT id FROM openbill_categories WHERE name = 'Escrow'),
    'Demo escrow account'
  ),
  (
    -130001,
    (SELECT id FROM openbill_categories WHERE name = 'Merchant'),
    'Demo merchant settlement'
  ),
  (
    -140001,
    (SELECT id FROM openbill_categories WHERE name = 'PlatformFee'),
    'Demo marketplace fee account'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: customer pays order into escrow
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-910001, -110001, -120001, 100, 'USD', 'demo:marketplace:pay:910001', 'Order payment')
ON CONFLICT DO NOTHING;

-- Step 3: escrow pays merchant
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-910002, -120001, -130001, 95, 'USD', 'demo:marketplace:payout:910002', 'Merchant payout')
ON CONFLICT DO NOTHING;

-- Step 4: escrow records platform fee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-910003, -120001, -140001, 5, 'USD', 'demo:marketplace:fee:910003', 'Platform fee')
ON CONFLICT DO NOTHING;

-- Step 5: refund via reverse transfer (allowed by policy with allow_reverse=true)
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-910004, -910001, -120001, -110001, 100, 'USD', 'demo:marketplace:refund:910004', 'Refund to customer')
ON CONFLICT DO NOTHING;

-- Step 6: blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-110001, -130001, 50, 'USD', 'demo:marketplace:blocked', 'Direct customer->merchant is forbidden');
