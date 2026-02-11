"""Configuration management and baseline file tasks."""

import json
import subprocess
from datetime import datetime
from pathlib import Path
from utils.parallel import time_task
from utils.result import create_task_result


def _default_config(project_name: str) -> dict:
    return {
        "bug_reporting_enabled": False,
        "dialog_export_enabled": False,
        "project_name": project_name,
        "first_run_completed": False,
        "consent_version": "1.0",
        "cold_start": {
            "silent_mode": True,
            "show_ready": False,
            "auto_update": True
        },
        "completion": {
            "silent_mode": True,
            "auto_commit": False,
            "show_commit_message": True
        }
    }


def _merge_missing(target: dict, defaults: dict) -> bool:
    changed = False
    for key, value in defaults.items():
        if key not in target:
            target[key] = value
            changed = True
            continue
        if isinstance(value, dict):
            current = target.get(key)
            if not isinstance(current, dict):
                target[key] = value
                changed = True
            elif _merge_missing(current, value):
                changed = True
    return changed


def _read_text(path: Path, max_chars: int = 140000) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")[:max_chars]
    except Exception:
        return ""


def _detect_branch(root: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=root,
            capture_output=True,
            text=True,
            check=True
        )
        value = result.stdout.strip()
        if value:
            return value
    except Exception:
        pass
    return "main"


def _detect_stack(root: Path) -> list:
    stack = []
    if (root / "package.json").exists():
        stack.append("Node.js / npm")
    if (root / "pyproject.toml").exists() or (root / "requirements.txt").exists():
        stack.append("Python")
    if (root / "Cargo.toml").exists():
        stack.append("Rust")
    if (root / "go.mod").exists():
        stack.append("Go")
    if not stack:
        stack.append("Stack requires manual confirmation")
    return stack


def _top_level_structure(root: Path) -> list:
    ignored = {
        ".git",
        ".claude",
        ".codex",
        "node_modules",
        "dist",
        "build",
        "archive",
        "reports",
        ".venv",
        "venv",
        "__pycache__",
    }
    rows = []
    for item in sorted(root.iterdir(), key=lambda p: p.name.lower()):
        if item.name in ignored or item.name.startswith(".DS_Store"):
            continue
        suffix = "/" if item.is_dir() else ""
        rows.append(f"- `{item.name}{suffix}`")
        if len(rows) >= 20:
            break
    if not rows:
        rows.append("- `<project files>`")
    return rows


def _state_needs_refresh(content: str) -> bool:
    if not content.strip():
        return True
    lower = content.lower()
    markers = [
        "{{project_",
        "{{tech_stack}}",
        "{{project_structure}}",
        "{{project_key_concepts}}",
        "add your high priority tasks here",
        "add your medium priority tasks here",
        "add your low priority tasks here",
        "add your current tasks here",
        "add your planned tasks here",
        "feature idea 1",
        "known bug 1",
        "tech debt item 1",
    ]
    if "{{" in content and "}}" in content:
        return True
    return any(marker in lower for marker in markers)


def _collect_docs(root: Path) -> list:
    docs = []
    seen = set()
    skip_roots = {
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
    for base in [root, root / "docs", root / "documentation", root / "notes", root / "wiki"]:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if not path.is_file():
                continue
            rel = path.relative_to(root)
            if rel.parts and rel.parts[0] in skip_roots:
                continue
            if path.name in {"CLAUDE.md", "AGENTS.md", "FRAMEWORK_GUIDE.md", "COMMIT_POLICY.md"}:
                continue
            if path.suffix.lower() not in {".md", ".txt", ".rst"} and not path.name.lower().startswith("readme"):
                continue
            rel_posix = rel.as_posix()
            if rel_posix in seen:
                continue
            seen.add(rel_posix)
            docs.append(path)

    def priority(doc_path: Path) -> tuple:
        name = doc_path.name.lower()
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
            size = doc_path.stat().st_size
        except Exception:
            size = 0
        return (score, -size)

    docs.sort(key=priority)
    return docs[:12]


def _first_paragraph(text: str) -> str:
    blocks = [part.strip() for part in text.split("\n\n") if part.strip()]
    for block in blocks:
        if block.startswith("#"):
            continue
        flat = " ".join(line.strip() for line in block.splitlines())
        if len(flat) >= 30:
            return flat
    return ""


def _extract_items(doc_texts: list) -> tuple:
    task_items = []
    roadmap_items = []
    idea_items = []
    headings = []

    for text in doc_texts:
        for raw in text.splitlines()[:1200]:
            line = raw.strip()
            if not line:
                continue
            if line.startswith("#"):
                heading = line.lstrip("#").strip()
                if heading and heading not in headings:
                    headings.append(heading)
                continue
            normalized = " ".join(line.split())
            if len(normalized) < 3:
                continue
            lowered = normalized.lower()
            if normalized.startswith("- [ ]"):
                item = normalized.replace("- [ ]", "", 1).strip()
                if item and item not in task_items:
                    task_items.append(item)
                continue
            if any(token in lowered for token in ("todo", "next", "fixme", "phase", "milestone")):
                if normalized not in task_items:
                    task_items.append(normalized)
            if any(token in lowered for token in ("roadmap", "phase", "milestone", "release")):
                if normalized not in roadmap_items:
                    roadmap_items.append(normalized)
            if any(token in lowered for token in ("idea", "future", "later", "could", "maybe", "wish")):
                if normalized not in idea_items:
                    idea_items.append(normalized)

    return task_items[:18], roadmap_items[:18], idea_items[:18], headings[:18]


@time_task
def migration_cleanup():
    """Check and cleanup migration files."""
    try:
        cleanup_file = Path(".claude/CLAUDE.production.md")
        if cleanup_file.exists():
            import shutil
            shutil.copy2(cleanup_file, "CLAUDE.md")
            cleanup_file.unlink(missing_ok=True)
            Path(".claude/migration-context.json").unlink(missing_ok=True)
            return create_task_result("migration_cleanup", "success", "CLEANUP:performed")
        return create_task_result("migration_cleanup", "success", "CLEANUP:done")
    except Exception as e:
        return create_task_result("migration_cleanup", "error", "", error=str(e))


@time_task
def init_config():
    """Initialize or normalize .framework-config."""
    try:
        config_file = Path(".claude/.framework-config")
        project_name = Path.cwd().name
        defaults = _default_config(project_name)

        config_file.parent.mkdir(parents=True, exist_ok=True)

        if not config_file.exists():
            with open(config_file, "w", encoding="utf-8") as f:
                json.dump(defaults, f, indent=2, ensure_ascii=False)
            return create_task_result("config_init", "success", "CONFIG:created")

        changed = False
        try:
            with open(config_file, encoding="utf-8") as f:
                current = json.load(f)
            if not isinstance(current, dict):
                current = {}
                changed = True
        except Exception:
            current = {}
            changed = True

        if _merge_missing(current, defaults):
            changed = True

        if current.get("project_name") in (None, "", "unknown"):
            current["project_name"] = project_name
            changed = True

        if changed:
            with open(config_file, "w", encoding="utf-8") as f:
                json.dump(current, f, indent=2, ensure_ascii=False)
            return create_task_result("config_init", "success", "CONFIG:updated")

        return create_task_result("config_init", "success", "CONFIG:exists")
    except Exception as e:
        return create_task_result("config_init", "error", "", error=str(e))


@time_task
def ensure_commit_policy():
    """Ensure COMMIT_POLICY.md exists."""
    try:
        policy_file = Path(".claude/COMMIT_POLICY.md")
        if policy_file.exists():
            return create_task_result("commit_policy", "success", "POLICY:exists")

        template_candidates = [
            Path(".claude/templates/COMMIT_POLICY.template.md"),
            Path("migration/templates/COMMIT_POLICY.template.md"),
        ]

        content = ""
        project_name = Path.cwd().name
        for template_file in template_candidates:
            if not template_file.exists():
                continue
            try:
                content = template_file.read_text(encoding="utf-8")
                content = content.replace("{{PROJECT_NAME}}", project_name)
                break
            except Exception:
                continue

        if not content:
            content = """# Commit Policy

## Never commit
- dialog/
- .claude/logs/
- reports/
- *.key
- *.pem

## Always review before commit
- New configuration files
- Files with potential secrets
"""

        policy_file.parent.mkdir(parents=True, exist_ok=True)
        policy_file.write_text(content, encoding="utf-8")
        return create_task_result("commit_policy", "success", "POLICY:created")
    except Exception as e:
        return create_task_result("commit_policy", "error", "", error=str(e))


@time_task
def ensure_project_baseline(create_missing: bool = True):
    """Refresh project baseline files.

    Args:
        create_missing: If False, only updates existing files and never creates new files.
    """
    try:
        root = Path.cwd()
        state_dir = root / ".claude"
        state_dir.mkdir(parents=True, exist_ok=True)

        created = []
        updated = []

        gitignore = root / ".gitignore"
        required_patterns = [
            ".env",
            ".env.*",
            "*credentials*",
            "*.pem",
            "*.key",
            ".claude/.last_session",
            ".claude/.session-owner",
            ".claude/logs/",
            "reports/",
        ]
        if not gitignore.exists():
            if create_missing:
                gitignore.write_text("\n".join(required_patterns) + "\n", encoding="utf-8")
                created.append(".gitignore")
        else:
            current = gitignore.read_text(encoding="utf-8", errors="ignore").splitlines()
            missing = [line for line in required_patterns if line not in current]
            if missing:
                with open(gitignore, "a", encoding="utf-8") as f:
                    prefix = "" if (not current or current[-1] == "") else "\n"
                    f.write(prefix + "\n".join(missing) + "\n")
                updated.append(".gitignore")

        changelog = root / "CHANGELOG.md"
        if create_missing and not changelog.exists():
            changelog.write_text(
                "# Changelog\n\n"
                "All notable changes to this project will be documented in this file.\n\n"
                "## [Unreleased]\n\n"
                "- Initial framework baseline created.\n",
                encoding="utf-8"
            )
            created.append("CHANGELOG.md")

        docs = _collect_docs(root)
        doc_texts = [_read_text(doc) for doc in docs]
        overview = ""
        for text in doc_texts:
            overview = _first_paragraph(text)
            if overview:
                break
        if not overview:
            try:
                package = json.loads((root / "package.json").read_text(encoding="utf-8"))
                overview = str(package.get("description", "")).strip()
            except Exception:
                overview = ""
        if not overview:
            overview = "Project context initialized by completion baseline task."

        tasks, roadmap_items, idea_items, headings = _extract_items(doc_texts)
        if not tasks:
            tasks = ["Validate project goals with owner", "Define first working sprint"]
        if not roadmap_items:
            roadmap_items = ["Define phased roadmap from project materials."]
        if not idea_items:
            idea_items = ["Capture ideas and experiments during implementation cycles."]
        if not headings:
            headings = ["No explicit section headings detected in docs."]

        today = datetime.now().strftime("%Y-%m-%d")
        branch = _detect_branch(root)
        docs_list = [f"- `{doc.relative_to(root).as_posix()}`" for doc in docs[:8]] or ["- `<no docs detected>`"]
        stack_lines = [f"- {item}" for item in _detect_stack(root)]
        structure_lines = _top_level_structure(root)
        task_lines = [f"- [ ] {item}" for item in tasks]
        roadmap_lines = [f"- {item}" for item in roadmap_items]
        idea_lines = [f"- {item}" for item in idea_items]
        heading_lines = [f"- {item}" for item in headings]

        snapshot_content = (
            f"# SNAPSHOT — {root.name}\n\n"
            f"*Last updated: {today}*\n\n"
            "## Current State\n\n"
            "- Framework mode: active\n"
            f"- Active branch: `{branch}`\n"
            f"- Source documents analyzed: {len(docs)}\n\n"
            "## Project Overview\n\n"
            f"{overview}\n\n"
            "## Source Documents\n\n"
            f"{chr(10).join(docs_list)}\n\n"
            "## Current Focus\n\n"
            f"{chr(10).join(task_lines[:3])}\n"
        )

        backlog_content = (
            f"# BACKLOG — {root.name}\n\n"
            f"*Refreshed on {today}*\n\n"
            "## Active Tasks\n\n"
            f"{chr(10).join(task_lines)}\n\n"
            "## Framework Follow-Ups\n\n"
            "- [ ] Review generated state files and adjust priorities.\n"
            "- [ ] Continue work cycle via start/finish protocol.\n"
        )

        architecture_content = (
            f"# ARCHITECTURE — {root.name}\n\n"
            "*Generated from detected project artifacts*\n\n"
            "## Detected Stack\n\n"
            f"{chr(10).join(stack_lines)}\n\n"
            "## Top-Level Structure\n\n"
            f"{chr(10).join(structure_lines)}\n\n"
            "## Key Topics\n\n"
            f"{chr(10).join(heading_lines)}\n\n"
            "## Notes\n\n"
            "- Shared memory is stored in `.claude/`.\n"
            "- Runtime entry points are in `CLAUDE.md` and `AGENTS.md`.\n"
            "- Shared execution core is `src/framework-core/`.\n"
        )

        roadmap_content = (
            f"# ROADMAP — {root.name}\n\n"
            "*Draft roadmap*\n\n"
            "## Candidate Milestones\n\n"
            f"{chr(10).join(roadmap_lines)}\n"
        )

        ideas_content = (
            f"# IDEAS — {root.name}\n\n"
            "*Captured ideas*\n\n"
            "## Candidate Ideas\n\n"
            f"{chr(10).join(idea_lines)}\n"
        )

        targets = {
            state_dir / "SNAPSHOT.md": snapshot_content,
            state_dir / "BACKLOG.md": backlog_content,
            state_dir / "ARCHITECTURE.md": architecture_content,
            state_dir / "ROADMAP.md": roadmap_content,
            state_dir / "IDEAS.md": ideas_content,
        }

        for path, content in targets.items():
            rel = path.relative_to(root).as_posix()
            if not path.exists():
                if create_missing:
                    path.write_text(content, encoding="utf-8")
                    created.append(rel)
                continue
            existing = _read_text(path)
            if _state_needs_refresh(existing):
                path.write_text(content, encoding="utf-8")
                updated.append(rel)

        return create_task_result(
            "project_baseline",
            "success",
            f"BASELINE:created:{len(created)}:updated:{len(updated)}"
        )
    except Exception as e:
        return create_task_result("project_baseline", "error", "", error=str(e))


def get_context_files():
    """Get list of context files to load."""
    return [
        ".claude/SNAPSHOT.md",
        ".claude/BACKLOG.md",
        ".claude/ARCHITECTURE.md"
    ]
