---
name: review-content
description: "Проверка готовности контента: sources, структура, стиль, формат, ссылки."
allowed-tools: Read Write Edit Glob Grep Bash
disable-model-invocation: false
---

# Skill: Review Content

## Purpose

Проверить content unit или bundle перед финализацией, публикацией или handoff.

## Input

- target files or diff
- brief
- style guide
- source hierarchy
- expected output format

## Process

### Brief Compliance (7 checks)
1. Контент отвечает исходной задаче
2. Тип выхода соответствует запросу
3. Scope включает обязательное и исключает запрещённое
4. Audience level соответствует brief
5. Output format корректен
6. Все обязательные content units созданы
7. Ограничения из brief соблюдены

### Structure & Flow (7 checks)
8. Иерархия заголовков понятна
9. Один раздел — одна функция
10. Переходы между разделами логичны
11. Нет knowledge jumps без scaffolding
12. Prerequisites указаны или покрыты
13. Навигация (index, cross-links) работает
14. Порядок соответствует learning curve / decision flow

### Content Quality (8 checks)
15. Source integrity — rich input сохранён
16. Факты имеют provenance
17. Нет invented citations или unsupported claims
18. Термины объяснены на уровне аудитории
19. Примеры из мира аудитории
20. Нет unexplained jargon
21. Summary/takeaway помогает (если формат требует)
22. Exercises/quizzes тестируют taught material (если применимо)

### Format & Delivery (6 checks)
23. Файл соответствует шаблону из content-formats.md
24. Metadata заполнены (status, audience, sources, updated)
25. Internal links относительные и resolve
26. Assets существуют и подключены
27. Index/registry обновлён
28. Export bundle compliant (если применимо)

## Output

```markdown
# Content Review: [Name]

**Status:** APPROVED / NEEDS REVISION / ESCALATION

## Critical
...

## Major
...

## Minor
...

## Recommendation
...
```

## Rules

- Не переписывай во время review
- Всегда указывай location
- Minor issues не блокируют
- Если проблем нет, напиши это явно
