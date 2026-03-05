-- Industry: donations
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -610001,
    (SELECT id FROM openbill_categories WHERE name = 'Donor'),
    'Demo donations account: Donor'
  ),
  (
    -610002,
    (SELECT id FROM openbill_categories WHERE name = 'CampaignEscrow'),
    'Demo donations account: CampaignEscrow'
  ),
  (
    -610003,
    (SELECT id FROM openbill_categories WHERE name = 'Beneficiary'),
    'Demo donations account: Beneficiary'
  ),
  (
    -610004,
    (SELECT id FROM openbill_categories WHERE name = 'PlatformFee'),
    'Demo donations account: PlatformFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer Donor -> CampaignEscrow
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-610101, -610001, -610002, 1000, 'USD', 'demo:donations:t01', 'Donations flow: Donor -> CampaignEscrow')
ON CONFLICT DO NOTHING;

-- Step 3: transfer CampaignEscrow -> Beneficiary
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-610102, -610002, -610003, 100, 'USD', 'demo:donations:t02', 'Donations flow: CampaignEscrow -> Beneficiary')
ON CONFLICT DO NOTHING;

-- Step 4: transfer CampaignEscrow -> PlatformFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-610103, -610002, -610004, 10, 'USD', 'demo:donations:t03', 'Donations flow: CampaignEscrow -> PlatformFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-610199, -610101, -610002, -610001, 1000, 'USD', 'demo:donations:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-610002, -610001, 50, 'USD', 'demo:donations:blocked', 'Blocked route example');
