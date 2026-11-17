<#
.SYNOPSIS
  The check of one plan (.asimov/plans/<slug>.md), as a script: the plan rows and every task's rows
  in one report, before the person sees the cut.

.DESCRIPTION
  Implements the checklist of asimov-plan-validation.md (beside this script's folder). The plan is
  rendered in memory exactly as render-plan.ps1 renders it, and the rows are answered on that: the
  S101 rows (the graph, the contracts, the coverage, the body, the ten checks of the S101 definition
  section 8) on the rendered S101 with every rendered S102 beside it, and the S102 rows (paths, names,
  placeholders, sections, boundary tokens, sizes, the ten checks of the S102 definition section 8)
  on each rendered S102. Every row is answered by enumeration and lookup (an id is in the design, a
  path exists, a name is declared in the file the task names, a package is referenced, two owned sets
  intersect, a count is under a threshold); nothing is run, no file's logic is read, no content is
  judged. Two runs on unchanged files return the same report.

  The templates are the schema: the S101 template's keys, role and tier values and section titles;
  the S102 template's keys, owns lists and section titles; the thresholds of the S101 definition
  section 8.1. The design's ids are read from a D101 (.html: the spans of class "id" and "ac-id") or
  from the normalised design cache (.md: the numbered items).

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose.

.PARAMETER Plan
  Repo-relative or absolute path of the plan to check.
.PARAMETER Design
  Path of the design (a D101 .html or the normalised design cache .md). When omitted it is taken
  from the plan's design line: the cache when the line has one, else the ref when it is a file.
.PARAMETER PluginRoot
  The plugin root. Defaults to four folders above this script (artifacts/dot-asimov/asimov-plan/scripts/).
.PARAMETER RepoRoot
  The product repo root every repo-relative path resolves against. Defaults to the folder two above
  .asimov/plans/.

.OUTPUTS
  The validation report, as asimov-plan-validation.md fixes it, on stdout, ending in one summary line.
  Exit code 0 when a report was produced, 2 when an input could not be read.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Plan,
  [string]$Design = '',
  [string]$PluginRoot = '',
  [string]$RepoRoot = ''
)

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

. (Join-Path $PSScriptRoot 'plan-lib.ps1')

if ($PluginRoot -eq '') { $PluginRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) }  # artifacts/dot-asimov/<artifact>/scripts/ -> the plugin root
if (-not [System.IO.Path]::IsPathRooted($Plan)) { $Plan = Join-Path (Get-Location).Path $Plan }
if ($RepoRoot -eq '') { $RepoRoot = Get-RepoRootFromPlan $Plan }

# ---------------------------------------------------------------- helpers

function Resolve-RepoPath([string]$Rel) {
  if ([System.IO.Path]::IsPathRooted($Rel)) { return $Rel }
  return (Join-Path $RepoRoot $Rel)
}

function Convert-GlobToRegex([string]$Glob) {
  $g = $Glob -replace '\\', '/'
  $sb = '^'
  $i = 0
  while ($i -lt $g.Length) {
    $c = $g[$i]
    if ($c -eq '*') {
      if ($i + 1 -lt $g.Length -and $g[$i + 1] -eq '*') {
        $i += 2
        if ($i -lt $g.Length -and $g[$i] -eq '/') { $i++; $sb += '(?:.*/)?' } else { $sb += '.*' }
        continue
      }
      $sb += '[^/]*'; $i++; continue
    }
    if ($c -eq '?') { $sb += '[^/]'; $i++; continue }
    $sb += [regex]::Escape([string]$c); $i++
  }
  return $sb + '$'
}

function Test-IsGlob([string]$PlanObj) { return ($PlanObj -match '[\*\?]') }

$script:RepoFileList = $null
function Get-RepoFiles {
  if ($null -eq $script:RepoFileList) {
    $root = (Resolve-Path -LiteralPath $RepoRoot).Path
    $script:RepoFileList = @(Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules|bin|obj)[\\/]' } |
      ForEach-Object { $_.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/' })
  }
  return $script:RepoFileList
}

function Expand-Owned([string]$PlanObj) {
  if (Test-IsGlob $PlanObj) { $rx = Convert-GlobToRegex $PlanObj; return @(Get-RepoFiles | Where-Object { $_ -match $rx }) }
  return @($PlanObj)
}

function Test-PathMatches([string]$Pattern, [string]$Path) {
  if (Test-IsGlob $Pattern) { return (($Path -replace '\\', '/') -match (Convert-GlobToRegex $Pattern)) }
  return (($Path -replace '\\', '/') -eq ($Pattern -replace '\\', '/'))
}

function Normalize-Line([string]$L) {
  $n = ($L -replace '[`*_]', '') -replace '^\s*[-*]\s*', ''
  $n = $n -replace '^\s*(must not|must|prefer|stops?)\s*:\s*', ''
  return ($n -replace '\s+', ' ').Trim().ToLowerInvariant()
}

function Constraint-Subject([string]$L) {
  $n = Normalize-Line $L
  $idx = $n.IndexOf($EmDash)
  if ($idx -ge 0) { $n = $n.Substring(0, $idx) }
  else { $idx2 = $n.IndexOf(' - '); if ($idx2 -ge 0) { $n = $n.Substring(0, $idx2) } }
  return $n.Trim()
}

$script:ProjectFileList = $null
function Get-ProjectFiles {
  if ($null -eq $script:ProjectFileList) { $script:ProjectFileList = @(Get-RepoFiles | Where-Object { $_ -match '\.(csproj|fsproj|vbproj)$|(^|/)package\.json$|(^|/)Directory\.Packages\.props$' }) }
  return $script:ProjectFileList
}
function Test-NameDeclared([string]$Name, [string]$Path) {
  $full = Resolve-RepoPath $Path
  if (-not (Test-Path -LiteralPath $full)) { return $false }
  $short = ($Name -split '\.')[-1]
  return ((Select-String -LiteralPath $full -Pattern ("\b" + [regex]::Escape($short) + "\b") -Quiet) -eq $true)
}
function Test-PackageReferenced([string]$Id) {
  foreach ($pf in Get-ProjectFiles) {
    $full = Resolve-RepoPath $pf
    if ($pf -match 'package\.json$') { if (Select-String -LiteralPath $full -Pattern ('"' + [regex]::Escape($Id) + '"') -Quiet) { return $true } }
    else { if (Select-String -LiteralPath $full -Pattern ('(?i)Package(Reference|Version)\s+Include="' + [regex]::Escape($Id) + '"') -Quiet) { return $true } }
  }
  return $false
}

$Rows = New-Object System.Collections.Generic.List[object]
$Report = New-Object System.Collections.Generic.List[object]
function Add-Row([string]$Id, [string]$Check, [string]$Result, [string]$Reason) {
  $Rows.Add([pscustomobject]@{ Id = $Id; Check = $Check; Result = $Result; Reason = ($Reason -replace '\|', '\|') })
}
function Worst([string[]]$Results) {
  foreach ($r in 'Fail', 'Flag', 'Warn') { if ($Results -contains $r) { return $r } }
  return 'Pass'
}
function RowOf([string]$Id) { foreach ($r in $Rows) { if ($r.Id -eq $Id) { return $r } }; return $null }
function Finish-Row([string]$Id, [string]$Check, [string[]]$Res, [string[]]$Why, [string]$PassSentence) {
  if ($Res.Count -eq 0) {
    $sentence = $PassSentence
    if ($Why.Count -gt 0) { $sentence = ($Why | Select-Object -Unique) -join '; ' }
    Add-Row $Id $Check 'Pass' $sentence
  } else { Add-Row $Id $Check (Worst $Res) (($Why | Select-Object -Unique) -join '; ') }
}
function Flush-Rows([string]$Prefix) {
  foreach ($r in $Rows) { $id = $r.Id; if ($Prefix -ne '') { $id = $Prefix + ' ' + $id }; $Report.Add([pscustomobject]@{ Id = $id; Check = $r.Check; Result = $r.Result; Reason = $r.Reason }) }
  $Rows.Clear()
}

# ---------------------------------------------------------------- inputs

try {
  $planText = Read-Text $Plan
  $PlanObj = Parse-Plan $planText
  $s101TplPath = Join-Path $PluginRoot 'artifacts/dot-asimov/s101-implementation-plan/s101-implementation-plan-template.md'
  $s101DefPath = Join-Path $PluginRoot 'artifacts/dot-asimov/s101-implementation-plan/s101-implementation-plan-definition.md'
  $s102TplPath = Join-Path $PluginRoot 'artifacts/dot-asimov/s102-task-spec/s102-task-spec-template.md'
  $s101TplText = Read-Text $s101TplPath
  $s101TplBody = [regex]::Replace($s101TplText, '(?s)^\s*<!--.*?-->\s*', '')
  $s101DefText = Read-Text $s101DefPath
  $s102TplText = [regex]::Replace((Read-Text $s102TplPath), '(?s)^\s*<!--.*?-->\s*', '')
} catch {
  Write-Output "validate-plan: $($_.Exception.Message)"
  exit 2
}

$Slug = Get-PlanSlug $Plan
$Version = Get-HeaderValue $PlanObj 'version'; if ($Version -eq '') { $Version = '0.1' }
$s101Rel = '.asimov/specs/' + $Slug + '/S101-' + $Slug + '.md'

# the rendered S101
$s101Text = Render-S101 $PlanObj 'draft' 'none' $Version
$pfm = Split-Frontmatter $s101Text
$PlanHeader = Parse-Header $pfm.Front
$PBody = @($pfm.Body)
$PSections = Get-Sections $PBody
$Phases = $PlanObj.Phases
$AllTasks = @($PlanObj.TreeTasks)
$TaskById = @{}; foreach ($t in $AllTasks) { if ($t.Id -ne '' -and -not $TaskById.ContainsKey($t.Id)) { $TaskById[$t.Id] = $t } }
$PhaseById = @{}; foreach ($ph in $Phases) { $PhaseById[$ph.Id] = $ph }
$PlanTaskById = @{}; $DupTaskSections = @()
foreach ($pt in $PlanObj.Tasks) { if ($PlanTaskById.ContainsKey($pt.Id)) { $DupTaskSections += $pt.Id } else { $PlanTaskById[$pt.Id] = $pt } }

# the rendered S102s, in memory
$Specs = @{}
foreach ($t in $AllTasks) {
  if ($t.Id -eq '' -or -not $PlanTaskById.ContainsKey($t.Id)) { continue }
  $txt = Render-S102 $PlanObj $t $PlanTaskById[$t.Id] $s101Rel 'draft' 'none'
  $sfm = Split-Frontmatter $txt
  if ($null -ne $sfm) { $Specs[$t.Id] = @{ Header = (Parse-Header $sfm.Front); Sections = (Get-Sections @($sfm.Body)); Body = @($sfm.Body); Text = $txt; Name = (Get-S102FileName $Slug $t) } }
}

# the templates as schema
$tplFm = Split-Frontmatter $s101TplBody
if ($null -eq $tplFm) { Write-Output "validate-plan: the S101 template has no frontmatter: $s101TplPath"; exit 2 }
$TplKeys = @(); foreach ($l in $tplFm.Front) { if ($l -match '^([A-Za-z_][\w-]*):') { $TplKeys += $Matches[1] } }
$TplSections = @(Get-Sections @($tplFm.Body) | ForEach-Object { $_.Title })
$s102Fm = Split-Frontmatter $s102TplText
if ($null -eq $s102Fm) { Write-Output "validate-plan: the S102 template has no frontmatter: $s102TplPath"; exit 2 }
$S102TplKeys = @(); $S102OwnsKeys = @()
foreach ($l in $s102Fm.Front) { if ($l -match '^([A-Za-z_][\w-]*):') { $S102TplKeys += $Matches[1] } elseif ($l -match '^\s+([A-Za-z_][\w-]*):') { $S102OwnsKeys += $Matches[1] } }
$S102TplSections = @(Get-Sections @($s102Fm.Body) | ForEach-Object { $_.Title })
$Roles = @('dotnet-builder', 'angular-builder', 'dotnet-tester', 'human')
$mRoles = [regex]::Match($s101TplText, 'role:\s*([a-z-]+(?:\s*\|\s*[a-z-]+)+)')
if ($mRoles.Success) { $Roles = @($mRoles.Groups[1].Value -split '\|' | ForEach-Object { $_.Trim() }) }
$Tiers = @('low', 'mid', 'high')
$mTiers = [regex]::Match($s101TplText, 'tier:\s*(low\s*\|\s*mid\s*\|\s*high)')
if ($mTiers.Success) { $Tiers = @($mTiers.Groups[1].Value -split '\|' | ForEach-Object { $_.Trim() }) }
$thrFiles = 3; $thrScen = 3; $thrScenTester = 5
if ($s101DefText -match 'owned_non_test_files:\s*(\d+)') { $thrFiles = [int]$Matches[1] }
if ($s101DefText -match '(?m)^\s*scenarios:\s*(\d+)') { $thrScen = [int]$Matches[1] }
if ($s101DefText -match 'scenarios_tester:\s*(\d+)') { $thrScenTester = [int]$Matches[1] }

# the design line and the design
$DesignMap = @{}
if ($PlanHeader.ContainsKey('design')) { $DesignMap = Parse-FlowMap ([string]$PlanHeader['design']) }
$IsNormalised = $DesignMap.ContainsKey('cache')
$designPath = $Design
if ($designPath -eq '') {
  if ($IsNormalised) { $designPath = $DesignMap['cache'] }
  elseif ($DesignMap.ContainsKey('ref') -and (Test-Path -LiteralPath (Resolve-RepoPath $DesignMap['ref']))) { $designPath = $DesignMap['ref'] }
}
$designText = ''
$designNote = ''
if ($designPath -ne '') {
  try { $designText = Read-Text (Resolve-RepoPath $designPath) } catch { $designNote = "design not readable at $designPath" }
} else { $designNote = 'no design path given or derivable; ids not looked up' }
$IsHtmlDesign = ($designPath -match '\.html?$')
$DesignIds = @()
if ($designText -ne '') {
  if ($IsHtmlDesign) {
    foreach ($m in [regex]::Matches($designText, 'class="(?:id|ac-id|req-id|q-id)"[^>]*>\s*((?:R|NF|AC|OOS)\d+)\s*<')) { $DesignIds += $m.Groups[1].Value }
  } else {
    foreach ($m in [regex]::Matches($designText, '(?m)^\s*(?:[-*]\s*|\d+\.\s*|#+\s*)?((?:R|NF|AC|OOS)\d+)\b')) { $DesignIds += $m.Groups[1].Value }
  }
  $DesignIds = @($DesignIds | Select-Object -Unique)
}
$RequiredIds = @($DesignIds | Where-Object { $_ -notmatch '^OOS' })
function Test-InDesign([string]$Id) {
  if ($designText -eq '') { return $true }
  if ($DesignIds -contains $Id) { return $true }
  $pat = [regex]::Escape($Id)
  if ($Id -match '^[A-Za-z]') { $pat = "\b$pat\b" }
  return ($designText -match $pat)
}

function Get-Upstream([string]$Id) {
  $seen = @{}; $stack = New-Object System.Collections.Generic.Stack[string]
  if ($TaskById.ContainsKey($Id)) { foreach ($a in $TaskById[$Id].After) { $stack.Push($a) } }
  while ($stack.Count -gt 0) {
    $x = $stack.Pop(); if ($seen.ContainsKey($x)) { continue }; $seen[$x] = $true
    if ($TaskById.ContainsKey($x)) { foreach ($a in $TaskById[$x].After) { $stack.Push($a) } }
  }
  return @($seen.Keys)
}
$UpstreamOf = @{}; foreach ($t in $AllTasks) { if ($t.Id -ne '') { $UpstreamOf[$t.Id] = Get-Upstream $t.Id } }
function Comes-After([string]$A, [string]$B) { return ($UpstreamOf.ContainsKey($A) -and ($UpstreamOf[$A] -contains $B)) }

function Spec-Owns([string]$Id, [string]$List) {
  if (-not $Specs.ContainsKey($Id)) { return @() }
  $sh = $Specs[$Id].Header
  if ($sh.ContainsKey('owns') -and ($sh['owns'] -is [hashtable]) -and $sh['owns'].ContainsKey($List)) {
    $v = $sh['owns'][$List]
    if ($v -is [array]) { return @($v) } elseif ([string]$v -eq '') { return @() } else { return @([string]$v) }
  }
  return @()
}
function Spec-List([string]$Id, [string]$Key) {
  if (-not $Specs.ContainsKey($Id)) { return @() }
  $sh = $Specs[$Id].Header
  if ($sh.ContainsKey($Key) -and $sh[$Key] -is [array]) { return @($sh[$Key]) }
  return @()
}

# S101 section 1 contracts
$Contracts = @{}; $ContractsNone = $false; $ContractsHasConsumedBy = $false; $ContractsHeaderOk = $false; $ContractRows = @()
$plan1 = Get-Section $PSections 1
if ($null -ne $plan1) {
  $txt1 = ($plan1.Lines -join "`n")
  if ($txt1 -match '(?m)^\s*\*?none\*?\s*$') { $ContractsNone = $true }
  $tbl = Parse-Table @($plan1.Lines)
  if ($null -ne $tbl.Header) {
    $iName = -1; $iShape = -1; $iProd = -1
    for ($i = 0; $i -lt $tbl.Header.Count; $i++) {
      if ($tbl.Header[$i] -match '(?i)^name$') { $iName = $i }
      if ($tbl.Header[$i] -match '(?i)^shape$') { $iShape = $i }
      if ($tbl.Header[$i] -match '(?i)produced') { $iProd = $i }
      if ($tbl.Header[$i] -match '(?i)consumed') { $ContractsHasConsumedBy = $true }
    }
    $ContractsHeaderOk = ($iName -ge 0 -and $iShape -ge 0 -and $iProd -ge 0)
    foreach ($r in $tbl.Rows) {
      if ($iName -lt 0 -or $r.Cells.Count -le $iName) { continue }
      $nm = ($r.Cells[$iName] -replace '`', '').Trim()
      if ($nm -eq '' -or $nm -match '^<') { continue }
      $prod = ''; if ($iProd -ge 0 -and $r.Cells.Count -gt $iProd) { $prod = $r.Cells[$iProd] }
      $shape = ''; if ($iShape -ge 0 -and $r.Cells.Count -gt $iShape) { $shape = $r.Cells[$iShape] }
      $ContractRows += [pscustomobject]@{ Name = $nm; Shape = $shape; ProducedBy = $prod; Producers = @($prod -split '[,\s]+' | Where-Object { $_ -match '^T\d+$' }) }
      $Contracts[$nm] = @($prod -split '[,\s]+' | Where-Object { $_ -match '^T\d+$' })
    }
  }
}

# ================================================================ the plan rows

# ---------------------------------------------------------------- G1 frontmatter
$res = @(); $why = @()
if ((Get-HeaderValue $PlanObj 'spec') -ne 'plan') { $res += 'Fail'; $why += "spec is '$(Get-HeaderValue $PlanObj 'spec')', not plan" }
if (-not $PlanObj.SawPhasesKey) { $res += 'Fail'; $why += 'no phases: key in the frontmatter' }
elseif ($Phases.Count -eq 0) { $res += 'Fail'; $why += 'phases: holds no phase (- id: Pn)' }
foreach ($k in $TplKeys) { if (-not $PlanHeader.ContainsKey($k)) { $res += 'Fail'; $why += "key '$k' missing" } }
if ($PlanHeader.ContainsKey('design')) {
  if ($DesignMap.Count -eq 0) { $res += 'Fail'; $why += 'design is not a flow mapping { ref: ..., ... }' }
  elseif (-not $DesignMap.ContainsKey('ref')) { $res += 'Fail'; $why += 'design has no ref' }
  elseif ($IsNormalised) {
    foreach ($dk in 'read', 'cache') { if (-not $DesignMap.ContainsKey($dk)) { $res += 'Fail'; $why += "design (normalised) has no $dk" } }
    if (-not $DesignMap.ContainsKey('approval')) { $res += 'Flag'; $why += 'design (normalised) has no approval mark' }
    elseif (@('verified', 'unverified') -notcontains $DesignMap['approval']) { $res += 'Flag'; $why += "design.approval '$($DesignMap['approval'])' is neither verified nor unverified" }
  } elseif (-not $DesignMap.ContainsKey('version')) { $res += 'Fail'; $why += 'design (repo file) has no version' }
}
$apRaw = Get-HeaderValue $PlanObj 'approved'
if ($apRaw -ne '' -and $apRaw -ne 'none') {
  $apm = Parse-FlowMap $apRaw
  foreach ($ak in 'by', 'date', 'fingerprint') { if (-not $apm.ContainsKey($ak)) { $res += 'Fail'; $why += "approved has no $ak" } }
}
$st = Get-HeaderValue $PlanObj 'status'
if ($st -ne '' -and @('draft', 'ready') -notcontains $st) { $res += 'Fail'; $why += "status '$st' (a plan is draft or ready)" }
if ($PlanObj.Title -eq '') { $res += 'Fail'; $why += 'no title heading (# Plan - <title>) before the sections' }
$expected = 1
foreach ($ph in $Phases) {
  foreach ($pk in 'name', 'delivers', 'checkpoint', 'check', 'tasks') { if ($ph.Keys -notcontains $pk) { $res += 'Fail'; $why += "$($ph.Id) has no $pk" } }
  if ($ph.Name -ne '' -and $ph.Name.Length -gt 40) { $res += 'Flag'; $why += "$($ph.Id) name is $($ph.Name.Length) characters (40)" }
  foreach ($t in $ph.Tasks) {
    foreach ($tk in 'id', 'title', 'role', 'tier', 'after', 'traces') { if ($t.Keys -notcontains $tk) { $res += 'Fail'; $why += "task '$($t.Id)' in $($ph.Id) has no $tk" } }
    foreach ($bad in 'owns', 'produces', 'consumes', 'file', 'phase') { if ($t.Keys -contains $bad) { $res += 'Flag'; $why += "$($t.Id) carries '$bad' on its task line (it belongs in the task section's yaml block)" } }
    if ($t.Role -ne '' -and $Roles -notcontains $t.Role) { $res += 'Fail'; $why += "$($t.Id) role '$($t.Role)' not in [$($Roles -join ', ')]" }
    if ($t.Tier -ne '' -and $Tiers -notcontains $t.Tier) { $res += 'Fail'; $why += "$($t.Id) tier '$($t.Tier)' not in [$($Tiers -join ', ')]" }
    if ($t.Title.Length -gt 60) { $res += 'Flag'; $why += "$($t.Id) title is $($t.Title.Length) characters (60)" }
    if ($t.Id -ne '') {
      $num = [int]([regex]::Match($t.Id, '\d+').Value)
      if ($num -ne $expected) { $res += 'Fail'; $why += "task ids out of order or with a gap at $($t.Id) (expected T$($expected.ToString('000')))" }
      $expected = $num + 1
    }
  }
}
Finish-Row 'G1' 'Frontmatter' $res $why "Every template key present; $($Phases.Count) phase(s), $($AllTasks.Count) task(s), ids in order."

# ---------------------------------------------------------------- G2 no cycle
$res = @(); $why = @()
foreach ($t in $AllTasks) { foreach ($a in $t.After) { if (-not $TaskById.ContainsKey($a)) { $res += 'Fail'; $why += "$($t.Id) comes after '$a', which is not in the tree" } } }
foreach ($t in $AllTasks) { if ($t.Id -ne '' -and (Comes-After $t.Id $t.Id)) { $res += 'Fail'; $why += "$($t.Id) reaches itself through after" } }
Finish-Row 'G2' 'No cycle' $res $why 'Every after id exists; no task reaches itself.'

# ---------------------------------------------------------------- G3 phases
$res = @(); $why = @()
$plan6 = Get-Section $PSections 6
$text6 = ''; if ($null -ne $plan6) { $text6 = ($plan6.Lines -join "`n") }
$HasP0 = ($Phases.Count -gt 0 -and $Phases[0].Id -eq 'P0')
foreach ($ph in $Phases) { if ($ph.Id -eq 'P0' -and $ph -ne $Phases[0]) { $res += 'Fail'; $why += 'P0 is not the first phase' } }
if ($HasP0 -and $Phases[0].Name -notmatch '(?i)foundation') { $res += 'Fail'; $why += "P0 is named '$($Phases[0].Name)', not Foundation" }
$lastSliceIdx = -1
for ($i = 0; $i -lt $Phases.Count; $i++) { if ($Phases[$i].Id -ne 'P0' -and $Phases[$i].Traces.Count -gt 0) { $lastSliceIdx = $i } }
$SliceTaskIds = @()
for ($i = 0; $i -lt $Phases.Count; $i++) { if ($Phases[$i].Id -ne 'P0' -and $Phases[$i].Traces.Count -gt 0) { $SliceTaskIds += @($Phases[$i].Tasks | ForEach-Object { $_.Id }) } }
$SeqPairs = @()
$TestFirstBuilders = @()
function Stack-Of([string]$Role) { return ($Role -split '-')[0] }
for ($i = 0; $i -lt $Phases.Count; $i++) {
  $ph = $Phases[$i]
  if ($ph.Tasks.Count -eq 0) { $res += 'Fail'; $why += "$($ph.Id) holds no task"; continue }
  $isSlice = ($ph.Id -ne 'P0' -and $ph.Traces.Count -gt 0)
  if ($ph.Id -eq 'P0') { continue }
  if ($HasP0) {
    foreach ($t in $ph.Tasks) {
      $p0Same = @($Phases[0].Tasks | Where-Object { (Stack-Of $_.Role) -eq (Stack-Of $t.Role) } | ForEach-Object { $_.Id })
      if ($p0Same.Count -eq 0) { continue }
      $viaP0 = $false; foreach ($p0 in $p0Same) { if (Comes-After $t.Id $p0) { $viaP0 = $true; break } }
      if (-not $viaP0) { $res += 'Fail'; $why += "$($t.Id) in $($ph.Id) has no path from the P0 task of its stack ($($p0Same -join ', '))" }
    }
  }
  if ($isSlice) {
    $testers = @($ph.Tasks | Where-Object { $_.Role -match 'tester' })
    $builders = @($ph.Tasks | Where-Object { $_.Role -match 'builder' -or $_.Role -eq 'human' })
    if ($builders.Count -eq 0) { $res += 'Fail'; $why += "$($ph.Id) is a slice with no builder task" }
    foreach ($b in $builders) {
      if ($b.Role -eq 'human') { continue }
      $sameStack = @($testers | Where-Object { (Stack-Of $_.Role) -eq (Stack-Of $b.Role) })
      if ($sameStack.Count -eq 0) {
        $TestFirstBuilders += $b.Id
        if (@(Spec-Owns $b.Id 'test').Count -eq 0) { $res += 'Fail'; $why += "$($b.Id) has no tester of its stack in $($ph.Id) and owns no test file" }
        continue
      }
      $afterTester = $false; foreach ($tt in $sameStack) { if (Comes-After $b.Id $tt.Id) { $afterTester = $true; break } }
      if (-not $afterTester) { $res += 'Fail'; $why += "$($b.Id) does not come after the tester of its stack in $($ph.Id)" }
    }
    foreach ($tt in $testers) {
      foreach ($u in $UpstreamOf[$tt.Id]) {
        if ($TaskById.ContainsKey($u) -and ($TaskById[$u].Role -match 'builder' -or $TaskById[$u].Role -eq 'human') -and $SliceTaskIds -contains $u -and $TaskById[$u].Phase -ne $ph.Id) { $SeqPairs += "$($tt.Id) after $u" }
      }
    }
  } elseif ($i -gt $lastSliceIdx -and $lastSliceIdx -ge 0) {
    $afterSlice = $false
    foreach ($t in $ph.Tasks) { foreach ($sid in $SliceTaskIds) { if (Comes-After $t.Id $sid) { $afterSlice = $true } } }
    if (-not $afterSlice) { $res += 'Fail'; $why += "$($ph.Id) (close) holds no task that comes after a slice task" }
  } elseif ($i -lt $lastSliceIdx) {
    $res += 'Fail'; $why += "$($ph.Id) has no traces and sits before the last slice (a slice carries traces; only P0 and a close phase have none)"
  }
}
if ($SeqPairs.Count -gt 0) {
  $pathInA6 = ($text6 -match '[\w.-]+/[\w./-]+\.\w+|\w+\.(cs|ts|csproj)\b')
  if ($pathInA6) { $why += "sequenced across slices ($($SeqPairs -join ', ')); a $Sym" + "6 row names a shared file" }
  else { $res += 'Flag'; $why += "sequenced across slices ($($SeqPairs -join ', ')) and no $Sym" + "6 row names the shared file" }
}
$g3Pass = 'Every slice has its tester before its builders; every phase holds a task.'
if ($TestFirstBuilders.Count -gt 0) { $g3Pass = 'Every slice has its tester before its builders, or a test-first builder (' + ($TestFirstBuilders -join ', ') + '); every phase holds a task.' }
Finish-Row 'G3' 'Phases' $res $why $g3Pass

# ---------------------------------------------------------------- G4 parallel = disjoint
$ParallelPairs = @()
for ($i = 0; $i -lt $AllTasks.Count; $i++) {
  for ($j = $i + 1; $j -lt $AllTasks.Count; $j++) {
    $a = $AllTasks[$i].Id; $b = $AllTasks[$j].Id
    if ($a -eq '' -or $b -eq '') { continue }
    if (-not (Comes-After $a $b) -and -not (Comes-After $b $a)) { $ParallelPairs += , @($a, $b) }
  }
}
$res = @(); $why = @()
foreach ($pair in $ParallelPairs) {
  $a = $pair[0]; $b = $pair[1]
  $setA = @(); foreach ($lst in 'create', 'modify', 'test') { foreach ($p in (Spec-Owns $a $lst)) { $setA += $p } }
  $setB = @(); foreach ($lst in 'create', 'modify', 'test') { foreach ($p in (Spec-Owns $b $lst)) { $setB += $p } }
  foreach ($pa in $setA) {
    foreach ($pb in $setB) {
      $hit = $false
      if ((Test-IsGlob $pa) -and (Test-IsGlob $pb)) { $hit = ($pa -eq $pb) -or (@(Expand-Owned $pa | Where-Object { Test-PathMatches $pb $_ }).Count -gt 0) }
      elseif (Test-IsGlob $pa) { $hit = Test-PathMatches $pa $pb }
      elseif (Test-IsGlob $pb) { $hit = Test-PathMatches $pb $pa }
      else { $hit = (($pa -replace '\\', '/') -eq ($pb -replace '\\', '/')) }
      if ($hit) { $res += 'Flag'; $why += "$a and $b may run together and both own '$pa'; the build serialises them" }
    }
  }
}
Finish-Row 'G4' 'Parallel = disjoint' $res $why "$($ParallelPairs.Count) pair(s) may run together; their owned sets are disjoint."

# ---------------------------------------------------------------- G5 contracts table
$res = @(); $why = @()
if ($null -eq $plan1) { $res += 'Fail'; $why += "$Sym" + '1 Contracts missing' }
elseif (-not $ContractsNone -and -not $ContractsHeaderOk) { $res += 'Fail'; $why += "$Sym" + '1 has neither the three columns (Name, Shape, Produced by) nor *none*' }
else {
  if ($ContractsHasConsumedBy) { $res += 'Flag'; $why += "$Sym" + '1 carries a Consumed by column; it is no longer read (the task headers record consumption)' }
  foreach ($r in $ContractRows) {
    if ($r.ProducedBy -match '(?i)existing') { $res += 'Flag'; $why += "'$($r.Name)' is produced by existing code; it belongs in a task's consumes, not $Sym" + '1' }
    elseif ($r.Producers.Count -eq 0) { $res += 'Fail'; $why += "'$($r.Name)' has no task id under Produced by" }
    else { foreach ($p in $r.Producers) { if (-not $TaskById.ContainsKey($p)) { $res += 'Fail'; $why += "'$($r.Name)' is produced by $p, which is not in the tree" } } }
    if ($r.Name -match '(?i)tests?$|^.*Tests?\.' -or $r.Shape -match '(?i)\btest (class|method|name)\b') { $res += 'Flag'; $why += "'$($r.Name)' looks like a test name; a test is never a contract" }
  }
}
Finish-Row 'G5' 'Contracts table' $res $why "$($ContractRows.Count) row(s); every producer is in the tree."

# ---------------------------------------------------------------- G6 coverage both ways
$res = @(); $why = @()
$plan3 = Get-Section $PSections 3
$MapIds = @(); $MapTaskIds = @(); $MapSaysEmpty = @()
if ($null -eq $plan3) { $res += 'Fail'; $why += "$Sym" + '3 Coverage missing' }
else {
  $tbl3 = Parse-Table @($plan3.Lines)
  if ($null -eq $tbl3.Header) { $res += 'Fail'; $why += "$Sym" + '3 holds no table' }
  else {
    $iId = -1; $iSays = -1; $iDel = -1
    for ($i = 0; $i -lt $tbl3.Header.Count; $i++) {
      if ($tbl3.Header[$i] -match '(?i)^id$') { $iId = $i }
      if ($tbl3.Header[$i] -match '(?i)says') { $iSays = $i }
      if ($tbl3.Header[$i] -match '(?i)delivered') { $iDel = $i }
    }
    if ($iId -lt 0 -or $iDel -lt 0) { $res += 'Fail'; $why += "$Sym" + '3 table lacks the Id or Delivered by column' }
    else {
      foreach ($r in $tbl3.Rows) {
        if ($r.Cells.Count -le $iId) { continue }
        $id = $r.Cells[$iId].Trim(); if ($id -eq '' -or $id -match '^<') { continue }
        $MapIds += $id
        $del = ''; if ($r.Cells.Count -gt $iDel) { $del = $r.Cells[$iDel] }
        $tids = @([regex]::Matches($del, '\bT\d{3}\b') | ForEach-Object { $_.Value })
        foreach ($tid in $tids) { $MapTaskIds += $tid; if (-not $TaskById.ContainsKey($tid)) { $res += 'Fail'; $why += "$Sym" + "3 row $id names $tid, not in the tree" } }
        if ($tids.Count -eq 0 -and $del -notmatch '(?i)verified by review|out of scope') { $res += 'Fail'; $why += "$Sym" + "3 row $id has no task and no stated reason" }
        if ($IsNormalised -and $iSays -ge 0) { $says = ''; if ($r.Cells.Count -gt $iSays) { $says = $r.Cells[$iSays].Trim() }; if ($says -eq '' -or $says -eq $EmDash -or $says -eq '-') { $MapSaysEmpty += $id } }
        if (-not (Test-InDesign $id)) { $res += 'Fail'; $why += "$Sym" + "3 row $id is not in the design" }
      }
    }
  }
}
if ($designText -ne '') {
  foreach ($rid in $RequiredIds) { if ($MapIds -notcontains $rid) { $res += 'Fail'; $why += "design id $rid has no $Sym" + '3 row' } }
}
foreach ($t in $AllTasks) {
  if ($t.Id -eq '') { continue }
  if ($t.Traces.Count -eq 0) { $res += 'Fail'; $why += "$($t.Id) has empty traces" }
  foreach ($tr in $t.Traces) { if (-not (Test-InDesign $tr)) { $res += 'Fail'; $why += "design: $($t.Id) traces $tr, not in the design" } }
  if ($MapTaskIds -notcontains $t.Id) { $res += 'Fail'; $why += "$($t.Id) appears in no $Sym" + '3 row' }
}
foreach ($ph in $Phases) { foreach ($tr in $ph.Traces) { if (-not (Test-InDesign $tr)) { $res += 'Fail'; $why += "design: $($ph.Id) traces $tr, not in the design" } } }
foreach ($id in $MapSaysEmpty) { $res += 'Fail'; $why += "$Sym" + "3 row $id has an empty Says (required for a normalised design)" }
if ($designNote -ne '') { $why += $designNote }
Finish-Row 'G6' 'Coverage both ways' $res $why "$($RequiredIds.Count) design id(s) mapped; every task is in the map and traces into the design."

# ---------------------------------------------------------------- G7 sizes
$res = @(); $why = @()
foreach ($t in $AllTasks) {
  if (-not $Specs.ContainsKey($t.Id)) { continue }
  $n = @(Spec-Owns $t.Id 'create').Count + @(Spec-Owns $t.Id 'modify').Count
  if ($n -gt $thrFiles) { $res += 'Warn'; $why += "$($t.Id) owns $n non-test files (threshold $thrFiles)" }
}
Finish-Row 'G7' 'Sizes' $res $why "Every task owns at most $thrFiles non-test files."

# ---------------------------------------------------------------- G8 body
$res = @(); $why = @()
$nums = @($PSections | ForEach-Object { $_.Num })
for ($n = 1; $n -le 6; $n++) { if ($nums -notcontains $n) { $res += 'Fail'; $why += "$Sym$n missing" } }
$ordered = $true; for ($i = 1; $i -lt $nums.Count; $i++) { if ($nums[$i] -lt $nums[$i - 1]) { $ordered = $false } }
if (-not $ordered) { $res += 'Fail'; $why += 'sections out of order' }
for ($i = 0; $i -lt [Math]::Min($PSections.Count, $TplSections.Count); $i++) {
  $want = ($TplSections[$i] -replace '\s+', ' ').Trim().ToLowerInvariant(); $have = ($PSections[$i].Title -replace '\s+', ' ').Trim().ToLowerInvariant()
  if ($want -ne $have -and $PSections[$i].Num -eq ($i + 1)) { $res += 'Flag'; $why += "$Sym$($PSections[$i].Num) is titled '$($PSections[$i].Title)', the template says '$($TplSections[$i])'" }
}
if ($null -ne $plan6) { $t6 = Parse-Table @($plan6.Lines); if ($null -eq $t6.Header -or $t6.Rows.Count -eq 0) { $res += 'Fail'; $why += "$Sym" + '6 Assumptions is empty (no row)' } }
$InFence = $false; $FenceCount = 0; $StepLists = 0; $Checkbox = 0
foreach ($l in $PBody) {
  if ($l -match '^\s*```') { if (-not $InFence) { $FenceCount++ }; $InFence = -not $InFence; continue }
  if ($InFence) { continue }
  if ($l -match '^\s*\d+\.\s+\S') { $StepLists++ }
  if ($l -match '^\s*[-*]\s*\[( |x)\]') { $Checkbox++ }
  foreach ($m in [regex]::Matches($l, '\b([PT]\d{1,3})\b')) {
    $ref = $m.Groups[1].Value
    if ($ref -match '^T' -and $ref.Length -eq 4 -and -not $TaskById.ContainsKey($ref)) { $res += 'Fail'; $why += "the plan body names $ref, not in the tree" }
    if ($ref -match '^P\d+$' -and -not $PhaseById.ContainsKey($ref)) { $res += 'Fail'; $why += "the plan body names $ref, not in the tree" }
  }
}
if ($FenceCount -gt 0) { $res += 'Fail'; $why += "$FenceCount code fence(s) in the plan sections; a plan carries no code" }
if ($StepLists -gt 0) { $res += 'Flag'; $why += "$StepLists numbered line(s) outside a table in the plan sections; a plan carries no step list" }
$TplBodyLines = @($tplFm.Body | ForEach-Object { ($_ -replace '\s+', ' ').Trim() } | Where-Object { $_ -ne '' })
foreach ($sec in $PSections) {
  if ($sec.Num -eq 1) { continue }
  foreach ($l in $sec.Lines) {
    if ($TplBodyLines -contains (($l -replace '\s+', ' ').Trim())) { continue }
    if ($l -match '\b[A-Z]\w*(?:<[^()]*>)?\s+\w+\((?:[^)]*\b[A-Z]\w*\s+\w+)') { $res += 'Flag'; $why += "a signature outside $Sym" + "1 in $Sym$($sec.Num): $($l.Trim())"; break }
  }
}
Finish-Row 'G8' 'Body' $res $why ("$Sym" + '1-' + "$Sym" + '6 in order; no code, no step list; every id named exists.')

# ---------------------------------------------------------------- G9 task sections
$res = @(); $why = @()
foreach ($t in $AllTasks) {
  if ($t.Id -eq '') { continue }
  if (-not $PlanTaskById.ContainsKey($t.Id)) { $res += 'Fail'; $why += "$($t.Id) has no task section (## $($t.Id) - <title>)"; continue }
  $pt = $PlanTaskById[$t.Id]
  if (-not $pt.HasYaml) { $res += 'Fail'; $why += "$($t.Id)'s section opens with no yaml block (owns, consumes, produces)" }
  if ($pt.HeadingTitle.Trim() -ne $t.Title.Trim()) { $res += 'Flag'; $why += "$($t.Id)'s heading reads '$($pt.HeadingTitle)', the task line '$($t.Title)'; the task line is rendered" }
}
foreach ($pt in $PlanObj.Tasks) { if (-not $TaskById.ContainsKey($pt.Id)) { $res += 'Fail'; $why += "a section for $($pt.Id), which is not in the tree" } }
foreach ($d in ($DupTaskSections | Select-Object -Unique)) { $res += 'Fail'; $why += "two sections for $d" }
Finish-Row 'G9' 'Task sections' $res $why 'One section per task, each with its yaml block, none extra.'

# ---------------------------------------------------------------- F3 interface closure across headers
$res = @(); $why = @()
foreach ($t in $AllTasks) {
  if (-not $Specs.ContainsKey($t.Id)) { continue }
  foreach ($c in (Spec-List $t.Id 'consumes')) {
    $mPkg = [regex]::Match($c, '^(.+?)\s*\(\s*package\s+([^)]+)\)\s*$')
    $mPath = [regex]::Match($c, '^(.+?)\s*\(([^)]+)\)\s*$')
    if ($mPkg.Success) { if (-not (Test-PackageReferenced $mPkg.Groups[2].Value.Trim())) { $res += 'Fail'; $why += "$($t.Id) consumes '$($mPkg.Groups[1].Value.Trim())' from package '$($mPkg.Groups[2].Value.Trim())', referenced by no project file" } }
    elseif ($mPath.Success) { $pth = $mPath.Groups[2].Value.Trim(); if (-not (Test-Path -LiteralPath (Resolve-RepoPath $pth))) { $res += 'Fail'; $why += "$($t.Id) consumes '$($mPath.Groups[1].Value.Trim())' at '$pth', which does not exist" } }
    else {
      $nm = $c.Trim()
      if (-not $Contracts.ContainsKey($nm)) { $res += 'Fail'; $why += "$($t.Id) consumes '$nm', in no $Sym" + '1 row and with no path or package' }
      else { $up = @($Contracts[$nm] | Where-Object { Comes-After $t.Id $_ }); if ($Contracts[$nm].Count -gt 0 -and $up.Count -eq 0) { $res += 'Fail'; $why += "$($t.Id) consumes '$nm', produced by $($Contracts[$nm] -join '/') which it does not come after" } }
    }
  }
  foreach ($p in (Spec-List $t.Id 'produces')) {
    $nm = $p.Trim()
    if (-not $Contracts.ContainsKey($nm)) { $res += 'Fail'; $why += "$($t.Id) produces '$nm', in no $Sym" + '1 row' }
    elseif ($Contracts[$nm] -notcontains $t.Id) { $res += 'Fail'; $why += "$($t.Id) produces '$nm', whose $Sym" + "1 row names $($Contracts[$nm] -join '/')" }
  }
}
Finish-Row 'F3' 'Interface closure across tasks' $res $why 'Every consumed name is produced upstream, on disk or in a package; every produced name has its row.'

# ---------------------------------------------------------------- F4 constraints, line against line
$res = @(); $why = @()
$plan2 = Get-Section $PSections 2
$PlanConstraints = @()
if ($null -ne $plan2) { foreach ($l in $plan2.Lines) { if ($l -match '^\s*[-*]\s+\S') { $PlanConstraints += (Constraint-Subject $l) } } }
foreach ($t in $AllTasks) {
  if (-not $Specs.ContainsKey($t.Id)) { continue }
  $s4 = Get-Section $Specs[$t.Id].Sections 4
  if ($null -eq $s4) { continue }
  foreach ($l in $s4.Lines) {
    if ($l -notmatch '^\s*[-*]\s+\S') { continue }
    $n = Normalize-Line $l
    if ($n -eq '' -or $n -eq 'none') { continue }
    foreach ($pc in $PlanConstraints) {
      if ($pc.Length -lt 8) { continue }
      if ($n -eq $pc -or $n.Contains($pc)) { $res += 'Flag'; $why += "$($t.Id) $Sym" + "4 restates $Sym" + "2: '$pc'" }
    }
  }
}
Finish-Row 'F4' 'Constraints' $res $why ("No task $Sym" + "4 line restates a $Sym" + '2 line; a contradiction is not detected by the script.')

# ---------------------------------------------------------------- the ten rows of the plan
function Combine([string[]]$Ids) {
  $results = @(); $reasons = @()
  foreach ($id in $Ids) { $r = RowOf $id; if ($null -eq $r) { continue }; $results += $r.Result; if ($r.Result -ne 'Pass') { $reasons += "$id $($r.Result): $($r.Reason)" } }
  return @{ Results = $results; Reasons = $reasons }
}

# 1 Completeness
$res = @(); $why = @()
if (-not $PlanHeader.ContainsKey('design')) { $res += 'Fail'; $why += 'no design line' }
if ($PlanObj.Preamble.Count -eq 0) { $res += 'Fail'; $why += 'no first paragraph naming the design and its approval' }
elseif (($PlanObj.Preamble -join ' ') -notmatch '(?i)approved') { $res += 'Flag'; $why += 'the first paragraph does not name the approval' }
foreach ($ph in $Phases) { if ($ph.Delivers -eq '') { $res += 'Fail'; $why += "$($ph.Id) has an empty delivers" }; if ($ph.Checkpoint -eq '') { $res += 'Fail'; $why += "$($ph.Id) has an empty checkpoint" }; if ($ph.Check -eq '') { $res += 'Fail'; $why += "$($ph.Id) has an empty check" } }
foreach ($n in 3, 4) { if ($null -eq (Get-Section $PSections $n)) { $res += 'Fail'; $why += "$Sym$n missing" } }
foreach ($n in 1, 2, 6) { $sec = Get-Section $PSections $n; if ($null -ne $sec -and (($sec.Lines -join "`n").Trim() -eq '')) { $res += 'Fail'; $why += "$Sym$n is empty (write *none* when there is nothing)" } }
$c = Combine @('G9'); foreach ($r in $c.Results) { if ($r -eq 'Fail') { $res += 'Fail' } }; $why += $c.Reasons
Finish-Row '1' 'Completeness' $res $why 'Every plan member present; every task has its section.'

# 2 Coverage both ways
$g6 = RowOf 'G6'; Add-Row '2' 'Coverage both ways' $g6.Result $g6.Reason

# 3 Graph validity
$c = Combine @('G2', 'G3', 'G4')
$rs = Worst $c.Results; $sentence = 'No cycle; phases hold; parallel pairs disjoint.'; if ($c.Reasons.Count -gt 0) { $sentence = ($c.Reasons -join '; ') }
Add-Row '3' 'Graph validity' $rs $sentence

# 4 Stoppable phases
$res = @(); $why = @()
foreach ($ph in $Phases) {
  $cp = $ph.Checkpoint; $ck = $ph.Check
  if ($cp -match '(?i)\b(code exists|implemented|is implemented|done)\b\s*$' -or $cp -match '(?i)^\s*(implemented|code exists)') { $res += 'Fail'; $why += "$($ph.Id) checkpoint reads as a claim, not a state: '$cp'" }
  # case-sensitive: a command word is lowercase, and a product term such as "Make now" is not a command
  if ($cp -cmatch '`|\b(dotnet|npm|ng|pwsh|powershell|bash|yarn|pnpm)\b|--\w|[\w.-]+/[\w.-]+\.\w+') { $res += 'Flag'; $why += "$($ph.Id) checkpoint carries a command or a path; it belongs in check" }
  $dl = $ph.Delivers
  if ($dl -cmatch '`|\b(dotnet|npm|ng|pwsh|powershell|bash|yarn|pnpm)\b|--\w|[\w.-]+/[\w.-]+\.\w+') { $res += 'Flag'; $why += "$($ph.Id) delivers carries a command or a path; it says what the phase adds, in the product's words" }
  if ($dl -match '(?i)\btests?\b[^.]*\b(green|red|pass|passes|passing)\b') { $res += 'Flag'; $why += "$($ph.Id) delivers reads as a test result; the checkpoint carries that, delivers says what the phase adds" }
  if ($ck.Trim() -eq '') { $res += 'Fail'; $why += "$($ph.Id) check is empty" }
  elseif ($ck -match '(?i)\b(grep|rg|Select-String|findstr)\b') { $res += 'Fail'; $why += "$($ph.Id) check searches the source: '$ck'" }
  elseif ($ck -notmatch '\S+\s+\S+' -and $ck -notmatch '\.(ps1|sh|cmd)$') { $res += 'Fail'; $why += "$($ph.Id) check has no runnable form: '$ck'" }
}
Finish-Row '4' 'Stoppable phases' $res $why 'Every checkpoint is a sentence; every check is a command that is not a search.'

# 5 Interface closure
$c = Combine @('G5', 'F3'); $rs = Worst $c.Results; $sentence = 'Contracts table consistent; every task header closes.'
if ($c.Reasons.Count -gt 0) { $sentence = ($c.Reasons -join '; ') }
Add-Row '5' 'Interface closure' $rs $sentence

# 6 Constraint consistency
$res = @(); $why = @()
if ($null -eq $plan2) { $res += 'Fail'; $why += "$Sym" + '2 missing' }
else {
  $lines2 = @($plan2.Lines | Where-Object { $_ -match '^\s*[-*]\s+\S' })
  foreach ($l in $lines2) {
    $n = Normalize-Line $l
    if ($n -eq 'none') { continue }
    if ($l -notmatch "$EmDash|\s-\s|\(.*(D101|\$Sym|decision|ticket|convention|CLAUDE|AGENTS|SEC-|[A-Z]+-\d+).*\)") { $res += 'Flag'; $why += "$Sym" + "2 line without a source: '$($l.Trim())'" }
  }
}
$f4 = RowOf 'F4'; if ($f4.Result -ne 'Pass') { $res += $f4.Result; $why += "F4: $($f4.Reason)" }
Finish-Row '6' 'Constraint consistency' $res $why 'Every constraint carries a source.'

# 7 Review focus
$res = @(); $why = @()
$plan5 = Get-Section $PSections 5
if ($null -eq $plan5) { $res += 'Fail'; $why += "$Sym" + '5 missing' }
else {
  $lines5 = @($plan5.Lines | Where-Object { $_ -match '^\s*[-*]\s+\S' })
  if ($lines5.Count -eq 0) { $why += 'stated as checked (empty)' }
  foreach ($l in $lines5) {
    if ((Normalize-Line $l) -eq 'none') { continue }
    $tids = @([regex]::Matches($l, '\bT\d{3}\b') | ForEach-Object { $_.Value })
    if ($tids.Count -eq 0) { $res += 'Fail'; $why += "$Sym" + "5 line pinned to no task: '$($l.Trim())'" }
    foreach ($tid in $tids) {
      if (-not $TaskById.ContainsKey($tid)) { $res += 'Fail'; $why += "$Sym" + "5 line pinned to $tid, not in the tree" }
      else {
        $pt = $TaskById[$tid]
        $phx = $PhaseById[$pt.Phase]
        $inSlice = ($pt.Phase -ne 'P0' -and $phx.Traces.Count -gt 0)
        $sliceHasTester = (@($phx.Tasks | Where-Object { $_.Role -match 'tester' }).Count -gt 0)
        if ($inSlice -and $sliceHasTester -and $pt.Role -match 'builder') { $res += 'Flag'; $why += "$Sym" + "5 line pinned to builder $tid; in a slice the tester carries the scenario" }
      }
    }
    if ($l -notmatch "$Arrow|->" ) { $res += 'Flag'; $why += "$Sym" + "5 line has no 'condition -> expected behaviour' form: '$($l.Trim())'" }
  }
}
Finish-Row '7' 'Review focus' $res $why 'Each line names a condition, a behaviour and a tester task.'

# 8 Escalation
$res = @(); $why = @()
$plan4 = Get-Section $PSections 4
if ($null -eq $plan4) { $res += 'Fail'; $why += "$Sym" + '4 missing' }
else {
  $t4 = ($plan4.Lines -join "`n")
  if ($t4 -notmatch '(?i)routes to') { $res += 'Fail'; $why += "$Sym" + '4 names no route' }
  if ($t4 -notmatch '(?i)stops specific') { $res += 'Fail'; $why += "$Sym" + '4 names no plan-specific stops line' }
  if ($t4 -notmatch '(?i)reaches a human') { $res += 'Fail'; $why += "$Sym" + '4 lacks the human-always cases' }
}
Finish-Row '8' 'Escalation' $res $why 'Route, plan-specific stops and the human-always cases are named.'

# 9 Separation
$res = @(); $why = @()
$g8 = RowOf 'G8'; if ($g8.Result -ne 'Pass') { $res += $g8.Result; $why += "G8: $($g8.Reason)" }
$bodyText = ($PBody -join "`n")
if ($Checkbox -gt 0) { $res += 'Fail'; $why += "$Checkbox checkbox line(s): run state belongs in the ledger" }
if ($bodyText -match '(?im)^\s*[-*|]?\s*(passes|passed|claimed|fixed|verified)\s*[:|]') { $res += 'Flag'; $why += 'a status word opens a line (passes/claimed/fixed); run state belongs in the ledger' }
Finish-Row '9' 'Separation' $res $why 'No code, no steps, no run state in the plan.'

# 10 Model choice
$res = @(); $why = @()
foreach ($t in $AllTasks) { if ($t.Tier -ne '' -and $Tiers -notcontains $t.Tier) { $res += 'Fail'; $why += "$($t.Id) tier '$($t.Tier)'" } }
foreach ($t in $AllTasks) {
  if ($t.Tier -ne 'low' -or -not $Specs.ContainsKey($t.Id)) { continue }
  $s2 = Get-Section $Specs[$t.Id].Sections 2
  if ($null -ne $s2 -and (($s2.Lines -join "`n") -match '(?m)^\s*Scenario(?: Outline)?:')) { $res += 'Flag'; $why += "$($t.Id) is low but its $Sym" + '2 holds a Scenario (behaviour in prose is mid)' }
}
Finish-Row '10' 'Model choice' $res $why 'Every tier is one of the three values.'

Flush-Rows ''

# ================================================================ the task rows, one rendered S102 at a time

$Neighbours = @{}
foreach ($id in $Specs.Keys) { $Neighbours[$id] = @{ Header = $Specs[$id].Header; Sections = $Specs[$id].Sections } }

function Owns([string]$List) {
  if ($H.ContainsKey('owns') -and ($H['owns'] -is [hashtable]) -and $H['owns'].ContainsKey($List)) {
    $v = $H['owns'][$List]
    if ($v -is [array]) { return @($v) } elseif ([string]$v -eq '') { return @() } else { return @([string]$v) }
  }
  return @()
}
function Created-Upstream([string]$PlanObj) { foreach ($c in $UpstreamCreates) { if (Test-PathMatches $c $PlanObj) { return $true } }; return $false }
function Section-Text([int]$n) { $sec = Get-Section $Sections $n; if ($null -eq $sec) { return @() }; return @($sec.Lines) }

$GeneratedRx = '(?i)(^|/)(packages\.lock\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml)$|\.lock\.json$|\.snap$|\.g\.cs$|\.generated\.|(^|/)(Generated|obj)/'
$SrcExt = '\.(cs|ts|tsx|js|html|scss|css|csproj|props|targets|json|md|sql|ya?ml|xml|config|razor|cshtml)'

foreach ($Task in $AllTasks) {
  $TaskId = $Task.Id
  if ($TaskId -eq '' -or -not $Specs.ContainsKey($TaskId)) { continue }
  $H = $Specs[$TaskId].Header
  $Body = @($Specs[$TaskId].Body)
  $Sections = $Specs[$TaskId].Sections
  $Upstream = @(); if ($UpstreamOf.ContainsKey($TaskId)) { $Upstream = @($UpstreamOf[$TaskId]) }
  $Create = Owns 'create'; $Modify = Owns 'modify'; $TestFiles = Owns 'test'; $Regen = Owns 'regenerates'
  $Consumes = @(); if ($H.ContainsKey('consumes') -and $H['consumes'] -is [array]) { $Consumes = @($H['consumes']) }
  $Produces = @(); if ($H.ContainsKey('produces') -and $H['produces'] -is [array]) { $Produces = @($H['produces']) }
  $Role = $Task.Role
  $IsTester = ($Role -match 'tester'); $IsBuilder = ($Role -match 'builder' -or $Role -eq 'human')

  # fences and gherkin
  $Fences = New-Object System.Collections.Generic.List[object]
  $inFence = $false; $fenceLang = ''; $fenceLines = $null
  $LineInFence = New-Object 'bool[]' ([Math]::Max($Body.Count, 1))
  for ($i = 0; $i -lt $Body.Count; $i++) {
    $l = $Body[$i]
    if ($l -match '^\s*```(\w*)') {
      if (-not $inFence) { $inFence = $true; $fenceLang = $Matches[1]; $fenceLines = New-Object System.Collections.Generic.List[string] }
      else { $Fences.Add([pscustomobject]@{ Lang = $fenceLang; Lines = $fenceLines }); $inFence = $false }
      $LineInFence[$i] = $true; continue
    }
    if ($inFence) { $LineInFence[$i] = $true; $fenceLines.Add($l) }
  }
  $Gherkin = @($Fences | Where-Object { $_.Lang -eq 'gherkin' })
  $ScenarioLines = @(); $OwnScenarioCount = 0; $ReviewFocusCount = 0
  foreach ($g in $Gherkin) {
    $prevNonBlank = ''
    foreach ($gl in $g.Lines) {
      if ($gl -match '^\s*Scenario(?: Outline)?:') {
        $ScenarioLines += $gl
        if ($prevNonBlank -match '^\s*@review-focus') { $ReviewFocusCount++ } else { $OwnScenarioCount++ }
      }
      if ($gl.Trim() -ne '') { $prevNonBlank = $gl }
    }
  }
  $Sec2 = Section-Text 2; $Sec3 = Section-Text 3; $Sec4 = Section-Text 4
  $NoneLine = @($Sec2 | Where-Object { $_ -match '^\s*(?:[-*]\s*)?none:' }) | Select-Object -First 1
  $AsLine = @($Sec2 | Where-Object { $_ -match '^\s*(?:[-*]\s*)?as\s+(T\d+):' }) | Select-Object -First 1
  $AsTester = ''; if ($null -ne $AsLine -and $AsLine -match 'as\s+(T\d+):') { $AsTester = $Matches[1] }
  $DoneItems = @($Sec3 | Where-Object { $_ -match '^\s*\d+\.\s' })

  # ---------------------------------------------------------------- S1 header block
  $res = @(); $why = @()
  if (-not $H.ContainsKey('owns') -or -not ($H['owns'] -is [hashtable])) { $res += 'Fail'; $why += 'owns missing in the yaml block' }
  else { foreach ($ok in $S102OwnsKeys) { if (-not $H['owns'].ContainsKey($ok)) { if ($ok -eq 'regenerates') { $res += 'Flag'; $why += 'owns.regenerates missing (reads as empty)' } else { $res += 'Fail'; $why += "owns.$ok missing" } } } }
  foreach ($k in 'consumes', 'produces') { if (-not $H.ContainsKey($k)) { $res += 'Fail'; $why += "$k missing in the yaml block" } }
  foreach ($k in $H.Keys) { if ($S102TplKeys -notcontains $k) { $res += 'Flag'; $why += "extra key $k in the yaml block" } }
  foreach ($k in 'spec', 's101', 'task', 'title', 'role', 'tier', 'after', 'traces', 'status', 'validated', 'author', 'date') {
    if (($PlanTaskById[$TaskId].YamlLines -join "`n") -match ('(?m)^' + $k + ':')) { $res += 'Flag'; $why += "the yaml block carries '$k', which the task line and the plan header provide" }
  }
  if ($res.Count -eq 0) { Add-Row 'S1' 'Header block' 'Pass' 'owns with its four lists, consumes and produces present.' } else { Add-Row 'S1' 'Header block' (Worst $res) ($why -join '; ') }

  # ---------------------------------------------------------------- S3 paths resolve
  $res = @(); $why = @()
  $UpstreamCreates = @()
  foreach ($u in $Upstream) {
    if ($Neighbours.ContainsKey($u)) {
      $nh = $Neighbours[$u].Header
      if ($nh.ContainsKey('owns') -and $nh['owns'] -is [hashtable] -and $nh['owns'].ContainsKey('create') -and $nh['owns']['create'] -is [array]) { $UpstreamCreates += @($nh['owns']['create']) }
    }
  }
  foreach ($p in $Modify) {
    if (Test-IsGlob $p) { if (@(Expand-Owned $p).Count -eq 0 -and -not (Created-Upstream $p)) { $res += 'Flag'; $why += "modify glob '$p' matches nothing today" } }
    elseif (-not (Test-Path -LiteralPath (Resolve-RepoPath $p)) -and -not (Created-Upstream $p)) { $res += 'Fail'; $why += "modify path '$p' does not exist and no upstream task creates it" }
    if ($p -match $GeneratedRx) { $res += 'Flag'; $why += "'$p' looks generated; it belongs under regenerates" }
    if ($p -match '(?i)(^|/)[^/]*tests?[^/]*\.(cs|ts|js)$|(^|/)tests?/') { $res += 'Flag'; $why += "'$p' is a test file listed under modify; it belongs under test" }
  }
  foreach ($p in $Create) {
    if (-not (Test-IsGlob $p) -and (Test-Path -LiteralPath (Resolve-RepoPath $p))) { $res += 'Fail'; $why += "create path '$p' already exists" }
    if ($p -match $GeneratedRx) { $res += 'Flag'; $why += "'$p' looks generated; it belongs under regenerates" }
  }
  foreach ($p in $TestFiles) { if ($p -match $GeneratedRx) { $res += 'Flag'; $why += "'$p' looks generated; it belongs under regenerates" } }
  $all = @($Create) + @($Modify) + @($TestFiles) + @($Regen)
  $dups = @($all | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
  foreach ($d in $dups) { $res += 'Fail'; $why += "'$d' appears in two owns lists" }
  $Owned = @($Create) + @($Modify) + @($TestFiles) + @($Regen)
  for ($i = 0; $i -lt $Body.Count; $i++) {
    if ($LineInFence[$i]) { continue }
    $l = $Body[$i] -replace 'https?://\S+', ''
    foreach ($m in [regex]::Matches($l, "(?<![\w/.:])((?:[\w.-]+/)+[\w.-]+$SrcExt)\b")) {
      $bp = $m.Groups[1].Value
      $ok = $false
      foreach ($o in $Owned) { if (Test-PathMatches $o $bp) { $ok = $true; break } }
      if (-not $ok -and (Test-Path -LiteralPath (Resolve-RepoPath $bp))) { $ok = $true }
      if (-not $ok -and (Created-Upstream $bp)) { $ok = $true }
      if (-not $ok) {
        foreach ($md in [regex]::Matches($l, '(?:--prefix|-C|\bcd)\s+"?([\w./-]+)"?')) { if (Test-Path -LiteralPath (Resolve-RepoPath (Join-Path $md.Groups[1].Value $bp))) { $ok = $true; break } }
      }
      if (-not $ok) {
        $inSpan = (([regex]::Matches($l.Substring(0, $m.Index), '`').Count % 2) -eq 1)
        if ($inSpan) { $res += 'Flag'; $why += "path '$bp' in a command does not resolve from the repo root; the builder runs it from its folder" }
        else { $res += 'Fail'; $why += "body path '$bp' is neither owned nor existing" }
      }
    }
  }
  if ($res.Count -eq 0) { Add-Row 'S3' 'Paths resolve' 'Pass' 'Every owned path exists, is created upstream, or is new under test.' } else { Add-Row 'S3' 'Paths resolve' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

  # ---------------------------------------------------------------- S4 names in the contracts
  $res = @(); $why = @()
  $ConsumedNames = @(); $ConsumedPaths = @()
  foreach ($c in $Consumes) {
    $mPkg = [regex]::Match($c, '^(.+?)\s*\(\s*package\s+([^)]+)\)\s*$')
    $mPath = [regex]::Match($c, '^(.+?)\s*\(([^)]+)\)\s*$')
    $nm = ''
    if ($mPkg.Success) {
      $nm = $mPkg.Groups[1].Value.Trim(); $pkg = $mPkg.Groups[2].Value.Trim(); $ConsumedNames += $nm
      if (-not (Test-PackageReferenced $pkg)) { $res += 'Fail'; $why += "'$nm': no project file references package '$pkg'" }
    } elseif ($mPath.Success) {
      $nm = $mPath.Groups[1].Value.Trim(); $pth = $mPath.Groups[2].Value.Trim(); $ConsumedNames += $nm; $ConsumedPaths += $pth
      if (-not (Test-Path -LiteralPath (Resolve-RepoPath $pth))) { $res += 'Fail'; $why += "'$nm': path '$pth' does not exist" }
      elseif (-not (Test-NameDeclared $nm $pth)) { $res += 'Fail'; $why += "'$nm' is not found in '$pth'" }
    } else {
      $nm = $c.Trim(); $ConsumedNames += $nm
      if ($Contracts.ContainsKey($nm)) {
        $producers = @($Contracts[$nm])
        $upstreamProducer = @($producers | Where-Object { $Upstream -contains $_ })
        if ($producers.Count -gt 0 -and $upstreamProducer.Count -eq 0) { $res += 'Fail'; $why += "'$nm' is produced by $($producers -join '/') which $TaskId does not come after" }
      } else { $res += 'Fail'; $why += "'$nm' is in no ${Sym}1 row and carries no path or package" }
    }
    if ($nm -match '(?i)tests?$|^.*Test[A-Z]') { $res += 'Flag'; $why += "'$nm' looks like a test name; a test is named in the done-when, never consumed" }
  }
  foreach ($p in $Produces) {
    if (-not $Contracts.ContainsKey($p)) { $res += 'Fail'; $why += "produced '$p' has no ${Sym}1 row" }
    elseif ($Contracts[$p].Count -gt 0 -and $Contracts[$p] -notcontains $TaskId) { $res += 'Fail'; $why += "${Sym}1 names $($Contracts[$p] -join '/') as producer of '$p', not $TaskId" }
  }
  if ($res.Count -eq 0) { Add-Row 'S4' 'Names in the contracts' 'Pass' "Every consumed name is a ${Sym}1 row produced upstream, declared at its path, or a referenced package type; every produced name is this task's row." } else { Add-Row 'S4' 'Names in the contracts' (Worst $res) ($why -join '; ') }

  # ---------------------------------------------------------------- S5 placeholders
  $res = @(); $why = @()
  $tokens = @('\bTBD\b', '\bTODO\b', '\bFIXME\b', '\bXXX\b', '(?i)similar to T0\d*', '(?i)handle edge cases', '(?i)appropriate error handling', '(?i)\bas needed\b', '(?i)to be decided', '\{\{[^}]*\}\}')
  for ($i = 0; $i -lt $Body.Count; $i++) {
    $l = $Body[$i]
    foreach ($tk in $tokens) { if ($l -match $tk) { $res += 'Fail'; $why += "'$($Matches[0])' on: $($l.Trim())" } }
    if (-not $LineInFence[$i]) {
      $noCode = $l -replace '`[^`]*`', ''
      foreach ($m in [regex]::Matches($noCode, '<[A-Za-z][^<>]*\s[^<>]*>')) { $res += 'Fail'; $why += "template description left: $($m.Value)" }
    }
  }
  foreach ($fc in $Fences) { if (@($fc.Lines | Where-Object { $_.Trim() -ne '' }).Count -eq 0) { $res += 'Fail'; $why += 'an empty fenced block' } }
  if ($res.Count -eq 0) { Add-Row 'S5' 'Placeholders' 'Pass' 'No placeholder token or template description.' } else { Add-Row 'S5' 'Placeholders' 'Fail' (($why | Select-Object -Unique) -join '; ') }

  # ---------------------------------------------------------------- S6 sections
  $res = @(); $why = @()
  for ($n = 1; $n -le $S102TplSections.Count; $n++) { $sec = Get-Section $Sections $n; if ($null -eq $sec) { $res += 'Fail'; $why += "${Sym}$n missing" } }
  $order = @($Sections | ForEach-Object { $_.Num })
  $sorted = @($order | Sort-Object)
  if (@(Compare-Object $order $sorted -SyncWindow 0).Count -gt 0) { $res += 'Fail'; $why += "sections out of the template's order" }
  $hasScenario = ($ScenarioLines.Count -gt 0)
  if (-not $hasScenario -and $null -eq $NoneLine -and $null -eq $AsLine) { $res += 'Fail'; $why += "${Sym}2 holds no gherkin Scenario, no none: line and no as T<nnn>: line" }
  if ($null -ne $AsLine) {
    if (-not $IsBuilder) { $res += 'Flag'; $why += 'as T<nnn>: line on a non-builder task' }
    $tt = $null; if ($TaskById.ContainsKey($AsTester)) { $tt = $TaskById[$AsTester] }
    if ($null -eq $tt -or $tt.Role -notmatch 'tester' -or $tt.Phase -ne $Task.Phase -or $Upstream -notcontains $AsTester) { $res += 'Fail'; $why += "as $AsTester`: names no tester task in the same phase that $TaskId comes after" }
  }
  if ($DoneItems.Count -eq 0) { $res += 'Fail'; $why += "${Sym}3 holds no numbered item" }
  if ($res.Count -eq 0) { Add-Row 'S6' 'Sections' 'Pass' "${Sym}1-${Sym}$($S102TplSections.Count) present in order; ${Sym}2 and ${Sym}3 hold content." } else { Add-Row 'S6' 'Sections' (Worst $res) ($why -join '; ') }

  # ---------------------------------------------------------------- S7 boundary tokens
  $res = @(); $why = @()
  foreach ($fc in $Fences) { if ($fc.Lang -ne 'gherkin') { $res += 'Fail'; $why += "a fenced block of language '$($fc.Lang)'" } }
  for ($i = 0; $i -lt $Body.Count - 1; $i++) { if ($Body[$i] -match '(?i)^\s*(#+\s*)?\**steps\**\s*:?\s*$' -and $Body[$i + 1] -match '^\s*(\d+\.|[-*])\s') { $res += 'Fail'; $why += 'a list under a Steps heading' } }
  foreach ($sl in $ScenarioLines) { if ($sl -match "(?:[\w.-]+/)+[\w.-]+$SrcExt") { $res += 'Fail'; $why += "a Scenario names a path: $($sl.Trim())" } }
  foreach ($d in $DoneItems) { if ($d -match '(?i)\b(grep|rg|Select-String|findstr)\b') { $res += 'Fail'; $why += "a done-when searches the source: $($d.Trim())" } }
  $OwnedOnDisk = @(@($Modify) + @($TestFiles) | Where-Object { -not (Test-IsGlob $_) -and (Test-Path -LiteralPath (Resolve-RepoPath $_)) })
  $known = @($Contracts.Keys) + @($ConsumedNames) + @($Produces)
  $knownShort = @($known | ForEach-Object { ($_ -split '\.')[-1] })
  $unknown = @()
  foreach ($g in $Gherkin) {
    foreach ($gl in $g.Lines) {
      foreach ($m in [regex]::Matches($gl, '\b[A-Z][a-z0-9]+(?:[A-Z][a-z0-9]+)+\b|\b[A-Za-z_]\w*\.[A-Z]\w*(?:\.\w+)*\b')) {
        $idn = $m.Value; $short = ($idn -split '\.')[-1]
        if ($knownShort -contains $short) { continue }
        if ($designText -ne '' -and $designText -match ("\b" + [regex]::Escape($short) + "\b")) { continue }
        if ($short -match 'Exception$') { continue }
        $found = $false
        foreach ($cp in ($ConsumedPaths + $OwnedOnDisk)) { if (Test-NameDeclared $short $cp) { $found = $true; break } }
        if (-not $found) { $unknown += $idn }
      }
    }
  }
  $unknown = @($unknown | Select-Object -Unique)
  if ($unknown.Count -gt 0) { $res += 'Flag'; $why += "identifiers in scenarios found in no ${Sym}1 row, header entry, design or consumed path: $($unknown -join ', ')" }
  if ($res.Count -eq 0) { Add-Row 'S7' 'Boundary tokens' 'Pass' 'Gherkin only; no steps list; no path in a scenario; no search in a done-when.' } else { Add-Row 'S7' 'Boundary tokens' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

  $SameStackTesters = @()
  if ($IsBuilder) {
    $stack = ($Role -split '-')[0]
    $SameStackTesters = @($Task.After | Where-Object { $TaskById.ContainsKey($_) -and $TaskById[$_].Role -match 'tester' -and $TaskById[$_].Phase -eq $Task.Phase -and ($TaskById[$_].Role -split '-')[0] -eq $stack })
  }
  $IsTestFirstBuilder = ($IsBuilder -and $SameStackTesters.Count -eq 0 -and @($TestFiles).Count -gt 0)

  # ---------------------------------------------------------------- S8 sizes
  $res = @(); $why = @()
  $fileCount = @($Create).Count + @($Modify).Count
  if ($fileCount -gt $thrFiles) { $res += 'Warn'; $why += "$fileCount owned non-test files, threshold $thrFiles" }
  $scenThr = $thrScen; if ($IsTester -or $IsTestFirstBuilder) { $scenThr = $thrScenTester }
  if ($OwnScenarioCount -gt $scenThr) { $res += 'Warn'; $why += "$OwnScenarioCount own scenarios, threshold $scenThr" }
  $sizeSentence = "$fileCount owned non-test files (threshold $thrFiles); $OwnScenarioCount own scenarios (threshold $scenThr); $ReviewFocusCount review-focus."
  if ($res.Count -eq 0) { Add-Row 'S8' 'Sizes' 'Pass' $sizeSentence } else { Add-Row 'S8' 'Sizes' 'Warn' ($why -join '; ') }

  # ---------------------------------------------------------------- the ten rows of the task
  # 1 Traceability
  $res = @(); $why = @()
  if ($designText -eq '') { $why += 'no design path given; ids not looked up' }
  else { foreach ($id in $Task.Traces) { if (-not (Test-InDesign $id)) { $res += 'Fail'; $why += "design: id '$id' not found in the design" } } }
  if ($res.Count -eq 0) { $sentence = 'Every traced id is in the design.'; if ($why.Count -gt 0) { $sentence = $why -join '; ' }; Add-Row '1' 'Traceability' 'Pass' $sentence } else { Add-Row '1' 'Traceability' (Worst $res) ($why -join '; ') }

  # 2 Scope
  $res = @(); $why = @()
  $s3 = RowOf 'S3'
  if ($s3.Result -eq 'Fail') { $res += 'Fail'; $why += 'S3 fails' } elseif ($s3.Result -eq 'Flag') { $res += 'Flag'; $why += $s3.Reason }
  $touchesPackages = @(@($Modify) + @($Create) | Where-Object { $_ -match '\.(csproj|props)$|(^|/)package\.json$' }).Count -gt 0
  if ($touchesPackages -and @($Regen).Count -eq 0) {
    $hasLocks = @(Get-RepoFiles | Where-Object { $_ -match '(^|/)(packages\.lock\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml)$' }).Count -gt 0
    if ($hasLocks) { $res += 'Flag'; $why += 'a project or package file is owned, lock files exist in the repo, and regenerates is empty' }
  }
  if ($res.Count -eq 0) { Add-Row '2' 'Scope' 'Pass' 'Owned set resolves; nothing generated listed as hand-edited.' } else { Add-Row '2' 'Scope' (Worst $res) ($why -join '; ') }

  # 3 Interface closure
  $s4 = RowOf 'S4'
  $sentence = "S4 holds; existing code is closed by the repo, never by ${Sym}1."
  if ($s4.Result -ne 'Pass') { $sentence = $s4.Reason }
  Add-Row '3' 'Interface closure' $s4.Result $sentence

  # 4 Behaviour
  $res = @(); $why = @()
  if ($null -ne $NoneLine -and -not $hasScenario) {
    if ($NoneLine -notmatch '(?i)build|command|compile|`') { $res += 'Flag'; $why += 'none: line names no build or command as its check' }
    if ($res.Count -eq 0) { Add-Row '4' 'Behaviour' 'n/a' 'The task states it adds no behaviour and names its check.' } else { Add-Row '4' 'Behaviour' (Worst $res) ($why -join '; ') }
  } else {
    if ($null -ne $AsLine -and $Neighbours.ContainsKey($AsTester)) {
      $tsec2 = Get-Section $Neighbours[$AsTester].Sections 2
      $tCount = 0; if ($null -ne $tsec2) { $tCount = @($tsec2.Lines | Where-Object { $_ -match '^\s*Scenario(?: Outline)?:' }).Count }
      if ($tCount -eq 0) { $res += 'Fail'; $why += "the tester $AsTester's ${Sym}2 holds no Scenario" }
    } elseif ($null -ne $AsLine) { $res += 'Fail'; $why += "the tester $AsTester has no task section" }
    foreach ($g in $Gherkin) {
      $cur = $null; $hasG = $false; $hasW = $false; $hasT = $false
      foreach ($gl in ($g.Lines + @('Scenario: __end__'))) {
        if ($gl -match '^\s*Scenario(?: Outline)?:\s*(.*)$') {
          if ($null -ne $cur) {
            if (-not $hasW -or -not $hasT) { $res += 'Fail'; $why += "'$cur' lacks a When or Then line" }
            elseif (-not $hasG) { $res += 'Flag'; $why += "'$cur' lacks a Given line" }
          }
          $cur = $Matches[1].Trim(); $hasG = $false; $hasW = $false; $hasT = $false; continue
        }
        if ($gl -match '^\s*Given\b') { $hasG = $true }
        if ($gl -match '^\s*When\b') { $hasW = $true }
        if ($gl -match '^\s*Then\b') { $hasT = $true }
      }
    }
    $pinned = 0
    if ($null -ne $plan5) { $pinned = @($plan5.Lines | Where-Object { $_ -match '^\s*[-*]' -and $_ -match ("\b" + [regex]::Escape($TaskId) + "\b") }).Count }
    if ($pinned -gt $ReviewFocusCount) { $res += 'Fail'; $why += "$pinned review-focus lines pinned to $TaskId in ${Sym}5, $ReviewFocusCount @review-focus scenarios here" }
    $s7 = RowOf 'S7'; if ($s7.Result -eq 'Flag' -and $s7.Reason -match 'identifiers') { $res += 'Flag'; $why += 'S7 names unknown identifiers' }
    if ($res.Count -eq 0) { Add-Row '4' 'Behaviour' 'Pass' "Every scenario has Given/When/Then; $ReviewFocusCount review-focus scenario(s) for $pinned pinned line(s)." } else { Add-Row '4' 'Behaviour' (Worst $res) ($why -join '; ') }
  }

  # 5 Done-when
  $res = @(); $why = @()
  foreach ($d in $DoneItems) {
    $hasCode = ($d -match '`[^`]+`')
    $hasResult = ($d -match '(?i)\b(green|red|pass(es)?|fails?|exits?|prints?|returns?|is|are|equals?|contains?|met)\b')
    if (-not $hasCode -or -not $hasResult) { $res += 'Fail'; $why += "no name/command in a code span with a result word: $($d.Trim())" }
  }
  if ($IsBuilder) {
    $testers = $SameStackTesters
    if ($testers.Count -gt 0) {
      $testerNames = @()
      foreach ($tid in $testers) {
        if ($Neighbours.ContainsKey($tid)) {
          $ts3 = Get-Section $Neighbours[$tid].Sections 3
          if ($null -ne $ts3) { foreach ($l in $ts3.Lines) { foreach ($m in [regex]::Matches($l, '`([^`]+)`')) { $testerNames += $m.Groups[1].Value } } }
        }
      }
      $testerNames = @($testerNames | Where-Object { $_ -notmatch '\s' } | Select-Object -Unique)
      $builderNames = @(); foreach ($d in $DoneItems) { foreach ($m in [regex]::Matches($d, '`([^`]+)`')) { if ($m.Groups[1].Value -notmatch '\s') { $builderNames += $m.Groups[1].Value } } }
      $shared = @($builderNames | Where-Object { $testerNames -contains $_ })
      if ($testerNames.Count -gt 0 -and $shared.Count -eq 0) { $res += 'Fail'; $why += "no done-when names a test the tester ($($testers -join ', ')) lists in its ${Sym}3" }
      elseif ($testerNames.Count -eq 0 -and -not (($DoneItems -join ' ') -match ($testers -join '|'))) { $res += 'Flag'; $why += "the tester's ${Sym}3 lists no code-span name to match, and the builder's done-when does not name the tester task" }
    }
  }
  $s7 = RowOf 'S7'; if ($s7.Reason -match 'searches the source') { $res += 'Fail'; $why += 'a done-when searches the source (S7)' }
  if ($res.Count -eq 0) { Add-Row '5' 'Done-when' 'Pass' "$($DoneItems.Count) item(s), each a name or command with a result." } else { Add-Row '5' 'Done-when' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

  # 6 Stops
  $res = @(); $why = @()
  $stopLines = @($Sec4 | Where-Object { $_ -match '(?i)\*\*stops?:?\*\*|^\s*[-*]\s*stops?:' })
  if ($stopLines.Count -eq 0) { Add-Row '6' 'Stops' 'Pass' 'No Stops line; the generic stops hold by the definition.' }
  else {
    foreach ($sl in $stopLines) {
      $generic = ($sl -match '(?i)outside (the|its) owned (set|files)|does not resolve|conflict(s)? with (the )?(design|conventions|neighbour)')
      $specific = ($sl -match '`|\bT\d{3}\b|/|\d')
      if ($generic -and -not $specific) { $res += 'Flag'; $why += "repeats a generic stop: $($sl.Trim())" }
    }
    if ($res.Count -eq 0) { Add-Row '6' 'Stops' 'Pass' "$($stopLines.Count) Stops line(s), each naming something of this task." } else { Add-Row '6' 'Stops' 'Flag' ($why -join '; ') }
  }

  # 7 Boundary
  $res = @(); $why = @()
  if ((RowOf 'S7').Result -eq 'Fail') { $res += 'Fail'; $why += 'S7 fails' }
  foreach ($ml in @($Sec4 | Where-Object { $_ -match '(?i)\*\*must:?\*\*' })) {
    foreach ($m in [regex]::Matches($ml, '`([^`]+)`')) { if ($m.Groups[1].Value -match '^\w+\(.*\)') { $res += 'Fail'; $why += "a must names a call: $($m.Groups[1].Value)" } }
    if ($ml -match '(?i)\b(for|foreach|while) loop\b|\balgorithm\b') { $res += 'Fail'; $why += "a must names how: $($ml.Trim())" }
  }
  for ($i = 0; $i -lt $Body.Count; $i++) {
    if ($LineInFence[$i]) { continue }
    foreach ($m in [regex]::Matches($Body[$i], '`([^`]+)`')) { if ($m.Groups[1].Value -match '^\w[\w<>\[\]]*\s+\w+\s*\(\s*[\w<>\[\]]+\s+\w+') { $res += 'Fail'; $why += "a restated signature: $($m.Groups[1].Value)" } }
  }
  if ($res.Count -eq 0) { Add-Row '7' 'Boundary' 'Pass' 'No body, call, loop or restated signature.' } else { Add-Row '7' 'Boundary' 'Fail' (($why | Select-Object -Unique) -join '; ') }

  # 8 Hygiene
  $res = @(); $why = @()
  foreach ($id in 'S5', 'S6') { $r = RowOf $id; if ($r.Result -eq 'Fail') { $res += 'Fail'; $why += "$id fails" } }
  $runState = '(?i)passes:\s*true|\bclaimed\b|\battempt \d|\bfix round\b|^\s*[-*]\s*\[x\]'
  for ($i = 0; $i -lt $Body.Count; $i++) { if ($Body[$i] -match $runState) { $res += 'Fail'; $why += "run state: $($Body[$i].Trim())" } }
  if ($null -ne $plan4) {
    $planLines = @($plan4.Lines | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Normalize-Line $_ })
    foreach ($l in $Sec4) { $nl = Normalize-Line $l; if ($nl.Length -gt 20 -and $planLines -contains $nl) { $res += 'Flag'; $why += "copies a plan ${Sym}4 line: $($l.Trim())" } }
  }
  if ($res.Count -eq 0) { Add-Row '8' 'Hygiene' 'Pass' 'No placeholder, no run state, no copied routing.' } else { Add-Row '8' 'Hygiene' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

  # 9 Size
  $s8 = RowOf 'S8'
  Add-Row '9' 'Size' $s8.Result $s8.Reason

  # 10 Inheritance
  $res = @(); $why = @()
  if ($null -ne $plan2) {
    $c2 = @($plan2.Lines | Where-Object { $_ -match '^\s*[-*]\s' } | ForEach-Object { (Normalize-Line ($_ -replace ($EmDash + '.*$'), '')) })
    foreach ($l in $Sec4) {
      $nl = Normalize-Line $l
      foreach ($c in $c2) { if ($c.Length -gt 15 -and ($nl -eq $c -or $nl.Contains($c))) { $res += 'Flag'; $why += "restates plan ${Sym}2: $($l.Trim())" } }
    }
  }
  if ($res.Count -eq 0) { Add-Row '10' 'Inheritance' 'Pass' "No ${Sym}4 line restates a plan ${Sym}2 line; a contradiction is the reviewer's to judge." } else { Add-Row '10' 'Inheritance' 'Flag' (($why | Select-Object -Unique) -join '; ') }

  Flush-Rows $TaskId
}

# ================================================================ report

$nFail = 0; $nFlag = 0; $nWarn = 0
foreach ($r in $Report) { if ($r.Result -eq 'Fail') { $nFail++ } elseif ($r.Result -eq 'Flag') { $nFlag++ } elseif ($r.Result -eq 'Warn') { $nWarn++ } }
$relPlan = $Plan -replace '\\', '/'; $rootFs = $RepoRoot -replace '\\', '/'
if ($relPlan.StartsWith($rootFs, [StringComparison]::OrdinalIgnoreCase)) { $relPlan = $relPlan.Substring($rootFs.Length).TrimStart('/') }
$out = New-Object System.Collections.Generic.List[string]
$out.Add('## Validation report')
$out.Add("target: $relPlan")
$out.Add('bar: dispatch-ready')
$out.Add('engine: script (validate-plan.ps1)')
$out.Add('| # | Check | Result | Reason |')
$out.Add('|---|---|---|---|')
foreach ($r in $Report) { $out.Add("| $($r.Id) | $($r.Check) | $($r.Result) | $($r.Reason) |") }
$out.Add('')
$out.Add("summary: $nFail fail $MidDot $nFlag flag $MidDot $nWarn warn $MidDot $($AllTasks.Count) tasks")
Write-Output ($out -join "`n")
exit 0
