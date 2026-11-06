---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T014"
title: "Risk log path in asimov-project"
role: human
tier: high
after: [T012, T013]
traces: [R3, R15, NF5, §6.1, §6.7, AC3, AC6, AC17, AC25, AC27, AC37, AC39]
owns:
  create: []
  modify: [plugins/asimov-plugin/skills/asimov-project/SKILL.md, plugins/asimov-plugin/commands/asimov-init.md, plugins/asimov-plugin/skills/codex-asimov-init/SKILL.md]
  test: []
  regenerates: []
consumes: [artifact-risk-log-authoring, artifact-risk-log-view, risk-log.ps1, risk-log-definition.md, "pm-advisor (plugins/asimov-plugin/skills/pm-advisor/SKILL.md)"]
produces: []
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T014 — Risk log path in asimov-project

## 1. Intent

The conversation of the risk log: its row in the Project frame's entry point and its section, with the verbs, the questions, the confirmation of the stored text and where the run waits, so a person keeps the register by naming it in Claude Code and Codex alike. Both init entry points keep its leftover writes out of git (D101 §6.2, §7.4.2, R3, NF5).

## 2. Behaviour

```gherkin
Scenario Outline: The risk log is kept by naming it in either tool
  Given a repo with no register
  When a person writes <invocation> "risk log, add" with a risk's four fields and confirms
  Then the register holds the risk, and no entry point named asimov-risk exists

  Examples:
    | invocation                          |
    | /asimov-project in Claude Code      |
    | $asimov-plugin:asimov-project in Codex |

Scenario Outline: The conversation asks before it writes
  Given an English register whose areas include "Schedule"
  When a person <says>
  Then the entry point <asks> and writes only on the answer

  Examples:
    | says                                                 | asks                                                         |
    | registers a risk with "the project lead" as owner    | asks for a person's name                                      |
    | registers a risk with area "schedule"                | asks once "Did you mean Schedule?" and keeps the answer       |
    | registers a risk in Danish                           | shows the English text as stored, to confirm or correct       |
    | asks to delete RISK-003                              | offers resolving it with a reason instead                     |

Scenario: The review is the default and waits for confirmation
  Given a repo with neither a register nor an opt-out, and another with a register
  When a person names the risk log with no verb in each
  Then in the first nothing is written and registering a risk or recording an opt-out is offered
  And in the second the view is shown, "Mark the register as reviewed today?" is asked, then "Who took part?", which may be skipped

Scenario: The first risk-log run keeps leftovers out of git
  Given a repo whose .gitignore lacks the Asimov patterns
  When the risk log is run twice
  Then .gitignore holds the four cache patterns and project/*.new once each

@review-focus
Scenario: No git user name means one question for the run
  Given a repo where git user.name is unset
  When the script exits 3 on the first write
  Then the person is asked for a name once and it is passed as -By for the rest of the run

@review-focus
Scenario: A leftover write is finished before any verb
  Given a risk-log.html.new left beside the register by an earlier run
  When the risk log is named with any verb
  Then -Finish runs first and its outcome is shown before the verb's questions
```

## 3. Done-when

1. `git diff --stat -- plugins/asimov-plugin/skills/asimov-project/SKILL.md plugins/asimov-plugin/commands/asimov-init.md plugins/asimov-plugin/skills/codex-asimov-init/SKILL.md` prints the three files as changed.
2. `pwsh -NoProfile -Command 'Get-Content -TotalCount 8 plugins/asimov-plugin/skills/asimov-project/SKILL.md'` prints the frontmatter with `model: claude-sonnet-5-5` unchanged.

## 4. Constraints and stops

- **Must:** the Step 01 table gains the risk log's row as the skeleton's comment gives it, the comment and the *none yet* row and line are replaced, and the risk log's section follows Step 02's rules: the questions, one summary of what will be stored, the go, then the write through `artifact-risk-log-authoring` and the view through `artifact-risk-log-view`.
- **Must:** `pm-advisor` is offered in one line when a person scores a risk against the anchors and when a person opts out, and its advice is never written into the page unasked.
- **Must:** in both init entry points the `.gitignore` block grows from four patterns to five with `project/*.new`, and every sentence that counts the patterns says five.
- **Must not:** restate the authoring or view skill's method, change the frontmatter of `asimov-project`, or touch another artifact's row.

## 5. Out of scope

- The website and D100, `CLAUDE.md` — T015, T016
- Noticing an owner who has left — Q3
