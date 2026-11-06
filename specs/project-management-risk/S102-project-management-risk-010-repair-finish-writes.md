---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T010"
title: "Repair and finish interrupted writes"
role: human
tier: high
after: [T009]
traces: [NF4, §6.7, AC24, AC36]
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

# S102 T010 — Repair and finish interrupted writes

## 1. Intent

A register the script cannot read in full is never written to: `-Repair` proposes each change as before and after, and a confirmed repair loses nothing. A write interrupted before its rename is finished or discarded by `-Finish`, so an interrupted write leaves the register as it was (D101 F6, RL11, NF4, §6.7).

## 2. Behaviour

```gherkin
Scenario: An unreadable register is not written to and gets a repair proposal
  Given a register whose RISK-005 lost its impact in a hand edit
  When -Read runs, then -Apply runs with a change file with verb add, then -Repair runs
  Then -Read reports a problem naming RISK-005 and its impact
  And -Apply exits 1 and the page is byte-identical to before
  And -Repair returns a proposal that lists each change as before and after, with RISK-005 impact going from missing to a value to be asked

Scenario: A confirmed repair loses nothing
  Given that register and the proposal -Repair returned, with 4 given for RISK-005's impact
  When -Apply runs with a change file with verb repair carrying that proposal, and -By "Maja Holm"
  Then -Read reports no problem and RISK-005 has impact 4
  And every risk and every history line the register held is still there
  And the register's history ends with a line of kind repair, by "Maja Holm", reading "Repaired"

Scenario Outline: A leftover new file is finished or discarded
  Given an unchanged register with a risk-log.html.new beside it that <passes or fails> the write's check
  When -Read runs, and then -Finish runs
  Then after -Read the register is byte-identical and the new file is still there
  And -Finish prints what the new file changes and <outcome>

  Examples:
    | passes or fails                      | outcome                                                                                   |
    | passes                               | renames it into place, exits 0, and the register's history ends with a line of kind finish |
    | fails, having dropped a history line | deletes it, exits 1 and says so, and the register is byte-identical to before              |

@review-focus
Scenario: A risk with no impact shows no score
  Given a register whose RISK-005 lost its impact in a hand edit
  When -View runs
  Then RISK-005 is shown with no score, not with 0
  And -Read reports the problem that turns the run into a repair

@review-focus
Scenario: Conflict markers after a merge become a repair
  Given a register in a git merge where both sides added RISK-007 and both changed RISK-002's probability to different values
  When -Read runs and then -Repair runs
  Then -Read reports the conflict as a problem
  And the proposal merges both sides by identifier, renumbers the later-created RISK-007 as the next free identifier, and asks for RISK-002's probability with both values shown
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 to T009 added still green and one test per scenario of §2 (one per example row of the outline): *An unreadable register is not written to and gets a repair proposal*, *A confirmed repair loses nothing*, *A leftover new file is finished or discarded*, *A risk with no impact shows no score*, *Conflict markers after a merge become a repair*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** `-Repair` returns its proposal as JSON and writes nothing. The change file of a confirmed repair carries that proposal with every asked value given, and is applied through the same `.new`, check and rename as any write.
- **Must:** a repair after a merge reads the two sides with `git show :2:` and `:3:` only, and the tests build their merge in a git repo inside `TestDrive:`.
- **Must not:** remove or rewrite a history line in a repair: a line a hand edit broke is restored from the page's own content or listed in the proposal as a question.
- **Stops:** a problem whose repair would lose a field or a history line the register held, with no question that could keep it.

## 5. Out of scope

- Running `-Finish` before any verb, and asking the person to confirm a repair — T014
- A git merge driver — rejected in D101 §6.1
