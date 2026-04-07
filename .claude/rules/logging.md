# Правило: Локальное логирование

## Принцип

Каждая сессия и миграция оставляет лог. Логи хранятся локально в `.claude/logs/`, никуда не отправляются, и нужны для анализа ошибок фреймворка.

## Что логируется

### Сессии (`.claude/logs/sessions/`)

При каждом `/start` и `/finish` создаётся/обновляется лог текущей сессии:

**Файл:** `.claude/logs/sessions/YYYY-MM-DD_HH-MM.md`

**Содержимое:**
```
# Session: YYYY-MM-DD HH:MM

## Start
- Timestamp: ...
- SNAPSHOT status: [found / not found / empty]
- Git status: [clean / N uncommitted files]
- Framework version: ...

## Actions
- [timestamp] action description
- [timestamp] subagent:implementer launched → completed/failed
- [timestamp] commit: abc1234 "message"
- [timestamp] error: description

## Finish
- Timestamp: ...
- Tests: [passed N / failed N / skipped]
- Commits: [list of hashes]
- Duration: ...
```

### Миграции (`.claude/logs/migrations/`)

При каждом запуске `migrate.sh`:

**Файл:** `.claude/logs/migrations/YYYY-MM-DD_HH-MM.json`

**Содержимое:**
```json
{
  "timestamp": "...",
  "completed": "...",
  "project": "project-name",
  "doc_files_found": 15,
  "claude_md_enriched": true,
  "settings_upgraded": false,
  "errors": []
}
```

### Ошибки (`.claude/logs/errors/`)

При любой ошибке в работе фреймворка (упавший хук, неудачный субагент, сломанный скрипт):

**Файл:** `.claude/logs/errors/YYYY-MM-DD_HH-MM_error.md`

**Содержимое:**
- Что произошло
- Контекст (какой skill/agent/hook)
- Stack trace или вывод команды
- Что было до ошибки (последние 3 действия)

## Как логировать

Логирование — это **конвенция агента**, не автоматика. Автоматически логируется только миграция (migrate.sh пишет JSON). Всё остальное — ответственность агента, который следует форматам выше.

Агент ведёт лог в процессе работы:
- При `/start` — создать файл сессии, записать начальное состояние
- В процессе работы — дописывать значимые действия (субагенты, коммиты, ошибки)
- При `/finish` — дописать итоги, тесты, duration
- При ошибке — создать отдельный error-лог

Логирование не должно замедлять работу. Запись — append в конец файла, без перечитывания. Если логирование мешает — пропусти. Лучше сделать работу без лога, чем не сделать с логом.

## Хранение

- Все логи в `.gitignore` (автоматически)
- Логи не удаляются автоматически
- Для анализа проблем фреймворка: читать `.claude/logs/errors/`
- Для хронологии работы: читать `.claude/logs/sessions/`
