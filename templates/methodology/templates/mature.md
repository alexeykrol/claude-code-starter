---
maturity: mature
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

---
*Поднимать до crystallized, когда вызывается стабильно. Тогда часть переезжает в детерминированный код, а методология остаётся как спецификация (живёт здесь же, статус не меняем).*
