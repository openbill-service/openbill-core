-- Industry: exchange
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1010001,
    (SELECT id FROM openbill_categories WHERE name = 'User_USD'),
    'Demo exchange account: User_USD'
  ),
  (
    -1010002,
    (SELECT id FROM openbill_categories WHERE name = 'User_BTC'),
    'Demo exchange account: User_BTC'
  ),
  (
    -1010003,
    (SELECT id FROM openbill_categories WHERE name = 'ExchangeVault_USD'),
    'Demo exchange account: ExchangeVault_USD'
  ),
  (
    -1010004,
    (SELECT id FROM openbill_categories WHERE name = 'ExchangeVault_BTC'),
    'Demo exchange account: ExchangeVault_BTC'
  ),
  (
    -1010005,
    (SELECT id FROM openbill_categories WHERE name = 'Fee_USD'),
    'Demo exchange account: Fee_USD'
  ),
  (
    -1010006,
    (SELECT id FROM openbill_categories WHERE name = 'Fee_BTC'),
    'Demo exchange account: Fee_BTC'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer User_USD -> ExchangeVault_USD
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1010101, -1010001, -1010003, 1000, 'USD', 'demo:exchange:t01', 'Exchange flow: User_USD -> ExchangeVault_USD')
ON CONFLICT DO NOTHING;

-- Step 3: transfer ExchangeVault_BTC -> User_BTC
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1010102, -1010004, -1010002, 100, 'USD', 'demo:exchange:t02', 'Exchange flow: ExchangeVault_BTC -> User_BTC')
ON CONFLICT DO NOTHING;

-- Step 4: transfer User_USD -> Fee_USD
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1010103, -1010001, -1010005, 10, 'USD', 'demo:exchange:t03', 'Exchange flow: User_USD -> Fee_USD')
ON CONFLICT DO NOTHING;

-- Step 5: transfer User_BTC -> Fee_BTC
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1010104, -1010002, -1010006, 5, 'USD', 'demo:exchange:t04', 'Exchange flow: User_BTC -> Fee_BTC')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount, currency, idempotency_key, details)
VALUES
  (-1010199, -1010101, -1010003, -1010001, 1000, 'USD', 'demo:exchange:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount, currency, idempotency_key, details)
-- VALUES
--   (-1010003, -1010001, 50, 'USD', 'demo:exchange:blocked', 'Blocked route example');
