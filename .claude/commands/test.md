---
description: Помочь написать тесты для кода
---

Помоги написать тесты для указанного кода.

**Стратегия тестирования:**

1. **Определи тип теста:**
   - Unit тест (функция, хук)
   - Component тест (UI компонент)
   - Integration тест (Server Action, API)
   - E2E тест (user flow)

2. **Определи что тестировать:**
   - Happy path (основной сценарий)
   - Edge cases (граничные случаи)
   - Error cases (обработка ошибок)
   - Различные входные данные

3. **Настрой окружение:**
   - Необходимые моки (Supabase, OpenAI, etc)
   - Test data
   - Helpers

4. **Напиши тесты:**
   - Arrange (подготовка)
   - Act (действие)
   - Assert (проверка)

5. **Покрытие:**
   - Все основные сценарии покрыты
   - Edge cases учтены
   - Ошибки обрабатываются

**Пример структуры:**

```typescript
describe('ComponentName', () => {
  describe('when user is authenticated', () => {
    it('should render correctly', () => {
      // test
    })

    it('should handle submit', () => {
      // test
    })
  })

  describe('when user is not authenticated', () => {
    it('should redirect to login', () => {
      // test
    })
  })

  describe('error handling', () => {
    it('should show error message on failure', () => {
      // test
    })
  })
})
```

**Best practices:**
- Тестируй поведение, не реализацию
- Используй понятные названия тестов
- Изолируй тесты друг от друга
- Мокируй внешние зависимости
- Проверяй как success, так и error cases

См. `.claude/testing-guide.md` для подробностей.
