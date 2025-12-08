# Migration System — Claude Code Starter Framework

This directory contains the migration and distribution system for Claude Code Starter Framework.

## Purpose

The migration system allows users to:
1. Install the framework into new projects
2. Migrate existing projects to use the framework
3. Upgrade from old framework versions with automatic backup

## Directory Structure

```
migration/
├── init-project.sh              # Main installation script
├── build-distribution.sh        # Creates distribution package
├── MIGRATION_GUIDE.md           # User-facing migration guide
├── FRAMEWORK_GUIDE.template.md  # User guide template
│
├── templates/                   # Meta file templates
│   ├── SNAPSHOT.template.md
│   ├── BACKLOG.template.md
│   └── ARCHITECTURE.template.md
│
├── scripts/                     # Helper scripts (future)
│   ├── detect-project.sh
│   ├── backup-old-fw.sh
│   └── analyze-legacy.js
│
└── README.md                    # This file
```

## For Framework Developers

### Building Distribution

1. Ensure framework code is compiled:
   ```bash
   npm run build
   ```

2. Run the distribution builder:
   ```bash
   cd migration
   ./build-distribution.sh
   ```

3. This creates:
   ```
   claude-code-starter-v2.0.5.tar.gz
   claude-code-starter-v2.0.5.tar.gz.sha256
   ```

### What Gets Packaged

The distribution includes:
- `CLAUDE.md` — Framework protocols
- `FRAMEWORK_GUIDE.md` — Usage guide
- `.claude/dist/` — Compiled framework code
- `.claude/commands/` — All slash commands
- `.claude/templates/` — Meta file templates
- `init-project.sh` — Installation script
- `MIGRATION_GUIDE.md` — Installation guide

### Testing Distribution

```bash
# Create test project
mkdir /tmp/test-project && cd /tmp/test-project
git init

# Extract distribution
tar -xzf /path/to/claude-code-starter-v2.0.5.tar.gz

# Run installation
./init-project.sh

# Verify files
ls -la .claude/
cat CLAUDE.md
cat FRAMEWORK_GUIDE.md
```

## Installation Flow

### New Project
1. User runs `init-project.sh`
2. Script detects "new" project (no existing files)
3. Installs framework files
4. Generates empty meta files from templates
5. Commits installation

### Legacy Project
1. User runs `init-project.sh`
2. Script detects "legacy" project (existing code)
3. Analyzes project structure
4. Detects old framework (if exists)
5. Creates backup → `.claude/.backup-{timestamp}/`
6. **Commits backup to git**
7. Removes old framework files
8. Installs new framework files
9. Generates meta files with project data
10. Updates README with framework link
11. Commits migration

### Old Framework Detected
1. Script finds old CLAUDE.md or .claude/ files
2. Backs up all old files
3. Commits backup (critical for rollback!)
4. Migrates what it can (project context, tasks)
5. Creates migration report
6. Commits new installation

## Template System

### Variables in Templates

Templates use `{{VARIABLE}}` syntax:
- `{{PROJECT_NAME}}` — From directory name
- `{{DATE}}` — Current date
- `{{PROJECT_VERSION}}` — From package.json
- `{{CURRENT_BRANCH}}` — From git
- `{{PROJECT_DESCRIPTION}}` — From package.json or README.md
- `{{TECH_STACK}}` — Detected from project files
- `{{PROJECT_STRUCTURE}}` — From tree or ls

### Adding New Templates

1. Create template in `templates/`
2. Use `{{VARIABLES}}` for dynamic content
3. Update `init-project.sh` to generate the file
4. Add variable substitution logic

## Safety Features

### Automatic Backup
- All old framework files backed up before changes
- Backup committed to git (can rollback)
- Backup path: `.claude/.backup-YYYYMMDD-HHMMSS/`

### Git Integration
- Requires git repository
- Commits backup before migration
- Commits installation after migration
- All changes tracked in git history

### Rollback
Users can rollback with:
```bash
git reset --hard HEAD~2  # Removes migration and backup commits
git revert HEAD          # Reverts only migration commit
```

## Version Management

### Current Version
Version is hardcoded in:
- `init-project.sh` (line 9)
- `build-distribution.sh` (line 9)
- `MIGRATION_GUIDE.md` (line 3)

### Updating Version
1. Update version in all three files
2. Update CHANGELOG.md
3. Run `build-distribution.sh`
4. Create GitHub release
5. Upload .tar.gz and .sha256 files

## Future Enhancements

### Planned Features
- [ ] Upgrade script (`upgrade-from-v2.0.sh`)
- [ ] Project analysis CLI (`node scripts/analyze-legacy.js`)
- [ ] Custom template support
- [ ] Interactive installation mode
- [ ] Migration validation tests

### Version-Specific Migrations
```
migration/
├── v2.0/                        # Current version
│   ├── init-project.sh
│   └── ...
├── v2.1/                        # Future version
│   ├── init-project.sh
│   ├── upgrade-from-v2.0.sh    # Upgrade script
│   └── ...
└── current -> v2.0/            # Symlink
```

## Troubleshooting

### Build Fails
```bash
# Ensure code is compiled
cd ../src/claude-export
npm run build
cd ../../migration
./build-distribution.sh
```

### Installation Fails
- Check git is initialized
- Check file permissions (chmod +x init-project.sh)
- Check for missing dependencies (tree, jq, rg are optional)

### Templates Not Substituted
- Check variable names match `{{VARIABLE}}`
- Check sed commands in `init-project.sh`
- Test substitution manually:
  ```bash
  sed 's/{{PROJECT_NAME}}/test/g' templates/SNAPSHOT.template.md
  ```

## Contributing

When adding to migration system:
1. Test on multiple project types (new, legacy, with old FW)
2. Test rollback scenarios
3. Update this README
4. Update MIGRATION_GUIDE.md if user-facing

## Documentation

- **MIGRATION_GUIDE.md** — For users installing framework
- **FRAMEWORK_GUIDE.template.md** — For users using framework
- **README.md** — This file, for developers

---
*Last updated: 2025-12-07*
