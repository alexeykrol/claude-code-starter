---
description: Optimize code performance
---

Help optimize performance of specified code.

**Optimization areas:**

## 1. React Performance

**Check:**
- [ ] No unnecessary re-renders
- [ ] Memoization used (`useMemo`, `useCallback`)
- [ ] Keys used correctly in lists
- [ ] Can React.memo be used
- [ ] No object/function creation in render

**Optimizations:**
```typescript
// ❌ Bad
function Component() {
  return <Child onClick={() => {}} data={{}} />
}

// ✅ Good
const EMPTY_DATA = {}
function Component() {
  const handleClick = useCallback(() => {}, [])
  return <Child onClick={handleClick} data={EMPTY_DATA} />
}
```

## 2. Database Queries

**Check:**
- [ ] Only needed fields requested
- [ ] Indexes used
- [ ] No N+1 problems
- [ ] Pagination used
- [ ] Limits on selection

**Optimizations:**
```typescript
// ❌ Bad
const { data } = await supabase.from('chats').select('*')

// ✅ Good
const { data } = await supabase
  .from('chats')
  .select('id, title, created_at')
  .limit(20)
  .order('created_at', { ascending: false })
```

## 3. Bundle Size

**Check:**
- [ ] Dynamic imports used
- [ ] No unnecessary dependencies
- [ ] Images optimized
- [ ] Tree shaking used

**Optimizations:**
```typescript
// ❌ Bad
import HeavyLibrary from 'heavy-library'

// ✅ Good
const HeavyLibrary = dynamic(() => import('heavy-library'), {
  loading: () => <Spinner />
})
```

## 4. Caching

**Check:**
- [ ] React cache used
- [ ] Revalidation works correctly
- [ ] SWR/React Query used
- [ ] Static data cached

## 5. Network

**Check:**
- [ ] Similar requests combined
- [ ] Parallel loading used
- [ ] Prefetching present
- [ ] Response sizes optimized

## 6. Images & Media

**Check:**
- [ ] next/image used
- [ ] Correct image sizes
- [ ] Lazy loading used
- [ ] Formats optimized (WebP)

**Optimization process:**

1. **Measure:**
   - Use React DevTools Profiler
   - Check Network tab
   - Run Lighthouse
   - Measure execution time

2. **Find bottleneck:**
   - What takes most time?
   - Where are unnecessary calculations?
   - Where are slow queries?

3. **Optimize:**
   - Start with slowest
   - Make one change at a time
   - Measure after each change

4. **Verify:**
   - Functionality preserved
   - Performance improved
   - No new problems

**Metrics to track:**
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Time to Interactive (TTI)
- Cumulative Layout Shift (CLS)
- Total Blocking Time (TBT)

**At the end provide:**
- List of found problems
- Optimization priority
- Expected improvement
- Specific code for changes
