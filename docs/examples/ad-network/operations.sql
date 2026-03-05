-- Industry: ad-network
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1910001,
    (SELECT id FROM openbill_categories WHERE name = 'AdvertiserDeposit'),
    'Demo ad-network account: AdvertiserDeposit'
  ),
  (
    -1910002,
    (SELECT id FROM openbill_categories WHERE name = 'CampaignEscrow'),
    'Demo ad-network account: CampaignEscrow'
  ),
  (
    -1910003,
    (SELECT id FROM openbill_categories WHERE name = 'PublisherPayout'),
    'Demo ad-network account: PublisherPayout'
  ),
  (
    -1910004,
    (SELECT id FROM openbill_categories WHERE name = 'NetworkFee'),
    'Demo ad-network account: NetworkFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer AdvertiserDeposit -> CampaignEscrow
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1910101, -1910001, -1910002, 1000, 'USD', 'demo:ad-network:t01', 'AdNetwork flow: AdvertiserDeposit -> CampaignEscrow')
ON CONFLICT DO NOTHING;

-- Step 3: transfer CampaignEscrow -> PublisherPayout
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1910102, -1910002, -1910003, 100, 'USD', 'demo:ad-network:t02', 'AdNetwork flow: CampaignEscrow -> PublisherPayout')
ON CONFLICT DO NOTHING;

-- Step 4: transfer CampaignEscrow -> NetworkFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1910103, -1910002, -1910004, 10, 'USD', 'demo:ad-network:t03', 'AdNetwork flow: CampaignEscrow -> NetworkFee')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1910002, -1910001, 50, 'USD', 'demo:ad-network:blocked', 'Blocked route example');
