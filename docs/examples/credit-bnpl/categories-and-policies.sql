-- Industry: credit-bnpl
-- Status: ready
-- Purpose: create categories and transfer policies for this industry.

-- Disable default allow-all policy so routing restrictions are effective.
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';

INSERT INTO openbill_categories (name) VALUES
  ('LenderFund'),
  ('BorrowerAccount'),
  ('PrincipalRepayment'),
  ('InterestIncome'),
  ('PenaltyIncome')
ON CONFLICT (name) DO NOTHING;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Credit: LenderFund -> BorrowerAccount',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'LenderFund' AND tc.name = 'BorrowerAccount'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Credit: BorrowerAccount -> PrincipalRepayment',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'BorrowerAccount' AND tc.name = 'PrincipalRepayment'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Credit: BorrowerAccount -> InterestIncome',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'BorrowerAccount' AND tc.name = 'InterestIncome'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Credit: BorrowerAccount -> PenaltyIncome',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'BorrowerAccount' AND tc.name = 'PenaltyIncome'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

