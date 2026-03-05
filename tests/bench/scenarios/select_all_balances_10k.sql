-- Benchmark: read balances for a fixed range of 10,000 accounts
SELECT id, balance, currency
FROM openbill_accounts
WHERE id >= :account_base::bigint
  AND id < (:account_base::bigint + :account_count::bigint);
