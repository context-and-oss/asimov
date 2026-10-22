<#
.SYNOPSIS
  The Spec stage's bookkeeping after the go, in one call: mark task specs validated, move the plan's status.

.DESCRIPTION
  asimov-spec used to edit every S102 header one at a time and then the S101's status line, each edit a
  tool call that re-read the whole conversation. This script does the same header edits in one call and
  nothing else: it changes only the status and validated lines inside the YAML frontmatter, keeps every
  other byte (line endings included), and prints one line per file. It never computes an approval, never
  writes a report, never touches a body.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose.

.PARAMETER S102
  One or more task-spec paths to mark. Each gets "status: validated" and "validated: <date>".
.PARAMETER Validated
  The date to write into each S102, YYYY-MM-DD. Defaults to today.
.PARAMETER S101
  The plan whose status line is moved.
.PARAMETER Status
  The S101's new status: draft, ready, "in progress" or done. asimov-spec passes ready, and draft on a re-check.

.EXAMPLE
  pwsh -NoProfile -File mark-spec.ps1 -S102 a.md,b.md,c.md -Validated 2026-10-13 -S101 S101-x.md -Status ready

.OUTPUTS
  One line per file changed. Exit code 0 when every edit was made, 2 when an input could not be read or a
  value is not allowed; nothing is written then.
#>
[CmdletBinding()]
param(
  [string[]]$S102 = @(),
  [string]$Validated = '',
  [string]$S101 = '',
  [string]$Status = ''
)

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'

# -File passes "a,b" as one argument, so a comma-separated list is split here
$S102 = @($S102 | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Raw([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { throw "cannot read: $Path" }
  return [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path).Path)
}

function Write-Raw([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $Path).Path, $Text, $Utf8NoBom)
}

# Replaces the value of one top-level key inside the frontmatter, leaving everything else as it was.
function Set-HeaderValue([string]$Text, [string]$Key, [string]$Value) {
  $fm = [regex]::Match($Text, '(?s)\A---\r?\n(.*?)(\r?\n---)')
  if (-not $fm.Success) { throw 'no YAML frontmatter between --- lines' }
  $front = $fm.Groups[1].Value
  $rx = New-Object System.Text.RegularExpressions.Regex ('(?m)^' + [regex]::Escape($Key) + ':[^\r\n]*$')
  if (-not $rx.IsMatch($front)) { throw "no '${Key}:' line in the frontmatter" }
  $front = $rx.Replace($front, ($Key + ': ' + $Value), 1)
  return $Text.Substring(0, $fm.Groups[1].Index) + $front + $Text.Substring($fm.Groups[1].Index + $fm.Groups[1].Length)
}

# ---------------------------------------------------------------- validate the inputs before writing anything

if ($S102.Count -eq 0 -and $S101 -eq '') { Write-Output 'mark-spec: nothing to do (give -S102 and/or -S101)'; exit 2 }
if ($S102.Count -gt 0) {
  if ($Validated -eq '') { $Validated = (Get-Date).ToString('yyyy-MM-dd') }
  if ($Validated -notmatch '^\d{4}-\d{2}-\d{2}$') { Write-Output "mark-spec: -Validated must be YYYY-MM-DD, got '$Validated'"; exit 2 }
}
if ($S101 -ne '') {
  if (@('draft', 'ready', 'in progress', 'done') -notcontains $Status) { Write-Output "mark-spec: -Status must be draft, ready, 'in progress' or done, got '$Status'"; exit 2 }
}

$edits = @()
try {
  foreach ($p in $S102) {
    $t = Read-Raw $p
    $t = Set-HeaderValue $t 'status' 'validated'
    $t = Set-HeaderValue $t 'validated' ('"' + $Validated + '"')
    $edits += @{ Path = $p; Text = $t; Line = "marked  $p  validated $Validated" }
  }
  if ($S101 -ne '') {
    $t = Read-Raw $S101
    $t = Set-HeaderValue $t 'status' $Status
    $edits += @{ Path = $S101; Text = $t; Line = "status  $S101  $Status" }
  }
} catch {
  Write-Output "mark-spec: $($_.Exception.Message)"
  exit 2
}

foreach ($e in $edits) { Write-Raw $e.Path $e.Text; Write-Output $e.Line }
exit 0
