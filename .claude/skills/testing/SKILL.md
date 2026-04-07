---
name: testing
description: "Запуск тестов проекта: unit, integration. Определение типа проекта и выбор стратегии."
allowed-tools: Read Glob Grep Bash
disable-model-invocation: true
---

# Skill: Testing

## Определение тестового окружения

```bash
# Node.js проект
if [ -f "package.json" ]; then
  echo "node"
  cat package.json | grep -A5 '"scripts"' | grep test
fi

# Python проект
if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
  echo "python"
fi
```

## Запуск тестов

### Node.js
```bash
npm test
```

### Python
```bash
python3 -m pytest tests/ -v
```

## Интерпретация результатов

- **Все зелёные:** сообщить «тесты пройдены» с количеством
- **Есть красные:** показать список упавших тестов, предложить фикс
- **Нет тестов:** сообщить, предложить создать базовый набор

## Когда запускать

- После каждого серьёзного коммита
- В составе `/finish`
- По явному запросу пользователя
- После работы субагента `implementer`

## Coverage (если настроен)

```bash
# Node.js
npx jest --coverage 2>/dev/null || true

# Python
python3 -m pytest --cov=src tests/ 2>/dev/null || true
```

Показать summary coverage, если доступен.
