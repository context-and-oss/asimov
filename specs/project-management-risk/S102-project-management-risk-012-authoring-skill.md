---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T012"
title: "Risk log authoring skill"
role: human
tier: high
after: [T011]
traces: [R15, AC6, AC27, AC40]
owns:
  create: [plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md]
  modify: []
  test: []
  regenerates: []
consumes: [risk-log.ps1, The change file, risk-log-template.html, risk-log-definition.md, "artifact-s101-ledger (plugins/asimov-plugin/skills/artifact-s101-ledger/SKILL.md)"]
produces: [artifact-risk-log-authoring]
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T012 — Risk log authoring skill

## 1. Intent

The method behind every register write: turn what the person said into one change file, in the project's language, with the decider and reason the target state needs, and hand it to the script. The skill also holds the rules the script implements, as their specification and as the fallback where no PowerShell runs (D101 §6.1, §7.4.3).

## 2. Behaviour

```gherkin
Scenario: An owner given as a role is never written
  Given a person registers a risk with "the project lead" as its owner, or hands risks over to "the project lead"
  When the skill builds the change file
  Then no change file is produced and the skill returns that a person's name is needed

Scenario: Text in another language is returned for confirmation in the project's language
  Given an English register and a risk told in Danish, owner "Jonas Berg"
  When the skill builds the change file
  Then its name and other free text are in English, the owner is "Jonas Berg" as given
  And the skill returns the text as it will be stored, to be confirmed or corrected before any write

Scenario: A request to delete a risk becomes an offer to resolve it
  Given a person asks to delete RISK-003
  When the skill reads the request
  Then no change file deletes or removes a risk, and the skill returns resolving with a reason as the way a risk leaves the open view

@review-focus
Scenario: With no PowerShell the skill applies the rules itself and says so
  Given a machine where neither pwsh nor powershell runs
  When a risk is registered through the skill
  Then the skill applies the read, the write and the check by its own rules and states plainly that no script ran the check
```

## 3. Done-when

1. `pwsh -NoProfile -Command 'Get-Content -TotalCount 3 plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md'` prints `---`, `name: artifact-risk-log-authoring` and a `description:` line.
2. `git status --short -- plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md` prints the file as new.

## 4. Constraints and stops

- **Must:** frontmatter carries `name` and `description` only, the description trigger-shaped and narrow; the body reads `risk-log-definition.md` and `risk-log-template.html` by path and calls the script by its full path under `${CLAUDE_PLUGIN_ROOT}`, with the Codex derived-root step of `D101-codex-support.html` §6.2.
- **Must:** the body holds the rules the script implements (read, apply, check, areas nearly the same) as the script's specification and the fallback; the view's layout stays in the view skill.
- **Must not:** call another skill, ask the person a question itself (it returns what is missing to its caller), write a file other than the change file it hands to the script, or edit the page by hand.
- **Prefer:** the frame of `artifact-s101-ledger`: read first, the only writer, never another file.

## 5. Out of scope

- The questions, the confirmation and the go — T014
- Printing the view — T013
- A risk detector — OOS4
