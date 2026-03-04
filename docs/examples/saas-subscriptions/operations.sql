-- Industry: saas-subscriptions
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -410001,
    (SELECT id FROM openbill_categories WHERE name = 'Customer'),
    'Demo saas-subscriptions account: Customer'
  ),
  (
    -410002,
    (SELECT id FROM openbill_categories WHERE name = 'Revenue'),
    'Demo saas-subscriptions account: Revenue'
  ),
  (
    -410003,
    (SELECT id FROM openbill_categories WHERE name = 'Tax'),
    'Demo saas-subscriptions account: Tax'
  ),
  (
    -410004,
    (SELECT id FROM openbill_categories WHERE name = 'RefundReserve'),
    'Demo saas-subscriptions account: RefundReserve'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer Customer -> Revenue
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-410101, -410001, -410002, 1000, 'USD', 'demo:saas-subscriptions:t01', 'SaaS flow: Customer -> Revenue')
ON CONFLICT DO NOTHING;

-- Step 3: transfer Revenue -> Tax
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-410102, -410002, -410003, 100, 'USD', 'demo:saas-subscriptions:t02', 'SaaS flow: Revenue -> Tax')
ON CONFLICT DO NOTHING;

-- Step 4: transfer Revenue -> RefundReserve
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-410103, -410002, -410004, 10, 'USD', 'demo:saas-subscriptions:t03', 'SaaS flow: Revenue -> RefundReserve')
ON CONFLICT DO NOTHING;

-- Reverse example for allow_reverse=true policy
INSERT INTO openbill_transfers
  (id, reverse_transaction_id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-410199, -410101, -410002, -410001, 1000, 'USD', 'demo:saas-subscriptions:reverse', 'Reverse transfer example')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-410002, -410001, 50, 'USD', 'demo:saas-subscriptions:blocked', 'Blocked route example');
