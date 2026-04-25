# Rule: Source Management

## Purpose

Защитить provenance, авторский смысл, фактическую точность, иерархию истины.

## Source Hierarchy

Каждый проект определяет порядок доверия. Default:

1. Primary source — исходные документы, диалоги, транскрипты, filed records, авторские материалы
2. Canon — bible, style guide, terms, arc, approved specs
3. Brief — задача на конкретный content unit
4. Existing content — уже написанные главы, уроки, docs
5. Generated notes — research notes, drafts, summaries

При конфликте используй более высокий source. Если конфликт смысловой, эскалируй.

## Provenance

Для важных утверждений фиксируй:
- URL или путь к файлу
- дата доступа (для внешних источников)
- section, heading или quote id
- confidence: high / medium / low

## Rich Input Preservation

Если работаешь с авторским текстом:
- сохраняй порядок мысли, если нет явной причины менять
- не удаляй повторы автоматически (могут быть риторические)
- не заменяй авторские термины синонимами
- не добавляй "более правильные" референсы без проверки
- пояснения добавляй как дополнение, не вместо текста

## Citation and Attribution

- Не выдумывай цитаты
- Не приписывай идеи авторам без проверки
- Внешний источник указывай в `sources.md` или локальной секции
- Закрытые/локальные документы: путь вместо публичного URL

## Deficits

```markdown
## Deficit: [short name]

**Question:** Что неизвестно?
**Needed for:** Какой content unit блокирует?
**Current evidence:** Что есть?
**Risk:** critical / major / minor
**Next step:** Где искать?
```

## Accuracy Modes

### Normal
Допустимы разумные обобщения при явной связи с источником.

### High-stakes
Для налогов, права, медицины, финансов, официальных документов:
- разделяй факты от предположений
- называй uncertainty
- предпочитай primary documents
- не давай окончательных выводов без источника
- проси проверку специалиста, если нужно
