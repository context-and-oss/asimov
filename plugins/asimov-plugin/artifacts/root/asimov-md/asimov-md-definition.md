---
artifact: asimov-md
maturity: assess
since: 2026-09-10
---

# Definition of asimov.md

The Asimov context file `/asimov-init` writes to a product repo's root, wires into `CLAUDE.md` with a single `@asimov.md` import (Claude Code) and carries inline in the `asimov:start`/`asimov:end` managed region of `AGENTS.md` (Codex, which reads `AGENTS.md` and does not expand `@`-imports). Rendered from `asimov-md-template.md` in this folder. Design: `documentation/features/D101-asimov-init.html`.

## 1. What it is for

The coding agent — Claude Code or Codex — working in the product repo learns the Asimov layer from this one file: where documentation lives, where D101s go, where the convention overlay is, and which Asimov commands and subagents exist. The developer's own repo context stays in `CLAUDE.md`; this file adds the toolkit's.

## 2. Required content

- The `documentation/` taxonomy — `features/`, `conventions/`, `reference/`, root `D100-*` / `E100-*` — and where D101s live.
- The convention-overlay pointer: `documentation/conventions/<stack>/README.md` per detected stack.
- The Asimov commands and subagents available in the repo.
- Repo name, detected stacks (or "none detected yet"), generation date.

## 3. Rules

- **Asimov-owned.** Regenerated wholesale on every run, never hand-edited. A note a developer adds here is lost on the next run; it belongs in `CLAUDE.md`.
- **One region in AGENTS.md.** The same rendered text sits between the two markers; everything outside them is the team's. Broken or duplicated markers stop the write to that file.
- **One line in CLAUDE.md.** The import is a single bare `@asimov.md` line: added once if absent, never re-added, and the only edit ever made to an existing `CLAUDE.md`. When none exists, a minimal one is created holding the import and a pointer to `/init`.
- **Generic.** No product-specific entity names; the same body renders in any repo.
- The template's leading authoring comment never reaches the rendered file.

## 4. Relationship

| File | Role |
|---|---|
| `asimov-md-template.md` | The body, with its placeholders |
| `documentation/features/D101-asimov-init.html` | The command that writes it (R1–R5, NF1–NF2) |
| `../../documentation/conventions/conventions-definition.md` | The read-list this file points at |
