---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T008"
title: "Review view and confirmed review"
role: human
tier: high
after: [T007]
traces: [R18, R19, R20, R24, R30, R31, AC19, AC20, AC30, AC35, AC39]
owns:
  create: []
  modify: [plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1]
  test: [plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1]
  regenerates: []
consumes: [risk-log.ps1, The change file, risk-log-template.html]
produces: []
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T008 — Review view and confirmed review

## 1. Intent

`-View` prints the one fixed view the weekly review reads top-down, every open risk in full. `-Apply` with a `review` verb records a confirmed review, which moves only the register's last-updated date and signs the register's own history. A glance is not a review (D101 F4, P6, RL9, RL12, S2).

## 2. Behaviour

```gherkin
Scenario Outline: A confirmed review moves only the register's date
  Given a register written on an earlier day by a registration by "Jonas Berg", holding risks with changed dates on earlier days
  When -Apply runs with a change file with verb review and with <participants>, and -By "Maja Holm"
  Then the register's last-updated date is today and no risk's changed date or history moved
  And the register's history holds two lines, the created line by "Jonas Berg" and a line of kind review dated today by "Maja Holm" <naming>

  Examples:
    | participants             | naming                                             |
    | "Erik Lund, Jonas Berg"  | that names "Erik Lund" and "Jonas Berg" as taking part |
    | no participants          | that names no one else                              |

Scenario: Page and view list risks in the fixed order
  Given a register holding risks in every state, two Active risks at score 12 as RISK-009 and RISK-003, and an Active risk at score 20 changed longest ago
  When -Apply writes any accepted change and -View runs
  Then on the page and in the view the groups run Active, Mitigated, Accepted, Occurred, Resolved
  And within a group risks run by score, highest first, then by identifier, so RISK-003 comes before RISK-009 and the risk at 20 comes first
  And on the page the Resolved group is last and folded

Scenario: The view shows every open risk in full and writes nothing
  Given a register holding an open risk with area, description and mitigation, an open risk with neither description nor mitigation, and two Resolved risks
  When -View runs
  Then each open risk shows its identifier, score, name, owner, area, impact, probability, changed date, description and mitigation
  And the risk with no description or mitigation shows "none written" in their place
  And the Resolved risks appear only as a count of 2, no line is wider than 80 columns, and the page is byte-identical to before

Scenario: The view never prints a verdict
  Given a register holding an Active risk at score 25 with no mitigation
  When -View runs
  Then the output holds the risks and their fields and no line of advice, warning or judgement about them

Scenario: A repo with neither a register nor an opt-out
  Given a repo with no register page
  When -Read runs, then -View runs, then -Apply runs with a change file with verb review
  Then -Read exits 0 and reports the register as none
  And -View exits 0 and prints that there is no register and no opt-out
  And the review is refused with exit 1, and no page and no leftover new file exist
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 to T007 added still green and one test per scenario of §2 (one per example row of the outline): *A confirmed review moves only the register's date*, *Page and view list risks in the fixed order*, *The view shows every open risk in full and writes nothing*, *The view never prints a verdict*, *A repo with neither a register nor an opt-out*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** the view's layout is the one D101 §5 S2 describes: a header line with the page and its last-updated date, the count per state, then each state group with every open risk in full, each risk closed by a horizontal rule, and the Resolved group as a count only. It ends after the risks: the closing question is the entry point's.
- **Must:** the view's labels are in the conversation's fixed English; a risk's content is printed as it is kept.
- **Must:** `-View` and `-Read` never write, the review date included.
- **Prefer:** the line layout of `documentation/features/mockups/d101-project-management-risk/risk-run.html` (its `view` function: the identifier, score and name line, the indented owner, area, impact, probability and changed line, the wrapped description and mitigation).

## 5. Out of scope

- Asking "Mark the register as reviewed today?" and "Who took part?" — T014
- Offering to register a risk or record an opt-out when there is neither — T014
- The view skill that prints this output — T013
- An opt-out page in the view — T009
