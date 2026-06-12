#!/bin/bash
#
# save-dialogs.sh — preserve Claude Code session JSONL files into project archive.
#
# TODO(manager): wire this into scripts/lib/install_common.sh so that
#   install_common() copies scripts/save-dialogs.sh into the target project,
#   and install_gitignore() adds these lines for shared/public mode:
#     .claude/dialogs/*.jsonl
#     .claude/dialogs/INDEX.md
#   Also copy templates/global/skills/save-dialog/ to each project type's
#   skills install loop, and the rule (dialog-preservation.md) to the rule
#   install loop. Currently only this repo's own .claude/ is wired manually.
#
# Behavior:
#   - Reads from $HOME/.claude/projects/<encoded-cwd>/*.jsonl
#   - Copies each into .claude/dialogs/<YYYY-MM-DD>_<session-id-short>.jsonl
#   - Idempotent: skips files whose hash matches an existing copy
#   - Updates .claude/dialogs/INDEX.md with one row per new/updated file
#   - Optional: --note "<topic>" attaches a note to new rows
#
# Usage:
#   bash scripts/save-dialogs.sh
#   bash scripts/save-dialogs.sh --note "тема диалога"
#
# Exits 0 even when source directory missing (prints a warning).

set -euo pipefail

# ---------- args ----------
NOTE=""
while [ $# -gt 0 ]; do
    case "$1" in
        --note)
            shift
            if [ $# -eq 0 ]; then
                echo "save-dialogs.sh: --note requires a value" >&2
                exit 1
            fi
            NOTE="$1"
            shift
            ;;
        --note=*)
            NOTE="${1#--note=}"
            shift
            ;;
        -h|--help)
            cat <<EOF
Usage: save-dialogs.sh [--note "topic"]
Preserves Claude Code JSONL session logs into .claude/dialogs/.
EOF
            exit 0
            ;;
        *)
            echo "save-dialogs.sh: unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

# ---------- detect CWD and encoded path ----------
CWD="$(pwd)"

# Encode path the way Claude Code does it: each '/' -> '-', and '_' -> '-' too.
# Leading '/' also becomes '-', producing e.g.
#   /Users/foo/bar      -> -Users-foo-bar
#   /Users/foo/my_proj  -> -Users-foo-my-proj
ENCODED="$(printf '%s' "$CWD" | sed -e 's|/|-|g' -e 's|_|-|g')"

SRC_DIR="$HOME/.claude/projects/$ENCODED"
DST_DIR="./.claude/dialogs"
INDEX="$DST_DIR/INDEX.md"

# ---------- preflight ----------
if [ ! -d "$SRC_DIR" ]; then
    echo "save-dialogs.sh: no Claude Code project dir at $SRC_DIR — nothing to save"
    exit 0
fi

mkdir -p "$DST_DIR"

# ---------- helpers ----------

# Portable hash (sha1) — picks whichever is available on macOS/Linux.
hash_file() {
    local f="$1"
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 1 "$f" 2>/dev/null | awk '{print $1}'
    elif command -v sha1sum >/dev/null 2>&1; then
        sha1sum "$f" 2>/dev/null | awk '{print $1}'
    else
        # last resort — file size + mtime; not a real hash but stable enough
        if [ "$(uname)" = "Darwin" ]; then
            stat -f '%z-%m' "$f" 2>/dev/null
        else
            stat -c '%s-%Y' "$f" 2>/dev/null
        fi
    fi
}

# Portable mtime as YYYY-MM-DD.
mtime_date() {
    local f="$1"
    if [ "$(uname)" = "Darwin" ]; then
        stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null
    else
        date -u -r "$f" '+%Y-%m-%d' 2>/dev/null || date '+%Y-%m-%d'
    fi
}

ensure_index_header() {
    if [ ! -f "$INDEX" ]; then
        cat > "$INDEX" <<EOF
# Dialog Archive

Сохранённые JSONL-диалоги Claude Code. Подробнее: rule \`dialog-preservation\`.

| Date | File | Session | Note |
|------|------|---------|------|
EOF
    fi
}

# ---------- collect candidates ----------
shopt -s nullglob 2>/dev/null || true

SAVED=0
NEW=0
UPDATED=0

# Collect JSONLs (avoid mapfile / readarray for bash-3 compat)
JSONLS=""
for f in "$SRC_DIR"/*.jsonl; do
    [ -f "$f" ] || continue
    JSONLS="$JSONLS$f"$'\n'
done

if [ -z "$JSONLS" ]; then
    echo "save-dialogs.sh: no *.jsonl files in $SRC_DIR"
    exit 0
fi

ensure_index_header

# ---------- iterate ----------
# Use process substitution carefully — keep counters in main shell by reading
# from a here-string (bash 3.2 compatible).
while IFS= read -r SRC; do
    [ -z "$SRC" ] && continue
    [ -f "$SRC" ] || continue

    BASENAME="$(basename "$SRC")"
    SESSION_FULL="${BASENAME%.jsonl}"
    # first 8 chars of session id
    SESSION_SHORT="$(printf '%s' "$SESSION_FULL" | cut -c1-8)"
    DATE_STR="$(mtime_date "$SRC")"
    [ -z "$DATE_STR" ] && DATE_STR="$(date '+%Y-%m-%d')"

    DST="$DST_DIR/${DATE_STR}_${SESSION_SHORT}.jsonl"

    STATUS=""
    if [ -f "$DST" ]; then
        SRC_HASH="$(hash_file "$SRC")"
        DST_HASH="$(hash_file "$DST")"
        if [ -n "$SRC_HASH" ] && [ "$SRC_HASH" = "$DST_HASH" ]; then
            # identical — skip silently
            continue
        else
            cp "$SRC" "$DST"
            STATUS="updated"
            UPDATED=$((UPDATED + 1))
        fi
    else
        cp "$SRC" "$DST"
        STATUS="new"
        NEW=$((NEW + 1))
    fi
    SAVED=$((SAVED + 1))

    # Append a row to INDEX.md only for genuinely new files.
    # For updates we leave the existing row alone (note may already be set).
    if [ "$STATUS" = "new" ]; then
        FILE_NAME="$(basename "$DST")"
        # Escape pipe chars in note (paranoia)
        SAFE_NOTE="$(printf '%s' "$NOTE" | sed 's/|/\\|/g')"
        printf '| %s | %s | %s | %s |\n' \
            "$DATE_STR" "$FILE_NAME" "$SESSION_SHORT" "$SAFE_NOTE" \
            >> "$INDEX"
    fi
done <<< "$JSONLS"

# ---------- summary ----------
TOTAL=0
for f in "$DST_DIR"/*.jsonl; do
    [ -f "$f" ] || continue
    TOTAL=$((TOTAL + 1))
done

echo "saved: $SAVED, new: $NEW, updated: $UPDATED, total in archive: $TOTAL"
