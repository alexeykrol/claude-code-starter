# Правило: Dialog Preservation (content)

Claude Code пишет полный JSONL текущей сессии в `~/.claude/projects/<encoded-cwd>/`. Эти файлы со временем удаляются retention'ом. Чтобы не потерять ценные обсуждения — методологию, archaeology решений, антипаттерны — копируй интересные сессии в `.claude/dialogs/` и веди реестр в `.claude/dialogs/INDEX.md`. Автоматика: при `/finish` диалог сохраняется сам; явно — через `/save-dialog`. В `repo_access=private-solo` архив можно коммитить; в `private-shared`/`public` — оставлять локально и чистить от секретов перед любой публикацией.

Полное описание поведения, формата INDEX, политики по repo_access и ритма анализа — в глобальном правиле `~/.claude/rules/dialog-preservation.md`.
