---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T013"
title: "Risk log view skill"
role: human
tier: low
after: [T010]
traces: [R30, R31, AC35]
owns:
  create: [plugins/asimov-plugin/skills/artifact-risk-log-view/SKILL.md]
  modify: []
  test: []
  regenerates: []
consumes: [risk-log.ps1, "artifact-s101-view (plugins/asimov-plugin/skills/artifact-s101-view/SKILL.md)"]
produces: [artifact-risk-log-view]
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T013 — Risk log view skill

## 1. Intent

The read side of the risk log: it calls the script's `-View` by its full path, prints the text unchanged and writes nothing, and holds the view's layout as the specification and the fallback (D101 §7.4.4).

## 2. Behaviour

none: this task adds no behaviour; the view is the script's (T008), and its check is the `Get-Content` and `git status` commands in §3.

## 3. Done-when

1. `pwsh -NoProfile -Command 'Get-Content -TotalCount 3 plugins/asimov-plugin/skills/artifact-risk-log-view/SKILL.md'` prints `---`, `name: artifact-risk-log-view` and a `description:` line.
2. `git status --short -- plugins/asimov-plugin/skills/artifact-risk-log-view/SKILL.md` prints the file as new.

## 4. Constraints and stops

- **Must:** frontmatter `name` and `description` only; the script is called as `${CLAUDE_PLUGIN_ROOT}/skills/artifact-risk-log-authoring/scripts/risk-log.ps1`, with the Codex derived-root step.
- **Must not:** write anything, the review date included, or add a line of judgement to the view.

## 5. Out of scope

- The closing review question — T014
