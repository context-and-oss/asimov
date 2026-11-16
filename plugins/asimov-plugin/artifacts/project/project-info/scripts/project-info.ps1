<#
.SYNOPSIS
  The project info's script: read, render, check and write the project's record, project/info.html.

.DESCRIPTION
  Implements the method of project-info-authoring.md, the file one folder above this script
  (artifacts/project/project-info/, beside the definition), on the one file that
  holds a project's metadata. The page is the record: the script reads it back from the table
  cells and paragraphs the template names (artifacts/project/project-info/project-info-template.html)
  and renders the links and marks without ever reading them. The model decides only the change;
  the rules the definition states (PI1-PI6) are checked here.

  Every call does one action on -Path. A write goes to <page>.new beside the page, is read back
  and compared with what was intended, then replaces the page by one rename; a failed check,
  or any exit before the rename, deletes the .new. There is no history and no date: project info is metadata (PI5).

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose. The page is
  written as UTF-8 without a byte-order mark.

.PARAMETER Path
  The page, normally project/info.html in the product repo.
.PARAMETER Read
  Print the data model as JSON: name, lede, lang, fields, areas (with the repository and whether
  it is this one), shared, and the problems found. Writes nothing. With no page, present is false.
.PARAMETER Apply
  Apply the change file given by -Change: write to <page>.new, check, rename.
.PARAMETER Change
  With -Apply: a JSON change file. Every member is optional; a member given replaces the page's
  value, a member absent keeps it (on a new page, absent means empty or "not set"):
    name      the project's name
    lede      its one line
    lang      the project language, a BCP 47 tag (default en)
    fields    [ { "field": "Project number", "value": "..." }, ... ]  the identity rows, in order;
              Language is rendered from lang and never listed here
    areas     [ { "area": "Frontend", "repo": "Sekstant-Frontend" }, ... ]  in order; a repo
              equal to -Repo (or the git remote's name) is this repository; "" means not decided
    shared    the shared line, or "" to drop it
.PARAMETER Render
  Read the page back and write it again from the current template, keeping every value. Used
  when the template changed. A no-op when the page is already in the current shape.
.PARAMETER Repo
  The name of the repository the page is in, to mark the areas held here. Defaults to the git
  remote's repository name, then the folder name.
.PARAMETER PluginRoot
  The plugin root, where the template is read from. Defaults to four folders above this script
  (scripts/ -> project-info -> project -> artifacts -> the plugin root).

.OUTPUTS
  Exit codes:
    0  done
    1  refused by a rule; the rule is printed on stdout
    2  an input could not be read

.EXAMPLE
  pwsh -NoProfile -File project-info.ps1 -Path project/info.html -Read
.EXAMPLE
  pwsh -NoProfile -File project-info.ps1 -Path project/info.html -Apply -Change change.json
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [switch]$Read,
  [switch]$Apply,
  [string]$Change,
  [switch]$Render,
  [string]$Repo,
  [string]$PluginRoot
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }

if (-not $PluginRoot) { $PluginRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) }
$TemplatePath = Join-Path $PluginRoot 'artifacts/project/project-info/project-info-template.html'
$Utf8 = New-Object System.Text.UTF8Encoding $false

$Path = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
$ProjectDir = Split-Path -Parent $Path
$RepoRoot = Split-Path -Parent $ProjectDir
$DocRoot = Join-Path $RepoRoot 'documentation'

if (-not $Repo) {
  try { $url = (& git -C $RepoRoot remote get-url origin 2>$null); if ($url) { $Repo = ([regex]::Match($url, '([^/:]+?)(\.git)?/?$')).Groups[1].Value } } catch { }
  if (-not $Repo) { $Repo = Split-Path -Leaf $RepoRoot }
}

function Read-Text([string]$p) { if (-not (Test-Path -LiteralPath $p)) { Write-Output "cannot read: $p"; exit 2 }; return ([System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) -replace "`r`n", "`n") }
function Esc([string]$t) { if ($null -eq $t) { return '' }; return $t.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;') }
function Unesc([string]$t) { return $t.Replace('&amp;', '&').Replace('&lt;', '<').Replace('&gt;', '>').Replace('&quot;', '"') }
function Text([string]$h) { if ($null -eq $h) { return '' }; $t = [regex]::Replace($h, '<[^>]+>', ' '); $t = [regex]::Replace($t, '\s+', ' '); return (Unesc $t).Trim() }
function Key([string]$t) { return [regex]::Replace($t.ToLowerInvariant(), '[^a-z0-9]', '') }
function Get-Block([string]$tpl, [string]$name) { $m = [regex]::Match($tpl, "(?s)<!-- BEGIN $name -->\r?\n?(.*?)<!-- END $name -->\r?\n?"); if (-not $m.Success) { throw "template has no block '$name'" }; return $m.Groups[1].Value }
function Set-Block([string]$tpl, [string]$name, [string]$html) { return [regex]::Replace($tpl, "(?s)<!-- BEGIN $name -->\r?\n?.*?<!-- END $name -->\r?\n?", { param($m) $html }) }
function Fill([string]$tpl, [hashtable]$v) { foreach ($k in $v.Keys) { $x = $v[$k]; if ($null -eq $x) { $x = '' }; $tpl = $tpl.Replace('{{' + $k + '}}', [string]$x) }; return $tpl }

# ---------------------------------------------------------------------------------------------
# Read the page back
# ---------------------------------------------------------------------------------------------
function Read-Page() {
  $model = [ordered]@{ present = $false; path = $Path; repo = $Repo; name = ''; lede = ''; lang = 'en'; fields = @(); areas = @(); shared = ''; problems = @() }
  if (-not (Test-Path -LiteralPath $Path)) { return $model }
  $h = Read-Text $Path
  $model.present = $true
  $problems = New-Object System.Collections.ArrayList
  if ($h -match '^(<<<<<<<|=======|>>>>>>>)') { [void]$problems.Add('git conflict markers on the page') }
  $m = [regex]::Match($h, '<html lang="([^"]+)"'); if ($m.Success) { $model.lang = $m.Groups[1].Value }
  $m = [regex]::Match($h, '(?s)<h1>(.*?)</h1>'); if ($m.Success) { $model.name = Text $m.Groups[1].Value } else { [void]$problems.Add('no h1 (the project name)') }
  $m = [regex]::Match($h, '(?s)<p class="[^"]*lead[^"]*">(.*?)</p>'); if ($m.Success) { $model.lede = Text $m.Groups[1].Value }
  $fields = New-Object System.Collections.ArrayList
  $m = [regex]::Match($h, '(?s)<table class="[^"]*kv[^"]*">.*?<tbody>(.*?)</tbody>')
  if ($m.Success) {
    foreach ($tr in [regex]::Matches($m.Groups[1].Value, '(?s)<tr[^>]*>(.*?)</tr>')) {
      $c = [regex]::Matches($tr.Groups[1].Value, '(?s)<t[hd][^>]*>(.*?)</t[hd]>'); if ($c.Count -lt 2) { continue }
      $f = Text $c[0].Groups[1].Value; $v = Text $c[1].Groups[1].Value
      if ($f -eq 'Language') { continue }
      if ($v -eq 'not set') { $v = '' }
      [void]$fields.Add([ordered]@{ field = $f; value = $v })
    }
  } else { [void]$problems.Add('no identity table (table.kv)') }
  $areas = New-Object System.Collections.ArrayList
  $m = [regex]::Match($h, '(?s)<table class="[^"]*areas[^"]*">.*?<tbody>(.*?)</tbody>')
  if ($m.Success) {
    foreach ($tr in [regex]::Matches($m.Groups[1].Value, '(?s)<tr[^>]*>(.*?)</tr>')) {
      $c = [regex]::Matches($tr.Groups[1].Value, '(?s)<t[hd][^>]*>(.*?)</t[hd]>'); if ($c.Count -lt 2) { continue }
      $a = Text $c[0].Groups[1].Value
      $cell = $c[1].Groups[1].Value
      $here = ($cell -match 'class="this"')
      $r = (Text ([regex]::Replace($cell, '(?s)<span class="this">.*?</span>', ''))).Replace('(this)', '').Trim()
      if ($r -eq 'not decided') { $r = '' }
      if (-not $a) { [void]$problems.Add('an area row with no name') }
      [void]$areas.Add([ordered]@{ area = $a; repo = $r; here = $here })
    }
  } else { [void]$problems.Add('no areas table (table.areas)') }
  $m = [regex]::Match($h, '(?s)<p class="[^"]*shared[^"]*">(.*?)</p>'); if ($m.Success) { $model.shared = Text $m.Groups[1].Value }
  $model.fields = @($fields); $model.areas = @($areas); $model.problems = @($problems)
  return $model
}

function Doc-Href([System.IO.FileInfo]$f) {
  # a markdown document is shown through the site's rendering when the site has made one
  if ($f.Extension -eq '.md') { $r = Join-Path $DocRoot ('_site/doc/' + $f.BaseName + '.html'); if (Test-Path -LiteralPath $r) { return '_site/doc/' + $f.BaseName + '.html' } }
  return $f.Name
}

# ---------------------------------------------------------------------------------------------
# Render from a model
# ---------------------------------------------------------------------------------------------
function Render-Page([hashtable]$model) {
  $tpl = Read-Text $TemplatePath
  $tpl = [regex]::Replace($tpl, '(?s)\n<!--\n  Page template for the project info.*?\n-->\n', "`n", 1)
  # identity rows: Project number, Customer, Language, then the rest in order
  $fieldTpl = Get-Block $tpl 'field'
  $rows = ''
  $ordered = New-Object System.Collections.ArrayList
  foreach ($want in 'Project number', 'Customer') {
    $f = $model.fields | Where-Object { $_.field -eq $want } | Select-Object -First 1
    if ($f) { [void]$ordered.Add($f) } else { [void]$ordered.Add([ordered]@{ field = $want; value = '' }) }
  }
  $langName = @{ en = 'English'; da = 'Danish'; de = 'German'; sv = 'Swedish'; nb = 'Norwegian'; nl = 'Dutch'; fr = 'French'; es = 'Spanish' }
  $ln = $model.lang; if ($langName.ContainsKey($ln)) { $ln = $langName[$ln] }
  [void]$ordered.Add([ordered]@{ field = 'Language'; value = $ln })
  foreach ($f in $model.fields) { if ($f.field -notin 'Project number', 'Customer', 'Language') { [void]$ordered.Add($f) } }
  foreach ($f in $ordered) {
    $v = $f.value; $cls = ''
    if (-not $v) { $v = 'not set'; $cls = ' class="unset"' }
    $rows += (Fill $fieldTpl @{ FIELD = (Esc $f.field); VALUE = (Esc $v); 'VALUE-CLASS' = $cls })
  }
  $tpl = Set-Block $tpl 'field' $rows
  # areas
  $areaTpl = Get-Block $tpl 'area'
  $rows = ''
  foreach ($a in $model.areas) {
    $here = ($a.repo -and (Key $a.repo) -eq (Key $Repo))
    $nameHtml = Esc $a.area
    if ($here) {
      $d100 = $null
      if (Test-Path -LiteralPath $DocRoot) {
        $cand = Get-ChildItem -LiteralPath $DocRoot -File -Filter 'D100-*' | Where-Object { $_.Extension -in '.html', '.md' } | Where-Object { ($_.BaseName.Split('-') | ForEach-Object { Key $_ }) -contains (Key $a.area) } | Sort-Object -Property @{ Expression = { $_.Extension -ne '.html' } }, Name | Select-Object -First 1
        if ($cand) { $d100 = '../documentation/' + (Doc-Href $cand) }
      }
      if ($d100) { $nameHtml = "<a href=`"$d100`">$(Esc $a.area)</a>" }
    }
    $repoHtml = ''
    if (-not $a.repo) { $repoHtml = '<span class="unset">not decided</span>' }
    else { $repoHtml = "<code>$(Esc $a.repo)</code>"; if ($here) { $repoHtml += ' <span class="this">this repo</span>' } }
    $rowClass = ''; if ($here) { $rowClass = ' class="here"' }
    $rows += (Fill $areaTpl @{ 'ROW-CLASS' = $rowClass; 'AREA-HTML' = $nameHtml; 'REPO-HTML' = $repoHtml })
  }
  $tpl = Set-Block $tpl 'area' $rows
  if ($model.shared) { $tpl = Set-Block $tpl 'shared' (Fill (Get-Block $tpl 'shared') @{ SHARED = (Esc $model.shared) }) } else { $tpl = Set-Block $tpl 'shared' '' }
  $landscape = $null
  if (Test-Path -LiteralPath $DocRoot) {
    $areaKeys = @($model.areas | ForEach-Object { Key $_.area })
    $cand = Get-ChildItem -LiteralPath $DocRoot -File -Filter 'D100-*' | Where-Object { $_.Extension -in '.html', '.md' } | Where-Object { $toks = @($_.BaseName.Split('-') | ForEach-Object { Key $_ }); -not ($toks | Where-Object { $areaKeys -contains $_ }) } | Sort-Object -Property @{ Expression = { $_.Extension -ne '.html' } }, Name | Select-Object -First 1
    if ($cand) { $landscape = '../documentation/' + (Doc-Href $cand) }
  }
  if ($landscape) { $tpl = Set-Block $tpl 'landscape' (Fill (Get-Block $tpl 'landscape') @{ 'LANDSCAPE-HREF' = $landscape }) } else { $tpl = Set-Block $tpl 'landscape' '' }
  $tpl = Fill $tpl @{ LANG = (Esc $model.lang); 'REPO-NAME' = (Esc $Repo); NAME = (Esc $model.name); LEDE = (Esc $model.lede) }
  return $tpl
}

# ---------------------------------------------------------------------------------------------
# Check: the rendered page reads back as the model intended
# ---------------------------------------------------------------------------------------------
function Compare-Model([hashtable]$want, [hashtable]$got) {
  if ($got.name -ne $want.name) { return "name: wanted '$($want.name)', page reads '$($got.name)'" }
  if ($got.lede -ne $want.lede) { return 'lede differs after render' }
  if ($got.lang -ne $want.lang) { return 'language differs after render' }
  if (@($got.areas).Count -ne @($want.areas).Count) { return "areas: wanted $(@($want.areas).Count), page reads $(@($got.areas).Count)" }
  for ($i = 0; $i -lt @($want.areas).Count; $i++) {
    if ($got.areas[$i].area -ne $want.areas[$i].area -or $got.areas[$i].repo -ne $want.areas[$i].repo) { return "area $($i + 1) differs after render" }
  }
  $wf = @($want.fields | Where-Object { $_.field -ne 'Language' }); $gf = @($got.fields)
  if ($gf.Count -ne $wf.Count) { return "fields: wanted $($wf.Count), page reads $($gf.Count)" }
  for ($i = 0; $i -lt $wf.Count; $i++) { if ($gf[$i].field -ne $wf[$i].field -or $gf[$i].value -ne $wf[$i].value) { return "field '$($wf[$i].field)' differs after render" } }
  if ($got.shared -ne $want.shared) { return 'shared line differs after render' }
  if ($got.problems.Count -gt 0) { return "rendered page has problems: $($got.problems -join '; ')" }
  return $null
}
function Write-Checked([hashtable]$model) {
  $html = Render-Page $model
  # the nav block is the site's: carry the one the page has into the new rendering
  if (Test-Path -LiteralPath $Path) {
    $nav = [regex]::Match((Read-Text $Path), '(?s)<!-- asimov-nav:start -->.*?<!-- asimov-nav:end -->')
    if ($nav.Success) { $html = [regex]::Replace($html, '(?s)<!-- asimov-nav:start -->.*?<!-- asimov-nav:end -->', { param($m) $nav.Value }, 1) }
  }
  if ($html -match '\{\{[A-Z-]+\}\}') { Write-Output 'refused: a placeholder was left in the rendering'; exit 1 }
  if (-not (Test-Path -LiteralPath $ProjectDir)) { [void](New-Item -ItemType Directory -Path $ProjectDir -Force) }
  $new = "$Path.new"
  [System.IO.File]::WriteAllText($new, $html, $Utf8)
  try {
    # read the .new back through the same reader
    $saved = $Path; $script:Path = $new
    try { $got = Read-Page } finally { $script:Path = $saved }
    $problem = Compare-Model $model $got
    if ($problem) { Write-Output "refused: $problem"; exit 1 }
    Move-Item -LiteralPath $new -Destination $Path -Force
  } finally {
    # any exit before the rename leaves no .new behind
    if (Test-Path -LiteralPath $new) { Remove-Item -LiteralPath $new -Force -ErrorAction SilentlyContinue }
  }
}

# ---------------------------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------------------------
if ($Read) {
  Write-Output ((Read-Page) | ConvertTo-Json -Depth 6)
  exit 0
}

if ($Render) {
  $model = Read-Page
  if (-not $model.present) { Write-Output "refused: no page at $Path to render"; exit 1 }
  if ($model.problems.Count -gt 0) { Write-Output "refused: the page does not read in full: $($model.problems -join '; ')"; exit 1 }
  $before = Read-Text $Path
  Write-Checked $model
  if ((Read-Text $Path) -ceq $before) { Write-Output 'project info: already in the current shape' } else { Write-Output 'project info: rendered again from the current template' }
  exit 0
}

if ($Apply) {
  if (-not $Change) { Write-Output 'cannot read: -Change is required with -Apply'; exit 2 }
  $json = Read-Text $Change
  $c = $json | ConvertFrom-Json
  $model = Read-Page
  if ($model.present -and $model.problems.Count -gt 0) { Write-Output "refused: the page does not read in full: $($model.problems -join '; ')"; exit 1 }
  $has = { param($o, $n) return ($null -ne $o -and $null -ne ($o.PSObject.Properties | Where-Object { $_.Name -eq $n })) }
  if (& $has $c 'name') { $model.name = [string]$c.name }
  if (& $has $c 'lede') { $model.lede = [string]$c.lede }
  if (& $has $c 'lang') { $model.lang = [string]$c.lang }
  if (-not $model.lang) { $model.lang = 'en' }
  if (& $has $c 'shared') { $model.shared = [string]$c.shared }
  if (& $has $c 'fields') { $model.fields = @($c.fields | ForEach-Object { [ordered]@{ field = [string]$_.field; value = [string]$_.value } } | Where-Object { $_.field -and $_.field -ne 'Language' }) }
  if (& $has $c 'areas') { $model.areas = @($c.areas | ForEach-Object { [ordered]@{ area = [string]$_.area; repo = [string]$_.repo; here = $false } }) }
  # rules
  if (-not $model.name) { Write-Output 'refused: the project needs a name (PI 3.1)'; exit 1 }
  if (-not $model.lede) { Write-Output 'refused: the project needs its one line (PI 3.1)'; exit 1 }
  if (@($model.areas).Count -eq 0) { Write-Output 'refused: at least one area is needed (PI 3.2)'; exit 1 }
  foreach ($a in $model.areas) { if (-not $a.area) { Write-Output 'refused: an area needs a name (PI 3.2)'; exit 1 } }
  $keys = @($model.areas | ForEach-Object { Key $_.area }); if (@($keys | Select-Object -Unique).Count -ne $keys.Count) { Write-Output 'refused: two areas have the same name (PI3)'; exit 1 }
  $hereCount = @($model.areas | Where-Object { $_.repo -and (Key $_.repo) -eq (Key $Repo) }).Count
  if ($hereCount -eq 0) { Write-Output "refused: no area names this repository ($Repo) as the one that holds it (PI4); give the repository's name exactly, or pass -Repo"; exit 1 }
  $was = $model.present
  Write-Checked $model
  if ($was) { Write-Output "project info: written, $(@($model.areas).Count) area(s), $hereCount held here" } else { Write-Output "project info: created at $Path, $(@($model.areas).Count) area(s), $hereCount held here" }
  exit 0
}

Write-Output 'cannot read: one of -Read, -Apply, -Render is required'
exit 2
