---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T016"
title: "Architecture and repo guide records"
role: human
tier: mid
after: [T011, T014]
traces: [R3, §6.1]
owns:
  create: []
  modify: [documentation/D100-Asimov-architecture.md, CLAUDE.md]
  test: []
  regenerates: []
consumes: [risk-log-definition.md, risk-log-template.html, risk-log.ps1, artifact-risk-log-authoring, artifact-risk-log-view, "asimov-project (plugins/asimov-plugin/skills/asimov-project/SKILL.md)"]
produces: []
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T016 — Architecture and repo guide records

## 1. Intent

The architecture and the repo guide record what shipped: the risk log is maintained through the frame's entry point `asimov-project` in Claude Code and Codex alike, by two artifact skills and a script, with its pair under `artifacts/project/risk-log/` and its leftover writes kept out of git (D101 R3, §6.1, §7.5).

## 2. Behaviour

none: this task adds no behaviour; its check is the `git status` and `git diff --check` commands in §3.

## 3. Done-when

1. `git status --short -- documentation/D100-Asimov-architecture.md CLAUDE.md` prints both files as modified and nothing else.
2. `git diff --check -- documentation/D100-Asimov-architecture.md CLAUDE.md` exits 0.

## 4. Constraints and stops

- **Must:** D100 §3, §4.3 and §4.6 move the risk log from "in flight" on PR 34 to built: the §4.3 `asimov-project` row no longer calls it a skeleton with an empty artifact table, and §4.6 gains a row each for `artifact-risk-log-authoring` (with its script) and `artifact-risk-log-view`.
- **Must:** D100 §5 shows `artifacts/project/risk-log/` with the definition and the template, and `skills/artifact-risk-log-authoring/scripts/risk-log.ps1` beside its skill, and the paragraph on what exists today names them; §9 drops the risk log from what is not yet built.
- **Must:** `CLAUDE.md`'s quick map gains the two skills, the script and the artifact folder, and `asimov-project` is no longer a skeleton there; *How to add a project artifact* and *Current state* say the risk log is built, not that it arrives with PR 34.
- **Must:** hard rule 9 names `project/*.new` in the `.gitignore` block both init entry points write and `asimov-project` appends, and names the risk log's skills and definition among the files that share the `project/` literal.
- **Must not:** touch the §4.5 rows of D100 (T011's), `documentation/model-choice.md` (no change, D101 §7.5), or a plugin manifest.
- **Stops:** D100 §4.5 lacks the risk log's definition and template rows: report it, since they are T011's and move with its commit.

## 5. Out of scope

- The website's two Project frame pages and `D101-website.html` — T015
- D100 §4.5 maturity rows — T011
