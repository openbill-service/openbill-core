# Policy (`openbill_policies`)

## Назначение

`openbill_policies` определяет, какие направления переводов разрешены. Если ни одна policy не подходит под трансфер, операция отклоняется с ошибкой `No policy for this transfer`.

## Схема

| Поле | Тип | Обязательно | По умолчанию | Описание |
| --- | --- | --- | --- | --- |
| `id` | `bigserial` | да | sequence | Идентификатор policy |
| `name` | `varchar(256)` | да | - | Уникальное имя policy |
| `from_category_id` | `bigint` | нет | `NULL` | Категория-источник |
| `to_category_id` | `bigint` | нет | `NULL` | Категория-получатель |
| `from_account_id` | `bigint` | нет | `NULL` | Конкретный счёт-источник |
| `to_account_id` | `bigint` | нет | `NULL` | Конкретный счёт-получатель |
| `allow_reverse` | `boolean` | да | `true` | Разрешён ли обратный маршрут |

## Семантика `NULL`

`NULL` в любом ограничивающем поле означает wildcard ("любой").

Примеры:

- только `from_category_id` заполнен -> разрешены исходящие из категории в любые направления
- `from_category_id` + `to_category_id` -> разрешён конкретный маршрут между категориями
- `from_account_id` + `to_account_id` -> разрешён трансфер между конкретной парой счетов

## Проверка policy при трансфере

### Обычный трансфер (`reverse_transaction_id IS NULL`)

Должна существовать policy, где все заданные (не `NULL`) поля совпадают с маршрутом `from -> to`.

### Reverse transfer (`reverse_transaction_id IS NOT NULL`)

Для возврата применяется зеркальная проверка маршрута `to <- from`, и дополнительно `allow_reverse = true`.

## Дефолтная policy

После инициализации есть запись:

- `name = 'Allow any transactions'`

Она открывает любые маршруты. Для production обычно удаляется и заменяется явными правилами.

## Права доступа

Для прикладной роли разрешены:

- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`

## Рекомендуемый production bootstrap

```sql
-- 1) удалить политику по умолчанию
DELETE FROM openbill_policies
WHERE name = 'Allow any transactions';

-- 2) добавить явное правило между категориями
INSERT INTO openbill_policies (
  name,
  from_category_id,
  to_category_id,
  allow_reverse
)
VALUES (
  'Users -> System',
  10,
  20,
  true
);
```

## Типовые ошибки

- `No policy for this transfer` — нет подходящей policy под текущий маршрут.
- `duplicate key value violates unique constraint "index_openbill_policies_name"` — имя policy уже занято.

## Связанные сущности

- [Категории](categories.md)
- [Счета](accounts.md)
- [Трансферы](transfers.md)
