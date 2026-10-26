<#
.SYNOPSIS
  The build ledger's operations, as a script: start, position, record, rule, commit, close.

.DESCRIPTION
  Implements the operations of skills/artifact-s101-ledger/SKILL.md on the one file that holds a
  build's run state, specs/<slug>/S101-<slug>.ledger.md, beside the plan it belongs
  to (s101-ledger-definition.md). The frontmatter is machine state and is rewritten with the
  statuses moved; the body is the record and is only ever appended to. Every call does one
  operation and prints one line for the chat (position prints a short block). It spawns nothing,
  runs nothing, commits nothing, and writes no file but the ledger.

  The S101 is read for its tree (phase ids and names, task ids) and its approval line. The
  fingerprint is the S101 definition section 6's, computed here exactly as the awk one-liner there
  computes it (the phases block and body sections 2, 3 and 6, line by line as the file has them,
  SHA-256, first 12 hex), so the two agree byte for byte.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose (the middle dot
  and the em dash of the headings are built at run-time).

.PARAMETER Op
  One of: start, position, task, attempt, review, verify, fail, stop, ruling, commit, close.
.PARAMETER S101
  Path of the plan; the ledger is S101-<slug>.ledger.md beside it.
.PARAMETER By
  A person's name (start, ruling, commit): normally git config user.name.
.PARAMETER Task
  A task id (task, attempt, fail, stop).
.PARAMETER Phase
  A phase id (review, verify, ruling, commit).
.PARAMETER Status
  The task status to set with -Op task: pending, running, built, done, failed, stopped.
.PARAMETER Agent
  The shell name of the attempt (task with -Status running).
.PARAMETER Model
  The model of the attempt, or "session" in Codex (task with -Status running).
.PARAMETER Text
  The text to append verbatim (attempt: the builder's summary; review and verify: the report).
  When omitted the text is read from -TextFile, else from stdin when stdin is redirected.
.PARAMETER TextFile
  A file whose content is the text to append.
.PARAMETER Passed
  With -Op verify: every done-when passed and the checkpoint is met.
.PARAMETER Failed
  With -Op verify and without -Passed: the task ids that failed, comma-separated.
.PARAMETER Choice
  With -Op ruling: resume, discard or stop.
.PARAMETER Note
  With -Op ruling: the person's note, if any.
.PARAMETER Hash
  With -Op commit: the commit hash.
.PARAMETER Files
  With -Op commit: the number of files committed.
.PARAMETER RepoRoot
  The product repo root (for the L5 git check). Defaults to two folders above the S101.

.EXAMPLE
  pwsh -NoProfile -File ledger.ps1 -Op start -S101 specs/x/S101-x.md -By "A. Person"
.EXAMPLE
  pwsh -NoProfile -File ledger.ps1 -Op task -S101 <s101> -Task T001 -Status running -Agent giskard-the-dotnet-developer -Model claude-sonnet-5-5
.EXAMPLE
  pwsh -NoProfile -File ledger.ps1 -Op review -S101 <s101> -Phase P1 -TextFile report.md

.OUTPUTS
  One line per operation (a short block for position), on stdout. Exit code 0 when the operation
  was done, 2 when it was refused or an input could not be read; nothing is written then.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][ValidateSet('start', 'position', 'task', 'attempt', 'review', 'verify', 'fail', 'stop', 'ruling', 'commit', 'close')][string]$Op,
  [Parameter(Mandatory = $true)][string]$S101,
  [string]$By = '',
  [string]$Task = '',
  [string]$Phase = '',
  [string]$Status = '',
  [string]$Agent = '',
  [string]$Model = '',
  [string]$Text = '',
  [string]$TextFile = '',
  [switch]$Passed,
  [string]$Failed = '',
  [string]$Choice = '',
  [string]$Note = '',
  [string]$Hash = '',
  [int]$Files = -1,
  [string]$RepoRoot = ''
)

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$Dot = [string][char]0xB7         # the middle dot of the headings
$EmDash = [string][char]0x2014    # the dash of the title line
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Today = (Get-Date).ToString('yyyy-MM-dd')
$PhaseStatuses = @('pending', 'building', 'built', 'passed', 'committed', 'discarded')
$TaskStatuses = @('pending', 'running', 'built', 'done', 'failed', 'stopped')

function Fail-Run([string]$Message) { Write-Output "ledger: $Message"; exit 2 }

# ---------------------------------------------------------------- files

function Read-Raw([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { throw "cannot read: $Path" }
  $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Path).Path)
  return [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Write-Raw([string]$Path, [string]$Content) {
  [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

if (-not [System.IO.Path]::IsPathRooted($S101)) { $S101 = Join-Path (Get-Location).Path $S101 }
$S101 = $S101 -replace '/', '\'
$SpecDir = Split-Path -Parent $S101
$Slug = [regex]::Match((Split-Path -Leaf $S101), '^S101-(.+)\.md$').Groups[1].Value
if ($Slug -eq '') { Fail-Run "not an S101 path: $S101" }
$LedgerPath = Join-Path $SpecDir ("S101-" + $Slug + ".ledger.md")
$LedgerName = Split-Path -Leaf $LedgerPath
if ($RepoRoot -eq '') {
  $m = [regex]::Match($S101.Replace('\', '/'), '^(.*)/specs/[^/]+/[^/]+$')
  if ($m.Success) { $RepoRoot = $m.Groups[1].Value } else { $RepoRoot = (Get-Location).Path }
}

# ---------------------------------------------------------------- the S101

# The definition section 6's fingerprint, as awk computes it: a line is kept from "phases:" up to
# the "---" that closes the frontmatter, and from a "## 2." / "## 3." / "## 6." heading up to the
# next "## " heading; each kept line is followed by "\n". Lines are matched as the file has them
# (a trailing CR stays part of the line, as it does for awk), so the two hashes agree.
function Get-Fingerprint([string]$Text) {
  $lines = $Text -split "`n"
  if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') { $lines = $lines[0..($lines.Count - 2)] }
  $sb = New-Object System.Text.StringBuilder
  $p = $false; $s = $false
  foreach ($l in $lines) {
    if ($l -match '^phases:') { $p = $true }
    if ($p -and $l -match '^---$') { $p = $false }
    if ($l -match '^## ') { $s = $false }
    if ($l -match '^## (2|3|6)\.') { $s = $true }
    if ($p -or $s) { [void]$sb.Append($l).Append("`n") }
  }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $hash = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($sb.ToString()))
  return (($hash | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 12)
}

function Strip-Quotes([string]$Value) {
  $v = $Value.Trim()
  if ($v.Length -ge 2 -and (($v[0] -eq '"' -and $v[-1] -eq '"') -or ($v[0] -eq "'" -and $v[-1] -eq "'"))) { return $v.Substring(1, $v.Length - 2) }
  return $v
}

function Parse-FlowMap([string]$Value) {
  $h = @{}
  $v = $Value.Trim()
  if (-not $v.StartsWith('{')) { return $h }
  $v = $v.Substring(1); if ($v.EndsWith('}')) { $v = $v.Substring(0, $v.Length - 1) }
  foreach ($item in ($v -split ',')) {
    $m = [regex]::Match($item, '^\s*([\w-]+)\s*:\s*(.*)$')
    if ($m.Success) { $h[$m.Groups[1].Value] = (Strip-Quotes $m.Groups[2].Value) }
  }
  return $h
}

function Get-Frontmatter([string]$Text) {
  $lines = ($Text -replace "`r`n", "`n") -split "`n"
  if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return $null }
  $end = -1
  for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $end = $i; break } }
  if ($end -lt 0) { return $null }
  return $lines[1..($end - 1)]
}

# The S101's tree: ordered phases with id, name and task ids; and its approval.
function Read-S101 {
  $text = Read-Raw $S101
  $front = Get-Frontmatter $text
  if ($null -eq $front) { throw "the S101 has no YAML frontmatter: $S101" }
  $phases = New-Object System.Collections.Generic.List[object]
  $cur = $null; $inPhases = $false; $approved = $null
  foreach ($raw in $front) {
    $mA = [regex]::Match($raw, '^approved:\s*(.*)$')
    if ($mA.Success) { $approved = $mA.Groups[1].Value.Trim() }
    if ($raw -match '^phases:') { $inPhases = $true; continue }
    if (-not $inPhases) { continue }
    if ($raw -match '^[A-Za-z_]') { $inPhases = $false; continue }
    $mP = [regex]::Match($raw, '^\s*-\s*id:\s*(P\d+)\s*$')
    if ($mP.Success) { $cur = [pscustomobject]@{ Id = $mP.Groups[1].Value; Name = ''; Tasks = (New-Object System.Collections.Generic.List[string]) }; $phases.Add($cur); continue }
    if ($null -eq $cur) { continue }
    $mN = [regex]::Match($raw, '^\s+name:\s*(.*)$')
    if ($mN.Success) { $cur.Name = (Strip-Quotes $mN.Groups[1].Value); continue }
    $mT = [regex]::Match($raw, '^\s*-\s*\{.*\bid:\s*(T\d+)')
    if ($mT.Success) { $cur.Tasks.Add($mT.Groups[1].Value) }
  }
  if ($phases.Count -eq 0) { throw "the S101 has no phases: $S101" }
  $fp = ''
  if ($null -ne $approved -and $approved -ne 'none') { $fp = (Parse-FlowMap $approved)['fingerprint'] }
  return @{ Phases = $phases; ApprovedFingerprint = [string]$fp; Fingerprint = (Get-Fingerprint $text) }
}

# ---------------------------------------------------------------- the ledger

function Read-Ledger {
  if (-not (Test-Path -LiteralPath $LedgerPath)) { throw "no ledger beside the plan: $LedgerName" }
  $text = Read-Raw $LedgerPath
  $norm = $text -replace "`r`n", "`n"
  $front = Get-Frontmatter $norm
  if ($null -eq $front) { throw "the ledger has no YAML frontmatter" }
  $bodyStart = $norm.IndexOf("`n---`n", 4)
  $body = ''
  if ($bodyStart -ge 0) { $body = $norm.Substring($bodyStart + 5) }
  $L = @{ Slug = ''; S101 = ''; Fingerprint = ''; StartedBy = ''; StartedDate = ''; Phases = (New-Object System.Collections.Generic.List[object]); Body = $body; Keys = @() }
  $cur = $null; $inPhases = $false
  foreach ($raw in $front) {
    if ($raw.Trim() -eq '') { continue }
    $mk = [regex]::Match($raw, '^([a-z0-9]+):\s*(.*)$')
    if ($mk.Success) {
      $inPhases = $false
      $k = $mk.Groups[1].Value; $v = $mk.Groups[2].Value.Trim(); $L.Keys += $k
      switch ($k) {
        'slug' { $L.Slug = (Strip-Quotes $v) }
        's101' { $L.S101 = (Strip-Quotes $v) }
        'fingerprint' { $L.Fingerprint = (Strip-Quotes $v) }
        'started' { $fm = Parse-FlowMap $v; $L.StartedBy = [string]$fm['by']; $L.StartedDate = [string]$fm['date'] }
        'phases' { $inPhases = $true }
      }
      continue
    }
    if (-not $inPhases) { continue }
    $mP = [regex]::Match($raw, '^\s*-\s*id:\s*(P\d+)\s*$')
    if ($mP.Success) { $cur = [pscustomobject]@{ Id = $mP.Groups[1].Value; Status = ''; Commit = 'none'; GoBy = ''; GoDate = ''; Tasks = (New-Object System.Collections.Generic.List[object]) }; $L.Phases.Add($cur); continue }
    if ($null -eq $cur) { continue }
    $mS = [regex]::Match($raw, '^\s+status:\s*(.*)$'); if ($mS.Success) { $cur.Status = $mS.Groups[1].Value.Trim(); continue }
    $mC = [regex]::Match($raw, '^\s+commit:\s*(.*)$'); if ($mC.Success) { $cur.Commit = (Strip-Quotes $mC.Groups[1].Value); continue }
    $mG = [regex]::Match($raw, '^\s+go:\s*(.*)$')
    if ($mG.Success) { $g = $mG.Groups[1].Value.Trim(); if ($g -ne 'none') { $fm = Parse-FlowMap $g; $cur.GoBy = [string]$fm['by']; $cur.GoDate = [string]$fm['date'] }; continue }
    $mT = [regex]::Match($raw, '^\s*-\s*\{(.*)\}\s*$')
    if ($mT.Success) {
      $fm = Parse-FlowMap ('{' + $mT.Groups[1].Value + '}')
      $att = 0; if ($fm.ContainsKey('attempts')) { $att = [int]$fm['attempts'] }
      $cur.Tasks.Add([pscustomobject]@{ Id = [string]$fm['id']; Status = [string]$fm['status']; Attempts = $att; Agent = [string]$fm['agent']; Model = [string]$fm['model'] })
    }
  }
  return $L
}

function Render-Ledger($L) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append("---`n")
  [void]$sb.Append("ledger: S101`n")
  [void]$sb.Append('slug: "' + $L.Slug + '"' + "`n")
  [void]$sb.Append('s101: ' + $L.S101 + "`n")
  [void]$sb.Append('fingerprint: "' + $L.Fingerprint + '"' + "`n")
  [void]$sb.Append('started: { by: "' + $L.StartedBy + '", date: "' + $L.StartedDate + '" }' + "`n")
  [void]$sb.Append("phases:`n")
  foreach ($ph in $L.Phases) {
    [void]$sb.Append('  - id: ' + $ph.Id + "`n")
    [void]$sb.Append('    status: ' + $ph.Status + "`n")
    if ($ph.Commit -eq 'none' -or $ph.Commit -eq '') { [void]$sb.Append("    commit: none`n") } else { [void]$sb.Append('    commit: "' + $ph.Commit + '"' + "`n") }
    if ($ph.GoBy -eq '') { [void]$sb.Append("    go: none`n") } else { [void]$sb.Append('    go: { by: "' + $ph.GoBy + '", date: "' + $ph.GoDate + '" }' + "`n") }
    [void]$sb.Append("    tasks:`n")
    foreach ($t in $ph.Tasks) {
      [void]$sb.Append('      - { id: ' + $t.Id + ', status: ' + $t.Status + ', attempts: ' + $t.Attempts + ', agent: ' + $t.Agent + ', model: ' + $t.Model + ' }' + "`n")
    }
  }
  [void]$sb.Append("---`n")
  [void]$sb.Append($L.Body)
  return $sb.ToString()
}

function Save-Ledger($L) { Write-Raw $LedgerPath (Render-Ledger $L) }

function Append-Body($L, [string]$Heading, [string]$Content) {
  $b = $L.Body
  if (-not $b.EndsWith("`n")) { $b += "`n" }
  $b += "`n" + $Heading + "`n"
  if ($Content -ne '') { $c = $Content -replace "`r`n", "`n"; if (-not $c.EndsWith("`n")) { $c += "`n" }; $b += $c }
  $L.Body = $b
}

function Find-Phase($L, [string]$Id) { foreach ($ph in $L.Phases) { if ($ph.Id -eq $Id) { return $ph } }; return $null }
function Find-Task($L, [string]$Id) { foreach ($ph in $L.Phases) { foreach ($t in $ph.Tasks) { if ($t.Id -eq $Id) { return @{ Phase = $ph; Task = $t } } } }; return $null }
function Phase-Name($Plan, [string]$Id) { foreach ($ph in $Plan.Phases) { if ($ph.Id -eq $Id) { return $ph.Name } }; return '' }

function Get-Text {
  if ($Text -ne '') { return $Text }
  if ($TextFile -ne '') { return (Read-Raw $TextFile) }
  if ([Console]::IsInputRedirected) {
    try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch { }
    return [Console]::In.ReadToEnd()
  }
  throw 'no text given: pass -Text, -TextFile, or pipe the text on stdin'
}

function Require([string]$Value, [string]$Name) { if ($Value -eq '') { throw "-$Name is required for -Op $Op" } }

# ---------------------------------------------------------------- the checks (definition section 6)

function Run-Checks($L, $Plan) {
  $needed = @('ledger', 'slug', 's101', 'fingerprint', 'started', 'phases')
  foreach ($k in $needed) { if ($L.Keys -notcontains $k) { return "L1: the ledger's frontmatter lacks '$k'" } }
  foreach ($ph in $L.Phases) {
    if ($PhaseStatuses -notcontains $ph.Status) { return "L1: phase $($ph.Id) has status '$($ph.Status)'" }
    foreach ($t in $ph.Tasks) { if ($TaskStatuses -notcontains $t.Status) { return "L1: task $($t.Id) has status '$($t.Status)'" } }
  }
  if ($L.Fingerprint -ne $Plan.Fingerprint) { return "L2: the plan changed after the ledger started; approve it again with asimov-spec" }
  $planTasks = @(); foreach ($ph in $Plan.Phases) { $planTasks += $ph.Tasks }
  $ledgerTasks = @(); foreach ($ph in $L.Phases) { foreach ($t in $ph.Tasks) { $ledgerTasks += $t.Id } }
  foreach ($ph in $L.Phases) { if ($null -eq (Phase-Name $Plan $ph.Id) -or @($Plan.Phases | Where-Object { $_.Id -eq $ph.Id }).Count -eq 0) { return "L3: phase $($ph.Id) is not in the plan's tree" } }
  foreach ($id in $ledgerTasks) { if ($planTasks -notcontains $id) { return "L3: task $id is not in the plan's tree" } }
  foreach ($id in $planTasks) { if ($ledgerTasks -notcontains $id) { return "L3: task $id of the plan is not in the ledger" } }
  $open = -1
  for ($i = 0; $i -lt $L.Phases.Count; $i++) {
    $st = $L.Phases[$i].Status
    if ($st -eq 'building' -or $st -eq 'built' -or $st -eq 'passed') {
      if ($open -ge 0) { return "L4: two phases are open ($($L.Phases[$open].Id), $($L.Phases[$i].Id))" }
      $open = $i
    }
  }
  if ($open -ge 0) {
    for ($i = 0; $i -lt $open; $i++) { $st = $L.Phases[$i].Status; if ($st -ne 'committed' -and $st -ne 'discarded') { return "L4: $($L.Phases[$i].Id) is $st before the open phase $($L.Phases[$open].Id)" } }
    for ($i = $open + 1; $i -lt $L.Phases.Count; $i++) { if ($L.Phases[$i].Status -ne 'pending') { return "L4: $($L.Phases[$i].Id) is $($L.Phases[$i].Status) after the open phase $($L.Phases[$open].Id)" } }
  }
  foreach ($ph in $L.Phases) {
    if ($ph.Status -eq 'committed') {
      if ($ph.Commit -eq 'none' -or $ph.Commit -eq '') { return "L5: $($ph.Id) is committed with no hash" }
      $ok = $false
      try { & git -C $RepoRoot cat-file -e ($ph.Commit + '^{commit}') 2>$null; $ok = ($LASTEXITCODE -eq 0) } catch { $ok = $false }
      if (-not $ok) { return "L5: $($ph.Id)'s commit $($ph.Commit) is not on this branch" }
    }
  }
  return ''
}

# ---------------------------------------------------------------- the operations

try {
  $Plan = Read-S101

  switch ($Op) {

    'start' {
      Require $By 'By'
      if (Test-Path -LiteralPath $LedgerPath) { throw "a ledger exists: $LedgerName; a run resumes from it (position)" }
      if ($Plan.ApprovedFingerprint -eq '') { throw 'the plan is not approved (approved: none); run asimov-spec first' }
      if ($Plan.ApprovedFingerprint -ne $Plan.Fingerprint) { throw 'the plan changed after it was approved; approve it again with asimov-spec' }
      $L = @{ Slug = $Slug; S101 = ($S101.Substring($RepoRoot.Length).TrimStart('\', '/') -replace '\\', '/'); Fingerprint = $Plan.Fingerprint; StartedBy = $By; StartedDate = $Today; Phases = (New-Object System.Collections.Generic.List[object]); Body = ("`n# Ledger " + $EmDash + ' ' + $Slug + "`n"); Keys = @() }
      foreach ($ph in $Plan.Phases) {
        $p = [pscustomobject]@{ Id = $ph.Id; Status = 'pending'; Commit = 'none'; GoBy = ''; GoDate = ''; Tasks = (New-Object System.Collections.Generic.List[object]) }
        foreach ($tid in $ph.Tasks) { $p.Tasks.Add([pscustomobject]@{ Id = $tid; Status = 'pending'; Attempts = 0; Agent = 'none'; Model = 'none' }) }
        $L.Phases.Add($p)
      }
      Save-Ledger $L
      Write-Output "ledger  $LedgerName created"
    }

    'position' {
      $L = Read-Ledger
      $why = Run-Checks $L $Plan
      if ($why -ne '') { Write-Output "refused  $why"; exit 2 }
      $parts = @()
      foreach ($ph in $L.Phases) {
        $p = $ph.Id + ' ' + $ph.Status
        if ($ph.Status -eq 'committed' -and $ph.Commit.Length -ge 7) { $p += ' ' + $ph.Commit.Substring(0, 7) }
        $parts += $p
      }
      Write-Output ('position  ' + ($parts -join " $Dot "))
      $openPh = $null
      foreach ($ph in $L.Phases) { if ($ph.Status -ne 'committed' -and $ph.Status -ne 'discarded') { $openPh = $ph; break } }
      if ($null -ne $openPh) {
        $ts = @()
        foreach ($t in $openPh.Tasks) {
          $d = $t.Id + ' ' + $t.Status
          if ($t.Attempts -gt 0) { $d += ' (' + $t.Attempts + ', ' + $t.Agent + ', ' + $t.Model + ')' }
          $ts += $d
        }
        Write-Output ('          ' + $openPh.Id + ': ' + ($ts -join " $Dot "))
      } else {
        Write-Output '          every phase committed or discarded'
      }
      $rulings = [regex]::Matches($L.Body, "(?m)^### ruling $Dot ([^\n]*)\n([^\n]*)")
      if ($rulings.Count -gt 0) { $last = $rulings[$rulings.Count - 1]; Write-Output ('          last ruling: ' + $last.Groups[1].Value + ' ' + $Dot + ' ' + $last.Groups[2].Value) }
      else { Write-Output '          last ruling: none' }
    }

    'task' {
      Require $Task 'Task'; Require $Status 'Status'
      if ($TaskStatuses -notcontains $Status) { throw "-Status must be one of $($TaskStatuses -join ', ')" }
      $L = Read-Ledger
      $f = Find-Task $L $Task; if ($null -eq $f) { throw "no task $Task in the ledger" }
      if ($Status -eq 'running') {
        Require $Agent 'Agent'; Require $Model 'Model'
        $f.Task.Attempts = $f.Task.Attempts + 1; $f.Task.Agent = $Agent; $f.Task.Model = $Model
        if ($f.Phase.Status -eq 'pending' -or $f.Phase.Status -eq 'discarded') {
          $f.Phase.Status = 'building'
          Append-Body $L ('## ' + $f.Phase.Id + ' ' + $Dot + ' ' + (Phase-Name $Plan $f.Phase.Id)) ''
        } elseif ($f.Phase.Status -eq 'built' -or $f.Phase.Status -eq 'passed') { $f.Phase.Status = 'building' }
      }
      $f.Task.Status = $Status
      Save-Ledger $L
      Write-Output "ledger  $Task $Status"
    }

    'attempt' {
      Require $Task 'Task'
      $L = Read-Ledger
      $f = Find-Task $L $Task; if ($null -eq $f) { throw "no task $Task in the ledger" }
      $summary = Get-Text
      Append-Body $L ('### ' + $Task + " $Dot attempt " + $f.Task.Attempts + " $Dot " + $f.Task.Agent + " $Dot " + $f.Task.Model) $summary
      $f.Task.Status = 'built'
      $allBuilt = $true; foreach ($t in $f.Phase.Tasks) { if ($t.Status -ne 'built' -and $t.Status -ne 'done') { $allBuilt = $false } }
      if ($allBuilt) { $f.Phase.Status = 'built' }
      Save-Ledger $L
      Write-Output "ledger  $Task built $Dot attempt $($f.Task.Attempts)"
    }

    'review' {
      Require $Phase 'Phase'
      $L = Read-Ledger
      $ph = Find-Phase $L $Phase; if ($null -eq $ph) { throw "no phase $Phase in the ledger" }
      $report = Get-Text
      Append-Body $L '### review' $report
      Save-Ledger $L
      Write-Output "ledger  $Phase review recorded"
    }

    'verify' {
      Require $Phase 'Phase'
      $L = Read-Ledger
      $ph = Find-Phase $L $Phase; if ($null -eq $ph) { throw "no phase $Phase in the ledger" }
      $report = Get-Text
      Append-Body $L '### verify' $report
      if ($Passed) {
        $ph.Status = 'passed'
        foreach ($t in $ph.Tasks) { $t.Status = 'done' }
        Save-Ledger $L
        Write-Output "ledger  $Phase passed"
      } else {
        $ids = @($Failed -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
        if ($ids.Count -eq 0) { throw 'a failed verification names its tasks: -Failed T001,T002' }
        foreach ($id in $ids) { $f = Find-Task $L $id; if ($null -eq $f) { throw "no task $id in the ledger" }; $f.Task.Status = 'failed' }
        Save-Ledger $L
        Write-Output "ledger  $Phase failed: $($ids -join ', ')"
      }
    }

    'fail' {
      Require $Task 'Task'
      $L = Read-Ledger
      $f = Find-Task $L $Task; if ($null -eq $f) { throw "no task $Task in the ledger" }
      $f.Task.Status = 'failed'
      Save-Ledger $L
      Write-Output "ledger  $Task failed"
    }

    'stop' {
      Require $Task 'Task'
      $L = Read-Ledger
      $f = Find-Task $L $Task; if ($null -eq $f) { throw "no task $Task in the ledger" }
      $f.Task.Status = 'stopped'
      Save-Ledger $L
      Write-Output "ledger  $Task stopped"
    }

    'ruling' {
      Require $Phase 'Phase'; Require $By 'By'; Require $Choice 'Choice'
      if (@('resume', 'discard', 'stop') -notcontains $Choice) { throw '-Choice must be resume, discard or stop' }
      $L = Read-Ledger
      $ph = Find-Phase $L $Phase; if ($null -eq $ph) { throw "no phase $Phase in the ledger" }
      $line = $Choice; if ($Note -ne '') { $line += " $Dot " + $Note }
      Append-Body $L ('### ruling ' + $Dot + ' ' + $Today + ' ' + $Dot + ' ' + $By) $line
      if ($Choice -eq 'resume') {
        foreach ($t in $ph.Tasks) { if ($t.Status -eq 'stopped' -or $t.Status -eq 'failed') { $t.Status = 'pending'; $t.Attempts = 0 } }
      } elseif ($Choice -eq 'discard') {
        $ph.Status = 'discarded'
        foreach ($t in $ph.Tasks) { $t.Status = 'pending'; $t.Attempts = 0 }
      }
      Save-Ledger $L
      Write-Output "ledger  ruling by $By $Dot $Choice"
    }

    'commit' {
      Require $Phase 'Phase'; Require $By 'By'; Require $Hash 'Hash'
      if ($Files -lt 0) { throw '-Files is required for -Op commit' }
      $L = Read-Ledger
      $ph = Find-Phase $L $Phase; if ($null -eq $ph) { throw "no phase $Phase in the ledger" }
      Append-Body $L ('### commit ' + $Dot + ' ' + $Hash) ('go by ' + $By + ' on ' + $Today + " $Dot " + $Files + " files $Dot ledger")
      $ph.Status = 'committed'; $ph.Commit = $Hash; $ph.GoBy = $By; $ph.GoDate = $Today
      Save-Ledger $L
      Write-Output "ledger  $Phase committed $Dot $Hash"
    }

    'close' {
      $L = Read-Ledger
      $open = @($L.Phases | Where-Object { $_.Status -ne 'committed' -and $_.Status -ne 'discarded' })
      if ($open.Count -eq 0) { Write-Output 'ledger  complete' } else { Write-Output "ledger  $($open.Count) phases not committed ($(($open | ForEach-Object { $_.Id }) -join ', '))" }
    }
  }
} catch {
  Fail-Run $_.Exception.Message
}
exit 0
