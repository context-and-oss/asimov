# Pester 5 tests for risk-log.ps1. Every slice of the risk-log plan adds its tests here, before
# the script code that makes them pass. Run on PowerShell 7 and on Windows PowerShell 5.1:
#   Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1
# Pure ASCII, as the script: Windows PowerShell 5.1 reads a BOM-less file as ANSI, so every
# character outside ASCII is built with [char].

BeforeAll {
  $script:RiskLog = Join-Path $PSScriptRoot 'risk-log.ps1'
  $script:Utf8 = New-Object System.Text.UTF8Encoding $false
  $script:ThisShell = (Get-Process -Id $PID).Path

  # A fresh git repo in TestDrive with no identity of its own; git reads no user or system config.
  function New-TestRepo([string]$Name) {
    $root = Join-Path $TestDrive $Name
    New-Item -ItemType Directory -Path $root | Out-Null
    $cfg = Join-Path $TestDrive 'empty.gitconfig'
    if (-not (Test-Path $cfg)) { [System.IO.File]::WriteAllText($cfg, '', $script:Utf8) }
    $env:GIT_CONFIG_GLOBAL = $cfg
    $env:GIT_CONFIG_NOSYSTEM = '1'
    & git -C $root init -q 2>$null | Out-Null
    return $root
  }

  function Write-Change([string]$Root, $Change) {
    $path = Join-Path $Root 'change.json'
    [System.IO.File]::WriteAllText($path, ($Change | ConvertTo-Json -Depth 6), $script:Utf8)
    return $path
  }

  # Runs the script in a child process of the given shell, from the repo root.
  function Invoke-RiskLog([string]$Root, [string[]]$Arguments, [string]$Shell = $script:ThisShell) {
    Push-Location $Root
    try {
      $out = & $Shell -NoProfile -ExecutionPolicy Bypass -File $script:RiskLog @Arguments 2>&1
      return [pscustomobject]@{ Code = $LASTEXITCODE; Output = ($out | Out-String) }
    } finally { Pop-Location }
  }

  function Read-Page([string]$Root) {
    return [System.IO.File]::ReadAllText((Join-Path $Root 'project/risk-log.html'), $script:Utf8)
  }

  function Get-Today { (Get-Date).ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) }

  # A register of the given risks, written by -Apply one add at a time.
  function New-Register([string]$Name, $Risks) {
    $root = New-TestRepo $Name
    foreach ($fields in $Risks) {
      $change = Write-Change $root ([ordered]@{ verb = 'add'; fields = $fields; language = 'en' })
      $r = Invoke-RiskLog $root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm')
      if ($r.Code -ne 0) { throw "fixture add failed: $($r.Output)" }
    }
    return $root
  }

  function Set-PageText([string]$Root, [string]$Text) {
    [System.IO.File]::WriteAllText((Join-Path $Root 'project/risk-log.html'), $Text, $script:Utf8)
  }

  # Sets one attribute on the article of the n-th risk with this id (a hand edit of a fixture).
  function Set-RiskAttr([string]$Html, [string]$Id, [string]$Attr, [string]$Value, [int]$Nth = 0) {
    $ms = [regex]::Matches($Html, '<article class="risk" id="' + $Id + '"[^>]*>')
    $m = $ms[$Nth]
    $tag = [regex]::Replace($m.Value, ' ' + $Attr + '="[^"]*"', ' ' + $Attr + '="' + $Value + '"')
    return $Html.Substring(0, $m.Index) + $tag + $Html.Substring($m.Index + $m.Length)
  }

  function Get-PageHash([string]$Root) {
    return [BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.IO.File]::ReadAllBytes((Join-Path $Root 'project/risk-log.html'))))
  }

  function Invoke-Read([string]$Root, [string[]]$More = @()) {
    $r = Invoke-RiskLog $Root (@('-Path', 'project/risk-log.html', '-Read') + $More)
    if ($r.Code -ne 0) { throw "-Read failed ($($r.Code)): $($r.Output)" }
    return ($r.Output | ConvertFrom-Json)
  }

  function Add-Risk([string]$Root, $Fields) {
    $change = Write-Change $Root ([ordered]@{ verb = 'add'; fields = $Fields })
    return Invoke-RiskLog $Root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm')
  }

  # the script writes UTF-8; read its output as UTF-8 whatever the console started with
  $script:SavedOutputEncoding = [Console]::OutputEncoding
  try { [Console]::OutputEncoding = $script:Utf8 } catch { }
  $script:SavedGitGlobal = $env:GIT_CONFIG_GLOBAL
  $script:SavedGitNoSystem = $env:GIT_CONFIG_NOSYSTEM
}

AfterAll {
  try { [Console]::OutputEncoding = $script:SavedOutputEncoding } catch { }
  $env:GIT_CONFIG_GLOBAL = $script:SavedGitGlobal
  $env:GIT_CONFIG_NOSYSTEM = $script:SavedGitNoSystem
}

Describe 'risk-log.ps1' {

  Context 'Register a risk on a new page' {

    It 'The first risk creates the register as RISK-001' {
      $root = New-TestRepo 'first'
      $change = Write-Change $root ([ordered]@{ verb = 'add'; fields = [ordered]@{ name = 'Sponsor changes mid-engagement'; owner = 'Allan Borup'; impact = 4; probability = 3 }; language = 'en' })
      $r = Invoke-RiskLog $root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm')
      $r.Code | Should -Be 0 -Because $r.Output
      $page = Read-Page $root
      $today = Get-Today
      $page | Should -Match '<html lang="en"'
      $page | Should -Match "data-updated=""$today"""
      $articles = [regex]::Matches($page, '(?s)<article class="risk"[^>]*>.*?</article>')
      $articles.Count | Should -Be 1
      $a = $articles[0].Value
      $a | Should -Match 'id="RISK-001"'
      $a | Should -Match 'data-state="Active"'
      $a | Should -Match '<span class="risk-name">Sponsor changes mid-engagement</span>.*<span class="sc">score 12</span>'
      $a | Should -Match "data-created=""$today"""
      $a | Should -Match "data-changed=""$today"""
      $riskLines = [regex]::Matches($a, '<li data-date="([^"]*)" data-by="([^"]*)" data-kind="([^"]*)"')
      $riskLines.Count | Should -Be 1
      $riskLines[0].Groups[1].Value | Should -Be $today
      $riskLines[0].Groups[2].Value | Should -Be 'Maja Holm'
      $riskLines[0].Groups[3].Value | Should -Be 'created'
      $reg = [regex]::Match($page, '(?s)<ol class="register-history">(.*?)</ol>').Groups[1].Value
      $regLines = [regex]::Matches($reg, '<li data-date="([^"]*)" data-by="([^"]*)" data-kind="([^"]*)"')
      $regLines.Count | Should -Be 1
      $regLines[0].Groups[1].Value | Should -Be $today
      $regLines[0].Groups[2].Value | Should -Be 'Maja Holm'
      $regLines[0].Groups[3].Value | Should -Be 'created'
    }

    It 'A first risk that cannot be written leaves no page behind (<what>)' -ForEach @(
      @{ what = 'no owner'; fields = @{ name = 'Key developer leaves'; impact = 5; probability = 2 }; by = 'Maja Holm'; code = 1 }
      @{ what = 'every required field present'; fields = @{ name = 'Key developer leaves'; owner = 'Allan Borup'; impact = 5; probability = 2 }; by = $null; code = 3 }
    ) {
      $root = New-TestRepo ('refused-' + $code)
      $change = Write-Change $root ([ordered]@{ verb = 'add'; fields = $fields; language = 'en' })
      $arguments = @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change)
      if ($by) { $arguments += @('-By', $by) }
      $r = Invoke-RiskLog $root $arguments
      $r.Code | Should -Be $code -Because $r.Output
      $r.Output.Trim() | Should -Not -BeNullOrEmpty
      Test-Path (Join-Path $root 'project/risk-log.html') | Should -BeFalse
      Test-Path (Join-Path $root 'project/risk-log.html.new') | Should -BeFalse
    }

    It 'Optional fields left out are not shown' {
      $root = New-TestRepo 'optional'
      $change = Write-Change $root ([ordered]@{ verb = 'add'; fields = [ordered]@{ name = 'Test environment arrives late'; owner = 'Jonas Berg'; impact = 3; probability = 4 }; language = 'en' })
      $r = Invoke-RiskLog $root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm')
      $r.Code | Should -Be 0 -Because $r.Output
      $a = [regex]::Match((Read-Page $root), '(?s)<article class="risk"[^>]*>.*?</article>').Value
      $a | Should -Not -Match 'class="risk-desc"'
      $a | Should -Not -Match 'class="risk-mitigation"'
      $a | Should -Match 'data-area=""'
    }

    It 'The page states its scoring and carries no script' {
      $root = New-TestRepo 'scoring'
      $change = Write-Change $root ([ordered]@{ verb = 'add'; fields = [ordered]@{ name = 'Pricing changes'; owner = 'Jonas Berg'; impact = 2; probability = 3 }; language = 'en' })
      (Invoke-RiskLog $root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm')).Code | Should -Be 0
      $page = Read-Page $root
      $page | Should -Not -Match '(?i)<script'
      $page | Should -Match '<link rel="stylesheet" href="\.\./documentation/_chrome\.css">'
      $page | Should -Match '(?s)<tr><td>Impact</td><td>[^<]+</td><td>[^<]+</td></tr>'
      $page | Should -Match '(?s)<tr><td>Probability</td><td>[^<]+</td><td>[^<]+</td></tr>'
      $page | Should -Match '<tr><th></th><th>1</th><th>5</th></tr>'
      $page | Should -Match 'The score ranks risks against each other\. It does not tell you what to do\.'
      $page | Should -Not -Match '\{\{'
    }

    It 'Names outside ASCII are written intact on both shell editions (<shell>)' -Tag 'review-focus' -ForEach @(
      @{ shell = 'pwsh' }
      @{ shell = 'powershell' }
    ) {
      $ae = [string][char]0x00E6; $oe = [string][char]0x00F8; $aa = [string][char]0x00E5
      $name = 'L' + $ae + 'kage i k' + $oe + 'l' + $aa + 'gen'
      $owner = 'S' + $oe + 'ren Fr' + $ae + 'k ' + $aa + 'sen'
      $root = New-TestRepo ('ascii-' + $shell)
      $change = Write-Change $root ([ordered]@{ verb = 'add'; fields = [ordered]@{ name = $name; owner = $owner; impact = 3; probability = 3 }; language = 'da' })
      $r = Invoke-RiskLog $root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm') $shell
      $r.Code | Should -Be 0 -Because $r.Output
      $bytes = [System.IO.File]::ReadAllBytes((Join-Path $root 'project/risk-log.html'))
      ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB) | Should -BeFalse
      $page = (New-Object System.Text.UTF8Encoding($false, $true)).GetString($bytes)
      $page | Should -Match ([regex]::Escape('<span class="risk-name">' + $name + '</span>'))
      $page | Should -Match ([regex]::Escape('data-owner="' + $owner + '"'))
    }
  }

  Context 'Read, number and score risks' {

    It 'An intact register reads back in full with no problem' {
      $root = New-Register 'intact' @(
        [ordered]@{ name = 'Sponsor changes'; owner = 'Maja Holm'; impact = 4; probability = 3; area = 'Governance'; description = 'A reorganisation is announced.'; mitigation = 'Brief the deputy sponsor.' }
        [ordered]@{ name = 'Environment late'; owner = 'Jonas Berg'; impact = 3; probability = 4; area = 'Schedule' }
        [ordered]@{ name = 'Pricing changes'; owner = 'Erik Lund'; impact = 2; probability = 3 }
      )
      $before = Get-PageHash $root
      $data = Invoke-Read $root
      @($data.risks).Count | Should -Be 3
      (@($data.risks) | ForEach-Object { $_.id }) -join ',' | Should -Be 'RISK-001,RISK-002,RISK-003'
      $first = @($data.risks) | Where-Object { $_.id -eq 'RISK-001' }
      $first.state | Should -Be 'Active'
      $first.owner | Should -Be 'Maja Holm'
      $first.impact | Should -Be '4'
      $first.probability | Should -Be '3'
      $first.area | Should -Be 'Governance'
      $first.description | Should -Be 'A reorganisation is announced.'
      $first.mitigation | Should -Be 'Brief the deputy sponsor.'
      $first.created | Should -Be (Get-Today)
      $first.changed | Should -Be (Get-Today)
      @($first.history).Count | Should -Be 1
      ((@($data.areas) | Sort-Object) -join ',') | Should -Be 'Governance,Schedule'
      @($data.problems).Count | Should -Be 0
      Get-PageHash $root | Should -Be $before
    }

    It 'A new risk continues the series past resolved risks' {
      $root = New-Register 'series' (1..7 | ForEach-Object { [ordered]@{ name = "Risk $_"; owner = 'Maja Holm'; impact = 2; probability = 2 } })
      $html = Read-Page $root
      $html = Set-RiskAttr $html 'RISK-004' 'data-state' 'Resolved'
      $html = Set-RiskAttr $html 'RISK-007' 'data-state' 'Resolved'
      Set-PageText $root $html
      $before = Invoke-Read $root
      $r = Add-Risk $root ([ordered]@{ name = 'Risk 8'; owner = 'Jonas Berg'; impact = 3; probability = 3 })
      $r.Code | Should -Be 0 -Because $r.Output
      $after = Invoke-Read $root
      (@($after.risks) | ForEach-Object { $_.id } | Sort-Object) -join ',' | Should -Be 'RISK-001,RISK-002,RISK-003,RISK-004,RISK-005,RISK-006,RISK-007,RISK-008'
      (@($after.risks) | Where-Object { $_.id -eq 'RISK-008' }).name | Should -Be 'Risk 8'
      foreach ($old in @($before.risks)) {
        $now = @($after.risks) | Where-Object { $_.id -eq $old.id }
        $now.state | Should -Be $old.state
        @($now.history).Count | Should -Be @($old.history).Count
      }
      @($after.history).Count | Should -Be (@($before.history).Count + 1)
    }

    It 'A duplicate identifier is renumbered before the write''s own change (<created>)' -ForEach @(
      @{ created = 'on two different days'; which = 'later-created' }
      @{ created = 'on the same day'; which = 'lower one on the page' }
    ) {
      $root = New-Register ('dup-' + $which.Replace(' ', '-')) @(
        [ordered]@{ name = 'Upper seven'; owner = 'Maja Holm'; impact = 2; probability = 2 }
        [ordered]@{ name = 'Lower seven'; owner = 'Maja Holm'; impact = 2; probability = 2 }
        [ordered]@{ name = 'The eight'; owner = 'Maja Holm'; impact = 2; probability = 2 }
      )
      $html = (Read-Page $root).Replace('RISK-001', 'RISK-007').Replace('RISK-002', 'RISK-007').Replace('RISK-003', 'RISK-008')
      if ($created -eq 'on two different days') {
        # the upper one on the page is the later-created, so the rule, not the page order, decides
        $html = Set-RiskAttr $html 'RISK-007' 'data-created' '2026-01-02' 0
        $html = Set-RiskAttr $html 'RISK-007' 'data-created' '2026-01-01' 1
        $expected = 'Upper seven'
      } else { $expected = 'Lower seven' }
      Set-PageText $root $html
      $r = Add-Risk $root ([ordered]@{ name = 'Brand new'; owner = 'Jonas Berg'; impact = 3; probability = 3 })
      $r.Code | Should -Be 0 -Because $r.Output
      $data = Invoke-Read $root
      $nine = @($data.risks) | Where-Object { $_.id -eq 'RISK-009' }
      $nine.name | Should -Be $expected
      $last = @($nine.history)[-1]
      $last.kind | Should -Be 'renumber'
      $last.text | Should -Be 'Renumbered from RISK-007'
      @($nine.history).Count | Should -Be 2
      @(@($data.risks) | Where-Object { $_.id -eq 'RISK-007' }).Count | Should -Be 1
      (@($data.risks) | Where-Object { $_.id -eq 'RISK-007' }).name | Should -Not -Be $expected
      (@($data.risks) | Where-Object { $_.id -eq 'RISK-008' }).name | Should -Be 'The eight'
      (@($data.risks) | Where-Object { $_.id -eq 'RISK-010' }).name | Should -Be 'Brand new'
    }

    It 'The score shown is recomputed and never given' {
      $root = New-Register 'score' @(
        [ordered]@{ name = 'Small one'; owner = 'Maja Holm'; impact = 2; probability = 2 }
        [ordered]@{ name = 'Big one'; owner = 'Maja Holm'; impact = 4; probability = 3 }
      )
      $html = Read-Page $root
      $art = [regex]::Match($html, '(?s)<article class="risk" id="RISK-002".*?</article>')
      $edited = $art.Value.Replace('<span class="sc">score 12</span>', '<span class="sc">score 15</span>')
      $html = $html.Substring(0, $art.Index) + $edited + $html.Substring($art.Index + $art.Length)
      $html = $html.Replace('<td class="num score">12</td>', '<td class="num score">15</td>')
      Set-PageText $root $html
      (Add-Risk $root ([ordered]@{ name = 'Third'; owner = 'Jonas Berg'; impact = 1; probability = 1 })).Code | Should -Be 0
      $page = Read-Page $root
      [regex]::Match($page, '(?s)<article class="risk" id="RISK-002".*?</article>').Value | Should -Match '<span class="sc">score 12</span>'
      $page | Should -Not -Match '<span class="sc">score 15</span>'
      $before = Get-PageHash $root
      $r = Add-Risk $root ([ordered]@{ name = 'Scored by hand'; owner = 'Jonas Berg'; impact = 3; probability = 5; score = 15 })
      $r.Code | Should -Be 1 -Because $r.Output
      Get-PageHash $root | Should -Be $before
    }

    It 'Areas nearly the same are found (<inUse> / <given>)' -ForEach @(
      @{ inUse = 'Schedule'; given = 'schedule'; near = $true }
      @{ inUse = 'Schedule'; given = 'sched-ule'; near = $true }
      @{ inUse = 'Schedule'; given = 'Schedul'; near = $true }
      @{ inUse = 'Cost'; given = 'Costs'; near = $true }
      @{ inUse = 'Customer schedule'; given = 'Customer schedules'; near = $true }
      @{ inUse = 'QA'; given = 'QC'; near = $false }
      @{ inUse = 'Supplier schedule'; given = 'Customer schedule'; near = $false }
    ) {
      $root = New-Register ('area-' + [guid]::NewGuid().ToString('n').Substring(0, 8)) @(
        [ordered]@{ name = 'One risk'; owner = 'Maja Holm'; impact = 2; probability = 2; area = $inUse }
      )
      $data = Invoke-Read $root @('-Area', $given)
      (@($data.nearly) -contains $inUse) | Should -Be $near
    }

    It 'A register with CRLF line endings reads and writes as normal' -Tag 'review-focus' {
      $root = New-Register 'crlf' @(
        [ordered]@{ name = 'Sponsor changes'; owner = 'Maja Holm'; impact = 4; probability = 3; description = 'First line.' }
      )
      Set-PageText $root ((Read-Page $root) -replace "`r?`n", "`r`n")
      (Read-Page $root) | Should -Match "`r`n"
      $data = Invoke-Read $root
      @($data.problems).Count | Should -Be 0
      $r = Add-Risk $root ([ordered]@{ name = 'Second'; owner = 'Jonas Berg'; impact = 2; probability = 2 })
      $r.Code | Should -Be 0 -Because $r.Output
      @((Invoke-Read $root).risks).Count | Should -Be 2
    }
  }

  Context 'Change a risk''s fields' {

    BeforeAll {
      function Invoke-Change([string]$Root, [string]$Target, $Fields) {
        $change = Write-Change $Root ([ordered]@{ verb = 'change'; target = $Target; fields = $Fields })
        return Invoke-RiskLog $Root @('-Path', 'project/risk-log.html', '-Apply', '-Change', $change, '-By', 'Maja Holm')
      }    }

    It 'A changed field moves the changed date and keeps the created date' {
      $root = New-Register 'change-one' (1..3 | ForEach-Object { [ordered]@{ name = "Risk $_"; owner = 'Jonas Berg'; impact = 3; probability = 2 } })
      $html = Read-Page $root
      $html = Set-RiskAttr $html 'RISK-003' 'data-created' '2026-01-05'
      $html = Set-RiskAttr $html 'RISK-003' 'data-changed' '2026-01-05'
      Set-PageText $root $html
      $r = Invoke-Change $root 'RISK-003' ([ordered]@{ impact = 4 })
      $r.Code | Should -Be 0 -Because $r.Output
      $data = Invoke-Read $root
      $risk = @($data.risks) | Where-Object { $_.id -eq 'RISK-003' }
      $risk.impact | Should -Be '4'
      $risk.state | Should -Be 'Active'
      $risk.created | Should -Be '2026-01-05'
      $risk.changed | Should -Be (Get-Today)
      $last = @($risk.history)[-1]
      $last.kind | Should -Be 'change'
      $last.date | Should -Be (Get-Today)
      $last.by | Should -Be 'Maja Holm'
      $last.text | Should -Match ('Impact 3 ' + ([string][char]0x2192) + ' 4')
      $data.updated | Should -Be (Get-Today)
      @($data.history)[0].kind | Should -Be 'write'
      @($data.history)[0].by | Should -Be 'Maja Holm'
    }

    It 'Several fields changed at once give one history line' {
      $root = New-Register 'change-several' (1..3 | ForEach-Object { [ordered]@{ name = "Risk $_"; owner = 'Jonas Berg'; impact = 3; probability = 2; area = 'Schedule' } })
      $before = @((@((Invoke-Read $root).risks) | Where-Object { $_.id -eq 'RISK-003' }).history).Count
      $r = Invoke-Change $root 'RISK-003' ([ordered]@{ owner = 'Sara Nygaard'; area = 'Resources' })
      $r.Code | Should -Be 0 -Because $r.Output
      $risk = @((Invoke-Read $root).risks) | Where-Object { $_.id -eq 'RISK-003' }
      @($risk.history).Count | Should -Be ($before + 1)
      $last = @($risk.history)[-1]
      $last.text | Should -Match ('Owner Jonas Berg ' + ([string][char]0x2192) + ' Sara Nygaard')
      $last.text | Should -Match ('Area Schedule ' + ([string][char]0x2192) + ' Resources')
      $risk.owner | Should -Be 'Sara Nygaard'
      $risk.area | Should -Be 'Resources'
    }

    It 'A resolved risk can be renamed and stays resolved' {
      $root = New-Register 'change-resolved' (1..6 | ForEach-Object { [ordered]@{ name = "Risk $_"; owner = 'Jonas Berg'; impact = 2; probability = 2 } })
      Set-PageText $root (Set-RiskAttr (Read-Page $root) 'RISK-006' 'data-state' 'Resolved')
      $r = Invoke-Change $root 'RISK-006' ([ordered]@{ name = 'Migration window, renamed' })
      $r.Code | Should -Be 0 -Because $r.Output
      $risk = @((Invoke-Read $root).risks) | Where-Object { $_.id -eq 'RISK-006' }
      $risk.name | Should -Be 'Migration window, renamed'
      $risk.state | Should -Be 'Resolved'
      @($risk.history).Count | Should -Be 2
      @($risk.history)[-1].kind | Should -Be 'change'
    }

    It 'An identifier that does not exist writes nothing' {
      $root = New-Register 'change-unknown' (1..2 | ForEach-Object { [ordered]@{ name = "Risk $_"; owner = 'Jonas Berg'; impact = 2; probability = 2 } })
      $before = Get-PageHash $root
      $r = Invoke-Change $root 'RISK-099' ([ordered]@{ impact = 4 })
      $r.Code | Should -Be 1 -Because $r.Output
      $r.Output | Should -Match 'RISK-099'
      Get-PageHash $root | Should -Be $before
      Test-Path (Join-Path $root 'project/risk-log.html.new') | Should -BeFalse
    }
  }
}
