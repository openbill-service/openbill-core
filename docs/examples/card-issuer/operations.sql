-- Industry: card-issuer
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1510001,
    (SELECT id FROM openbill_categories WHERE name = 'CardholderAccount'),
    'Demo card-issuer account: CardholderAccount'
  ),
  (
    -1510002,
    (SELECT id FROM openbill_categories WHERE name = 'CardAuthHold'),
    'Demo card-issuer account: CardAuthHold'
  ),
  (
    -1510003,
    (SELECT id FROM openbill_categories WHERE name = 'MerchantSettlement'),
    'Demo card-issuer account: MerchantSettlement'
  ),
  (
    -1510004,
    (SELECT id FROM openbill_categories WHERE name = 'CardFeeIncome'),
    'Demo card-issuer account: CardFeeIncome'
  ),
  (
    -1510005,
    (SELECT id FROM openbill_categories WHERE name = 'ChargebackReserve'),
    'Demo card-issuer account: ChargebackReserve'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer CardholderAccount -> CardAuthHold
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1510101, -1510001, -1510002, 1000, 'USD', 'demo:card-issuer:t01', 'CardIssuer flow: CardholderAccount -> CardAuthHold')
ON CONFLICT DO NOTHING;

-- Step 3: transfer CardAuthHold -> MerchantSettlement
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1510102, -1510002, -1510003, 100, 'USD', 'demo:card-issuer:t02', 'CardIssuer flow: CardAuthHold -> MerchantSettlement')
ON CONFLICT DO NOTHING;

-- Step 4: transfer CardholderAccount -> CardFeeIncome
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1510103, -1510001, -1510004, 10, 'USD', 'demo:card-issuer:t03', 'CardIssuer flow: CardholderAccount -> CardFeeIncome')
ON CONFLICT DO NOTHING;

-- Step 5: transfer CardAuthHold -> ChargebackReserve
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1510104, -1510002, -1510005, 5, 'USD', 'demo:card-issuer:t04', 'CardIssuer flow: CardAuthHold -> ChargebackReserve')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1510002, -1510001, 50, 'USD', 'demo:card-issuer:blocked', 'Blocked route example');
