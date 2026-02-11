#!/bin/bash
set -euo pipefail

ROOT_DIR="${FRAMEWORK_ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$ROOT_DIR"

CONTEXT_FILE=".claude/migration-context.json"
LOG_FILE=".claude/migration-log.json"
REPORTS_DIR="reports"
PROJECT_NAME="$(basename "$ROOT_DIR")"
STARTED_AT="$(date -Iseconds)"
END_AT="$STARTED_AT"
BACKUP_DIR=""
OLD_VERSION=""

CREATED_FILES=()
UPDATED_FILES=()
SKIPPED_FILES=()
WARNINGS=()
BACKED_UP_FILES=()
STEPS_COMPLETED=""
CLAUDE_SWAPPED="false"
ARCHIVED_LOG="$REPORTS_DIR/${PROJECT_NAME}-migration-log.json"
MIGRATION_REPORT=""

log() {
  printf "[codex][upgrade-framework] %s\n" "$1"
}

append_step() {
  local step="$1"
  if [ -z "$STEPS_COMPLETED" ]; then
    STEPS_COMPLETED="$step"
  else
    STEPS_COMPLETED="$STEPS_COMPLETED,$step"
  fi
}

write_log() {
  local status="$1"
  local step_num="$2"
  local step_name="$3"
  local last_error="${4:-}"

  python3 - "$LOG_FILE" "$STARTED_AT" "$status" "$step_num" "$step_name" "$STEPS_COMPLETED" "$last_error" "$OLD_VERSION" <<'PY'
import json
import sys
from pathlib import Path

log_file = Path(sys.argv[1])
started = sys.argv[2]
status = sys.argv[3]
step_num = int(sys.argv[4])
step_name = sys.argv[5]
steps_csv = sys.argv[6]
last_error = sys.argv[7] if len(sys.argv) > 7 else ""
old_version = sys.argv[8] if len(sys.argv) > 8 else ""

steps_completed = [s for s in steps_csv.split(",") if s]
payload = {
    "status": status,
    "mode": "upgrade",
    "old_version": old_version or "unknown",
    "started": started,
    "updated": __import__("datetime").datetime.now().astimezone().isoformat(timespec="seconds"),
    "current_step": step_num,
    "current_step_name": step_name,
    "steps_completed": steps_completed,
    "last_error": (last_error or None),
}

log_file.parent.mkdir(parents=True, exist_ok=True)
log_file.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
PY
}

render_template_if_missing() {
  local template_path="$1"
  local target_path="$2"

  if [ -f "$target_path" ]; then
    SKIPPED_FILES+=("$target_path")
    return 0
  fi

  if [ ! -f "$template_path" ]; then
    WARNINGS+=("missing template: $template_path")
    return 0
  fi

  python3 - "$template_path" "$target_path" "$ROOT_DIR" <<'PY'
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

template_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])
root = Path(sys.argv[3])

package = {}
package_json = root / "package.json"
if package_json.exists():
    try:
        package = json.loads(package_json.read_text(encoding="utf-8"))
    except Exception:
        package = {}

def detect_branch() -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=root,
            capture_output=True,
            text=True,
            check=True,
        )
        value = result.stdout.strip()
        if value:
            return value
    except Exception:
        pass
    return "main"

def detect_tech_stack() -> str:
    parts = []
    if (root / "package.json").exists():
        parts.append("- Node.js / npm")
    if (root / "pyproject.toml").exists() or (root / "requirements.txt").exists():
        parts.append("- Python")
    if (root / "Cargo.toml").exists():
        parts.append("- Rust")
    if (root / "go.mod").exists():
        parts.append("- Go")
    if not parts:
        parts.append("- Define stack during first active sprint")
    return "\n".join(parts)

def detect_dependencies() -> str:
    deps = []
    for key in ("dependencies", "devDependencies"):
        raw = package.get(key, {})
        if isinstance(raw, dict):
            deps.extend(sorted(raw.keys()))
    deps = deps[:8]
    if deps:
        return "\n".join(f"- {dep}" for dep in deps)
    return "- Managed by host project package files"

def detect_project_structure() -> str:
    ignored = {
        ".git",
        ".claude",
        ".codex",
        "node_modules",
        "dist",
        "build",
        ".venv",
        "venv",
        "__pycache__",
    }
    entries = []
    try:
        for item in sorted(root.iterdir(), key=lambda p: p.name.lower()):
            name = item.name
            if name in ignored or name.startswith(".DS_Store"):
                continue
            suffix = "/" if item.is_dir() else ""
            entries.append(f"  {name}{suffix}")
            if len(entries) >= 16:
                break
    except Exception:
        pass
    if not entries:
        entries = ["  <project files>"]
    return "\n".join(entries)

replacements = {
    "PROJECT_NAME": root.name,
    "DATE": datetime.now().strftime("%Y-%m-%d"),
    "CURRENT_BRANCH": detect_branch(),
    "PROJECT_VERSION": str(package.get("version", "0.1.0")),
    "PROJECT_DESCRIPTION": str(package.get("description", "Project integrated with framework migration flow.")),
    "TECH_STACK": detect_tech_stack(),
    "PROJECT_STRUCTURE": detect_project_structure(),
    "PROJECT_KEY_CONCEPTS": "- Shared project memory\n- Additive adapter strategy\n- Agent-agnostic lifecycle contract",
    "COMPONENT_1_NAME": "Application Core",
    "COMPONENT_1_PATH": "src/",
    "COMPONENT_1_PURPOSE": "Primary business logic and runtime services.",
    "COMPONENT_2_NAME": "Framework Integration",
    "COMPONENT_2_PATH": ".claude/",
    "COMPONENT_2_PURPOSE": "Project memory files, policies, and lifecycle metadata.",
    "ARCHITECTURE_PATTERN": "Layered modular architecture",
    "PATTERN_DESCRIPTION": "Runtime workflows are separated from project state and adapter logic.",
    "DATA_FLOW_DIAGRAM": "User Action -> Adapter Command -> Framework Core -> Shared State Files",
    "DEPENDENCIES_LIST": detect_dependencies(),
    "ENV_CONFIG": "Use environment files that are excluded from git.",
    "BUILD_CONFIG": "Use native project build tooling from package manifests.",
    "TESTING_STRATEGY": "Run project tests plus framework parity checks on migration artifacts.",
    "DEPLOYMENT_INFO": "Deploy according to host project pipeline; framework files remain in-repo.",
}

content = template_path.read_text(encoding="utf-8")
for key, value in replacements.items():
    content = content.replace("{{" + key + "}}", value)

target_path.parent.mkdir(parents=True, exist_ok=True)
target_path.write_text(content, encoding="utf-8")
PY

  CREATED_FILES+=("$target_path")
}

ensure_text_file_if_missing() {
  local target_path="$1"
  local content="$2"

  if [ -f "$target_path" ]; then
    SKIPPED_FILES+=("$target_path")
    return 0
  fi

  mkdir -p "$(dirname "$target_path")"
  printf "%s\n" "$content" > "$target_path"
  CREATED_FILES+=("$target_path")
}

file_sha256() {
  local target_path="$1"
  if [ ! -f "$target_path" ]; then
    printf ""
    return 0
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$target_path" | awk '{print $1}'
    return 0
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target_path" | awk '{print $1}'
    return 0
  fi

  wc -c < "$target_path" | tr -d '[:space:]'
}

track_generated_state_file() {
  local target_path="$1"
  local existed_before="$2"
  local hash_before="$3"

  if [ ! -f "$target_path" ]; then
    WARNINGS+=("failed to generate: $target_path")
    return 0
  fi

  if [ "$existed_before" -eq 0 ]; then
    CREATED_FILES+=("$target_path")
    return 0
  fi

  local hash_after
  hash_after="$(file_sha256 "$target_path")"
  if [ "$hash_after" != "$hash_before" ]; then
    UPDATED_FILES+=("$target_path")
  else
    SKIPPED_FILES+=("$target_path")
  fi
}

generate_upgrade_memory_files() {
  local snapshot_exists=0 backlog_exists=0 architecture_exists=0 roadmap_exists=0 ideas_exists=0
  local snapshot_hash="" backlog_hash="" architecture_hash="" roadmap_hash="" ideas_hash=""

  if [ -f ".claude/SNAPSHOT.md" ]; then
    snapshot_exists=1
    snapshot_hash="$(file_sha256 ".claude/SNAPSHOT.md")"
  fi
  if [ -f ".claude/BACKLOG.md" ]; then
    backlog_exists=1
    backlog_hash="$(file_sha256 ".claude/BACKLOG.md")"
  fi
  if [ -f ".claude/ARCHITECTURE.md" ]; then
    architecture_exists=1
    architecture_hash="$(file_sha256 ".claude/ARCHITECTURE.md")"
  fi
  if [ -f ".claude/ROADMAP.md" ]; then
    roadmap_exists=1
    roadmap_hash="$(file_sha256 ".claude/ROADMAP.md")"
  fi
  if [ -f ".claude/IDEAS.md" ]; then
    ideas_exists=1
    ideas_hash="$(file_sha256 ".claude/IDEAS.md")"
  fi

  python3 - "$ROOT_DIR" "$OLD_VERSION" <<'PY'
import os
import re
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path

root = Path(sys.argv[1])
old_version = (sys.argv[2] or "").strip() if len(sys.argv) > 2 else ""
state_dir = root / ".claude"
state_dir.mkdir(parents=True, exist_ok=True)

skip_root_dirs = {
    ".git",
    ".claude",
    ".codex",
    "node_modules",
    "dist",
    "build",
    "archive",
    "reports",
    "security",
    ".venv",
    "venv",
    "__pycache__",
}

text_suffixes = {".md", ".txt", ".rst"}
skip_names = {"CLAUDE.md", "AGENTS.md", "FRAMEWORK_GUIDE.md", "COMMIT_POLICY.md"}

def safe_read(path: Path, max_chars: int = 160000) -> str:
    try:
        if path.stat().st_size > 2_000_000:
            return ""
        return path.read_bytes().decode("utf-8", errors="ignore")[:max_chars]
    except Exception:
        return ""

def is_template_like(path: Path) -> bool:
    if not path.exists():
        return True
    text = safe_read(path)
    if not text.strip():
        return True
    lower = text.lower()

    markers = [
        "{{project_description}}",
        "{{tech_stack}}",
        "{{project_structure}}",
        "{{project_key_concepts}}",
        "add your high priority tasks here",
        "add your medium priority tasks here",
        "add your low priority tasks here",
        "add your current tasks here",
        "add your planned tasks here",
        "feature idea 1",
        "improvement idea 1",
        "known bug 1",
        "tech debt item 1",
        "define medium-term milestones for the project",
        "capture future ideas here",
        "move validated ideas to roadmap.md",
        "project integrated with framework migration flow",
    ]

    if "{{" in text and "}}" in text:
        return True
    return any(marker in lower for marker in markers)

def candidate_docs() -> list[Path]:
    docs = []
    roots = [root, root / "docs", root / "documentation", root / "notes", root / "wiki"]
    seen = set()
    for base in roots:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if not path.is_file():
                continue
            rel = path.relative_to(root)
            if rel.parts and rel.parts[0] in skip_root_dirs:
                continue
            if rel.as_posix().startswith("src/framework-core/"):
                continue
            if path.name in skip_names:
                continue
            if path.suffix.lower() in text_suffixes or path.name.lower().startswith("readme"):
                rel_posix = rel.as_posix()
                if rel_posix not in seen:
                    seen.add(rel_posix)
                    docs.append(path)

    def priority(p: Path) -> tuple[int, int]:
        name = p.name.lower()
        score = 9
        if name.startswith("readme"):
            score = 0
        elif "snapshot" in name or "status" in name:
            score = 1
        elif "backlog" in name or "todo" in name or "task" in name:
            score = 2
        elif "architecture" in name or "design" in name:
            score = 3
        elif "roadmap" in name or "plan" in name:
            score = 4
        try:
            size = p.stat().st_size
        except Exception:
            size = 0
        return (score, -size)

    docs.sort(key=priority)
    return docs[:14]

docs = candidate_docs()
doc_snippets = []
for doc in docs:
    text = safe_read(doc)
    if text.strip():
        doc_snippets.append((doc, text))

def first_paragraph(text: str) -> str:
    blocks = [b.strip() for b in re.split(r"\n\s*\n", text) if b.strip()]
    for block in blocks:
        if block.startswith("#"):
            continue
        candidate = " ".join(line.strip() for line in block.splitlines())
        if len(candidate) >= 30:
            return candidate
    return ""

def project_description_from_package() -> str:
    package_json = root / "package.json"
    if not package_json.exists():
        return ""
    try:
        package = json.loads(package_json.read_text(encoding="utf-8"))
    except Exception:
        return ""
    return str(package.get("description", "")).strip()

overview = ""
for _, text in doc_snippets:
    overview = first_paragraph(text)
    if overview:
        break

if not overview:
    overview = project_description_from_package()
if not overview:
    overview = "Framework upgrade completed. State files were regenerated from repository materials."

task_items: list[str] = []
roadmap_items: list[str] = []
idea_items: list[str] = []
heading_notes: list[str] = []

checkbox_re = re.compile(r"^\s*[-*]\s+\[\s\]\s+(.+?)\s*$")
todo_re = re.compile(r"\b(TODO|NEXT|FIXME|MVP|PHASE|MILESTONE)\b", re.IGNORECASE)
roadmap_re = re.compile(r"\b(roadmap|phase|milestone|release|v\d+\.\d+)\b", re.IGNORECASE)
ideas_re = re.compile(r"\b(idea|future|later|could|maybe|wish)\b", re.IGNORECASE)

def normalize_item(value: str) -> str:
    value = re.sub(r"^\s*[-*]\s*", "", value).strip()
    value = re.sub(r"\s+", " ", value)
    return value[:180]

for doc, text in doc_snippets:
    for raw in text.splitlines()[:1400]:
        line = raw.strip()
        if not line:
            continue
        if line.startswith("#"):
            heading = line.lstrip("#").strip()
            if heading and heading not in heading_notes:
                heading_notes.append(heading)
            continue
        checked = checkbox_re.match(line)
        if checked:
            value = normalize_item(checked.group(1))
            if value and value not in task_items:
                task_items.append(value)
            continue
        if todo_re.search(line):
            cleaned = normalize_item(line)
            if cleaned not in task_items:
                task_items.append(cleaned)
        if roadmap_re.search(line):
            cleaned = normalize_item(line)
            if cleaned not in roadmap_items:
                roadmap_items.append(cleaned)
        if ideas_re.search(line):
            cleaned = normalize_item(line)
            if cleaned not in idea_items:
                idea_items.append(cleaned)

task_items = task_items[:20]
roadmap_items = roadmap_items[:20]
idea_items = idea_items[:20]
heading_notes = heading_notes[:20]

def detect_branch() -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=root,
            capture_output=True,
            text=True,
            check=True,
        )
        value = result.stdout.strip()
        if value:
            return value
    except Exception:
        pass
    return "main"

def detect_stack() -> list[str]:
    found = []
    if (root / "package.json").exists():
        found.append("Node.js / npm")
    if (root / "pyproject.toml").exists() or (root / "requirements.txt").exists():
        found.append("Python")
    if (root / "Cargo.toml").exists():
        found.append("Rust")
    if (root / "go.mod").exists():
        found.append("Go")
    if not found:
        found.append("Stack requires manual confirmation")
    return found

def top_level_structure() -> list[str]:
    rows = []
    for item in sorted(root.iterdir(), key=lambda p: p.name.lower()):
        name = item.name
        if name in skip_root_dirs or name.startswith(".DS_Store"):
            continue
        suffix = "/" if item.is_dir() else ""
        rows.append(f"- `{name}{suffix}`")
        if len(rows) >= 20:
            break
    if not rows:
        rows.append("- `<project files>`")
    return rows

def write_if_needed(path: Path, content: str) -> None:
    if is_template_like(path):
        path.write_text(content.strip() + "\n", encoding="utf-8")

project = root.name
today = datetime.now().strftime("%Y-%m-%d")
branch = detect_branch()
docs_list = [f"- `{doc.relative_to(root).as_posix()}`" for doc, _ in doc_snippets[:10]]
if not docs_list:
    docs_list = ["- `<no legacy docs detected>`"]

tasks_block = "\n".join(f"- [ ] {item}" for item in task_items) if task_items else "- [ ] Validate project goals with owner\n- [ ] Define first working sprint"
roadmap_block = "\n".join(f"- {item}" for item in roadmap_items) if roadmap_items else "- Define phased roadmap from repository materials."
ideas_block = "\n".join(f"- {item}" for item in idea_items) if idea_items else "- Capture hypotheses and experiments discovered during upgrade."
headings_block = "\n".join(f"- {item}" for item in heading_notes) if heading_notes else "- No explicit section headings detected in project docs."
stack_block = "\n".join(f"- {item}" for item in detect_stack())
structure_block = "\n".join(top_level_structure())

snapshot = f"""
# SNAPSHOT — {project}

*Last updated: {today}*

## Current State

- Framework mode: framework upgrade
- Previous framework version: `{old_version or "unknown"}`
- Active branch: `{branch}`
- Repository sources analyzed: {len(doc_snippets)}

## Project Overview

{overview}

## Source Documents

{os.linesep.join(docs_list)}

## Current Focus (Inferred)

{tasks_block.splitlines()[0] if tasks_block else "- Define immediate priorities"}
{tasks_block.splitlines()[1] if len(tasks_block.splitlines()) > 1 else ""}
{tasks_block.splitlines()[2] if len(tasks_block.splitlines()) > 2 else ""}
"""

backlog = f"""
# BACKLOG — {project}

*Inferred from repository materials on {today}*

## Active Tasks

{tasks_block}

## Upgrade Follow-Ups

- [ ] Validate generated priorities with the project owner.
- [ ] Confirm security and update policies after migration.
- [ ] Continue work cycles via start/finish protocol.
"""

architecture = f"""
# ARCHITECTURE — {project}

*Generated from detected project artifacts*

## Detected Stack

{stack_block}

## Top-Level Structure

{structure_block}

## Key Topics Found in Project Docs

{headings_block}

## Data / Workflow Notes

- Project memory is stored in `.claude/`.
- Agent adapters execute from `.claude/` (Claude) and `.codex/` (Codex).
- Shared runtime scripts live in `src/framework-core/`.
"""

roadmap = f"""
# ROADMAP — {project}

*Draft roadmap inferred during framework upgrade*

## Candidate Milestones

{roadmap_block}
"""

ideas = f"""
# IDEAS — {project}

*Candidate ideas captured during framework upgrade*

## Candidate Ideas

{ideas_block}
"""

write_if_needed(state_dir / "SNAPSHOT.md", snapshot)
write_if_needed(state_dir / "BACKLOG.md", backlog)
write_if_needed(state_dir / "ARCHITECTURE.md", architecture)
write_if_needed(state_dir / "ROADMAP.md", roadmap)
write_if_needed(state_dir / "IDEAS.md", ideas)
PY

  if [ $? -ne 0 ]; then
    WARNINGS+=("upgrade analysis generation failed")
  fi

  track_generated_state_file ".claude/SNAPSHOT.md" "$snapshot_exists" "$snapshot_hash"
  track_generated_state_file ".claude/BACKLOG.md" "$backlog_exists" "$backlog_hash"
  track_generated_state_file ".claude/ARCHITECTURE.md" "$architecture_exists" "$architecture_hash"
  track_generated_state_file ".claude/ROADMAP.md" "$roadmap_exists" "$roadmap_hash"
  track_generated_state_file ".claude/IDEAS.md" "$ideas_exists" "$ideas_hash"
}

backup_if_exists() {
  local source_path="$1"

  if [ ! -e "$source_path" ]; then
    return 0
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$source_path")"
  cp -R "$source_path" "$BACKUP_DIR/$source_path"
  BACKED_UP_FILES+=("$source_path")
}

archive_log() {
  mkdir -p "$REPORTS_DIR"
  cp "$LOG_FILE" "$ARCHIVED_LOG"
}

write_migration_report() {
  END_AT="$(date -Iseconds)"
  MIGRATION_REPORT="$REPORTS_DIR/${PROJECT_NAME}-MIGRATION_REPORT.md"
  mkdir -p "$REPORTS_DIR"

  {
    echo "# Migration Report"
    echo ""
    echo "- Project: \`$PROJECT_NAME\`"
    echo "- Mode: \`upgrade\`"
    echo "- Status: \`success\`"
    echo "- Previous version: \`${OLD_VERSION:-unknown}\`"
    echo "- Started: \`$STARTED_AT\`"
    echo "- Completed: \`$END_AT\`"
    echo "- Backup dir: \`$BACKUP_DIR\`"
    echo ""
    echo "## Backed Up Files"
    if [ "${#BACKED_UP_FILES[@]}" -eq 0 ]; then
      echo "- none"
    else
      for item in "${BACKED_UP_FILES[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo ""
    echo "## Created Files"
    if [ "${#CREATED_FILES[@]}" -eq 0 ]; then
      echo "- none"
    else
      for item in "${CREATED_FILES[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo ""
    echo "## Updated Files"
    if [ "${#UPDATED_FILES[@]}" -eq 0 ]; then
      echo "- none"
    else
      for item in "${UPDATED_FILES[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo ""
    echo "## Skipped Existing Files"
    if [ "${#SKIPPED_FILES[@]}" -eq 0 ]; then
      echo "- none"
    else
      for item in "${SKIPPED_FILES[@]}"; do
        echo "- \`$item\`"
      done
    fi
    echo ""
    echo "## Warnings"
    if [ "${#WARNINGS[@]}" -eq 0 ]; then
      echo "- none"
    else
      for item in "${WARNINGS[@]}"; do
        echo "- $item"
      done
    fi
    echo ""
    echo "## Artifacts"
    echo "- Migration log archive: \`$ARCHIVED_LOG\`"
    echo "- This report: \`$MIGRATION_REPORT\`"
  } > "$MIGRATION_REPORT"
}

if [ ! -f "$CONTEXT_FILE" ]; then
  log "missing migration context: $CONTEXT_FILE"
  exit 2
fi

MODE_AND_VERSION="$(python3 - "$CONTEXT_FILE" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
mode = data.get("mode", "")
old_version = data.get("old_version", "")
print(mode)
print(old_version)
PY
)"

MODE="$(printf "%s\n" "$MODE_AND_VERSION" | sed -n '1p')"
OLD_VERSION="$(printf "%s\n" "$MODE_AND_VERSION" | sed -n '2p')"

if [ "$MODE" != "upgrade" ]; then
  log "unexpected migration mode '$MODE' (expected 'upgrade')"
  exit 3
fi

log "step 1/5: validating upgrade context"
write_log "in_progress" 1 "context-validation"
append_step "context-validation"

log "step 2/5: creating backup snapshot"
write_log "in_progress" 2 "backup"

BACKUP_DIR=".claude/backups/upgrade-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_if_exists "CLAUDE.md"
backup_if_exists ".claude/SNAPSHOT.md"
backup_if_exists ".claude/BACKLOG.md"
backup_if_exists ".claude/ARCHITECTURE.md"
backup_if_exists ".claude/ROADMAP.md"
backup_if_exists ".claude/IDEAS.md"
backup_if_exists ".claude/.framework-config"
backup_if_exists ".claude/COMMIT_POLICY.md"

append_step "backup"

log "step 3/5: ensuring required framework state files"
write_log "in_progress" 3 "state-upgrade"

generate_upgrade_memory_files

render_template_if_missing "migration/templates/.framework-config.template.json" ".claude/.framework-config"
render_template_if_missing "migration/templates/COMMIT_POLICY.template.md" ".claude/COMMIT_POLICY.md"

if [ ! -f ".claude/.framework-config" ]; then
  ensure_text_file_if_missing ".claude/.framework-config" "{
  \"bug_reporting_enabled\": false,
  \"dialog_export_enabled\": false,
  \"project_name\": \"$PROJECT_NAME\",
  \"first_run_completed\": false,
  \"consent_version\": \"1.0\",
  \"cold_start\": {
    \"silent_mode\": true,
    \"show_ready\": false,
    \"auto_update\": true
  },
  \"completion\": {
    \"silent_mode\": true,
    \"auto_commit\": false,
    \"show_commit_message\": true
  }
}"
fi

if [ ! -f ".claude/COMMIT_POLICY.md" ]; then
  ensure_text_file_if_missing ".claude/COMMIT_POLICY.md" "# Commit Policy

## Never commit
- dialog/
- .claude/logs/
- reports/
- *.key
- *.pem

## Always review before commit
- New configuration files
- Files with potential secrets"
fi

ensure_text_file_if_missing "CHANGELOG.md" "# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

- Initial framework baseline created."

ensure_text_file_if_missing ".gitignore" ".env
.env.*
*credentials*
*.pem
*.key
.claude/.last_session
.claude/.session-owner
.claude/logs/
reports/"

append_step "state-upgrade"

log "step 4/5: writing migration artifacts"
write_log "in_progress" 4 "reporting"

write_migration_report

append_step "reporting"

log "step 5/5: cleanup migration markers"
write_log "in_progress" 5 "cleanup"

if [ -f ".claude/CLAUDE.production.md" ]; then
  cp ".claude/CLAUDE.production.md" "CLAUDE.md"
  rm -f ".claude/CLAUDE.production.md"
  CLAUDE_SWAPPED="true"
fi

append_step "cleanup"
write_log "success" 5 "cleanup"
archive_log

rm -f "$CONTEXT_FILE"
rm -f "$LOG_FILE"

log "upgrade completed successfully"
log "previous version: ${OLD_VERSION:-unknown}"
log "backup dir: $BACKUP_DIR"
log "created: ${#CREATED_FILES[@]}, updated: ${#UPDATED_FILES[@]}, skipped existing: ${#SKIPPED_FILES[@]}"
log "migration report: $MIGRATION_REPORT"
log "migration log archive: $ARCHIVED_LOG"
log "claude swap performed: $CLAUDE_SWAPPED"
