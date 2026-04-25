# {{PROJECT_NAME}}

## Назначение

{{PROJECT_PURPOSE}}

**Тип контента:** {{CONTENT_TYPE}}
**Основной продукт:** тексты / курс / книга / база знаний / документы / транскрипты / гибрид
**Код в проекте:** отсутствует / обслуживающий pipeline / равноправный слой

## Целевая аудитория

{{TARGET_AUDIENCE}}

Опиши:
- кто читатель/пользователь;
- уровень: beginner / intermediate / advanced / mixed;
- что читатель должен понять/решить/уметь;
- какие знания нельзя предполагать.

## Структура контента

Точка входа: `{{ENTRYPOINT_FILE}}`

```text
{{CONTENT_TREE}}
```

**Правило навигации:**
1. Начинай с точки входа.
2. Читай индексы разделов (registry, arc, syllabus, map).
3. Только потом открывай конкретные content units.
4. Не делай выводы по файлу без проверки его места в структуре.

## Иерархия источников

При конфликте доверяй в порядке:

1. `{{SOURCE_LEVEL_1}}` — первичный источник истины.
2. `{{SOURCE_LEVEL_2}}` — canon, bible, style guide, specs.
3. `{{SOURCE_LEVEL_3}}` — briefs, задачи, рабочие документы.
4. `{{SOURCE_LEVEL_4}}` — черновики, notes, generated artifacts.

**Правило:** не придумывай факты, цитаты, ссылки, термины или намерения автора. Дефицит или эскалация.

## Стиль и голос

Основной style guide: `{{STYLE_GUIDE_FILE}}`

Правила:
- сохраняй авторский голос с богатым входом;
- объясняй термины на уровне аудитории;
- не вводи новые термины без нужды;
- не меняй жанр без запроса;
- не удаляй авторский материал без разрешения.

Запрет-лист:
- `{{FORBIDDEN_PATTERN_1}}`
- `{{FORBIDDEN_PATTERN_2}}`

**Универсальные запреты (всегда):**
- Не убирать авторский контент из rich input
- Не менять голос/стиль без явного разрешения
- Не нарушать иерархию источников
- Не добавлять выдуманные факты, цитаты, ссылки
- Не игнорировать audience level

## Workflow

```text
Intake → Research → Outline → Write → Enrich → Review → Export/Index
```

### Intake

Определи режим:

- **Rich input:** авторский текст, транскрипт, документ, глава, лекция. Задача — сохранить мысль, структуру, голос; допускаются разметка, форматирование, пояснения, редактура.
- **Sparse input:** тема или краткий бриф. Задача — исследовать, структурировать, создать с нуля.

Зафиксируй:
```text
Режим: rich / sparse / mixed
Тип выхода: book / course / knowledge-base / docs / transcripts / report / hybrid
Аудитория: beginner / intermediate / advanced / mixed
Источники: full / partial / weak
Ограничения: ...
Дефициты: ...
```

## Форматы файлов

Используй:
- `templates/`
- `.claude/rules/content-formats.md`
- существующие файлы проекта

Базовые content unit форматы:
- глава: `chapters/NN-slug.md`
- урок: `modules/NN-name/lesson-NN.md`
- транскрипт: `Section-NN/NN-Lecture-Title.md`
- документ: `docs/topic-name.md`
- registry/index: `INDEX.md`, `00-course-index.md`, `course-registry.md`
- metadata: `meta.yaml` или frontmatter

## Review и качество

Checklist:
- соответствует задаче и аудитории;
- сохраняет источник и голос;
- нет фактических ошибок;
- нет потери обязательных тем;
- структура понятна;
- ссылки работают;
- формат соответствует шаблону.

Severity:
- Critical — блокирует публикацию.
- Major — исправить до финала.
- Minor — backlog.

## Состояние проекта

`.claude/SNAPSHOT.md` хранит:
- текущую фазу;
- готовность content units;
- последнюю точку работы;
- открытые дефициты;
- pending review;
- важные решения по источникам, стилю, структуре.

## Подсистемы

| Слой | Путь | Назначение |
|------|------|------------|
| Правила | `.claude/rules/` | workflow, quality, sources, formats, commits |
| Навыки | `.claude/skills/` | research, outline, write, review, enrich, index |
| Агенты | `.claude/agents/` | researcher, writer, editor, reviewer |
| Хуки | `.claude/hooks/` | checkpoints, compaction, reminders |
| Состояние | `.claude/SNAPSHOT.md` | рабочая память проекта |
| Метаданные | `manifest.md` | project_name, repo_access, project_type, content_type |

## Агенты

- `researcher` — исследует источники, строит source map, выделяет concepts, gaps.
- `writer` — пишет/адаптирует content units по brief, structure, style guide.
- `editor` — проверяет голос, стиль, термины, формат, readability.
- `reviewer` — release review: полнота, ссылки, sources, contract.

## Коммиты

В content-проекте продуктом являются content files. Префиксы:

- `content:` — новый контент;
- `edit:` — редактура;
- `chapter:` — глава книги;
- `lesson:` — урок курса;
- `research:` — источники, notes;
- `index:` — индексы, registry, навигация;
- `meta:` — snapshot, manifest;
- `pipeline:` — обслуживающий код.

Следуй `.claude/rules/content-commit-policy.md`.
