# Rule: Content Pipeline

## Purpose

Общий рабочий цикл для проектов, где продуктом является контент.

## Mandatory Intake

Перед research, writing, editing определи режим входа.

### Rich input

Признаки:
- авторский текст, транскрипт, глава, лекция, документ;
- формулировки, примеры, порядок мысли важны;
- задача похожа на адаптацию, структурирование, чистку, редактуру.

Правила:
- источник истины — входной материал;
- не сокращай и не переписывай авторский смысл;
- допускаются структура, заголовки, форматирование, пояснения, transitions;
- пояснения добавляй как дополнение, не замену.

### Sparse input

Признаки:
- тема или краткий бриф;
- источников мало;
- ожидается генерация структуры и текста.

Правила:
- запускай research;
- фиксируй sources;
- разделяй факты от выводов;
- логируй дефициты явно.

### Intake output

```text
Mode: rich / sparse / mixed
Content type: book / course / knowledge-base / docs / transcripts / report / hybrid
Audience: beginner / intermediate / advanced / mixed
Output format: ...
Source sufficiency: full / partial / weak
Constraints: ...
Deficits: ...
```

## Pipeline Stages

```text
Intake → Research → Outline → Write → Enrich → Review → Export/Index
```

### Stage 1: Research

Цель: собрать и систематизировать материал.

Выходы:
- `research-report.md`
- `sources.md`
- `concepts.md` или `source-map.md`

Критерии:
- ключевые темы покрыты;
- sources имеют provenance;
- спорные факты отмечены;
- gaps записаны как deficits.

### Stage 2: Outline

Цель: построить структуру продукта.

Выходы:
- курс: `program.md`, `learning-objectives.md`, `dependencies.md`
- книга: `arc.md`, `chapter-map.md`, `briefs/chapter-N.md`
- база знаний: `INDEX.md`, `INDEX-*.md`, taxonomy
- документы: `document-map.md`, canonical files list

Критерии:
- последовательность соответствует learning или decision flow;
- нет циклических prerequisites;
- каждый раздел имеет функцию;
- структура не теряет обязательный source.

### Stage 3: Write

Цель: создать или адаптировать content units.

Правила:
- один unit — один фокус;
- цель или функция видна в начале;
- термины объяснены при первом важном употреблении;
- богатый вход сохраняется;
- sparse input опирается на research.

### Stage 4: Enrich

Цель: сделать контент практичным и полезным.

Возможные проходы:
- examples and cases
- exercises and quizzes
- glossary/thesaurus
- cross-links
- diagrams/media references
- pitfalls and best practices
- summaries and study notes

### Stage 5: Review

Цель: проверить соответствие задаче, источникам, стилю, формату.

Severity:
- Critical — фактическая ошибка, потеря обязательного source, broken structure, нарушение hierarchy.
- Major — слабое объяснение, missing example, несоответствие аудитории, неполный формат.
- Minor — стилистика, локальная формулировка, nice-to-have.

Maximum iterations: 3. После 3 сделай escalation note.

### Stage 6: Export/Index

Цель: подготовить финальный продукт.

Проверить:
- metadata заполнены;
- index/registry обновлен;
- внутренние ссылки работают;
- assets рядом с content unit;
- output bundle соответствует contract.

## Anti-Paralysis

- Логируй дефициты и двигайся дальше, если не блокируют смысл.
- Не ищи идеальный source бесконечно; отметь confidence и продолжай.
- Лучше черновик с явными deficits, чем остановка.
- Эскалируй только смысловые конфликты, которые нельзя решить по source hierarchy.
