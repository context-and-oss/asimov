<#
.SYNOPSIS
  The documentation site's script: scan documentation/, read the project info, fill the
  templates and write the site, whole, every run.

.DESCRIPTION
  Implements the method of skills/artifact-site-authoring/SKILL.md. The site is a rendering:
  it indexes the documents a product repo has and never authors one. Every run derives the
  same model from the same folder and writes every page it owns again, so a re-run after the
  plugin's templates changed brings the whole site to the new shape in one call.

  What it writes (all Asimov-owned):
    documentation/index.html            the front page (home-template.html)
    documentation/_chrome.css           a verbatim copy of the plugin's chrome
    documentation/_site/<section>.html  one overview page per section of the taxonomy
    documentation/_site/<section>-<group>.html   one page per group
    documentation/_site/doc/<path>.html  one rendering per markdown document (PowerShell 7)
    the nav block between <!-- asimov-nav:start --> and <!-- asimov-nav:end --> in every
      authored HTML document the site indexes and in every page under project/

  It touches nothing else: a document's content is its author's.

  The taxonomy is fixed: Home, Architecture, Environments, Features, Testing, Project,
  Reference. A section with no documents is still a page, saying what belongs there and how
  it comes to be. The areas come from project/info.html when the repo has one; without it the
  site groups by nothing and says so on the front page.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose. Markdown
  is rendered only on PowerShell 7 (ConvertFrom-Markdown); on 5.1 the cards link the .md and
  the report says how many were left unrendered.

.PARAMETER Root
  The documentation folder. Defaults to ./documentation.
.PARAMETER Repo
  The repository's name, for the brand and the footers. Defaults to the git remote's
  repository name, then the folder name of the repo root.
.PARAMETER Plan
  Print the site model and the files a run would write, as JSON. Writes nothing.
.PARAMETER Check
  Render in memory and compare with the files on disk; exit 1 when a run would change
  anything, listing the paths. Writes nothing.
.PARAMETER PluginRoot
  The plugin root, where the templates and the chrome are read from. Defaults to three
  folders above this script.

.OUTPUTS
  One report on stdout: pages written and unchanged, documents indexed per section,
  markdown rendered or left, files that fit no section, whether project info was found.
  Exit codes: 0 done; 1 (-Check) the site is out of date; 2 an input could not be read.

.EXAMPLE
  pwsh -NoProfile -File site.ps1
.EXAMPLE
  pwsh -NoProfile -File site.ps1 -Root documentation -Check
#>
[CmdletBinding()]
param(
  [string]$Root = 'documentation',
  [string]$Repo,
  [switch]$Plan,
  [switch]$Check,
  [string]$PluginRoot
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { }

if (-not $PluginRoot) { $PluginRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }
$TemplateDir = Join-Path $PluginRoot 'artifacts/documentation/site'
$CanRenderMarkdown = ($PSVersionTable.PSVersion.Major -ge 7)

# ---------------------------------------------------------------------------------------------
# Files and text
# ---------------------------------------------------------------------------------------------
$Utf8 = New-Object System.Text.UTF8Encoding $false

function Read-Text([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { Write-Output "cannot read: $path"; exit 2 }
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}
function Norm([string]$text) { return ($text -replace "`r`n", "`n") }
function Rel([string]$base, [string]$path) {
  $b = [System.IO.Path]::GetFullPath($base).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  $p = [System.IO.Path]::GetFullPath($path)
  if ($p.StartsWith($b, [System.StringComparison]::OrdinalIgnoreCase)) { return ($p.Substring($b.Length) -replace '\\', '/') }
  return ($p -replace '\\', '/')
}
function Esc([string]$t) { if ($null -eq $t) { return '' }; return $t.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;') }
function Attr([string]$t) { return (Esc $t).Replace('"', '&quot;') }
function Strip-Tags([string]$h) { if ($null -eq $h) { return '' }; $t = [regex]::Replace($h, '<[^>]+>', ' '); $t = [regex]::Replace($t, '[ 	]+', ' '); return (Unesc $t).Trim() }
function Clean-Title([string]$t) { return ([regex]::Replace($t, '^[A-Z]\d{3}\s*[-–—:]\s*', '')).Trim() }
function First-Sentence([string]$t) { $m = [regex]::Match($t, '^(.*?[.!?])(\s|$)'); if ($m.Success) { return $m.Groups[1].Value }; return $t }
function Unesc([string]$t) { return $t.Replace('&amp;', '&').Replace('&lt;', '<').Replace('&gt;', '>').Replace('&quot;', '"').Replace('&#39;', "'") }
function Squash([string]$t) { return ([regex]::Replace($t, '\s+', ' ')).Trim() }
function Prefix-Of([string]$rel) { $n = ([regex]::Matches($rel, '/')).Count; $s = ''; for ($i = 0; $i -lt $n; $i++) { $s += '../' }; return $s }
function Slug([string]$t) { $s = $t.ToLowerInvariant(); $s = [regex]::Replace($s, '[^a-z0-9]+', '-'); return $s.Trim('-') }
function Key([string]$t) { return [regex]::Replace($t.ToLowerInvariant(), '[^a-z0-9]', '') }
function Sort-Ordinal([string[]]$a) { if ($null -eq $a -or $a.Count -eq 0) { return ,@() }; $c = [string[]]$a.Clone(); [Array]::Sort($c, [System.StringComparer]::Ordinal); return ,$c }
function Inline-Md([string]$t) {
  # the few inline marks a title or first paragraph may carry
  $t = Esc $t
  $t = [regex]::Replace($t, '`([^`]+)`', '<code>$1</code>')
  $t = [regex]::Replace($t, '\*\*([^*]+)\*\*', '<strong>$1</strong>')
  $t = [regex]::Replace($t, '\[([^\]]+)\]\([^)]+\)', '$1')
  return $t
}

# ---------------------------------------------------------------------------------------------
# Templates: {{PLACEHOLDER}} and <!-- BEGIN name --> ... <!-- END name --> blocks
# ---------------------------------------------------------------------------------------------
function Get-Block([string]$tpl, [string]$name) {
  $m = [regex]::Match($tpl, "(?s)<!-- BEGIN $name -->\r?\n?(.*?)<!-- END $name -->\r?\n?")
  if (-not $m.Success) { throw "template has no block '$name'" }
  return $m.Groups[1].Value
}
function Set-Block([string]$tpl, [string]$name, [string]$html) {
  return [regex]::Replace($tpl, "(?s)<!-- BEGIN $name -->\r?\n?.*?<!-- END $name -->\r?\n?", { param($m) $html })
}
function Drop-Block([string]$tpl, [string]$name) { return (Set-Block $tpl $name '') }
function Fill([string]$tpl, [hashtable]$values) {
  foreach ($k in $values.Keys) { $v = $values[$k]; if ($null -eq $v) { $v = '' }; $tpl = $tpl.Replace('{{' + $k + '}}', [string]$v) }
  return $tpl
}
function Strip-Leading-Comment([string]$tpl) {
  # the authoring comment inside <head> (or at the top) never reaches a page
  return [regex]::Replace($tpl, '(?s)\n<!--\n  .*?\n-->\n', "`n", 1)
}

$NavTpl = Get-Block (Norm (Read-Text (Join-Path $TemplateDir 'nav-template.html'))) 'block'
$HomeTpl = Strip-Leading-Comment (Norm (Read-Text (Join-Path $TemplateDir 'home-template.html')))
$SectionTplAll = Norm (Read-Text (Join-Path $TemplateDir 'section-template.html'))
$DocTpl = Strip-Leading-Comment (Norm (Read-Text (Join-Path $TemplateDir 'document-template.html')))
$Chrome = Norm (Read-Text (Join-Path $TemplateDir '_chrome.css'))

# the section template carries its page and its blocks after </html>
$SectionPage = Strip-Leading-Comment ($SectionTplAll.Substring(0, $SectionTplAll.IndexOf('</html>') + 7)) + "`n"
$B = @{}
foreach ($n in 'figure', 'grid', 'card', 'group-head', 'empty', 'note', 'table', 'row') { $B[$n] = Get-Block $SectionTplAll $n }

# ---------------------------------------------------------------------------------------------
# Where things are
# ---------------------------------------------------------------------------------------------
$Root = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Root))
if (-not (Test-Path -LiteralPath $Root)) { Write-Output "cannot read: $Root"; exit 2 }
$RepoRoot = Split-Path -Parent $Root
$ProjectDir = Join-Path $RepoRoot 'project'

if (-not $Repo) {
  try {
    $url = (& git -C $RepoRoot remote get-url origin 2>$null)
    if ($url) { $Repo = ([regex]::Match($url, '([^/:]+?)(\.git)?/?$')).Groups[1].Value }
  } catch { }
  if (-not $Repo) { $Repo = Split-Path -Leaf $RepoRoot }
}

# ---------------------------------------------------------------------------------------------
# Project info: project/info.html, the project's record
# ---------------------------------------------------------------------------------------------
$Project = $null
$InfoPath = Join-Path $ProjectDir 'info.html'
if (Test-Path -LiteralPath $InfoPath) {
  $h = Norm (Read-Text $InfoPath)
  $areas = New-Object System.Collections.ArrayList
  $tbl = [regex]::Match($h, '(?s)<table class="[^"]*areas[^"]*">.*?<tbody>(.*?)</tbody>')
  if ($tbl.Success) {
    foreach ($tr in [regex]::Matches($tbl.Groups[1].Value, '(?s)<tr[^>]*>(.*?)</tr>')) {
      $cells = [regex]::Matches($tr.Groups[1].Value, '(?s)<t[hd][^>]*>(.*?)</t[hd]>')
      if ($cells.Count -lt 2) { continue }
      $name = Strip-Tags $cells[0].Groups[1].Value
      $repoCell = $cells[1].Groups[1].Value
      $here = ($repoCell -match 'class="this"') -or ($repoCell -match '\(this\)')
      $repoName = (Strip-Tags ([regex]::Replace($repoCell, '(?s)<span class="this">.*?</span>', ''))).Replace(' (this)', '').Trim()
      [void]$areas.Add([ordered]@{ name = $name; slug = (Slug $name); key = (Key $name); repo = $repoName; here = $here })
    }
  }
  $Project = [ordered]@{
    name   = Strip-Tags ([regex]::Match($h, '(?s)<h1>(.*?)</h1>')).Groups[1].Value
    lede   = Strip-Tags ([regex]::Match($h, '(?s)<p class="[^"]*lead[^"]*">(.*?)</p>')).Groups[1].Value
    lang   = ([regex]::Match($h, '<html lang="([^"]+)"')).Groups[1].Value
    areas  = @($areas)
  }
}
$Areas = @(); if ($Project) { $Areas = @($Project.areas) }
$AreasHere = @($Areas | Where-Object { $_.here })

# ---------------------------------------------------------------------------------------------
# Inventory: every document under documentation/, one entry per document (an .md with an .html
# sibling is one document, the .html)
# ---------------------------------------------------------------------------------------------
$Exclude = '^(_site/|index\.html$|_chrome\.css$|_|README\.md$|specs/|decks/)|/images/|/mockups/|/_raw/|\.review\.md$|\.generated\.html$|/_'
$Exts = @('.html', '.md', '.png', '.pdf', '.yaml', '.yml', '.json', '.svg')
$Files = @{}
Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
  $rel = Rel $Root $_.FullName
  if ($rel -match $Exclude) { return }
  if ($Exts -notcontains $_.Extension.ToLowerInvariant()) { return }
  $Files[$rel] = $_.FullName
}
# de-duplicate: an .md beside an .html is the same document (the .html); a .pdf beside either is its print
$Docs = @{}
foreach ($rel in (Sort-Ordinal @($Files.Keys))) {
  $stem = $rel.Substring(0, $rel.LastIndexOf('.'))
  if ($rel.EndsWith('.md') -and $Files.ContainsKey("$stem.html")) { continue }
  if ($rel.EndsWith('.pdf') -and ($Files.ContainsKey("$stem.html") -or $Files.ContainsKey("$stem.md"))) { continue }
  $Docs[$rel] = $Files[$rel]
}

function Family([string]$rel) {
  $m = [regex]::Match((Split-Path -Leaf $rel), '^([A-Z]\d{3})-')
  if ($m.Success) { return $m.Groups[1].Value }
  return ''
}
function Scope-Tokens([string]$rel) {
  # D100-Frontend-architecture -> Frontend ; E100-Sekstant-Frontend-environments -> Sekstant, Frontend
  $stem = [System.IO.Path]::GetFileNameWithoutExtension($rel)
  $parts = $stem.Split('-')
  if ($parts.Count -lt 3) { return @() }
  return @($parts[1..($parts.Count - 2)])
}
function Area-Of([string]$rel) {
  # the area whose name is a token of the file name (D100-<Area>-..., D101-<area>-...)
  $stem = [System.IO.Path]::GetFileNameWithoutExtension($rel).ToLowerInvariant()
  $tokens = @($stem.Split('-') | ForEach-Object { Key $_ })
  foreach ($a in $Areas) { if ($tokens -contains $a.key) { return $a } }
  return $null
}

# metadata of one document: title, one-line description, chips (a D101), kind
$Meta = @{}
function Get-Meta([string]$rel) {
  if ($Meta.ContainsKey($rel)) { return $Meta[$rel] }
  $path = $Docs[$rel]
  $ext = [System.IO.Path]::GetExtension($rel).ToLowerInvariant()
  $title = ''; $desc = ''; $chips = ''
  if ($ext -eq '.html') {
    $h = Norm (Read-Text $path)
    $m = [regex]::Match($h, '(?s)<h1[^>]*>(.*?)</h1>'); if ($m.Success) { $title = Clean-Title (Squash (Strip-Tags $m.Groups[1].Value)) }
    foreach ($cls in 'tagline', 'lede', 'lead', 'desc') {
      $m = [regex]::Match($h, "(?s)<p class=`"[^`"]*\b$cls\b[^`"]*`">(.*?)</p>"); if ($m.Success) { $desc = Squash (Strip-Tags $m.Groups[1].Value); break }
    }
    if (-not $desc) { $m = [regex]::Match($h, '(?s)<(main|article)[^>]*>.*?<p[^>]*>(.*?)</p>'); if ($m.Success) { $desc = Squash (Strip-Tags $m.Groups[2].Value) } }
    $cm = [regex]::Matches($h, '(?s)<span class="(phase-chip[^"]*|status-chip[^"]*)">(.*?)</span>')
    $seen = @{}
    foreach ($c in $cm) {
      $cls = $c.Groups[1].Value; $kind = $cls.Split(' ')[0]
      if ($seen.ContainsKey($kind)) { continue }; $seen[$kind] = $true
      $chips += '<span class="' + $cls + '">' + (Squash (Strip-Tags $c.Groups[2].Value)) + '</span>'
    }
  } elseif ($ext -eq '.md') {
    $md = Norm (Read-Text $path)
    $m = [regex]::Match($md, '(?m)^# (.+)$'); if ($m.Success) { $title = Clean-Title (Strip-Tags (Inline-Md $m.Groups[1].Value.Trim())) }
    foreach ($para in ($md -split "`n\s*`n")) {
      $p = $para.Trim()
      if (-not $p -or $p.StartsWith('#') -or $p.StartsWith('|') -or $p.StartsWith('!') -or $p.StartsWith('<') -or $p.StartsWith('```') -or $p.StartsWith('---') -or $p.StartsWith('- ') -or $p.StartsWith('> ')) { continue }
      $desc = Squash $p; break
    }
    if (-not $title) { $title = [System.IO.Path]::GetFileNameWithoutExtension($rel) }
  } else {
    $title = [System.IO.Path]::GetFileNameWithoutExtension($rel)
  }
  if ($desc.Length -gt 220) { $desc = $desc.Substring(0, 217).TrimEnd() + '...' }
  $Meta[$rel] = [ordered]@{ title = $title; desc = $desc; chips = $chips; ext = $ext }
  return $Meta[$rel]
}

# ---------------------------------------------------------------------------------------------
# The taxonomy and its fixed texts
# ---------------------------------------------------------------------------------------------
$SectionOrder = @('architecture', 'environments', 'features', 'testing', 'project', 'reference')
$SectionLabel = @{ architecture = 'Architecture'; environments = 'Environments'; features = 'Features'; testing = 'Testing'; project = 'Project'; reference = 'Reference' }
$SectionLede = @{
  architecture = 'How it is built: the landscape across the project, then each area this repository holds, and the conventions for writing its code.'
  environments = 'What is deployed where: one table per area, dev, test and prod side by side.'
  features     = 'One design per feature, by the area it changes. Phase and status on every card.'
  testing      = 'The test strategy across the project and the test plan per area.'
  project      = 'The engagement around the work: what the project is, its areas and where they live, the releases.'
  reference    = 'Analyses, research and external material that informed the designs.'
}
$SectionWhat = @{
  architecture = 'How each area is built, and the conventions for writing its code.'
  environments = 'What is deployed in dev, test and prod, and what it is called there.'
  features     = 'One design per feature, with phase and status.'
  testing      = 'The shared test strategy and this repository''s test plan.'
  project      = 'Project info and releases.'
  reference    = 'Analyses, research and contracts other parties own.'
}
$SectionEmptyWhat = @{
  architecture = 'The architecture documents belong here: the landscape of the project (D100) and one document per area this repository holds, with the conventions for writing its code.'
  environments = 'The environment documents belong here: one per area (E100), each with its table of what is deployed in dev, test and prod and what it is called.'
  features     = 'The feature designs belong here: one D101 per feature, grouped by the area it changes, each carrying its phase and status.'
  testing      = 'The test documents belong here: the strategy across the project (T100) and the test plan of each area this repository holds (T101).'
  project      = 'The project''s record belongs here: the project info with its areas and repositories, and one page per release.'
  reference    = 'The material behind the designs belongs here: analyses (documentation/analysis/), research notes (documentation/reference/) and the contracts other parties own (a folder per party under reference/).'
}
$SectionEmptyHow = @{
  architecture = 'Write documentation/D100-&lt;Area&gt;-architecture.html for an area, and D100-&lt;Project&gt;-architecture.html for the landscape; conventions go under documentation/conventions/&lt;stack&gt;/. The site picks them up on its next run.'
  environments = 'Write documentation/E100-&lt;Project&gt;-&lt;Area&gt;-environments.html with a section 3 of Name | dev | test | prod tables; the site renders the tables here on its next run.'
  features     = 'Design a feature with /asimov-design; it lands at documentation/features/D101-&lt;slug&gt;.html and appears here on the site''s next run.'
  testing      = 'Write documentation/T100-&lt;Project&gt;-test-strategy.html and documentation/T101-&lt;Area&gt;-test-plan.html; the site lists them here on its next run.'
  project      = 'Write the project info with /asimov-project project info; a release is one page under documentation/releases/. Both appear here on the site''s next run.'
  reference    = 'Put an analysis under documentation/analysis/, a research note under documentation/reference/, an external contract in its own folder under reference/; the site lists them here on its next run.'
}

# ---------------------------------------------------------------------------------------------
# Build the site model: sections -> children (doc | group | envtable | groups)
# ---------------------------------------------------------------------------------------------
function Doc-Item([string]$rel, [string]$type, [string]$label) {
  $m = Get-Meta $rel
  $title = $m.title; if ($label) { $title = $label }
  return [ordered]@{ kind = 'doc'; rel = $rel; href = $rel; type = $type; title = $title; desc = $m.desc; chips = $m.chips; ext = $m.ext }
}
function Type-Of([string]$rel) {
  $f = Family $rel; if ($f) { return $f }
  $ext = [System.IO.Path]::GetExtension($rel).ToLowerInvariant()
  if ($rel -like 'conventions/*') { if ($rel -like '*/README.md') { return 'Index' }; return 'Convention' }
  if ($rel -like 'releases/*') { return 'Release' }
  if ($rel -like 'analysis/*') { if ($ext -eq '.md') { return 'Note' }; return 'Analysis' }
  if ($rel -like 'reference/*') { if ($ext -in '.yaml', '.yml', '.json') { return 'Contract' }; return 'Reference' }
  if ($rel -like '*-template.md') { return 'Template' }
  return $ext.TrimStart('.').ToUpperInvariant()
}

$Used = @{}
function Take([string]$rel) { $Used[$rel] = $true }
$Sections = [ordered]@{}
foreach ($s in $SectionOrder) { $Sections[$s] = New-Object System.Collections.ArrayList }

$Landscape = $null
$RootDocs = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -notmatch '/' })

# --- architecture
$d100s = @($RootDocs | Where-Object { (Family $_) -eq 'D100' })
$areaD100 = @{}
foreach ($d in $d100s) {
  $a = Area-Of $d
  if ($a) { $areaD100[$a.key] = $d } else { if (-not $Landscape) { $Landscape = $d } }
}
if ($Landscape) {
  $item = Doc-Item $Landscape 'D100' 'System landscape'; $item.slug = 'landscape'; $item.label = 'System landscape'
  [void]$Sections.architecture.Add($item); Take $Landscape
}
foreach ($a in $Areas) {
  if ($areaD100.ContainsKey($a.key)) {
    $item = Doc-Item $areaD100[$a.key] 'D100' $a.name; $item.slug = $a.slug; $item.label = $a.name
    [void]$Sections.architecture.Add($item); Take $areaD100[$a.key]
  }
}
foreach ($d in $d100s) { if (-not $Used.ContainsKey($d)) { $m = Get-Meta $d; $item = Doc-Item $d 'D100' ''; $item.slug = Slug ((Scope-Tokens $d) -join ' '); $item.label = $m.title; [void]$Sections.architecture.Add($item); Take $d } }
$diagrams = @($RootDocs | Where-Object { $_ -match '\.(png|svg)$' })
if ($diagrams.Count -gt 0) {
  $items = @($diagrams | ForEach-Object { Take $_; Doc-Item $_ (Type-Of $_) '' })
  [void]$Sections.architecture.Add([ordered]@{ kind = 'group'; slug = 'diagrams'; label = 'Code structure'; desc = 'The drawings: how the code is layered and how the projects compose.'; items = $items })
}
$convDirs = @()
$convRoot = Join-Path $Root 'conventions'
if (Test-Path -LiteralPath $convRoot) { $convDirs = @(Get-ChildItem -LiteralPath $convRoot -Directory | ForEach-Object { $_.Name }); $convDirs = Sort-Ordinal $convDirs }
if ($convDirs.Count -gt 0 -or ($Docs.Keys | Where-Object { $_ -like 'conventions/*' })) {
  $groups = New-Object System.Collections.ArrayList
  foreach ($stack in $convDirs) {
    $files = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -like "conventions/$stack/*" })
    $readme = @($files | Where-Object { $_ -like '*/README.md' }); $rest = @($files | Where-Object { $_ -notlike '*/README.md' })
    $items = @()
    foreach ($f in @($readme + $rest)) { Take $f; $items += (Doc-Item $f (Type-Of $f) '') }
    $label = $stack; if ($stack -eq 'dotnet') { $label = '.NET' } elseif ($stack.Length -le 3) { $label = $stack.ToUpperInvariant() } else { $label = $stack.Substring(0, 1).ToUpperInvariant() + $stack.Substring(1) }
    $desc = ''; if ($readme.Count -gt 0) { $desc = (Get-Meta $readme[0]).desc }
    [void]$groups.Add([ordered]@{ label = $label; id = $stack; desc = $desc; items = $items })
  }
  foreach ($f in @($Docs.Keys | Where-Object { $_ -like 'conventions/*' -and -not $Used.ContainsKey($_) })) { Take $f }  # conventions/README.md: the index, not a card
  [void]$Sections.architecture.Add([ordered]@{ kind = 'groups'; slug = 'conventions'; label = 'Conventions'; desc = 'How we write code, per stack. The build agents load each stack''s read-list at run-time.'; groups = @($groups) })
}

# --- environments
$e100s = @($RootDocs | Where-Object { (Family $_) -eq 'E100' })
$landscapeE100 = $null
foreach ($e in $e100s) {
  $a = Area-Of $e
  if ($a) {
    Take $e
    $archHref = ''; if ($areaD100.ContainsKey($a.key)) { $archHref = $areaD100[$a.key] }
    [void]$Sections.environments.Add([ordered]@{ kind = 'envtable'; slug = $a.slug; label = $a.name; rel = $e; arch = $archHref; desc = "What the $($a.name) area deploys and what it is called in each environment." })
  } elseif (-not $landscapeE100) { $landscapeE100 = $e }
}
if ($landscapeE100) { Take $landscapeE100; $item = Doc-Item $landscapeE100 'E100' 'Naming & rules'; $item.slug = 'rules'; $item.label = 'Naming & rules'; [void]$Sections.environments.Add($item) }
foreach ($e in $e100s) { if (-not $Used.ContainsKey($e)) { Take $e; $m = Get-Meta $e; $item = Doc-Item $e 'E100' ''; $item.slug = Slug ((Scope-Tokens $e) -join ' '); $item.label = $m.title; [void]$Sections.environments.Add($item) } }

# --- features
$d101s = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -like 'features/*' -and (Family $_) -eq 'D101' })
$byArea = [ordered]@{}
foreach ($a in $Areas) { $byArea[$a.key] = New-Object System.Collections.ArrayList }
$unassigned = New-Object System.Collections.ArrayList
foreach ($d in $d101s) {
  Take $d
  $a = Area-Of $d
  $type = 'D101'; if ($d -like '*-template.md') { $type = 'Template' }
  $item = Doc-Item $d $type ''
  if ($a) { [void]$byArea[$a.key].Add($item) } else { [void]$unassigned.Add($item) }
}
if ($Areas.Count -gt 0) {
  # a design naming no area belongs to the first area held here
  $homeArea = $null; if ($AreasHere.Count -gt 0) { $homeArea = $AreasHere[0] } else { $homeArea = $Areas[0] }
  foreach ($u in $unassigned) { [void]$byArea[$homeArea.key].Add($u) }
  foreach ($a in $Areas) {
    if ($byArea[$a.key].Count -eq 0 -and -not $a.here) { continue }
    [void]$Sections.features.Add([ordered]@{ kind = 'group'; slug = $a.slug; label = $a.name; desc = "Features of the $($a.name) area."; items = @($byArea[$a.key]) })
  }
} elseif ($unassigned.Count -gt 0) {
  [void]$Sections.features.Add([ordered]@{ kind = 'group'; slug = 'all'; label = 'All features'; desc = 'One design per feature.'; items = @($unassigned) })
}

# --- testing
foreach ($t in @($RootDocs | Where-Object { (Family $_) -eq 'T100' })) { Take $t; $item = Doc-Item $t 'T100' 'Strategy'; $item.slug = 'strategy'; $item.label = 'Strategy'; [void]$Sections.testing.Add($item) }
foreach ($t in @($RootDocs | Where-Object { (Family $_) -eq 'T101' })) {
  Take $t; $a = Area-Of $t
  $label = 'Test plan'; $slug = 'plan'
  if ($a) { $label = "$($a.name) test plan"; $slug = $a.slug }
  $item = Doc-Item $t 'T101' $label; $item.slug = $slug; $item.label = $label; [void]$Sections.testing.Add($item)
}

# --- project
if ($Project) {
  [void]$Sections.project.Add([ordered]@{ kind = 'doc'; rel = '../project/info.html'; href = '../project/info.html'; type = 'Project'; title = 'Project info'; desc = 'Name, customer, language, the areas the project is made of and the repository that holds each. The project''s record.'; chips = ''; ext = '.html'; slug = 'info'; label = 'Project info'; external = $true })
}
$riskPath = Join-Path $ProjectDir 'risk-log.html'
if (Test-Path -LiteralPath $riskPath) {
  [void]$Sections.project.Add([ordered]@{ kind = 'doc'; rel = '../project/risk-log.html'; href = '../project/risk-log.html'; type = 'Project'; title = 'Risk log'; desc = 'The engagement''s register of risks: what could go wrong, who owns it, what is done about it.'; chips = ''; ext = '.html'; slug = 'risk-log'; label = 'Risk log'; external = $true })
}
$releases = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -like 'releases/*' })
if ($releases.Count -gt 0) {
  $items = @()
  foreach ($r in $releases) { Take $r; $items += (Doc-Item $r 'Release' '') }
  [array]::Reverse($items)
  [void]$Sections.project.Add([ordered]@{ kind = 'group'; slug = 'releases'; label = 'Releases'; desc = 'What went out, and when. Newest first.'; items = $items })
}

# --- reference
$analyses = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -like 'analysis/*' })
if ($analyses.Count -gt 0) {
  $items = @(); foreach ($x in $analyses) { Take $x; $items += (Doc-Item $x (Type-Of $x) '') }
  [void]$Sections.reference.Add([ordered]@{ kind = 'group'; slug = 'analyses'; label = 'Analyses'; desc = 'Analyses and dated notes that fed a design.'; items = $items })
}
$research = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -like 'reference/*' -and $_ -notmatch '^reference/[^/]+/' })
if ($research.Count -gt 0) {
  $items = @(); foreach ($x in $research) { Take $x; $items += (Doc-Item $x (Type-Of $x) '') }
  [void]$Sections.reference.Add([ordered]@{ kind = 'group'; slug = 'research'; label = 'Research'; desc = 'The thinking behind the way we work.'; items = $items })
}
$external = Sort-Ordinal @($Docs.Keys | Where-Object { $_ -match '^reference/[^/]+/' })
if ($external.Count -gt 0) {
  $items = @(); foreach ($x in $external) { Take $x; $items += (Doc-Item $x (Type-Of $x) '') }
  [void]$Sections.reference.Add([ordered]@{ kind = 'group'; slug = 'external'; label = 'External'; desc = 'Contracts and specifications owned by others.'; items = $items })
}

$Uncategorised = Sort-Ordinal @($Docs.Keys | Where-Object { -not $Used.ContainsKey($_) })

# ---------------------------------------------------------------------------------------------
# Where a document is shown: the rendering of a markdown document, or the document itself
# ---------------------------------------------------------------------------------------------
function Render-Path([string]$rel) { return ('_site/doc/' + $rel.Substring(0, $rel.Length - 3) + '.html') }
function Shown-Href([hashtable]$item) {
  if ($item.ext -eq '.md' -and $CanRenderMarkdown) { return (Render-Path $item.rel) }
  return $item.href
}
function Child-Href([string]$section, [hashtable]$child) {
  if ($child.kind -eq 'doc') { return (Shown-Href $child) }
  return "_site/$section-$($child.slug).html"
}
# the section and child a document is shown under (for its nav)
$Placement = @{}
foreach ($s in $SectionOrder) {
  foreach ($c in $Sections[$s]) {
    if ($c.kind -eq 'doc') { $Placement[$c.rel] = @{ section = $s; child = $c.slug } }
    elseif ($c.kind -eq 'envtable') { $Placement[$c.rel] = @{ section = $s; child = $c.slug } }
    elseif ($c.kind -eq 'group') { foreach ($i in $c.items) { $Placement[$i.rel] = @{ section = $s; child = $c.slug } } }
    elseif ($c.kind -eq 'groups') { foreach ($g in $c.groups) { foreach ($i in $g.items) { $Placement[$i.rel] = @{ section = $s; child = $c.slug } } } }
  }
}

# ---------------------------------------------------------------------------------------------
# The nav block
# ---------------------------------------------------------------------------------------------
function New-Nav([string]$section, [string]$child, [string]$prefix, [string]$chips) {
  $tpl = $NavTpl
  $topItem = Get-Block $tpl 'top-item'
  $items = ''
  $act = ''; if ($section -eq 'home') { $act = ' class="active"' }
  $items += (Fill $topItem @{ ACTIVE = $act; HREF = "${prefix}index.html"; LABEL = 'Home' })
  foreach ($s in $SectionOrder) {
    $act = ''; if ($s -eq $section) { $act = ' class="active"' }
    $items += (Fill $topItem @{ ACTIVE = $act; HREF = "${prefix}_site/$s.html"; LABEL = $SectionLabel[$s] })
  }
  $tpl = Set-Block $tpl 'top-item' $items
  if ($section -eq 'home' -or -not $SectionLabel.ContainsKey($section)) {
    $tpl = Drop-Block $tpl 'sub-nav'
  } else {
    $sub = Get-Block $tpl 'sub-nav'
    $subItem = Get-Block $sub 'sub-item'
    $act = ''; if ($child -eq 'overview') { $act = ' class="active"' }
    $sitems = (Fill $subItem @{ ACTIVE = $act; HREF = "${prefix}_site/$section.html"; LABEL = 'Overview' })
    foreach ($c in $Sections[$section]) {
      $act = ''; if ($c.slug -eq $child) { $act = ' class="active"' }
      $sitems += (Fill $subItem @{ ACTIVE = $act; HREF = ($prefix + (Child-Href $section $c)); LABEL = (Esc $c.label) })
    }
    $sub = Set-Block $sub 'sub-item' $sitems
    if ($chips) { $sub = Set-Block $sub 'chips' (Fill (Get-Block $sub 'chips') @{ CHIPS = $chips }) } else { $sub = Drop-Block $sub 'chips' }
    $sub = Fill $sub @{ SECTION = $SectionLabel[$section] }
    $tpl = Set-Block $tpl 'sub-nav' $sub
  }
  $tpl = Fill $tpl @{ PREFIX = $prefix; 'REPO-NAME' = (Esc $Repo) }
  return ($tpl -replace '\.\./documentation/\.\./', '../').TrimEnd("`n")
}

# ---------------------------------------------------------------------------------------------
# Cards and pages
# ---------------------------------------------------------------------------------------------
function Card([hashtable]$item, [string]$prefix) {
  $c = $B['card']
  $href = Shown-Href $item
  $fmt = ''
  $ext = $item.ext.TrimStart('.')
  $isPage = ($ext -eq 'html') -or ($ext -eq 'md' -and $CanRenderMarkdown)
  if (-not $isPage) { $fmt = Fill (Get-Block $c 'fmt') @{ FMT = $ext } }
  $c = Set-Block $c 'fmt' $fmt
  if ($item.chips) { $c = Set-Block $c 'chips' (Fill (Get-Block $c 'chips') @{ CHIPS = ($item.chips -replace 'phase-chip', 'chip' -replace 'status-chip', 'chip draft' -replace 'chip full', 'chip full' -replace 'chip business', 'chip business') }) } else { $c = Drop-Block $c 'chips' }
  return (Fill $c @{ HREF = ($prefix + $href); TYPE = (Esc $item.type); TITLE = (Esc $item.title); DESC = (Esc $item.desc) })
}
function Chip-Classes([string]$chips) {
  # the document's chips, as the card shows them: phase -> chip business|full, status -> chip draft
  $out = [regex]::Replace($chips, '<span class="phase-chip([^"]*)">([^<]*)</span>', { param($m) $t = $m.Groups[2].Value; $k = 'business'; if ($t -match '(?i)full') { $k = 'full' }; "<span class=`"chip $k`">$t</span>" })
  $out = [regex]::Replace($out, '<span class="status-chip[^"]*">([^<]*)</span>', '<span class="chip draft">$1</span>')
  return $out
}
function Group-Card([string]$section, [hashtable]$child, [string]$prefix) {
  $n = 0
  if ($child.kind -eq 'groups') { foreach ($g in $child.groups) { $n += @($g.items).Count } } else { $n = @($child.items).Count }
  $item = [ordered]@{ href = (Child-Href $section $child); type = 'Group'; title = $child.label; desc = $child.desc; chips = ''; ext = '.html' }
  $c = Set-Block $B['card'] 'fmt' (Fill (Get-Block $B['card'] 'fmt') @{ FMT = "$n doc" + $(if ($n -ne 1) { 's' } else { '' }) })
  $c = Drop-Block $c 'chips'
  return (Fill $c @{ HREF = ($prefix + $item.href); TYPE = 'Group'; TITLE = (Esc $item.title); DESC = (Esc $item.desc) })
}
function Md-Table([string]$block) {
  # the first pipe table of a markdown block: header cells, rendered column headers, rendered rows (first cell as th), raw cells
  $header = @(); $cols = @(); $rows = ''; $cells = New-Object System.Collections.ArrayList
  foreach ($line in ($block -split "`n")) {
    $l = $line.Trim()
    if (-not $l.StartsWith('|')) { if ($header.Count -gt 0) { break }; continue }
    if ($l -match '^\|\s*:?-') { continue }
    $c = @($l.Trim('|').Split('|') | ForEach-Object { $_.Trim() })
    if ($header.Count -eq 0) { $header = $c; $cols = @($c | ForEach-Object { '<th>' + (Esc $_) + '</th>' }); continue }
    if ($c.Count -lt 2) { continue }
    [void]$cells.Add($c)
    $tds = ''; foreach ($cell in $c[1..($c.Count - 1)]) { $tds += '<td>' + (Inline-Md $cell) + '</td>' }
    $rows += (Fill $B['row'] @{ NAME = (Inline-Md $c[0]); CELLS = $tds })
  }
  return @{ header = $header; cols = $cols; rows = $rows; cells = @($cells) }
}
function Env-Tables([hashtable]$child, [string]$prefix) {
  # the section-3 tables of an E100: <h3>3.x Heading</h3><table> (html) or ### 3.x Heading + pipe table (md)
  $rel = $child.rel; $path = $Docs[$rel]
  $text = Norm (Read-Text $path)
  $out = ''
  $archLink = ''; if ($child.arch) { $archLink = " What each name is: <a href=`"$prefix$(Shown-Href (Doc-Item $child.arch 'D100' ''))`">$(Esc $child.label) architecture</a>." }
  $out += (Fill $B['note'] @{ TEXT = "Names as deployed, read from the <a href=`"$prefix$(Shown-Href (Doc-Item $rel 'E100' ''))`">environment document</a>.$archLink" })
  if ($rel.EndsWith('.html')) {
    foreach ($m in [regex]::Matches($text, '(?s)<h3[^>]*>\s*3\.\d+\s+(.+?)</h3>\s*<table>(.*?)</table>')) {
      $heading = Strip-Tags $m.Groups[1].Value
      $cols = @([regex]::Matches($m.Groups[2].Value, '(?s)<th[^>]*>(.*?)</th>') | ForEach-Object { '<th>' + $_.Groups[1].Value.Trim() + '</th>' })
      $rows = ''
      foreach ($tr in [regex]::Matches($m.Groups[2].Value, '(?s)<tr>(.*?)</tr>')) {
        $cells = @([regex]::Matches($tr.Groups[1].Value, '(?s)<td>(.*?)</td>') | ForEach-Object { $_.Groups[1].Value.Trim() })
        if ($cells.Count -lt 2) { continue }
        $tds = ''; foreach ($cell in $cells[1..($cells.Count - 1)]) { $tds += "<td>$cell</td>" }
        $rows += (Fill $B['row'] @{ NAME = $cells[0]; CELLS = $tds })
      }
      if ($rows) { $out += (Fill $B['table'] @{ HEADING = (Esc $heading); COLUMNS = ($cols -join ''); ROWS = $rows.TrimEnd("`n") }) }
    }
  } else {
    $found = $false
    # (a) section 3 with one table per heading: ### 3.x Heading, then Name | dev | test | prod
    foreach ($m in [regex]::Matches($text, '(?ms)^### 3\.\d+ (.+?)$\n(.*?)(?=^### |^## |\z)')) {
      $t = Md-Table $m.Groups[2].Value
      if ($t.rows.Length -gt 0 -and $t.cols.Count -ge 3) { $found = $true; $out += (Fill $B['table'] @{ HEADING = (Esc $m.Groups[1].Value.Trim()); COLUMNS = ($t.cols -join ''); ROWS = $t.rows.TrimEnd("`n") }) }
    }
    # (b) section 3 holding one table of Name | dev | test | prod directly
    if (-not $found) {
      $m = [regex]::Match($text, '(?ms)^## 3\.[^\n]*\n(.*?)(?=^## |\z)')
      if ($m.Success) {
        $t = Md-Table $m.Groups[1].Value
        if ($t.rows.Length -gt 0 -and $t.header.Count -ge 4 -and @($t.header[1..3] | Where-Object { $_ -match '(?i)^(local|dev|test|prod|stage|staging|uat|acc)' }).Count -ge 2) { $found = $true; $out += (Fill $B['table'] @{ HEADING = 'Components'; COLUMNS = ($t.cols -join ''); ROWS = $t.rows.TrimEnd("`n") }) }
      }
    }
    # (c) one table per environment (### 4.x `env`, Component | Name), pivoted into Name | env ...
    if (-not $found) {
      $envs = New-Object System.Collections.ArrayList; $byName = [ordered]@{}
      foreach ($m in [regex]::Matches($text, '(?ms)^### \d+\.\d+ `?([a-z]+)`?[^\n]*\n(.*?)(?=^### |^## |\z)')) {
        $env = $m.Groups[1].Value
        if ($env -eq 'local') { continue }
        $t = Md-Table $m.Groups[2].Value
        if ($t.cells.Count -eq 0) { continue }
        [void]$envs.Add($env)
        foreach ($row in $t.cells) { if ($row.Count -lt 2) { continue }; if (-not $byName.Contains($row[0])) { $byName[$row[0]] = @{} }; $byName[$row[0]][$env] = $row[1] }
      }
      if ($envs.Count -gt 0) {
        $found = $true
        $cols = @('<th>Name</th>') + @($envs | ForEach-Object { '<th>' + (Esc $_) + '</th>' })
        $rows = ''
        foreach ($name in $byName.Keys) {
          $tds = ''; foreach ($e in $envs) { $v = $byName[$name][$e]; if ($null -eq $v) { $v = '-' }; $tds += '<td>' + (Inline-Md $v) + '</td>' }
          $rows += (Fill $B['row'] @{ NAME = (Inline-Md $name); CELLS = $tds })
        }
        $out += (Fill $B['table'] @{ HEADING = 'Components'; COLUMNS = ($cols -join ''); ROWS = $rows.TrimEnd("`n") })
      }
    }
    if (-not $found) { $out += (Fill $B['note'] @{ TEXT = 'The environment document has no table of deployed names per environment (section 3 as Name | dev | test | prod, or one table per environment in section 4); open the document itself.' }) }
  }
  return $out
}
function Empty-Body([string]$section) { return (Fill $B['empty'] @{ WHAT = $SectionEmptyWhat[$section]; HOW = $SectionEmptyHow[$section] }) }

function Section-Page([string]$section) {
  $prefix = '../'
  $children = $Sections[$section]
  $cards = ''
  foreach ($c in $children) {
    if ($c.kind -eq 'doc') { $cards += (Card ([hashtable]$c) $prefix) }
    elseif ($c.kind -eq 'envtable') { $cards += (Fill (Drop-Block (Drop-Block $B['card'] 'fmt') 'chips') @{ HREF = ($prefix + (Child-Href $section $c)); TYPE = 'E100'; TITLE = (Esc $c.label); DESC = (Esc $c.desc) }) }
    else { $cards += (Group-Card $section ([hashtable]$c) $prefix) }
  }
  $intro = ''
  if ($section -eq 'architecture' -and $Landscape) {
    $h = Norm (Read-Text $Docs[$Landscape])
    $img = [regex]::Match($h, '<img[^>]+src="([^"]+)"[^>]*>')
    if (-not $img.Success -and $Landscape.EndsWith('.md')) { $img = [regex]::Match($h, '!\[[^\]]*\]\(([^)]+)\)') }
    if ($img.Success) {
      $src = Unesc ($img.Groups[1].Value -replace '%20', ' ')
      if ($src -notmatch '^(https?:)?//' -and (Test-Path -LiteralPath (Join-Path $Root $src))) {
        $title = (Get-Meta $Landscape).title
        $intro = Fill $B['figure'] @{ SRC = ($prefix + (Attr $src)); ALT = (Attr $title); CAPTION = ("The landscape, as <a href=`"$prefix$(Shown-Href (Doc-Item $Landscape 'D100' ''))`">$(Esc $title)</a> draws it. Click to open full size.") }
      }
    }
  }
  $body = ''
  if ($cards) { $body = Fill $B['grid'] @{ CARDS = $cards.TrimEnd("`n") } } else { $body = Empty-Body $section }
  $page = Set-Block $SectionPage 'crumb' ''
  return (Fill $page @{ NAV = (New-Nav $section 'overview' $prefix ''); TITLE = $SectionLabel[$section]; LEDE = (Esc $SectionLede[$section]); INTRO = $intro; BODY = $body.TrimEnd("`n"); 'REPO-NAME' = (Esc $Repo) })
}
function Group-Page([string]$section, [hashtable]$child) {
  $prefix = '../'
  $crumb = Fill (Get-Block $SectionPage 'crumb') @{ 'SECTION-HREF' = "$section.html"; SECTION = $SectionLabel[$section]; CHILD = (Esc $child.label) }
  $page = Set-Block $SectionPage 'crumb' $crumb
  $intro = ''; $body = ''
  if ($child.kind -eq 'envtable') {
    $intro = Env-Tables $child $prefix
  } elseif ($child.kind -eq 'groups') {
    foreach ($g in $child.groups) {
      $cards = ''; foreach ($i in $g.items) { $cards += (Card ([hashtable]$i) $prefix) }
      $body += (Fill $B['group-head'] @{ ID = (Attr $g.id); LABEL = (Esc $g.label); DESC = (Esc $g.desc) })
      if ($cards) { $body += (Fill $B['grid'] @{ CARDS = $cards.TrimEnd("`n") }) }
    }
  } else {
    $cards = ''; foreach ($i in $child.items) { $cards += (Card ([hashtable]$i) $prefix) }
    if ($cards) { $body = Fill $B['grid'] @{ CARDS = $cards.TrimEnd("`n") } } else { $body = Empty-Body $section }
  }
  return (Fill $page @{ NAV = (New-Nav $section $child.slug $prefix ''); TITLE = (Esc $child.label); LEDE = (Esc $child.desc); INTRO = $intro.TrimEnd("`n"); BODY = $body.TrimEnd("`n"); 'REPO-NAME' = (Esc $Repo) })
}
function Home-Page() {
  $tpl = $HomeTpl
  $projectName = $Repo; $title = $Repo; $lede = ''
  if ($Project) {
    $projectName = $Project.name
    $title = $Repo -replace '-', ' '
    $hereNames = @($AreasHere | ForEach-Object { $_.name })
    $n = @($Areas).Count
    $lede = (Esc $Project.lede)
    if ($n -gt 0) {
      $count = @('no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine')[[Math]::Min($n, 9)]
      $holds = ''
      if ($hereNames.Count -eq 1) { $holds = "<strong>$(Esc $hereNames[0])</strong>" }
      elseif ($hereNames.Count -gt 1) { $holds = (($hereNames[0..($hereNames.Count - 2)] | ForEach-Object { "<strong>$(Esc $_)</strong>" }) -join ', ') + " and <strong>$(Esc $hereNames[-1])</strong>" }
      $lede += " The project has $count areas"
      if ($holds) { $lede += "; this repository holds $holds." } else { $lede += '.' }
    }
    $rowTpl = Get-Block $tpl 'area-row'
    $rows = ''
    foreach ($a in $Areas) {
      $nameHtml = Esc $a.name
      $what = ''
      if ($a.here -and $areaD100.ContainsKey($a.key)) { $nameHtml = "<a href=`"$(Shown-Href (Doc-Item $areaD100[$a.key] 'D100' ''))`">$(Esc $a.name)</a>"; $what = Esc (First-Sentence (Get-Meta $areaD100[$a.key]).desc) }
      $where = $a.repo; $whereClass = 'where'
      if ($a.here) { $where = 'this repository'; $whereClass = 'where here' }
      elseif (-not $where -or $where -match '^(?i)not decided$') { $where = 'not decided'; $whereClass = 'where unset' }
      $rowClass = ''; if ($a.here) { $rowClass = ' class="here"' }
      $rows += (Fill $rowTpl @{ 'ROW-CLASS' = $rowClass; 'AREA-HTML' = $nameHtml; WHAT = $what; 'WHERE-CLASS' = $whereClass; WHERE = (Esc $where) })
    }
    $areasBlock = Set-Block (Get-Block $tpl 'areas') 'area-row' $rows
    $landscapeLink = ''; if ($Landscape) { $landscapeLink = " · <a href=`"$(Shown-Href (Doc-Item $Landscape 'D100' ''))`">How the areas fit together</a>" }
    $areasBlock = Fill $areasBlock @{ 'LANDSCAPE-LINK' = $landscapeLink }
    $tpl = Set-Block $tpl 'areas' $areasBlock
    $tpl = Drop-Block $tpl 'no-areas'
  } else {
    $lede = "The documentation of $(Esc $Repo)."
    $tpl = Drop-Block $tpl 'areas'
    $tpl = Set-Block $tpl 'no-areas' (Get-Block $tpl 'no-areas')
  }
  $rowTpl = Get-Block $tpl 'section-row'
  $rows = ''
  foreach ($s in $SectionOrder) { $rows += (Fill $rowTpl @{ HREF = "_site/$s.html"; LABEL = $SectionLabel[$s]; WHAT = $SectionWhat[$s] }) }
  $readme = Get-ChildItem -LiteralPath $RepoRoot -File | Where-Object { $_.Name -match '^readme\.md$' } | Select-Object -First 1
  if ($readme) { $rows += (Fill $rowTpl @{ HREF = ('../' + $readme.Name); LABEL = 'Readme'; WHAT = 'The repository''s readme: how to build, run and test locally.' }) }
  $tpl = Set-Block $tpl 'section-row' $rows
  return (Fill $tpl @{ NAV = (New-Nav 'home' '' '' ''); 'PROJECT-NAME' = (Esc $projectName); TITLE = (Esc $title); LEDE = $lede; 'REPO-NAME' = (Esc $Repo) })
}

# ---------------------------------------------------------------------------------------------
# Markdown documents, rendered (PowerShell 7)
# ---------------------------------------------------------------------------------------------
function Render-Markdown([string]$rel) {
  $path = $Docs[$rel]
  $md = Norm (Read-Text $path)
  $out = Render-Path $rel
  $prefix = Prefix-Of $out
  $docDir = Split-Path -Parent $rel; if ($docDir) { $docDir = ($docDir -replace '\\', '/') + '/' } else { $docDir = '' }
  # links: a sibling .md the site renders -> its rendering; other relative links -> back to the document's folder
  $md = [regex]::Replace($md, '\]\(([^)\s]+)(\s+"[^"]*")?\)', {
    param($m)
    $href = $m.Groups[1].Value; $titlePart = $m.Groups[2].Value
    if ($href -match '^(https?:|mailto:|#|/)') { return $m.Value }
    $frag = ''; $i = $href.IndexOf('#'); if ($i -ge 0) { $frag = $href.Substring($i); $href = $href.Substring(0, $i) }
    if (-not $href) { return $m.Value }
    # relative to documentation/ again, ../ kept for a target above it; another drive stays as written
    $full = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $Root $docDir) $href))
    $targetRel = [System.IO.Path]::GetRelativePath($Root, $full) -replace '\\', '/'
    if ([System.IO.Path]::IsPathRooted($targetRel)) { return $m.Value }
    $shown = $null
    if ($targetRel.EndsWith('.md')) {
      $html = $targetRel.Substring(0, $targetRel.Length - 3) + '.html'
      # rendered only when placed in a section, the same test the renderer below uses
      if ($Docs.ContainsKey($html)) { $shown = $html } elseif ($Placement.ContainsKey($targetRel)) { $shown = Render-Path $targetRel } else { $shown = $targetRel }
    } else { $shown = $targetRel }
    return '](' + $prefix + $shown + $frag + $titlePart + ')'
  })
  $md = [regex]::Replace($md, '!\]\(', '](')  # (no-op guard)
  $html = (ConvertFrom-Markdown -InputObject $md).Html
  # images that were relative are now prefixed like links; nothing else to do
  $title = ''
  $m = [regex]::Match($html, '(?s)<h1[^>]*>(.*?)</h1>\s*')
  if ($m.Success) { $title = Strip-Tags $m.Groups[1].Value; $html = $html.Remove($m.Index, $m.Length) } else { $title = (Get-Meta $rel).title }
  $toc = ''
  $tocTpl = Get-Block $DocTpl 'toc-item'
  foreach ($h2 in [regex]::Matches($html, '(?s)<h2 id="([^"]+)">(.*?)</h2>')) { $toc += (Fill $tocTpl @{ ID = $h2.Groups[1].Value; TEXT = (Esc (Strip-Tags $h2.Groups[2].Value)) }) }
  $page = Set-Block $DocTpl 'toc-item' $toc
  $pl = $Placement[$rel]
  $section = 'reference'; $childSlug = ''; $childLabel = ''
  if ($pl) { $section = $pl.section; $childSlug = $pl.child; $c = $Sections[$section] | Where-Object { $_.slug -eq $childSlug } | Select-Object -First 1; if ($c) { $childLabel = $c.label } }
  return @{ path = $out; html = (Fill $page @{ NAV = (New-Nav $section $childSlug $prefix ''); TITLE = (Esc $title); KIND = (Type-Of $rel); SOURCE = (Esc $rel); 'SOURCE-HREF' = ($prefix + $rel); 'SECTION-HREF' = "${prefix}_site/$section.html"; SECTION = $SectionLabel[$section]; CHILD = (Esc $childLabel); BODY = $html.TrimEnd("`n"); PREFIX = $prefix; 'REPO-NAME' = (Esc $Repo) }) }
}

# ---------------------------------------------------------------------------------------------
# The nav block in authored pages
# ---------------------------------------------------------------------------------------------
function Inject-Nav([string]$html, [string]$section, [string]$child, [string]$prefix) {
  $m = [regex]::Match($html, '(?s)<!-- asimov-nav:start -->.*?<!-- asimov-nav:end -->\n?')
  $old = ''
  if ($m.Success) { $old = $m.Value } else { $m = [regex]::Match($html, '(?s)<nav class="top-nav">.*?</nav>\n?'); if ($m.Success) { $old = $m.Value } }
  if (-not $old) { return $null }
  $chips = ''
  $seen = @{}
  foreach ($c in [regex]::Matches($old, '(?s)<span class="((?:phase|status)-chip[^"]*)">(.*?)</span>')) {
    $kind = $c.Groups[1].Value.Split(' ')[0]; if ($seen.ContainsKey($kind)) { continue }; $seen[$kind] = $true
    $chips += '<span class="' + $c.Groups[1].Value + '">' + (Squash (Strip-Tags $c.Groups[2].Value)) + '</span>'
  }
  $block = (New-Nav $section $child $prefix $chips) + "`n"
  return $html.Replace($old, $block)
}

# ---------------------------------------------------------------------------------------------
# Render everything into memory
# ---------------------------------------------------------------------------------------------
$Out = [ordered]@{}   # repo-root-relative path -> text
function Put([string]$relFromRoot, [string]$text) { $Out[$relFromRoot] = $text }
$docRel = (Rel $RepoRoot $Root).TrimEnd('/')

Put "$docRel/index.html" (Home-Page)
Put "$docRel/_chrome.css" $Chrome
foreach ($s in $SectionOrder) {
  Put "$docRel/_site/$s.html" (Section-Page $s)
  foreach ($c in $Sections[$s]) { if ($c.kind -ne 'doc') { Put "$docRel/_site/$s-$($c.slug).html" (Group-Page $s ([hashtable]$c)) } }
}
$Rendered = 0; $Unrendered = New-Object System.Collections.ArrayList
foreach ($rel in (Sort-Ordinal @($Placement.Keys))) {
  if (-not $rel.EndsWith('.md') -or -not $Docs.ContainsKey($rel)) { continue }
  if ($CanRenderMarkdown) { $r = Render-Markdown $rel; Put "$docRel/$($r.path)" $r.html; $Rendered++ } else { [void]$Unrendered.Add($rel) }
}
$Injected = New-Object System.Collections.ArrayList; $NoNav = New-Object System.Collections.ArrayList
foreach ($rel in (Sort-Ordinal @($Placement.Keys))) {
  if (-not $rel.EndsWith('.html') -or -not $Docs.ContainsKey($rel)) { continue }
  $pl = $Placement[$rel]
  $html = Norm (Read-Text $Docs[$rel])
  $new = Inject-Nav $html $pl.section $pl.child (Prefix-Of $rel)
  if ($null -eq $new) { [void]$NoNav.Add($rel); continue }
  Put "$docRel/$rel" $new; [void]$Injected.Add($rel)
}
if (Test-Path -LiteralPath $ProjectDir) {
  foreach ($f in (Get-ChildItem -LiteralPath $ProjectDir -Filter '*.html' -File | Sort-Object -Property Name)) {
    $html = Norm (Read-Text $f.FullName)
    $child = [System.IO.Path]::GetFileNameWithoutExtension($f.Name); if ($child -eq 'info') { $child = 'info' }
    $new = Inject-Nav $html 'project' $child "../$docRel/"
    if ($null -eq $new) { [void]$NoNav.Add("project/$($f.Name)"); continue }
    Put "project/$($f.Name)" $new; [void]$Injected.Add("project/$($f.Name)")
  }
}

# ---------------------------------------------------------------------------------------------
# Plan, check or write
# ---------------------------------------------------------------------------------------------
if ($Plan) {
  $model = [ordered]@{ repo = $Repo; root = $docRel; project = $Project; sections = $Sections; uncategorised = $Uncategorised; writes = @($Out.Keys) }
  Write-Output ($model | ConvertTo-Json -Depth 8)
  exit 0
}

$Written = New-Object System.Collections.ArrayList; $Same = 0; $Changed = New-Object System.Collections.ArrayList
foreach ($k in $Out.Keys) {
  $path = Join-Path $RepoRoot $k
  $text = $Out[$k]
  $existing = $null
  if (Test-Path -LiteralPath $path) { $existing = Norm ([System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)) }
  if ($existing -ceq $text) { $Same++; continue }
  [void]$Changed.Add($k)
  if ($Check) { continue }
  $dir = Split-Path -Parent $path
  if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
  [System.IO.File]::WriteAllText($path, $text, $Utf8)
  [void]$Written.Add($k)
}
# pages under _site/ the model no longer produces are stale: remove them
$Stale = New-Object System.Collections.ArrayList
$siteDir = Join-Path $Root '_site'
if (Test-Path -LiteralPath $siteDir) {
  foreach ($f in (Get-ChildItem -LiteralPath $siteDir -Recurse -File -Filter '*.html')) {
    $k = Rel $RepoRoot $f.FullName
    if (-not $Out.Contains($k)) { [void]$Stale.Add($k); if (-not $Check) { Remove-Item -LiteralPath $f.FullName -Force } }
  }
}

if ($Check) {
  if ($Changed.Count -eq 0 -and $Stale.Count -eq 0) { Write-Output "site: up to date ($Same files)"; exit 0 }
  Write-Output "site: out of date; $($Changed.Count) file(s) would change, $($Stale.Count) stale:"
  foreach ($c in $Changed) { Write-Output "  $c" }
  foreach ($c in $Stale) { Write-Output "  stale $c" }
  exit 1
}

$counts = @()
foreach ($s in $SectionOrder) {
  $n = 0
  foreach ($c in $Sections[$s]) { if ($c.kind -eq 'doc' -or $c.kind -eq 'envtable') { $n++ } elseif ($c.kind -eq 'group') { $n += @($c.items).Count } else { foreach ($g in $c.groups) { $n += @($g.items).Count } } }
  $counts += "$($SectionLabel[$s]) $n"
}
Write-Output "site: $($Written.Count) file(s) written, $Same unchanged, $($Stale.Count) stale removed; $Rendered markdown document(s) rendered; nav in $($Injected.Count) authored page(s)"
Write-Output "sections: $($counts -join ' / ')"
if ($Project) { Write-Output "project info: $($Project.name), $(@($Areas).Count) area(s), $(@($AreasHere).Count) held here" } else { Write-Output 'project info: none (project/info.html); the front page says so' }
if ($Unrendered.Count -gt 0) { Write-Output "markdown not rendered (PowerShell $($PSVersionTable.PSVersion.Major); the cards link the .md): $($Unrendered.Count)" }
if ($NoNav.Count -gt 0) { Write-Output "no nav block to replace (page has no <nav class=`"top-nav`"> and no markers): $($NoNav -join ', ')" }
if ($Uncategorised.Count -gt 0) { Write-Output "fit no section: $($Uncategorised -join ', ')" }
exit 0
