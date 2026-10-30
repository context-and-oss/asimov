---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T009"
title: "Opt out and replace it"
role: human
tier: mid
after: [T008]
traces: [R21, R22, R23, AC21, AC22, AC23]
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

# S102 T009 — Opt out and replace it

## 1. Intent

`-Apply` with an `optout` verb records, in the register's place, that no register is kept here, why, and who decided, because an absent register cannot tell "decided not to" from "never thought about it". The first risk registered afterwards replaces the opt-out with a register that remembers what it replaced (D101 F5, RL15, R21–R23).

## 2. Behaviour

```gherkin
Scenario Outline: An opt-out with its reason and decider is written
  Given a repo with no register page
  When -Apply runs with a change file with verb optout, reason <reason>, where <where>, decider "Erik Lund" and language "en", and -By "Maja Holm"
  Then the script exits 0 and the page is an opt-out page titled "No risk register kept here"
  And its first paragraph states the reason <and place>, and it shows the decider "Erik Lund" and today's date
  And the register's history holds one line of kind opt-out, dated today, by "Maja Holm"

  Examples:
    | reason      | where                            | and place                                        |
    | elsewhere   | "the customer's project tool"     | and names "the customer's project tool"          |
    | not-worked  | none                             | that risks are not worked with on this engagement |

Scenario Outline: An opt-out missing what it needs is not written
  Given a repo with no register page
  When -Apply runs with a change file with verb optout, reason <reason>, <missing>
  Then the script exits 1 and names what is missing
  And no page and no leftover new file exist

  Examples:
    | reason      | missing                                        |
    | elsewhere   | no place and decider "Erik Lund"               |
    | elsewhere   | where "the customer's project tool" and no decider |
    | not-worked  | no decider                                     |

Scenario: Registering a risk replaces the opt-out
  Given an opt-out page with reason elsewhere, decided by "Erik Lund" on an earlier day
  When -Apply runs with a change file with verb add and the four required fields
  Then the page is a kept register holding RISK-001
  And the register's history starts with a line of kind replaced-opt-out that names the opt-out's reason, its decider and its date

Scenario: An opt-out cannot replace a register that holds risks
  Given a register holding RISK-001
  When -Apply runs with a change file with verb optout, reason not-worked and decider "Erik Lund"
  Then the script exits 1 and says a risk is never deleted
  And the page is byte-identical to before

Scenario: The view of an opt-out page states the opt-out
  Given an opt-out page with reason elsewhere, where "the customer's project tool", decided by "Erik Lund"
  When -View runs
  Then it prints that no register is kept here, the reason with its place, and the decider with the date
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 to T008 added still green and one test per scenario of §2 (one per example row of an outline): *An opt-out with its reason and decider is written*, *An opt-out missing what it needs is not written*, *Registering a risk replaces the opt-out*, *An opt-out cannot replace a register that holds risks*, *The view of an opt-out page states the opt-out*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** the opt-out page is the template's opt-out form, with `data-register` `opt-out` on `body` and the attributes of `section.opt-out` as D101 §6.4 names them; it keeps the project language and the register's history.
- **Must:** the reason is one of the two values `elsewhere` and `not-worked`; any other value exits 1.

## 5. Out of scope

- Offering `pm-advisor` when a person opts out — T014
- Listing the opt-out on the product's documentation site — OOS3
