<#
.SYNOPSIS
  The shape check of one S102 task spec, as a script.

.DESCRIPTION
  Implements the checklist of skills/artifact-s102-validation/SKILL.md: the eight
  shape rows (S1-S8) and the ten rows of s102-task-spec-definition.md section 8,
  answered from the files' text and from lookups only (a path exists, a name is
  declared in the file the header points at, an id is in the design, a test name
  is in the tester's list, a count is under a threshold). It runs nothing, reads
  no file's logic, and judges no content. Two runs on unchanged files return the
  same report.

  The template is the schema: header keys and section titles are read from
  s102-task-spec-template.md; the size thresholds from the S101 definition
  section 8.1; the role and tier values from the S101 template's leading comment.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike. The source is pure
  ASCII on purpose: 5.1 reads a BOM-less file as ANSI, so the section sign is
  built at run-time ($Sym).

.PARAMETER S102
  Repo-relative or absolute path of the task spec to check.
.PARAMETER S101
  Path of the plan the task spec belongs to.
.PARAMETER Design
  Path of the design (a D101 .html or the normalised design.md cache). Used only
  to look the traced ids up. Optional; row 1 says so when absent.
.PARAMETER PluginRoot
  The plugin root. Defaults to the parent of this script's folder.
.PARAMETER RepoRoot
  The product repo root every repo-relative path resolves against. Defaults to the
  current directory.

.OUTPUTS
  The validation report, as the skill's Report section fixes it, on stdout.
  Exit code 0 when a report was produced, 2 when an input could not be read.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$S102,
  [Parameter(Mandatory = $true)][string]$S101,
  [string]$Design = '',
  [string]$PluginRoot = '',
  [string]$RepoRoot = ''
)

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

if ($PluginRoot -eq '') { $PluginRoot = Split-Path -Parent $PSScriptRoot }
if ($RepoRoot -eq '') { $RepoRoot = (Get-Location).Path }

$Sym = [string][char]0xA7       # the section sign
$EmDash = [string][char]0x2014  # the dash before a constraint's source

# ---------------------------------------------------------------- helpers

function Read-Text([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { throw "cannot read: $Path" }
  $t = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  if ($null -eq $t) { $t = '' }
  return ($t -replace "`r`n", "`n")
}

function Resolve-RepoPath([string]$Rel) {
  if ([System.IO.Path]::IsPathRooted($Rel)) { return $Rel }
  return (Join-Path $RepoRoot $Rel)
}

function Split-Frontmatter([string]$Text) {
  $lines = $Text -split "`n"
  if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return $null }
  $end = -1
  for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $end = $i; break } }
  if ($end -lt 0) { return $null }
  $body = @()
  if ($end + 1 -lt $lines.Count) { $body = $lines[($end + 1)..($lines.Count - 1)] }
  return @{ Front = $lines[1..($end - 1)]; Body = $body }
}

function Strip-Quotes([string]$Value) {
  $v = $Value.Trim()
  if ($v.Length -ge 2 -and (($v[0] -eq '"' -and $v[-1] -eq '"') -or ($v[0] -eq "'" -and $v[-1] -eq "'"))) { return $v.Substring(1, $v.Length - 2) }
  return $v
}

# Splits a YAML flow list "[a, "b (x, y)", c]" on commas outside quotes and parentheses.
function Parse-FlowList([string]$Value) {
  $v = $Value.Trim()
  if ($v.StartsWith('[')) { $v = $v.Substring(1) }
  if ($v.EndsWith(']')) { $v = $v.Substring(0, $v.Length - 1) }
  $items = New-Object System.Collections.Generic.List[string]
  $cur = ''; $depth = 0; $q = $null
  foreach ($ch in $v.ToCharArray()) {
    if ($null -ne $q) { $cur += $ch; if ($ch -eq $q) { $q = $null }; continue }
    if ($ch -eq '"' -or $ch -eq "'") { $q = $ch; $cur += $ch; continue }
    if ($ch -eq '(' -or $ch -eq '[' -or $ch -eq '{') { $depth++ }
    if ($ch -eq ')' -or $ch -eq ']' -or $ch -eq '}') { $depth-- }
    if ($ch -eq ',' -and $depth -eq 0) { if ($cur.Trim() -ne '') { $items.Add((Strip-Quotes $cur)) }; $cur = ''; continue }
    $cur += $ch
  }
  if ($cur.Trim() -ne '') { $items.Add((Strip-Quotes $cur)) }
  return , $items.ToArray()
}

# Parses a flat header with one level of nesting (owns:). Lists in flow form.
function Parse-Header([string[]]$Lines) {
  $h = @{}; $parent = $null
  foreach ($raw in $Lines) {
    if ($raw.Trim() -eq '' -or $raw.Trim().StartsWith('#')) { continue }
    $m = [regex]::Match($raw, '^([A-Za-z_][\w-]*):\s*(.*)$')
    if ($m.Success) {
      $key = $m.Groups[1].Value; $val = $m.Groups[2].Value.Trim()
      if ($val -eq '') { $h[$key] = @{}; $parent = $key }
      elseif ($val.StartsWith('[')) { $h[$key] = (Parse-FlowList $val); $parent = $null }
      elseif ($val.StartsWith('{')) { $h[$key] = $val; $parent = $null }
      else { $h[$key] = (Strip-Quotes $val); $parent = $null }
      continue
    }
    $m2 = [regex]::Match($raw, '^\s+([A-Za-z_][\w-]*):\s*(.*)$')
    if ($m2.Success -and $null -ne $parent) {
      $val = $m2.Groups[2].Value.Trim()
      if ($val.StartsWith('[')) { $h[$parent][$m2.Groups[1].Value] = (Parse-FlowList $val) } else { $h[$parent][$m2.Groups[1].Value] = (Strip-Quotes $val) }
    }
  }
  return $h
}

# The S101 tree: phases and their task lines.
function Parse-Tree([string[]]$Front) {
  $phases = New-Object System.Collections.Generic.List[object]
  $cur = $null; $inPhases = $false
  foreach ($raw in $Front) {
    if ($raw -match '^phases:') { $inPhases = $true; continue }
    if (-not $inPhases) { continue }
    if ($raw -match '^[A-Za-z_]') { $inPhases = $false; continue }
    $m = [regex]::Match($raw, '^\s*-\s*id:\s*(P\d+)\s*$')
    if ($m.Success) {
      $cur = [pscustomobject]@{ Id = $m.Groups[1].Value; Name = ''; Checkpoint = ''; Check = ''; Traces = @(); Tasks = (New-Object System.Collections.Generic.List[object]) }
      $phases.Add($cur); continue
    }
    if ($null -eq $cur) { continue }
    $mt = [regex]::Match($raw, '^\s*-\s*\{(.*)\}\s*$')
    if ($mt.Success) {
      $body = $mt.Groups[1].Value
      $t = [pscustomobject]@{ Id = ''; Title = ''; Role = ''; Tier = ''; After = @(); Traces = @(); Phase = $cur.Id }
      $t.Id = [regex]::Match($body, '\bid:\s*(T\d+)').Groups[1].Value
      $mTitle = [regex]::Match($body, '\btitle:\s*"((?:[^"\\]|\\.)*)"')
      if ($mTitle.Success) { $t.Title = $mTitle.Groups[1].Value } else { $t.Title = [regex]::Match($body, '\btitle:\s*([^,]+)').Groups[1].Value.Trim() }
      $t.Role = [regex]::Match($body, '\brole:\s*([\w-]+)').Groups[1].Value
      $t.Tier = [regex]::Match($body, '\btier:\s*([\w-]+)').Groups[1].Value
      $mA = [regex]::Match($body, '\bafter:\s*\[([^\]]*)\]'); if ($mA.Success) { $t.After = (Parse-FlowList $mA.Groups[1].Value) }
      $mTr = [regex]::Match($body, '\btraces:\s*\[([^\]]*)\]'); if ($mTr.Success) { $t.Traces = (Parse-FlowList $mTr.Groups[1].Value) }
      $cur.Tasks.Add($t); continue
    }
    $mk = [regex]::Match($raw, '^\s+(name|checkpoint|check|traces):\s*(.*)$')
    if ($mk.Success) {
      $v = $mk.Groups[2].Value.Trim()
      switch ($mk.Groups[1].Value) {
        'name' { $cur.Name = (Strip-Quotes $v) }
        'checkpoint' { $cur.Checkpoint = (Strip-Quotes $v) }
        'check' { $cur.Check = (Strip-Quotes $v) }
        'traces' { $cur.Traces = (Parse-FlowList $v) }
      }
    }
  }
  return $phases
}

function Get-Sections([string[]]$Body) {
  $secs = New-Object System.Collections.Generic.List[object]
  $cur = $null
  foreach ($line in $Body) {
    $m = [regex]::Match($line, '^##\s+(\d+)\.\s*(.+?)\s*$')
    if ($m.Success) { $cur = [pscustomobject]@{ Num = [int]$m.Groups[1].Value; Title = $m.Groups[2].Value; Lines = (New-Object System.Collections.Generic.List[string]) }; $secs.Add($cur); continue }
    if ($null -ne $cur) { $cur.Lines.Add($line) }
  }
  return $secs
}

function Get-Section($Sections, [int]$Num) { foreach ($sec in $Sections) { if ($sec.Num -eq $Num) { return $sec } }; return $null }

function Parse-Table([string[]]$Lines) {
  $rows = New-Object System.Collections.Generic.List[object]
  $header = $null
  foreach ($l in $Lines) {
    if (-not ($l.Trim().StartsWith('|'))) { continue }
    $cells = @($l.Trim().Trim('|') -split '\|' | ForEach-Object { $_.Trim() })
    if ($null -eq $header) { $header = $cells; continue }
    if (($cells -join '') -match '^[-: ]+$') { continue }
    $rows.Add([pscustomobject]@{ Cells = $cells })
  }
  return @{ Header = $header; Rows = $rows }
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

function Test-IsGlob([string]$P) { return ($P -match '[\*\?]') }

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

function Expand-Owned([string]$P) {
  if (Test-IsGlob $P) { $rx = Convert-GlobToRegex $P; return @(Get-RepoFiles | Where-Object { $_ -match $rx }) }
  return @($P)
}

function Test-PathMatches([string]$Pattern, [string]$Path) {
  if (Test-IsGlob $Pattern) { return (($Path -replace '\\', '/') -match (Convert-GlobToRegex $Pattern)) }
  return (($Path -replace '\\', '/') -eq ($Pattern -replace '\\', '/'))
}

function Normalize-Line([string]$L) {
  $n = ($L -replace '[`*_]', '') -replace '^\s*[-*]\s*', ''   # markdown emphasis and list markers carry no meaning
  $n = $n -replace '^\s*(must not|must|prefer|stops?)\s*:\s*', ''   # the S102 section 4 labels
  return ($n -replace '\s+', ' ').Trim().ToLowerInvariant()
}

$Rows = New-Object System.Collections.Generic.List[object]
function Add-Row([string]$Id, [string]$Check, [string]$Result, [string]$Reason) {
  $Rows.Add([pscustomobject]@{ Id = $Id; Check = $Check; Result = $Result; Reason = ($Reason -replace '\|', '\|') })
}
function Worst([string[]]$Results) {
  foreach ($r in 'Fail', 'Flag', 'Warn') { if ($Results -contains $r) { return $r } }
  return 'Pass'
}
function RowOf([string]$Id) { foreach ($r in $Rows) { if ($r.Id -eq $Id) { return $r } }; return $null }

# ---------------------------------------------------------------- inputs

try {
  $s102Path = Resolve-RepoPath $S102
  $s101Path = Resolve-RepoPath $S101
  $s102Text = Read-Text $s102Path
  $s101Text = Read-Text $s101Path
  $designText = ''
  if ($Design -ne '') { $designText = Read-Text (Resolve-RepoPath $Design) }
  $tplPath = Join-Path $PluginRoot 'artifacts/documentation/s102-task-spec/s102-task-spec-template.md'
  $s101TplPath = Join-Path $PluginRoot 'artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md'
  $s101DefPath = Join-Path $PluginRoot 'artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md'
  $tplText = Read-Text $tplPath
  # the templates open with an HTML authoring comment; the frontmatter follows it
  $tplText = [regex]::Replace($tplText, '(?s)^\s*<!--.*?-->\s*', '')
  $s101TplText = Read-Text $s101TplPath
  $s101DefText = Read-Text $s101DefPath
} catch {
  Write-Output "validate-s102: $($_.Exception.Message)"
  exit 2
}

$fm = Split-Frontmatter $s102Text
if ($null -eq $fm) { Write-Output "validate-s102: $S102 has no YAML frontmatter between --- lines"; exit 2 }
$pfm = Split-Frontmatter $s101Text
if ($null -eq $pfm) { Write-Output "validate-s102: $S101 has no YAML frontmatter between --- lines"; exit 2 }

$H = Parse-Header $fm.Front
$Body = @($fm.Body)
$Sections = Get-Sections $Body
$Phases = Parse-Tree $pfm.Front
$PlanHeader = Parse-Header $pfm.Front
$PlanSections = Get-Sections @($pfm.Body)

# the template as schema
$tplFm = Split-Frontmatter $tplText
if ($null -eq $tplFm) { Write-Output "validate-s102: the S102 template has no frontmatter: $tplPath"; exit 2 }
$TplKeys = @(); $TplOwnsKeys = @()
foreach ($l in $tplFm.Front) { if ($l -match '^([A-Za-z_][\w-]*):') { $TplKeys += $Matches[1] } elseif ($l -match '^\s+([A-Za-z_][\w-]*):') { $TplOwnsKeys += $Matches[1] } }
$TplSections = @(Get-Sections @($tplFm.Body) | ForEach-Object { $_.Title })
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

# this task's line
$TaskId = ''; if ($H.ContainsKey('task')) { $TaskId = [string]$H['task'] }
$AllTasks = @(); foreach ($ph in $Phases) { foreach ($t in $ph.Tasks) { $AllTasks += $t } }
$Task = $null; foreach ($t in $AllTasks) { if ($t.Id -eq $TaskId) { $Task = $t } }
$TaskById = @{}; foreach ($t in $AllTasks) { $TaskById[$t.Id] = $t }

function Get-Upstream([string]$Id) {
  $seen = @{}; $stack = New-Object System.Collections.Generic.Stack[string]
  if ($TaskById.ContainsKey($Id)) { foreach ($a in $TaskById[$Id].After) { $stack.Push($a) } }
  while ($stack.Count -gt 0) {
    $x = $stack.Pop(); if ($seen.ContainsKey($x)) { continue }; $seen[$x] = $true
    if ($TaskById.ContainsKey($x)) { foreach ($a in $TaskById[$x].After) { $stack.Push($a) } }
  }
  return @($seen.Keys)
}
$Upstream = @(); if ($null -ne $Task) { $Upstream = Get-Upstream $TaskId }

# neighbours' headers
$Folder = Split-Path -Parent $s102Path
$Neighbours = @{}
$selfFull = (Resolve-Path -LiteralPath $s102Path).Path
foreach ($f in Get-ChildItem -LiteralPath $Folder -File -Filter 'S102-*.md' -ErrorAction SilentlyContinue) {
  if ($f.FullName -eq $selfFull) { continue }
  $nfm = Split-Frontmatter (Read-Text $f.FullName)
  if ($null -eq $nfm) { continue }
  $nh = Parse-Header $nfm.Front
  if ($nh.ContainsKey('task')) { $Neighbours[[string]$nh['task']] = @{ Header = $nh; Sections = (Get-Sections @($nfm.Body)); Path = $f.FullName } }
}

function Owns([string]$List) {
  if ($H.ContainsKey('owns') -and ($H['owns'] -is [hashtable]) -and $H['owns'].ContainsKey($List)) {
    $v = $H['owns'][$List]
    if ($v -is [array]) { return @($v) } elseif ([string]$v -eq '') { return @() } else { return @([string]$v) }
  }
  return @()
}
$Create = Owns 'create'; $Modify = Owns 'modify'; $TestFiles = Owns 'test'; $Regen = Owns 'regenerates'
$Consumes = @(); if ($H.ContainsKey('consumes') -and $H['consumes'] -is [array]) { $Consumes = @($H['consumes']) }
$Produces = @(); if ($H.ContainsKey('produces') -and $H['produces'] -is [array]) { $Produces = @($H['produces']) }
$Status = ''; if ($H.ContainsKey('status')) { $Status = [string]$H['status'] }
$Role = ''; if ($H.ContainsKey('role')) { $Role = [string]$H['role'] }
$IsTester = ($Role -match 'tester'); $IsBuilder = ($Role -match 'builder')

# S101 section 1 contracts: name -> producer task ids
$Contracts = @{}
$plan1 = Get-Section $PlanSections 1
$ContractsHasConsumedBy = $false
if ($null -ne $plan1) {
  $tbl = Parse-Table @($plan1.Lines)
  if ($null -ne $tbl.Header) {
    $iName = 0; $iProd = -1
    for ($i = 0; $i -lt $tbl.Header.Count; $i++) {
      if ($tbl.Header[$i] -match '(?i)^name$') { $iName = $i }
      if ($tbl.Header[$i] -match '(?i)produced') { $iProd = $i }
      if ($tbl.Header[$i] -match '(?i)consumed') { $ContractsHasConsumedBy = $true }
    }
    foreach ($r in $tbl.Rows) {
      if ($r.Cells.Count -le $iName) { continue }
      $nm = ($r.Cells[$iName] -replace '`', '').Trim()
      if ($nm -eq '' -or $nm -match '^<') { continue }
      $prod = ''; if ($iProd -ge 0 -and $r.Cells.Count -gt $iProd) { $prod = $r.Cells[$iProd] }
      $Contracts[$nm] = @($prod -split '[,\s]+' | Where-Object { $_ -match '^T\d+$' })
    }
  }
}

# fences and gherkin
$Fences = New-Object System.Collections.Generic.List[object]
$inFence = $false; $fenceLang = ''; $fenceLines = $null
$LineInFence = New-Object 'bool[]' $Body.Count
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

function Section-Text([int]$n) { $sec = Get-Section $Sections $n; if ($null -eq $sec) { return @() }; return @($sec.Lines) }
$Sec2 = Section-Text 2; $Sec3 = Section-Text 3; $Sec4 = Section-Text 4
$NoneLine = @($Sec2 | Where-Object { $_ -match '^\s*(?:[-*]\s*)?none:' }) | Select-Object -First 1
$AsLine = @($Sec2 | Where-Object { $_ -match '^\s*(?:[-*]\s*)?as\s+(T\d+):' }) | Select-Object -First 1
$AsTester = ''; if ($null -ne $AsLine -and $AsLine -match 'as\s+(T\d+):') { $AsTester = $Matches[1] }
$DoneItems = @($Sec3 | Where-Object { $_ -match '^\s*\d+\.\s' })

# ---------------------------------------------------------------- S1 header fields

$res = @(); $why = @()
$failKeys = @('s101', 'task', 'role', 'after', 'traces', 'consumes', 'produces')
foreach ($k in $TplKeys) {
  if ($k -eq 'owns') {
    if (-not $H.ContainsKey('owns') -or -not ($H['owns'] -is [hashtable])) { $res += 'Fail'; $why += 'owns missing'; continue }
    foreach ($ok in $TplOwnsKeys) {
      if (-not $H['owns'].ContainsKey($ok)) { if ($ok -eq 'regenerates') { $res += 'Flag'; $why += 'owns.regenerates missing (reads as empty)' } else { $res += 'Fail'; $why += "owns.$ok missing" } }
    }
    continue
  }
  if (-not $H.ContainsKey($k)) { if ($failKeys -contains $k) { $res += 'Fail'; $why += "$k missing" } else { $res += 'Flag'; $why += "$k missing" } }
}
foreach ($k in $H.Keys) { if ($TplKeys -notcontains $k) { $res += 'Flag'; $why += "extra key $k" } }
if ($Role -ne '' -and $Roles -notcontains $Role) { $res += 'Fail'; $why += "role '$Role' not in [$($Roles -join ', ')]" }
if ($H.ContainsKey('tier') -and $Tiers -notcontains [string]$H['tier']) { $res += 'Fail'; $why += "tier '$($H['tier'])' not in [$($Tiers -join ', ')]" }
if ($Status -ne '' -and @('draft', 'validated', 'done') -notcontains $Status) { $res += 'Flag'; $why += "status '$Status'" }
if ($H.ContainsKey('validated')) {
  $v = [string]$H['validated']
  if ($v -ne 'none' -and $v -notmatch '^\d{4}-\d{2}-\d{2}$') { $res += 'Flag'; $why += "validated '$v' is neither none nor a date" }
  elseif ($v -ne 'none' -and $Status -eq 'draft') { $res += 'Flag'; $why += 'validated carries a date while status is draft (leftover)' }
}
if ($res.Count -eq 0) { Add-Row 'S1' 'Header fields' 'Pass' 'Every template key present with a listed value.' } else { Add-Row 'S1' 'Header fields' (Worst $res) ($why -join '; ') }

# ---------------------------------------------------------------- S2 header equals task line

if ($null -eq $Task) { Add-Row 'S2' 'Header equals task line' 'Fail' "S101: no task $TaskId in the S101 tree." }
else {
  $res = @(); $why = @()
  if ($H.ContainsKey('title') -and ([string]$H['title']).Trim() -ne $Task.Title.Trim()) { $res += 'Flag'; $why += 'title differs from the task line' }
  if ($Role -ne $Task.Role) { $res += 'Fail'; $why += "role '$Role' vs task line '$($Task.Role)'" }
  if ($H.ContainsKey('tier') -and [string]$H['tier'] -ne $Task.Tier) { $res += 'Flag'; $why += 'tier differs from the task line' }
  $hAfter = @(); if ($H.ContainsKey('after') -and $H['after'] -is [array]) { $hAfter = @($H['after']) }
  if (@(Compare-Object @($hAfter | Sort-Object) @($Task.After | Sort-Object)).Count -gt 0) { $res += 'Fail'; $why += "after [$($hAfter -join ', ')] vs task line [$($Task.After -join ', ')]" }
  $hTr = @(); if ($H.ContainsKey('traces') -and $H['traces'] -is [array]) { $hTr = @($H['traces']) }
  if (@(Compare-Object @($hTr | Sort-Object) @($Task.Traces | Sort-Object)).Count -gt 0) { $res += 'Fail'; $why += "traces [$($hTr -join ', ')] vs task line [$($Task.Traces -join ', ')]" }
  if ($res.Count -eq 0) { Add-Row 'S2' 'Header equals task line' 'Pass' "Equal to the $TaskId line." } else { Add-Row 'S2' 'Header equals task line' (Worst $res) ($why -join '; ') }
}

# ---------------------------------------------------------------- S3 paths resolve

$res = @(); $why = @()
$GeneratedRx = '(?i)(^|/)(packages\.lock\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml)$|\.lock\.json$|\.snap$|\.g\.cs$|\.generated\.|(^|/)(Generated|obj)/'
$UpstreamCreates = @()
foreach ($u in $Upstream) {
  if ($Neighbours.ContainsKey($u)) {
    $nh = $Neighbours[$u].Header
    if ($nh.ContainsKey('owns') -and $nh['owns'] -is [hashtable] -and $nh['owns'].ContainsKey('create') -and $nh['owns']['create'] -is [array]) { $UpstreamCreates += @($nh['owns']['create']) }
  }
}
function Created-Upstream([string]$P) { foreach ($c in $UpstreamCreates) { if (Test-PathMatches $c $P) { return $true } }; return $false }
foreach ($p in $Modify) {
  if (Test-IsGlob $p) { if ((Expand-Owned $p).Count -eq 0 -and -not (Created-Upstream $p)) { $res += 'Flag'; $why += "modify glob '$p' matches nothing today" } }
  elseif (-not (Test-Path -LiteralPath (Resolve-RepoPath $p)) -and -not (Created-Upstream $p)) { $res += 'Fail'; $why += "modify path '$p' does not exist and no upstream task creates it" }
  if ($p -match $GeneratedRx) { $res += 'Flag'; $why += "'$p' looks generated; it belongs under regenerates" }
  if ($p -match '(?i)(^|/)[^/]*tests?[^/]*\.(cs|ts|js)$|(^|/)tests?/') { $res += 'Flag'; $why += "'$p' is a test file listed under modify; it belongs under test" }
}
foreach ($p in $Create) {
  if (-not (Test-IsGlob $p) -and ($Status -eq 'draft' -or $Status -eq 'validated') -and (Test-Path -LiteralPath (Resolve-RepoPath $p))) { $res += 'Fail'; $why += "create path '$p' already exists" }
  if ($p -match $GeneratedRx) { $res += 'Flag'; $why += "'$p' looks generated; it belongs under regenerates" }
}
foreach ($p in $TestFiles) { if ($p -match $GeneratedRx) { $res += 'Flag'; $why += "'$p' looks generated; it belongs under regenerates" } }
$all = @($Create) + @($Modify) + @($TestFiles) + @($Regen)
$dups = @($all | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
foreach ($d in $dups) { $res += 'Fail'; $why += "'$d' appears in two owns lists" }
# body paths
$SrcExt = '\.(cs|ts|tsx|js|html|scss|css|csproj|props|targets|json|md|sql|ya?ml|xml|config|razor|cshtml)'
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
    if (-not $ok) { $res += 'Fail'; $why += "body path '$bp' is neither owned nor existing" }
  }
}
if ($res.Count -eq 0) { Add-Row 'S3' 'Paths resolve' 'Pass' 'Every owned path exists, is created upstream, or is new under test.' } else { Add-Row 'S3' 'Paths resolve' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

# ---------------------------------------------------------------- S4 names in the contracts

$res = @(); $why = @()
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
      if ($producers.Count -gt 0 -and $upstreamProducer.Count -eq 0) { $res += 'Fail'; $why += "S101: '$nm' is produced by $($producers -join '/') which $TaskId does not come after" }
    } else { $res += 'Fail'; $why += "'$nm' is in no S101 ${Sym}1 row and carries no path or package" }
  }
  if ($nm -match '(?i)tests?$|^.*Test[A-Z]') { $res += 'Flag'; $why += "'$nm' looks like a test name; a test is named in the done-when, never consumed" }
}
foreach ($p in $Produces) {
  if (-not $Contracts.ContainsKey($p)) { $res += 'Fail'; $why += "S101: produced '$p' has no ${Sym}1 row" }
  elseif ($Contracts[$p].Count -gt 0 -and $Contracts[$p] -notcontains $TaskId) { $res += 'Fail'; $why += "S101: ${Sym}1 names $($Contracts[$p] -join '/') as producer of '$p', not $TaskId" }
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
for ($n = 1; $n -le $TplSections.Count; $n++) {
  $sec = Get-Section $Sections $n
  if ($null -eq $sec) { $res += 'Fail'; $why += "${Sym}$n missing" }
}
$order = @($Sections | ForEach-Object { $_.Num })
$sorted = @($order | Sort-Object)
if (@(Compare-Object $order $sorted -SyncWindow 0).Count -gt 0) { $res += 'Fail'; $why += "sections out of the template's order" }
$hasScenario = ($ScenarioLines.Count -gt 0)
if (-not $hasScenario -and $null -eq $NoneLine -and $null -eq $AsLine) { $res += 'Fail'; $why += "${Sym}2 holds no gherkin Scenario, no none: line and no as T<nnn>: line" }
if ($null -ne $AsLine) {
  if (-not $IsBuilder) { $res += 'Flag'; $why += 'as T<nnn>: line on a non-builder task' }
  $tt = $null; if ($TaskById.ContainsKey($AsTester)) { $tt = $TaskById[$AsTester] }
  if ($null -eq $tt -or $tt.Role -notmatch 'tester' -or $null -eq $Task -or $tt.Phase -ne $Task.Phase -or $Upstream -notcontains $AsTester) { $res += 'Fail'; $why += "as $AsTester`: names no tester task in the same phase that $TaskId comes after" }
}
if ($DoneItems.Count -eq 0) { $res += 'Fail'; $why += "${Sym}3 holds no numbered item" }
if ($res.Count -eq 0) { Add-Row 'S6' 'Sections' 'Pass' "${Sym}1-${Sym}$($TplSections.Count) present in order; ${Sym}2 and ${Sym}3 hold content." } else { Add-Row 'S6' 'Sections' (Worst $res) ($why -join '; ') }

# ---------------------------------------------------------------- S7 boundary tokens

$res = @(); $why = @()
foreach ($fc in $Fences) { if ($fc.Lang -ne 'gherkin') { $res += 'Fail'; $why += "a fenced block of language '$($fc.Lang)'" } }
for ($i = 0; $i -lt $Body.Count - 1; $i++) { if ($Body[$i] -match '(?i)^\s*(#+\s*)?\**steps\**\s*:?\s*$' -and $Body[$i + 1] -match '^\s*(\d+\.|[-*])\s') { $res += 'Fail'; $why += 'a list under a Steps heading' } }
foreach ($sl in $ScenarioLines) { if ($sl -match "(?:[\w.-]+/)+[\w.-]+$SrcExt") { $res += 'Fail'; $why += "a Scenario names a path: $($sl.Trim())" } }
foreach ($d in $DoneItems) { if ($d -match '(?i)\b(grep|rg|Select-String|findstr)\b') { $res += 'Fail'; $why += "a done-when searches the source: $($d.Trim())" } }
# identifiers in gherkin against section 1, consumes, produces, design, consumed paths
$known = @($Contracts.Keys) + @($ConsumedNames) + @($Produces)
$knownShort = @($known | ForEach-Object { ($_ -split '\.')[-1] })
$unknown = @()
foreach ($g in $Gherkin) {
  foreach ($gl in $g.Lines) {
    foreach ($m in [regex]::Matches($gl, '\b[A-Z][a-z0-9]+(?:[A-Z][a-z0-9]+)+\b|\b[A-Za-z_]\w*\.[A-Z]\w*(?:\.\w+)*\b')) {
      $idn = $m.Value; $short = ($idn -split '\.')[-1]
      if ($knownShort -contains $short) { continue }
      if ($designText -ne '' -and $designText -match ("\b" + [regex]::Escape($short) + "\b")) { continue }
      $found = $false
      foreach ($cp in $ConsumedPaths) { if (Test-NameDeclared $short $cp) { $found = $true; break } }
      if (-not $found) { $unknown += $idn }
    }
  }
}
$unknown = @($unknown | Select-Object -Unique)
if ($unknown.Count -gt 0) { $res += 'Flag'; $why += "identifiers in scenarios found in no ${Sym}1 row, header entry, design or consumed path: $($unknown -join ', ')" }
if ($res.Count -eq 0) { Add-Row 'S7' 'Boundary tokens' 'Pass' 'Gherkin only; no steps list; no path in a scenario; no search in a done-when.' } else { Add-Row 'S7' 'Boundary tokens' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

# ---------------------------------------------------------------- S8 sizes

$res = @(); $why = @()
$fileCount = @($Create).Count + @($Modify).Count
if ($fileCount -gt $thrFiles) { $res += 'Warn'; $why += "$fileCount owned non-test files, threshold $thrFiles" }
$scenThr = $thrScen; if ($IsTester) { $scenThr = $thrScenTester }
if ($OwnScenarioCount -gt $scenThr) { $res += 'Warn'; $why += "$OwnScenarioCount own scenarios, threshold $scenThr" }
$sizeSentence = "$fileCount owned non-test files (threshold $thrFiles); $OwnScenarioCount own scenarios (threshold $scenThr); $ReviewFocusCount review-focus."
if ($res.Count -eq 0) { Add-Row 'S8' 'Sizes' 'Pass' $sizeSentence } else { Add-Row 'S8' 'Sizes' 'Warn' ($why -join '; ') }

# ---------------------------------------------------------------- the ten rows

# 1 Traceability
$res = @(); $why = @()
if ((RowOf 'S2').Result -eq 'Fail') { $res += 'Fail'; $why += 'S2 fails' }
if ($designText -eq '') { $why += 'no design path given; ids not looked up' }
else {
  $hTr = @(); if ($H.ContainsKey('traces') -and $H['traces'] -is [array]) { $hTr = @($H['traces']) }
  foreach ($id in $hTr) {
    $pat = [regex]::Escape($id)
    if ($id -match '^[A-Za-z]') { $pat = "\b$pat\b" }
    if (-not ($designText -match $pat)) { $res += 'Fail'; $why += "design: id '$id' not found in the design" }
  }
}
if ($res.Count -eq 0) {
  $sentence = 'Header equals the task line and every traced id is in the design.'
  if ($why.Count -gt 0) { $sentence = $why -join '; ' }
  Add-Row '1' 'Traceability' 'Pass' $sentence
} else { Add-Row '1' 'Traceability' (Worst $res) ($why -join '; ') }

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
  } elseif ($null -ne $AsLine) { $res += 'Fail'; $why += "the tester $AsTester's S102 is not on disk" }
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
  # review-focus pins
  $plan5 = Get-Section $PlanSections 5
  $pinned = 0
  if ($null -ne $plan5) { $pinned = @($plan5.Lines | Where-Object { $_ -match '^\s*[-*]' -and $_ -match ("\b" + [regex]::Escape($TaskId) + "\b") }).Count }
  if ($pinned -gt $ReviewFocusCount) { $res += 'Fail'; $why += "$pinned review-focus lines pinned to $TaskId in S101 ${Sym}5, $ReviewFocusCount @review-focus scenarios here" }
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
if ($IsBuilder -and $null -ne $Task) {
  $testers = @($Task.After | Where-Object { $TaskById.ContainsKey($_) -and $TaskById[$_].Role -match 'tester' -and $TaskById[$_].Phase -eq $Task.Phase })
  if ($testers.Count -gt 0) {
    $testerNames = @()
    foreach ($tid in $testers) {
      if ($Neighbours.ContainsKey($tid)) {
        $ts3 = Get-Section $Neighbours[$tid].Sections 3
        if ($null -ne $ts3) { foreach ($l in $ts3.Lines) { foreach ($m in [regex]::Matches($l, '`([^`]+)`')) { $testerNames += $m.Groups[1].Value } } }
      }
    }
    $testerNames = @($testerNames | Select-Object -Unique)
    $builderNames = @(); foreach ($d in $DoneItems) { foreach ($m in [regex]::Matches($d, '`([^`]+)`')) { $builderNames += $m.Groups[1].Value } }
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
$plan4 = Get-Section $PlanSections 4
if ($null -ne $plan4) {
  $planLines = @($plan4.Lines | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Normalize-Line $_ })
  foreach ($l in $Sec4) { $nl = Normalize-Line $l; if ($nl.Length -gt 20 -and $planLines -contains $nl) { $res += 'Flag'; $why += "copies an S101 ${Sym}4 line: $($l.Trim())" } }
}
if ($res.Count -eq 0) { Add-Row '8' 'Hygiene' 'Pass' 'No placeholder, no run state, no copied routing (header fields copied from the task line are not restatement).' } else { Add-Row '8' 'Hygiene' (Worst $res) (($why | Select-Object -Unique) -join '; ') }

# 9 Size
$s8 = RowOf 'S8'
Add-Row '9' 'Size' $s8.Result $s8.Reason

# 10 Inheritance
$res = @(); $why = @()
$plan2 = Get-Section $PlanSections 2
if ($null -ne $plan2) {
  $c2 = @($plan2.Lines | Where-Object { $_ -match '^\s*[-*]\s' } | ForEach-Object { (Normalize-Line ($_ -replace ($EmDash + '.*$'), '')) })
  foreach ($l in $Sec4) {
    $nl = Normalize-Line $l
    foreach ($c in $c2) { if ($c.Length -gt 15 -and ($nl -eq $c -or $nl.Contains($c))) { $res += 'Flag'; $why += "restates S101 ${Sym}2: $($l.Trim())" } }
  }
}
if ($res.Count -eq 0) { Add-Row '10' 'Inheritance' 'Pass' "No ${Sym}4 line restates an S101 ${Sym}2 line; a contradiction is the reviewer's to judge." } else { Add-Row '10' 'Inheritance' 'Flag' (($why | Select-Object -Unique) -join '; ') }

# ---------------------------------------------------------------- report

$out = New-Object System.Collections.Generic.List[string]
$out.Add('## Validation report')
$out.Add("target: $S102")
$out.Add('bar: buildable-blind (shape)')
$out.Add('blind: true')
$out.Add('engine: script (validate-s102.ps1)')
$out.Add('| # | Check | Result | Reason |')
$out.Add('|---|---|---|---|')
foreach ($r in $Rows) { $out.Add("| $($r.Id) | $($r.Check) | $($r.Result) | $($r.Reason) |") }
if ($ContractsHasConsumedBy) { $out.Add(''); $out.Add('template findings:'); $out.Add("- S101 ${Sym}1 still carries a *Consumed by* column; the S102 header is the only home of consumption, and the column is not read.") }
Write-Output ($out -join "`n")
exit 0
