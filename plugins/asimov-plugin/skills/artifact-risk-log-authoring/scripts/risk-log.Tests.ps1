# Pester 5 tests for risk-log.ps1. Every slice of the risk-log plan adds its tests here, before
# the script code that makes them pass. Run on PowerShell 7 and on Windows PowerShell 5.1:
#   Invoke-Pester -Path plugins/asimov-plugin/skills/artifact-risk-log-authoring/scripts/risk-log.Tests.ps1

BeforeAll {
  $script:RiskLog = Join-Path $PSScriptRoot 'risk-log.ps1'
}

Describe 'risk-log.ps1' {
}
