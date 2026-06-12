# Dialog Archive

Здесь хранятся сохранённые JSONL-логи сессий Claude Code, которые иначе будут удалены retention'ом.

## Как сохранить текущий диалог

```bash
bash scripts/save-dialogs.sh
# или с темой:
bash scripts/save-dialogs.sh --note "тема диалога"
```

Идемпотентно: можно запускать сколько угодно раз — копируются только новые/изменённые файлы.

## Структура

```
.claude/dialogs/
  YYYY-MM-DD_<session-id-short>.jsonl   # сырой JSONL сессии
  INDEX.md                              # реестр: что за диалог, почему сохранили
  README.md                             # этот файл
```

## Политика коммитов

| `repo_access` | `.claude/dialogs/` |
|---------------|--------------------|
| `private-solo` | можно коммитить |
| `private-shared` | локально; не коммитить без чистки секретов |
| `public` | локально; не коммитить без чистки секретов |

Полное правило: `.claude/rules/dialog-preservation.md` (и глобальное `~/.claude/rules/dialog-preservation.md`).
