-- Industry: payment-system-psp
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -310001,
    (SELECT id FROM openbill_categories WHERE name = 'PayerSource'),
    'Payer source account'
  ),
  (
    -320001,
    (SELECT id FROM openbill_categories WHERE name = 'PSPClearing'),
    'PSP clearing account'
  ),
  (
    -330001,
    (SELECT id FROM openbill_categories WHERE name = 'MerchantSettlement'),
    'Merchant settlement account'
  ),
  (
    -340001,
    (SELECT id FROM openbill_categories WHERE name = 'PSPFee'),
    'PSP fee account'
  ),
  (
    -350001,
    (SELECT id FROM openbill_categories WHERE name = 'ChargebackReserve'),
    'Chargeback reserve account'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: payer funds PSP clearing
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-930001, -310001, -320001, 100, 'USD', 'demo:psp:pay:930001', 'Customer payment')
ON CONFLICT DO NOTHING;

-- Step 3: settlement to merchant
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-930002, -320001, -330001, 92, 'USD', 'demo:psp:payout:930002', 'Merchant settlement')
ON CONFLICT DO NOTHING;

-- Step 4: PSP fee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-930003, -320001, -340001, 5, 'USD', 'demo:psp:fee:930003', 'PSP fee')
ON CONFLICT DO NOTHING;

-- Step 5: reserve for potential chargebacks
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-930004, -320001, -350001, 3, 'USD', 'demo:psp:reserve:930004', 'Chargeback reserve')
ON CONFLICT DO NOTHING;

-- Step 6: blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-310001, -330001, 50, 'USD', 'demo:psp:blocked', 'Direct payer->merchant transfer is forbidden');
