<#
.SYNOPSIS
  The Windows side of run-hook.cmd for Codex, whose Windows hook shell is PowerShell.

.DESCRIPTION
  Usage, from hooks-codex.json commandWindows:
    powershell -NoProfile -ExecutionPolicy Bypass -File "<plugin>/hooks/run-hook.ps1" <script-name>
  A hook command line of the form "<path>" <arg> is a syntax error in PowerShell, so Codex on
  Windows gets this launcher instead: it reads the hook payload from stdin, hands it to
  run-hook.cmd (cmd finds Git Bash and runs the named script), and prints what the script
  printed. No bash found → the shim exits 0 silently and nothing is injected. Always exits 0.
  Windows PowerShell 5.1 and PowerShell 7 alike.
#>
param([Parameter(Mandatory = $true)][string]$Script)
$ErrorActionPreference = 'Continue'

$payload = ''
try { $payload = [Console]::In.ReadToEnd() } catch { }

$cmdPath = Join-Path $PSScriptRoot 'run-hook.cmd'
$out = @()
try { $out = @($payload | & cmd.exe /d /c "`"$cmdPath`" $Script" 2>$null) } catch { }

$stdout = ($out | Where-Object { $_ -is [string] }) -join "`n"
if ($stdout) { [Console]::Out.Write($stdout) }
exit 0
