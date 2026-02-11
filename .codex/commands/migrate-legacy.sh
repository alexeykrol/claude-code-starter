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

CREATED_FILES=()
SKIPPED_FILES=()
WARNINGS=()
STEPS_COMPLETED=""
SECURITY_SCAN_STATUS="skipped"
CLAUDE_SWAPPED="false"
ARCHIVED_LOG="$REPORTS_DIR/${PROJECT_NAME}-migration-log.json"
MIGRATION_REPORT=""

log() {
  printf "[codex][migrate-legacy] %s\n" "$1"
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

  python3 - "$LOG_FILE" "$STARTED_AT" "$status" "$step_num" "$step_name" "$STEPS_COMPLETED" "$last_error" <<'PY'
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

steps_completed = [s for s in steps_csv.split(",") if s]
payload = {
    "status": status,
    "mode": "legacy",
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

track_state_file() {
  local target_path="$1"
  local existed_before="$2"

  if [ "$existed_before" -eq 1 ]; then
    SKIPPED_FILES+=("$target_path")
    return
  fi

  if [ -f "$target_path" ]; then
    CREATED_FILES+=("$target_path")
  else
    WARNINGS+=("failed to generate: $target_path")
  fi
}

generate_legacy_memory_files() {
  local snapshot_exists=0
  local backlog_exists=0
  local architecture_exists=0
  local roadmap_exists=0
  local ideas_exists=0

  [ -f ".claude/SNAPSHOT.md" ] && snapshot_exists=1
  [ -f ".claude/BACKLOG.md" ] && backlog_exists=1
  [ -f ".claude/ARCHITECTURE.md" ] && architecture_exists=1
  [ -f ".claude/ROADMAP.md" ] && roadmap_exists=1
  [ -f ".claude/IDEAS.md" ] && ideas_exists=1

  python3 - "$ROOT_DIR" <<'PY'
import os
import sys
import re
import subprocess
import json
from datetime import datetime
from pathlib import Path

root = Path(sys.argv[1])
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

def safe_read(path: Path, max_chars: int = 120000) -> str:
    try:
        if path.stat().st_size > 2_000_000:
            return ""
        data = path.read_bytes()
        return data.decode("utf-8", errors="ignore")[:max_chars]
    except Exception:
        return ""

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
                if rel.as_posix() not in seen:
                    seen.add(rel.as_posix())
                    docs.append(path)
    def priority(p: Path) -> tuple[int, int]:
        n = p.name.lower()
        score = 9
        if n.startswith("readme"):
            score = 0
        elif "snapshot" in n or "status" in n:
            score = 1
        elif "backlog" in n or "todo" in n or "task" in n:
            score = 2
        elif "architecture" in n or "design" in n:
            score = 3
        elif "roadmap" in n or "plan" in n:
            score = 4
        try:
            size = p.stat().st_size
        except Exception:
            size = 0
        return (score, -size)
    docs.sort(key=priority)
    return docs[:12]

docs = candidate_docs()
doc_snippets = []
for doc in docs:
    text = safe_read(doc)
    if text.strip():
        doc_snippets.append((doc, text))

def first_paragraph(text: str) -> str:
    blocks = [b.strip() for b in re.split(r"\n\s*\n", text) if b.strip()]
    for b in blocks:
        if b.startswith("#"):
            continue
        b = " ".join(line.strip() for line in b.splitlines())
        if len(b) >= 30:
            return b
    return ""

overview = ""
for _, text in doc_snippets:
    overview = first_paragraph(text)
    if overview:
        break
if not overview:
    overview = "Legacy project imported into the framework. This summary was generated from available repository files."

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
    return value[:160]

for doc, text in doc_snippets:
    for raw in text.splitlines()[:1200]:
        line = raw.strip()
        if not line:
            continue
        if line.startswith("#"):
            heading = line.lstrip("#").strip()
            if heading and heading not in heading_notes:
                heading_notes.append(heading)
            continue
        m = checkbox_re.match(line)
        if m:
            val = normalize_item(m.group(1))
            if val and val not in task_items:
                task_items.append(val)
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

task_items = task_items[:18]
roadmap_items = roadmap_items[:18]
idea_items = idea_items[:18]
heading_notes = heading_notes[:18]

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
    if any((root / p).exists() for p in ("Fast-bank_2.md", "Google Gemini.md")):
        found.append("Product notes / narrative documents")
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

def write_if_missing(path: Path, content: str) -> None:
    if not path.exists():
        path.write_text(content.strip() + "\n", encoding="utf-8")

project = root.name
today = datetime.now().strftime("%Y-%m-%d")
branch = detect_branch()
docs_list = [f"- `{doc.relative_to(root).as_posix()}`" for doc, _ in doc_snippets[:8]]
if not docs_list:
    docs_list = ["- `<no legacy docs detected>`"]

tasks_block = "\n".join(f"- [ ] {item}" for item in task_items) if task_items else "- [ ] Validate project goals with owner\n- [ ] Define first working sprint"
roadmap_block = "\n".join(f"- {item}" for item in roadmap_items) if roadmap_items else "- Define phased roadmap from legacy materials."
ideas_block = "\n".join(f"- {item}" for item in idea_items) if idea_items else "- Capture hypotheses and experiments discovered during migration."
headings_block = "\n".join(f"- {item}" for item in heading_notes) if heading_notes else "- No explicit section headings detected in legacy docs."
stack_block = "\n".join(f"- {item}" for item in detect_stack())
structure_block = "\n".join(top_level_structure())

snapshot = f"""
# SNAPSHOT — {project}

*Last updated: {today}*

## Current State

- Framework mode: legacy migration
- Active branch: `{branch}`
- Legacy sources analyzed: {len(doc_snippets)}

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

*Inferred from legacy materials on {today}*

## Active Tasks

{tasks_block}

## Migration Follow-Ups

- [ ] Review generated memory files and adjust priorities.
- [ ] Confirm security scan report and remove false positives.
- [ ] Start first implementation cycle in the chosen coding agent.
"""

architecture = f"""
# ARCHITECTURE — {project}

*Generated from detected project artifacts*

## Detected Stack

{stack_block}

## Top-Level Structure

{structure_block}

## Key Topics Found in Legacy Docs

{headings_block}

## Data / Workflow Notes

- Project memory lives in `.claude/` files.
- Execution adapters run from `.claude/` (Claude) and `.codex/` (Codex).
- Shared runtime is implemented in `src/framework-core/`.
"""

roadmap = f"""
# ROADMAP — {project}

*Draft roadmap inferred from legacy project materials*

## Candidate Milestones

{roadmap_block}
"""

ideas = f"""
# IDEAS — {project}

*Captured from legacy notes and inferred opportunities*

## Candidate Ideas

{ideas_block}
"""

write_if_missing(state_dir / "SNAPSHOT.md", snapshot)
write_if_missing(state_dir / "BACKLOG.md", backlog)
write_if_missing(state_dir / "ARCHITECTURE.md", architecture)
write_if_missing(state_dir / "ROADMAP.md", roadmap)
write_if_missing(state_dir / "IDEAS.md", ideas)
PY

  if [ $? -ne 0 ]; then
    WARNINGS+=("legacy analysis generation failed")
  fi

  track_state_file ".claude/SNAPSHOT.md" "$snapshot_exists"
  track_state_file ".claude/BACKLOG.md" "$backlog_exists"
  track_state_file ".claude/ARCHITECTURE.md" "$architecture_exists"
  track_state_file ".claude/ROADMAP.md" "$roadmap_exists"
  track_state_file ".claude/IDEAS.md" "$ideas_exists"
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
    echo "- Mode: \`legacy\`"
    echo "- Status: \`success\`"
    echo "- Started: \`$STARTED_AT\`"
    echo "- Completed: \`$END_AT\`"
    echo "- Security scan: \`$SECURITY_SCAN_STATUS\`"
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

MODE="$(python3 - "$CONTEXT_FILE" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
print(data.get("mode", ""))
PY
)"

if [ "$MODE" != "legacy" ]; then
  log "unexpected migration mode '$MODE' (expected 'legacy')"
  exit 3
fi

log "step 1/5: validating migration context"
write_log "in_progress" 1 "context-validation"
append_step "context-validation"

log "step 2/5: running mandatory initial security scan"
write_log "in_progress" 2 "security-scan"

if [ -f "security/initial-scan.sh" ]; then
  set +e
  bash security/initial-scan.sh
  scan_exit=$?
  set -e

  if [ "$scan_exit" -ne 0 ]; then
    SECURITY_SCAN_STATUS="blocked:$scan_exit"
    write_log "blocked" 2 "security-scan" "security/initial-scan.sh failed with exit $scan_exit"
    archive_log
    log "security scan blocked migration (exit $scan_exit)"
    log "resolve report in security/reports and rerun migration"
    exit 4
  fi

  SECURITY_SCAN_STATUS="clean"
else
  SECURITY_SCAN_STATUS="skipped:script_missing"
  WARNINGS+=("security/initial-scan.sh not found; security gate skipped")
fi

append_step "security-scan"

log "step 3/5: generating missing framework state files"
write_log "in_progress" 3 "state-generation"

generate_legacy_memory_files

render_template_if_missing "migration/templates/.framework-config.template.json" ".claude/.framework-config"
render_template_if_missing "migration/templates/COMMIT_POLICY.template.md" ".claude/COMMIT_POLICY.md"

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

append_step "state-generation"

log "step 4/5: finalizing migration artifacts"
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

log "migration completed successfully"
log "created: ${#CREATED_FILES[@]}, skipped existing: ${#SKIPPED_FILES[@]}"
log "security scan: $SECURITY_SCAN_STATUS"
log "migration report: $MIGRATION_REPORT"
log "migration log archive: $ARCHIVED_LOG"
log "claude swap performed: $CLAUDE_SWAPPED"
