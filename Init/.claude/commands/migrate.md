---
description: Создать database migration с правильным процессом
---

Создай database migration следуя лучшим практикам.

**ВАЖНО: Миграции - критическая часть. Тестируй все тщательно!**

## Процесс:

### 1. Анализ текущей схемы БД

Прочитай и проанализируй:
```bash
# Найди файлы схемы БД
find . -name "schema.*" -o -name "*.prisma" -o -name "*migration*"

# Посмотри последние миграции
ls -la supabase/migrations/ || ls -la prisma/migrations/ || ls -la migrations/
```

Прочитай:
- Текущую схему БД
- Последние миграции
- Database documentation (если есть в ARCHITECTURE.md)

### 2. Пойми требования

Спроси себя:
- Какие изменения в схеме нужны?
- Есть ли существующие данные, которые нужно сохранить?
- Нужна ли обратная совместимость?
- Есть ли зависимости от других таблиц?

### 3. Спланируй миграцию

**Типы изменений:**

**Безопасные (можно делать на проде):**
- ✅ ADD column (с DEFAULT или NULL)
- ✅ ADD index (concurrent)
- ✅ ADD new table
- ✅ ADD constraint (NOT VALID, потом VALIDATE)

**Опасные (требуют осторожности):**
- ⚠️ DROP column (может сломать приложение)
- ⚠️ RENAME column (нужна двухфазная миграция)
- ⚠️ CHANGE column type (может потерять данные)
- ⚠️ ADD NOT NULL (сначала заполни данные)

**Очень опасные (только с downtime):**
- 🔴 DROP table
- 🔴 CHANGE primary key
- 🔴 Большая структурная переделка

### 4. Создай migration файл

**Naming convention:**
```
YYYYMMDDHHMMSS_descriptive_name.sql
```

Пример: `20250110120000_add_user_preferences_table.sql`

**Структура миграции:**

```sql
-- Migration: Add user preferences table
-- Created: 2025-01-10
-- Author: Claude Code
-- Description: Add table to store user preferences with foreign key to users

-- ============================================
-- Up Migration
-- ============================================

BEGIN;

-- Create table
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  theme VARCHAR(20) DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'auto')),
  language VARCHAR(10) DEFAULT 'en',
  notifications_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Constraints
  CONSTRAINT unique_user_preferences UNIQUE(user_id)
);

-- Create indexes
CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- Add comments
COMMENT ON TABLE user_preferences IS 'Stores user-specific preferences';
COMMENT ON COLUMN user_preferences.theme IS 'UI theme preference';

-- Enable Row Level Security
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view own preferences"
  ON user_preferences
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON user_preferences
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
  ON user_preferences
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

COMMIT;

-- ============================================
-- Down Migration (Rollback)
-- ============================================

-- Uncomment to enable rollback:
-- BEGIN;
-- DROP TABLE IF EXISTS user_preferences CASCADE;
-- COMMIT;
```

### 5. Создай TypeScript types (если используется TypeScript)

**Файл: `src/types/database.ts` или обнови существующий:**

```typescript
// Database Types
export interface UserPreferences {
  id: string;
  user_id: string;
  theme: 'light' | 'dark' | 'auto';
  language: string;
  notifications_enabled: boolean;
  created_at: string;
  updated_at: string;
}

// Database Tables
export interface Database {
  public: {
    Tables: {
      user_preferences: {
        Row: UserPreferences;
        Insert: Omit<UserPreferences, 'id' | 'created_at' | 'updated_at'>;
        Update: Partial<Omit<UserPreferences, 'id' | 'created_at'>>;
      };
      // ... other tables
    };
  };
}
```

### 6. Тестирование миграции

**В Development:**
```bash
# Применить миграцию
make db-migrate
# или
npm run db:migrate
# или
supabase db push

# Проверить что таблица создана
# (команда зависит от вашей БД)

# Тестировать операции
# - INSERT тестовые данные
# - SELECT проверить чтение
# - UPDATE проверить обновление
# - DELETE проверить удаление
# - Проверить RLS policies
```

**Rollback тест:**
```bash
# Откатить миграцию
make db-rollback
# или
npm run db:rollback

# Проверить что откат работает
# Применить снова для продолжения работы
make db-migrate
```

### 7. Обнови документацию

**Обнови ARCHITECTURE.md:**
```markdown
### Database Schema

#### user_preferences
Stores user-specific UI and notification preferences.

**Columns:**
- `id` (UUID, PK) - Unique identifier
- `user_id` (UUID, FK → users.id) - Reference to user
- `theme` (VARCHAR) - UI theme: 'light', 'dark', 'auto'
- `language` (VARCHAR) - Preferred language code
- `notifications_enabled` (BOOLEAN) - Email notifications toggle
- `created_at` (TIMESTAMP) - Record creation time
- `updated_at` (TIMESTAMP) - Last update time

**Constraints:**
- One preference record per user (unique user_id)
- Cascading delete when user is deleted

**Security:**
- RLS enabled
- Users can only view/edit their own preferences
```

### 8. Обнови связанный код

**Создай/обнови API endpoints:**
```typescript
// Example: API route for preferences
import { Database } from '@/types/database';

export async function GET(req: Request) {
  const supabase = createClient<Database>();

  const { data, error } = await supabase
    .from('user_preferences')
    .select('*')
    .single();

  if (error) {
    return Response.json({ error: error.message }, { status: 400 });
  }

  return Response.json(data);
}
```

### 9. Создай коммит

Используй `/commit` команду со следующими изменениями:
- Migration SQL файл
- TypeScript types
- Обновленная документация
- Новый/обновленный код использующий новую схему

### 10. Security Checklist для миграций

- [ ] RLS (Row Level Security) включен для новых таблиц
- [ ] RLS policies созданы и протестированы
- [ ] Foreign keys правильно настроены
- [ ] Indexes добавлены для performance
- [ ] Sensitive data правильно защищена
- [ ] Cascading deletes настроены где нужно
- [ ] Comments добавлены для документации
- [ ] Нет hardcoded значений (используй константы/enums)

## 📋 Migration Checklist

### До создания:
- [ ] Прочитал текущую схему БД
- [ ] Понял требования к изменениям
- [ ] Спланировал безопасную миграцию
- [ ] Проверил зависимости от других таблиц

### Во время создания:
- [ ] Создал migration файл с правильным именем
- [ ] Добавил комментарии и описание
- [ ] Создал rollback (down migration)
- [ ] Обновил TypeScript types
- [ ] Добавил indexes для performance
- [ ] Настроил RLS и policies

### После создания:
- [ ] Протестировал в development
- [ ] Протестировал rollback
- [ ] Обновил ARCHITECTURE.md
- [ ] Обновил связанный код
- [ ] Создал коммит с описанием

## 🚫 Опасные операции

**НИКОГДА не делай без явного подтверждения:**
- ❌ DROP TABLE на production
- ❌ DROP COLUMN с данными
- ❌ TRUNCATE TABLE
- ❌ ALTER TYPE на больших таблицах (может заблокировать)
- ❌ Миграции без rollback плана

**Если нужно удалить column:**
1. Сначала убери использование в коде
2. Deploy код без использования column
3. Только потом DROP column в миграции

## 💡 Best Practices

1. **Atomic migrations:** Используй BEGIN/COMMIT
2. **Idempotent:** Используй IF EXISTS / IF NOT EXISTS
3. **Reversible:** Всегда создавай down migration
4. **Documented:** Добавляй комментарии SQL и в docs
5. **Tested:** Тестируй up и down migrations
6. **Small:** Одна миграция = одно логическое изменение
7. **Safe defaults:** Используй DEFAULT для новых columns

## Примеры частых сценариев:

### Add column (безопасно):
```sql
ALTER TABLE users
ADD COLUMN avatar_url TEXT DEFAULT NULL;
```

### Add NOT NULL column (двухфазно):
```sql
-- Phase 1: Add column as nullable with default
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT false;

-- Phase 2 (after data backfill): Make NOT NULL
-- ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
```

### Rename column (двухфазно):
```sql
-- Phase 1: Add new column
ALTER TABLE users ADD COLUMN full_name TEXT;
UPDATE users SET full_name = name;

-- Phase 2 (after code update): Drop old column
-- ALTER TABLE users DROP COLUMN name;
```

**После выполнения миграции обязательно обнови BACKLOG.md!**
