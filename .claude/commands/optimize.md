---
description: Оптимизировать производительность кода
---

Помоги оптимизировать производительность указанного кода.

**Области оптимизации:**

## 1. React Performance

**Проверь:**
- [ ] Нет ли лишних ре-рендеров
- [ ] Используется ли мемоизация (`useMemo`, `useCallback`)
- [ ] Правильно ли используются keys в списках
- [ ] Можно ли использовать React.memo
- [ ] Нет ли создания объектов/функций в рендере

**Оптимизации:**
```typescript
// ❌ Плохо
function Component() {
  return <Child onClick={() => {}} data={{}} />
}

// ✅ Хорошо
const EMPTY_DATA = {}
function Component() {
  const handleClick = useCallback(() => {}, [])
  return <Child onClick={handleClick} data={EMPTY_DATA} />
}
```

## 2. Database Queries

**Проверь:**
- [ ] Запрашиваются только нужные поля
- [ ] Используются индексы
- [ ] Нет N+1 проблем
- [ ] Используется pagination
- [ ] Есть ли лимиты на выборку

**Оптимизации:**
```typescript
// ❌ Плохо
const { data } = await supabase.from('chats').select('*')

// ✅ Хорошо
const { data } = await supabase
  .from('chats')
  .select('id, title, created_at')
  .limit(20)
  .order('created_at', { ascending: false })
```

## 3. Bundle Size

**Проверь:**
- [ ] Используются ли dynamic imports
- [ ] Нет ли лишних зависимостей
- [ ] Оптимизированы ли изображения
- [ ] Используется ли tree shaking

**Оптимизации:**
```typescript
// ❌ Плохо
import HeavyLibrary from 'heavy-library'

// ✅ Хорошо
const HeavyLibrary = dynamic(() => import('heavy-library'), {
  loading: () => <Spinner />
})
```

## 4. Caching

**Проверь:**
- [ ] Используется ли React cache
- [ ] Правильно ли работает revalidation
- [ ] Используется ли SWR/React Query
- [ ] Кэшируются ли статические данные

## 5. Network

**Проверь:**
- [ ] Объединены ли похожие запросы
- [ ] Используется ли параллельная загрузка
- [ ] Есть ли prefetching
- [ ] Оптимизирован ли размер ответов

## 6. Images & Media

**Проверь:**
- [ ] Используется ли next/image
- [ ] Правильные ли размеры изображений
- [ ] Используется ли lazy loading
- [ ] Форматы оптимизированы (WebP)

**Процесс оптимизации:**

1. **Измерь:**
   - Используй React DevTools Profiler
   - Проверь Network tab
   - Запусти Lighthouse
   - Измерь время выполнения

2. **Найди bottleneck:**
   - Что занимает больше всего времени?
   - Где происходят лишние вычисления?
   - Где медленные запросы?

3. **Оптимизируй:**
   - Начни с самого медленного
   - Делай по одному изменению
   - Измеряй после каждого изменения

4. **Проверь:**
   - Функциональность сохранена
   - Производительность улучшилась
   - Нет новых проблем

**Метрики для отслеживания:**
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Time to Interactive (TTI)
- Cumulative Layout Shift (CLS)
- Total Blocking Time (TBT)

**В конце дай:**
- Список найденных проблем
- Приоритет оптимизаций
- Ожидаемое улучшение
- Конкретный код для изменений
