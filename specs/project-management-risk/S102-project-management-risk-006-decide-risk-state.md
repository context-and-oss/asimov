---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T006"
title: "Decide a risk's state"
role: human
tier: high
after: [T005]
traces: [R10, R11, R12, R13, R14, R26, R27, AC12, AC13, AC14, AC15, AC16, AC32]
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

# S102 T006 — Decide a risk's state

## 1. Intent

`-Apply` with a `state` verb: every state beyond Active is a person's decision with a reason, Mitigated needs a written mitigation, Accepted needs a named decider, and any state can be set back to Active under the same identifier. The register never shows a risk as dealt with that nobody decided (D101 F3, P4, RL5, RL6, RL7, RL17).

## 2. Behaviour

```gherkin
Scenario Outline: A state is set when what it needs is given
  Given a register holding RISK-002 in state <from>, with a mitigation written
  When -Apply runs with a change file with verb state, target RISK-002, to <to>, reason "<reason>" and decider "<decider>", and -By "Maja Holm"
  Then RISK-002 is in state <to> under the same identifier, its changed date is today, and it sits in the <to> group on the page
  And its history ends with one line of kind state, by "Maja Holm", holding the reason and, when given, the decider

  Examples:
    | from      | to        | reason                                          | decider      |
    | Active    | Mitigated | pairing in place on all modules                 |              |
    | Active    | Accepted  | the customer carries the cost                   | Allan Borup  |
    | Active    | Occurred  | arrived three weeks late; re-planned            |              |
    | Active    | Resolved  | rehearsal finished inside the window            |              |
    | Mitigated | Active    | the mitigation no longer holds                  |              |
    | Accepted  | Active    | the contract changed                            |              |
    | Occurred  | Active    | the problem is handled; the risk remains        |              |
    | Resolved  | Active    | the sponsor change is back on the table         |              |

Scenario Outline: A state whose requirement is missing is not set
  Given a register holding RISK-002 in state <from>, <mitigation>
  When -Apply runs with a change file with verb state, target RISK-002, to <to>, <given>
  Then the script exits 1 and names what is missing
  And the page is byte-identical to before

  Examples:
    | from      | mitigation            | to        | given                          |
    | Active    | with no mitigation    | Mitigated | a reason                       |
    | Active    | with a mitigation     | Accepted  | a reason and no decider        |
    | Active    | with a mitigation     | Resolved  | no reason                      |
    | Active    | with a mitigation     | Occurred  | no reason                      |
    | Resolved  | with a mitigation     | Active    | no reason                      |
    | Active    | with a mitigation     | Active    | a reason                       |

Scenario: The mitigation of a Mitigated risk cannot be emptied
  Given a register holding RISK-003 in state Mitigated with a mitigation written
  When -Apply runs with a change file with verb change, target RISK-003 and an empty mitigation
  Then the script exits 1 and says the risk must first be set back to Active
  And the page is byte-identical to before

Scenario: A risk's history only grows
  Given a repo with no register page
  When a risk is registered, then its impact is changed, then it is set Resolved with a reason, each by -Apply
  Then the risk has three dated history lines, of kinds created, change and state
  And the first line is exactly as it was after the registration
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with the tests T003 to T005 added still green and one test per scenario of §2 (one per example row of an outline): *A state is set when what it needs is given*, *A state whose requirement is missing is not set*, *The mitigation of a Mitigated risk cannot be emptied*, *A risk's history only grows*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** every state can be set from every other (RL5); a state change never alters a field, and a field change never alters the state.
- **Must:** the write's check refuses, with exit 1, a new page that removes or rewrites any history line the current page held.
- **Must not:** derive a state from a field: a written mitigation never makes a risk Mitigated by itself.

## 5. Out of scope

- Asking the person for the missing mitigation, decider or reason — T012, T014
- The Occurred group in the chat view — T008
- Pointing an Occurred risk to an issue log — OOS5
