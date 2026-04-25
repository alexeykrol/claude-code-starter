# Rule: Content Formats

## Purpose

Задать базовые форматы content units, metadata, index, export bundle.

## Common Metadata

```yaml
title: "Title"
type: "book|course|lesson|chapter|knowledge-base|document|transcript|report"
status: "draft|review|approved|published|archived"
audience: "beginner|intermediate|advanced|mixed"
author: "Author"
updated: "YYYY-MM-DD"
sources:
  - "path-or-url"
tags:
  - tag
```

## Chapter Format

```markdown
# Chapter NN: Title

**Status:** draft/review/approved
**Brief:** `briefs/chapter-NN.md`
**Sources:** `source/...`

[Text]

## Notes

[Optional editorial notes, not for publication.]
```

## Lesson Format

```markdown
# [Lesson Title]

**Learning Objective:** By the end, you will [action].
**Prerequisites:** [What should be known first]
**Duration:** [Estimate]

## The Problem
[Why this matters.]

## Explanation
[Plain language first, term second.]

## Example
[Concrete example or scenario.]

## Practice
[Exercise link or task.]

## Summary
[One-sentence recap.]

**Next:** [Next lesson or concept.]
```

## Transcript Format

```markdown
# <Lecture Title>

**Course:** <Course Name>
**Section:** <Section #> - <Section Name>
**Lecture:** <Lecture #>
**Duration:** <Duration>
**URL:** <Source URL>

---

## Transcript

[Clean transcript. Remove timestamps unless useful. Preserve thought flow.]

---

## Screenshots

![Description](../screenshots/SXX-LXX-description.png)

---

## Resources & Links

- [Resource](https://example.com) - description

---

## Notes

- **Key Takeaway:** ...
- **Flags:** ...
```

## Knowledge Base Article Format

```markdown
# [Topic]

**Status:** draft/review/approved
**Tags:** tag1, tag2
**Related:** [Other topic](../path.md)

## Summary
[Short answer.]

## Details
[Structured content.]

## Sources
- [source](path-or-url)

## Links
- [related](path.md)
```

## Course Index Format

```markdown
# [Course Name] - Index

**Platform:** local / Udemy / Skilljar / WordPress / GitHub
**Total Lessons:** NN
**Total Duration:** NN hours
**Status:** draft/review/complete

## Overview
[2-3 sentences.]

## Table of Contents

| # | Section | Lesson | Duration | Description | File |
|---|---------|--------|----------|-------------|------|
| 1 | Section 1 | Lesson title | 8 min | Description | [Link](Section-01/lesson-01.md) |

## Learning Objectives
- [Objective] → [Lesson](path.md)

## Key Concepts
- **Term:** definition
```

## Registry Format

```markdown
# Content Registry

**Last Updated:** YYYY-MM-DD
**Total Items:** NN

| ID | Title | Type | Status | Location | Updated |
|----|-------|------|--------|----------|---------|
| item-001 | Title | lesson | approved | [file](path.md) | YYYY-MM-DD |
```

## Export Bundle

```text
<content-slug>/
  meta.yaml
  INDEX.md or program.md
  sources.md
  content/
    NN-slug.md
  assets/
  review-report.md
```

Rules:
- slugs should be stable
- internal links should be relative
- generated metadata in `_meta/`
- do not publish `_meta/` unless explicitly requested
