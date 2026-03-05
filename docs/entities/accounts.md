# Счета (`openbill_accounts`)

## Назначение

`openbill_accounts` хранит текущее состояние счёта: баланс, валюту, категорию, тип счёта и технические атрибуты (`hold_amount`, `transactions_count`, `locked_at`).

## Схема

| Поле | Тип | Обязательно | По умолчанию | Описание |
| --- | --- | --- | --- | --- |
| `id` | `bigserial` | да | sequence | Идентификатор счёта |
| `category_id` | `bigint` | да | - | Ссылка на `openbill_categories.id` |
| `balance` | `numeric(36,18)` | да | `0` | Текущий баланс |
| `currency` | `varchar(8)` | да | `USD` | Валюта счёта |
| `details` | `text` | нет | `NULL` | Описание |
| `transactions_count` | `integer` | да | `0` | Количество трансферов по счёту |
| `meta` | `jsonb` | да | `{}` | Произвольные метаданные |
| `hold_amount` | `numeric(36,18)` | да | `0` | Сумма в удержании (hold) |
| `locked_at` | `timestamp` | нет | `NULL` | Блокировка списаний со счёта |
| `kind` | `account_kind` | да | `any` | Ограничение на знак баланса |
| `created_at` | `timestamp` | нет | `current_timestamp` | Время создания |
| `updated_at` | `timestamp` | нет | `current_timestamp` | Время изменения |

## Ограничения и инварианты

- `category_id` обязан ссылаться на существующую категорию.
- `kind = positive` требует `balance >= 0`.
- `kind = negative` требует `balance <= 0`.
- `kind = any` не ограничивает знак.
- Баланс должен меняться через `transfers`/`holds`, а не прямым `UPDATE` прикладной роли.

## Права доступа (прикладной пользователь)

Разрешено:

- `INSERT` только в поля: `id, category_id, currency, details, meta, kind`
- `UPDATE` только полей: `locked_at, details`
- `SELECT`, `DELETE`

Не разрешено напрямую менять:

- `balance`
- `hold_amount`
- `transactions_count`
- `created_at`, `updated_at`

## Типовые операции

### Создать счёт

```sql
INSERT INTO openbill_accounts (category_id, currency, details, kind)
VALUES (10, 'USD', 'User wallet', 'positive')
RETURNING id;
```

### Поставить/снять блокировку на списание

```sql
-- запретить списания
UPDATE openbill_accounts
SET locked_at = now()
WHERE id = 1001;

-- разрешить списания
UPDATE openbill_accounts
SET locked_at = NULL
WHERE id = 1001;
```

### Проверить состояние счёта

```sql
SELECT
  id,
  category_id,
  balance,
  hold_amount,
  currency,
  kind,
  locked_at,
  transactions_count
FROM openbill_accounts
WHERE id = 1001;
```

## Типовые ошибки

- `permission denied for table openbill_accounts` при попытке менять служебные поля напрямую.
- `violates check constraint "openbill_accounts_kind"` при нарушении ограничения типа счёта.
- `violates foreign key constraint` при удалении счёта, у которого есть связанные трансферы.

## Связанные сущности

- [Категории](categories.md)
- [Трансферы](transfers.md)
- [Policy](policy.md)
