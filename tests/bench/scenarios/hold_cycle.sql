\set amount random(10, :max_amount)
\set half_amount :amount / 2
\set hold_key random(1, 2000000000)

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
        :hot_from::bigint,
        :hot_to::bigint,
        md5(random()::text || clock_timestamp()::text || :client_id::text),
        'bench hold_cycle transfer_1'
    );

INSERT INTO openbill_holds (
    account_id,
    amount,
    currency,
    idempotency_key,
    details
)
VALUES
    (
        :hot_to::bigint,
        :half_amount::numeric(36, 18),
        'USD',
        :hold_key::text,
        'bench hold_cycle hold'
    );

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
        :half_amount::numeric(36, 18),
        'USD',
        :hot_to::bigint,
        :hot_from::bigint,
        md5(random()::text || clock_timestamp()::text || :client_id::text),
        'bench hold_cycle transfer_2'
    );

INSERT INTO openbill_holds (
    account_id,
    amount,
    currency,
    idempotency_key,
    hold_key,
    details
)
VALUES
    (
        :hot_to::bigint,
        -:half_amount::numeric(36, 18),
        'USD',
        md5(random()::text || clock_timestamp()::text || :client_id::text),
        :hold_key::text,
        'bench hold_cycle unhold'
    );

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
        :half_amount::numeric(36, 18),
        'USD',
        :hot_to::bigint,
        :hot_from::bigint,
        md5(random()::text || clock_timestamp()::text || :client_id::text),
        'bench hold_cycle transfer_3'
    );
