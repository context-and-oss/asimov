---
spec: S101
slug: "project-management-risk"
title: "Risk log"
design: { ref: documentation/features/D101-project-management-risk.html, version: "0.9" }
status: done
approved: { by: "SimonVilandt", date: "2026-10-29", fingerprint: "1bb81caedb63" }
version: 0.1
author: "Simon Vilandt"
date: "2026-10-29"
phases:
  - id: P0
    name: Foundation
    delivers: "Lays down the register page's shape and the script's interface, so every slice below renders the same page and answers through the same five actions."
    checkpoint: "The page template and the script's interface are in place with no behaviour yet, and the empty test file runs under Pester 5 on both shell editions."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T001, title: "Risk log page template", role: human, tier: mid, after: [], traces: [§6.4, NF1, NF2, NF3, NF6] }
      - { id: T002, title: "Script interface and test scaffold", role: human, tier: low, after: [], traces: [§6.1, §6.4, §6.5] }
  - id: P1
    name: "Register the first risk"
    traces: [AC1, AC5, AC7, AC11, AC28, AC29]
    delivers: "Lets a person register a risk with its four required fields and writes the register page the first time, so every later action has a page to read."
    checkpoint: "A first risk becomes RISK-001, Active, on a new register page that shows the scoring anchors and carries no script, a risk without an owner is refused, and the script's tests prove it."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T003, title: "Register a risk on a new page", role: human, tier: high, after: [T001, T002], traces: [R1, R5, R6, R8, R9, R14, R16, R18, NF1, NF2, NF3, NF4, NF6, §6.4, AC1, AC5, AC7, AC11, AC28, AC29] }
  - id: P2
    name: "Number and score risks"
    traces: [AC8, AC9, AC10, AC25]
    delivers: "Reads an existing register back and keeps its numbering and its scores honest, so later changes can address a risk by its identifier."
    checkpoint: "A new risk continues the series past resolved ones, a duplicate identifier is renumbered before the write, a hand-edited score is recomputed, nearly-same areas are found, and the script's tests prove each case."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T004, title: "Read, number and score risks", role: human, tier: high, after: [T003], traces: [R7, R8, AC8, AC9, AC10, AC25] }
  - id: P3
    name: "Change a risk"
    traces: [AC18, AC34, AC38]
    delivers: "Lets a person change any field of a risk in any state with a signed history line, so the register stays current without changing a decision."
    checkpoint: "A changed field moves the risk's changed date and keeps its created date and its state, an unknown identifier writes nothing, and the script's tests prove it."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T005, title: "Change a risk's fields", role: human, tier: mid, after: [T004], traces: [R7, R14, R16, R17, R29, AC18, AC34, AC38] }
  - id: P4
    name: "Decide a risk's state"
    traces: [AC12, AC13, AC14, AC15, AC16, AC32]
    delivers: "Lets a person set Mitigated, Accepted, Occurred, Resolved or Active with what each state requires, so every decision on the register carries a reason and a name."
    checkpoint: "Each state is set only with its reason, decider or mitigation, a refused state leaves the page as it was, a risk's history only grows, and the script's tests prove every case."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T006, title: "Decide a risk's state", role: human, tier: high, after: [T005], traces: [R10, R11, R12, R13, R14, R26, R27, AC12, AC13, AC14, AC15, AC16, AC32] }
  - id: P5
    name: "Hand risks to an owner"
    traces: [AC31, AC33, AC40]
    delivers: "Lets a person hand every open risk of a leaving owner to a named successor in one step, so no risk sits with someone who has gone."
    checkpoint: "Every open risk of the owner moves to the new owner with its own signed history line, resolved risks keep their owner, an owner with no open risks writes nothing, and the script's tests prove it."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T007, title: "Hand open risks to an owner", role: human, tier: mid, after: [T006], traces: [R25, R28, AC31, AC33, AC40] }
  - id: P6
    name: "Review the register"
    traces: [AC19, AC20, AC30, AC35, AC39]
    delivers: "Gives the weekly review its fixed view and lets a person confirm a review, so the register's date says when it was last read with care."
    checkpoint: "The view lists every open risk in full in the fixed order with resolved ones as a count, a confirmed review moves only the register's date and signs its history, a missing register writes nothing, and the script's tests prove it."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T008, title: "Review view and confirmed review", role: human, tier: high, after: [T007], traces: [R18, R19, R20, R24, R30, R31, AC19, AC20, AC30, AC35, AC39] }
  - id: P7
    name: "Record an opt-out"
    traces: [AC21, AC22, AC23]
    delivers: "Lets a team record that it keeps no register here and why, and replaces that record with a register once a risk is raised."
    checkpoint: "An opt-out is written only with its reason, its place and its decider, a first risk replaces it and names it in the history, and the script's tests prove it."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T009, title: "Opt out and replace it", role: human, tier: mid, after: [T008], traces: [R21, R22, R23, AC21, AC22, AC23] }
  - id: P8
    name: "Repair and finish writes"
    traces: [AC24, AC36]
    delivers: "Brings a hand-edited, merged or half-written register back into working order without losing a line, so a broken page never blocks the engagement."
    checkpoint: "An unreadable register gets a repair shown as before and after and loses nothing once confirmed, a leftover write is finished or discarded, and the script's tests prove it."
    check: "pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })' && powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'"
    tasks:
      - { id: T010, title: "Repair and finish interrupted writes", role: human, tier: high, after: [T009], traces: [NF4, §6.7, AC24, AC36] }
  - id: P9
    name: "Risk log conversation"
    delivers: "Gives the risk log its words: the definition, the two skills and its path in the Project frame's entry point, so a person keeps the register by asking in either tool."
    checkpoint: "A person registers, changes, decides, reviews and hands over risks through the frame's entry point in Claude Code and in Codex, and the hand run of the conversation's criteria proves it."
    check: "git status --short -- plugins/asimov-plugin/artifacts/project/risk-log/risk-log-definition.md plugins/asimov-plugin/skills/artifact-risk-log-authoring/SKILL.md plugins/asimov-plugin/skills/artifact-risk-log-view/SKILL.md plugins/asimov-plugin/skills/asimov-project/SKILL.md plugins/asimov-plugin/commands/asimov-init.md plugins/asimov-plugin/skills/codex-asimov-init/SKILL.md documentation/D100-Asimov-architecture.md"
    tasks:
      - { id: T011, title: "Risk log definition and maturity", role: human, tier: mid, after: [T010], traces: [R1, §6.1, AC26] }
      - { id: T012, title: "Risk log authoring skill", role: human, tier: high, after: [T011], traces: [R15, AC6, AC27, AC40] }
      - { id: T013, title: "Risk log view skill", role: human, tier: low, after: [T010], traces: [R30, R31, AC35] }
      - { id: T014, title: "Risk log path in asimov-project", role: human, tier: high, after: [T012, T013], traces: [R3, R15, NF5, §6.1, §6.7, AC3, AC6, AC17, AC25, AC27, AC37, AC39] }
  - id: P10
    name: "Website and records"
    delivers: "Tells the public website and the repo's own records that the risk log exists, so no page contradicts the plugin on the day it ships."
    checkpoint: "The website's two Project frame pages name the risk log as available, and the architecture, the repo guide and the website's design agree with what shipped."
    check: "git status --short -- site/inside/project-management.html site/artifacts/project-management/index.html documentation/features/D101-website.html documentation/D100-Asimov-architecture.md CLAUDE.md"
    tasks:
      - { id: T015, title: "Website pages name the risk log", role: human, tier: mid, after: [T014], traces: [R4, AC4] }
      - { id: T016, title: "Architecture and repo guide records", role: human, tier: mid, after: [T011, T014], traces: [R3, §6.1] }
---

# S101 — Risk log

The first artifact of the Project frame: one register page per product repo, kept by a script the risk log's skills drive through `asimov-project`. Plans `documentation/features/D101-project-management-risk.html` v0.9 (Full design, status Draft: not yet approved by its business approver, Allan Borup).

## 1. Contracts

| Name | Shape | Produced by |
|---|---|---|
| `risk-log.ps1` | D101 §6.5: `-Path <page>` plus one action, `-Read` (with `-Area <text>`), `-View`, `-Apply -Change <file>`, `-Repair`, `-Finish`; `-By <name>`, `-PluginRoot <path>`; exit `0` done, `1` refused by a rule (the rule on stdout), `2` an input could not be read, `3` no person | T002 |
| The change file | D101 §6.4 *The change file -Apply takes*: `verb`, `target`, `fields`, `state`, `with`, `to`, `opt-out`, `language` | T002 |
| `risk-log-template.html` | D101 §6.4 *The page* and *One risk*: the elements and `data-*` attributes the script renders and reads back | T001 |
| `risk-log-definition.md` | D101 §6.3: fields, states, rules, the bar, the divergence from the discipline; opens with the maturity block | T011 |
| `artifact-risk-log-authoring` | D101 §6.3: the skill that turns what was said into one change file | T012 |
| `artifact-risk-log-view` | D101 §6.3: the skill that prints the fixed view and writes nothing | T013 |

## 2. Constraints

- The script runs on Windows PowerShell 5.1 and PowerShell 7 — D101 §6.1
- The script file is pure ASCII; it writes the page as UTF-8 explicitly — D101 §6.8
- A write goes to `risk-log.html.new` beside the page, is checked, then replaces the page by one rename; a failed check deletes the `.new` — D101 §6.1, §6.2
- The person is `git config user.name`, or `-By`; never guessed — D101 §6.6
- The script runs only `git config user.name` and, in a repair after a merge, `git show :2:` and `:3:` — D101 §7.4.1
- The score, the summary table and the counts are rendered and never read back — D101 §6.4
- The check compares parsed data, never bytes — D101 §6.8
- The view is 80 columns, fixed — D101 §6.6
- Two areas are nearly the same when equal after ignoring case, spaces, hyphens and punctuation, or one letter apart at four letters or more — D101 §6.4
- The register page carries no `<script>` and links the site's shared chrome stylesheet — D101 AC28
- Tests are Pester 5, in `risk-log.Tests.ps1` beside the script — the author's answer at planning
- `project/*.new` joins the `.gitignore` block both init entry points write and `asimov-project` appends — D101 §6.1
- The definition's maturity is `assess`, mirrored in D100 §4.5 in the same commit — D101 §6.1
- No plugin manifest changes and no `asimov-risk` entry point — D101 §7.5, AC3
- Nothing under `plugins/asimov-plugin/processes/` is edited — D101 OOS11

## 3. Coverage

| Id | Says | Delivered by |
|---|---|---|
| R1 | — | T003, T011 |
| R3 | — | T014, T016 |
| R4 | — | T015 |
| R5 | — | T003 |
| R6 | — | T003 |
| R7 | — | T004, T005 |
| R8 | — | T003, T004 |
| R9 | — | T003 |
| R10 | — | T006 |
| R11 | — | T006 |
| R12 | — | T006 |
| R13 | — | T006 |
| R14 | — | T003, T005, T006 |
| R15 | — | T012, T014 |
| R16 | — | T003, T005 |
| R17 | — | T005 |
| R18 | — | T003, T008 |
| R19 | — | T008 |
| R20 | — | T008 |
| R21 | — | T009 |
| R22 | — | T009 |
| R23 | — | T009 |
| R24 | — | T008 |
| R25 | — | T007 |
| R26 | — | T006 |
| R27 | — | T006 |
| R28 | — | T007 |
| R29 | — | T005 |
| R30 | — | T008, T013 |
| R31 | — | T008, T013 |
| NF1 | — | T001, T003 |
| NF2 | — | T001, T003 |
| NF3 | — | T001, T003 |
| NF4 | — | T003, T010 |
| NF5 | — | T014 |
| NF6 | — | T001, T003 |
| §6.1 | — | T002, T011, T014, T016 |
| §6.4 | — | T001, T002, T003 |
| §6.5 | — | T002 |
| §6.7 | — | T010, T014 |
| AC1 | — | T003 |
| AC3 | — | T014; verified by review: a hand run in Claude Code and in Codex |
| AC4 | — | T015; verified by review |
| AC5 | — | T003 |
| AC6 | — | T012, T014; verified by review: a hand run |
| AC7 | — | T003 |
| AC8 | — | T004 |
| AC9 | — | T004 |
| AC10 | — | T004 |
| AC11 | — | T003 |
| AC12 | — | T006 |
| AC13 | — | T006 |
| AC14 | — | T006 |
| AC15 | — | T006 |
| AC16 | — | T006 |
| AC17 | — | T014; verified by review |
| AC18 | — | T005 |
| AC19 | — | T008 |
| AC20 | — | T008 |
| AC21 | — | T009 |
| AC22 | — | T009 |
| AC23 | — | T009 |
| AC24 | — | T010 |
| AC25 | — | T004, T014; the question verified by review: a hand run |
| AC26 | — | T011; verified by review |
| AC27 | — | T012, T014; verified by review: a hand run |
| AC28 | — | T003 |
| AC29 | — | T003 |
| AC30 | — | T008 |
| AC31 | — | T007 |
| AC32 | — | T006 |
| AC33 | — | T007 |
| AC34 | — | T005 |
| AC35 | — | T008, T013 |
| AC36 | — | T010 |
| AC37 | — | T014; verified by review: a hand run |
| AC38 | — | T005 |
| AC39 | — | T008, T014 |
| AC40 | — | T007, T012 |

## 4. Escalation

- **Routes to:** the person directing the run, the design's owner.
- **Stops specific to this plan:**
  - Pester 5 cannot be imported in PowerShell 7 or in Windows PowerShell 5.1 (only Pester 3.4 is installed today): stop; installing a module is a side effect outside the working tree.
  - A slice needs an element or attribute that `risk-log-template.html` or D101 §6.4 does not carry: stop; the template is the script's schema.
  - The script would have to judge free text (a role given as an owner, a translation, what a person meant): stop; that judgement is the authoring skill's and the entry point's, never the script's.
  - A change would touch a plugin manifest or a file under `plugins/asimov-plugin/processes/`: stop.
- **Reaches a human always:** an irreversible or destructive action, a security-sensitive action, a side effect outside the working tree, a plan so broken that every path forward is a guess.
- **Rulings are recorded in:** the ledger. Never in this plan or an S102.

## 5. Review focus

- A name or content outside ASCII (æ, ø, å) → written as UTF-8 and read back unchanged on both shell editions — T003
- A register checked out with CRLF line endings → read and written as normal, the check comparing parsed data — T004
- A risk whose impact was removed by hand → no score shown, not 0, and the read reports a problem that turns the run into a repair — T010
- Git conflict markers after a merge → a repair that merges both sides by identifier, renumbers true duplicates and asks for each field changed on both sides — T010
- `git config user.name` unset → exit 3, and the entry point asks for the name once and passes it as `-By` for the rest of the run — T014
- A `.new` left by an earlier run → `-Finish` runs before any verb — T014
- No PowerShell on the machine → the skills apply the rules themselves and say plainly that no script ran the check — T012

## 6. Assumptions

| # | Would have asked | Options | Taken | How |
|---|---|---|---|---|
| A1 | Which role builds each task? | dotnet-builder / angular-builder / dotnet-tester / human | `human` for every task: no role skill fits a PowerShell script with Pester tests, Markdown skills and HTML pages | decided by default |
| A2 | Tester then builder, or test-first? | a tester task, then a builder / one test-first task per slice | Test-first: each script slice, T003 to T010, is one task that adds its tests to `plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1` first and then the script code; no tester role exists for this stack | default |
| A3 | One slice per criterion? | one per criterion / grouped by what the script does | Grouped by what the script does (register, number and score, change, state, handover, review, opt-out, repair), since every script criterion passes in the same two files | default |
| A4 | How do the script slices share their files? | in parallel / in sequence | In sequence: T003 to T010 all extend `plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1` and `risk-log.Tests.ps1`, so each comes after the previous one | default |
| A5 | Where do the criteria checked by hand or by review go? | a slice each / the close phases | AC3, AC4, AC6, AC17, AC26, AC27, AC37 and the question of AC25 map to no slice; the work behind them is in P9 and P10, checked by a hand run and by review | default |
| A6 | Where does the definition go? | the Foundation / beside the skills | In P9, with its D100 §4.5 maturity row in the same task (one commit), beside the skills that read it; the Foundation holds only what the slices build against | default |
| A7 | What does `-PluginRoot` default to? | the parent of the script's folder, as D101 §6.5 words it / three folders above the script, as every script beside its skill | Three folders above the script: the parent of `scripts` is the skill folder, not the plugin root | decided by default |
| A8 | What does a slice's check run? | the slice's tests alone / the whole test file | The whole `risk-log.Tests.ps1` on PowerShell 7 and on Windows PowerShell 5.1, so each slice also proves the earlier ones still hold | default |
| A9 | Who installs Pester 5? | the run / the person | The person, before P0's check: installing a module is outside the working tree | default |
| A10 | "Score it 15" (AC10) | the script ignores a score / the script refuses it | The change file has no score field; `-Apply` refuses a change that carries one with exit 1 and writes nothing | default |
| A11 | Who tells a role from a person's name (RL1, AC6, AC40)? | the script / the authoring skill and the entry point | The authoring skill and the entry point ask for a person's name; the script checks only that an owner is present | default |
| A12 | The template's tier | low / mid | mid: the template is a page design that the names alone do not decide | default |
| A13 | What do the close phases' checks run? | a test / the files the phase wrote | `git status --short` over the files the phase owns; the conversation and the pages are proven by a hand run and by review | default |
| A14 | Does this repo's own `.gitignore` gain `project/*.new`? | yes / no | No: the design names only the block the init entry points write and `asimov-project` appends (D101 §7.5) | default |
