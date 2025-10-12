#!/bin/bash

# Claude Code Starter - Smart Project Initialization Script
# Version: 1.2.0
# Usage: bash init-project.sh [--lang=ru|en]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default language
LANG="ru"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --lang=en)
            LANG="en"
            ;;
        --lang=ru)
            LANG="ru"
            ;;
        --help)
            echo "Usage: bash init-project.sh [--lang=ru|en]"
            echo ""
            echo "Options:"
            echo "  --lang=ru    Use Russian templates (default)"
            echo "  --lang=en    Use English templates"
            exit 0
            ;;
    esac
done

# Set zip file name based on language
if [ "$LANG" = "ru" ]; then
    ZIP_FILE="init-starter.zip"
    TEMPLATES_DIR="Init"
else
    ZIP_FILE="init-starter-en.zip"
    TEMPLATES_DIR="init_eng"
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Starter - Project Initialization        ║${NC}"
echo -e "${BLUE}║                    Version 1.2.0                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Confirm current directory
echo -e "${YELLOW}📂 Текущая папка:${NC} $(pwd)"
echo ""
read -p "Это папка вашего проекта? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Сначала перейдите в папку проекта:${NC}"
    echo "   cd /path/to/your/project"
    echo "   bash init-project.sh"
    exit 1
fi

echo ""

# Step 2: Check if zip file exists
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ Ошибка: Файл $ZIP_FILE не найден в текущей папке${NC}"
    echo ""
    echo "Убедитесь что:"
    echo "  1. Вы скопировали $ZIP_FILE в папку проекта"
    echo "  2. Файл называется именно $ZIP_FILE"
    exit 1
fi

# Step 3: Check if unzip is available
if ! command -v unzip &> /dev/null; then
    echo -e "${RED}❌ Ошибка: команда 'unzip' не найдена${NC}"
    echo ""
    echo "Установите unzip:"
    echo "  macOS: brew install unzip"
    echo "  Ubuntu/Debian: sudo apt-get install unzip"
    exit 1
fi

# Step 4: Extract templates
echo -e "${BLUE}📦 Распаковка шаблонов...${NC}"
unzip -q "$ZIP_FILE"

if [ ! -d "$TEMPLATES_DIR" ]; then
    echo -e "${RED}❌ Ошибка: Папка $TEMPLATES_DIR не найдена после распаковки${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Шаблоны распакованы${NC}"
echo ""

# Step 5: Detect project type (new vs legacy)
echo -e "${BLUE}🔍 Анализ проекта...${NC}"

# Count files (excluding .git, init directory, and this script)
FILE_COUNT=$(find . -maxdepth 1 -type f ! -name 'init-project.sh' ! -name "$ZIP_FILE" | wc -l | tr -d ' ')
DIR_COUNT=$(find . -maxdepth 1 -type d ! -name '.' ! -name '.git' ! -name "$TEMPLATES_DIR" | wc -l | tr -d ' ')
TOTAL_COUNT=$((FILE_COUNT + DIR_COUNT))

if [ $TOTAL_COUNT -eq 0 ]; then
    # New project scenario
    echo -e "${GREEN}✨ Обнаружен НОВЫЙ проект (папка пустая)${NC}"
    echo ""
    echo -e "${BLUE}🚀 Установка шаблонов...${NC}"

    # Copy all files from templates directory to current directory
    cp -r "$TEMPLATES_DIR/." .

    # Remove the templates directory
    rm -rf "$TEMPLATES_DIR"

    # Remove the zip file
    rm "$ZIP_FILE"

    echo -e "${GREEN}✅ Шаблоны установлены!${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 Готово!                              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📋 Следующие шаги:${NC}"
    echo ""
    echo "  1. Переименуйте README шаблон:"
    echo -e "     ${BLUE}mv README-TEMPLATE.md README.md${NC}"
    echo ""
    echo "  2. Заполните PROJECT_INTAKE.md:"
    echo -e "     ${BLUE}code PROJECT_INTAKE.md${NC}  # или любой редактор"
    echo ""
    echo "  3. Запустите Claude Code:"
    echo -e "     ${BLUE}claude${NC}"
    echo ""
    echo "  4. В Claude попросите:"
    echo -e "     ${BLUE}\"Прочитай PROJECT_INTAKE.md и задай уточняющие вопросы\"${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Не забудьте:${NC}"
    echo "  - Создать .env.local из .env.example"
    echo "  - Прочитать SECURITY.md перед началом разработки"
    echo ""

else
    # Legacy project scenario
    echo -e "${YELLOW}📂 Обнаружен СУЩЕСТВУЮЩИЙ проект (найдено файлов/папок: $TOTAL_COUNT)${NC}"
    echo ""

    # Copy CLAUDE.md to root for auto-loading
    if [ ! -f "CLAUDE.md" ]; then
        cp "$TEMPLATES_DIR/CLAUDE.md" ./CLAUDE.md
        echo -e "${GREEN}✅ CLAUDE.md скопирован в корень для автозагрузки${NC}"
    else
        echo -e "${YELLOW}⚠️  CLAUDE.md уже существует, пропускаем копирование${NC}"
    fi

    echo -e "${GREEN}✅ Шаблоны готовы в папке: $TEMPLATES_DIR/${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              📋 Миграция Legacy Проекта                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}📋 Следующие шаги:${NC}"
    echo ""
    echo "  1. (Опционально) Создайте .migrationignore для исключения файлов:"
    echo -e "     ${BLUE}cp $TEMPLATES_DIR/.migrationignore.example .migrationignore${NC}"
    echo "     Отредактируйте .migrationignore (исключите статьи, заметки и т.д.)"
    echo ""
    echo "  2. Запустите Claude Code:"
    echo -e "     ${BLUE}claude${NC}"
    echo ""
    echo "  3. В Claude выполните команду миграции:"
    echo -e "     ${BLUE}/migrate${NC}"
    echo ""
    echo "  4. Следуйте инструкциям миграции:"
    echo "     - Проверьте MIGRATION_REPORT.md"
    echo "     - Разрешите конфликты (если есть): /migrate-resolve"
    echo "     - Финализируйте: /migrate-finalize"
    echo ""
    echo -e "${YELLOW}ℹ️  Подробнее о миграции:${NC}"
    echo -e "   См. ${BLUE}$TEMPLATES_DIR/MIGRATION.md${NC}"
    echo ""

fi

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
