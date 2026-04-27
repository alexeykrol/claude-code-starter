#!/usr/bin/env python3
"""Tests for merge_claude_md.py — stdlib unittest."""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SCRIPT = REPO_ROOT / "scripts" / "lib" / "merge_claude_md.py"

# Make merge module importable as a library too
sys.path.insert(0, str(SCRIPT.parent))
import merge_claude_md as mm  # noqa: E402


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def write_tmp(text: str) -> str:
    fd, path = tempfile.mkstemp(suffix=".md")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(text)
    return path


def run_cli(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        capture_output=True,
        text=True,
    )


# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------

class TestParser(unittest.TestCase):
    def test_parse_basic(self):
        text = (
            "# Title\n\nIntro text.\n\n"
            "## A\n\nbody A\n\n"
            "## B\n\nbody B\n"
        )
        pre, h1, h2 = mm.parse_md(text)
        self.assertIn("# Title", pre)
        self.assertEqual(len(h1), 1)
        self.assertEqual(len(h2), 2)
        self.assertEqual(h2[0].title, "A")
        self.assertEqual(h2[1].title, "B")

    def test_code_fence_not_a_heading(self):
        text = (
            "# T\n\n"
            "## Real Section\n\n"
            "```\n## Not a heading\n```\n\n"
            "## Another\n\nx\n"
        )
        _, _, h2 = mm.parse_md(text)
        titles = [s.title for s in h2]
        self.assertEqual(titles, ["Real Section", "Another"])

    def test_no_h2_only_h1(self):
        text = "# Just Title\n\nSome body without h2.\n"
        pre, h1, h2 = mm.parse_md(text)
        self.assertEqual(len(h2), 0)
        self.assertEqual(len(h1), 1)

    def test_multiple_h1_detected(self):
        text = "# One\n\nx\n\n# Two\n\n## Sec\n\ny\n"
        _, h1, _ = mm.parse_md(text)
        self.assertEqual(len(h1), 2)


class TestNormalization(unittest.TestCase):
    def test_normalize_title_strips_emoji_and_format(self):
        self.assertEqual(mm.normalize_title("## **Bold** Title"), "bold title")
        self.assertEqual(mm.normalize_title("Архитектура"), "архитектура")
        self.assertEqual(mm.normalize_title("Workflow!"), "workflow")

    def test_similarity_identical(self):
        self.assertGreaterEqual(mm.similarity("hello world", "hello world"), 0.99)

    def test_similarity_low(self):
        self.assertLess(mm.similarity("apple", "completely different content"), 0.4)


class TestListMerging(unittest.TestCase):
    def test_merge_lists_dedup(self):
        t = "- a\n- b\n- c"
        e = "- b\n- d"
        out = mm.merge_lists(t, e)
        items = [l[2:] for l in out.splitlines()]
        self.assertEqual(items, ["a", "b", "c", "d"])

    def test_is_list_block(self):
        self.assertTrue(mm.is_list_block("- one\n- two\n- three"))
        self.assertFalse(mm.is_list_block("This is just prose, no list."))


class TestTableMerging(unittest.TestCase):
    def test_parse_and_merge_tables(self):
        t = "| A | B |\n| --- | --- |\n| 1 | 2 |\n| 3 | 4 |"
        e = "| A | B |\n| --- | --- |\n| 3 | 4 |\n| 5 | 6 |"
        merged, conflict = mm.merge_tables(t, e)
        self.assertIsNone(conflict)
        self.assertIn("| 1 | 2 |", merged)
        self.assertIn("| 5 | 6 |", merged)
        # dedup
        self.assertEqual(merged.count("| 3 | 4 |"), 1)

    def test_table_headers_differ(self):
        t = "| A | B |\n| --- | --- |\n| 1 | 2 |"
        e = "| X | Y |\n| --- | --- |\n| 9 | 9 |"
        merged, conflict = mm.merge_tables(t, e)
        self.assertIsNone(merged)
        self.assertEqual(conflict, "table_headers_differ")


class TestMergeFiles(unittest.TestCase):
    def test_identical_files(self):
        text = "# T\n\n## A\n\nbody\n\n## B\n\nbody2\n"
        merged, conflicts = mm.merge_files(text, text)
        self.assertEqual(conflicts, [])
        self.assertIn("## A", merged)
        self.assertIn("## B", merged)

    def test_existing_empty_returns_template(self):
        existing = ""
        template = "# T\n\n## A\n\nbody\n"
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [])
        self.assertIn("## A", merged)

    def test_template_adds_section(self):
        existing = "# T\n\n## A\n\nbody A\n"
        template = "# T\n\n## A\n\nbody A\n\n## B\n\nbody B\n"
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [])
        self.assertIn("## A", merged)
        self.assertIn("## B", merged)

    def test_existing_custom_section_preserved(self):
        existing = (
            "# T\n\n## Common\n\nbody\n\n## Custom\n\nuser-only text\n"
        )
        template = "# T\n\n## Common\n\nbody\n\n## NewFromTemplate\n\nx\n"
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [])
        self.assertIn("## Custom", merged)
        self.assertIn("user-only text", merged)
        self.assertIn("## NewFromTemplate", merged)
        # Custom should appear after the matched template sections
        custom_pos = merged.find("## Custom")
        new_pos = merged.find("## NewFromTemplate")
        self.assertGreater(custom_pos, new_pos)

    def test_hard_conflict_detected(self):
        existing = "# T\n\n## Архитектура\n\nThis project is a code repository with src/, lib/, tests/.\n"
        template = "# T\n\n## Архитектура\n\nKnowledge tree: book/, chapters/, fragments/.\n"
        _, conflicts = mm.merge_files(existing, template)
        self.assertTrue(any("Архитектура" in c for c in conflicts))

    def test_list_sections_merged(self):
        existing = "# T\n\n## Tools\n\n- vim\n- git\n"
        template = "# T\n\n## Tools\n\n- git\n- python\n- make\n"
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [])
        # All four items present, dedup on git
        self.assertIn("- vim", merged)
        self.assertIn("- python", merged)
        self.assertIn("- make", merged)
        self.assertEqual(merged.count("- git"), 1)

    def test_nearly_identical_keeps_existing_format(self):
        existing = "# T\n\n## Workflow\n\nDo X then Y then Z.\n"
        template = "# T\n\n## Workflow\n\nDo X then Y then Z\n"  # no period
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [])
        self.assertIn("Do X then Y then Z.", merged)

    def test_placeholder_template_keeps_existing(self):
        # Real-world case: existing has user-filled content; template has
        # only placeholders. Must not be treated as a conflict.
        existing = (
            "# Project\n\n## Назначение\n\n"
            "Content production engine. Input: brief. Output: markdown bundle.\n"
        )
        template = (
            "# Project\n\n## Назначение\n\n"
            "{{PROJECT_PURPOSE}}\n\n"
            "**Тип контента:** {{CONTENT_TYPE}}\n"
        )
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [], msg=f"unexpected conflicts: {conflicts}")
        self.assertIn("Content production engine", merged)
        self.assertNotIn("{{PROJECT_PURPOSE}}", merged)

    def test_multiple_h1_does_not_block_merge(self):
        # Real CLAUDE.md sometimes carry multiple H1 (banner + project title).
        # Should warn-but-merge, not fail.
        existing = "# Banner\n\nfluff\n\n# Project\n\n## A\n\nbody\n"
        template = "# Project\n\n## A\n\nbody\n\n## B\n\nnew section\n"
        merged, conflicts = mm.merge_files(existing, template)
        self.assertEqual(conflicts, [], msg=f"unexpected conflicts: {conflicts}")
        self.assertIn("## B", merged)
        self.assertIn("new section", merged)


class TestCLI(unittest.TestCase):
    def test_cli_merge_clean(self):
        e = write_tmp("# T\n\n## A\n\nbody\n")
        t = write_tmp("# T\n\n## A\n\nbody\n\n## B\n\nx\n")
        try:
            r = run_cli("merge", e, t)
            self.assertEqual(r.returncode, 0, msg=r.stderr)
            self.assertIn("## B", r.stdout)
        finally:
            os.unlink(e)
            os.unlink(t)

    def test_cli_check_clean(self):
        e = write_tmp("# T\n\n## A\n\nbody\n")
        t = write_tmp("# T\n\n## A\n\nbody\n\n## B\n\nx\n")
        try:
            r = run_cli("check", e, t)
            self.assertEqual(r.returncode, 0, msg=r.stderr)
        finally:
            os.unlink(e)
            os.unlink(t)

    def test_cli_check_conflict(self):
        e = write_tmp("# T\n\n## Архитектура\n\ncode project src/ lib/ tests/\n")
        t = write_tmp(
            "# T\n\n## Архитектура\n\nknowledge tree book/ chapters/ fragments/\n"
        )
        try:
            r = run_cli("check", e, t)
            self.assertEqual(r.returncode, 2)
            self.assertIn("Архитектура", r.stderr)
        finally:
            os.unlink(e)
            os.unlink(t)

    def test_cli_propose(self):
        e = write_tmp("# T\n\n## A\n\nbody\n\n## Custom\n\nx\n")
        t = write_tmp("# T\n\n## A\n\nbody\n\n## NewSec\n\ny\n")
        try:
            r = run_cli("propose", e, t)
            self.assertEqual(r.returncode, 0, msg=r.stderr)
            self.assertIn("Merge Proposal", r.stdout)
            self.assertIn("Custom", r.stdout)
            self.assertIn("NewSec", r.stdout)
        finally:
            os.unlink(e)
            os.unlink(t)

    def test_cli_missing_file(self):
        r = run_cli("merge", "/no/such/file.md", "/also/missing.md")
        self.assertEqual(r.returncode, 1)
        self.assertIn("not found", r.stderr)

    def test_cli_bad_command(self):
        r = run_cli("frobnicate", "a", "b")
        self.assertEqual(r.returncode, 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
