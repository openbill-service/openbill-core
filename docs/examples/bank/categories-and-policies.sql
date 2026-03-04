-- Industry: bank
-- Status: ready
-- Purpose: create categories and transfer policies for this industry.

-- Disable default allow-all policy so routing restrictions are effective.
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';

INSERT INTO openbill_categories (name) VALUES
  ('ExternalClearing'),
  ('ClientAccount'),
  ('CardSettlement'),
  ('BankFeeIncome'),
  ('LoanRepayment')
ON CONFLICT (name) DO NOTHING;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Bank: ExternalClearing -> ClientAccount',
  fc.id,
  tc.id,
  true
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'ExternalClearing' AND tc.name = 'ClientAccount'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Bank: ClientAccount -> CardSettlement',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'ClientAccount' AND tc.name = 'CardSettlement'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Bank: ClientAccount -> BankFeeIncome',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'ClientAccount' AND tc.name = 'BankFeeIncome'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Bank: ClientAccount -> LoanRepayment',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'ClientAccount' AND tc.name = 'LoanRepayment'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;
