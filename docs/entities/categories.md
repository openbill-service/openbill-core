# Категории (`openbill_categories`)

## Назначение

`openbill_categories` группирует счета по бизнес-смыслу. Категории используются для:

- логической сегментации счетов
- настройки правил маршрутизации в `openbill_policies`

## Схема

| Поле | Тип | Обязательно | По умолчанию | Описание |
| --- | --- | --- | --- | --- |
| `id` | `bigserial` | да | sequence | Идентификатор категории |
| `name` | `varchar(256)` | да | - | Уникальное имя категории |

## Дефолтные данные

При инициализации создаётся системная категория:

- `id = -1`
- `name = 'System'`

Эта категория удобна для быстрого старта, но в production обычно добавляют свои доменные категории.

## Ограничения

- `name` уникально.
- На категорию ссылаются `openbill_accounts.category_id` и `openbill_policies.(from_category_id, to_category_id)`.
- Удаление категории с зависимыми счетами/политиками будет отклонено ограничениями FK.

## Права доступа

Для прикладной роли разрешены:

- `SELECT`
- `INSERT`
- `UPDATE`

## Типовые операции

### Создать категорию

```sql
INSERT INTO openbill_categories (name)
VALUES ('User wallets')
RETURNING id;
```

### Переименовать категорию

```sql
UPDATE openbill_categories
SET name = 'Customer wallets'
WHERE id = 10;
```

### Получить список категорий

```sql
SELECT id, name
FROM openbill_categories
ORDER BY id;
```

## Типовые ошибки

- `duplicate key value violates unique constraint "index_openbill_categories_name"` при повторном имени.
- `violates foreign key constraint` при удалении категории, на которую есть ссылки.

## Связанные сущности

- [Счета](accounts.md)
- [Policy](policy.md)
