-- Industry: payroll
-- Status: ready
-- Purpose: demonstrate typical business operations.

-- Step 1: create demo accounts (negative IDs avoid clashes with regular sequences)
INSERT INTO openbill_accounts (id, category_id, details)
VALUES
  (
    -1310001,
    (SELECT id FROM openbill_categories WHERE name = 'EmployerFunding'),
    'Demo payroll account: EmployerFunding'
  ),
  (
    -1310002,
    (SELECT id FROM openbill_categories WHERE name = 'PayrollClearing'),
    'Demo payroll account: PayrollClearing'
  ),
  (
    -1310003,
    (SELECT id FROM openbill_categories WHERE name = 'EmployeeAccount'),
    'Demo payroll account: EmployeeAccount'
  ),
  (
    -1310004,
    (SELECT id FROM openbill_categories WHERE name = 'TaxAccount'),
    'Demo payroll account: TaxAccount'
  )
ON CONFLICT (id) DO NOTHING;

-- Step 2: transfer EmployerFunding -> PayrollClearing
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1310101, -1310001, -1310002, 1000, 'USD', 'demo:payroll:t01', 'Payroll flow: EmployerFunding -> PayrollClearing')
ON CONFLICT DO NOTHING;

-- Step 3: transfer PayrollClearing -> EmployeeAccount
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1310102, -1310002, -1310003, 100, 'USD', 'demo:payroll:t02', 'Payroll flow: PayrollClearing -> EmployeeAccount')
ON CONFLICT DO NOTHING;

-- Step 4: transfer PayrollClearing -> TaxAccount
INSERT INTO openbill_transfers
  (id, from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
VALUES
  (-1310103, -1310002, -1310004, 10, 'USD', 'demo:payroll:t03', 'Payroll flow: PayrollClearing -> TaxAccount')
ON CONFLICT DO NOTHING;

-- Blocked example (should fail with: No policy for this transfer)
-- INSERT INTO openbill_transfers
--   (from_account_id, to_account_id, amount_value, amount_currency, idempotency_key, details)
-- VALUES
--   (-1310002, -1310001, 50, 'USD', 'demo:payroll:blocked', 'Blocked route example');
