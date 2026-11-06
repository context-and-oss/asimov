---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T003"
title: "Register a risk on a new page"
role: human
tier: high
after: [T001, T002]
traces: [R1, R5, R6, R8, R9, R14, R16, R18, NF1, NF2, NF3, NF4, NF6, §6.4, AC1, AC5, AC7, AC11, AC28, AC29]
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

# S102 T003 — Register a risk on a new page

## 1. Intent

The first write of the register: `-Apply` with an `add` change on a repo that has no register writes the page, with the risk Active as RISK-001, its score shown and never entered, and a signed, dated history line. Every later action then has a page to read (D101 F1, R1, AC1).

## 2. Behaviour

```gherkin
Scenario: The first risk creates the register as RISK-001
  Given a repo with no register page
  And a change file with verb add, name "Sponsor changes mid-engagement", owner "Allan Borup", impact 4, probability 3 and language "en"
  When -Apply runs with that change file and -By "Maja Holm"
  Then the script exits 0 and the register page exists with lang "en"
  And it holds one risk RISK-001 in state Active with the score 12 shown beside its name
  And the risk's created and changed dates and the register's last-updated date are today
  And the risk's history and the register's history each hold one line of kind created, dated today, by "Maja Holm"

Scenario Outline: A first risk that cannot be written leaves no page behind
  Given a repo with no register page
  And a change file with verb add and <what is missing>
  When -Apply runs with that change file and <the person>
  Then the script exits <code> and names the reason
  And no register page and no leftover new file exist

  Examples:
    | what is missing                      | the person                                  | code |
    | no owner                             | -By "Maja Holm"                             | 1    |
    | every required field present         | no -By and no git user name configured      | 3    |

Scenario: Optional fields left out are not shown
  Given a repo with no register page
  And a change file with verb add and the four required fields, and no description, area or mitigation
  When -Apply runs with that change file
  Then the script exits 0
  And the risk on the page carries no description and no mitigation element and an empty area

Scenario: The page states its scoring and carries no script
  Given the register page written by a first risk
  When the page is opened as text
  Then it contains no script element
  And it links the site's shared chrome stylesheet
  And it states what 1 and 5 mean on the impact axis and on the probability axis
  And it states that the score ranks risks and does not decide what to do

@review-focus
Scenario: Names outside ASCII are written intact on both shell editions
  Given a change file whose name and owner hold "æ", "ø" and "å"
  When -Apply runs with it under PowerShell 7 and, in a fresh repo, under Windows PowerShell 5.1
  Then each page is UTF-8 and holds the name and the owner unchanged
```

## 3. Done-when

1. `risk-log.Tests.ps1` is green under `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`, with one test per scenario of §2: *The first risk creates the register as RISK-001*, *A first risk that cannot be written leaves no page behind* (one per example row), *Optional fields left out are not shown*, *The page states its scoring and carries no script*, *Names outside ASCII are written intact on both shell editions*.
2. `risk-log.Tests.ps1` is green under `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'`.

## 4. Constraints and stops

- **Must:** render the page from `risk-log-template.html` read at run time under `-PluginRoot`, never from a copy held in the script.
- **Must:** write through `risk-log.html.new` beside the page, check it, then rename it into place; a failed check deletes the `.new` and exits 1. The page's folder is created when absent.
- **Must:** the score is rendered from impact and probability; it is in no `data-*` attribute and nothing reads it back.
- **Must:** the tests build every repo and page in Pester's `TestDrive:` and never depend on the developer's own git identity.
- **Must not:** read back an existing register page; this task writes a page only where none exists, and an `add` on an existing page is T004's.

## 5. Out of scope

- Reading an existing register, numbering past RISK-001, renumbering and areas — T004
- Replacing an opt-out with a register — T009
- Asking for a person's name when the owner is a role, and the translation step — T012, T014
- Listing the page on the product's documentation site — OOS3
