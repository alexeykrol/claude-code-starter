---
paths:
  - "**/deploy/**"
  - "**/infra/**"
  - "**/production/**"
  - "**/.env.production"
  - "**/Dockerfile"
  - "**/docker-compose.prod*"
---

# Правило: Production Safety

## Принцип

Всё, что касается production — требует подтверждения пользователя. Всё остальное — полная автономность.

## Требует подтверждения

- Deploy на production-сервер
- Изменение production базы данных (миграции, данные)
- Изменение DNS, домена, SSL
- Изменение production environment variables
- Push в main/master (если это production branch)
- Публикация пакета (npm publish, PyPI upload)
- Изменение CI/CD pipeline для production

## Полная автономность (не спрашивать)

- Создание, изменение, удаление файлов в проекте
- Запуск тестов (unit, integration, E2E)
- Git операции: commit, branch, merge (кроме push в production)
- Staging deploy
- Локальная разработка
- Установка зависимостей
- Рефакторинг кода
- Создание и обновление документации

## Как спрашивать

Коротко. Без лишних объяснений:

```
Production deploy готов:
- [что будет развёрнуто]
- [какие изменения]
Подтвердить? (y/n)
```
