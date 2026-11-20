<#
.SYNOPSIS
  The shared parser and renderer of the plan artifact, dot-sourced by validate-plan.ps1 and
  render-plan.ps1 beside it. Not a script a caller runs.

.DESCRIPTION
  One plan file (.asimov/plans/<slug>.md) carries the S101 header and tree, the six plan sections
  and one section per task. The two scripts read it through Parse-Plan and turn it into the S101
  and the S102s through Render-S101 and Render-S102, in memory (the validator) or on disk (the
  renderer), so the two always agree byte for byte on what the build will receive.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike. The source is pure ASCII on purpose:
  5.1 reads a BOM-less file as ANSI, so every non-ASCII character is built at run-time.
#>

Set-StrictMode -Version 2

$Sym = [string][char]0xA7        # the section sign
$EmDash = [string][char]0x2014   # the dash in headings and before a constraint's source
$EnDash = [string][char]0x2013
$MidDot = [string][char]0xB7
$Arrow = [string][char]0x2192    # the arrow in a review-focus line
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# ---------------------------------------------------------------- text

function Read-Text([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) { throw "cannot read: $Path" }
  $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Path).Path)
  $t = [System.Text.Encoding]::UTF8.GetString($bytes)
  if ($t.Length -gt 0 -and $t[0] -eq [char]0xFEFF) { $t = $t.Substring(1) }
  return ($t -replace "`r`n", "`n")
}

function Write-Text([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  if ($dir -ne '' -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Split-Frontmatter([string]$Text) {
  $lines = $Text -split "`n"
  if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return $null }
  $end = -1
  for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $end = $i; break } }
  if ($end -lt 0) { return $null }
  $body = @()
  if ($end + 1 -lt $lines.Count) { $body = $lines[($end + 1)..($lines.Count - 1)] }
  return @{ Front = @($lines[1..($end - 1)]); Body = @($body) }
}

function Strip-Quotes([string]$Value) {
  $v = $Value.Trim()
  if ($v.Length -ge 2 -and (($v[0] -eq '"' -and $v[-1] -eq '"') -or ($v[0] -eq "'" -and $v[-1] -eq "'"))) { return $v.Substring(1, $v.Length - 2) }
  return $v
}

function Quote-Yaml([string]$Value) {
  return '"' + ($Value -replace '\\', '\\' -replace '"', '\"') + '"'
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

# The tree: phases and their task lines, with the raw text and the keys each carries.
function Parse-Tree([string[]]$Front) {
  $phases = New-Object System.Collections.Generic.List[object]
  $cur = $null; $inPhases = $false; $sawPhasesKey = $false
  foreach ($raw in $Front) {
    if ($raw -match '^phases:') { $inPhases = $true; $sawPhasesKey = $true; continue }
    if (-not $inPhases) { continue }
    if ($raw -match '^[A-Za-z_]') { $inPhases = $false; continue }
    $m = [regex]::Match($raw, '^\s*-\s*id:\s*(P\d+)\s*$')
    if ($m.Success) {
      $cur = [pscustomobject]@{ Id = $m.Groups[1].Value; Name = ''; Delivers = ''; Checkpoint = ''; Check = ''; Traces = @(); HasTraces = $false; Keys = @('id'); Tasks = (New-Object System.Collections.Generic.List[object]) }
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
    $mk = [regex]::Match($raw, '^\s+(name|delivers|checkpoint|check|traces|tasks):\s*(.*)$')
    if ($mk.Success) {
      $v = $mk.Groups[2].Value.Trim()
      $cur.Keys += $mk.Groups[1].Value
      switch ($mk.Groups[1].Value) {
        'name' { $cur.Name = (Strip-Quotes $v) }
        'delivers' { $cur.Delivers = (Strip-Quotes $v) }
        'checkpoint' { $cur.Checkpoint = (Strip-Quotes $v) }
        'check' { $cur.Check = (Strip-Quotes $v) }
        'traces' { $cur.Traces = (Parse-FlowList $v); $cur.HasTraces = $true }
      }
    }
  }
  return @{ Phases = $phases; SawKey = $sawPhasesKey }
}

# Sections "## n. Title" (or "### n. Title" at the given depth) with their lines.
function Get-Sections([string[]]$Body, [int]$Depth = 2) {
  $hashes = ('#' * $Depth)
  $rx = '^' + [regex]::Escape($hashes) + '\s+(\d+)\.\s*(.+?)\s*$'
  $secs = New-Object System.Collections.Generic.List[object]
  $cur = $null
  foreach ($line in $Body) {
    $m = [regex]::Match($line, $rx)
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

# ---------------------------------------------------------------- the plan

# The heading of a task section: "## T001 <dash> Title". The dash may be an em dash, an en dash, a hyphen,
# a middle dot or a colon; the renderer writes the em dash.
$script:TaskHeadingRx = '^##\s+(T\d{3})\s*(?:' + [regex]::Escape($EmDash) + '|' + [regex]::Escape($EnDash) + '|' + [regex]::Escape($MidDot) + '|-|:)\s*(.*?)\s*$'

function Parse-Plan([string]$Text) {
  $fm = Split-Frontmatter $Text
  if ($null -eq $fm) { throw 'the plan has no YAML frontmatter between --- lines' }
  $H = Parse-Header $fm.Front
  $tree = Parse-Tree $fm.Front
  # the frontmatter lines by key, verbatim, and the phases block verbatim
  $headLines = New-Object System.Collections.Generic.List[object]
  $phaseLines = New-Object System.Collections.Generic.List[string]
  $inPhases = $false
  foreach ($raw in $fm.Front) {
    if ($raw -match '^phases:') { $inPhases = $true; $phaseLines.Add($raw); continue }
    if ($inPhases) {
      if ($raw -match '^[A-Za-z_]') { $inPhases = $false } else { $phaseLines.Add($raw); continue }
    }
    $m = [regex]::Match($raw, '^([A-Za-z_][\w-]*):')
    if ($m.Success) { $headLines.Add([pscustomobject]@{ Key = $m.Groups[1].Value; Line = $raw }) }
    elseif ($headLines.Count -gt 0 -and $raw -match '^\s+\S') { $headLines[$headLines.Count - 1].Line += "`n" + $raw }
  }
  # the body: preamble, plan sections, task sections
  $preamble = New-Object System.Collections.Generic.List[string]
  $planBody = New-Object System.Collections.Generic.List[string]
  $tasks = New-Object System.Collections.Generic.List[object]
  $title = ''
  $state = 'preamble'; $curTask = $null
  foreach ($line in $fm.Body) {
    $mt = [regex]::Match($line, $script:TaskHeadingRx)
    if ($mt.Success) {
      $curTask = [pscustomobject]@{ Id = $mt.Groups[1].Value; HeadingTitle = $mt.Groups[2].Value; Lines = (New-Object System.Collections.Generic.List[string]); YamlLines = @(); Meta = @{}; HasYaml = $false; Sections = $null }
      $tasks.Add($curTask); $state = 'task'; continue
    }
    if ($state -eq 'preamble') {
      if ($line -match '^#\s+(.+)$' -and $title -eq '') { $title = $Matches[1].Trim() }
      elseif ($line -match '^##\s') { $state = 'plan'; $planBody.Add($line) }
      else { $preamble.Add($line) }
    } elseif ($state -eq 'plan') { $planBody.Add($line) }
    else { $curTask.Lines.Add($line) }
  }
  # each task: the first yaml fence is the header block; the ### sections are the five S102 sections
  foreach ($t in $tasks) {
    $inFence = $false; $lang = ''; $yaml = New-Object System.Collections.Generic.List[string]; $rest = New-Object System.Collections.Generic.List[string]; $taken = $false
    foreach ($l in $t.Lines) {
      if (-not $taken) {
        if (-not $inFence -and $l -match '^\s*```\s*(\w*)\s*$') { $inFence = $true; $lang = $Matches[1]; continue }
        if ($inFence) {
          if ($l -match '^\s*```\s*$') { $inFence = $false; $taken = $true; continue }
          $yaml.Add($l); continue
        }
        if ($l.Trim() -ne '' -and $l -notmatch '^\s*```') { $taken = $true }   # content before any fence: no header block
        if (-not $taken) { continue }
      }
      $rest.Add($l)
    }
    if ($yaml.Count -gt 0 -and ($lang -eq 'yaml' -or $lang -eq 'yml' -or $lang -eq '')) { $t.HasYaml = $true; $t.YamlLines = @($yaml); $t.Meta = Parse-Header @($yaml) }
    elseif ($yaml.Count -gt 0) { $rest.InsertRange(0, $yaml) }
    $t.Lines = $rest
    $t.Sections = Get-Sections @($rest) 3
  }
  # trailing blank lines of the preamble and the plan body carry nothing
  while ($preamble.Count -gt 0 -and $preamble[$preamble.Count - 1].Trim() -eq '') { $preamble.RemoveAt($preamble.Count - 1) }
  while ($preamble.Count -gt 0 -and $preamble[0].Trim() -eq '') { $preamble.RemoveAt(0) }
  while ($planBody.Count -gt 0 -and $planBody[$planBody.Count - 1].Trim() -eq '') { $planBody.RemoveAt($planBody.Count - 1) }
  # the title is the header's; the h1 is only a heading
  if ($H.ContainsKey('title') -and ([string]$H['title']).Trim() -ne '') { $title = [string]$H['title'] }
  $allTasks = @(); foreach ($ph in $tree.Phases) { foreach ($tt in $ph.Tasks) { $allTasks += $tt } }
  return [pscustomobject]@{
    Header = $H; HeadLines = $headLines; PhaseLines = @($phaseLines); Phases = $tree.Phases; SawPhasesKey = $tree.SawKey
    Title = $title; Preamble = @($preamble); PlanBody = @($planBody); PlanSections = (Get-Sections @($planBody) 2)
    Tasks = $tasks; TreeTasks = $allTasks
  }
}

function Get-HeaderValue($Plan, [string]$Key) {
  if ($Plan.Header.ContainsKey($Key)) { return [string]$Plan.Header[$Key] }
  return ''
}

# The file name of a task's S102: three to five words of the title, kebab-case.
function Get-TaskSlug([string]$Title) {
  $words = @(($Title.ToLowerInvariant() -replace "[^a-z0-9]+", ' ').Trim() -split '\s+' | Where-Object { $_ -ne '' })
  if ($words.Count -gt 5) { $words = $words[0..4] }
  if ($words.Count -eq 0) { return 'task' }
  return ($words -join '-')
}

function Get-S102FileName([string]$Slug, $TreeTask) {
  $num = ([regex]::Match($TreeTask.Id, '\d+').Value).PadLeft(3, '0')
  return ('S102-' + $Slug + '-' + $num + '-' + (Get-TaskSlug $TreeTask.Title) + '.md')
}

# The S101 text: the plan's header with spec, status, approved and version set, the phases block
# verbatim, the title, the preamble and the six plan sections verbatim.
function Render-S101($Plan, [string]$Status, [string]$ApprovedLine, [string]$Version) {
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add('---')
  $out.Add('spec: S101')
  foreach ($hl in $Plan.HeadLines) {
    switch ($hl.Key) {
      'spec' { continue }
      'status' { $out.Add('status: ' + $Status) }
      'approved' { $out.Add('approved: ' + $ApprovedLine) }
      'version' { $out.Add('version: ' + $Version) }
      default { $out.Add($hl.Line) }
    }
  }
  foreach ($pl in $Plan.PhaseLines) { $out.Add($pl) }
  $out.Add('---')
  $out.Add('')
  $out.Add('# S101 ' + $EmDash + ' ' + $Plan.Title)
  $out.Add('')
  foreach ($l in $Plan.Preamble) { $out.Add($l) }
  if ($Plan.Preamble.Count -gt 0) { $out.Add('') }
  foreach ($l in $Plan.PlanBody) { $out.Add($l) }
  $out.Add('')
  return ($out -join "`n")
}

# The S102 text of one task: the header from the task line and the task's yaml block, the five
# sections with their headings promoted from ### to ##.
function Render-S102($Plan, $TreeTask, $PlanTask, [string]$S101Rel, [string]$Status, [string]$Validated) {
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add('---')
  $out.Add('spec: S102')
  $out.Add('s101: ' + $S101Rel)
  $out.Add('task: ' + (Quote-Yaml $TreeTask.Id))
  $out.Add('title: ' + (Quote-Yaml $TreeTask.Title))
  $out.Add('role: ' + $TreeTask.Role)
  $out.Add('tier: ' + $TreeTask.Tier)
  $out.Add('after: [' + ($TreeTask.After -join ', ') + ']')
  $out.Add('traces: [' + ($TreeTask.Traces -join ', ') + ']')
  if ($null -ne $PlanTask -and $PlanTask.HasYaml) { foreach ($yl in $PlanTask.YamlLines) { $out.Add($yl) } }
  $out.Add('status: ' + $Status)
  if ($Validated -eq '' -or $Validated -eq 'none') { $out.Add('validated: none') } else { $out.Add('validated: ' + (Quote-Yaml $Validated)) }
  $out.Add('author: ' + (Quote-Yaml (Get-HeaderValue $Plan 'author')))
  $out.Add('date: ' + (Quote-Yaml (Get-HeaderValue $Plan 'date')))
  $out.Add('---')
  $out.Add('')
  $out.Add('# S102 ' + $TreeTask.Id + ' ' + $EmDash + ' ' + $TreeTask.Title)
  $out.Add('')
  $bodyLines = @()
  if ($null -ne $PlanTask) { $bodyLines = @($PlanTask.Lines) }
  $started = $false
  foreach ($l in $bodyLines) {
    if (-not $started) { if ($l.Trim() -eq '') { continue }; $started = $true }
    if ($l -match '^###\s+(\d+)\.\s*(.+?)\s*$') { $out.Add('## ' + $Matches[1] + '. ' + $Matches[2]) } else { $out.Add($l) }
  }
  while ($out.Count -gt 0 -and $out[$out.Count - 1].Trim() -eq '') { $out.RemoveAt($out.Count - 1) }
  $out.Add('')
  return ($out -join "`n")
}

# The S101 definition section 6's fingerprint, as ledger.ps1 computes it: the phases block of the
# frontmatter and body sections 2, 3 and 6, line by line as the text has them, SHA-256, 12 hex.
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

# The product repo root from the plan path: <root>/.asimov/plans/<slug>.md.
function Get-RepoRootFromPlan([string]$PlanPath) {
  $probe = $PlanPath; if (-not [System.IO.Path]::IsPathRooted($probe)) { $probe = Join-Path (Get-Location).Path $probe }
  $m = [regex]::Match($probe.Replace('\', '/'), '^(.*)/\.asimov/plans/[^/]+\.md$')
  if ($m.Success) { return $m.Groups[1].Value }
  return (Get-Location).Path
}

function Get-PlanSlug([string]$PlanPath) {
  return [regex]::Match((Split-Path -Leaf $PlanPath), '^(.+)\.md$').Groups[1].Value
}
