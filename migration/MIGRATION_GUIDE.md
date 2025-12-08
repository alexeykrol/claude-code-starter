# Установка Claude Code Starter Framework

**Версия:** 2.1.0

## Перед установкой

Убедитесь, что проект использует git:
```bash
git status
```

Если нет — инициализируйте:
```bash
git init
git add .
git commit -m "Initial commit"
```

## Установка

### 1. Скачайте архив

```bash
curl -LO https://github.com/alexeykrol/claude-code-starter/releases/download/v2.1.0/claude-code-starter-v2.1.0.tar.gz
```

### 2. Распакуйте в проекте

```bash
tar -xzf claude-code-starter-v2.1.0.tar.gz
```

### 3. Запустите установку

```bash
./init-project.sh
```

Скрипт автоматически:
- Создаст backup старых файлов (если есть)
- Установит фреймворк
- Создаст commit в git

## После установки

Откройте проект в Claude Code и напишите:
```
start
```

Готово! 🎉

---

**Документация:** https://github.com/alexeykrol/claude-code-starter

**Проблемы?** https://github.com/alexeykrol/claude-code-starter/issues
