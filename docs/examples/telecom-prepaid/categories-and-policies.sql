-- Industry: telecom-prepaid
-- Status: ready
-- Purpose: create categories and transfer policies for this industry.

-- Disable default allow-all policy so routing restrictions are effective.
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';

INSERT INTO openbill_categories (name) VALUES
  ('TopupSource'),
  ('SubscriberWallet'),
  ('ServiceConsumption'),
  ('TelecomFee')
ON CONFLICT (name) DO NOTHING;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Telecom: TopupSource -> SubscriberWallet',
  fc.id,
  tc.id,
  true
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'TopupSource' AND tc.name = 'SubscriberWallet'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Telecom: SubscriberWallet -> ServiceConsumption',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'SubscriberWallet' AND tc.name = 'ServiceConsumption'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT
  'Telecom: SubscriberWallet -> TelecomFee',
  fc.id,
  tc.id,
  false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'SubscriberWallet' AND tc.name = 'TelecomFee'
ON CONFLICT (name) DO UPDATE
SET from_category_id = EXCLUDED.from_category_id,
    to_category_id = EXCLUDED.to_category_id,
    allow_reverse = EXCLUDED.allow_reverse;

