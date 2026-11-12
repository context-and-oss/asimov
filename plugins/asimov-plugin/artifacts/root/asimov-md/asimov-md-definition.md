---
artifact: asimov-md
maturity: assess
since: 2026-11-12
---

# Definition of asimov.md

The Asimov marker `asimov-init` writes to a product repo's root. Its presence tells the installed plugin that this repository uses Asimov; the plugin's hooks then inject the Asimov context into every session and every subagent from the plugin itself, at its installed version, cut to the entry points the marker enables. The marker carries no context of its own. Rendered from `asimov-md-template.md` in this folder. Design: `documentation/features/D101-asimov-init.html`.

Until 2026-11-12 this file *was* the context, imported from `CLAUDE.md` with `@asimov.md` and copied into an `AGENTS.md` region for Codex. Both carriers went stale with every plugin release and doubled the text; the hook replaces them in both harnesses (verified in Claude Code and in the Codex desktop app, 2026-11-12).

## 1. What it is for

- For the plugin: the switch and the scope. `hooks/asimov-context` runs at `SessionStart` and `SubagentStart`; when `asimov.md` exists it injects `skills/using-asimov/SKILL.md` (the session) or `skills/using-asimov/subagent.md` (a subagent), keeping only the blocks of the enabled parts, with the invocation syntax of the harness that runs the hook. The repo name is the folder's, the stacks are the folders under `documentation/conventions/`. No marker: nothing is injected.
- For people: three lines on what the file is and how to refresh the setup.

## 2. Required content

Frontmatter with one key per entry point, one per line, `enabled` or `disabled`, nothing nested or quoted (the hook parses lines, not YAML):

| Key | Enables in the context |
|---|---|
| `asimov-design` | `asimov-design` and `asimov-design-review`, the personas, `documentation/features/` |
| `asimov-spec` | `asimov-spec`, `specs/` |
| `asimov-build` | `asimov-build`, the agents, the delegation rule |
| `asimov-project` | `asimov-project`, `pm-advisor`, `project/` |

A key that is absent counts as `enabled`; `asimov-init` is always in. All four `disabled` is the opt-out: the marker stays and nothing is loaded but one line saying so.

Body: what the file is, that the context comes from the plugin, how to refresh.

## 3. Rules

- **Asimov-owned.** Regenerated wholesale on every run, never hand-edited except the `enabled`/`disabled` values, which a person may change by hand and the next run keeps. A developer's context belongs in `CLAUDE.md` or `AGENTS.md`.
- **Nothing imports it.** `asimov-init` adds no `@asimov.md` line to `CLAUDE.md` and no region to `AGENTS.md`; a run removes the line and the region an earlier version wrote, and nothing else in those files.
- **The context is the skill.** What a session is told lives in `skills/using-asimov/`, versioned with the plugin and cut by the marker's keys; a change to the context is a change there, never here. A part is a block between `<!-- part: X -->` and `<!-- /part -->` in that skill; the four parts (design, spec, build, project) are the only ones the hook knows, one per key.
- **Backwards-tolerant.** A marker without frontmatter, including the old full context file, counts as all four enabled, so a repo set up before 2026-11-12 gets the context on the next plugin update without a run.
- **Generic.** No product-specific entity names; the same body renders in any repo.
- The template's leading authoring comment never reaches the rendered file.

## 4. Relationship

| File | Role |
|---|---|
| `asimov-md-template.md` | The marker, with its four placeholders |
| `skills/using-asimov/SKILL.md` | The context the hook injects at session start, in part blocks |
| `skills/using-asimov/subagent.md` | The note the hook injects at subagent start, in part blocks |
| `hooks/asimov-context`, `hooks/run-hook.cmd`, `hooks/run-hook.ps1` | The hook and its launchers; `hooks/hooks.json` (Claude Code) and `hooks/hooks-codex.json` (Codex) register them |
| `documentation/features/D101-asimov-init.html` | The skill that writes the marker (R1–R5, NF1–NF2) |
| `../../documentation/conventions/conventions-definition.md` | The read-list the context points at |
