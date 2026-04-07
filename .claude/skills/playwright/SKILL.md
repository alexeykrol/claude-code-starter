---
name: playwright
description: "E2E тестирование UI с Playwright. Запуск, создание тестов, анализ результатов."
paths:
  - "src/**/*.tsx"
  - "src/**/*.jsx"
  - "src/**/*.vue"
  - "src/**/*.svelte"
  - "pages/**/*"
  - "app/**/*"
  - "tests/e2e/**/*"
  - "e2e/**/*"
allowed-tools: Read Edit Write Glob Grep Bash
disable-model-invocation: true
---

# Skill: Playwright E2E Testing

## Проверка окружения

```bash
# Проверить установлен ли Playwright
npx playwright --version 2>/dev/null || echo "Playwright not installed"
```

Если не установлен:
```bash
npm install -D @playwright/test
npx playwright install chromium
```

## Запуск существующих тестов

```bash
npx playwright test
```

С UI отчётом:
```bash
npx playwright test --reporter=html
```

## Создание нового теста

При создании E2E теста:

1. Определить сценарий (user flow)
2. Создать файл в `tests/e2e/` или `e2e/`
3. Использовать паттерн:

```typescript
import { test, expect } from '@playwright/test';

test('описание сценария', async ({ page }) => {
  await page.goto('/');
  // ... actions
  await expect(page.locator('selector')).toBeVisible();
});
```

## Когда использовать

- После изменений UI-компонентов
- После изменений роутинга
- После изменений форм и интерактивных элементов
- Перед production deploy (обязательно)

## Анализ падений

При падении теста:
1. Показать скриншот ошибки (если есть в `test-results/`)
2. Показать trace (если включен)
3. Определить: баг в коде или устаревший тест
4. Предложить фикс
