---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T007"
title: "Hand open risks to an owner"
role: human
tier: mid
after: [T006]
traces: [R25, R28, AC31, AC33, AC40]
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

# S102 T007 — Hand open risks to an owner

## 1. Intent

`-Apply` with a `handover` verb gives every open risk of a leaving owner to a named successor in one step, each risk with its own signed history line, so no risk is left with someone who has gone. Every history line on the page names the person who made the change (D101 F7, R25, R28).

## 2. Behaviour

```gherkin
Scenario: Every open risk of the owner moves to the new owner
  Given a register where "Jonas Berg" owns RISK-002 in state Occurred, RISK-004 in state Accepted and RISK-006 in state Resolved
  When -Apply runs with a change file with verb handover, target "Jonas Berg" and to "Sara Nygaard", and -By "Maja Holm"
  Then RISK-002 and RISK-004 are owned by "Sara Nygaard", keep their states, and have changed dates of today
  And each of them gains its own history line of kind handover, by "Maja Holm", naming "Jonas Berg" and "Sara Nygaard"
  And RISK-006 is still owned by "Jonas Berg" and its history and dates are unchanged

Scenario Outline: A handover with no open risk to move writes nothing
  Given a register where <owner situation>
  When -Apply runs with a change file with verb handover, target "Jonas Berg" and to "Sara Nygaard"
  Then the script exits 1 and says "Jonas Berg" has no open risks
  And the page is byte-identical to before

  Examples:
    | owner situation                                  |
    | "Jonas Berg" owns only RISK-006 in state Resolved |
    | "Jonas Berg" owns no risk                         |

Scenario: Every history line on every risk names a person
  Given a repo with no register page
  When a risk is registered, changed, set Mitigated and handed over, each by -Apply with a different -By
  Then every line of that risk's history names the person given for its write
  And a new page holding a history line with no person is refused by the write's check with exit 1
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 to T006 added still green and one test per scenario of §2 (one per example row of the outline): *Every open risk of the owner moves to the new owner*, *A handover with no open risk to move writes nothing*, *Every history line on every risk names a person*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** an open risk is any risk not in state Resolved; owners are compared as written, after trimming spaces.
- **Must:** the handover is one write: either every open risk of the owner moves, or none does.

## 5. Out of scope

- Refusing a new owner given as a role, such as "the project lead" (AC40, RL1): the authoring skill and the entry point ask for a person's name — T012, T014
- Noticing an owner who has left — Q3
