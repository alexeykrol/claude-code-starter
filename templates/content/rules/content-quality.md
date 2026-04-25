# Rule: Content Quality

## Purpose

Единый review protocol для текстов, курсов, книг, документов, транскриптов, баз знаний.

## Universal Checklist

### 1. Task Fit
- Контент отвечает исходной задаче
- Тип выхода соответствует запросу
- Scope включает обязательное, исключает запрещенное

### 2. Audience Fit
- Уровень сложности соответствует аудитории
- Термины объяснены при первом важном употреблении
- Примеры из мира аудитории
- Читатель знает, что делать дальше

### 3. Source Integrity
- Обязательные sources сохранены
- Rich input не переписан с потерей голоса/смысла
- Факты, цитаты, ссылки имеют provenance
- Спорные утверждения помечены

### 4. Structure
- Понятная иерархия заголовков
- Один раздел — одна функция
- Transitions логичны
- Нет knowledge jumps без scaffolding

### 5. Style and Voice
- Тон соответствует style guide
- Терминология стабильна
- Нет запрещенных оборотов
- Нет неожиданного жанра/академизма/маркетинга

### 6. Format
- Файл соответствует шаблону
- Metadata заполнены
- Ссылки относительные
- Assets существуют и подключены

### 7. Utility
- Примеры есть в обучающем материале
- Summary/takeaway помогает формату
- Index/cross-links есть в коллекции
- Exercises/quizzes есть в курсе

## Review Report Format

```markdown
# Content Review: [Name]

**Date:** YYYY-MM-DD
**Status:** APPROVED / NEEDS REVISION / ESCALATION

## Summary
[Короткая оценка готовности.]

## Critical Issues
1. [file:line] Описание → suggested route

## Major Issues
1. ...

## Minor Issues
1. ...

## Checklist Results
- Task Fit: pass/fail
- Audience Fit: pass/fail
- Source Integrity: pass/fail
- Structure: pass/fail
- Style and Voice: pass/fail
- Format: pass/fail
- Utility: pass/fail

## Recommendation
Approved / Return to Write / Return to Enrich / Return to Research / Escalate
```

## Routing

| Issue type | Route |
|------------|-------|
| Missing facts or weak evidence | Research |
| Broken sequence or unclear outline | Outline |
| Poor explanation or missing section | Write |
| Missing examples, exercises, glossary | Enrich |
| Broken links or metadata | Export/Index |
| Voice drift | Editor |

## Audience-Level Quality Criteria

| Level | Объяснения | Термины | Примеры | Темп |
|-------|-----------|---------|---------|------|
| **beginner** | Подробные, пошаговые | Раскрывать все при первом употреблении | Много, из повседневного опыта | Медленный |
| **intermediate** | Средние, с допущениями | Профессиональные допустимы, ключевые раскрывать | Профессиональные, реальные кейсы | Средний |
| **advanced** | Минимальные, фокус на нюансах | Профессиональные без пояснений | Edge cases, anti-patterns | Быстрый |

## Common Quality Issues

| Issue | Признак | Fix |
|-------|---------|-----|
| Слишком high-level | Читатель не понимает, что делать | Добавить concrete example |
| Unexplained jargon | Термин без определения | Объяснить при первом употреблении |
| Missing prerequisite | Knowledge jump | Добавить dependency или scaffolding |
| Voice drift | Чужой жанр, академизм, маркетинг | Вернуть к style guide |
| Weak evidence | Утверждение без источника | Добавить provenance или пометить deficit |
| Broken structure | Нарушена последовательность | Перестроить по outline |

## Rules

- Review is verification, not rewriting.
- Do not block release on minor issues.
- Always cite concrete location.
- If no issues found, list residual risks.
