# Policies (политики переводов)

Policy — правило, разрешающее переводы в определённом направлении. Openbill работает по **whitelist-модели**: перевод проходит, только если хотя бы одна policy его разрешает. Если ни одна не подходит — триггер выбрасывает ошибку `No policy for this transfer`.

## Зачем нужны policies

Без policies любой счёт может переводить средства на любой другой. Это удобно для экспериментов, но опасно в production — ошибка в коде приложения может создать некорректный перевод (например, напрямую с кошелька клиента на счёт мерчанта, минуя escrow).

Policies ограничивают допустимые маршруты на уровне базы данных. Даже если в приложении баг — база не пропустит запрещённый перевод.

## Структура policy

Каждая policy задаёт:

| Поле | Что означает | NULL = |
|-|-|-|
| `from_category_id` | Категория счёта-отправителя | Любая категория |
| `to_category_id` | Категория счёта-получателя | Любая категория |
| `from_account_id` | Конкретный счёт-отправитель | Любой счёт |
| `to_account_id` | Конкретный счёт-получатель | Любой счёт |
| `allow_reverse` | Разрешён ли reverse transfer | — (default: `true`) |

**NULL означает «любой»** — это ключевой механизм гибкости. Комбинируя NULL и конкретные значения, можно создавать как точечные, так и широкие правила.

## Дефолтная policy

При инициализации базы создаётся policy «Allow any transactions» — все поля NULL, всё разрешено:

```sql
-- Создаётся автоматически при миграции
INSERT INTO openbill_policies (name) VALUES ('Allow any transactions');
```

Перед настройкой production-маршрутов её нужно удалить:

```sql
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';
```

!!! warning "Порядок действий"
    Сначала создайте нужные policies, потом удалите дефолтную. Иначе все переводы будут заблокированы.

## Уровни ограничений

### По категориям (типичный случай)

Разрешает переводы между всеми счетами двух категорий:

```sql
-- Разрешить: Customer → Escrow (с возвратами)
INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT 'Customer -> Escrow', fc.id, tc.id, true
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'Customer' AND tc.name = 'Escrow';
```

Теперь любой счёт категории Customer может переводить на любой счёт категории Escrow.

### По конкретным счетам

Разрешает перевод только между двумя конкретными счетами:

```sql
-- Разрешить: только счёт #5 → счёт #10
INSERT INTO openbill_policies (name, from_account_id, to_account_id, allow_reverse)
VALUES ('Special route', 5, 10, false);
```

### Полу-открытые (категория + счёт)

Можно комбинировать — например, разрешить переводы из любого счёта категории на один конкретный счёт:

```sql
-- Все счета категории Customer могут переводить на escrow-счёт #42
INSERT INTO openbill_policies (name, from_category_id, to_account_id, allow_reverse)
SELECT 'Any customer -> Main escrow', c.id, 42, true
FROM openbill_categories c
WHERE c.name = 'Customer';
```

### Широкие (с NULL)

NULL в поле означает «без ограничений по этому параметру»:

```sql
-- Разрешить переводы из категории Customer куда угодно
INSERT INTO openbill_policies (name, from_category_id, allow_reverse)
SELECT 'Customer outbound', c.id, false
FROM openbill_categories c
WHERE c.name = 'Customer';
```

## Как работает проверка

При каждом `INSERT INTO openbill_transfers` срабатывает триггер `restrict_transfer`. Он ищет хотя бы одну policy, которая разрешает этот перевод.

Для **обычного перевода** (`reverse_transaction_id IS NULL`):

```
Ищем policy, где:
  (from_category_id IS NULL ИЛИ совпадает с категорией отправителя)
  И (to_category_id IS NULL ИЛИ совпадает с категорией получателя)
  И (from_account_id IS NULL ИЛИ совпадает с id отправителя)
  И (to_account_id IS NULL ИЛИ совпадает с id получателя)
```

Для **reverse transfer** (`reverse_transaction_id IS NOT NULL`) проверка зеркальная — направления переворачиваются, и дополнительно требуется `allow_reverse = true`:

```
Ищем policy, где:
  (from_category_id IS NULL ИЛИ совпадает с категорией ПОЛУЧАТЕЛЯ)
  И (to_category_id IS NULL ИЛИ совпадает с категорией ОТПРАВИТЕЛЯ)
  И allow_reverse = true
```

!!! note "Достаточно одной"
    Если хотя бы одна policy совпала — перевод разрешён. Policies работают как OR, не как AND.

## Пример: настройка маркетплейса

```sql
-- 1. Создаём категории
INSERT INTO openbill_categories (name) VALUES
  ('Customer'), ('Escrow'), ('Merchant'), ('PlatformFee');

-- 2. Создаём policies
-- Клиент → Escrow (возвраты разрешены)
INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT 'Customer -> Escrow', fc.id, tc.id, true
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'Customer' AND tc.name = 'Escrow';

-- Escrow → Merchant (возвраты запрещены)
INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT 'Escrow -> Merchant', fc.id, tc.id, false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'Escrow' AND tc.name = 'Merchant';

-- Escrow → PlatformFee (возвраты запрещены)
INSERT INTO openbill_policies (name, from_category_id, to_category_id, allow_reverse)
SELECT 'Escrow -> PlatformFee', fc.id, tc.id, false
FROM openbill_categories fc, openbill_categories tc
WHERE fc.name = 'Escrow' AND tc.name = 'PlatformFee';

-- 3. Удаляем дефолтную policy
DELETE FROM openbill_policies WHERE name = 'Allow any transactions';
```

Результат — три разрешённых маршрута:

```
Customer → Escrow       (+ reverse)
Escrow   → Merchant     (без reverse)
Escrow   → PlatformFee  (без reverse)
```

Всё остальное заблокировано. Попытка перевести `Customer → Merchant` напрямую вызовет ошибку:

```
ERROR: No policy for this transfer
```

## allow_reverse: когда разрешать возвраты

`allow_reverse = true` означает, что для данного маршрута допустим reverse transfer — перевод в обратном направлении со ссылкой на `reverse_transaction_id`.

Рекомендации:

- **true** — входные точки (оплата клиентом), где возврат — нормальный бизнес-сценарий
- **false** — внутренние маршруты (escrow → merchant, fee), где возврат нарушил бы бизнес-логику

В примере marketplace: клиент может получить возврат из escrow (`allow_reverse = true`), но выплату мерчанту нельзя «отменить» обратным переводом (`allow_reverse = false`).

## Типичные ошибки

### Забыли удалить дефолтную policy

Если `Allow any transactions` осталась — все остальные policies бессмысленны, потому что дефолтная разрешает всё.

### Создали policies, но не создали категории

Policy ссылается на `category_id`. Если счета не привязаны к правильным категориям — policy не сработает.

### Перепутали направление при возврате

Reverse transfer физически идёт от получателя к отправителю, но policy проверяет его по **исходному** направлению (зеркально). Не нужно создавать отдельную policy для обратного направления — достаточно `allow_reverse = true` на исходной.
