---
name: research
description: "Сбор, проверка и систематизация источников."
allowed-tools: Read Write Edit Glob Grep Bash WebSearch
disable-model-invocation: false
---

# Skill: Research

## Purpose

Собрать материал, sources, concept map и deficits перед outline или writing.

## Input

- brief or task
- content type
- target audience
- existing source hierarchy
- optional source files

## Process

1. Определи scope
2. Проверь source hierarchy проекта
3. Собери sources: локальные файлы, docs, web, primary records
4. Раздели по credibility: primary / expert / practitioner / introductory / generated
5. Сгруппируй по темам
6. Выдели key concepts, prerequisites, disagreements, gaps
7. Зафиксируй deficits и confidence

## Output

- `research-report.md`
- `sources.md` with annotations
- `concepts.md` или `source-map.md`
- optional `deficits.md`

## Quality

- Каждый важный факт имеет source
- 2-3 независимых sources для спорных тем
- Gaps не скрыты
- Research достаточен для outline
