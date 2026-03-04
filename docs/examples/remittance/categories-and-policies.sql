-- Industry: remittance
-- Status: ready
-- Purpose: create categories and transfer policies for this industry.

-- Disable default allow-all policy so routing restrictions are effective.
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';

INSERT INTO openbill_categories (name) VALUES
  ('SenderSource'),
  ('RemitEscrow'),
  ('RecipientPayout'),
  ('FXFee')
ON CONFLICT (name) DO NOTHING;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Remittance: SenderSource -> RemitEscrow',
  fc.id,
  tc.id,
  true
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'SenderSource' AND tc.name = 'RemitEscrow'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Remittance: RemitEscrow -> RecipientPayout',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'RemitEscrow' AND tc.name = 'RecipientPayout'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Remittance: RemitEscrow -> FXFee',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'RemitEscrow' AND tc.name = 'FXFee'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

