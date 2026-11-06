---
spec: S102
s101: specs/project-management-risk/S101-project-management-risk.md
task: "T002"
title: "Script interface and test scaffold"
role: human
tier: low
after: []
traces: [§6.1, §6.4, §6.5]
owns:
  create: [plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1]
  modify: []
  test: [plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1]
  regenerates: []
consumes: []
produces: [risk-log.ps1, The change file]
status: validated
validated: "2026-10-29"
author: "Simon Vilandt"
date: "2026-10-29"
---

# S102 T002 — Script interface and test scaffold

## 1. Intent

The risk-log script's public interface (D101 §6.5) and the change file it takes (D101 §6.4) as a skeleton with help and no action bodies, plus the empty Pester 5 file beside it, so every slice adds its tests and its action to the same two files.

## 2. Behaviour

none: this task adds no behaviour; its check is the Pester 5 run of `risk-log.Tests.ps1` and the `Get-Help` command in §3.

## 3. Done-when

1. `pwsh -NoProfile -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'` exits 0.
2. `powershell -NoProfile -ExecutionPolicy Bypass -Command 'Import-Module Pester -MinimumVersion 5.0; exit (Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1 -PassThru | ForEach-Object { $_.FailedCount + $_.FailedContainersCount })'` exits 0.
3. `pwsh -NoProfile -Command 'Get-Help ./plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.ps1 -Full'` prints the parameters `-Path`, `-Read`, `-Area`, `-View`, `-Apply`, `-Change`, `-Repair`, `-Finish`, `-By` and `-PluginRoot`, the four exit codes and the fields of the change file.

## 4. Constraints and stops

- **Must:** `-PluginRoot` defaults to the folder three levels above the script, the plugin root, as every script beside its skill does (S101 §6 A7).
- **Must:** the comment-based help states the change file's fields as D101 §6.4 lists them and the exit codes as D101 §6.5 lists them.
- **Prefer:** the help, parameter and exit-code shape of `plugins/asimov-plugin/skills/artifact-s102-validation/scripts/validate-s102.ps1` and `plugins/asimov-plugin/skills/artifact-s101-ledger/scripts/ledger.ps1`.

## 5. Out of scope

- What each action does — T003 to T010
- The page template the script renders from — T001
