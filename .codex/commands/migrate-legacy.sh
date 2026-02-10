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
ARCHIVED_LOG=""
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

archive_log() {
  mkdir -p "$REPORTS_DIR"
  ARCHIVED_LOG="$REPORTS_DIR/${PROJECT_NAME}-migration-log.json"
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

render_template_if_missing "migration/templates/SNAPSHOT.template.md" ".claude/SNAPSHOT.md"
render_template_if_missing "migration/templates/BACKLOG.template.md" ".claude/BACKLOG.md"
render_template_if_missing "migration/templates/ARCHITECTURE.template.md" ".claude/ARCHITECTURE.md"
render_template_if_missing "migration/templates/.framework-config.template.json" ".claude/.framework-config"
render_template_if_missing "migration/templates/COMMIT_POLICY.template.md" ".claude/COMMIT_POLICY.md"

ensure_text_file_if_missing ".claude/.framework-config" "{
  \"bug_reporting_enabled\": false,
  \"project_name\": \"$PROJECT_NAME\",
  \"first_run_completed\": false
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

ensure_text_file_if_missing ".claude/ROADMAP.md" "# ROADMAP

## Next Milestones
- [ ] Define medium-term milestones for the project.
- [ ] Link roadmap items to backlog tasks."

ensure_text_file_if_missing ".claude/IDEAS.md" "# IDEAS

## Brainstorm
- Capture future ideas here.
- Move validated ideas to ROADMAP.md."

append_step "state-generation"

log "step 4/5: finalizing migration artifacts"
write_log "in_progress" 4 "reporting"

archive_log
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

rm -f "$CONTEXT_FILE"
rm -f "$LOG_FILE"

log "migration completed successfully"
log "created: ${#CREATED_FILES[@]}, skipped existing: ${#SKIPPED_FILES[@]}"
log "security scan: $SECURITY_SCAN_STATUS"
log "migration report: $MIGRATION_REPORT"
log "migration log archive: $ARCHIVED_LOG"
log "claude swap performed: $CLAUDE_SWAPPED"
