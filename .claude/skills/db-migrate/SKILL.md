---
name: db-migrate
description: "Миграция схемы базы данных: SQLite → PostgreSQL/Supabase. Генерация SQL, проверка совместимости."
paths:
  - "**/schema*"
  - "**/migrations/**"
  - "**/db/**"
  - "**/*.sql"
allowed-tools: Read Edit Write Glob Grep Bash
disable-model-invocation: true
---

# Skill: Database Migration

## Workflow: SQLite → PostgreSQL/Supabase

### 1. Анализ текущей схемы

```bash
# Извлечь схему из SQLite
sqlite3 database.db ".schema" > schema-sqlite.sql
```

### 2. Конвертация типов

| SQLite | PostgreSQL |
|--------|-----------|
| INTEGER | INTEGER / BIGINT |
| TEXT | TEXT / VARCHAR |
| REAL | DOUBLE PRECISION |
| BLOB | BYTEA |
| DATETIME (text) | TIMESTAMPTZ |
| BOOLEAN (0/1) | BOOLEAN |
| AUTOINCREMENT | SERIAL / GENERATED ALWAYS AS IDENTITY |

### 3. Генерация PostgreSQL схемы

- Преобразовать типы
- Добавить TIMESTAMPTZ вместо TEXT для дат
- Заменить AUTOINCREMENT на SERIAL
- Добавить Row Level Security (RLS) для Supabase
- Сгенерировать миграционный файл

### 4. Проверка

- Валидировать SQL синтаксис
- Проверить foreign keys
- Проверить индексы
- Проверить constraints

### 5. Деплой

**Staging (автономно):**
```bash
# Применить на staging
psql $STAGING_DATABASE_URL -f migration.sql
```

**Production (с подтверждением):**
- Показать пользователю план миграции
- Дождаться подтверждения
- Применить
- Проверить результат

## Supabase-специфика

- Автоматически добавлять RLS policies
- Использовать Supabase CLI если доступен:
  ```bash
  supabase db push
  ```
- Генерировать TypeScript типы:
  ```bash
  supabase gen types typescript --local > src/types/database.ts
  ```
