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
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }

if (-not $PluginRoot) { $PluginRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }

$Utf8 = New-Object System.Text.UTF8Encoding $false
$Dot = [string][char]0x00B7
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
  if ($By) { return $By.Trim() }
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
  return [ordered]@{ lang = $Lang; register = 'kept'; updated = $Today; history = @(); risks = @() }
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

# ---------------------------------------------------------------- read back

function ConvertFrom-Html([string]$Value) { return [System.Net.WebUtility]::HtmlDecode($Value) }

function Get-Attr([string]$Tag, [string]$Name) {
  $m = [regex]::Match($Tag, '\s' + [regex]::Escape($Name) + '="([^"]*)"')
  if ($m.Success) { return (ConvertFrom-Html $m.Groups[1].Value) }
  return ''
}

function Read-Lines([string]$List) {
  $out = @()
  foreach ($m in [regex]::Matches($List, '(?s)<li(?<attrs>[^>]*)>.*?<span class="who">.*?</span> ' + $Dot + ' (?<text>.*?)</li>')) {
    $a = $m.Groups['attrs'].Value
    $out += [ordered]@{ date = (Get-Attr $a 'data-date'); by = (Get-Attr $a 'data-by'); kind = (Get-Attr $a 'data-kind'); with = (Get-Attr $a 'data-with'); text = (ConvertFrom-Html $m.Groups['text'].Value) }
  }
  return $out
}

# The page back into the model: only the attributes and lists the template names.
function Read-PageModel([string]$Html) {
  $Html = $Html.Replace("`r`n", "`n")
  $body = [regex]::Match($Html, '<body([^>]*)>').Groups[1].Value
  $model = [ordered]@{ lang = (Get-Attr ([regex]::Match($Html, '<html[^>]*>').Value) 'lang'); register = (Get-Attr $body 'data-register'); updated = (Get-Attr $body 'data-updated'); history = @(); risks = @() }
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
    $risk.history = @(Read-Lines ([regex]::Match($b, '(?s)<ol class="risk-history">(.*?)</ol>').Groups[1].Value) | ForEach-Object { [ordered]@{ date = $_.date; by = $_.by; kind = $_.kind; text = $_.text } })
    $risks += $risk
  }
  $model.risks = $risks
  return $model
}

# What stops a register being read in full; a duplicate identifier is not one (the next write renumbers it).
function Get-Problems($Model) {
  $problems = @()
  if ($Model.register -notin @('kept', 'opt-out')) { $problems += 'the page does not say whether a register is kept (data-register)' }
  if ($Model.updated -notmatch '^\d{4}-\d{2}-\d{2}$') { $problems += 'the register has no last-updated date' }
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
  }
  return $problems
}

function Read-Register([string]$Page) {
  try { $html = [System.IO.File]::ReadAllText($Page, $Utf8) } catch { Exit-Unreadable "The register $Page cannot be read: $($_.Exception.Message)" }
  return Read-PageModel $html
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
  if ($ka -eq $kb) { return $true }
  if ($ka.Length -lt 4 -or $kb.Length -lt 4) { return $false }
  return ((Get-Distance $ka $kb) -eq 1)
}

function Get-Areas($Model) {
  return @($Model.risks | ForEach-Object { $_.area } | Where-Object { $_ } | Sort-Object -Unique)
}

# ---------------------------------------------------------------- write

# Render to <page>.new, read it back, compare with the intended model and with what the page held,
# then rename into place. Anything short of the rename deletes the .new.
function Write-Register([string]$Page, $Model, $Held) {
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
    elseif ((Format-Model $back) -ne (Format-Model $Model)) { $problem = 'the written page does not read back as the change' }
    else { $problem = Test-Kept $Held $back }
    if ($problem) { Exit-Refused "Not written: $problem. The register is as it was." }
    if (Test-Path -LiteralPath $Page) { [System.IO.File]::Replace($new, $Page, [NullString]::Value) } else { [System.IO.File]::Move($new, $Page) }
    $renamed = $true
  } finally {
    if (-not $renamed -and (Test-Path -LiteralPath $new)) { Remove-Item -LiteralPath $new -Force }
  }
}

# The new page keeps every risk and every history line the page held (after renumbering), and
# holds no identifier twice.
function Test-Kept($Held, $New) {
  $ids = @($New.risks | ForEach-Object { $_.id })
  $dups = @($ids | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
  if ($dups.Count -gt 0) { return "the new page holds $($dups -join ', ') twice" }
  if ($null -eq $Held) { return $null }
  foreach ($r in $Held.risks) {
    $now = @($New.risks | Where-Object { $_.id -eq $r.id })
    if ($now.Count -eq 0) { return "the new page drops $($r.id)" }
    $old = @($r.history); $cur = @($now[0].history)
    if ($cur.Count -lt $old.Count) { return "the new page drops a history line of $($r.id)" }
    for ($k = 0; $k -lt $old.Count; $k++) {
      if ("$($old[$k].date)|$($old[$k].by)|$($old[$k].kind)|$($old[$k].text)" -ne "$($cur[$k].date)|$($cur[$k].by)|$($cur[$k].kind)|$($cur[$k].text)") { return "the new page changes a history line of $($r.id)" }
    }
  }
  # the register's history is newest first: what the page held is the tail of the new list
  $old = @($Held.history); $cur = @($New.history)
  if ($cur.Count -lt $old.Count) { return 'the new page drops a line of the register history' }
  $offset = $cur.Count - $old.Count
  for ($k = 0; $k -lt $old.Count; $k++) {
    if ("$($old[$k].date)|$($old[$k].by)|$($old[$k].kind)|$($old[$k].text)" -ne "$($cur[$k + $offset].date)|$($cur[$k + $offset].by)|$($cur[$k + $offset].kind)|$($cur[$k + $offset].text)") { return 'the new page changes a line of the register history' }
  }
  return $null
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
  $held = $null; $renumbered = @()
  if (Test-Path -LiteralPath $Page) {
    $current = Get-Current $Page $Person
    $model = $current.Model; $held = $current.Held; $renumbered = $current.Renumbered
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
  $risk.history = @([ordered]@{ date = $Today; by = $Person; kind = 'created'; text = "Created. Impact $($risk.impact), Probability $($risk.probability) (score $(Get-Score $risk))." })
  $model.risks = @($model.risks) + @($risk)
  if ($null -eq $held) {
    $line = [ordered]@{ date = $Today; by = $Person; kind = 'created'; with = ''; text = "Register created with $($risk.id). Project language: $($model.lang)." }
  } else {
    $text = "$($risk.id) registered."
    if ($renumbered.Count -gt 0) { $text += ' ' + ($renumbered -join '; ') + '.' }
    $line = [ordered]@{ date = $Today; by = $Person; kind = 'write'; with = ''; text = $text }
  }
  $model.history = @($line) + @($model.history)
  $model.updated = $Today
  Write-Register $Page $model $held
  Write-Output "$($risk.id) written."
}

function Invoke-Read([string]$Page) {
  if (-not (Test-Path -LiteralPath $Page)) { Exit-Unreadable "No register at $Page." }
  $model = Read-Register $Page
  $areas = @(Get-Areas $model)
  $out = [ordered]@{
    lang = $model.lang; register = $model.register; updated = $model.updated
    history = @($model.history); risks = @($model.risks); areas = $areas
    problems = @(Get-Problems $model)
  }
  if ($PSBoundParameters.ContainsKey('Area') -or $Area) { $out.nearly = @($areas | Where-Object { Test-NearlySame $_ $Area }) }
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
  'Apply' {
    if (Test-Path -LiteralPath ($PagePath + '.new')) { Exit-Refused "An earlier write was interrupted: $Path.new is still there. Run -Finish first. Nothing written." }
    $data = Read-Change $Change
    $person = Get-Person
    switch (Get-Text (Get-Field $data 'verb')) {
      'add' { Invoke-Add $PagePath $data $person }
      default { Exit-Unreadable "The verb '$(Get-Text (Get-Field $data 'verb'))' is not built yet." }
    }
    exit 0
  }
  default {
    Write-Output "-$($actions) is not built yet."
    exit 2
  }
}
