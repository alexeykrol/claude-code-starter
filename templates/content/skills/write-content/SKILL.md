---
name: write-content
description: "Создание или бережная адаптация content units по brief, структуре и style guide."
allowed-tools: Read Write Edit Glob Grep
disable-model-invocation: false
---

# Skill: Write Content

## Purpose

Написать или адаптировать главу, урок, статью, документ, transcript-derived lesson, knowledge-base entry.

## Input

- Intake result: rich / sparse / mixed
- outline or brief
- source hierarchy
- style guide
- target file path

## Process

1. Прочитай brief, relevant outline, style guide
2. Прочитай только нужные sources
3. Если input rich: сохрани голос, порядок мысли, обязательные формулировки
4. Если input sparse: опирайся на research outputs
5. Напиши content unit по локальному формату
6. Объясни термины на уровне аудитории
7. Добавь transitions, summary, cross-links
8. Запиши unresolved deficits

## Quality

- Один unit — один фокус
- В начале ясна цель
- Нет unexplained jargon
- Нет invented citations
- Rich input не потерян
- Файл соответствует формату

## Output

- Created/updated content file
- Optional local notes in `notes/` or `_meta/`
