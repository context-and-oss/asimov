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

  function Get-Today { (Get-Date).ToString('yyyy-MM-dd') }
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
}
