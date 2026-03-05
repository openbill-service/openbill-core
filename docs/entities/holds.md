# Удержания (`openbill_holds`)

## Назначение

`openbill_holds` резервирует (блокирует) средства на счёте без их перемещения. Используется для сценариев, где деньги должны быть «заморожены» до подтверждения операции (авторизация карты, предзаказ и т.д.).

Механика: положительная сумма блокирует средства, отрицательная — снимает блокировку (release). Связь между блокировкой и разблокировкой — через `hold_key`.

## Схема

| Поле | Тип | Обязательно | По умолчанию | Описание |
|-|-|-|-|-|
| `id` | `bigserial` | да | sequence | Идентификатор удержания |
| `date` | `date` | да | `current_date` | Бизнес-дата |
| `created_at` | `timestamp` | нет | `current_timestamp` | Время создания |
| `account_id` | `bigint` | да | - | Счёт, на котором удерживаются средства |
| `amount_value` | `numeric(36,18)` | да | - | Сумма удержания (> 0 — блокировка, < 0 — разблокировка) |
| `amount_currency` | `varchar(8)` | да | `USD` | Валюта |
| `idempotency_key` | `varchar(256)` | да | - | Уникальный ключ идемпотентности |
| `details` | `text` | да | - | Описание |
| `meta` | `jsonb` | да | `{}` | Метаданные |
| `hold_key` | `varchar(256)` | нет | `NULL` | Ссылка на `idempotency_key` удержания, которое снимается |

## Бизнес-правила

- Блокировка (`amount_value > 0`): `hold_key` должен быть `NULL`.
- Разблокировка (`amount_value < 0`): `hold_key` обязан ссылаться на `idempotency_key` существующего удержания.
- Это гарантируется CHECK-ограничением: `(amount_value < 0 AND hold_key IS NOT NULL) OR (amount_value > 0 AND hold_key IS NULL)`.
- Нельзя заблокировать больше, чем текущий баланс счёта.
- Нельзя разблокировать больше, чем было заблокировано.
- Валюта удержания должна совпадать с валютой счёта.

## Влияние на баланс счёта

При INSERT в `openbill_holds` триггер выполняет:

```sql
UPDATE openbill_accounts
SET amount_value = amount_value - NEW.amount_value,
    hold_value   = hold_value   + NEW.amount_value
WHERE id = NEW.account_id;
```

Что это значит для двух операций:

- **Блокировка (amount_value > 0):** свободный баланс (`amount_value`) уменьшается, замороженный (`hold_value`) увеличивается.
- **Разблокировка (amount_value < 0):** свободный баланс увеличивается, замороженный уменьшается.

Инвариант: `amount_value + hold_value` остаётся постоянным. Средства не покидают счёт — они перемещаются между «свободным» и «замороженным» балансом.

### Пример: шаг за шагом

Допустим, на счёте `amount_value = 100`, `hold_value = 0`:

| Операция | amount_value | hold_value | Сумма (инвариант) |
|-|-|-|-|
| Исходное состояние | 100 | 0 | 100 |
| Hold +60 | 40 | 60 | 100 |
| Release −40 | 80 | 20 | 100 |
| Release −20 | 100 | 0 | 100 |

## Влияние на трансферы

Holds и transfers — **независимые механизмы**, но они взаимодействуют через `amount_value` счёта.

### Как hold ограничивает трансферы

Трансфер списывает из `amount_value` (свободный баланс). Hold уменьшает `amount_value`, перемещая часть средств в `hold_value`. Поэтому:

- Для счёта с `kind = 'positive'` (баланс ≥ 0): hold уменьшает доступный для списания баланс. Трансфер, который опустил бы `amount_value` ниже нуля, будет отклонён CHECK-ограничением.
- Для счёта с `kind = 'any'`: hold уменьшает `amount_value`, но баланс может уходить в минус, поэтому трансферы не блокируются.
- Для счёта с `kind = 'negative'` (баланс ≤ 0): hold увеличивает замороженный баланс, но списание (уменьшение `amount_value`) допустимо по ограничению типа.

### Hold vs locked_at

Это **разные механизмы**:

| | Hold | locked_at |
|-|-|-|
| Что делает | Резервирует конкретную сумму | Полностью блокирует исходящие трансферы |
| Гранулярность | Сумма | Весь счёт |
| Влияет на | `amount_value` и `hold_value` | Триггер `process_account_transfer` проверяет `locked_at IS NOT NULL` |
| Трансферы | Косвенно ограничивает (через уменьшение `amount_value`) | Прямо запрещает все исходящие |
| Входящие трансферы | Не влияет | Не влияет |

### Типовой сценарий: авторизация платежа

```
1. Hold $60       → amount_value: 100→40, hold_value: 0→60
2. Transfer $30   → amount_value: 40→10 (списание из свободного баланса)
3. Release $60    → amount_value: 10→70, hold_value: 60→0
```

Hold не запрещает трансферы — он лишь уменьшает свободный баланс. Трансферы и holds работают с одним и тем же `amount_value`.

## Права доступа

Для прикладной роли:

- Разрешены `SELECT` и `INSERT`
- Не разрешены `UPDATE` и `DELETE`

## Типовые операции

### Заблокировать средства

```sql
INSERT INTO openbill_holds (
  account_id,
  amount_value,
  amount_currency,
  idempotency_key,
  details
)
VALUES (
  1001,
  60.00,
  'USD',
  'hold:order:456',
  'Pre-auth for order 456'
)
RETURNING id;
```

### Частично разблокировать средства

```sql
INSERT INTO openbill_holds (
  account_id,
  amount_value,
  amount_currency,
  idempotency_key,
  hold_key,
  details
)
VALUES (
  1001,
  -40.00,
  'USD',
  'release:order:456:partial',
  'hold:order:456',
  'Partial release for order 456'
);
```

### Полностью разблокировать средства

```sql
INSERT INTO openbill_holds (
  account_id,
  amount_value,
  amount_currency,
  idempotency_key,
  hold_key,
  details
)
VALUES (
  1001,
  -60.00,
  'USD',
  'release:order:456:full',
  'hold:order:456',
  'Full release for order 456'
);
```

## Типовые ошибки

- `It is impossible to block the amount more than is on the account` — попытка заблокировать больше, чем баланс.
- `Hold has wrong currency` — валюта удержания не совпадает с валютой счёта.
- `duplicate key value violates unique constraint` по `idempotency_key`.
- Нарушение CHECK-ограничения — положительная сумма с `hold_key` или отрицательная без `hold_key`.

## Связанные сущности

- [Счета](accounts.md)
- [Трансферы](transfers.md)
