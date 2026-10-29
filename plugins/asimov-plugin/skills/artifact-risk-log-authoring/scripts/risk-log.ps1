<#
.SYNOPSIS
  The risk log's script: read, render, check and write one register page, project/risk-log.html.

.DESCRIPTION
  Implements the method of skills/artifact-risk-log-authoring/SKILL.md on the one file that holds
  an engagement's risks. The page is the record: the script reads it back from the attributes and
  lists the template names (artifacts/project/risk-log/risk-log-template.html), and renders the
  score, the summary table and the counts without ever reading them. The model decides only the
  change; every rule the definition states is checked here.

  Every call does one action on -Path. A write goes to <page>.new beside the page, is read back and
  checked, then replaces the page by one rename; a failed check deletes the .new. The person who
  makes a change is -By, else git config user.name, never guessed.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose. The page is
  written as UTF-8.

.PARAMETER Path
  The register page, normally project/risk-log.html in the product repo.
.PARAMETER Read
  Print the data model, the areas in use and the problems found, as JSON. Writes nothing.
.PARAMETER Area
  With -Read: also print the areas in use that are nearly the same as this text.
.PARAMETER View
  Print the fixed 80-column view of the register. Writes nothing.
.PARAMETER Apply
  Apply the change file given by -Change: write to <page>.new, check, rename.
.PARAMETER Change
  With -Apply: a JSON change file. Its fields:
    verb      add | change | state | handover | review | optout | repair
    target    RISK-NNN, or the leaving owner for handover
    fields    name, owner, impact, probability, area, description, mitigation
    state     { to, reason, decider }
    with      [participants], for a review
    to        the new owner, for a handover
    opt-out   { reason, where, decider }
    language  the project language, on the first write only
.PARAMETER Repair
  Print a repair proposal as JSON, from the problems a read finds or from git conflict markers.
.PARAMETER Finish
  Finish an interrupted write: check a <page>.new left beside the page and rename it, or delete it.
.PARAMETER By
  The person making the change. Defaults to git config user.name.
.PARAMETER PluginRoot
  The plugin root, where the template is read from. Defaults to three folders above this script.

.OUTPUTS
  Exit codes:
    0  done
    1  refused by a rule; the rule is printed on stdout
    2  an input could not be read
    3  no person: git config user.name is unset and no -By was given

.EXAMPLE
  pwsh -NoProfile -File risk-log.ps1 -Path project/risk-log.html -View
.EXAMPLE
  pwsh -NoProfile -File risk-log.ps1 -Path project/risk-log.html -Apply -Change change.json
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [switch]$Read,
  [string]$Area,
  [switch]$View,
  [switch]$Apply,
  [string]$Change,
  [switch]$Repair,
  [switch]$Finish,
  [string]$By,
  [string]$PluginRoot
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

if (-not $PluginRoot) { $PluginRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }

$actions = @(@('Read', $Read), @('View', $View), @('Apply', $Apply), @('Repair', $Repair), @('Finish', $Finish)) | Where-Object { $_[1] } | ForEach-Object { $_[0] }
if (@($actions).Count -ne 1) {
  Write-Output 'Give exactly one action: -Read, -View, -Apply, -Repair or -Finish.'
  exit 2
}

Write-Output "-$($actions) is not built yet."
exit 2
