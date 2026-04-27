#!/usr/bin/env python3
"""merge_claude_md.py — Safe additive merge of CLAUDE.md files.

Merges a framework template CLAUDE.md into an existing user CLAUDE.md without
losing custom content. Stdlib only.

Usage:
    python3 merge_claude_md.py merge <existing.md> <template.md>
        Write merged result to stdout. Exit 2 if hard conflicts present.

    python3 merge_claude_md.py check <existing.md> <template.md>
        Exit 0 if mergeable, exit 2 if hard conflicts. Conflicts to stderr.

    python3 merge_claude_md.py propose <existing.md> <template.md>
        Generate markdown merge proposal report to stdout.

Errors (file missing, parse error) -> exit 1, message to stderr.
"""

from __future__ import annotations

import sys
import re
import difflib
from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class Section:
    level: int
    title: str  # original title text (may contain emoji/formatting)
    content: str  # body text (without heading line), raw
    subsections: List["Section"] = field(default_factory=list)
    raw_heading: str = ""  # full original heading line, e.g. "## **Bold** Title"
    merge_status: str = ""  # "added" | "kept_custom" | "merged" | "kept_existing" | "from_template"


# ---------------------------------------------------------------------------
# Parser
# ---------------------------------------------------------------------------

_HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
_FENCE_RE = re.compile(r"^(\s*)(```|~~~)")


def parse_md(text: str) -> Tuple[str, List[Section], List[Section]]:
    """Parse markdown into (preamble, h1_sections, h2_sections).

    - preamble: text before the first heading (may include frontmatter and H1
      title block content). For our purposes we keep frontmatter + first H1
      heading + any text up to the first H2 inside `preamble`.
    - h1_sections: list of level-1 sections detected (used to flag conflicts
      if multiple H1 are present).
    - h2_sections: ordered list of level-2 sections (the primary merge unit).
      Their `subsections` field contains level-3+ children.

    Code fences are tracked so that `## ` inside ``` blocks isn't treated as a
    heading.
    """
    lines = text.splitlines(keepends=False)
    in_fence = False
    fence_marker = ""

    # Pass 1: locate all headings (line index, level, title, raw_heading)
    headings: List[Tuple[int, int, str, str]] = []
    for i, line in enumerate(lines):
        m_fence = _FENCE_RE.match(line)
        if m_fence:
            marker = m_fence.group(2)
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif marker == fence_marker:
                in_fence = False
                fence_marker = ""
            continue
        if in_fence:
            continue
        m = _HEADING_RE.match(line)
        if m:
            level = len(m.group(1))
            title = m.group(2).strip()
            headings.append((i, level, title, line))

    # Identify preamble end: line index of first heading (any level), else EOF
    if not headings:
        # Whole file = preamble
        return ("\n".join(lines), [], [])

    first_heading_idx = headings[0][0]

    # Detect H1 sections (for conflict detection: multiple H1 = hard conflict)
    h1_indices = [idx for (idx, lvl, _, _) in headings if lvl == 1]

    # Find first H2; if no H2, the whole post-preamble area is one virtual section
    h2_positions = [(idx, lvl, title, raw) for (idx, lvl, title, raw) in headings if lvl == 2]

    if h2_positions:
        # Preamble = lines[0 : first H2 index]
        preamble_end = h2_positions[0][0]
    else:
        preamble_end = len(lines)

    preamble = "\n".join(lines[:preamble_end])

    # Build H1 sections list (mainly for counting)
    h1_sections: List[Section] = []
    for idx, lvl, title, raw in headings:
        if lvl == 1:
            h1_sections.append(Section(level=1, title=title, content="", raw_heading=raw))

    # Build H2 sections with H3+ subsections
    h2_sections: List[Section] = []
    if not h2_positions:
        return (preamble, h1_sections, h2_sections)

    # Compute end positions for H2 sections
    for i, (idx, lvl, title, raw) in enumerate(h2_positions):
        # End = next H2 start, or EOF
        if i + 1 < len(h2_positions):
            end = h2_positions[i + 1][0]
        else:
            end = len(lines)
        body_lines = lines[idx + 1 : end]
        body = "\n".join(body_lines)

        # Extract H3+ subsections from this block
        subs = _extract_subsections(body_lines, base_level=3)

        sec = Section(
            level=2,
            title=title,
            content=body,
            subsections=subs,
            raw_heading=raw,
        )
        h2_sections.append(sec)

    return (preamble, h1_sections, h2_sections)


def _extract_subsections(lines: List[str], base_level: int) -> List[Section]:
    """Extract subsections of `base_level` (and deeper) from a block of lines."""
    in_fence = False
    fence_marker = ""
    headings: List[Tuple[int, int, str, str]] = []
    for i, line in enumerate(lines):
        m_fence = _FENCE_RE.match(line)
        if m_fence:
            marker = m_fence.group(2)
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif marker == fence_marker:
                in_fence = False
                fence_marker = ""
            continue
        if in_fence:
            continue
        m = _HEADING_RE.match(line)
        if m:
            level = len(m.group(1))
            title = m.group(2).strip()
            if level == base_level:
                headings.append((i, level, title, line))

    sections: List[Section] = []
    for i, (idx, lvl, title, raw) in enumerate(headings):
        end = headings[i + 1][0] if i + 1 < len(headings) else len(lines)
        body = "\n".join(lines[idx + 1 : end])
        sections.append(
            Section(
                level=lvl,
                title=title,
                content=body,
                raw_heading=raw,
            )
        )
    return sections


# ---------------------------------------------------------------------------
# Normalization & similarity
# ---------------------------------------------------------------------------

_PUNCT_RE = re.compile(r"[^\w\s]", re.UNICODE)
_WS_RE = re.compile(r"\s+", re.UNICODE)
_MD_FORMAT_RE = re.compile(r"[*_`~]+")
_EMOJI_RE = re.compile(
    "["
    "\U0001F300-\U0001FAFF"
    "\U00002600-\U000027BF"
    "\U0001F1E6-\U0001F1FF"
    "]+",
    flags=re.UNICODE,
)


def normalize_title(title: str) -> str:
    t = _EMOJI_RE.sub("", title)
    t = _MD_FORMAT_RE.sub("", t)
    t = _PUNCT_RE.sub(" ", t)
    t = _WS_RE.sub(" ", t).strip().lower()
    return t


def normalize_content(text: str) -> str:
    """Normalize for similarity comparison: strip whitespace + punctuation."""
    t = _MD_FORMAT_RE.sub("", text)
    t = _PUNCT_RE.sub(" ", t)
    t = _WS_RE.sub(" ", t).strip().lower()
    return t


def similarity(a: str, b: str) -> float:
    na = normalize_content(a)
    nb = normalize_content(b)
    if not na and not nb:
        return 1.0
    if not na or not nb:
        return 0.0
    return difflib.SequenceMatcher(None, na, nb).ratio()


_PLACEHOLDER_RE = re.compile(r"\{\{[^}]+\}\}")


def is_placeholder_template(text: str) -> bool:
    """Returns True if a section looks like an unfilled framework template.

    A section is template-like if it contains at least one {{PLACEHOLDER}}.
    Template sections frequently surround placeholders with example values
    (e.g. "beginner / intermediate / advanced") that look like real text but
    are skeleton — so the share-based heuristic alone is unreliable.
    Presence of any placeholder is a strong signal that the section is not
    yet filled, and during migration we should prefer existing content if
    the user already wrote something concrete in the same section.
    """
    return bool(_PLACEHOLDER_RE.search(text))


def has_no_placeholders(text: str) -> bool:
    return not _PLACEHOLDER_RE.search(text)


# ---------------------------------------------------------------------------
# List/table parsing & merging
# ---------------------------------------------------------------------------

_LIST_ITEM_RE = re.compile(r"^(\s*)([-*+]|\d+\.)\s+(.+)$")
_TABLE_ROW_RE = re.compile(r"^\s*\|.*\|\s*$")
_TABLE_SEP_RE = re.compile(r"^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)+\|?\s*$")


def is_list_block(text: str) -> bool:
    lines = [l for l in text.splitlines() if l.strip()]
    if not lines:
        return False
    list_lines = sum(1 for l in lines if _LIST_ITEM_RE.match(l))
    return list_lines >= max(2, int(len(lines) * 0.6))


def parse_list_items(text: str) -> List[str]:
    items: List[str] = []
    for line in text.splitlines():
        m = _LIST_ITEM_RE.match(line)
        if m:
            items.append(m.group(3).strip())
    return items


def merge_lists(template_text: str, existing_text: str) -> str:
    """Merge two markdown list blocks: template first, then unique-from-existing."""
    t_items = parse_list_items(template_text)
    e_items = parse_list_items(existing_text)
    seen = set()
    merged = []
    for item in t_items + e_items:
        key = normalize_content(item)
        if key in seen:
            continue
        seen.add(key)
        merged.append(item)
    return "\n".join(f"- {it}" for it in merged)


def parse_table(text: str) -> Optional[Tuple[List[str], List[List[str]]]]:
    """Return (headers, rows) or None if not a recognizable table."""
    lines = [l for l in text.splitlines() if l.strip()]
    if len(lines) < 2:
        return None
    # Find a row that looks like a header followed by a separator
    for i in range(len(lines) - 1):
        if _TABLE_ROW_RE.match(lines[i]) and _TABLE_SEP_RE.match(lines[i + 1]):
            header = _split_table_row(lines[i])
            rows: List[List[str]] = []
            for j in range(i + 2, len(lines)):
                if _TABLE_ROW_RE.match(lines[j]):
                    rows.append(_split_table_row(lines[j]))
                else:
                    break
            return (header, rows)
    return None


def _split_table_row(line: str) -> List[str]:
    s = line.strip()
    if s.startswith("|"):
        s = s[1:]
    if s.endswith("|"):
        s = s[:-1]
    return [c.strip() for c in s.split("|")]


def is_table_block(text: str) -> bool:
    return parse_table(text) is not None


def merge_tables(
    template_text: str, existing_text: str
) -> Tuple[Optional[str], Optional[str]]:
    """Merge two markdown tables. Returns (merged_text, conflict_or_None)."""
    t_tab = parse_table(template_text)
    e_tab = parse_table(existing_text)
    if not t_tab or not e_tab:
        return (None, "table_parse_failed")
    t_header, t_rows = t_tab
    e_header, e_rows = e_tab
    if [normalize_content(c) for c in t_header] != [normalize_content(c) for c in e_header]:
        return (None, "table_headers_differ")
    seen = set()
    merged_rows: List[List[str]] = []
    for row in t_rows + e_rows:
        key = "|".join(normalize_content(c) for c in row)
        if key in seen:
            continue
        seen.add(key)
        merged_rows.append(row)

    out_lines = []
    out_lines.append("| " + " | ".join(t_header) + " |")
    out_lines.append("| " + " | ".join(["---"] * len(t_header)) + " |")
    for row in merged_rows:
        # Pad/truncate to header width
        cells = list(row) + [""] * (len(t_header) - len(row))
        cells = cells[: len(t_header)]
        out_lines.append("| " + " | ".join(cells) + " |")
    return ("\n".join(out_lines), None)


# ---------------------------------------------------------------------------
# Section merge
# ---------------------------------------------------------------------------

SIM_KEEP_EXISTING = 0.85
SIM_HARD_CONFLICT = 0.40


def merge_sections(
    existing: Section, template: Section
) -> Tuple[Section, Optional[str]]:
    """Merge two sections that share a normalized title.

    Returns (merged_section, conflict_description_or_None).
    """
    sim = similarity(existing.content, template.content)
    norm_e = normalize_content(existing.content)
    norm_t = normalize_content(template.content)

    # Case A: nearly identical -> keep existing (preserves user formatting)
    if sim >= SIM_KEEP_EXISTING:
        merged = Section(
            level=2,
            title=existing.title,
            content=existing.content,
            subsections=existing.subsections,
            raw_heading=existing.raw_heading,
            merge_status="kept_existing",
        )
        return (merged, None)

    # Case B: existing fully contained in template -> use template (framework update)
    if norm_e and norm_e in norm_t:
        merged = Section(
            level=2,
            title=template.title,
            content=template.content,
            subsections=template.subsections,
            raw_heading=template.raw_heading,
            merge_status="from_template",
        )
        return (merged, None)

    # Case C: template fully contained in existing -> keep existing (user expanded)
    if norm_t and norm_t in norm_e:
        merged = Section(
            level=2,
            title=existing.title,
            content=existing.content,
            subsections=existing.subsections,
            raw_heading=existing.raw_heading,
            merge_status="kept_existing",
        )
        return (merged, None)

    # Case D: list blocks -> merge
    if is_list_block(existing.content) and is_list_block(template.content):
        merged_text = merge_lists(template.content, existing.content)
        merged = Section(
            level=2,
            title=template.title,
            content=merged_text,
            raw_heading=template.raw_heading,
            merge_status="merged",
        )
        return (merged, None)

    # Case E: table blocks -> merge if headers match
    if is_table_block(existing.content) and is_table_block(template.content):
        merged_text, conflict = merge_tables(template.content, existing.content)
        if merged_text is not None:
            merged = Section(
                level=2,
                title=template.title,
                content=merged_text,
                raw_heading=template.raw_heading,
                merge_status="merged",
            )
            return (merged, None)
        return (
            Section(
                level=2,
                title=existing.title,
                content=existing.content,
                raw_heading=existing.raw_heading,
                merge_status="kept_existing",
            ),
            f'Section "## {existing.title}": tables with incompatible headers',
        )

    # Case E.5: template is a placeholder skeleton (e.g. "{{PROJECT_PURPOSE}}")
    # and existing has real user content -> keep existing, no conflict.
    # This is the common case when migrating an already-filled CLAUDE.md.
    if is_placeholder_template(template.content) and not is_placeholder_template(
        existing.content
    ):
        merged = Section(
            level=2,
            title=existing.title,
            content=existing.content,
            subsections=existing.subsections,
            raw_heading=existing.raw_heading,
            merge_status="kept_existing",
        )
        return (merged, None)

    # Case F: low similarity -> hard conflict
    if sim < SIM_HARD_CONFLICT:
        return (
            Section(
                level=2,
                title=existing.title,
                content=existing.content,
                raw_heading=existing.raw_heading,
                merge_status="kept_existing",
            ),
            f'Section "## {existing.title}": conflicting content (similarity {sim:.2f})',
        )

    # Case G: medium similarity, no list/table -> append template content as note
    # (additive — preserves both, doesn't lose info)
    combined = (
        existing.content.rstrip()
        + "\n\n<!-- merged from framework template -->\n\n"
        + template.content.lstrip()
    )
    merged = Section(
        level=2,
        title=existing.title,
        content=combined,
        raw_heading=existing.raw_heading,
        merge_status="merged",
    )
    return (merged, None)


# ---------------------------------------------------------------------------
# File-level merge
# ---------------------------------------------------------------------------

def _render_section(sec: Section) -> str:
    heading = sec.raw_heading or ("#" * sec.level + " " + sec.title)
    body = sec.content.rstrip("\n")
    if body:
        return heading + "\n" + body
    return heading


def merge_files(existing_text: str, template_text: str) -> Tuple[str, List[str]]:
    """Merge two CLAUDE.md texts. Returns (merged_text, conflicts)."""
    e_pre, e_h1, e_h2 = parse_md(existing_text)
    t_pre, t_h1, t_h2 = parse_md(template_text)

    conflicts: List[str] = []

    # Multiple H1 in existing -> structural notice (non-blocking).
    # Many real CLAUDE.md files have a banner-style H1 plus a project H1,
    # or accumulated H1s from older framework iterations. The merger flattens
    # to the first H1 (or template H1) and proceeds; we surface this as info
    # rather than blocking the migration.
    # No-op here: parse_md already keeps everything reachable; user can
    # post-edit to dedupe headings if they want.

    # Build lookup from normalized title -> existing section index
    e_by_norm = {normalize_title(s.title): i for i, s in enumerate(e_h2)}
    matched_existing_idx: set = set()

    # Walk template sections, in template order
    out_sections: List[Section] = []
    for t_sec in t_h2:
        key = normalize_title(t_sec.title)
        if key in e_by_norm:
            ei = e_by_norm[key]
            matched_existing_idx.add(ei)
            merged, conflict = merge_sections(e_h2[ei], t_sec)
            out_sections.append(merged)
            if conflict:
                conflicts.append(conflict)
        else:
            t_sec.merge_status = "added"
            out_sections.append(t_sec)

    # Append existing sections not present in template (custom user sections)
    # Preserve their relative order from the existing file.
    for i, e_sec in enumerate(e_h2):
        if i in matched_existing_idx:
            continue
        e_sec.merge_status = "kept_custom"
        out_sections.append(e_sec)

    # Choose preamble: prefer existing preamble (user's H1 + any intro text);
    # fall back to template preamble if existing is empty.
    preamble = e_pre if e_pre.strip() else t_pre

    parts: List[str] = []
    if preamble.strip():
        parts.append(preamble.rstrip())
    for sec in out_sections:
        parts.append(_render_section(sec))

    merged_text = "\n\n".join(p for p in parts if p) + "\n"
    return (merged_text, conflicts)


# ---------------------------------------------------------------------------
# Proposal report
# ---------------------------------------------------------------------------

def build_proposal(existing_text: str, template_text: str, exfile: str, tpfile: str) -> str:
    e_pre, e_h1, e_h2 = parse_md(existing_text)
    t_pre, t_h1, t_h2 = parse_md(template_text)

    e_by_norm = {normalize_title(s.title): s for s in e_h2}
    t_by_norm = {normalize_title(s.title): s for s in t_h2}

    added = [t for t in t_h2 if normalize_title(t.title) not in e_by_norm]
    kept = [e for e in e_h2 if normalize_title(e.title) not in t_by_norm]

    conflicts: List[Tuple[Section, Section, str]] = []
    common = [
        (e_by_norm[k], t_by_norm[k])
        for k in t_by_norm
        if k in e_by_norm
    ]
    for e_sec, t_sec in common:
        _, conflict = merge_sections(e_sec, t_sec)
        if conflict:
            conflicts.append((e_sec, t_sec, conflict))

    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    lines: List[str] = []
    lines.append("# CLAUDE.md Merge Proposal")
    lines.append("")
    lines.append(f"**Generated:** {now}")
    lines.append(f"**Existing file:** {exfile} (sections: {len(e_h2)})")
    lines.append(f"**Template file:** {tpfile} (sections: {len(t_h2)})")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- {len(added)} sections will be added from framework template")
    lines.append(f"- {len(kept)} sections from your custom CLAUDE.md will be preserved")
    if conflicts:
        lines.append(f"- {len(conflicts)} hard conflict(s) require resolution")
    else:
        lines.append("- 0 hard conflicts — merge can proceed automatically")
    lines.append("")

    if conflicts:
        lines.append("## Conflicts")
        lines.append("")
        for idx, (e_sec, t_sec, desc) in enumerate(conflicts, start=1):
            lines.append(f'### Conflict {idx}: Section "## {e_sec.title}"')
            lines.append("")
            lines.append(f"_Detection:_ {desc}")
            lines.append("")
            lines.append("**Your version (excerpt):**")
            lines.append("")
            lines.append("```")
            lines.append(_excerpt(e_sec.content, 6))
            lines.append("```")
            lines.append("")
            lines.append("**Template version (excerpt):**")
            lines.append("")
            lines.append("```")
            lines.append(_excerpt(t_sec.content, 6))
            lines.append("```")
            lines.append("")
            lines.append("**Proposed resolution:**")
            lines.append(
                f'Rename your "## {e_sec.title}" → "## {e_sec.title} (legacy)" and '
                f'add the new "## {t_sec.title}" from template. Both will coexist; '
                "you can manually consolidate later."
            )
            lines.append("")

    if added:
        lines.append("## Sections to be added")
        lines.append("")
        for sec in added:
            lines.append(f"- ## {sec.title} (from template)")
        lines.append("")

    if kept:
        lines.append("## Sections to be preserved")
        lines.append("")
        for sec in kept:
            lines.append(f"- ## {sec.title} (from your file)")
        lines.append("")

    lines.append("## To apply this proposal")
    lines.append("")
    lines.append("```bash")
    lines.append("bash init-project.sh --apply-proposal")
    lines.append("```")
    lines.append("")
    return "\n".join(lines)


def _excerpt(text: str, max_lines: int) -> str:
    lines = [l for l in text.splitlines() if l.strip()]
    out = lines[:max_lines]
    if len(lines) > max_lines:
        out.append("...")
    return "\n".join(out) if out else "(empty)"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

USAGE = (
    "Usage:\n"
    "  merge_claude_md.py merge   <existing.md> <template.md>\n"
    "  merge_claude_md.py check   <existing.md> <template.md>\n"
    "  merge_claude_md.py propose <existing.md> <template.md>\n"
)


def _read_file(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        print(f"Error reading {path}: {e}", file=sys.stderr)
        sys.exit(1)


def main(argv: Optional[List[str]] = None) -> int:
    argv = argv if argv is not None else sys.argv[1:]
    if len(argv) < 3:
        print(USAGE, file=sys.stderr)
        return 1

    cmd, exfile, tpfile = argv[0], argv[1], argv[2]
    if cmd not in ("merge", "check", "propose"):
        print(f"Error: unknown command '{cmd}'", file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 1

    existing_text = _read_file(exfile)
    template_text = _read_file(tpfile)

    try:
        if cmd == "check":
            _, conflicts = merge_files(existing_text, template_text)
            if conflicts:
                for c in conflicts:
                    print(c, file=sys.stderr)
                return 2
            return 0

        if cmd == "merge":
            merged, conflicts = merge_files(existing_text, template_text)
            if conflicts:
                for c in conflicts:
                    print(c, file=sys.stderr)
                print(
                    "Hard conflict(s) detected — run `propose` to review.",
                    file=sys.stderr,
                )
                return 2
            sys.stdout.write(merged)
            return 0

        if cmd == "propose":
            report = build_proposal(existing_text, template_text, exfile, tpfile)
            sys.stdout.write(report)
            return 0

    except Exception as e:  # noqa: BLE001
        print(f"Error: {e}", file=sys.stderr)
        return 1

    return 1


if __name__ == "__main__":
    sys.exit(main())
