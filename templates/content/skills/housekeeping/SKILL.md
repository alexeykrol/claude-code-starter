---
name: housekeeping
description: "Обслуживание content-проекта: индексы, metadata, snapshot, links, sources."
allowed-tools: Read Edit Write Glob Grep Bash
disable-model-invocation: true
---

# Skill: Housekeeping

## Purpose

Проверить, что content-проект не разъехался: навигация, metadata, links, snapshot, formats.

## Checks

### 1. Index and Registry
- `INDEX.md`, `00-course-index.md` существуют, если нужны
- Новые content files добавлены в index
- Archived/draft файлы не смешаны с current
- Orphan files перечислены или подключены

### 2. Metadata
- `meta.yaml` or frontmatter заполнены
- Status актуален
- Audience/type/tags указаны
- Updated date не старее последней правки

### 3. Links
- Relative links resolve
- Image/media paths exist
- Cross-links между chapters/lessons не сломаны

### 4. Source Hygiene
- `sources.md` обновлен после research
- Важные утверждения имеют provenance
- Deficits не потеряны

### 5. SNAPSHOT
- current phase
- current unit
- progress table
- open deficits
- pending review
- next actions

### 6. CLAUDE.md Drift

- Структура контента в `CLAUDE.md` соответствует реальному дереву папок?
- Описание workflow актуально?
- Source hierarchy не изменилась?
- Audience и content_type не устарели?

Если обнаружен drift — обновить `CLAUDE.md` автоматически.

### 7. Commit Hygiene
- No secrets
- No private docs в public/shared mode
- Generated artifacts ignored unless deliverable

## What Not To Do

- Не переписывай контент
- Не меняй смысл
- Не удаляй черновики без запроса
- Не трать больше 3 минут без причины

## When To Run

- перед push
- перед handoff
- после массового перемещения файлов
- после генерации нового bundle
- по запросу пользователя
