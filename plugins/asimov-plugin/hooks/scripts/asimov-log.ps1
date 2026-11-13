<#
.SYNOPSIS
  The Asimov run log's writer: one text line per harness event, appended by a hook.

.DESCRIPTION
  Fired by hooks/hooks.json on five harness events (SessionStart, the invocation of an asimov-*
  skill, SubagentStart, SubagentStop, SessionEnd). Reads the event's JSON from stdin and appends
  one line to .asimov/log/<YYYY-MM-DD>-<id8>.log under the repo root the payload names, in the
  shape artifacts/dot-asimov/asimov-log/asimov-log-definition.md fixes:

      YYYY-MM-DD HH:MM  <stage>  <feature>  <who>  <sentence>

  Its own memory is .asimov/state/<id8>.state (stage, feature, log file name, one line per running
  agent), deleted at session end; a state file a session end could not delete (the harness gives
  SessionEnd hooks 1.5 s) is swept by the next SessionStart once it is over twelve hours old.
  Hooks run in parallel, so the read-modify-write of the state file holds a named mutex per
  session. Only an asimov-* invocation creates the folder, and with it .asimov/.gitignore holding
  '*' so git never lists it whatever the repo's own .gitignore says; every other event writes a line
  only where the folder exists, so a repo Asimov never ran in gets no folder. It prints nothing,
  always exits 0, and writes nothing outside .asimov/. No skill and no model calls it: the harness does.

  Set ASIMOV_LOG_RAW=1 in the environment to also append every payload, verbatim, to
  .asimov/raw/<id8>.jsonl before any filter, where .asimov/log/ already exists: the way to read
  what a harness hands over (D101-asimov-log Q1, Q2).
  Off by default, since a raw payload carries prompt text the log never may.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose.
#>

$ErrorActionPreference = 'Stop'

function Read-Payload {
  try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null, $null }
    return ($raw | ConvertFrom-Json), $raw
  } catch { return $null, $null }
}

function Get-Field($obj, [string]$name) {
  if ($null -eq $obj) { return $null }
  $p = $obj.PSObject.Properties[$name]
  if ($null -eq $p) { return $null }
  return $p.Value
}

function Write-Retry([string]$path, [string]$text, [bool]$append) {
  $enc = New-Object System.Text.UTF8Encoding $false
  for ($i = 0; $i -lt 5; $i++) {
    try {
      if ($append) { [System.IO.File]::AppendAllText($path, $text, $enc) }
      else         { [System.IO.File]::WriteAllText($path, $text, $enc) }
      return
    } catch { Start-Sleep -Milliseconds 40 }
  }
}

function Read-State([string]$path) {
  $s = @{ stage = 'session'; feature = '-'; file = ''; agents = @(); lastSkill = '' }
  if (-not (Test-Path -LiteralPath $path)) { return $s }
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^stage=(.*)$')   { $s.stage = $Matches[1]; continue }
    if ($line -match '^feature=(.*)$') { $s.feature = $Matches[1]; continue }
    if ($line -match '^file=(.*)$')    { $s.file = $Matches[1]; continue }
    if ($line -match '^skill=(.*)$')   { $s.lastSkill = $Matches[1]; continue }
    if ($line -match '^agent=(.*)$')   { $s.agents += $Matches[1]; continue }
  }
  return $s
}

function Write-State([string]$path, $s) {
  $lines = @("stage=$($s.stage)", "feature=$($s.feature)", "file=$($s.file)", "skill=$($s.lastSkill)")
  foreach ($a in $s.agents) { $lines += "agent=$a" }
  Write-Retry $path (($lines -join "`n") + "`n") $false
}

function Get-Stage([string]$skill) {
  switch -Regex ($skill) {
    '^asimov-init$'             { return 'init' }
    '^asimov-design(-review)?$' { return 'design' }
    '^asimov-spec$'             { return 'spec' }
    '^asimov-build$'            { return 'build' }
  }
  return $null
}

function Get-Harness {
  if ($env:CLAUDECODE) { return 'claude-code' }
  # Codex (verified 2026-11-12, desktop app on Windows) sets CODEX_SHELL, CODEX_APP_RUNTIME_CLI_PATH and PLUGIN_ROOT, no CODEX_HOME.
  if ($env:CODEX_SHELL -or $env:CODEX_HOME -or $env:CODEX_SANDBOX -or $env:CODEX_APP_RUNTIME_CLI_PATH -or ($env:PLUGIN_ROOT -and -not $env:CLAUDE_PROJECT_DIR)) { return 'codex' }
  if ($env:CLAUDE_PLUGIN_ROOT) { return 'claude-code' }
  return 'unknown'
}

function Format-Line([string]$stage, [string]$feature, [string]$who, [string]$sentence) {
  $t = Get-Date -Format 'yyyy-MM-dd HH:mm'
  return ('{0}  {1}  {2}  {3}  {4}' -f $t, $stage.PadRight(7), $feature.PadRight(9), $who.PadRight(8), $sentence) + "`n"
}

function Remove-StaleState([string]$dir, [string]$keep) {
  try {
    $limit = (Get-Date).AddHours(-12)
    foreach ($f in Get-ChildItem -LiteralPath $dir -Filter '*.state' -Force -File -ErrorAction SilentlyContinue) {
      if ($f.Name -ne $keep -and $f.LastWriteTime -lt $limit) { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue }
    }
  } catch { }
}

function Invoke-Log {
  $mutex = $null
  try {
  $payload, $raw = Read-Payload
  if ($null -eq $payload) { return }

  $event = [string](Get-Field $payload 'hook_event_name')
  $root = [string](Get-Field $payload 'cwd')
  if (-not $root) { $root = $env:CLAUDE_PROJECT_DIR }
  if (-not $root) { return }
  $sid = [string](Get-Field $payload 'session_id')
  if (-not $sid) { $sid = 'nosession' }
  $id8 = $sid.Substring(0, [Math]::Min(8, $sid.Length))

  $dir = Join-Path $root '.asimov/log'
  $stateDir = Join-Path $root '.asimov/state'   # the hook's memory; log/ holds only what a person reads
  $statePath = Join-Path $stateDir "$id8.state"
  $rawDir = Join-Path $root '.asimov/raw'

  # The raw dump, before any filter: every payload the harness hands over, where the folder already exists (Q1, Q2).
  if ($env:ASIMOV_LOG_RAW -eq '1' -and (Test-Path -LiteralPath $dir)) { if (-not (Test-Path -LiteralPath $rawDir)) { New-Item -ItemType Directory -Path $rawDir -Force | Out-Null }; Write-Retry (Join-Path $rawDir "$id8.jsonl") (($raw -replace "`r?`n", ' ') + "`n") $true }

  # Only an asimov-* invocation creates the folder; every other event logs only where it already exists.
  if ($event -ne 'PreToolUse' -and $event -ne 'UserPromptExpansion' -and -not (Test-Path -LiteralPath $dir)) { return }

  # One writer at a time per session: hooks run in parallel and the state is read, changed, written.
  try {
    $mutex = New-Object System.Threading.Mutex($false, "asimov-log-$id8")
    if (-not $mutex.WaitOne(3000)) { $mutex.Dispose(); $mutex = $null }
  } catch { $mutex = $null }

  $state = Read-State $statePath
  if (-not $state.file) { $state.file = (Get-Date -Format 'yyyy-MM-dd') + "-$id8.log" }
  $line = $null
  $saveState = $true

  switch ($event) {
    'SessionStart' {
      $source = [string](Get-Field $payload 'source')
      $h = Get-Harness
      $what = if ($source -and $source -ne 'startup') { "started ($h, $source)" } else { "started ($h)" }
      $line = Format-Line $state.stage $state.feature 'session' $what
    }
    { $_ -eq 'PreToolUse' -or $_ -eq 'UserPromptExpansion' } {
      $skill = $null; $argText = $null
      if ($event -eq 'PreToolUse') {
        $tool = [string](Get-Field $payload 'tool_name')
        $ti = Get-Field $payload 'tool_input'
        if ($tool -eq 'Skill') {
          foreach ($k in 'skill', 'name', 'skill_name', 'command') { if (-not $skill) { $skill = [string](Get-Field $ti $k) } }
          foreach ($k in 'args', 'arguments', 'input') { if ($null -eq $argText) { $argText = Get-Field $ti $k } }
        } else {
          # Codex has no Skill tool (verified 2026-11-13): the model starts a skill by reading its SKILL.md,
          # with Bash or a file-read tool. The first read of skills/asimov-<x>/SKILL.md is the invocation; the
          # words that started it never reach this hook, so the line carries no argument.
          $text = ''
          foreach ($k in 'command', 'file_path', 'path', 'filePath') { $v = [string](Get-Field $ti $k); if ($v) { $text += ' ' + $v } }
          if ($text -notmatch 'skills[\\/](asimov-[a-z-]+)[\\/]SKILL\.md') { return }
          $skill = $Matches[1]
          if ($state.stage -eq (Get-Stage $skill) -and $state.lastSkill -eq $skill) { return }   # one line per start, not per re-read
          $state.lastSkill = $skill
          $argText = ''
        }
      } else {
        foreach ($k in 'command_name', 'skill_name', 'skill', 'name', 'command') { if (-not $skill) { $skill = [string](Get-Field $payload $k) } }
        foreach ($k in 'command_args', 'args', 'arguments', 'prompt') { if ($null -eq $argText) { $argText = Get-Field $payload $k } }
      }
      if (-not $skill) { return }
      $skill = ($skill -replace '^.*:', '') -replace '^/', ''
      $stage = Get-Stage $skill
      if (-not $stage) { return }
      if ($argText -is [System.Array]) { $argText = ($argText -join ' ') }
      $argText = [string]$argText
      if ($event -eq 'UserPromptExpansion' -and $argText -match "^\s*/$([regex]::Escape($skill))\b(.*)$") { $argText = $Matches[1] }
      $tokens = @($argText -split '\s+' | Where-Object { $_ })
      $state.stage = $stage
      if ($tokens.Count -eq 0)     { $word = '-' }
      elseif ($tokens.Count -eq 1) { $word = $tokens[0]; $state.feature = $word }
      else                         { $word = "(text, $($argText.Trim().Length) chars)" }
      $line = Format-Line $state.stage $state.feature 'skill' "$skill invoked: $word"
    }
    'SubagentStart' {
      $shell = ([string](Get-Field $payload 'agent_type')) -replace '^.*:', ''
      if (-not $shell) { $shell = 'agent' }
      $aid = [string](Get-Field $payload 'agent_id')
      $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
      if ($aid) { $state.agents = @($state.agents | Where-Object { $_ -notlike "$aid|*" }) + "$aid|$now|$shell" }
      $line = Format-Line $state.stage $state.feature $shell 'started'
    }
    'SubagentStop' {
      $shell = ([string](Get-Field $payload 'agent_type')) -replace '^.*:', ''
      $aid = [string](Get-Field $payload 'agent_id')
      $what = 'stopped'
      $hit = $null
      if ($aid) { $hit = $state.agents | Where-Object { $_ -like "$aid|*" } | Select-Object -First 1 }
      if ($hit) {
        $parts = $hit -split '\|', 3
        $secs = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() - [int64]$parts[1]
        if (-not $shell) { $shell = $parts[2] }
        $what = "stopped after $secs s"
        $state.agents = @($state.agents | Where-Object { $_ -ne $hit })
      }
      if (-not $shell) { $shell = 'agent' }
      $line = Format-Line $state.stage $state.feature $shell $what
    }
    'SessionEnd' {
      $reason = [string](Get-Field $payload 'reason')
      if (-not $reason) { $reason = 'unknown' }
      $line = Format-Line $state.stage $state.feature 'session' "ended ($reason)"
      $saveState = $false
    }
    default { return }
  }

  if (-not $line) { return }
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $selfIgnore = Join-Path (Split-Path -Parent $dir) '.gitignore'
  if (-not (Test-Path -LiteralPath $selfIgnore)) { Write-Retry $selfIgnore "*`n" $false }
  Write-Retry (Join-Path $dir $state.file) $line $true
  if ($saveState) { if (-not (Test-Path -LiteralPath $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }; Write-State $statePath $state }
  elseif (Test-Path -LiteralPath $statePath) { Remove-Item -LiteralPath $statePath -Force -ErrorAction SilentlyContinue }
  if ($event -eq 'SessionStart') { Remove-StaleState $stateDir "$id8.state" }
  } catch { }
  finally {
    if ($mutex) { try { $mutex.ReleaseMutex() } catch { }; $mutex.Dispose() }
  }
}

Invoke-Log
exit 0
