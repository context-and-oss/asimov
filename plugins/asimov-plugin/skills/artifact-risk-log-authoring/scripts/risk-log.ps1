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
  Print the data model, the areas in use, the opt-out and the problems found, as JSON. Writes
  nothing. With no page, register is "none" and every list is empty (exit 0).
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
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }

if (-not $PluginRoot) { $PluginRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }

$Utf8 = New-Object System.Text.UTF8Encoding $false
$Dot = [string][char]0x00B7
$Arrow = [string][char]0x2192
$States = @('Active', 'Mitigated', 'Accepted', 'Occurred', 'Resolved')
$Today = (Get-Date).ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)

# ---------------------------------------------------------------- exits

function Exit-Refused([string]$Rule) { Write-Output $Rule; exit 1 }
function Exit-Unreadable([string]$What) { Write-Output $What; exit 2 }

# ---------------------------------------------------------------- inputs

function Get-Field($Object, [string]$Name) {
  if ($null -eq $Object) { return $null }
  $p = $Object.PSObject.Properties[$Name]
  if ($null -eq $p) { return $null }
  return $p.Value
}

function Get-Text($Value) {
  if ($null -eq $Value) { return '' }
  return ([string]$Value).Trim()
}

function Get-Person {
  if ($By -and $By.Trim()) { return $By.Trim() }
  $name = $null
  try { $name = (& git config user.name 2>$null) } catch { $name = $null }
  if ($name) { return ([string]$name).Trim() }
  Write-Output 'No person: git config user.name is unset and no -By was given.'
  exit 3
}

function Read-Change([string]$File) {
  if (-not $File) { Exit-Unreadable '-Apply needs -Change <file>.' }
  if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { Exit-Unreadable "The change file $File does not exist." }
  try { return ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $File).ProviderPath, $Utf8) | ConvertFrom-Json) }
  catch { Exit-Unreadable "The change file $File is not JSON: $($_.Exception.Message)" }
}

function Read-Template {
  $file = Join-Path $PluginRoot 'artifacts/project/risk-log/risk-log-template.html'
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { Exit-Unreadable "The template $file cannot be read." }
  return [System.IO.File]::ReadAllText($file, $Utf8)
}

# ---------------------------------------------------------------- the model

function New-Register([string]$Lang) {
  return [ordered]@{ lang = $Lang; register = 'kept'; updated = $Today; history = @(); risks = @(); optout = $null }
}

$OptOutReasons = @('elsewhere', 'not-worked')

# The opt-out's reason as a sentence: the page's first paragraph, the view, the replacing line.
function Format-OptOutReason($OptOut) {
  if ($OptOut.reason -eq 'elsewhere') { return "Risks are handled elsewhere: $(([string]$OptOut.where).TrimEnd('.'))." }
  return 'Risks are not worked with on this engagement.'
}

function Get-Score($Risk) {
  if ($Risk.impact -match '^[1-5]$' -and $Risk.probability -match '^[1-5]$') { return [string]([int]$Risk.impact * [int]$Risk.probability) }
  return ''
}

# One canonical text per model, so the check compares parsed data and never bytes; the risks in
# identifier order, since the page shows them in the RL12 order.
function Format-Model($Model) {
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("lang=$($Model.lang)|register=$($Model.register)|updated=$($Model.updated)")
  if ($Model.Contains('optout') -and $null -ne $Model.optout) { $o = $Model.optout; $lines.Add("optout|$($o.reason)|$($o.where)|$($o.by)|$($o.date)") }
  foreach ($h in $Model.history) { $lines.Add("reg|$($h.date)|$($h.by)|$($h.kind)|$($h.with)|$($h.text)") }
  foreach ($r in @($Model.risks | Sort-Object @{ Expression = { $_.id } }, @{ Expression = { $_.created } }, @{ Expression = { $_.name } })) {
    $lines.Add("risk|$($r.id)|$($r.state)|$($r.impact)|$($r.probability)|$($r.owner)|$($r.area)|$($r.created)|$($r.changed)|$($r.name)|$($r.description)|$($r.mitigation)")
    foreach ($h in $r.history) { $lines.Add("line|$($r.id)|$($h.date)|$($h.by)|$($h.kind)|$($h.text)") }
  }
  return ($lines -join "`n")
}

# The RL12 order: by state, then score descending, then identifier.
function Get-Ordered($Risks) {
  return @($Risks | Sort-Object @{ Expression = { [array]::IndexOf($States, $_.state) } }, @{ Expression = { $s = Get-Score $_; if ($s) { [int]$s } else { -1 } }; Descending = $true }, @{ Expression = { $_.id } })
}

# ---------------------------------------------------------------- render

function ConvertTo-Html([string]$Value) {
  # only what HTML needs; a name outside ASCII stays as written, in UTF-8
  return $Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace('{', '&#123;').Replace('}', '&#125;')
}

function Set-Values([string]$Text, $Values) {
  foreach ($k in $Values.Keys) { $Text = $Text.Replace('{{' + $k + '}}', (ConvertTo-Html ([string]$Values[$k]))) }
  return $Text
}

function Get-BlockPattern([string]$Name) {
  $n = [regex]::Escape($Name)
  return "(?s)[ \t]*<!-- BEGIN $n -->\r?\n(?<body>.*?)[ \t]*<!-- END $n -->[ \t]*\r?\n?"
}

function Get-Block([string]$Text, [string]$Name) {
  $m = [regex]::Match($Text, (Get-BlockPattern $Name))
  if (-not $m.Success) { Exit-Unreadable "The template has no block $Name." }
  return $m.Groups['body'].Value
}

# Replaces a block, markers included, by the given text (empty to drop it).
function Set-Block([string]$Text, [string]$Name, [string]$With) {
  $m = [regex]::Match($Text, (Get-BlockPattern $Name))
  if (-not $m.Success) { Exit-Unreadable "The template has no block $Name." }
  return $Text.Substring(0, $m.Index) + $With + $Text.Substring($m.Index + $m.Length)
}

function Format-RegisterLine([string]$Block, $Line) {
  $li = Set-Values $Block ([ordered]@{ DATE = $Line.date; BY = $Line.by; KIND = $Line.kind; WITH = $Line.with; TEXT = $Line.text })
  if ($Line.kind -ne 'review') { $li = $li -replace ' data-with="[^"]*"', '' }
  return $li
}

function Format-Risk([string]$Block, $Risk) {
  $b = $Block
  if ($Risk.description) { $b = Set-Block $b 'risk-desc' (Set-Values (Get-Block $b 'risk-desc') @{ DESC = $Risk.description }) } else { $b = Set-Block $b 'risk-desc' '' }
  if ($Risk.mitigation) {
    $b = Set-Block $b 'risk-mitigation' (Set-Values (Get-Block $b 'risk-mitigation') @{ MITIGATION = $Risk.mitigation })
    $b = Set-Block $b 'risk-none' ''
  } else {
    $b = Set-Block $b 'risk-mitigation' ''
    $b = Set-Block $b 'risk-none' (Get-Block $b 'risk-none')
  }
  $lineBlock = Get-Block $b 'risk-line'
  $lines = ($Risk.history | ForEach-Object { Set-Values $lineBlock ([ordered]@{ DATE = $_.date; BY = $_.by; KIND = $_.kind; TEXT = $_.text }) }) -join ''
  $b = Set-Block $b 'risk-line' $lines
  return Set-Values $b ([ordered]@{ ID = $Risk.id; STATE = $Risk.state; IMPACT = $Risk.impact; PROBABILITY = $Risk.probability; SCORE = (Get-Score $Risk); OWNER = $Risk.owner; AREA = $Risk.area; CREATED = $Risk.created; CHANGED = $Risk.changed; NAME = $Risk.name })
}

function Format-Page([string]$Template, $Model, [string]$RepoName) {
  # the template's own authoring comment never reaches a page
  $t = ([regex]'(?s)<!--\s*\r?\n\s*Page template for the risk log.*?-->\r?\n?').Replace($Template, '', 1)
  if ($Model.register -eq 'opt-out') { return Format-OptOutPage $t $Model $RepoName }
  $t = Set-Block $t 'form:opt-out' ''
  $t = Set-Block $t 'form:kept' (Get-Block $t 'form:kept')
  $t = Set-Block $t 'counts' (Get-Block $t 'counts')

  $regBlock = Get-Block $t 'register-line'
  $t = Set-Block $t 'register-line' (($Model.history | ForEach-Object { Format-RegisterLine $regBlock $_ }) -join '')

  $ordered = Get-Ordered $Model.risks
  $groupBlock = Get-Block $t 'summary-group'
  $rowBlock = Get-Block $groupBlock 'summary-row'
  $groupHead = Set-Block $groupBlock 'summary-row' ''
  $summary = ''
  foreach ($s in $States) {
    $inState = @($ordered | Where-Object { $_.state -eq $s })
    if ($inState.Count -eq 0) { continue }
    $summary += Set-Values $groupHead @{ STATE = $s }
    foreach ($r in $inState) { $summary += Set-Values $rowBlock ([ordered]@{ ID = $r.id; NAME = $r.name; OWNER = $r.owner; AREA = $r.area; IMPACT = $r.impact; PROBABILITY = $r.probability; SCORE = (Get-Score $r); CHANGED = $r.changed }) }
  }
  $t = Set-Block $t 'summary-group' $summary

  $stateBlock = Get-Block $t 'state-group'
  $riskBlock = Get-Block $stateBlock 'risk'
  $stateHead = Set-Block $stateBlock 'risk' ("<!-- RISKS -->`n")
  $groups = ''
  foreach ($s in $States[0..3]) {
    $inState = @($ordered | Where-Object { $_.state -eq $s })
    if ($inState.Count -eq 0) { continue }
    $groups += (Set-Values $stateHead @{ STATE = $s }).Replace("<!-- RISKS -->`n", (($inState | ForEach-Object { Format-Risk $riskBlock $_ }) -join ''))
  }
  $t = Set-Block $t 'state-group' $groups

  $open = @($ordered | Where-Object { $_.state -ne 'Resolved' })
  $resolved = @($ordered | Where-Object { $_.state -eq 'Resolved' })
  if ($open.Count -eq 0) { $t = Set-Block $t 'empty-note' (Get-Block $t 'empty-note') } else { $t = Set-Block $t 'empty-note' '' }
  if ($resolved.Count -gt 0) {
    $res = Get-Block $t 'resolved-group'
    $res = [regex]::Replace($res, '[ \t]*<!-- the same `risk` block[^>]*-->\r?\n?', (($resolved | ForEach-Object { Format-Risk $riskBlock $_ }) -join '').Replace('$', '$$'))
    $t = Set-Block $t 'resolved-group' $res
  } else { $t = Set-Block $t 'resolved-group' '' }

  $count = { param($s) [string]@($Model.risks | Where-Object { $_.state -eq $s }).Count }
  return Set-Values $t ([ordered]@{
    LANG = $Model.lang; 'REPO-NAME' = $RepoName; TITLE = 'Risk log'; REGISTER = $Model.register; UPDATED = $Model.updated
    DESCRIPTION = "The engagement's risks: who owns each, how likely and how bad it is, and what is done about it."
    'N-ACTIVE' = (& $count 'Active'); 'N-MITIGATED' = (& $count 'Mitigated'); 'N-ACCEPTED' = (& $count 'Accepted'); 'N-OCCURRED' = (& $count 'Occurred'); 'N-RESOLVED' = (& $count 'Resolved')
  })
}

# The template's opt-out form: no risks, the reason, the place, the decider, and the register's history.
function Format-OptOutPage([string]$T, $Model, [string]$RepoName) {
  $o = $Model.optout
  $t = Set-Block $T 'form:kept' ''
  $t = Set-Block $t 'counts' ''
  $t = Set-Block $t 'form:opt-out' (Get-Block $t 'form:opt-out')
  $regBlock = Get-Block $t 'register-line'
  $t = Set-Block $t 'register-line' (($Model.history | ForEach-Object { Format-RegisterLine $regBlock $_ }) -join '')
  $reasonText = if ($o.reason -eq 'elsewhere') { 'Handled elsewhere' } else { 'Not worked with on this engagement' }
  return Set-Values $t ([ordered]@{
    REASON = $o.reason; 'REASON-TEXT' = $reasonText; WHERE = $o.where; DECIDER = $o.by; DATE = $o.date; LANGUAGE = $Model.lang
    LANG = $Model.lang; 'REPO-NAME' = $RepoName; TITLE = 'No risk register kept here'; REGISTER = $Model.register; UPDATED = $Model.updated
    DESCRIPTION = (Format-OptOutReason $o)
  })
}

# ---------------------------------------------------------------- read back

function ConvertFrom-Html([string]$Value) { return [System.Net.WebUtility]::HtmlDecode($Value) }

function Get-Attr([string]$Tag, [string]$Name) {
  $m = [regex]::Match($Tag, '\s' + [regex]::Escape($Name) + '="([^"]*)"')
  if ($m.Success) { return (ConvertFrom-Html $m.Groups[1].Value) }
  return ''
}

# Every <li> of a history list is a line: one a hand edit damaged is read from what is left of it
# and marked, so the repair restores it and no line is ever lost to the reader.
function Read-Lines([string]$List) {
  $out = @()
  # split at every opening tag, so a lost </li> can never fold the next line into this one
  foreach ($chunk in [regex]::Split($List, '(?=<li[\s>])')) {
    $open = [regex]::Match($chunk, '^<li(?<attrs>[^>]*)>')
    if (-not $open.Success) { continue }
    $a = $open.Groups['attrs'].Value
    $rest = $chunk.Substring($open.Length)
    $end = $rest.IndexOf('</li>', [System.StringComparison]::Ordinal)
    $damaged = ($end -lt 0)
    $inner = if ($damaged) { $rest.Trim() } else { $rest.Substring(0, $end) }
    $line = [ordered]@{ date = (Get-Attr $a 'data-date'); by = (Get-Attr $a 'data-by'); kind = (Get-Attr $a 'data-kind'); with = (Get-Attr $a 'data-with'); text = '' }
    $m = [regex]::Match($inner, '(?s)^<time>(?<time>.*?)</time><span class="who">.*?</span> ' + $Dot + ' (?<text>.*)$')
    if ($m.Success) {
      $line.text = ConvertFrom-Html $m.Groups['text'].Value
      # a date lost from the attribute is still in the line's own <time>
      if (-not $line.date) { $line.date = ConvertFrom-Html $m.Groups['time'].Value; $damaged = $true }
    } else {
      $time = [regex]::Match($inner, '(?s)<time>(.*?)</time>')
      if (-not $line.date -and $time.Success) { $line.date = ConvertFrom-Html $time.Groups[1].Value }
      $plain = (ConvertFrom-Html ($inner -replace '<[^>]*>', '')).Trim()
      foreach ($lead in @($line.date, $line.by)) { if ($lead -and $plain.StartsWith($lead, [System.StringComparison]::Ordinal)) { $plain = $plain.Substring($lead.Length).Trim() } }
      $line.text = $plain.TrimStart([char]0x00B7).Trim()
      $damaged = $true
    }
    if (-not $line.kind -or $line.date -notmatch '^\d{4}-\d{2}-\d{2}$') { $damaged = $true }
    if ($damaged) { $line.damaged = $true }
    $out += $line
  }
  return $out
}

# The page back into the model: only the attributes and lists the template names.
function Read-PageModel([string]$Html) {
  $Html = $Html.Replace("`r`n", "`n")
  $body = [regex]::Match($Html, '<body([^>]*)>').Groups[1].Value
  $model = [ordered]@{ lang = (Get-Attr ([regex]::Match($Html, '<html[^>]*>').Value) 'lang'); register = (Get-Attr $body 'data-register'); updated = (Get-Attr $body 'data-updated'); history = @(); risks = @(); optout = $null }
  $section = [regex]::Match($Html, '<section class="opt-out"([^>]*)>')
  if ($section.Success) {
    $a = $section.Groups[1].Value
    $model.optout = [ordered]@{ reason = (Get-Attr $a 'data-reason'); where = (Get-Attr $a 'data-where'); by = (Get-Attr $a 'data-by'); date = (Get-Attr $a 'data-date') }
  }
  $model.history = @(Read-Lines ([regex]::Match($Html, '(?s)<ol class="register-history">(.*?)</ol>').Groups[1].Value))
  $risks = @()
  foreach ($m in [regex]::Matches($Html, '(?s)<article class="risk"(?<attrs>[^>]*)>(?<body>.*?)</article>')) {
    $a = $m.Groups['attrs'].Value; $b = $m.Groups['body'].Value
    $risk = [ordered]@{
      id = (Get-Attr $a 'id'); state = (Get-Attr $a 'data-state'); impact = (Get-Attr $a 'data-impact'); probability = (Get-Attr $a 'data-probability')
      owner = (Get-Attr $a 'data-owner'); area = (Get-Attr $a 'data-area'); created = (Get-Attr $a 'data-created'); changed = (Get-Attr $a 'data-changed')
      name = (ConvertFrom-Html ([regex]::Match($b, '(?s)<span class="risk-name">(.*?)</span>').Groups[1].Value))
      description = (ConvertFrom-Html ([regex]::Match($b, '(?s)<p class="risk-desc">(.*?)</p>').Groups[1].Value))
      mitigation = (ConvertFrom-Html ([regex]::Match($b, '(?s)<p class="risk-mitigation">(.*?)</p>').Groups[1].Value))
      history = @()
    }
    $risk.history = @(Read-Lines ([regex]::Match($b, '(?s)<ol class="risk-history">(.*?)</ol>').Groups[1].Value) | ForEach-Object {
      $l = [ordered]@{ date = $_.date; by = $_.by; kind = $_.kind; text = $_.text }
      if ($_.Contains('damaged')) { $l.damaged = $true }
      $l
    })
    $risks += $risk
  }
  $model.risks = $risks
  return $model
}

function Test-Same([string]$A, [string]$B) { return [string]::Equals($A, $B, [System.StringComparison]::Ordinal) }

# What stops a register being read in full; a duplicate identifier is not one (the next write renumbers it).
function Get-Problems($Model) {
  $problems = @()
  if ($Model.register -notin @('kept', 'opt-out')) { $problems += 'the page does not say whether a register is kept (data-register)' }
  if ($Model.updated -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems += 'the register has no last-updated date' }
  if ($Model.register -eq 'opt-out') {
    $o = $null; if ($Model.Contains('optout')) { $o = $Model.optout }
    if ($null -eq $o -or $OptOutReasons -cnotcontains $o.reason -or -not $o.by -or $o.date -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems += 'the opt-out has no reason, decider or date' }
    elseif ($o.reason -eq 'elsewhere' -and -not $o.where) { $problems += 'the opt-out says risks are handled elsewhere but not where' }
    if (@($Model.risks).Count -gt 0) { $problems += 'an opt-out page holds risks' }
  }
  if ($Model.Contains('markers') -and $Model.markers) { $problems += 'the page holds git conflict markers from a merge' }
  if (@($Model.history | Where-Object { -not $_.by }).Count -gt 0) { $problems += 'a line of the register history names no person' }
  if (@($Model.history | Where-Object { $_.Contains('damaged') }).Count -gt 0) { $problems += 'a line of the register history is damaged' }
  $i = 0
  foreach ($r in $Model.risks) {
    $i++
    $who = if ($r.id) { $r.id } else { "risk $i on the page" }
    if ($r.id -notmatch '^RISK-\d{3,}$') { $problems += "$who has no identifier of the form RISK-NNN" }
    if ($r.state -notin $States) { $problems += "$who has no state" }
    if (-not $r.name) { $problems += "$who has no name" }
    if (-not $r.owner) { $problems += "$who has no owner" }
    if ($r.impact -notmatch '^[1-5]$') { $problems += "$who has no impact from 1 to 5" }
    if ($r.probability -notmatch '^[1-5]$') { $problems += "$who has no probability from 1 to 5" }
    if ($r.created -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems += "$who has no created date" }
    if ($r.changed -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems += "$who has no changed date" }
    if (@($r.history).Count -eq 0) { $problems += "$who has no history" }
    if (@($r.history | Where-Object { -not $_.by }).Count -gt 0) { $problems += "a history line of $who names no person" }
    if (@($r.history | Where-Object { $_.Contains('damaged') }).Count -gt 0) { $problems += "a history line of $who is damaged" }
  }
  return $problems
}

function Read-Register([string]$Page) {
  try { $html = [System.IO.File]::ReadAllText($Page, $Utf8) } catch { Exit-Unreadable "The register $Page cannot be read: $($_.Exception.Message)" }
  $model = Read-PageModel $html
  # git conflict markers left by a merge: the page cannot be read in full until the repair (T010)
  $model.markers = ([regex]::IsMatch($html, '(?m)^<{7}(\s|$)') -and [regex]::IsMatch($html, '(?m)^>{7}(\s|$)'))
  return $model
}

# ---------------------------------------------------------------- areas (RL13)

function Get-AreaKey([string]$Area) { return ($Area.ToLowerInvariant() -replace '[^\p{L}\p{Nd}]', '') }

function Get-Distance([string]$A, [string]$B) {
  $prev = New-Object 'int[]' ($B.Length + 1)
  for ($j = 0; $j -le $B.Length; $j++) { $prev[$j] = $j }
  for ($i = 1; $i -le $A.Length; $i++) {
    $cur = New-Object 'int[]' ($B.Length + 1)
    $cur[0] = $i
    for ($j = 1; $j -le $B.Length; $j++) {
      $cost = 1
      if ($A[$i - 1] -eq $B[$j - 1]) { $cost = 0 }
      $up = $prev[$j] + 1; $left = $cur[$j - 1] + 1; $diag = $prev[$j - 1] + $cost
      $cur[$j] = [Math]::Min([Math]::Min($up, $left), $diag)
    }
    $prev = $cur
  }
  return $prev[$B.Length]
}

# Whole texts, never word by word: equal after ignoring case, spaces, hyphens and punctuation, or
# one letter apart when both are four letters or more.
function Test-NearlySame([string]$A, [string]$B) {
  $ka = Get-AreaKey $A; $kb = Get-AreaKey $B
  if ([string]::Equals($ka, $kb, [System.StringComparison]::Ordinal)) { return $true }
  if ($ka.Length -lt 4 -or $kb.Length -lt 4) { return $false }
  return ((Get-Distance $ka $kb) -eq 1)
}

function Get-Areas($Model) {
  # unique by ordinal comparison: "Schedule" and "schedule" are two areas to show, never one
  $set = New-Object System.Collections.Generic.HashSet[string] ([System.StringComparer]::Ordinal)
  foreach ($r in $Model.risks) { if ($r.area) { [void]$set.Add($r.area) } }
  $list = New-Object System.Collections.Generic.List[string] (,[string[]]@($set))
  # alphabetical without regard to case, case only as a tie-break; ordinal, so both editions agree
  $list.Sort([System.Comparison[string]] { param($a, $b) $c = [string]::Compare($a, $b, [System.StringComparison]::OrdinalIgnoreCase); if ($c -ne 0) { $c } else { [string]::CompareOrdinal($a, $b) } })
  return @($list)
}

# ---------------------------------------------------------------- write

# Render to <page>.new, read it back, compare with the intended model and with what the page held,
# then rename into place. Anything short of the rename deletes the .new.
function Write-Register([string]$Page, $Model, $Held, [switch]$Fill) {
  $dir = Split-Path -Parent $Page
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $repoName = Split-Path -Leaf (Split-Path -Parent $dir)
  $html = Format-Page (Read-Template) $Model $repoName
  $new = $Page + '.new'
  $renamed = $false
  try {
    [System.IO.File]::WriteAllText($new, $html, $Utf8)
    $back = Read-PageModel ([System.IO.File]::ReadAllText($new, $Utf8))
    $problem = $null
    if ($html -match '\{\{') { $problem = 'a placeholder was left unfilled' }
    elseif (-not (Test-Same (Format-Model $back) (Format-Model $Model))) { $problem = 'the written page does not read back as the change' }
    elseif (Test-Unsigned $back) { $problem = "a history line names no person" }
    else { $problem = Test-Kept $Held $back -Fill:$Fill }
    if ($problem) { Exit-Refused "Not written: $problem. The register is as it was." }
    if (Test-Path -LiteralPath $Page) { [System.IO.File]::Replace($new, $Page, [NullString]::Value) } else { [System.IO.File]::Move($new, $Page) }
    $renamed = $true
  } finally {
    if (-not $renamed -and (Test-Path -LiteralPath $new)) { Remove-Item -LiteralPath $new -Force }
  }
}

# Every history line, of the register and of every risk, names the person who made it (R25).
function Test-Unsigned($Model) {
  if (@($Model.history | Where-Object { -not $_.by }).Count -gt 0) { return $true }
  foreach ($r in $Model.risks) { if (@($r.history | Where-Object { -not $_.by }).Count -gt 0) { return $true } }
  return $false
}

# The new page keeps every risk and every history line the page held (after renumbering), and
# holds no identifier twice.
function Test-Kept($Held, $New, [switch]$Fill) {
  $ids = @($New.risks | ForEach-Object { $_.id })
  $dups = @($ids | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
  if ($dups.Count -gt 0) { return "the new page holds $($dups -join ', ') twice" }
  if ($null -eq $Held) { return $null }
  foreach ($r in $Held.risks) {
    $now = @($New.risks | Where-Object { Test-Same $_.id $r.id })
    if ($now.Count -eq 0) { return "the new page drops $($r.id)" }
    $old = @($r.history); $cur = @($now[0].history)
    if ($cur.Count -lt $old.Count) { return "the new page drops a history line of $($r.id)" }
    for ($k = 0; $k -lt $old.Count; $k++) { if (-not (Test-LineKept $old[$k] $cur[$k] $Fill)) { return "the new page changes a history line of $($r.id)" } }
  }
  # the register's history is newest first: what the page held is the tail of the new list
  $old = @($Held.history); $cur = @($New.history)
  if ($cur.Count -lt $old.Count) { return 'the new page drops a line of the register history' }
  $offset = $cur.Count - $old.Count
  for ($k = 0; $k -lt $old.Count; $k++) { if (-not (Test-LineKept $old[$k] $cur[$k + $offset] $Fill)) { return 'the new page changes a line of the register history' } }
  return $null
}

# A history line is kept as it was; in a repair a line with no person may gain one, and nothing else.
function Test-LineKept($Old, $Cur, [bool]$Fill) {
  if (-not $Fill) { return (Test-Same (Get-LineKey $Old) (Get-LineKey $Cur)) }
  # in a repair a field the line lost (person, kind, date) may be given back; nothing it held may change
  foreach ($f in 'date', 'by', 'kind', 'text') { if ($Old[$f] -and -not (Test-Same ([string]$Old[$f]) ([string]$Cur[$f]))) { return $false } }
  return $true
}

# ---------------------------------------------------------------- numbering (RL3, RL4)

function Get-Number([string]$Id) { if ($Id -match '^RISK-(\d+)$') { return [int]$Matches[1] } return 0 }

function Format-Id([int]$N) { return 'RISK-' + $N.ToString('000', [System.Globalization.CultureInfo]::InvariantCulture) }

function Get-NextNumber($Model) {
  $max = 0
  foreach ($r in $Model.risks) { $n = Get-Number $r.id; if ($n -gt $max) { $max = $n } }
  return $max + 1
}

# Every identifier held twice keeps its earliest-created risk (on the same day, the upper one on the
# page); each other gets the next number and a renumber line. Returns what was renumbered.
function Invoke-Renumber($Model, [string]$Person) {
  $done = @()
  $risks = @($Model.risks)
  $groups = @($risks | Group-Object { $_.id } | Where-Object { $_.Count -gt 1 })
  foreach ($g in $groups) {
    $order = @(0..($risks.Count - 1) | Where-Object { $risks[$_].id -eq $g.Name } | Sort-Object @{ Expression = { $risks[$_].created } }, @{ Expression = { $_ } })
    foreach ($idx in $order[1..($order.Count - 1)]) {
      $old = $risks[$idx].id
      $risks[$idx].id = Format-Id (Get-NextNumber $Model)
      $risks[$idx].history = @($risks[$idx].history) + @([ordered]@{ date = $Today; by = $Person; kind = 'renumber'; text = "Renumbered from $old" })
      $done += "$old renumbered to $($risks[$idx].id)"
    }
  }
  return $done
}

# ---------------------------------------------------------------- the change

function Test-Required($Fields) {
  $missing = @()
  foreach ($f in 'name', 'owner') { if (-not (Get-Text (Get-Field $Fields $f))) { $missing += $f } }
  foreach ($f in 'impact', 'probability') { if ((Get-Text (Get-Field $Fields $f)) -notmatch '^[1-5]$') { $missing += "$f (1 to 5)" } }
  if ($missing.Count -gt 0) { Exit-Refused ('A risk needs a name, an owner, an impact and a probability; missing: ' + ($missing -join ', ') + '. Nothing written.') }
}

# The score is rendered from impact and probability, never given (RL2).
function Test-NoScore($ChangeData) {
  if ($null -ne (Get-Field $ChangeData 'score') -or $null -ne (Get-Field (Get-Field $ChangeData 'fields') 'score')) {
    Exit-Refused 'A score is never given: it is impact times probability. Give those instead. Nothing written.'
  }
}

# The current register, readable in full and with its duplicates renumbered, plus the same again
# as the baseline the write's check holds the new page to.
function Get-Current([string]$Page, [string]$Person) {
  $model = Read-Register $Page
  $problems = @(Get-Problems $model)
  if ($problems.Count -gt 0) { Exit-Refused ('The register cannot be read in full (' + ($problems -join '; ') + '); run -Repair first. Nothing written.') }
  $renumbered = @(Invoke-Renumber $model $Person)
  $held = Read-Register $Page
  Invoke-Renumber $held $Person | Out-Null
  return @{ Model = $model; Held = $held; Renumbered = $renumbered }
}

function Invoke-Add([string]$Page, $ChangeData, [string]$Person) {
  Test-NoScore $ChangeData
  $fields = Get-Field $ChangeData 'fields'
  Test-Required $fields
  $held = $null; $renumbered = @(); $replaced = $null
  if (Test-Path -LiteralPath $Page) {
    $current = Get-Current $Page $Person
    $model = $current.Model; $held = $current.Held; $renumbered = $current.Renumbered
    # the first risk replaces an opt-out, and the register remembers what it replaced (R23)
    if ($model.register -eq 'opt-out') { $replaced = $model.optout; $model.register = 'kept'; $model.optout = $null }
  } else {
    $lang = Get-Text (Get-Field $ChangeData 'language')
    if (-not $lang) { Exit-Refused 'The first write names the project language (language). Nothing written.' }
    $model = New-Register $lang
  }
  $risk = [ordered]@{
    id = (Format-Id (Get-NextNumber $model)); state = 'Active'; impact = (Get-Text (Get-Field $fields 'impact')); probability = (Get-Text (Get-Field $fields 'probability'))
    owner = (Get-Text (Get-Field $fields 'owner')); area = (Get-Text (Get-Field $fields 'area')); created = $Today; changed = $Today
    name = (Get-Text (Get-Field $fields 'name')); description = (Get-Text (Get-Field $fields 'description')); mitigation = (Get-Text (Get-Field $fields 'mitigation'))
    history = @()
  }
  # the name goes into the first line, which never changes, so a merge can tell two new risks apart
  $risk.history = @([ordered]@{ date = $Today; by = $Person; kind = 'created'; text = "Created: $($risk.name). Impact $($risk.impact), Probability $($risk.probability) (score $(Get-Score $risk))." })
  $model.risks = @($model.risks) + @($risk)
  if ($null -ne $replaced) {
    $line = [ordered]@{ date = $Today; by = $Person; kind = 'replaced-opt-out'; with = ''; text = "Register created with $($risk.id), replacing the opt-out ($($replaced.reason)) decided by $($replaced.by) on $($replaced.date): $(Format-OptOutReason $replaced)" }
  } elseif ($null -eq $held) {
    $line = [ordered]@{ date = $Today; by = $Person; kind = 'created'; with = ''; text = "Register created with $($risk.id). Project language: $($model.lang)." }
  } else {
    # the register line says what it is about, so two sides writing on one day stay two lines in a merge
    $text = "$($risk.id) registered: $($risk.name)."
    if ($renumbered.Count -gt 0) { $text += ' ' + ($renumbered -join '; ') + '.' }
    $line = [ordered]@{ date = $Today; by = $Person; kind = 'write'; with = ''; text = $text }
  }
  $model.history = @($line) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $held
  Write-Output "$($risk.id) written."
}

$FieldNames = @('name', 'owner', 'impact', 'probability', 'area', 'description', 'mitigation')

# Any of the seven fields, in any state; the state is never touched (R29, RL8).
function Invoke-Change([string]$Page, $ChangeData, [string]$Person) {
  Test-NoScore $ChangeData
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Refused 'There is no register yet; register a risk first. Nothing written.' }
  $target = Get-Text (Get-Field $ChangeData 'target')
  $fields = Get-Field $ChangeData 'fields'
  $given = @()
  if ($null -ne $fields) { $given = @($fields.PSObject.Properties | ForEach-Object { $_.Name }) }
  $unknown = @($given | Where-Object { $FieldNames -cnotcontains $_ })
  if ($unknown.Count -gt 0) { Exit-Refused ('A change carries only ' + ($FieldNames -join ', ') + '; not ' + ($unknown -join ', ') + '. Nothing written.') }
  if ($given.Count -eq 0) { Exit-Refused 'The change names no field. Nothing written.' }
  $current = Get-Current $Page $Person
  $model = $current.Model
  $risk = @($model.risks | Where-Object { [string]::Equals($_.id, $target, [System.StringComparison]::Ordinal) })
  if (-not $target) { Exit-Refused "The change names no target (RISK-NNN). Nothing written." }
  if ($risk.Count -eq 0) { Exit-Refused "The register holds no $target. Nothing written." }
  $risk = $risk[0]
  $parts = @()
  foreach ($f in $FieldNames) {
    if ($given -cnotcontains $f) { continue }
    $value = Get-Text (Get-Field $fields $f)
    if ($f -in @('name', 'owner') -and -not $value) { Exit-Refused "A risk keeps its $f; it cannot be emptied. Nothing written." }
    if ($f -in @('impact', 'probability') -and $value -notmatch '^[1-5]$') { Exit-Refused "The $f is a whole number from 1 to 5. Nothing written." }
    if ([string]::Equals([string]$risk[$f], $value, [System.StringComparison]::Ordinal)) { continue }
    if ($f -eq 'mitigation' -and -not $value -and $risk.state -eq 'Mitigated') { Exit-Refused "$target is Mitigated, so its mitigation cannot be emptied; set it back to Active first. Nothing written." }
    $old = if ($risk[$f]) { $risk[$f] } else { 'none' }
    $new = if ($value) { $value } else { 'none' }
    $parts += (($f.Substring(0, 1).ToUpperInvariant() + $f.Substring(1)) + ' ' + $old + ' ' + $Arrow + ' ' + $new)
    $risk[$f] = $value
  }
  if ($parts.Count -eq 0) { Exit-Refused "The change leaves $target as it is. Nothing written." }
  $risk.changed = $Today
  $risk.history = @($risk.history) + @([ordered]@{ date = $Today; by = $Person; kind = 'change'; text = (($parts -join '; ') + '.') })
  $text = "$target changed: " + ($parts -join "; ") + "."
  if ($current.Renumbered.Count -gt 0) { $text += ' ' + ($current.Renumbered -join '; ') + '.' }
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'write'; with = ''; text = $text }) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $current.Held
  Write-Output "$target written."
}

# Every state is a person's decision with a reason; Mitigated needs a mitigation, Accepted a decider;
# any state can be set from any other, under the same identifier (RL5, RL6, RL7, RL17).
function Invoke-State([string]$Page, $ChangeData, [string]$Person) {
  Test-NoScore $ChangeData
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Refused 'There is no register yet; register a risk first. Nothing written.' }
  $target = Get-Text (Get-Field $ChangeData 'target')
  if (-not $target) { Exit-Refused 'The change names no target (RISK-NNN). Nothing written.' }
  $state = Get-Field $ChangeData 'state'
  $to = Get-Text (Get-Field $state 'to')
  $reason = Get-Text (Get-Field $state 'reason')
  $decider = Get-Text (Get-Field $state 'decider')
  $match = @($States | Where-Object { Test-Same $_ $to })
  if ($match.Count -eq 0) { Exit-Refused ("The state is one of " + ($States -join ', ') + "; not '$to'. Nothing written.") }
  $current = Get-Current $Page $Person
  $model = $current.Model
  $risk = @($model.risks | Where-Object { Test-Same $_.id $target })
  if ($risk.Count -eq 0) { Exit-Refused "The register holds no $target. Nothing written." }
  $risk = $risk[0]
  if (Test-Same $risk.state $to) { Exit-Refused "$target is already $to. Nothing written." }
  if (-not $reason) { Exit-Refused "Setting $target to $to needs a reason. Nothing written." }
  if ($to -eq 'Mitigated' -and -not $risk.mitigation) { Exit-Refused "Setting $target to Mitigated needs its mitigation written first. Nothing written." }
  if ($to -eq 'Accepted' -and -not $decider) { Exit-Refused "Setting $target to Accepted needs the name of the person who decided it. Nothing written." }
  $text = "$($risk.state) $Arrow ${to}: $reason"
  if ($text -notmatch '[.?!]$') { $text += '.' }
  if ($decider) { $text += " Decided by $decider." }
  $risk.state = $to
  $risk.changed = $Today
  $risk.history = @($risk.history) + @([ordered]@{ date = $Today; by = $Person; kind = 'state'; text = $text })
  $line = "$target $($to.ToLowerInvariant()): $reason"
  if ($line -notmatch "[.?!]$") { $line += "." }
  if ($current.Renumbered.Count -gt 0) { $line += ' ' + ($current.Renumbered -join '; ') + '.' }
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'write'; with = ''; text = $line }) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $current.Held
  Write-Output "$target written."
}

# Every open risk of a leaving owner to a named successor in one write, each with its own line (R28).
function Invoke-Handover([string]$Page, $ChangeData, [string]$Person) {
  Test-NoScore $ChangeData
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Refused 'There is no register yet; register a risk first. Nothing written.' }
  $from = Get-Text (Get-Field $ChangeData 'target')
  $to = Get-Text (Get-Field $ChangeData 'to')
  if (-not $from) { Exit-Refused 'A handover names the owner whose risks move (target). Nothing written.' }
  if (-not $to) { Exit-Refused 'A handover names the person the risks move to (to). Nothing written.' }
  if (Test-Same $from $to) { Exit-Refused "$from already owns those risks. Nothing written." }
  $current = Get-Current $Page $Person
  $model = $current.Model
  $open = @($model.risks | Where-Object { $_.state -ne 'Resolved' -and (Test-Same $_.owner.Trim() $from) })
  if ($open.Count -eq 0) { Exit-Refused "$from has no open risks; nothing to hand over. Nothing written." }
  foreach ($risk in $open) {
    $risk.owner = $to
    $risk.changed = $Today
    $risk.history = @($risk.history) + @([ordered]@{ date = $Today; by = $Person; kind = 'handover'; text = "Handed over from $from to $to." })
  }
  $line = "Open risks of $from handed over to ${to}: " + (($open | ForEach-Object { $_.id }) -join ', ') + '.'
  if ($current.Renumbered.Count -gt 0) { $line += ' ' + ($current.Renumbered -join '; ') + '.' }
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'write'; with = ''; text = $line }) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $current.Held
  Write-Output ((($open | ForEach-Object { $_.id }) -join ', ') + ' written.')
}

# A confirmed review: one register-history line, the last-updated date, and no risk touched (RL9).
function Invoke-Review([string]$Page, $ChangeData, [string]$Person) {
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Refused 'There is no register to review: register a risk or record an opt-out first. Nothing written.' }
  $with = @(@(Get-Field $ChangeData 'with') | ForEach-Object { Get-Text $_ } | Where-Object { $_ })
  $current = Get-Current $Page $Person
  $model = $current.Model
  if ($model.register -eq 'opt-out') { Exit-Refused 'No register is kept here (an opt-out); there is nothing to review. Register a risk to start one. Nothing written.' }
  # a review adds no line to any risk (RL10), so duplicates wait for the repair, which renumbers them
  if ($current.Renumbered.Count -gt 0) { Exit-Refused 'The register holds the same identifier twice; run -Repair first, which renumbers it. Nothing written.' }
  $text = 'Reviewed'
  if ($with.Count -gt 0) { $text += ', with ' + ($with -join ', ') }
  $text += '.'
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'review'; with = ($with -join ', '); text = $text }) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $current.Held
  Write-Output 'Review written.'
}

# ---------------------------------------------------------------- repair (RL11, NF4, D101 section 6.7)

function Get-LineKey($Line) { return "$($Line.date)|$($Line.by)|$($Line.kind)|$($Line.text)" }

# Lines by date, newest first, keeping the given order among lines of one date (5.1's sort is not stable).
function Get-ByDate($Lines, [switch]$Oldest) {
  $i = 0
  $tagged = @($Lines | ForEach-Object { $i++; [pscustomobject]@{ n = $i; d = $_.date; line = $_ } })
  return @($tagged | Sort-Object @{ Expression = { $_.d }; Descending = (-not $Oldest) }, @{ Expression = { $_.n } } | ForEach-Object { $_.line })
}

# The two sides of a conflicted page, read from git's index (:2: ours, :3: theirs), and nothing else.
function Read-Sides([string]$Page) {
  $dir = Split-Path -Parent $Page; $leaf = Split-Path -Leaf $Page
  $sides = @()
  foreach ($stage in 2, 3) {
    $text = $null
    try { $text = (& git -C $dir show ":${stage}:./$leaf" 2>$null) -join "`n" } catch { $text = $null }
    if (-not $text) { Exit-Refused "The page holds conflict markers but git has no side $stage of it; finish or abort the merge in git first. Nothing written." }
    $sides += , (Read-PageModel $text)
  }
  return $sides
}

# Both sides merged by identifier: a risk on one side is kept; the same risk (same name, first history line
# and the same created date) on both is one risk whose differing fields become questions; two risks under one identifier stay two,
# and the renumbering settles them. Every history line of either side is kept.
# Two histories of one thing joined: the lines both sides share are their common start (oldest first)
# and are kept once; every line after it is a side's own and is kept, even one identical to a line of
# the other side, since the same words on the same day can be two events.
function Join-Histories($A, $B, [switch]$NewestFirst) {
  $a = @($A); $b = @($B)
  if ($NewestFirst) { [array]::Reverse($a); [array]::Reverse($b) }
  $n = 0
  while ($n -lt $a.Count -and $n -lt $b.Count -and (Test-Same (Get-LineKey $a[$n]) (Get-LineKey $b[$n]))) { $n++ }
  $shared = @(); if ($n -gt 0) { $shared = @($a[0..($n - 1)]) }
  $own = @(); if ($a.Count -gt $n) { $own += @($a[$n..($a.Count - 1)]) }; if ($b.Count -gt $n) { $own += @($b[$n..($b.Count - 1)]) }
  $joined = @($shared) + @(Get-ByDate $own -Oldest)
  if ($NewestFirst) { [array]::Reverse($joined) }
  return $joined
}

function Merge-Sides($Ours, $Theirs) {
  $questions = @()
  $model = [ordered]@{ lang = $Ours.lang; register = 'kept'; updated = (@($Ours.updated, $Theirs.updated) | Sort-Object)[-1]; history = @(); risks = @(); optout = $null }
  # a risk on either side makes the register kept (a risk is never deleted); two opt-outs stay an opt-out
  if ($Ours.register -eq 'opt-out' -and $Theirs.register -eq 'opt-out') { $model.register = 'opt-out'; $model.optout = $Ours.optout }
  elseif ($Ours.register -eq 'opt-out' -and @($Ours.risks).Count -eq 0 -and $Theirs.register -ne 'kept') { $model.register = 'opt-out'; $model.optout = $Ours.optout }
  $model.history = Join-Histories $Ours.history $Theirs.history -NewestFirst
  $used = @()
  $risks = @()
  foreach ($r in $Ours.risks) {
    $first = $r.created + "|" + $r.name + "|" + $(if (@($r.history).Count -gt 0) { Get-LineKey @($r.history)[0] } else { "" })
    $k = -1
    for ($j = 0; $j -lt @($Theirs.risks).Count; $j++) {
      $t = @($Theirs.risks)[$j]
      if ($used -ccontains $j -or -not (Test-Same $t.id $r.id)) { continue }
      $tFirst = $t.created + "|" + $t.name + "|" + $(if (@($t.history).Count -gt 0) { Get-LineKey @($t.history)[0] } else { "" })
      if (Test-Same $tFirst $first) { $k = $j; break }
    }
    if ($k -lt 0) { $risks += $r; continue }
    $used += $k
    $t = @($Theirs.risks)[$k]
    foreach ($f in @('state') + $FieldNames) {
      if (-not (Test-Same ([string]$r[$f]) ([string]$t[$f]))) {
        $questions += [ordered]@{ key = "$($r.id)#$($risks.Count)/$f"; target = $r.id; field = $f; name = $r.name; index = $risks.Count; before = @([string]$r[$f], [string]$t[$f]); after = $null; ask = $true; note = 'differs between the two sides of the merge; with no common base, either side may be the one that changed it' }
      }
    }
    $r.history = Join-Histories $r.history $t.history
    $r.changed = (@($r.changed, $t.changed) | Sort-Object)[-1]
    $risks += $r
  }
  for ($j = 0; $j -lt @($Theirs.risks).Count; $j++) { if ($used -cnotcontains $j) { $risks += @($Theirs.risks)[$j] } }
  $model.risks = $risks
  return @{ Model = $model; Questions = $questions }
}

# What a repair would change, as before and after: the merge's questions, the renumbering of
# true duplicates, and one entry per field a hand edit broke. Asked values carry after = null.
function Get-RepairPlan([string]$Page) {
  $model = Read-Register $Page
  $changes = @()
  $merged = $false
  if ($model.Contains('markers') -and $model.markers) {
    $sides = Read-Sides $Page
    $m = Merge-Sides $sides[0] $sides[1]
    $model = $m.Model; $changes += $m.Questions; $merged = $true
  }
  # true duplicates: the earliest-created keeps the identifier (ties: the one first on the page)
  $risks = @($model.risks)
  $next = Get-NextNumber $model
  foreach ($g in @($risks | Group-Object { $_.id } | Where-Object { $_.Count -gt 1 })) {
    $order = @(0..($risks.Count - 1) | Where-Object { Test-Same $risks[$_].id $g.Name } | Sort-Object @{ Expression = { $risks[$_].created } }, @{ Expression = { $_ } })
    $n = 0
    foreach ($idx in $order[1..($order.Count - 1)]) {
      $n++
      $changes += [ordered]@{ key = "$($g.Name)#$n"; target = $g.Name; field = 'id'; name = $risks[$idx].name; index = $idx; before = $g.Name; after = (Format-Id $next); ask = $false; note = 'the same identifier twice' }
      $next++
    }
  }
  # every key carries the risk's place on the page, so two risks under one identifier never share an answer
  $i = 0
  foreach ($r in $risks) {
    $who = if ($r.id) { $r.id } else { "risk $($i + 1) on the page" }
    $at = "$who#$i"
    if ($r.id -notmatch '^RISK-\d{3,}$') { $changes += [ordered]@{ key = "$at/id"; target = $who; field = 'id'; name = $r.name; index = $i; before = [string]$r.id; after = (Format-Id $next); ask = $false; note = 'no identifier of the form RISK-NNN; the next free one' }; $next++ }
    foreach ($f in 'name', 'owner') { if (-not $r[$f]) { $changes += [ordered]@{ key = "$at/$f"; target = $who; field = $f; name = $r.name; index = $i; before = ''; after = $null; ask = $true; note = 'missing' } } }
    foreach ($f in 'impact', 'probability') { if ($r[$f] -notmatch '^[1-5]$') { $changes += [ordered]@{ key = "$at/$f"; target = $who; field = $f; name = $r.name; index = $i; before = [string]$r[$f]; after = $null; ask = $true; note = 'not a whole number from 1 to 5' } } }
    if ($r.state -notin $States -and -not $merged) { $changes += [ordered]@{ key = "$at/state"; target = $who; field = 'state'; name = $r.name; index = $i; before = [string]$r.state; after = $null; ask = $true; note = 'not a state' } }
    $lines = @($r.history)
    if ($r.created -notmatch '^\d{4}-\d{2}-\d{2}$' -and $lines.Count -gt 0) { $changes += [ordered]@{ key = "$at/created"; target = $who; field = 'created'; name = $r.name; index = $i; before = [string]$r.created; after = $lines[0].date; ask = $false; note = 'from its first history line' } }
    if ($r.changed -notmatch '^\d{4}-\d{2}-\d{2}$' -and $lines.Count -gt 0) { $changes += [ordered]@{ key = "$at/changed"; target = $who; field = 'changed'; name = $r.name; index = $i; before = [string]$r.changed; after = $lines[-1].date; ask = $false; note = 'from its last history line' } }
    for ($k = 0; $k -lt $lines.Count; $k++) {
      if (-not $lines[$k].by) { $changes += [ordered]@{ key = "$at/history/$k/by"; target = $who; field = "history/$k/by"; name = $r.name; index = $i; before = ''; after = $null; ask = $true; note = "the person of its history line of $($lines[$k].date)" } }
      if ($lines[$k].Contains('damaged')) { $changes += Get-LineRepair $lines[$k] "$at/history/$k" $who "history/$k" $r.name $i "its history line" }
    }
    $i++
  }
  $reg = @($model.history)
  for ($k = 0; $k -lt $reg.Count; $k++) {
    if (-not $reg[$k].by) { $changes += [ordered]@{ key = "register/history/$k/by"; target = 'register'; field = "history/$k/by"; name = ''; before = ''; after = $null; ask = $true; note = "the person of the register's line of $($reg[$k].date)" } }
    if ($reg[$k].Contains('damaged')) { $changes += Get-LineRepair $reg[$k] "register/history/$k" 'register' "history/$k" '' $null "the register's line" }
  }
  # a merge is a change of its own, so the joined register is written even when nothing is asked
  if ($merged) { $changes += [ordered]@{ key = 'register/merge'; target = 'register'; field = 'merge'; name = ''; before = 'two sides of a git merge'; after = 'one register'; ask = $false; note = 'the sides of the merge joined by identifier, every line of both kept' } }
  if ($model.updated -notmatch '^\d{4}-\d{2}-\d{2}$') { $changes += [ordered]@{ key = 'register/updated'; target = 'register'; field = 'updated'; name = ''; before = [string]$model.updated; after = $(if ($reg.Count -gt 0) { $reg[0].date } else { $Today }); ask = $false; note = 'from its newest history line' } }
  if ($model.register -notin @('kept', 'opt-out')) { $changes += [ordered]@{ key = 'register/register'; target = 'register'; field = 'register'; name = ''; before = [string]$model.register; after = $(if ($risks.Count -gt 0) { 'kept' } else { 'opt-out' }); ask = $false; note = 'from what the page holds' } }
  if ($model.register -eq 'opt-out') {
    if ($risks.Count -gt 0) {
      # a risk is never deleted, so a page holding risks is a register, whatever it says
      $changes += [ordered]@{ key = 'register/register'; target = 'register'; field = 'register'; name = ''; before = 'opt-out'; after = 'kept'; ask = $false; note = 'the page holds risks, and a risk is never deleted' }
    } else {
      $o = $model.optout
      foreach ($f in 'reason', 'by', 'date') {
        $v = ''; if ($null -ne $o) { $v = [string]$o[$f] }
        $bad = ($f -eq 'reason' -and $OptOutReasons -cnotcontains $v) -or ($f -eq 'by' -and -not $v) -or ($f -eq 'date' -and $v -notmatch '^\d{4}-\d{2}-\d{2}$')
        if ($bad) { $changes += [ordered]@{ key = "register/optout/$f"; target = 'register'; field = "optout/$f"; name = ''; before = $v; after = $null; ask = $true; note = "the opt-out's $(if ($f -eq 'by') { 'decider' } else { $f })" } }
      }
      if ($null -ne $o -and $o.reason -eq 'elsewhere' -and -not $o.where) { $changes += [ordered]@{ key = 'register/optout/where'; target = 'register'; field = 'optout/where'; name = ''; before = ''; after = $null; ask = $true; note = 'where risks are handled' } }
    }
  }
  return @{ Model = $model; Changes = $changes }
}

# A damaged history line: restored from what is left of it (unasked), and its kind or date asked when
# nothing on the page holds them any more.
function Get-LineRepair($Line, [string]$Key, [string]$Target, [string]$Field, [string]$Name, $Index, [string]$What) {
  $out = @()
  $c = [ordered]@{ key = "$Key/text"; target = $Target; field = "$Field/text"; name = $Name; before = 'damaged'; after = $Line.text; ask = $false; note = "$What of $($Line.date), restored from what is left of it on the page" }
  if ($null -ne $Index) { $c.index = $Index }
  $out += $c
  foreach ($f in 'kind', 'date') {
    $bad = if ($f -eq 'kind') { -not $Line.kind } else { $Line.date -notmatch '^\d{4}-\d{2}-\d{2}$' }
    if ($bad) {
      $q = [ordered]@{ key = "$Key/$f"; target = $Target; field = "$Field/$f"; name = $Name; before = [string]$Line[$f]; after = $null; ask = $true; note = "the $f of $What `"$($Line.text)`", which the page no longer holds" }
      if ($null -ne $Index) { $q.index = $Index }
      $out += $q
    }
  }
  return $out
}

# Applies a plan to its model; with -AutoOnly only what needs no answer (the baseline the check holds).
function Set-Repair($Plan, $Answers, [string]$Person, [switch]$AutoOnly) {
  $model = $Plan.Model
  $risks = @($model.risks)
  $done = @()
  foreach ($c in $Plan.Changes) {
    if ($c.ask -and $AutoOnly) { continue }
    $value = $c.after
    if ($c.ask) {
      $a = @($Answers | Where-Object { Test-Same ([string](Get-Field $_ 'key')) $c.key })
      if ($a.Count -eq 0 -or -not (Get-Text (Get-Field $a[0] 'after'))) { Exit-Refused "The repair still asks for $($c.target) $($c.field) ($($c.note)). Nothing written." }
      $value = Get-Text (Get-Field $a[0] 'after')
    }
    if ($c.target -eq 'register') {
      if ($c.field -eq 'merge') { $done += 'the two sides of a git merge joined'; continue }
      if ($c.field -match '^history/(\d+)/(by|kind|date)$') { @($model.history)[[int]$Matches[1]][$Matches[2]] = $value }
      elseif ($c.field -match '^history/(\d+)/text$') { $l = @($model.history)[[int]$Matches[1]]; $l.text = $value; $l.Remove('damaged') }
      elseif ($c.field -match '^optout/(\w+)$') { if ($null -eq $model.optout) { $model.optout = [ordered]@{ reason = ''; where = ''; by = ''; date = '' } }; $model.optout[$Matches[1]] = $value }
      else {
        $model[$c.field] = $value
        if ($c.field -eq 'register' -and $value -eq 'kept') { $model.optout = $null }
      }
      $done += "register $($c.field) $(if ($c.before) { $c.before } else { '(missing)' }) $Arrow $value"
      continue
    }
    $risk = if ($c.Contains('index')) { $risks[$c.index] } else { @($risks | Where-Object { Test-Same $_.id $c.target })[0] }
    if ($c.field -eq 'id') {
      $risk.id = $value
      $from = if ($c.before) { $c.before } else { 'no identifier' }
      $risk.history = @($risk.history) + @([ordered]@{ date = $Today; by = $Person; kind = 'renumber'; text = "Renumbered from $from" })
    } elseif ($c.field -match '^history/(\d+)/(by|kind|date)$') {
      @($risk.history)[[int]$Matches[1]][$Matches[2]] = $value
    } elseif ($c.field -match '^history/(\d+)/text$') {
      $l = @($risk.history)[[int]$Matches[1]]; $l.text = $value; $l.Remove('damaged')
    } else {
      $risk[$c.field] = $value
    }
    $before = if ($c.before -is [array]) { ($c.before -join ' / ') } elseif ($c.before) { $c.before } else { '(missing)' }
    $done += "$($c.target) $($c.field) $before $Arrow $value"
  }
  return $done
}

function Invoke-RepairProposal([string]$Page) {
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Refused "No register at $Path; there is nothing to repair." }
  $plan = Get-RepairPlan $Page
  $problems = @(Get-Problems (Read-Register $Page))
  $ids = @($plan.Changes | Where-Object { $_.field -eq 'id' })
  if ($ids.Count -gt 0) { $problems += 'the same identifier twice' }
  Write-Output (ConvertTo-Json -InputObject ([ordered]@{ problems = $problems; changes = @($plan.Changes) }) -Depth 6)
}

# A confirmed repair: the plan again, the answers the proposal carries, the same .new, check and rename.
function Invoke-RepairWrite([string]$Page, $ChangeData, [string]$Person) {
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Refused "No register at $Path; there is nothing to repair. Nothing written." }
  $answers = @(Get-Field (Get-Field $ChangeData 'proposal') 'changes')
  $held = Get-RepairPlan $Page
  Set-Repair $held @() $Person -AutoOnly | Out-Null
  $plan = Get-RepairPlan $Page
  $done = @(Set-Repair $plan $answers $Person)
  if ($done.Count -eq 0) {
    $left = @(Get-Problems (Read-Register $Page))
    if ($left.Count -gt 0) { Exit-Refused ('The repair cannot settle this by itself: ' + ($left -join '; ') + '. Edit the page by hand and run -Repair again. Nothing written.') }
    Exit-Refused 'The register needs no repair. Nothing written.'
  }
  $model = $plan.Model
  $problems = @(Get-Problems $model)
  if ($problems.Count -gt 0) { Exit-Refused ('The repair would still leave: ' + ($problems -join '; ') + '. Nothing written.') }
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'repair'; with = ''; text = ('Repaired: ' + ($done -join '; ') + '.') }) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $held.Model -Fill
  Write-Output 'Repair written.'
}

# A .new left by an interrupted write: shown, then renamed into place if it passes the check, else deleted.
function Invoke-Finish([string]$Page, [string]$Person) {
  $new = $Page + '.new'
  if (-not (Test-Path -LiteralPath $new)) { Write-Output 'Nothing to finish.'; return }
  $current = $null
  if (Test-Path -LiteralPath $Page) { $current = Read-Register $Page }
  $html = [System.IO.File]::ReadAllText($new, $Utf8)
  $next = Read-PageModel $html
  $next.markers = ([regex]::IsMatch($html, '(?m)^<{7}(\s|$)') -and [regex]::IsMatch($html, '(?m)^>{7}(\s|$)'))
  $was = @(); if ($null -ne $current) { $was = @((Format-Model $current) -split "`n") }
  $now = @((Format-Model $next) -split "`n")
  $diff = @($now | Where-Object { $was -cnotcontains $_ } | ForEach-Object { "+ $_" }) + @($was | Where-Object { $now -cnotcontains $_ } | ForEach-Object { "- $_" })
  Write-Output ("$Path.new changes:`n" + ($diff -join "`n"))
  $problem = $null
  if ($html -match '\{\{') { $problem = 'a placeholder was left unfilled' }
  elseif (@(Get-Problems $next).Count -gt 0) { $problem = (@(Get-Problems $next) -join '; ') }
  elseif (Test-Unsigned $next) { $problem = 'a history line names no person' }
  else { $problem = Test-Kept $current $next }
  Remove-Item -LiteralPath $new -Force
  if ($problem) { Exit-Refused "Deleted $Path.new: $problem. The register is as it was." }
  $next.history = @([ordered]@{ date = $Today; by = $Person; kind = 'finish'; with = ''; text = 'Finished an interrupted write.' }) + @($next.history)
  $next.updated = $Today
  Write-Register $Page $next $current
  Write-Output 'Finished: the interrupted write is in place.'
}

# ---------------------------------------------------------------- the view (S2, P6)

$Width = 80
$Indent = ' ' * 16

# Words to lines no wider than the view; the first line starts with $First, the rest with the indent.
function Format-Wrapped([string]$Text, [string]$First) {
  $lines = @(); $line = $First; $room = $Width
  foreach ($word in ($Text -split '\s+' | Where-Object { $_ })) {
    while ($Indent.Length + $word.Length -gt $room) {
      # a word longer than a whole line is cut, never left to overflow
      $take = $room - $line.Length
      if ($take -lt 1) { $lines += $line.TrimEnd(); $line = $Indent; continue }
      $lines += $line + $word.Substring(0, $take); $word = $word.Substring($take); $line = $Indent
    }
    if (($line.Length + $word.Length) -gt $room -and $line.Trim()) { $lines += $line.TrimEnd(); $line = $Indent }
    $line += $word + ' '
  }
  $lines += $line.TrimEnd()
  return $lines
}

function Format-View($Model, [string]$Shown) {
  $out = New-Object System.Collections.Generic.List[string]
  $risks = @($Model.risks)
  $out.Add("Risk log $Dot $Shown")
  $out.Add("Updated $($Model.updated) $Dot $($risks.Count) risks")
  $out.Add((($States | ForEach-Object { $s = $_; "$(@($risks | Where-Object { $_.state -eq $s }).Count) $s" }) -join " $Dot "))
  $out.Add('')
  $rule = '  ' + ([string][char]0x2500 * ($Width - 2))
  $ordered = Get-Ordered $risks
  foreach ($s in $States) {
    $inState = @($ordered | Where-Object { $_.state -eq $s })
    if ($inState.Count -eq 0) { continue }
    if ($s -eq 'Resolved') { $out.Add("Resolved ($($inState.Count))"); $out.Add(''); continue }
    $out.Add($s)
    foreach ($r in $inState) {
      $score = (Get-Score $r).PadLeft(2)
      foreach ($l in (Format-Wrapped $r.name ('  ' + $r.id + '  ' + $score + '  '))) { $out.Add($l) }
      $area = if ($r.area) { $r.area } else { 'area none written' }
      foreach ($l in (Format-Wrapped "$($r.owner) $Dot $area $Dot I$($r.impact) P$($r.probability) $Dot changed $($r.changed)" $Indent)) { $out.Add($l) }
      if ($r.description) { foreach ($l in (Format-Wrapped $r.description $Indent)) { $out.Add($l) } } else { $out.Add($Indent + 'Description: none written') }
      if ($r.mitigation) { foreach ($l in (Format-Wrapped $r.mitigation '     Mitigation ')) { $out.Add($l) } } else { $out.Add('     Mitigation none written') }
      $out.Add($rule)
    }
    $out.Add('')
  }
  while ($out.Count -gt 0 -and $out[$out.Count - 1] -eq '') { $out.RemoveAt($out.Count - 1) }
  return ($out -join "`n")
}

function Invoke-View([string]$Page) {
  if (-not (Test-Path -LiteralPath $Page)) { Write-Output "No register and no opt-out at $Path."; return }
  $model = Read-Register $Page
  $problems = @(Get-Problems $model)
  # a missing field or person, or a damaged history line, is shown as the page holds it (no score
  # for no impact); anything that leaves no clear register to show (conflict markers, a risk with no
  # identifier or state, a broken opt-out) is refused
  $shown = '(has no (impact|probability|owner|name|created date|changed date|history)|names no person|is damaged)'
  $blocking = @($problems | Where-Object { $_ -notmatch $shown })
  if ($blocking.Count -gt 0) { Exit-Refused ('The register cannot be read in full (' + ($problems -join '; ') + '); run -Repair first.') }
  if ($model.register -eq 'opt-out') {
    $o = $model.optout
    $lines = @("Risk log $Dot $Path", 'No risk register kept here.', '')
    $lines += Format-Wrapped (Format-OptOutReason $o) ''
    $lines += "Decided by $($o.by) on $($o.date)."
    Write-Output ($lines -join "`n")
    return
  }
  Write-Output (Format-View $model $Path)
}

# Records that no register is kept here, why and who decided, in the register's place (RL15, R21, R22).
function Invoke-OptOut([string]$Page, $ChangeData, [string]$Person) {
  $o = Get-Field $ChangeData 'opt-out'
  $reason = Get-Text (Get-Field $o 'reason')
  $where = Get-Text (Get-Field $o 'where')
  $decider = Get-Text (Get-Field $o 'decider')
  if ($OptOutReasons -cnotcontains $reason) { Exit-Refused ("An opt-out's reason is one of " + ($OptOutReasons -join ', ') + "; not '$reason'. Nothing written.") }
  if ($reason -eq 'elsewhere' -and -not $where) { Exit-Refused 'An opt-out because risks are handled elsewhere names where (where). Nothing written.' }
  if (-not $decider) { Exit-Refused 'An opt-out names the person who decided it (decider). Nothing written.' }
  if (Test-Path -LiteralPath $Page) {
    $current = Read-Register $Page
    if ($current.register -eq 'opt-out') { Exit-Refused 'An opt-out is already recorded here. Nothing written.' }
    if (@(Get-Problems $current).Count -gt 0) { Exit-Refused 'The register cannot be read in full; run -Repair first. Nothing written.' }
    if (@($current.risks).Count -gt 0) { Exit-Refused 'The register holds risks, and a risk is never deleted: resolve the risks instead of opting out. Nothing written.' }
    Exit-Refused 'A register is kept here; an opt-out replaces no register. Nothing written.'
  }
  $lang = Get-Text (Get-Field $ChangeData 'language')
  if (-not $lang) { Exit-Refused 'The first write names the project language (language). Nothing written.' }
  $model = New-Register $lang
  $model.register = 'opt-out'
  $model.optout = [ordered]@{ reason = $reason; where = $where; by = $decider; date = $Today }
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'opt-out'; with = ''; text = "Opt-out recorded, decided by ${decider}: $(Format-OptOutReason $model.optout)" })
  Write-Register $Page $model $null
  Write-Output 'Opt-out written.'
}

function Invoke-Read([string]$Page) {
  if (-not (Test-Path -LiteralPath $Page)) {
    Write-Output (ConvertTo-Json -InputObject ([ordered]@{ lang = ''; register = 'none'; updated = ''; history = @(); risks = @(); areas = @(); problems = @() }) -Depth 4)
    return
  }
  $model = Read-Register $Page
  $areas = @(Get-Areas $model)
  $out = [ordered]@{
    lang = $model.lang; register = $model.register; updated = $model.updated
    history = @($model.history); risks = @($model.risks); areas = $areas; optout = $model.optout
    problems = @(Get-Problems $model)
  }
  if ($Area) { $out.nearly = @($areas | Where-Object { Test-NearlySame $_ $Area }) }
  Write-Output (ConvertTo-Json -InputObject $out -Depth 8)
}

# ---------------------------------------------------------------- main

$actions = @(@('Read', $Read), @('View', $View), @('Apply', $Apply), @('Repair', $Repair), @('Finish', $Finish)) | Where-Object { $_[1] } | ForEach-Object { $_[0] }
if (@($actions).Count -ne 1) {
  Write-Output 'Give exactly one action: -Read, -View, -Apply, -Repair or -Finish.'
  exit 2
}

$PagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

switch ($actions) {
  'Read' {
    Invoke-Read $PagePath
    exit 0
  }
  'View' {
    Invoke-View $PagePath
    exit 0
  }
  'Apply' {
    if (Test-Path -LiteralPath ($PagePath + '.new')) { Exit-Refused "An earlier write was interrupted: $Path.new is still there. Run -Finish first. Nothing written." }
    $data = Read-Change $Change
    $person = Get-Person
    switch (Get-Text (Get-Field $data 'verb')) {
      'add' { Invoke-Add $PagePath $data $person }
      'change' { Invoke-Change $PagePath $data $person }
      'state' { Invoke-State $PagePath $data $person }
      'handover' { Invoke-Handover $PagePath $data $person }
      'review' { Invoke-Review $PagePath $data $person }
      'optout' { Invoke-OptOut $PagePath $data $person }
      'repair' { Invoke-RepairWrite $PagePath $data $person }
      default { Exit-Unreadable "The verb '$(Get-Text (Get-Field $data 'verb'))' is not one of add, change, state, handover, review, optout, repair." }
    }
    exit 0
  }
  'Repair' {
    Invoke-RepairProposal $PagePath
    exit 0
  }
  'Finish' {
    $person = Get-Person
    Invoke-Finish $PagePath $person
    exit 0
  }
}
