\set amount random(1, :max_amount)

WITH pick AS (
    SELECT
        :account_base::bigint AS account_base,
        :account_count::int AS account_count,
        floor(random() * :account_count)::int AS from_off,
        floor(random() * (:account_count - 1) + 1)::int AS shift
)

INSERT INTO openbill_transfers (
    amount_value,
    amount_currency,
    from_account_id,
    to_account_id,
    idempotency_key,
    details
)
SELECT
    :amount::numeric(36, 18),
    'USD',
    account_base + from_off,
    account_base + ((from_off + shift) % account_count),
    md5(random()::text || clock_timestamp()::text || :client_id::text),
    'bench account_pool'
FROM pick;
