---
description: Объяснить как работает определенная часть кода
---

# Adaptive Code Explanation

**IMPORTANT: Automatically assess code complexity BEFORE explaining.**

## Step 1: Complexity Assessment

Quickly evaluate the code size and complexity:

**Simple** (1-10 lines, basic operations):
- Variable assignments
- Simple loops/conditions
- Basic function calls
- Config declarations

**Medium** (10-50 lines, multiple functions):
- Multiple interacting functions
- Data transformations with logic
- Component with props/state
- API endpoint implementation

**Complex** (50+ lines, architecture):
- Full modules or features
- Multiple components interaction
- Advanced patterns (HOCs, middleware chains)
- System architecture decisions

## Step 2: Adaptive Explanation

### For SIMPLE code:

**Format:**
```
Краткое объяснение (2-3 предложения):

1. Что делает код
2. Ключевые моменты (если есть)
3. Результат

[Если есть важные детали - добавить 1-2 пункта]
```

**Example:**
```
Этот bash-скрипт генерирует уникальное имя файла для bug report:

1. Берёт имя текущей папки: PROJECT_NAME=$(basename "$(pwd)")
2. Создаёт timestamp: 20260116-143055
3. Собирает путь: .claude/logs/ProjectName-bug-20260116-143055.md

Результат: уникальное имя файла для каждого отчёта.
```

### For MEDIUM code:

**Sections:**
1. **Общий обзор** (1-2 предложения)
2. **Пошаговое объяснение** (ключевые блоки)
3. **Edge cases** (если есть обработка ошибок)

**Skip:**
- Подробные паттерны (unless important)
- Альтернативные подходы (unless asked)
- Концепции (unless non-obvious)

### For COMPLEX code:

**Full breakdown with all sections:**

1. **Общий обзор:**
   - Что делает этот код?
   - Какова его роль в проекте?
   - С чем он взаимодействует?

2. **Пошаговое объяснение:**
   - Разбери код построчно или по блокам
   - Объясни логику
   - Укажи на важные детали

3. **Концепции и паттерны:**
   - Какие концепции используются?
   - Какие паттерны проектирования?
   - Почему выбран этот подход?

4. **Data flow:**
   - Как данные входят?
   - Как преобразуются?
   - Что возвращается?

5. **Зависимости:**
   - Какие внешние зависимости?
   - Какие внутренние модули используются?
   - Какие side effects?

6. **Edge cases:**
   - Как обрабатываются ошибки?
   - Что происходит в граничных случаях?
   - Какие ограничения?

7. **Возможные улучшения:**
   - Укажи на потенциальные улучшения
   - Предложи альтернативные подходы

## Guidelines

**Token economy:**
- Simple code → 50-100 tokens response
- Medium code → 200-400 tokens
- Complex code → Full detailed breakdown

**Always:**
- Start with complexity assessment (don't mention it to user)
- Match detail level to code complexity
- Focus on "what" and "why", not just "how"
- Use simple language for complex concepts

**Never:**
- Force all 6 sections for simple code
- Add unnecessary details
- Explain obvious things
- Include improvements unless asked or clearly needed

**Examples:**

Good (simple):
```
User: Explain this code
const name = path.basename(filePath);

Response: Извлекает имя файла из полного пути (убирает директории).
Пример: "/home/user/file.txt" → "file.txt"
```

Bad (simple):
```
[500 lines with all 6 sections for 1 line of code]
```

Good (complex):
```
User: Explain middleware.ts authentication flow

Response: [Full breakdown with all sections, patterns, edge cases]
```
