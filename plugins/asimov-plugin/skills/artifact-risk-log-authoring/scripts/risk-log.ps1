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
$Today = (Get-Date).ToString('yyyy-MM-dd')

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

# One canonical text per model, so the check compares parsed data and never bytes.
function Format-Model($Model) {
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("lang=$($Model.lang)|register=$($Model.register)|updated=$($Model.updated)")
  foreach ($h in $Model.history) { $lines.Add("reg|$($h.date)|$($h.by)|$($h.kind)|$($h.with)|$($h.text)") }
  foreach ($r in $Model.risks) {
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
  $t = [regex]::Replace($Template, '(?s)<!--\s*\r?\n\s*Page template for the risk log.*?-->\r?\n?', '', 1)
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

# ---------------------------------------------------------------- write

# Render to <page>.new, read it back, compare with the intended model, then rename into place.
function Write-Register([string]$Page, $Model) {
  $dir = Split-Path -Parent $Page
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $repoName = Split-Path -Leaf (Split-Path -Parent $dir)
  $html = Format-Page (Read-Template) $Model $repoName
  $new = $Page + '.new'
  [System.IO.File]::WriteAllText($new, $html, $Utf8)
  $back = Read-PageModel ([System.IO.File]::ReadAllText($new, $Utf8))
  $problem = $null
  if ($html -match '\{\{') { $problem = 'a placeholder was left unfilled' }
  elseif ((Format-Model $back) -ne (Format-Model $Model)) { $problem = 'the written page does not read back as the change' }
  if ($problem) {
    Remove-Item -LiteralPath $new -Force
    Exit-Refused "Not written: $problem. The register is as it was."
  }
  if (Test-Path -LiteralPath $Page) { [System.IO.File]::Replace($new, $Page, $null) } else { [System.IO.File]::Move($new, $Page) }
}

# ---------------------------------------------------------------- the change

function Test-Required($Fields) {
  $missing = @()
  foreach ($f in 'name', 'owner') { if (-not (Get-Text (Get-Field $Fields $f))) { $missing += $f } }
  foreach ($f in 'impact', 'probability') { if ((Get-Text (Get-Field $Fields $f)) -notmatch '^[1-5]$') { $missing += "$f (1 to 5)" } }
  if ($missing.Count -gt 0) { Exit-Refused ('A risk needs a name, an owner, an impact and a probability; missing: ' + ($missing -join ', ') + '. Nothing written.') }
}

function Invoke-Add([string]$Page, $ChangeData, [string]$Person) {
  if (Test-Path -LiteralPath $Page) { Exit-Unreadable 'Adding to an existing register is not built yet.' }
  $fields = Get-Field $ChangeData 'fields'
  Test-Required $fields
  $lang = Get-Text (Get-Field $ChangeData 'language')
  if (-not $lang) { Exit-Refused 'The first write names the project language (language). Nothing written.' }
  $model = New-Register $lang
  $risk = [ordered]@{
    id = 'RISK-001'; state = 'Active'; impact = (Get-Text (Get-Field $fields 'impact')); probability = (Get-Text (Get-Field $fields 'probability'))
    owner = (Get-Text (Get-Field $fields 'owner')); area = (Get-Text (Get-Field $fields 'area')); created = $Today; changed = $Today
    name = (Get-Text (Get-Field $fields 'name')); description = (Get-Text (Get-Field $fields 'description')); mitigation = (Get-Text (Get-Field $fields 'mitigation'))
    history = @()
  }
  $risk.history = @([ordered]@{ date = $Today; by = $Person; kind = 'created'; text = "Created. Impact $($risk.impact), Probability $($risk.probability) (score $(Get-Score $risk))." })
  $model.risks = @($risk)
  $model.history = @([ordered]@{ date = $Today; by = $Person; kind = 'created'; with = ''; text = "Register created with $($risk.id). Project language: $lang." })
  Write-Register $Page $model
  Write-Output "$($risk.id) written."
}

# ---------------------------------------------------------------- main

$actions = @(@('Read', $Read), @('View', $View), @('Apply', $Apply), @('Repair', $Repair), @('Finish', $Finish)) | Where-Object { $_[1] } | ForEach-Object { $_[0] }
if (@($actions).Count -ne 1) {
  Write-Output 'Give exactly one action: -Read, -View, -Apply, -Repair or -Finish.'
  exit 2
}

$PagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

switch ($actions) {
  'Apply' {
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
