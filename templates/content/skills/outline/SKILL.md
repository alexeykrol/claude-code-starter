---
name: outline
description: "Построение структуры книги, курса, базы знаний, документа."
allowed-tools: Read Write Edit Glob Grep
disable-model-invocation: false
---

# Skill: Outline

## Purpose

Сформировать content map: оглавление, программу, chapter map, registry или document structure.

## Input

- brief
- research outputs
- existing index/arc/program
- audience and content type

## Process

1. Определи конечный результат для читателя
2. Разбей материал на content units
3. Для каждого unit задай функцию: teach, prove, reference, decide, practice, archive
4. Построй порядок: prerequisites, learning curve, narrative arc, decision flow
5. Отметь dependencies и cross-links
6. Проверь, что обязательные sources не потеряны
7. Зафиксируй gaps for research/write

## Output

- курс: `program.md`, `learning-objectives.md`, `dependencies.md`
- книга: `arc.md`, `chapter-map.md`, `briefs/chapter-N.md`
- база знаний: `INDEX.md`, `INDEX-*.md`, taxonomy
- документы: `document-map.md`, canonical files list
- транскрипты: `00-course-index.md`, section map

## Quality

- У каждого section/unit есть цель
- Нет циклических dependencies
- Структура соответствует audience level
- Навигация понятна
