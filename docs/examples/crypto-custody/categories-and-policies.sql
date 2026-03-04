-- Industry: crypto-custody
-- Status: ready
-- Purpose: create categories and transfer policies for this industry.

-- Disable default allow-all policy so routing restrictions are effective.
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';

INSERT INTO openbill_categories (name) VALUES
  ('OnchainHot'),
  ('UserCustody'),
  ('WithdrawalQueue'),
  ('ComplianceHold'),
  ('NetworkFee')
ON CONFLICT (name) DO NOTHING;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Custody: OnchainHot -> UserCustody',
  fc.id,
  tc.id,
  true
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'OnchainHot' AND tc.name = 'UserCustody'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Custody: UserCustody -> WithdrawalQueue',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'UserCustody' AND tc.name = 'WithdrawalQueue'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Custody: UserCustody -> ComplianceHold',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'UserCustody' AND tc.name = 'ComplianceHold'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Custody: UserCustody -> NetworkFee',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'UserCustody' AND tc.name = 'NetworkFee'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

