# Отчёт об ошибках фреймворка Claude Code Starter v2.1.1

**Дата:** 2025-12-08
**Проект тестирования:** chatRAG
**Версия фреймворка:** Claude Code Starter v2.1.1 / Claude Export v2.2.2-v2.3.0
**Автор отчёта:** Claude (Opus 4.5)

---

## Сводная таблица ошибок

| # | Файл | Ошибка | Критичность | Статус |
|---|------|--------|-------------|--------|
| 1 | `package.json` | dialog:ui не запускает сервер | Высокая | Исправлено |
| 2 | `watcher.js:120` | Паразитные папки проектов | Высокая | Исправлено |
| 3 | `template.html` | Статический HTML не работает | Средняя | Исправлено |

---

## Ошибка #1: Неработающий скрипт `dialog:ui`

### Файл
`package.json`

### Симптомы
При запуске `npm run dialog:ui`:
- Процесс завершался мгновенно без вывода
- Сервер не стартовал
- Порт 3333 не прослушивался
- Никаких ошибок в консоли

### Диагностика
```bash
npm run dialog:ui
# Выводит только:
# > chatrag@1.6.0 dialog:ui
# > node .claude/dist/claude-export/server.js
# (процесс завершается)
```

### Причина
Скрипт указывал напрямую на файл `server.js`, который **экспортирует функцию** `startServer()`, но **не вызывает её при запуске**:

```json
// БЫЛО (неправильно):
"dialog:ui": "node .claude/dist/claude-export/server.js"
```

Содержимое `server.js` (конец файла):
```javascript
function startServer(port = 3333, projectPath, outputDir) {
    // ... код сервера ...
    app.listen(port, () => {
        console.log('Claude Export UI');
        // ...
    });
}
exports.startServer = startServer;  // экспортирует, но не вызывает!
```

При запуске `node server.js`:
1. Файл загружается
2. Функция `startServer` определяется и экспортируется
3. Процесс завершается (функция не вызвана)

### Исправление
Изменил скрипт на вызов через CLI, который правильно обрабатывает команду `ui` и вызывает `startServer()`:

```json
// СТАЛО (правильно):
"dialog:ui": "node .claude/dist/claude-export/cli.js ui"
```

Код в `cli.js` (строки ~50-55):
```javascript
case 'ui':
case 'server':
case 'u':
    const port = parseInt(options.port) || 3333;
    startServer(port, projectPath, options.output);  // вызывает функцию!
    break;
```

### Результат после исправления
```bash
npm run dialog:ui
# Выводит:
# ════════════════════════════════════════════════════════════
#   Claude Export UI
# ════════════════════════════════════════════════════════════
#   URL:      http://localhost:3333
#   Source:   /Users/.../chatRAG
#   Dialogs:  /Users/.../chatRAG/dialog
# ════════════════════════════════════════════════════════════
```

### Рекомендация для фреймворка
При генерации `package.json` через `init-project.sh` или при копировании конфигов нужно использовать CLI вместо прямого вызова `server.js`:

**Файлы для исправления:**
- `init-project.sh` — шаблон package.json
- Документация — примеры npm scripts
- README.md — инструкции по установке

---

## Ошибка #2: Создание паразитных папок проектов в `~/.claude/projects/`

### Файл
`.claude/dist/claude-export/watcher.js` (строка 120)
**Исходник:** `src/claude-export/watcher.ts` (примерно строка 90-130)

### Симптомы
При работе фреймворка в `~/.claude/projects/` создавались **паразитные папки** с суффиксом `-dialog`:

```bash
ls ~/.claude/projects/ | grep chatRAG
# Результат:
-Users-alexeykrolmini-Downloads-Code-chatRAG        # легитимная
-Users-alexeykrolmini-Downloads-Code-chatRAG-dialog # паразитная!
```

Последствия:
- Сессии записывались в неправильный проект
- UI показывал сессии из разных проектов
- Путаница и потеря данных
- Расход дискового пространства

### Диагностика
```bash
# Проверка содержимого паразитной папки
ls ~/.claude/projects/-Users-...-chatRAG-dialog/
# 221979c3-16bb-4ae6-8346-ef85fb0619ca.jsonl
# 614809c5-c977-4e9b-ac54-15cca2b035bd.jsonl
# ... агенты и сессии, которые должны быть в основном проекте
```

### Причина
При генерации summary для диалогов фреймворк вызывает Claude через `spawn()` с параметром `cwd`:

```javascript
// watcher.js, строки 112-121:
const claude = spawn('claude', [
    '-p',
    '--dangerously-skip-permissions',
    '--model', 'haiku',
    '--tools', 'Read,Edit'
], {
    stdio: ['pipe', 'pipe', 'pipe'],
    shell: false,
    cwd: path.dirname(dialogPath)  // ПРОБЛЕМА ЗДЕСЬ!
});
```

Логика ошибки:
- `dialogPath` = `/Users/.../chatRAG/dialog/2025-12-08_session-xxx.md`
- `path.dirname(dialogPath)` = `/Users/.../chatRAG/dialog/`
- Claude Code видит `cwd = chatRAG/dialog/`
- Claude Code создаёт проект для этой директории: `chatRAG-dialog`

### Исправление
Изменил `cwd` на родительскую директорию (корень проекта):

```javascript
// watcher.js, строки 117-122:
], {
    stdio: ['pipe', 'pipe', 'pipe'],
    shell: false,
    // Fix: use project root, not dialog/ folder to avoid creating parasitic project
    cwd: path.dirname(path.dirname(dialogPath))  // = /project/
});
```

Логика исправления:
- `dialogPath` = `/Users/.../chatRAG/dialog/2025-12-08_session-xxx.md`
- `path.dirname(dialogPath)` = `/Users/.../chatRAG/dialog/`
- `path.dirname(path.dirname(dialogPath))` = `/Users/.../chatRAG/` ✓

### Очистка после исправления
```bash
# Удаление паразитной папки
rm -rf ~/.claude/projects/-Users-...-chatRAG-dialog/
```

### Рекомендация для фреймворка
**Файл для исправления:**
`src/claude-export/watcher.ts` — функция генерации summary

**Изменение:**
```typescript
// БЫЛО:
cwd: path.dirname(dialogPath)

// ДОЛЖНО БЫТЬ:
cwd: path.dirname(path.dirname(dialogPath))
```

---

## Ошибка #3: Статический HTML viewer не работает при открытии через `file://`

### Файл
`html-viewer/template.html`

### Симптомы
При открытии `html-viewer/index.html` через `file://` протокол (двойной клик в Finder/Explorer):
- Ошибка в консоли: `Error: NetworkError when attempting to fetch resource.`
- Список диалогов пустой
- UI загружается, но данные не отображаются

### Диагностика
```bash
# Проверка на fetch-вызовы в шаблоне
grep -c "fetch\|/api/" html-viewer/template.html
# Результат: 14 (!)

# Проверка на placeholder'ы
grep "__DIALOGS_DATA__" html-viewer/template.html
# Результат: пусто (placeholder'ов нет!)
```

### Причина
Шаблон `template.html` был **копией серверного HTML** (`public/index.html`), который использовал fetch-вызовы к API:

```javascript
// В template.html было:
async function loadSessions() {
    const res = await fetch('/api/dialogs');  // требует сервер!
    const data = await res.json();
    sessions = data.dialogs;
    // ...
}

async function selectSession(filename) {
    const res = await fetch(`/api/dialog/${filename}`);  // требует сервер!
    // ...
}
```

Эти API endpoints работают **только при запущенном сервере** (`npm run dialog:ui`).

Код в `exporter.js` пытался заменить placeholder'ы, но их **не было в шаблоне**:

```javascript
// exporter.js (строки 793-801):
template = template.replace('__DIALOGS_DATA__', dialogsDataJson);
template = template.replace('__PROJECT_INFO__', JSON.stringify(projectInfo));
template = template.replace('__VERSION__', 'v2.3.0');
// ... но в template.html не было этих placeholder'ов!
```

### Исправление
Полностью переписал `template.html` для статического использования:

#### 1. Добавил placeholder'ы для встраивания данных:
```javascript
// В <script> секции:
const DIALOGS_DATA = __DIALOGS_DATA__;
const PROJECT_INFO = __PROJECT_INFO__;
```

#### 2. Убрал все fetch-вызовы, заменив на использование встроенных данных:
```javascript
// БЫЛО:
async function loadSessions() {
    const res = await fetch('/api/dialogs');
    const data = await res.json();
    dialogs = data.dialogs;
}

// СТАЛО:
document.addEventListener('DOMContentLoaded', () => {
    dialogs = DIALOGS_DATA;  // данные уже встроены в HTML
    filteredDialogs = dialogs;
    renderDialogs();
});
```

#### 3. Добавил placeholder'ы для метаданных:
```html
<title>Claude Export - __PROJECT_NAME__</title>
<h1>Claude Export <span>__VERSION__ · __DATE__</span></h1>
<footer>Generated: __DATETIME__ · ...</footer>
```

#### 4. Убрал серверные функции:
- Кнопка "Force Sync" — требует API `/api/force-export`
- Toggle visibility — требует API `/api/dialog/visibility`
- Auto-refresh каждые 10 секунд — бессмысленно для статического файла
- Кнопка "Помощь" с загрузкой help.md — требует сервер

#### 5. Упростил поиск для работы с встроенными данными:
```javascript
function filterDialogs() {
    const query = document.getElementById('searchBox').value.toLowerCase();
    filteredDialogs = dialogs.filter(d => {
        if (!query) return true;
        const inSummary = (d.summary || '').toLowerCase().includes(query);
        const inContent = (d.content || '').toLowerCase().includes(query);
        const inFilename = d.filename.toLowerCase().includes(query);
        return inSummary || inContent || inFilename;
    });
    renderDialogs();
}
```

### Результат после исправления
```bash
# Размер файла до исправления
ls -lh html-viewer/index.html
# 34K (данные не встроены)

# Размер файла после исправления
ls -lh html-viewer/index.html
# 105K (данные диалогов встроены)

# Проверка на встроенные данные
grep -o "DIALOGS_DATA = \[" html-viewer/index.html
# DIALOGS_DATA = [  ✓
```

### Дополнительное исправление: .gitignore
```gitignore
# Dialog export (gitignored by default)
dialog/
html-viewer/
!html-viewer/template.html  # шаблон нужен для генерации
```

### Рекомендация для фреймворка
**Архитектурное решение:** Разделить HTML шаблоны на два файла:

1. `src/claude-export/public/index.html` — **серверный** (оставить как есть)
   - Использует fetch API
   - Работает с `npm run dialog:ui`
   - Интерактивные функции (visibility toggle, force sync)

2. `src/claude-export/static-template.html` — **статический** (создать новый)
   - Содержит placeholder'ы `__DIALOGS_DATA__`, `__PROJECT_INFO__` и т.д.
   - Работает при открытии через `file://`
   - Только просмотр и поиск

3. `src/claude-export/exporter.ts` — функция `generateStaticHtml()`
   - Должна использовать `static-template.html`
   - Функция `getTemplatePath()` должна указывать на правильный шаблон

---

## Полный список изменённых файлов

### В проекте chatRAG (тестовый проект):
| Файл | Изменение |
|------|-----------|
| `package.json` | Исправлен скрипт `dialog:ui` |
| `.claude/dist/claude-export/watcher.js` | Исправлен `cwd` для spawn |
| `html-viewer/template.html` | Полностью переписан для статического использования |
| `.gitignore` | Добавлено исключение для `template.html` |

### Рекомендации для фреймворка Claude Code Starter:
| Файл | Требуемое изменение |
|------|---------------------|
| `init-project.sh` | Исправить шаблон package.json |
| `src/claude-export/watcher.ts` | Исправить `cwd` в функции summary |
| `src/claude-export/static-template.html` | Создать новый статический шаблон |
| `src/claude-export/exporter.ts` | Обновить `getTemplatePath()` |

---

## Воспроизведение ошибок

### Ошибка #1 (dialog:ui):
```bash
# В package.json установить:
"dialog:ui": "node .claude/dist/claude-export/server.js"

# Запустить:
npm run dialog:ui
# Результат: процесс завершается без запуска сервера
```

### Ошибка #2 (паразитные папки):
```bash
# Экспортировать диалоги несколько раз
npm run dialog:export

# Проверить ~/.claude/projects/
ls ~/.claude/projects/ | grep -E "project-name|project-name-dialog"
# Если есть две папки — баг воспроизведён
```

### Ошибка #3 (статический HTML):
```bash
# Сгенерировать HTML
node .claude/dist/claude-export/cli.js generate-html

# Открыть в браузере через file://
open html-viewer/index.html

# Если список пустой и есть NetworkError — баг воспроизведён
```

---

## Контакты

**Отчёт подготовлен:** Claude (Opus 4.5)
**Дата:** 2025-12-08
**Проект тестирования:** chatRAG v1.6.0
**Репозиторий фреймворка:** Claude Code Starter

---

*Этот отчёт создан для передачи в репозиторий фреймворка Claude Code Starter для внесения исправлений в основную кодовую базу.*
