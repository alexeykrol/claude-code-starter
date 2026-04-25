# Rule: Content Commit Policy

## Principle

В content-проекте продуктом являются `*.md`, `*.txt`, `*.pdf`, `*.docx`, images, metadata, indexes, bundles и source materials.

Используй `git add` конкретных файлов. Не используй `git add .` или `git add -A`.

## Prefixes

| Prefix | Use |
|--------|-----|
| `content:` | новый материал, статья, раздел, документ |
| `edit:` | редактура существующего текста |
| `chapter:` | глава книги |
| `lesson:` | урок курса |
| `research:` | sources, research reports, notes |
| `index:` | INDEX, registry, cross-links, navigation |
| `meta:` | SNAPSHOT, manifest, project metadata |
| `format:` | templates, format cleanup, metadata normalization |
| `pipeline:` | обслуживающие скрипты, extractor, generator, converter |
| `fix:` | исправление ошибки в коде или контенте |

## repo_access Modes

### public / private-shared

Коммитить продукт:
- publishable content
- user-facing docs
- source files (если часть продукта)
- metadata, indexes, templates
- production scripts and tests

Не коммитить процесс:
- `.claude/`, `CLAUDE.md`, `manifest.md` (если framework локальный)
- private notes, drafts, scratch, logs
- raw dumps with sensitive data
- unpublished author feedback

### private-solo

Можно коммитить все рабочие материалы, кроме always-forbidden.

## Always Forbidden

- `.env`, `.env.*`
- keys, certs, credentials
- `.claude/settings.local.json`
- local databases with private data
- `node_modules/`, `.venv/`, `__pycache__/`
- generated build artifacts (если не deliverable)
- private tax/legal/medical docs в public/shared repos

## Content Atomicity

Коммит должен быть смысловым:
- одна глава + metadata/index updates
- один урок + quiz/exercise + index update
- один research pass + sources/concepts
- один pipeline change + tests

Если правка content unit требует обновить index, commit включает оба.

## Before Push

- Нет secrets
- Нет private source docs в public/shared
- Indexes обновлены
- Links не сломаны
- SNAPSHOT актуален
