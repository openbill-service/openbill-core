# Сущности Openbill Core

Раздел описывает ключевые сущности ledger-модели Openbill Core и правила работы с ними.

## Карта сущностей

| Сущность | Таблица | За что отвечает |
| --- | --- | --- |
| Счета | `openbill_accounts` | Хранение балансов, валюты, типа счёта и состояния блокировки |
| Трансферы | `openbill_transfers` | Перемещение суммы между двумя счетами с идемпотентностью |
| Категории | `openbill_categories` | Группировка счетов по бизнес-назначению |
| Policy | `openbill_policies` | Разрешённые маршруты переводов между категориями/счетами |
| Удержания | `openbill_holds` | Резервирование (блокировка) средств на счёте без перемещения |

## Как сущности связаны

1. Создаёте категории (`openbill_categories`).
2. Создаёте счета (`openbill_accounts`) и привязываете к категориям.
3. Настраиваете policy (`openbill_policies`) для разрешённых направлений.
4. Выполняете трансферы (`openbill_transfers`) в рамках policy.
5. При необходимости создаёте удержания (`openbill_holds`) для резервирования средств.

## ERD (Mermaid)

```mermaid
erDiagram
    openbill_categories {
      bigint id PK
      varchar name UK
    }

    openbill_accounts {
      bigint id PK
      bigint category_id FK
      numeric amount_value
      varchar amount_currency
      numeric hold_value
      account_kind kind
      timestamp locked_at
    }

    openbill_transfers {
      bigint id PK
      bigint from_account_id FK
      bigint to_account_id FK
      numeric amount_value
      varchar amount_currency
      varchar idempotency_key UK
      bigint reverse_transaction_id FK
    }

    openbill_policies {
      bigint id PK
      varchar name UK
      bigint from_category_id FK
      bigint to_category_id FK
      bigint from_account_id FK
      bigint to_account_id FK
      boolean allow_reverse
    }

    openbill_holds {
      bigint id PK
      bigint account_id FK
      numeric amount_value
      varchar amount_currency
      varchar idempotency_key UK
      varchar hold_key FK
    }

    openbill_categories ||--o{ openbill_accounts : "category_id"

    openbill_accounts ||--o{ openbill_transfers : "from_account_id"
    openbill_accounts ||--o{ openbill_transfers : "to_account_id"
    openbill_transfers ||--o{ openbill_transfers : "reverse_transaction_id"

    openbill_accounts ||--o{ openbill_holds : "account_id"
    openbill_holds ||--o{ openbill_holds : "hold_key -> idempotency_key"

    openbill_categories ||--o{ openbill_policies : "from_category_id"
    openbill_categories ||--o{ openbill_policies : "to_category_id"
    openbill_accounts ||--o{ openbill_policies : "from_account_id"
    openbill_accounts ||--o{ openbill_policies : "to_account_id"
```

## Порядок чтения

1. [Категории](categories.md)
2. [Счета](accounts.md)
3. [Policy](policy.md)
4. [Трансферы](transfers.md)
5. [Удержания](holds.md)

## Связанные разделы

- [Быстрый старт](../getting-started.md)
- [Глоссарий](../glossary.md)
- [Каталог примеров](../examples/README.md)
