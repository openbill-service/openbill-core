\set amount random(1, :max_amount)
\set direction random(1, 2)

INSERT INTO openbill_transfers (
    amount,
    currency,
    from_account_id,
    to_account_id,
    idempotency_key,
    details
)
VALUES
    (
        :amount::numeric(36, 18),
        'USD',
        CASE WHEN :direction = 1 THEN :hot_from::bigint ELSE :hot_to::bigint END,
        CASE WHEN :direction = 1 THEN :hot_to::bigint ELSE :hot_from::bigint END,
        md5(random()::text || clock_timestamp()::text || :client_id::text),
        'bench hot_pair'
    );
