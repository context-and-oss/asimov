<#
.SYNOPSIS
  Renders one plan (.asimov/plans/<slug>.md) into the S101 and its S102s under .asimov/specs/<slug>/,
  and records the person's approval when asked to.

.DESCRIPTION
  The plan is the writer's surface; the S101 and the S102s are the build's data model. This script is
  the only thing that writes them: the S101 header and tree, the six plan sections and one S102 per
  task, header copied from the task line and the task's yaml block, body from the task's sections.
  It judges nothing (validate-plan.ps1 does, before the go) and it is idempotent: the same plan renders
  the same files.

  The approval is the person's go. With -Approve the script computes the S101 fingerprint (the S101
  definition section 6, as ledger.ps1 computes it), writes approved: { by, date, fingerprint } into the
  plan and the S101, sets the plan and the S101 ready and marks every S102 validated. Without -Approve
  it keeps the approval the plan carries when the fingerprint still matches (a hand edit outside the
  approved parts, a re-render), and refuses with exit 3 when the approved parts changed, so the caller
  shows the plan again and asks for the go. A plan that was approved once and is approved again after
  a change gets its version bumped: the version is the approval's name.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose.

.PARAMETER Plan
  Repo-relative or absolute path of the plan, .asimov/plans/<slug>.md.
.PARAMETER Approve
  Record the person's go: a new approval with -By and -Date, the status ready.
.PARAMETER By
  The approver's name. Defaults to git config user.name, then the plan's author.
.PARAMETER Date
  The approval date, YYYY-MM-DD. Defaults to today.
.PARAMETER OutDir
  Where the S101 and S102s are written. Defaults to <repo>/.asimov/specs/<slug>/.
.PARAMETER RepoRoot
  The product repo root. Defaults to the folder two above .asimov/plans/.

.OUTPUTS
  One line per thing done: approved, rendered, removed, kept. Exit 0 when the files were written,
  2 when an input could not be read or the plan is not a plan, 3 when the approved parts changed
  and no -Approve was given (nothing written).
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Plan,
  [switch]$Approve,
  [string]$By = '',
  [string]$Date = '',
  [string]$OutDir = '',
  [string]$RepoRoot = ''
)

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

. (Join-Path $PSScriptRoot 'plan-lib.ps1')

function Fail-Run([string]$Message) { Write-Output "render-plan: $Message"; exit 2 }

if (-not [System.IO.Path]::IsPathRooted($Plan)) { $Plan = Join-Path (Get-Location).Path $Plan }
$Plan = $Plan -replace '/', '\'
if ($RepoRoot -eq '') { $RepoRoot = Get-RepoRootFromPlan $Plan }
$Slug = Get-PlanSlug $Plan
if ($Slug -eq '') { Fail-Run "not a plan path: $Plan" }
if ($OutDir -eq '') { $OutDir = Join-Path (Join-Path (Join-Path $RepoRoot '.asimov') 'specs') $Slug }
$OutDir = $OutDir -replace '/', '\'

try { $planText = Read-Text $Plan; $PlanObj = Parse-Plan $planText } catch { Fail-Run $_.Exception.Message }
if ((Get-HeaderValue $PlanObj 'spec') -ne 'plan') { Fail-Run "spec is '$(Get-HeaderValue $PlanObj 'spec')', not plan" }
if ($PlanObj.TreeTasks.Count -eq 0) { Fail-Run 'the tree holds no task' }
if ($Date -eq '') { $Date = (Get-Date).ToString('yyyy-MM-dd') }
if ($Date -notmatch '^\d{4}-\d{2}-\d{2}$') { Fail-Run "-Date must be YYYY-MM-DD, got '$Date'" }
if ($Approve -and $By -eq '') {
  try { $By = (& git -C $RepoRoot config user.name 2>$null | Out-String).Trim() } catch { $By = '' }
  if ($By -eq '') { $By = Get-HeaderValue $PlanObj 'author' }
}

# ---------------------------------------------------------------- the approval

$Version = Get-HeaderValue $PlanObj 'version'; if ($Version -eq '') { $Version = '0.1' }
$approvedRaw = Get-HeaderValue $PlanObj 'approved'
$old = @{}
if ($approvedRaw -ne '' -and $approvedRaw -ne 'none') { $old = Parse-FlowMap $approvedRaw }
$oldFp = ''; if ($old.ContainsKey('fingerprint')) { $oldFp = $old['fingerprint'] }

# the fingerprint covers the tree and sections 2, 3 and 6; neither the approval line nor the status is in it
$fp = Get-Fingerprint (Render-S101 $PlanObj 'draft' 'none' $Version)

$approvedLine = 'none'; $status = 'draft'; $line1 = ''
if ($Approve) {
  if ($oldFp -ne '' -and $oldFp -ne $fp) {
    # approved before, changed since: the new approval gets the next version
    $parts = $Version -split '\.'
    if ($parts.Count -ge 2 -and $parts[1] -match '^\d+$') { $parts[1] = [string]([int]$parts[1] + 1); $Version = ($parts -join '.') } else { $Version = $Version + '.1' }
  }
  $approvedLine = '{ by: ' + (Quote-Yaml $By) + ', date: ' + (Quote-Yaml $Date) + ', fingerprint: ' + (Quote-Yaml $fp) + ' }'
  $status = 'ready'
  $line1 = "approved  v$Version by $By $MidDot $Date"
} elseif ($oldFp -ne '') {
  if ($oldFp -eq $fp) { $approvedLine = $approvedRaw; $status = 'ready'; $line1 = "approval  holds $MidDot v$Version by $($old['by']) $MidDot $($old['date'])" }
  else {
    Write-Output ("changed   the approved parts of v$Version changed since $($old['by']) approved it on $($old['date']); approve the plan again (render with -Approve) " + $MidDot + ' nothing written')
    exit 3
  }
}

# ---------------------------------------------------------------- render

$s101Rel = '.asimov/specs/' + $Slug + '/S101-' + $Slug + '.md'
$s101Text = Render-S101 $PlanObj $status $approvedLine $Version
$validated = 'none'; $s102Status = 'draft'
if ($status -eq 'ready') { $validated = $Date; $s102Status = 'validated' }
$files = New-Object System.Collections.Generic.List[object]
$files.Add(@{ Name = ('S101-' + $Slug + '.md'); Text = $s101Text })
$planTaskById = @{}; foreach ($pt in $PlanObj.Tasks) { if (-not $planTaskById.ContainsKey($pt.Id)) { $planTaskById[$pt.Id] = $pt } }
$missing = @()
foreach ($tt in $PlanObj.TreeTasks) {
  $pt = $null; if ($planTaskById.ContainsKey($tt.Id)) { $pt = $planTaskById[$tt.Id] }
  if ($null -eq $pt) { $missing += $tt.Id; continue }
  $files.Add(@{ Name = (Get-S102FileName $Slug $tt); Text = (Render-S102 $PlanObj $tt $pt $s101Rel $s102Status $validated) })
}
if ($missing.Count -gt 0) { Fail-Run "no task section for $($missing -join ', '); validate the plan first" }

# the plan's own header: status, approval and version as settled above
$newPlan = $planText
$newPlan = Set-HeaderValue $newPlan 'status' $status
$newPlan = Set-HeaderValue $newPlan 'approved' $approvedLine
$newPlan = Set-HeaderValue $newPlan 'version' $Version
if ($newPlan -ne $planText) { Write-Text $Plan $newPlan }

if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$wanted = @{}
foreach ($f in $files) { $wanted[$f.Name] = $true; Write-Text (Join-Path $OutDir $f.Name) $f.Text }
# the S102s are the plan's: one that no task owns any more is a leftover
$removed = @()
foreach ($existing in Get-ChildItem -LiteralPath $OutDir -File -Filter 'S102-*.md' -ErrorAction SilentlyContinue) {
  if (-not $wanted.ContainsKey($existing.Name)) { Remove-Item -LiteralPath $existing.FullName -Force; $removed += $existing.Name }
}

if ($line1 -ne '') { Write-Output $line1 }
$relOut = $OutDir -replace '\\', '/'; $rootFs = $RepoRoot -replace '\\', '/'
if ($relOut.StartsWith($rootFs, [StringComparison]::OrdinalIgnoreCase)) { $relOut = $relOut.Substring($rootFs.Length).TrimStart('/') }
Write-Output ("rendered  $relOut/  S101 + $($PlanObj.TreeTasks.Count) S102 $MidDot $status")
foreach ($r in $removed) { Write-Output "removed   $r" }
exit 0
