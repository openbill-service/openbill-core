-- Industry: p2p-wallet
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -510001,
    (SELECT id FROM openbill_categories WHERE name = 'UserWallet'),
    'Demo p2p-wallet account: UserWallet'
  ),
  (
    -510002,
    (SELECT id FROM openbill_categories WHERE name = 'TopupSource'),
    'Demo p2p-wallet account: TopupSource'
  ),
  (
    -510003,
    (SELECT id FROM openbill_categories WHERE name = 'WithdrawalSink'),
    'Demo p2p-wallet account: WithdrawalSink'
  ),
  (
    -510004,
    (SELECT id FROM openbill_categories WHERE name = 'PlatformFee'),
    'Demo p2p-wallet account: PlatformFee'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer TopupSource -> UserWallet
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-510101, -510002, -510001, 1000, 'USD', 'demo:p2p-wallet:t01', 'P2P flow: TopupSource -> UserWallet')
ON CONFLICT DO NOTHING;

-- Step 3: transfer UserWallet -> WithdrawalSink
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-510102, -510001, -510003, 100, 'USD', 'demo:p2p-wallet:t02', 'P2P flow: UserWallet -> WithdrawalSink')
ON CONFLICT DO NOTHING;

-- Step 4: transfer UserWallet -> PlatformFee
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-510103, -510001, -510004, 10, 'USD', 'demo:p2p-wallet:t03', 'P2P flow: UserWallet -> PlatformFee')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-510199, -510101, -510001, -510002, 1000, 'USD', 'demo:p2p-wallet:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-510001, -510002, 50, 'USD', 'demo:p2p-wallet:blocked', 'Blocked route example');
