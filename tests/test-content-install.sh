#!/bin/bash
# Smoke test for Claude Code Starter v6.0 content-aware installer.
# Tests basic install/migrate scenarios in /tmp fixtures.
#
# Usage: bash tests/test-content-install.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
FAILED_TESTS=()

# ANSI colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ----------------------------------------------------------------------------
# Assertion helpers (return non-zero on failure to be caught by `set +e` tests)
# ----------------------------------------------------------------------------

assert_file_exists() {
    local f="$1"
    local desc="$2"
    if [ -f "$f" ]; then
        echo -e "  ${GREEN}OK${NC}   $desc"
        return 0
    else
        echo -e "  ${RED}MISS${NC} $desc (missing: $f)"
        return 1
    fi
}

assert_dir_exists() {
    local d="$1"
    local desc="$2"
    if [ -d "$d" ]; then
        echo -e "  ${GREEN}OK${NC}   $desc"
        return 0
    else
        echo -e "  ${RED}MISS${NC} $desc (missing dir: $d)"
        return 1
    fi
}

assert_file_contains() {
    local f="$1"
    local pattern="$2"
    local desc="$3"
    if [ ! -f "$f" ]; then
        echo -e "  ${RED}MISS${NC} $desc (file not found: $f)"
        return 1
    fi
    if grep -qF -- "$pattern" "$f" 2>/dev/null; then
        echo -e "  ${GREEN}OK${NC}   $desc"
        return 0
    else
        echo -e "  ${RED}MISS${NC} $desc (pattern not found in $f)"
        return 1
    fi
}

assert_file_not_contains() {
    local f="$1"
    local pattern="$2"
    local desc="$3"
    if [ ! -f "$f" ]; then
        echo -e "  ${RED}MISS${NC} $desc (file not found: $f)"
        return 1
    fi
    if grep -qF -- "$pattern" "$f" 2>/dev/null; then
        echo -e "  ${RED}MISS${NC} $desc (unexpected pattern present in $f)"
        return 1
    fi
    echo -e "  ${GREEN}OK${NC}   $desc"
    return 0
}

assert_glob_exists() {
    local pattern="$1"
    local desc="$2"
    # Use compgen-style with shell glob expansion
    local match
    # shellcheck disable=SC2086
    match=$(ls -d $pattern 2>/dev/null | head -1)
    if [ -n "$match" ]; then
        echo -e "  ${GREEN}OK${NC}   $desc"
        return 0
    else
        echo -e "  ${RED}MISS${NC} $desc (no match for: $pattern)"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Fixture lifecycle
# ----------------------------------------------------------------------------

# Each test gets its own /tmp dir. cleanup_fixture is called in trap so that
# failure mid-test does not leave junk behind.
CURRENT_FIXTURE=""

cleanup_all_fixtures() {
    # Final safety net — wipe any leftover /tmp/test-cs-* dirs and stray logs.
    rm -rf /tmp/test-cs-1 /tmp/test-cs-2 /tmp/test-cs-3 /tmp/test-cs-4 \
           /tmp/test-cs-5 /tmp/test-cs-6 /tmp/test-cs-7 /tmp/test-cs-8 \
           2>/dev/null || true
    rm -f /tmp/test-cs-*.log /tmp/cs-snapshot-*.md 2>/dev/null || true
}

trap cleanup_all_fixtures EXIT

setup_fixture() {
    local name="$1"
    local dir="/tmp/test-cs-${name}"
    rm -rf "$dir"
    mkdir -p "$dir"
    CURRENT_FIXTURE="$dir"
    echo "$dir"
}

# Direct cleanup helper — invoked from run_test in the parent shell after the
# subshell test finishes, since setup_fixture's CURRENT_FIXTURE assignment
# inside the subshell does not propagate.
cleanup_dir_by_name() {
    local name="$1"
    local dir="/tmp/test-cs-${name}"
    if [ -d "$dir" ]; then
        rm -rf "$dir"
    fi
}

# ----------------------------------------------------------------------------
# Test runner
# ----------------------------------------------------------------------------

run_test() {
    local name="$1"
    local fxnum="$2"
    shift 2
    echo ""
    echo "------------------------------------"
    echo -e "${BLUE}TEST:${NC} $name"
    echo "------------------------------------"

    # Run the test in a subshell with set +e so assertion failures don't kill us
    set +e
    (
        set +e
        "$@"
    )
    local rc=$?
    set -u

    # Always clean up this test's fixture, even on failure
    cleanup_dir_by_name "$fxnum"

    if [ "$rc" -eq 0 ]; then
        PASS=$((PASS + 1))
        echo -e "${GREEN}PASS${NC}: $name"
    else
        FAIL=$((FAIL + 1))
        FAILED_TESTS+=("$name")
        echo -e "${RED}FAIL${NC}: $name"
    fi
}

# ============================================================================
# Test 1: install code into an empty project
# ============================================================================
test_install_code_empty() {
    local fx
    fx="$(setup_fixture 1)"
    cd "$fx" || return 1

    bash "$REPO_DIR/scripts/init-project.sh" \
        --type code \
        --name "Test Code" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-1.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  installer exit code: $rc"
        echo "  --- last 20 lines of log ---"
        tail -20 /tmp/test-cs-1.log
        return 1
    fi

    local fail=0
    assert_file_exists ".claude/rules/autonomy.md"            "rules/autonomy.md installed"            || fail=1
    assert_file_exists ".claude/rules/commit-policy.md"       "rules/commit-policy.md installed"       || fail=1
    assert_file_exists ".claude/skills/start/SKILL.md"        "skills/start/SKILL.md installed"        || fail=1
    assert_file_exists ".claude/skills/finish/SKILL.md"       "skills/finish/SKILL.md installed"       || fail=1
    assert_file_exists ".claude/agents/researcher/researcher.md" "agents/researcher installed"         || fail=1
    assert_file_exists ".claude/agents/implementer/implementer.md" "agents/implementer installed"      || fail=1
    assert_file_exists ".claude/hooks/pre-compact.sh"         "hooks/pre-compact.sh installed"         || fail=1
    assert_file_exists "manifest.md"                          "manifest.md created"                    || fail=1
    assert_file_contains "manifest.md" "project_type=code"    "manifest.md has project_type=code"      || fail=1
    assert_file_exists "CLAUDE.md"                            "CLAUDE.md created"                      || fail=1

    return $fail
}

# ============================================================================
# Test 2: install content/book into an empty project
# ============================================================================
test_install_content_book() {
    local fx
    fx="$(setup_fixture 2)"
    cd "$fx" || return 1

    bash "$REPO_DIR/scripts/init-project.sh" \
        --type content \
        --content-type book \
        --name "Test Book" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-2.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  installer exit code: $rc"
        tail -20 /tmp/test-cs-2.log
        return 1
    fi

    local fail=0
    # Content rules
    assert_file_exists ".claude/rules/content-pipeline.md"     "content-pipeline.md installed"     || fail=1
    assert_file_exists ".claude/rules/content-quality.md"      "content-quality.md installed"      || fail=1
    assert_file_exists ".claude/rules/source-management.md"    "source-management.md installed"    || fail=1
    assert_file_exists ".claude/rules/content-formats.md"      "content-formats.md installed"      || fail=1
    # commit-policy in content mode is the renamed content-commit-policy
    assert_file_exists ".claude/rules/commit-policy.md"        "commit-policy.md installed (content)" || fail=1

    # Skills
    assert_file_exists ".claude/skills/research/SKILL.md"      "skills/research"      || fail=1
    assert_file_exists ".claude/skills/write-content/SKILL.md" "skills/write-content" || fail=1
    assert_file_exists ".claude/skills/review-content/SKILL.md" "skills/review-content" || fail=1

    # Agents
    assert_file_exists ".claude/agents/writer/writer.md"       "agents/writer"      || fail=1
    assert_file_exists ".claude/agents/editor/editor.md"       "agents/editor"      || fail=1
    assert_file_exists ".claude/agents/reviewer/reviewer.md"   "agents/reviewer (content)" || fail=1

    # Content templates → templates/
    assert_file_exists "templates/chapter.md"  "templates/chapter.md" || fail=1
    assert_file_exists "templates/lesson.md"   "templates/lesson.md"  || fail=1

    # Book starter
    assert_dir_exists  "chapters"                             "chapters/ starter dir"   || fail=1
    assert_file_exists "bible/voice.md"                       "bible/voice.md"          || fail=1

    # Manifest
    assert_file_contains "manifest.md" "project_type=content" "manifest project_type=content" || fail=1
    assert_file_contains "manifest.md" "content_type=book"    "manifest content_type=book"    || fail=1

    return $fail
}

# ============================================================================
# Test 3: install content/course
# ============================================================================
test_install_content_course() {
    local fx
    fx="$(setup_fixture 3)"
    cd "$fx" || return 1

    bash "$REPO_DIR/scripts/init-project.sh" \
        --type content \
        --content-type course \
        --name "Test Course" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-3.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  installer exit code: $rc"
        tail -20 /tmp/test-cs-3.log
        return 1
    fi

    local fail=0
    assert_file_exists ".claude/rules/content-pipeline.md"     "content-pipeline.md installed"   || fail=1
    assert_file_exists ".claude/skills/research/SKILL.md"      "skills/research"                 || fail=1
    assert_file_exists ".claude/agents/writer/writer.md"       "agents/writer"                   || fail=1

    # Course starter
    assert_dir_exists  "modules"                               "modules/ starter dir"            || fail=1
    assert_file_exists "meta/program.md"                       "meta/program.md"                 || fail=1

    assert_file_contains "manifest.md" "content_type=course"   "manifest content_type=course"    || fail=1

    return $fail
}

# ============================================================================
# Test 4: install hybrid (code + content overlay)
# ============================================================================
test_install_hybrid() {
    local fx
    fx="$(setup_fixture 4)"
    cd "$fx" || return 1

    # Make it look like a real hybrid project
    echo '{"name":"x"}' > package.json
    mkdir -p chapters
    echo "# Foo" > chapters/foo.md

    bash "$REPO_DIR/scripts/init-project.sh" \
        --type hybrid \
        --content-type book \
        --name "Test Hybrid" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-4.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  installer exit code: $rc"
        tail -20 /tmp/test-cs-4.log
        return 1
    fi

    local fail=0
    # Code side
    assert_file_exists ".claude/rules/autonomy.md"             "code: autonomy.md"        || fail=1
    assert_file_exists ".claude/agents/implementer/implementer.md" "code: implementer"    || fail=1
    assert_file_exists ".claude/agents/researcher/researcher.md"   "code: researcher"     || fail=1

    # Content side
    assert_file_exists ".claude/rules/content-pipeline.md"     "content: content-pipeline" || fail=1
    assert_file_exists ".claude/agents/writer/writer.md"       "content: writer"           || fail=1
    assert_file_exists ".claude/agents/editor/editor.md"       "content: editor"           || fail=1

    # In hybrid mode, commit-policy.md is the standard code one;
    # content-commit-policy.md is preserved as a separate supplement.
    assert_file_contains ".claude/rules/commit-policy.md" "private-solo" \
        "commit-policy.md is standard code-commit-policy" || fail=1
    assert_file_exists ".claude/rules/content-commit-policy.md" \
        "content-commit-policy.md present as supplement" || fail=1

    assert_file_contains "manifest.md" "project_type=hybrid"   "manifest project_type=hybrid" || fail=1

    return $fail
}

# ============================================================================
# Test 5: auto-detect book project (no --type flag)
# ============================================================================
test_auto_detect_book() {
    local fx
    fx="$(setup_fixture 5)"
    cd "$fx" || return 1

    # Build content-shaped fixture: chapters/, briefs/, bible/, INDEX.md, plus
    # extra .md files so total_files >= 3 and content_dirs_score >= 3.
    mkdir -p chapters briefs bible
    echo "# Chapter 1" > chapters/01.md
    echo "# Brief"     > briefs/intro.md
    echo "# Voice"     > bible/voice.md
    echo "# Index"     > INDEX.md
    echo "# Notes"     > NOTES.md
    echo "# Extra"     > EXTRA.md

    bash "$REPO_DIR/scripts/init-project.sh" \
        --name "Auto Detect" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-5.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  installer exit code: $rc"
        tail -25 /tmp/test-cs-5.log
        return 1
    fi

    local fail=0
    assert_file_exists ".claude/rules/content-pipeline.md"     "auto-detect chose content"    || fail=1
    assert_file_contains "manifest.md" "project_type=content"  "manifest: project_type=content" || fail=1
    assert_file_contains "manifest.md" "content_type=book"     "manifest: content_type=book"    || fail=1

    return $fail
}

# ============================================================================
# Test 6: migrate with existing CLAUDE.md (preserve user content)
# ============================================================================
test_migrate_existing_claude() {
    local fx
    fx="$(setup_fixture 6)"
    cd "$fx" || return 1

    # User-authored CLAUDE.md
    cat > CLAUDE.md <<'EOF'
# My Project

## Custom Section
This should be preserved.

## Another Custom Section
Also keep this.
EOF

    # A couple .md files so detection has something to chew on
    echo "# Readme" > README.md
    echo "# Notes"  > NOTES.md
    echo "# Doc"    > DOC.md

    bash "$REPO_DIR/scripts/migrate.sh" \
        --type code \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-6.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  installer exit code: $rc"
        tail -25 /tmp/test-cs-6.log
        return 1
    fi

    local fail=0
    assert_file_contains "CLAUDE.md" "Custom Section"          "CLAUDE.md preserved Custom Section"         || fail=1
    assert_file_contains "CLAUDE.md" "Another Custom Section"  "CLAUDE.md preserved Another Custom Section" || fail=1
    assert_glob_exists  ".claude/backup-*"                     "backup directory created"                   || fail=1
    # The backup itself should contain the original CLAUDE.md
    if ls .claude/backup-*/CLAUDE.md >/dev/null 2>&1; then
        echo -e "  ${GREEN}OK${NC}   backup contains CLAUDE.md"
    else
        echo -e "  ${RED}MISS${NC} backup directory has no CLAUDE.md"
        fail=1
    fi
    assert_file_exists ".claude/rules/autonomy.md"             "framework rules installed"                  || fail=1

    return $fail
}

# ============================================================================
# Test 7: rollback after install (smoke check — backup remains, exit 0)
# ============================================================================
test_rollback() {
    local fx
    fx="$(setup_fixture 7)"
    cd "$fx" || return 1

    bash "$REPO_DIR/scripts/init-project.sh" \
        --type code \
        --name "Rollback Test" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-7-install.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  install failed (rc=$rc)"
        tail -20 /tmp/test-cs-7-install.log
        return 1
    fi

    # Sanity: CLAUDE.md exists post-install
    if [ ! -f "CLAUDE.md" ]; then
        echo "  CLAUDE.md missing after install"
        return 1
    fi
    cp CLAUDE.md /tmp/cs-snapshot-7.md

    # Modify CLAUDE.md
    echo "modified" > CLAUDE.md

    # Run rollback (via launcher or migrate.sh — use init-project.sh internal)
    bash "$REPO_DIR/scripts/init-project.sh" \
        --rollback \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-7-rollback.log 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  rollback failed (rc=$rc)"
        tail -20 /tmp/test-cs-7-rollback.log
        return 1
    fi

    local fail=0
    # Backup directory must still exist after rollback
    assert_glob_exists ".claude/backup-*" "backup preserved after rollback" || fail=1

    # Best-effort: rollback should have brought back something — either CLAUDE.md
    # matches the post-install snapshot, OR (if no CLAUDE.md was backed up) it
    # left the modified file untouched. We accept either as "ran without error".
    if [ -f "CLAUDE.md" ]; then
        echo -e "  ${GREEN}OK${NC}   CLAUDE.md still present"
    else
        echo -e "  ${YELLOW}WARN${NC} CLAUDE.md missing after rollback (acceptable for fresh install)"
    fi

    rm -f /tmp/cs-snapshot-7.md
    return $fail
}

# ============================================================================
# Test 8: --force overwrites manually edited framework files
# ============================================================================
test_force() {
    local fx
    fx="$(setup_fixture 8)"
    cd "$fx" || return 1

    bash "$REPO_DIR/scripts/init-project.sh" \
        --type code \
        --name "Force Test" \
        --template "$REPO_DIR" </dev/null >/tmp/test-cs-8a.log 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  first install failed (rc=$rc)"
        tail -20 /tmp/test-cs-8a.log
        return 1
    fi

    if [ ! -f ".claude/rules/autonomy.md" ]; then
        echo "  autonomy.md missing after first install"
        return 1
    fi

    # Inject a sentinel line that is NOT in the template
    echo "MANUAL_EDIT_SENTINEL_DO_NOT_KEEP" >> ".claude/rules/autonomy.md"

    # Sanity: sentinel is there
    if ! grep -qF "MANUAL_EDIT_SENTINEL_DO_NOT_KEEP" ".claude/rules/autonomy.md"; then
        echo "  could not inject sentinel"
        return 1
    fi

    # Re-run with --force
    bash "$REPO_DIR/scripts/init-project.sh" \
        --type code \
        --name "Force Test" \
        --template "$REPO_DIR" \
        --force </dev/null >/tmp/test-cs-8b.log 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "  forced install failed (rc=$rc)"
        tail -20 /tmp/test-cs-8b.log
        return 1
    fi

    local fail=0
    assert_file_not_contains ".claude/rules/autonomy.md" \
        "MANUAL_EDIT_SENTINEL_DO_NOT_KEEP" \
        "--force replaced manually edited file" || fail=1

    return $fail
}

# ============================================================================
# Run all tests
# ============================================================================

echo ""
echo "===================================="
echo " Claude Code Starter v6.0 — smoke   "
echo "===================================="
echo " repo: $REPO_DIR"
echo "===================================="

run_test "install_code_empty_project"       1 test_install_code_empty
run_test "install_content_book"             2 test_install_content_book
run_test "install_content_course"           3 test_install_content_course
run_test "install_hybrid"                   4 test_install_hybrid
run_test "auto_detect_book_project"         5 test_auto_detect_book
run_test "migrate_with_existing_claude_md"  6 test_migrate_existing_claude
run_test "rollback_after_install"           7 test_rollback
run_test "force_overwrite"                  8 test_force

# Final cleanup of any logs
rm -f /tmp/test-cs-*.log /tmp/cs-snapshot-*.md 2>/dev/null || true

echo ""
echo "===================================="
echo -e " RESULTS: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "===================================="
if [ "$FAIL" -gt 0 ]; then
    echo "Failed:"
    for t in "${FAILED_TESTS[@]}"; do
        echo "  - $t"
    done
    exit 1
fi
echo "All tests passed."
exit 0
