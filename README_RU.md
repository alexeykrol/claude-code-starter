# Claude Code Starter

Двуагентный мета-фреймворк для структурированной AI-разработки с **Claude Code** и **Codex**.

> Название репозитория `claude-code-starter` сохранено для обратной совместимости.

[![GitHub](https://img.shields.io/badge/GitHub-claude--code--starter-blue)](https://github.com/alexeykrol/claude-code-starter)
[![Version](https://img.shields.io/badge/version-4.0.0-orange.svg)](https://github.com/alexeykrol/claude-code-starter)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

> **EN version:** [README.md](README.md)

## Что нового в v4.0.0

- Полноценная **двуагентная** архитектура: Claude-ветка + Codex-ветка в одном фреймворке.
- Общий контракт состояния: `.claude/SNAPSHOT.md`, `.claude/BACKLOG.md`, `.claude/ARCHITECTURE.md`.
- Аддитивная установка: текущий Claude-контур не ломается, Codex добавляется параллельно.
- В Codex `start` поддерживает авто-роутинг миграции/апгрейда и автообновление фреймворка.
- Миграция улучшена: legacy/upgrade могут формировать содержательные memory-файлы из материалов проекта.

## Для пользователей

### Требования

- Node.js 18+
- Python 3.x

Проверка:

```bash
node --version
python3 --version
```

### Установка в любой host-проект

1. Скопируйте `init-project.sh` в корень host-проекта.
2. Запустите установщик:

```bash
./init-project.sh
```

3. Запустите предпочитаемый агент в этом проекте:
- `codex`
- `claude`

4. Запуск протокола:
- `start`

5. Завершение протокола:
- `/fi`

## Рабочий цикл

### Start

Команда `start` выполняет cold start:

- роутинг миграции/апгрейда (на первом запуске),
- проверку crash/session,
- загрузку общего контекста,
- проверку версии фреймворка (с автообновлением при необходимости).

### Finish

Команда `/fi` выполняет completion:

- security/export проверки,
- git status/diff проверки,
- финализацию сессии.

## Структура фреймворка

```text
claude-code-starter/
├── CLAUDE.md                    # Точка входа для Claude
├── AGENTS.md                    # Точка входа для Codex
├── init-project.sh              # Установщик для host-проектов
├── quick-update.sh              # Апдейтер в host-проектах
├── CHANGELOG.md
├── README.md
├── README_RU.md
├── .claude/
│   ├── commands/                # Claude workflows/prompts
│   ├── protocols/               # Silent protocol specs
│   └── templates/               # Шаблоны состояния/конфига
├── .codex/
│   ├── commands/                # Исполняемые Codex workflows
│   └── contracts/
├── src/framework-core/          # Общий Python runtime (cold-start/completion)
├── security/                    # Security scan/cleanup скрипты
└── migration/                   # Сборка и релизные скрипты
```

## Режимы миграции

Установщик автоматически определяет тип host-проекта:

- `new` — инициализация в новом проекте,
- `legacy` — миграция существующего проекта,
- `upgrade` — апгрейд со старой версии фреймворка.

Во всех режимах бизнес-код host-проекта не должен разрушаться.

## Модель обновления

- В `start` встроена проверка версии.
- Если доступна новая версия и есть апдейтер, обновление применяется автоматически.
- Пакет обновления включает обе ветки (Claude + Codex), чтобы сохранить parity.

## Для разработчиков фреймворка

### Подготовка

```bash
git clone https://github.com/alexeykrol/claude-code-starter.git
cd claude-code-starter
npm install
npm run build
```

### Сборка дистрибутива

```bash
bash migration/build-distribution.sh
```

Артефакты создаются в `dist-release/`:

- `init-project.sh`
- `framework.tar.gz`
- `framework-commands.tar.gz`
- `quick-update.sh`

## Версионирование

- Используется Semantic Versioning.
- `4.0.0` — major-релиз, так как фреймворк перешёл от single-agent к dual-agent контракту.

Подробности см. в [CHANGELOG.md](CHANGELOG.md).

## Contributing

1. Создайте ветку
2. Внесите изменения
3. Прогоните локальные проверки/сборку
4. Откройте PR

---

Цель фреймворка: дать пользователю выбор агента при едином состоянии проекта и единой модели протоколов.
