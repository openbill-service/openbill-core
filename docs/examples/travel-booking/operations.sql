-- Industry: travel-booking
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1710001,
    (SELECT id FROM openbill_categories WHERE name = 'Traveler'),
    'Demo travel-booking account: Traveler'
  ),
  (
    -1710002,
    (SELECT id FROM openbill_categories WHERE name = 'BookingEscrow'),
    'Demo travel-booking account: BookingEscrow'
  ),
  (
    -1710003,
    (SELECT id FROM openbill_categories WHERE name = 'SupplierPayout'),
    'Demo travel-booking account: SupplierPayout'
  ),
  (
    -1710004,
    (SELECT id FROM openbill_categories WHERE name = 'OTAFee'),
    'Demo travel-booking account: OTAFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer Traveler -> BookingEscrow
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1710101, -1710001, -1710002, 1000, 'USD', 'demo:travel-booking:t01', 'Travel flow: Traveler -> BookingEscrow')
ON CONFLICT DO NOTHING;

-- Step 3: transfer BookingEscrow -> SupplierPayout
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1710102, -1710002, -1710003, 100, 'USD', 'demo:travel-booking:t02', 'Travel flow: BookingEscrow -> SupplierPayout')
ON CONFLICT DO NOTHING;

-- Step 4: transfer BookingEscrow -> OTAFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1710103, -1710002, -1710004, 10, 'USD', 'demo:travel-booking:t03', 'Travel flow: BookingEscrow -> OTAFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1710199, -1710101, -1710002, -1710001, 1000, 'USD', 'demo:travel-booking:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1710002, -1710001, 50, 'USD', 'demo:travel-booking:blocked', 'Blocked route example');
