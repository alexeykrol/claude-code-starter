---
name: content-index
description: "Построение и обновление индексов, registry, оглавлений, course maps, cross-links."
allowed-tools: Read Write Edit Glob Grep Bash
disable-model-invocation: false
---

# Skill: Content Index

## Purpose

Обновить навигацию и registry так, чтобы проект был читаемым после изменения контента.

## Input

- content tree
- existing `INDEX.md`, `00-course-index.md`, `course-registry.md` или README
- metadata files

## Process

1. Просканируй content files
2. Извлеки title, status, type, tags, updated date, summary
3. Проверь missing metadata
4. Обнови master index
5. Обнови section indexes
6. Проверь relative links
7. Зафиксируй orphan files

## Output

- `INDEX.md`
- `INDEX-*.md`
- `00-course-index.md`
- `course-registry.md`
- `README.md` navigation section
- optional `orphan-report.md`

## Quality

- Каждый publishable file достижим из индекса
- Нет broken relative links
- Index descriptions one-line и specific
- Archive/drafts clearly separated
