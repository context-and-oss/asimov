<#
.SYNOPSIS
  The plan check of one S101 implementation plan, as a script.

.DESCRIPTION
  Implements the checklist of skills/artifact-s101-validation/SKILL.md: the nine
  graph rows (G1-G9), the four cross-file rows (F2-F5, full mode) and the ten rows
  of s101-implementation-plan-definition.md section 8, answered by enumeration
  from the files' text and from lookups only (an id is in the design, a path
  exists, a package is referenced, a file is on disk, two owned sets intersect).
  It runs nothing, reads no file's logic, and judges no content. Two runs on
  unchanged files return the same report.

  The S101 template is the schema: its frontmatter keys, the role and tier values
  in its leading comment and its section titles are read from
  s101-implementation-plan-template.md; the size thresholds from the S101
  definition section 8.1. The design's ids are read from a D101 (.html: the
  spans of class "id" and "ac-id") or from the normalised design cache (.md: the
  numbered items).

  Written for Windows PowerShell 5.1 and PowerShell 7 alike. The source is pure
  ASCII on purpose: 5.1 reads a BOM-less file as ANSI, so the section sign and
  the arrows are built at run-time.

.PARAMETER S101
  Repo-relative or absolute path of the plan to check.
.PARAMETER Design
  Path of the design (a D101 .html or the normalised design.md cache). When
  omitted it is taken from the plan's design line: the cache when the line has
  one, else the ref when it is a file in the repo.
.PARAMETER Mode
  graph-only, full, or auto (the default): auto is full when every task's S102 is
  on disk, else graph-only.
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
  [Parameter(Mandatory = $true)][string]$S101,
  [string]$Design = '',
  [ValidateSet('auto', 'graph-only', 'full')][string]$Mode = 'auto',
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
$Arrow = [string][char]0x2192   # the arrow in a review-focus line

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

# A flow mapping "{ a: x, b: "y" }" as a hashtable of strings.
function Parse-FlowMap([string]$Value) {
  $h = @{}
  if ($null -eq $Value) { return $h }
  $v = $Value.Trim()
  if (-not $v.StartsWith('{')) { return $h }
  $v = $v.Substring(1); if ($v.EndsWith('}')) { $v = $v.Substring(0, $v.Length - 1) }
  foreach ($item in (Parse-FlowList ('[' + $v + ']'))) {
    $m = [regex]::Match($item, '^\s*([\w-]+)\s*:\s*(.*)$')
    if ($m.Success) { $h[$m.Groups[1].Value] = (Strip-Quotes $m.Groups[2].Value) }
  }
  return $h
}

# The S101 tree: phases and their task lines, with the raw text and the keys each carries.
function Parse-Tree([string[]]$Front) {
  $phases = New-Object System.Collections.Generic.List[object]
  $cur = $null; $inPhases = $false; $sawPhasesKey = $false
  foreach ($raw in $Front) {
    if ($raw -match '^phases:') { $inPhases = $true; $sawPhasesKey = $true; continue }
    if (-not $inPhases) { continue }
    if ($raw -match '^[A-Za-z_]') { $inPhases = $false; continue }
    $m = [regex]::Match($raw, '^\s*-\s*id:\s*(P\d+)\s*$')
    if ($m.Success) {
      $cur = [pscustomobject]@{ Id = $m.Groups[1].Value; Name = ''; Checkpoint = ''; Check = ''; Traces = @(); HasTraces = $false; Keys = @('id'); Tasks = (New-Object System.Collections.Generic.List[object]) }
      $phases.Add($cur); continue
    }
    if ($null -eq $cur) { continue }
    $mt = [regex]::Match($raw, '^\s*-\s*\{(.*)\}\s*$')
    if ($mt.Success) {
      $body = $mt.Groups[1].Value
      $t = [pscustomobject]@{ Id = ''; Title = ''; Role = ''; Tier = ''; After = @(); Traces = @(); Phase = $cur.Id; Keys = @(); Raw = $body }
      $t.Keys = @([regex]::Matches($body, '(?:^|[,{])\s*([A-Za-z_][\w-]*)\s*:') | ForEach-Object { $_.Groups[1].Value })
      $t.Id = [regex]::Match($body, '\bid:\s*(T\d+)').Groups[1].Value
      $mTitle = [regex]::Match($body, '\btitle:\s*"((?:[^"\\]|\\.)*)"')
      if ($mTitle.Success) { $t.Title = $mTitle.Groups[1].Value } else { $t.Title = [regex]::Match($body, '\btitle:\s*([^,]+)').Groups[1].Value.Trim() }
      $t.Role = [regex]::Match($body, '\brole:\s*([\w-]+)').Groups[1].Value
      $t.Tier = [regex]::Match($body, '\btier:\s*([\w-]+)').Groups[1].Value
      $mA = [regex]::Match($body, '\bafter:\s*\[([^\]]*)\]'); if ($mA.Success) { $t.After = (Parse-FlowList $mA.Groups[1].Value) }
      $mTr = [regex]::Match($body, '\btraces:\s*\[([^\]]*)\]'); if ($mTr.Success) { $t.Traces = (Parse-FlowList $mTr.Groups[1].Value) }
      $cur.Tasks.Add($t); continue
    }
    $mk = [regex]::Match($raw, '^\s+(name|checkpoint|check|traces|tasks):\s*(.*)$')
    if ($mk.Success) {
      $v = $mk.Groups[2].Value.Trim()
      $cur.Keys += $mk.Groups[1].Value
      switch ($mk.Groups[1].Value) {
        'name' { $cur.Name = (Strip-Quotes $v) }
        'checkpoint' { $cur.Checkpoint = (Strip-Quotes $v) }
        'check' { $cur.Check = (Strip-Quotes $v) }
        'traces' { $cur.Traces = (Parse-FlowList $v); $cur.HasTraces = $true }
      }
    }
  }
  return @{ Phases = $phases; SawKey = $sawPhasesKey }
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
  $n = ($L -replace '[`*_]', '') -replace '^\s*[-*]\s*', ''
  $n = $n -replace '^\s*(must not|must|prefer|stops?)\s*:\s*', ''
  return ($n -replace '\s+', ' ').Trim().ToLowerInvariant()
}

# A constraint line without its source: the text before the dash (em dash, or " - ").
function Constraint-Subject([string]$L) {
  $n = Normalize-Line $L
  $idx = $n.IndexOf($EmDash)
  if ($idx -ge 0) { $n = $n.Substring(0, $idx) }
  else { $idx2 = $n.IndexOf(' - '); if ($idx2 -ge 0) { $n = $n.Substring(0, $idx2) } }
  return $n.Trim()
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
function Finish-Row([string]$Id, [string]$Check, [string[]]$Res, [string[]]$Why, [string]$PassSentence) {
  if ($Res.Count -eq 0) {
    $sentence = $PassSentence
    if ($Why.Count -gt 0) { $sentence = ($Why | Select-Object -Unique) -join '; ' }
    Add-Row $Id $Check 'Pass' $sentence
  } else { Add-Row $Id $Check (Worst $Res) (($Why | Select-Object -Unique) -join '; ') }
}

# ---------------------------------------------------------------- inputs

try {
  $s101Path = Resolve-RepoPath $S101
  $s101Text = Read-Text $s101Path
  $tplPath = Join-Path $PluginRoot 'artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md'
  $defPath = Join-Path $PluginRoot 'artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md'
  $tplText = Read-Text $tplPath
  $tplBody = [regex]::Replace($tplText, '(?s)^\s*<!--.*?-->\s*', '')
  $defText = Read-Text $defPath
} catch {
  Write-Output "validate-s101: $($_.Exception.Message)"
  exit 2
}

$pfm = Split-Frontmatter $s101Text
if ($null -eq $pfm) { Write-Output "validate-s101: $S101 has no YAML frontmatter between --- lines"; exit 2 }
$H = Parse-Header $pfm.Front
$Body = @($pfm.Body)
$Sections = Get-Sections $Body
$treeInfo = Parse-Tree $pfm.Front
$Phases = $treeInfo.Phases
$Folder = Split-Path -Parent $s101Path

# the template as schema
$tplFm = Split-Frontmatter $tplBody
if ($null -eq $tplFm) { Write-Output "validate-s101: the S101 template has no frontmatter: $tplPath"; exit 2 }
$TplKeys = @(); foreach ($l in $tplFm.Front) { if ($l -match '^([A-Za-z_][\w-]*):') { $TplKeys += $Matches[1] } }
$TplSections = @(Get-Sections @($tplFm.Body) | ForEach-Object { $_.Title })
$Roles = @('dotnet-builder', 'angular-builder', 'dotnet-tester', 'human')
$mRoles = [regex]::Match($tplText, 'role:\s*([a-z-]+(?:\s*\|\s*[a-z-]+)+)')
if ($mRoles.Success) { $Roles = @($mRoles.Groups[1].Value -split '\|' | ForEach-Object { $_.Trim() }) }
$Tiers = @('low', 'mid', 'high')
$mTiers = [regex]::Match($tplText, 'tier:\s*(low\s*\|\s*mid\s*\|\s*high)')
if ($mTiers.Success) { $Tiers = @($mTiers.Groups[1].Value -split '\|' | ForEach-Object { $_.Trim() }) }
$thrFiles = 3
if ($defText -match 'owned_non_test_files:\s*(\d+)') { $thrFiles = [int]$Matches[1] }

# the design line and the design
$DesignMap = @{}
if ($H.ContainsKey('design')) { $DesignMap = Parse-FlowMap ([string]$H['design']) }
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

# the design's ids: R, NF, AC (required coverage) and OOS (trace target only)
$DesignIds = @()
if ($designText -ne '') {
  if ($IsHtmlDesign) {
    foreach ($m in [regex]::Matches($designText, 'class="(?:id|ac-id)"[^>]*>\s*((?:R|NF|AC|OOS)\d+)\s*<')) { $DesignIds += $m.Groups[1].Value }
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

# tasks
$AllTasks = @(); foreach ($ph in $Phases) { foreach ($t in $ph.Tasks) { $AllTasks += $t } }
$TaskById = @{}; foreach ($t in $AllTasks) { if ($t.Id -ne '' -and -not $TaskById.ContainsKey($t.Id)) { $TaskById[$t.Id] = $t } }
$PhaseById = @{}; foreach ($ph in $Phases) { $PhaseById[$ph.Id] = $ph }

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

# S102 files on disk
$Slug = ''; if ($H.ContainsKey('slug')) { $Slug = [string]$H['slug'] }
$S102Files = @(Get-ChildItem -LiteralPath $Folder -File -Filter 'S102-*.md' -ErrorAction SilentlyContinue)
$FilesByNum = @{}
foreach ($f in $S102Files) {
  $mn = [regex]::Match($f.Name, '^S102-.+-(\d{3})-[^/\\]+\.md$')
  if ($mn.Success) { $n = $mn.Groups[1].Value; if (-not $FilesByNum.ContainsKey($n)) { $FilesByNum[$n] = @() }; $FilesByNum[$n] += $f.FullName }
}
function Task-Num([string]$Id) { return ([regex]::Match($Id, '\d+').Value).PadLeft(3, '0') }
$Specs = @{}
foreach ($t in $AllTasks) {
  if ($t.Id -eq '') { continue }
  $n = Task-Num $t.Id
  if ($FilesByNum.ContainsKey($n) -and $FilesByNum[$n].Count -eq 1) {
    $sfm = Split-Frontmatter (Read-Text $FilesByNum[$n][0])
    if ($null -ne $sfm) { $Specs[$t.Id] = @{ Header = (Parse-Header $sfm.Front); Sections = (Get-Sections @($sfm.Body)); Body = @($sfm.Body); Path = $FilesByNum[$n][0] } }
  }
}
$MissingSpecs = @($AllTasks | Where-Object { $_.Id -ne '' -and -not $Specs.ContainsKey($_.Id) } | ForEach-Object { $_.Id })
$EffectiveMode = $Mode
if ($Mode -eq 'auto') { if ($AllTasks.Count -gt 0 -and $MissingSpecs.Count -eq 0) { $EffectiveMode = 'full' } else { $EffectiveMode = 'graph-only' } }
if ($EffectiveMode -eq 'full' -and $MissingSpecs.Count -gt 0) { $EffectiveMode = 'full' }  # G9 fails on the missing ones
$Full = ($EffectiveMode -eq 'full')

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
$plan1 = Get-Section $Sections 1
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

# ---------------------------------------------------------------- G1 frontmatter

$res = @(); $why = @()
if (-not $treeInfo.SawKey) { $res += 'Fail'; $why += 'no phases: key in the frontmatter' }
elseif ($Phases.Count -eq 0) { $res += 'Fail'; $why += 'phases: holds no phase (- id: Pn)' }
foreach ($k in $TplKeys) { if (-not $H.ContainsKey($k)) { $res += 'Fail'; $why += "key '$k' missing" } }
if ($H.ContainsKey('design')) {
  if ($DesignMap.Count -eq 0) { $res += 'Fail'; $why += 'design is not a flow mapping { ref: ..., ... }' }
  elseif (-not $DesignMap.ContainsKey('ref')) { $res += 'Fail'; $why += 'design has no ref' }
  elseif ($IsNormalised) {
    foreach ($dk in 'read', 'cache') { if (-not $DesignMap.ContainsKey($dk)) { $res += 'Fail'; $why += "design (normalised) has no $dk" } }
    if (-not $DesignMap.ContainsKey('approval')) { $res += 'Flag'; $why += 'design (normalised) has no approval mark' }
    elseif (@('verified', 'unverified') -notcontains $DesignMap['approval']) { $res += 'Flag'; $why += "design.approval '$($DesignMap['approval'])' is neither verified nor unverified" }
  } elseif (-not $DesignMap.ContainsKey('version')) { $res += 'Fail'; $why += 'design (repo file) has no version' }
}
if ($H.ContainsKey('approved')) {
  $ap = [string]$H['approved']
  if ($ap -ne 'none') {
    $apm = Parse-FlowMap $ap
    foreach ($ak in 'by', 'date', 'fingerprint') { if (-not $apm.ContainsKey($ak)) { $res += 'Fail'; $why += "approved has no $ak" } }
  }
}
if ($H.ContainsKey('status') -and @('draft', 'ready', 'in progress', 'done') -notcontains [string]$H['status']) { $res += 'Fail'; $why += "status '$($H['status'])'" }
$expected = 1
foreach ($ph in $Phases) {
  foreach ($pk in 'name', 'checkpoint', 'check', 'tasks') { if ($ph.Keys -notcontains $pk) { $res += 'Fail'; $why += "$($ph.Id) has no $pk" } }
  if ($ph.Name -ne '' -and $ph.Name.Length -gt 40) { $res += 'Flag'; $why += "$($ph.Id) name is $($ph.Name.Length) characters (40)" }
  foreach ($t in $ph.Tasks) {
    foreach ($tk in 'id', 'title', 'role', 'tier', 'after', 'traces') { if ($t.Keys -notcontains $tk) { $res += 'Fail'; $why += "task '$($t.Id)' in $($ph.Id) has no $tk" } }
    foreach ($bad in 'owns', 'produces', 'consumes', 'file', 'phase') { if ($t.Keys -contains $bad) { $res += 'Flag'; $why += "$($t.Id) carries '$bad' (an S102 header field)" } }
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
$plan6 = Get-Section $Sections 6
$text6 = ''; if ($null -ne $plan6) { $text6 = ($plan6.Lines -join "`n") }
$HasP0 = ($Phases.Count -gt 0 -and $Phases[0].Id -eq 'P0')
foreach ($ph in $Phases) { if ($ph.Id -eq 'P0' -and $ph -ne $Phases[0]) { $res += 'Fail'; $why += 'P0 is not the first phase' } }
if ($HasP0 -and $Phases[0].Name -notmatch '(?i)foundation') { $res += 'Fail'; $why += "P0 is named '$($Phases[0].Name)', not Foundation" }
$P0Ids = @(); if ($HasP0) { $P0Ids = @($Phases[0].Tasks | ForEach-Object { $_.Id }) }
$lastSliceIdx = -1
for ($i = 0; $i -lt $Phases.Count; $i++) { if ($Phases[$i].Id -ne 'P0' -and $Phases[$i].Traces.Count -gt 0) { $lastSliceIdx = $i } }
$SliceTaskIds = @()
for ($i = 0; $i -lt $Phases.Count; $i++) { if ($Phases[$i].Id -ne 'P0' -and $Phases[$i].Traces.Count -gt 0) { $SliceTaskIds += @($Phases[$i].Tasks | ForEach-Object { $_.Id }) } }
$SeqPairs = @()
for ($i = 0; $i -lt $Phases.Count; $i++) {
  $ph = $Phases[$i]
  if ($ph.Tasks.Count -eq 0) { $res += 'Fail'; $why += "$($ph.Id) holds no task"; continue }
  $isSlice = ($ph.Id -ne 'P0' -and $ph.Traces.Count -gt 0)
  if ($ph.Id -eq 'P0') { continue }
  if ($HasP0) {
    foreach ($t in $ph.Tasks) {
      $viaP0 = $false; foreach ($p0 in $P0Ids) { if (Comes-After $t.Id $p0) { $viaP0 = $true; break } }
      if (-not $viaP0) { $res += 'Fail'; $why += "$($t.Id) in $($ph.Id) has no path from a P0 task" }
    }
  }
  if ($isSlice) {
    $testers = @($ph.Tasks | Where-Object { $_.Role -match 'tester' })
    $builders = @($ph.Tasks | Where-Object { $_.Role -match 'builder' })
    if ($testers.Count -eq 0) {
      $named = $false
      foreach ($b in $builders) { if ($text6 -match ("\b" + [regex]::Escape($b.Id) + "\b") -and $text6 -match '(?i)tester|test-first') { $named = $true } }
      if ($named) { $res += 'Flag'; $why += "$($ph.Id) has no tester task; a $Sym" + "6 row names its builder as the slice's tester" }
      else { $res += 'Fail'; $why += "$($ph.Id) is a slice with no tester task" }
    } else {
      if ($builders.Count -eq 0) { $res += 'Fail'; $why += "$($ph.Id) is a slice with no builder task" }
      foreach ($b in $builders) {
        $afterTester = $false; foreach ($tt in $testers) { if (Comes-After $b.Id $tt.Id) { $afterTester = $true; break } }
        if (-not $afterTester) { $res += 'Fail'; $why += "$($b.Id) does not come after a tester of $($ph.Id)" }
      }
      foreach ($tt in $testers) {
        foreach ($u in $UpstreamOf[$tt.Id]) {
          if ($TaskById.ContainsKey($u) -and $TaskById[$u].Role -match 'builder' -and $SliceTaskIds -contains $u -and $TaskById[$u].Phase -ne $ph.Id) { $SeqPairs += "$($tt.Id) after $u" }
        }
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
Finish-Row 'G3' 'Phases' $res $why 'Every slice has its tester before its builders; every phase holds a task.'

# ---------------------------------------------------------------- G4 parallel = disjoint

$ParallelPairs = @()
for ($i = 0; $i -lt $AllTasks.Count; $i++) {
  for ($j = $i + 1; $j -lt $AllTasks.Count; $j++) {
    $a = $AllTasks[$i].Id; $b = $AllTasks[$j].Id
    if ($a -eq '' -or $b -eq '') { continue }
    if (-not (Comes-After $a $b) -and -not (Comes-After $b $a)) { $ParallelPairs += , @($a, $b) }
  }
}
if (-not $Full) {
  $pairText = 'none'; if ($ParallelPairs.Count -gt 0) { $pairText = (($ParallelPairs | ForEach-Object { "$($_[0])/$($_[1])" }) -join ', ') }
  Add-Row 'G4' 'Parallel = disjoint' 'not yet' "No S102 to read; pairs that may run together: $pairText."
} else {
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
}

# ---------------------------------------------------------------- G5 contracts table

$res = @(); $why = @()
if ($null -eq $plan1) { $res += 'Fail'; $why += "$Sym" + '1 Contracts missing' }
elseif (-not $ContractsNone -and -not $ContractsHeaderOk) { $res += 'Fail'; $why += "$Sym" + '1 has neither the three columns (Name, Shape, Produced by) nor *none*' }
else {
  if ($ContractsHasConsumedBy) { $res += 'Flag'; $why += "$Sym" + '1 carries a Consumed by column; it is no longer read (the S102 headers record consumption)' }
  foreach ($r in $ContractRows) {
    if ($r.ProducedBy -match '(?i)existing') { $res += 'Flag'; $why += "'$($r.Name)' is produced by existing code; it belongs in an S102 header, not $Sym" + '1' }
    elseif ($r.Producers.Count -eq 0) { $res += 'Fail'; $why += "'$($r.Name)' has no task id under Produced by" }
    else { foreach ($p in $r.Producers) { if (-not $TaskById.ContainsKey($p)) { $res += 'Fail'; $why += "'$($r.Name)' is produced by $p, which is not in the tree" } } }
    if ($r.Name -match '(?i)tests?$|^.*Tests?\.' -or $r.Shape -match '(?i)\btest (class|method|name)\b') { $res += 'Flag'; $why += "'$($r.Name)' looks like a test name; a test is never a contract" }
  }
}
Finish-Row 'G5' 'Contracts table' $res $why "$($ContractRows.Count) row(s); every producer is in the tree."

# ---------------------------------------------------------------- G6 coverage both ways

$res = @(); $why = @()
$plan3 = Get-Section $Sections 3
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
  foreach ($tr in $t.Traces) { if (-not (Test-InDesign $tr)) { $res += 'Fail'; $why += "$($t.Id) traces $tr, not in the design" } }
  if ($MapTaskIds -notcontains $t.Id) { $res += 'Fail'; $why += "$($t.Id) appears in no $Sym" + '3 row' }
}
foreach ($ph in $Phases) { foreach ($tr in $ph.Traces) { if (-not (Test-InDesign $tr)) { $res += 'Fail'; $why += "$($ph.Id) traces $tr, not in the design" } } }
foreach ($id in $MapSaysEmpty) { $res += 'Fail'; $why += "$Sym" + "3 row $id has an empty Says (required for a normalised design)" }
if ($designNote -ne '') { $why += $designNote }
Finish-Row 'G6' 'Coverage both ways' $res $why "$($RequiredIds.Count) design id(s) mapped; every task is in the map and traces into the design."

# ---------------------------------------------------------------- G7 sizes

if (-not $Full) { Add-Row 'G7' 'Sizes' 'not yet' 'No S102 to count.' }
else {
  $res = @(); $why = @()
  foreach ($t in $AllTasks) {
    if (-not $Specs.ContainsKey($t.Id)) { continue }
    $n = @(Spec-Owns $t.Id 'create').Count + @(Spec-Owns $t.Id 'modify').Count
    if ($n -gt $thrFiles) { $res += 'Warn'; $why += "$($t.Id) owns $n non-test files (threshold $thrFiles)" }
  }
  Finish-Row 'G7' 'Sizes' $res $why "Every task owns at most $thrFiles non-test files."
}

# ---------------------------------------------------------------- G8 body

$res = @(); $why = @()
$nums = @($Sections | ForEach-Object { $_.Num })
for ($n = 1; $n -le 6; $n++) { if ($nums -notcontains $n) { $res += 'Fail'; $why += "$Sym$n missing" } }
$ordered = $true; for ($i = 1; $i -lt $nums.Count; $i++) { if ($nums[$i] -lt $nums[$i - 1]) { $ordered = $false } }
if (-not $ordered) { $res += 'Fail'; $why += 'sections out of order' }
for ($i = 0; $i -lt [Math]::Min($Sections.Count, $TplSections.Count); $i++) {
  $want = ($TplSections[$i] -replace '\s+', ' ').Trim().ToLowerInvariant(); $have = ($Sections[$i].Title -replace '\s+', ' ').Trim().ToLowerInvariant()
  if ($want -ne $have -and $Sections[$i].Num -eq ($i + 1)) { $res += 'Flag'; $why += "$Sym$($Sections[$i].Num) is titled '$($Sections[$i].Title)', the template says '$($TplSections[$i])'" }
}
if ($null -ne $plan6) { $t6 = Parse-Table @($plan6.Lines); if ($null -eq $t6.Header -or $t6.Rows.Count -eq 0) { $res += 'Fail'; $why += "$Sym" + '6 Assumptions is empty (no row)' } }
$InFence = $false; $FenceCount = 0; $StepLists = 0; $Checkbox = 0
foreach ($l in $Body) {
  if ($l -match '^\s*```') { if (-not $InFence) { $FenceCount++ }; $InFence = -not $InFence; continue }
  if ($InFence) { continue }
  if ($l -match '^\s*\d+\.\s+\S') { $StepLists++ }
  if ($l -match '^\s*[-*]\s*\[( |x)\]') { $Checkbox++ }
  foreach ($m in [regex]::Matches($l, '\b([PT]\d{1,3})\b')) {
    $ref = $m.Groups[1].Value
    if ($ref -match '^T' -and $ref.Length -eq 4 -and -not $TaskById.ContainsKey($ref)) { $res += 'Fail'; $why += "body names $ref, not in the tree" }
    if ($ref -match '^P\d+$' -and -not $PhaseById.ContainsKey($ref)) { $res += 'Fail'; $why += "body names $ref, not in the tree" }
  }
}
if ($FenceCount -gt 0) { $res += 'Fail'; $why += "$FenceCount code fence(s) in the body; a plan carries no code" }
if ($StepLists -gt 0) { $res += 'Flag'; $why += "$StepLists numbered line(s) outside a table; a plan carries no step list" }
# a signature outside section 1: a parenthesised parameter list with a type-looking token
foreach ($sec in $Sections) {
  if ($sec.Num -eq 1) { continue }
  foreach ($l in $sec.Lines) {
    if ($l -match '\b[A-Z]\w+(?:<[\w, ]+>)?\s+\w+\s*\([^)]*\b[A-Z]\w*\s+\w+') { $res += 'Flag'; $why += "a signature outside $Sym" + "1 in $Sym$($sec.Num): $($l.Trim())"; break }
  }
}
Finish-Row 'G8' 'Body' $res $why ("$Sym" + '1-' + "$Sym" + '6 in order; no code, no step list; every id named exists.')

# ---------------------------------------------------------------- G9 S102 files on disk

$res = @(); $why = @()
$TreeNums = @($AllTasks | Where-Object { $_.Id -ne '' } | ForEach-Object { Task-Num $_.Id })
foreach ($n in $FilesByNum.Keys) {
  if ($TreeNums -notcontains $n) { $res += 'Fail'; $why += "'$([System.IO.Path]::GetFileName($FilesByNum[$n][0]))' carries number $n, not in the tree (a leftover)" }
  elseif ($FilesByNum[$n].Count -gt 1) { $res += 'Fail'; $why += "two files carry number $n" }
}
foreach ($f in $S102Files) { if ($f.Name -notmatch '^S102-.+-\d{3}-[^/\\]+\.md$') { $res += 'Fail'; $why += "'$($f.Name)' does not follow S102-<slug>-NNN-<task>.md" } }
if ($MissingSpecs.Count -gt 0) {
  if ($Full) { $res += 'Fail'; $why += "no S102 for $($MissingSpecs -join ', ')" }
  else { $why += "no S102 yet for $($MissingSpecs -join ', ')" }
}
if ($res.Count -eq 0 -and -not $Full) { $s9 = (($why | Select-Object -Unique) -join '; '); if ($s9 -eq '') { $s9 = 'Graph-only mode; the files are not checked.' }; Add-Row 'G9' 'S102 files on disk' 'not yet' $s9 }
else { Finish-Row 'G9' 'S102 files on disk' $res $why 'One S102 per task, none extra.' }

# ---------------------------------------------------------------- F2-F5 (full mode)

if ($Full) {
  # F2 header equals task line
  $res = @(); $why = @()
  foreach ($t in $AllTasks) {
    if (-not $Specs.ContainsKey($t.Id)) { continue }
    $sh = $Specs[$t.Id].Header
    if ($sh.ContainsKey('task') -and [string]$sh['task'] -ne $t.Id) { $res += 'Fail'; $why += "$($t.Id): header task '$($sh['task'])'" }
    if ($sh.ContainsKey('title') -and ([string]$sh['title']).Trim() -ne $t.Title.Trim()) { $res += 'Fail'; $why += "$($t.Id): title differs from the task line" }
    if ($sh.ContainsKey('role') -and [string]$sh['role'] -ne $t.Role) { $res += 'Fail'; $why += "$($t.Id): role '$($sh['role'])' vs '$($t.Role)'" }
    if ($sh.ContainsKey('tier') -and [string]$sh['tier'] -ne $t.Tier) { $res += 'Fail'; $why += "$($t.Id): tier '$($sh['tier'])' vs '$($t.Tier)'" }
    $hAfter = Spec-List $t.Id 'after'; if (@(Compare-Object @($hAfter | Sort-Object) @($t.After | Sort-Object)).Count -gt 0) { $res += 'Fail'; $why += "$($t.Id): after [$($hAfter -join ', ')] vs [$($t.After -join ', ')]" }
    $hTr = Spec-List $t.Id 'traces'; if (@(Compare-Object @($hTr | Sort-Object) @($t.Traces | Sort-Object)).Count -gt 0) { $res += 'Fail'; $why += "$($t.Id): traces [$($hTr -join ', ')] vs [$($t.Traces -join ', ')]" }
  }
  Finish-Row 'F2' 'Header equals task line' $res $why 'Every S102 header equals its task line.'

  # F3 interface closure across headers
  $res = @(); $why = @()
  $script:ProjectFileList = $null
  function Get-ProjectFiles {
    if ($null -eq $script:ProjectFileList) { $script:ProjectFileList = @(Get-RepoFiles | Where-Object { $_ -match '\.(csproj|fsproj|vbproj)$|(^|/)package\.json$|(^|/)Directory\.Packages\.props$' }) }
    return $script:ProjectFileList
  }
  function Test-PackageReferenced([string]$Id) {
    foreach ($pf in Get-ProjectFiles) {
      $full = Resolve-RepoPath $pf
      if ($pf -match 'package\.json$') { if (Select-String -LiteralPath $full -Pattern ('"' + [regex]::Escape($Id) + '"') -Quiet) { return $true } }
      else { if (Select-String -LiteralPath $full -Pattern ('(?i)Package(Reference|Version)\s+Include="' + [regex]::Escape($Id) + '"') -Quiet) { return $true } }
    }
    return $false
  }
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
  Finish-Row 'F3' 'Interface closure across headers' $res $why 'Every consumed name is produced upstream, on disk or in a package; every produced name has its row.'

  # F4 constraints, line against line
  $res = @(); $why = @()
  $plan2 = Get-Section $Sections 2
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
  Finish-Row 'F4' 'Constraints' $res $why ("No $Sym" + "4 line restates a $Sym" + '2 line; a contradiction is not detected by the script.')

  # F5 S102 bars
  $res = @(); $why = @()
  foreach ($t in $AllTasks) {
    if (-not $Specs.ContainsKey($t.Id)) { continue }
    $sh = $Specs[$t.Id].Header
    $st = ''; if ($sh.ContainsKey('status')) { $st = [string]$sh['status'] }
    $vd = ''; if ($sh.ContainsKey('validated')) { $vd = [string]$sh['validated'] }
    if ($st -ne 'validated' -and $st -ne 'done') { $res += 'Fail'; $why += "$($t.Id) is '$st'" }
    elseif ($vd -notmatch '^\d{4}-\d{2}-\d{2}$') { $res += 'Fail'; $why += "$($t.Id) is validated without a date" }
  }
  Finish-Row 'F5' 'S102 bars' $res $why 'Every S102 carries status: validated with a date.'
}

# ---------------------------------------------------------------- the ten rows

function Row-Result([string]$Id) { $r = RowOf $Id; if ($null -eq $r) { return 'n/a' }; return $r.Result }
function Combine([string[]]$Ids) {
  $results = @(); $reasons = @()
  foreach ($id in $Ids) { $r = RowOf $id; if ($null -eq $r) { continue }; $results += $r.Result; if ($r.Result -ne 'Pass') { $reasons += "$id $($r.Result): $($r.Reason)" } }
  return @{ Results = $results; Reasons = $reasons }
}

# 1 Completeness
$res = @(); $why = @()
if (-not $H.ContainsKey('design')) { $res += 'Fail'; $why += 'no design line' }
$preamble = @(); foreach ($l in $Body) { if ($l -match '^##\s') { break }; if ($l.Trim() -ne '' -and $l -notmatch '^#\s') { $preamble += $l } }
if ($preamble.Count -eq 0) { $res += 'Fail'; $why += 'no first paragraph naming the design and its approval' }
elseif (($preamble -join ' ') -notmatch '(?i)approved') { $res += 'Flag'; $why += 'the first paragraph does not name the approval' }
foreach ($ph in $Phases) { if ($ph.Checkpoint -eq '') { $res += 'Fail'; $why += "$($ph.Id) has an empty checkpoint" }; if ($ph.Check -eq '') { $res += 'Fail'; $why += "$($ph.Id) has an empty check" } }
foreach ($n in 3, 4) { if ($null -eq (Get-Section $Sections $n)) { $res += 'Fail'; $why += "$Sym$n missing" } }
foreach ($n in 1, 2, 6) { $sec = Get-Section $Sections $n; if ($null -ne $sec -and (($sec.Lines -join "`n").Trim() -eq '')) { $res += 'Fail'; $why += "$Sym$n is empty (write *none* when there is nothing)" } }
if ($Full) {
  $c = Combine @('G9', 'F5'); foreach ($r in $c.Results) { if ($r -eq 'Fail') { $res += 'Fail' } }; $why += $c.Reasons
  Finish-Row '1' 'Completeness' $res $why 'Every plan member present; every S102 on disk and validated.'
} else {
  if ($res.Count -eq 0) { Add-Row '1' 'Completeness' 'not yet' 'Members present; no S102 exists.' } else { Finish-Row '1' 'Completeness' $res $why '' }
}

# 2 Coverage both ways
$g6 = RowOf 'G6'; Add-Row '2' 'Coverage both ways' $g6.Result $g6.Reason

# 3 Graph validity
$c = Combine @('G2', 'G3', 'G4')
if (-not $Full) { $sub = @($c.Results | Where-Object { $_ -ne 'not yet' }); $rs = Worst $sub; $sentence = 'No cycle; phases hold; G4 not yet.'; if ($c.Reasons.Count -gt 0) { $sentence = (($c.Reasons | Where-Object { $_ -notmatch '^G4' }) -join '; ') }; if ($sentence -eq '') { $sentence = 'No cycle; phases hold; G4 not yet.' }; Add-Row '3' 'Graph validity' $rs $sentence }
else { $rs = Worst $c.Results; $sentence = 'No cycle; phases hold; parallel pairs disjoint.'; if ($c.Reasons.Count -gt 0) { $sentence = ($c.Reasons -join '; ') }; Add-Row '3' 'Graph validity' $rs $sentence }

# 4 Stoppable phases
$res = @(); $why = @()
foreach ($ph in $Phases) {
  $cp = $ph.Checkpoint; $ck = $ph.Check
  if ($cp -match '(?i)\b(code exists|implemented|is implemented|done)\b\s*$' -or $cp -match '(?i)^\s*(implemented|code exists)') { $res += 'Fail'; $why += "$($ph.Id) checkpoint reads as a claim, not a state: '$cp'" }
  if ($cp -match '`|\b(dotnet|npm|ng|pwsh|powershell|bash|make|yarn|pnpm)\b|--\w|[\w.-]+/[\w.-]+\.\w+') { $res += 'Flag'; $why += "$($ph.Id) checkpoint carries a command or a path; it belongs in check" }
  if ($ck.Trim() -eq '') { $res += 'Fail'; $why += "$($ph.Id) check is empty" }
  elseif ($ck -match '(?i)\b(grep|rg|Select-String|findstr)\b') { $res += 'Fail'; $why += "$($ph.Id) check searches the source: '$ck'" }
  elseif ($ck -notmatch '\S+\s+\S+' -and $ck -notmatch '\.(ps1|sh|cmd)$') { $res += 'Fail'; $why += "$($ph.Id) check has no runnable form: '$ck'" }
}
Finish-Row '4' 'Stoppable phases' $res $why 'Every checkpoint is a sentence; every check is a command that is not a search.'

# 5 Interface closure
$ids5 = @('G5'); if ($Full) { $ids5 += 'F3' }
$c = Combine $ids5; $rs = Worst $c.Results; $sentence = 'Contracts table consistent'; if ($Full) { $sentence += '; every header closes.' } else { $sentence += '; F3 not yet.' }
if ($c.Reasons.Count -gt 0) { $sentence = ($c.Reasons -join '; ') }
Add-Row '5' 'Interface closure' $rs $sentence

# 6 Constraint consistency
$res = @(); $why = @()
$plan2 = Get-Section $Sections 2
if ($null -eq $plan2) { $res += 'Fail'; $why += "$Sym" + '2 missing' }
else {
  $lines2 = @($plan2.Lines | Where-Object { $_ -match '^\s*[-*]\s+\S' })
  foreach ($l in $lines2) {
    $n = Normalize-Line $l
    if ($n -eq 'none') { continue }
    if ($l -notmatch "$EmDash|\s-\s|\(.*(D101|\$Sym|decision|ticket|convention|CLAUDE|AGENTS|SEC-|[A-Z]+-\d+).*\)") { $res += 'Flag'; $why += "$Sym" + "2 line without a source: '$($l.Trim())'" }
  }
}
if ($Full) { $f4 = RowOf 'F4'; if ($f4.Result -ne 'Pass') { $res += $f4.Result; $why += "F4: $($f4.Reason)" } }
Finish-Row '6' 'Constraint consistency' $res $why 'Every constraint carries a source.'

# 7 Review focus
$res = @(); $why = @()
$plan5 = Get-Section $Sections 5
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
$plan4 = Get-Section $Sections 4
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
$bodyText = ($Body -join "`n")
if ($Checkbox -gt 0) { $res += 'Fail'; $why += "$Checkbox checkbox line(s): run state belongs in the ledger" }
if ($bodyText -match '(?im)^\s*[-*|]?\s*(passes|passed|claimed|fixed|verified)\s*[:|]') { $res += 'Flag'; $why += 'a status word opens a line (passes/claimed/fixed); run state belongs in the ledger' }
Finish-Row '9' 'Separation' $res $why 'No code, no steps, no run state in the plan.'

# 10 Model choice
$res = @(); $why = @()
foreach ($t in $AllTasks) { if ($t.Tier -ne '' -and $Tiers -notcontains $t.Tier) { $res += 'Fail'; $why += "$($t.Id) tier '$($t.Tier)'" } }
if ($Full) {
  foreach ($t in $AllTasks) {
    if ($t.Tier -ne 'low' -or -not $Specs.ContainsKey($t.Id)) { continue }
    $s2 = Get-Section $Specs[$t.Id].Sections 2
    if ($null -ne $s2 -and (($s2.Lines -join "`n") -match '(?m)^\s*Scenario(?: Outline)?:')) { $res += 'Flag'; $why += "$($t.Id) is low but its S102 $Sym" + '2 holds a Scenario (behaviour in prose is mid)' }
  }
}
Finish-Row '10' 'Model choice' $res $why 'Every tier is one of the three values.'

# ---------------------------------------------------------------- report

$out = New-Object System.Collections.Generic.List[string]
$out.Add('## Validation report')
$out.Add("target: $S101")
$out.Add('bar: dispatch-ready')
$out.Add("mode: $EffectiveMode")
$out.Add('blind: false')
$out.Add('engine: script (validate-s101.ps1)')
$out.Add('| # | Check | Result | Reason |')
$out.Add('|---|---|---|---|')
foreach ($r in $Rows) { $out.Add("| $($r.Id) | $($r.Check) | $($r.Result) | $($r.Reason) |") }
Write-Output ($out -join "`n")
exit 0
