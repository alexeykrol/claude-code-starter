---
maturity: crystallized
id: <kebab-case-stable-id>
domain: <pipeline-design | content | extraction | classification | ...>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
applies_when: []        # routing signals: when router should pick this methodology
does_not_apply: []      # exclusion signals
inputs_required: []     # what data the executor needs
outputs_produced: []    # what the executor produces
composes_with: []       # other methodology ids it chains with
related: []
---

# Methodology: [имя]

## Концепция
[1 параграф]

## Routing signals
[как роутер определяет применимость, в формализованном виде]

## Декомпозиция (judgment vs bookkeeping)
- **Суждение (LLM):** что решает модель
- **Бухгалтерия (код):** что считает/проверяет код
- Граница между ними (важная часть: см. [[rules/llm-as-component]])

## Prompt skeleton (для executor)
```text
[Шаблон промпта с placeholder'ами {{input_x}}]
```

## Anti-patterns
- ...

## Composition notes
- Как соединяется с другими методологиями (id ссылки)
- Какие данные передаёт дальше

## Примеры и trace-ы
- ссылки на конкретные применения

## Реализация в коде
- `path/to/file.py` — что именно делает
- Какие части остались за LLM, какие сделаны детерминированно

## История перехода
- Что было причиной кристаллизации (стабильность? цена? скорость?)
- Что было выкинуто в процессе

---
*Crystallized означает, что методология живёт одновременно как спецификация (этот файл) и как код. При изменении кода — обнови этот файл, иначе спецификация рассинхронизируется с реализацией.*
