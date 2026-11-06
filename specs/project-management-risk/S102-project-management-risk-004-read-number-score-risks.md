---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T004"
title: "Read, number and score risks"
role: human
tier: high
after: [T003]
traces: [R7, R8, AC8, AC9, AC10, AC25]
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

# S102 T004 — Read, number and score risks

## 1. Intent

`-Read` turns an existing register page back into its data, and `-Apply` writes to a page that already exists. Identifiers continue one series that is never reused, duplicates from a merge are renumbered before anything new is added, and the score is always recomputed, never read (D101 RL2, RL3, RL4, RL13, P3).

## 2. Behaviour

```gherkin
Scenario: An intact register reads back in full with no problem
  Given a register page holding three risks with their fields and history, written by -Apply
  When -Read runs on it
  Then the script exits 0 and returns every risk with its identifier, state, fields and dates, the areas in use, and an empty list of problems
  And the page is unchanged

Scenario: A new risk continues the series past resolved risks
  Given a register holding RISK-001 to RISK-007, with RISK-004 and RISK-007 resolved
  When -Apply runs with a change file with verb add and the four required fields
  Then the new risk is RISK-008 and every risk and history line the register held is still there

Scenario Outline: A duplicate identifier is renumbered before the write's own change
  Given a register holding two RISK-007, created <created>, and one RISK-008
  When -Apply runs with a change file with verb add
  Then the <which> RISK-007 becomes RISK-009, keeps its history, and its last history line is of kind renumber and reads "Renumbered from RISK-007"
  And the other RISK-007 and RISK-008 keep their identifiers
  And the new risk is RISK-010

  Examples:
    | created                   | which                       |
    | on two different days     | later-created               |
    | on the same day           | lower one on the page       |

Scenario: The score shown is recomputed and never given
  Given a register page whose shown score for RISK-002, impact 4 and probability 3, was edited by hand to 15
  When -Apply runs with any accepted change
  Then the page shows 12 for RISK-002
  And a change file that carries a score is refused with exit 1 and the page is unchanged

Scenario Outline: Areas nearly the same are found
  Given a register whose risks use the area "<in use>"
  When -Read runs with -Area "<given>"
  Then "<in use>" <is or is not> among the areas returned as nearly the same

  Examples:
    | in use             | given               | is or is not |
    | Schedule           | schedule            | is           |
    | Schedule           | sched-ule           | is           |
    | Schedule           | Schedul             | is           |
    | Cost               | Costs               | is           |
    | Customer schedule  | Customer schedules  | is           |
    | QA                 | QC                  | is not       |
    | Supplier schedule  | Customer schedule   | is not       |

@review-focus
Scenario: A register with CRLF line endings reads and writes as normal
  Given a register page whose line endings were turned into CRLF by a checkout
  When -Read runs and then -Apply runs with a change file with verb add
  Then -Read reports no problem and the write passes its check
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 added still green and one test per scenario of §2 (one per example row of an outline): *An intact register reads back in full with no problem*, *A new risk continues the series past resolved risks*, *A duplicate identifier is renumbered before the write's own change*, *The score shown is recomputed and never given*, *Areas nearly the same are found*, *A register with CRLF line endings reads and writes as normal*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** `-Read` returns JSON and writes nothing; it reads only the attributes and lists D101 §6.4 names, never the rendered score, summary table or counts.
- **Must:** the write's check refuses, with exit 1, a new page that drops a risk or a history line the current page held, or that holds a duplicate identifier.
- **Must not:** close a gap in the series, or reuse the identifier of a resolved risk.
- **Stops:** a fixture register that the template from T001 cannot express (a duplicate identifier is the only allowed defect) means the template needs a change; report it rather than change the template.

## 5. Out of scope

- A register `-Read` finds unreadable, and the repair it turns into — T010
- Asking "Did you mean Schedule?" in the conversation — T014
- Changing a risk's fields — T005
