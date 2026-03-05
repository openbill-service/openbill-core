# Трансферы (`openbill_transfers`)

## Назначение

`openbill_transfers` фиксирует перевод между двумя счетами. Трансфер одновременно уменьшает баланс счёта-источника и увеличивает баланс счёта-получателя на одинаковую сумму.

## Схема

| Поле | Тип | Обязательно | По умолчанию | Описание |
| --- | --- | --- | --- | --- |
| `id` | `bigserial` | да | sequence | Идентификатор трансфера |
| `billing_date` | `date` | да | `current_date` | Бизнес-дата операции |
| `created_at` | `timestamp` | нет | `current_timestamp` | Время записи |
| `from_account_id` | `bigint` | да | - | Счёт-источник |
| `to_account_id` | `bigint` | да | - | Счёт-получатель |
| `amount` | `numeric(36,18)` | да | - | Сумма (> 0) |
| `currency` | `varchar(8)` | да | `USD` | Валюта трансфера |
| `idempotency_key` | `varchar(256)` | да | - | Уникальный ключ идемпотентности |
| `details` | `text` | да | - | Описание |
| `meta` | `jsonb` | да | `{}` | Метаданные |
| `reverse_transaction_id` | `bigint` | нет | `NULL` | Ссылка на исходный трансфер при возврате |

## Бизнес-правила

- `amount > 0`.
- `from_account_id <> to_account_id`.
- `idempotency_key` уникален.
- Валюта трансфера должна совпадать с валютой обоих счетов.
- Если `from_account.locked_at IS NOT NULL`, списание запрещено.
- Для `reverse_transaction_id` проверяется, что исходный трансфер существует и зеркален по направлению/сумме/валюте.
- Любой трансфер должен быть разрешён через `openbill_policies`.

## Права доступа

Для прикладной роли:

- Разрешены `SELECT` и `INSERT`
- Не разрешены `UPDATE` и `DELETE`

Для привилегированной роли `UPDATE`/`DELETE` доступны; при этом триггеры корректируют балансы и `transactions_count`.

## Типовые операции

### Провести обычный трансфер

```sql
INSERT INTO openbill_transfers (
  from_account_id,
  to_account_id,
  amount,
  currency,
  idempotency_key,
  details
)
VALUES (
  1001,
  2001,
  150.00,
  'USD',
  'payment:order:123',
  'Order payment'
)
RETURNING id;
```

### Сделать возврат (reverse transfer)

```sql
INSERT INTO openbill_transfers (
  reverse_transaction_id,
  from_account_id,
  to_account_id,
  amount,
  currency,
  idempotency_key,
  details
)
VALUES (
  555,
  2001,
  1001,
  150.00,
  'USD',
  'refund:order:123',
  'Refund for order 123'
);
```

## Типовые ошибки

- `No policy for this transfer` — отсутствует подходящая policy.
- `Account (from #...) has wrong currency` / `Account (to #...) has wrong currency`.
- `Account (from #...) is hold from ...` — счёт-источник заблокирован.
- `Not found reverse transfer with same accounts and amount` — неверный `reverse_transaction_id`.
- `duplicate key value violates unique constraint` по `idempotency_key`.

## Связанные сущности

- [Счета](accounts.md)
- [Категории](categories.md)
- [Policy](policy.md)
