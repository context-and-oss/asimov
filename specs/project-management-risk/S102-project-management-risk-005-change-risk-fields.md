---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T005"
title: "Change a risk's fields"
role: human
tier: mid
after: [T004]
traces: [R7, R14, R16, R17, R29, AC18, AC34, AC38]
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

# S102 T005 — Change a risk's fields

## 1. Intent

`-Apply` with a `change` verb: any field of a risk can be changed in any state without changing the state, and every change leaves a dated, signed history line. The register stays current without anyone deciding anything new (D101 F2, R29, RL8, RL10).

## 2. Behaviour

```gherkin
Scenario: A changed field moves the changed date and keeps the created date
  Given a register holding RISK-003, Active, impact 3, created on an earlier day
  When -Apply runs with a change file with verb change, target RISK-003 and impact 4, and -By "Maja Holm"
  Then RISK-003 has impact 4, is still Active, keeps its created date, and its changed date is today
  And its history ends with one line of kind change, dated today, by "Maja Holm", naming impact with 3 and 4
  And the register's last-updated date is today and its history ends with a line of kind write by "Maja Holm"

Scenario: Several fields changed at once give one history line
  Given a register holding RISK-003 with owner "Jonas Berg" and area "Schedule"
  When -Apply runs with a change file with verb change, target RISK-003, owner "Sara Nygaard" and area "Resources"
  Then RISK-003's history gains exactly one line, naming owner and area, each with its old and new value

Scenario: A resolved risk can be renamed and stays resolved
  Given a register holding RISK-006 in state Resolved
  When -Apply runs with a change file with verb change, target RISK-006 and a new name
  Then RISK-006 carries the new name, is still Resolved, and its history gains one line of kind change

Scenario: An identifier that does not exist writes nothing
  Given a register that holds no RISK-099
  When -Apply runs with a change file with verb change and target RISK-099
  Then the script exits 1 and names the unknown identifier
  And the page is byte-identical to before and no leftover new file exists
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 and T004 added still green and one test per scenario of §2: *A changed field moves the changed date and keeps the created date*, *Several fields changed at once give one history line*, *A resolved risk can be renamed and stays resolved*, *An identifier that does not exist writes nothing*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** a `change` never sets `data-state`; the earlier history lines of the risk stay exactly as they were.
- **Must:** the fields a `change` may carry are the seven of the change file (name, owner, impact, probability, area, description, mitigation); impact and probability stay whole numbers from 1 to 5, else exit 1.

## 5. Out of scope

- Refusing to empty the mitigation of a Mitigated risk (AC12), and every change of state — T006
- Handing all of an owner's risks over in one step — T007
- Showing the register so the person can find the right identifier — T014
