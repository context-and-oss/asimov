<#
.SYNOPSIS
  The Asimov run log's writer: one text line per harness event, appended by a hook.

.DESCRIPTION
  Fired by hooks/hooks.json (Claude Code) and hooks/hooks-codex.json (Codex) on the harness events
  (SessionStart, the invocation of an asimov-* skill, the tool calls that spawn or message an agent,
  SubagentStart, SubagentStop, SessionEnd). Reads the event's JSON from stdin and appends one line to
  .asimov/log/<YYYY-MM-DD>-<id8>.log under the repo root the payload names, in the shape
  artifacts/dot-asimov/asimov-log/asimov-log-definition.md fixes:

      YYYY-MM-DD HH:MM  <stage>  <feature>  <who>  <sentence>

  <id8> is the LAST eight characters of the session id: Codex ids are UUIDv7, whose first eight
  characters are a timestamp two sessions in one hour share.

  A stop line carries what the agent did: its round (an agent continued by message answers more than
  once), the seconds since it was started or last messaged, and, read from the agent's transcript
  (agent_transcript_path), its tool calls and tokens for the round and the first line of its answer.
  The transcript has two shapes: Codex's rollout (cumulative token_count events, one function_call
  row per tool call) and Claude Code's (usage on every assistant line, repeated per content block of
  one message, so it is counted once per message id).

  Its own memory is .asimov/state/<id8>.state (stage, feature, log file name, a pending spawn, one line
  per agent seen with its counters), deleted at session end; a state file a session end could not
  delete (the harness gives SessionEnd hooks 1.5 s) is swept by the next SessionStart once it is over
  twelve hours old. Hooks run in parallel, so the read-modify-write of the state file holds a named
  mutex per session. Only an asimov-* invocation creates the folder, and with it .asimov/.gitignore
  holding '*' so git never lists it whatever the repo's own .gitignore says; every other event writes
  a line only where the folder exists, so a repo Asimov never ran in gets no folder. It prints
  nothing, always exits 0, and writes nothing outside .asimov/. No skill and no model calls it: the
  harness does.

  Set ASIMOV_LOG_RAW=1 in the environment to also append every payload, verbatim, to
  .asimov/raw/<id8>.jsonl before any filter, where .asimov/log/ already exists: the way to read
  what a harness hands over (D101-asimov-log Q1, Q2).
  Off by default, since a raw payload carries prompt text the log never may.

  Written for Windows PowerShell 5.1 and PowerShell 7 alike; pure ASCII on purpose.
#>

$ErrorActionPreference = 'Stop'

function Read-Payload {
  # The payload is UTF-8 bytes; [Console]::In would decode them in the console's code page and turn every
  # non-ASCII character of an agent's answer into mojibake, so the bytes are read and decoded here.
  try {
    $in = [Console]::OpenStandardInput()
    $ms = New-Object System.IO.MemoryStream
    $in.CopyTo($ms)
    $raw = (New-Object System.Text.UTF8Encoding $false).GetString($ms.ToArray())
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

function Get-SessionKey([string]$sid) {
  if (-not $sid) { return 'nosession' }
  if ($sid.Length -le 8) { return $sid }
  return $sid.Substring($sid.Length - 8)
}

# --- state ---------------------------------------------------------------------------------------
# agent=<id>|<shell>|<start>|<last>|<round>|<tokens>|<cached>|<out>|<calls>   (unix seconds; cumulative counters)
# pending=<name>|<model>|<effort>|<fork>|<ts>                                  (a spawn seen, its start not yet)

function New-Agent([string]$id, [string]$shell, [int64]$now) {
  return @{ id = $id; shell = $shell; start = $now; last = $now; round = 0; tokens = 0; cached = 0; out = 0; calls = 0 }
}

function Read-State([string]$path) {
  $s = @{ stage = 'session'; feature = '-'; file = ''; agents = @(); lastSkill = ''; pending = '' }
  if (-not (Test-Path -LiteralPath $path)) { return $s }
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^stage=(.*)$')   { $s.stage = $Matches[1]; continue }
    if ($line -match '^feature=(.*)$') { $s.feature = $Matches[1]; continue }
    if ($line -match '^file=(.*)$')    { $s.file = $Matches[1]; continue }
    if ($line -match '^skill=(.*)$')   { $s.lastSkill = $Matches[1]; continue }
    if ($line -match '^pending=(.*)$') { $s.pending = $Matches[1]; continue }
    if ($line -match '^agent=(.*)$') {
      $p = $Matches[1] -split '\|'
      if ($p.Count -lt 9) { continue }
      $a = New-Agent $p[0] $p[1] ([int64]$p[2])
      $a.last = [int64]$p[3]; $a.round = [int]$p[4]; $a.tokens = [int64]$p[5]; $a.cached = [int64]$p[6]; $a.out = [int64]$p[7]; $a.calls = [int64]$p[8]
      $s.agents += $a
    }
  }
  return $s
}

function Write-State([string]$path, $s) {
  $lines = @("stage=$($s.stage)", "feature=$($s.feature)", "file=$($s.file)", "skill=$($s.lastSkill)", "pending=$($s.pending)")
  foreach ($a in $s.agents) { $lines += "agent=$($a.id)|$($a.shell)|$($a.start)|$($a.last)|$($a.round)|$($a.tokens)|$($a.cached)|$($a.out)|$($a.calls)" }
  Write-Retry $path (($lines -join "`n") + "`n") $false
}

function Find-Agent($s, [string]$id) {
  if (-not $id) { return $null }
  foreach ($a in $s.agents) { if ($a.id -eq $id) { return $a } }
  return $null
}

function Find-AgentByShell($s, [string]$shell) {
  if (-not $shell) { return $null }
  $hit = $null
  foreach ($a in $s.agents) { if ($a.shell -eq $shell) { $hit = $a } }   # the latest of that name
  return $hit
}

# --- small helpers -------------------------------------------------------------------------------

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
  return ('{0}  {1}  {2}  {3}  {4}' -f $t, $stage.PadRight(7), $feature.PadRight(12), $who.PadRight(16), $sentence) + "`n"
}

function Format-Count([int64]$n) {
  $inv = [System.Globalization.CultureInfo]::InvariantCulture   # a decimal point whatever the machine's culture
  if ($n -lt 1000) { return "$n" }
  if ($n -lt 10000) { return ($n / 1000.0).ToString('0.0', $inv) + 'k' }
  if ($n -lt 1000000) { return ($n / 1000.0).ToString('0', $inv) + 'k' }
  if ($n -lt 10000000) { return ($n / 1000000.0).ToString('0.0', $inv) + 'M' }
  return ($n / 1000000.0).ToString('0', $inv) + 'M'
}

function Get-Slug([string]$text) {
  # a persona or role name from the text of a spawn message: "You are Giskard, the .NET builder" -> giskard;
  # "Act as the S101 plan writer for ..." -> s101-plan-writer. Nothing else of the message is read.
  if (-not $text) { return '' }
  if ($text -match '(?:You are|Act as)\s+(?:the\s+|a\s+|an\s+)?([A-Za-z][A-Za-z0-9 .-]{0,40}?)(?=[,.:;!\r\n]| for | of | in | on | who | that |$)') {
    $name = $Matches[1].Trim().ToLowerInvariant() -replace '[.]', ''
    $name = ($name -replace '\s+', '-').Trim('-')
    if ($name) { return $name }
  }
  return ''
}

function Get-Headline([string]$text) {
  if (-not $text) { return '' }
  foreach ($l in ($text -split "`r?`n")) {
    $h = $l -replace '^[\s#>*-]+', '' -replace '`', '' -replace '\*\*', ''
    $h = ($h -replace '\s+', ' ').Trim()
    if (-not $h) { continue }
    if ($h.Length -gt 80) { $h = $h.Substring(0, 79) + '...' }
    return $h
  }
  return ''
}

function Get-FeatureFromText([string]$text) {
  # the feature slug a tool input names: specs/<slug>/ or D101-<slug>; the first found. No other word of the input is read.
  if (-not $text) { return '' }
  if ($text -cmatch 'specs[\\/]+([a-z0-9][a-z0-9-]*)[\\/]') { return $Matches[1] }
  if ($text -cmatch 'plans[\\/]+([a-z0-9][a-z0-9-]*)\.(?:design\.|review\.)?md') { return $Matches[1] }
  if ($text -cmatch 'D101-([a-z0-9][a-z0-9-]*)\.(html|md)') { return $Matches[1] }   # a design file, never the d101-* artifact folder
  return ''
}

# --- the transcript --------------------------------------------------------------------------------

function Get-TranscriptStats([string]$path) {
  # Cumulative tokens, tool calls and the last answer's text of one transcript. Two shapes:
  #   Codex rollout: event_msg/token_count rows carry total_token_usage (cumulative); response_item/function_call, custom_tool_call, local_shell_call and web_search_call are tool calls;
  #                  response_item/message with role assistant is an answer.
  #   Claude Code:   type=assistant rows carry message.usage, repeated for every content block of one message id;
  #                  a tool_use block is a tool call; a text block is an answer.
  $r = @{ ok = $false; tokens = 0; cached = 0; out = 0; calls = 0; headline = '' }
  try {
    if (-not $path -or -not (Test-Path -LiteralPath $path)) { return $r }
    if ((Get-Item -LiteralPath $path).Length -gt 40MB) { return $r }   # the budget is seconds; a transcript this size is not read
    $codex = $false; $lastTok = ''; $lastMsg = ''; $lastId = ''
    $inp = [int64]0; $cre = [int64]0; $red = [int64]0; $out = [int64]0; $calls = [int64]0
    # The harness holds its transcript open while it writes: open with every share, as a reader that may not block a writer.
    $fs = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, ([System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete))
    $sr = New-Object System.IO.StreamReader($fs, (New-Object System.Text.UTF8Encoding $false))
    try {
      while ($null -ne ($line = $sr.ReadLine())) {
        if ($line.Contains('"type":"response_item"')) {
          # Codex rollout rows: a tool call, an answer, or neither
          $codex = $true
          if ($line.Contains('"type":"function_call"') -or $line.Contains('"type":"custom_tool_call"') -or $line.Contains('"type":"local_shell_call"') -or $line.Contains('"type":"web_search_call"')) { $calls++ }
          elseif ($line.Contains('"type":"message"') -and $line.Contains('"role":"assistant"')) { $lastMsg = $line }
          continue
        }
        if ($line.Contains('"type":"event_msg"') -and $line.Contains('"token_count"')) {
          # a token_count row may carry info: null; only a row with numbers is the cumulative count
          $codex = $true; if ($line.Contains('"total_token_usage"')) { $lastTok = $line }; continue
        }
        if ($codex) { continue }
        if (-not $line.Contains('"type":"assistant"')) { continue }
        if ($line -match '"id":"(msg_[A-Za-z0-9_-]+)"' -and $Matches[1] -ne $lastId) {
          $lastId = $Matches[1]
          if ($line -match '"usage":\{([^}]*)\}') {
            $u = $Matches[1]
            if ($u -match '"input_tokens":(\d+)')          { $inp += [int64]$Matches[1] }
            if ($u -match '"cache_creation_input_tokens":(\d+)') { $cre += [int64]$Matches[1] }
            if ($u -match '"cache_read_input_tokens":(\d+)') { $red += [int64]$Matches[1] }
            if ($u -match '"output_tokens":(\d+)')         { $out += [int64]$Matches[1] }
          }
        }
        $calls += [regex]::Matches($line, '"type":"tool_use"').Count
        if ($line.Contains('"type":"text"')) { $lastMsg = $line }
      }
    } finally { $sr.Dispose(); $fs.Dispose() }
    if ($codex) {
      if ($lastTok -match '"total_token_usage":\{([^}]*)\}') {
        $u = $Matches[1]
        if ($u -match '"total_tokens":(\d+)')        { $r.tokens = [int64]$Matches[1] }
        if ($u -match '"cached_input_tokens":(\d+)') { $r.cached = [int64]$Matches[1] }
        if ($u -match '"output_tokens":(\d+)')       { $r.out = [int64]$Matches[1] }
      }
    } else {
      $r.tokens = $inp + $cre + $red + $out; $r.cached = $red; $r.out = $out
    }
    $r.calls = $calls
    $r.ok = ($lastTok -ne '' -or $lastId -ne '')
    if ($lastMsg) {
      try {
        $o = $lastMsg | ConvertFrom-Json
        $blocks = $null
        if ($codex) { $blocks = Get-Field (Get-Field $o 'payload') 'content' } else { $blocks = Get-Field (Get-Field $o 'message') 'content' }
        if ($blocks -is [string]) { $r.headline = Get-Headline $blocks }
        else { foreach ($b in @($blocks)) { $t = [string](Get-Field $b 'text'); if ($t) { $r.headline = Get-Headline $t; if ($r.headline) { break } } } }
      } catch { }
    }
  } catch { }
  return $r
}

function Format-Usage($stats, $agent) {
  # the round's share: the transcript's cumulative counters less what the agent's record already holds
  $tok = $stats.tokens - $agent.tokens; $cac = $stats.cached - $agent.cached; $out = $stats.out - $agent.out; $cal = $stats.calls - $agent.calls
  if ($tok -lt 0) { $tok = $stats.tokens }; if ($cac -lt 0) { $cac = $stats.cached }; if ($out -lt 0) { $out = $stats.out }; if ($cal -lt 0) { $cal = $stats.calls }
  $agent.tokens = $stats.tokens; $agent.cached = $stats.cached; $agent.out = $stats.out; $agent.calls = $stats.calls
  $callWord = if ($cal -eq 1) { 'tool call' } else { 'tool calls' }
  return ('{0} {1}, {2} tokens, {3} cached, {4} out' -f $cal, $callWord, (Format-Count $tok), (Format-Count $cac), (Format-Count $out))
}

function Remove-StaleState([string]$dir, [string]$keep) {
  try {
    $limit = (Get-Date).AddHours(-12)
    foreach ($f in Get-ChildItem -LiteralPath $dir -Filter '*.state' -Force -File -ErrorAction SilentlyContinue) {
      if ($f.Name -ne $keep -and $f.LastWriteTime -lt $limit) { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue }
    }
  } catch { }
}

# --- the hook --------------------------------------------------------------------------------------

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
  $id8 = Get-SessionKey $sid

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
  $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
  $line = $null
  $saveState = $true

  switch ($event) {
    'SessionStart' {
      $source = [string](Get-Field $payload 'source')
      $h = Get-Harness
      $model = [string](Get-Field $payload 'model')
      $bits = @($h); if ($model) { $bits += $model }; if ($source -and $source -ne 'startup') { $bits += $source }
      $line = Format-Line $state.stage $state.feature 'session' ("started ({0})" -f ($bits -join ', '))
    }
    'UserPromptExpansion' {
      $skill = $null; $argText = $null
      foreach ($k in 'command_name', 'skill_name', 'skill', 'name', 'command') { if (-not $skill) { $skill = [string](Get-Field $payload $k) } }
      foreach ($k in 'command_args', 'args', 'arguments', 'prompt') { if ($null -eq $argText) { $argText = Get-Field $payload $k } }
      if (-not $skill) { return }
      $skill = ($skill -replace '^.*:', '') -replace '^/', ''
      $stage = Get-Stage $skill
      if (-not $stage) { return }
      if ($argText -is [System.Array]) { $argText = ($argText -join ' ') }
      $argText = [string]$argText
      if ($argText -match "^\s*/$([regex]::Escape($skill))\b(.*)$") { $argText = $Matches[1] }
      $tokens = @($argText -split '\s+' | Where-Object { $_ })
      $state.stage = $stage; $state.lastSkill = $skill
      if ($tokens.Count -eq 0)     { $word = '-' }
      elseif ($tokens.Count -eq 1) { $word = $tokens[0]; $state.feature = $word }
      else                         { $word = "(text, $($argText.Trim().Length) chars)" }
      $line = Format-Line $state.stage $state.feature 'skill' "$skill invoked: $word"
    }
    'PreToolUse' {
      $tool = [string](Get-Field $payload 'tool_name')
      $ti = Get-Field $payload 'tool_input'
      $tiText = ''
      try { if ($null -ne $ti) { $tiText = [string]($ti | ConvertTo-Json -Compress -Depth 8) } } catch { $tiText = '' }

      if ($tool -eq 'Skill') {
        # Claude Code: a Skill call of an asimov-* skill is the invocation; its args give the word.
        $skill = $null; $argText = $null
        foreach ($k in 'skill', 'name', 'skill_name', 'command') { if (-not $skill) { $skill = [string](Get-Field $ti $k) } }
        foreach ($k in 'args', 'arguments', 'input') { if ($null -eq $argText) { $argText = Get-Field $ti $k } }
        if (-not $skill) { return }
        $skill = ($skill -replace '^.*:', '') -replace '^/', ''
        $stage = Get-Stage $skill
        if (-not $stage) { return }
        if ($argText -is [System.Array]) { $argText = ($argText -join ' ') }
        $argText = [string]$argText
        $tokens = @($argText -split '\s+' | Where-Object { $_ })
        $state.stage = $stage; $state.lastSkill = $skill
        if ($tokens.Count -eq 0)     { $word = '-' }
        elseif ($tokens.Count -eq 1) { $word = $tokens[0]; $state.feature = $word }
        else                         { $word = "(text, $($argText.Trim().Length) chars)" }
        $line = Format-Line $state.stage $state.feature 'skill' "$skill invoked: $word"
        break
      }

      # Codex has no Skill tool (verified 2026-11-13): the model starts a skill by reading its SKILL.md, with Bash or a
      # file-read tool. The first read of skills/asimov-<x>/SKILL.md is the invocation; the words that started it never
      # reach this hook, so the line carries no argument and the feature is read from the first path that names one.
      $text = ''
      foreach ($k in 'command', 'file_path', 'path', 'filePath') { $v = [string](Get-Field $ti $k); if ($v) { $text += ' ' + $v } }
      if ($text -match 'skills[\\/](asimov-[a-z-]+)[\\/]SKILL\.md') {
        $skill = $Matches[1]
        $stage = Get-Stage $skill
        if ($stage -and -not ($state.stage -eq $stage -and $state.lastSkill -eq $skill)) {   # one line per start, not per re-read
          $state.stage = $stage; $state.lastSkill = $skill
          $line = Format-Line $state.stage $state.feature 'skill' "$skill invoked: -"
          break
        }
      }

      if ($state.stage -eq 'session') { return }   # before any invocation nothing below is Asimov's

      switch ($tool) {
        { $_ -in 'spawn_agent', 'Agent', 'Task' } {
          # a spawn: remember the name, model and effort for the SubagentStart that follows; no line of its own
          $msg = [string](Get-Field $ti 'message'); if (-not $msg) { $msg = [string](Get-Field $ti 'prompt') }
          $name = ([string](Get-Field $ti 'subagent_type')) -replace '^.*:', ''
          if (-not $name -or $name -in 'default', 'general-purpose') { $slug = Get-Slug $msg; if ($slug) { $name = $slug } }
          $model = [string](Get-Field $ti 'model')
          $effort = [string](Get-Field $ti 'reasoning_effort'); if (-not $effort) { $effort = [string](Get-Field $ti 'effort') }
          $fork = ''; $fc = Get-Field $ti 'fork_context'; if ($fc -eq $true) { $fork = 'fork' }
          $state.pending = "$name|$model|$effort|$fork|$now"
        }
        { $_ -in 'multi_agent_v1send_input', 'SendMessage' } {
          # a message to a running agent starts its next round; an interrupt is a line
          $a = Find-Agent $state ([string](Get-Field $ti 'target'))
          if (-not $a) { $a = Find-AgentByShell $state ([string](Get-Field $ti 'to')) }
          if ($a) {
            $a.last = $now
            if ((Get-Field $ti 'interrupt') -eq $true) { $line = Format-Line $state.stage $state.feature $a.shell 'interrupted' }
          }
        }
      }

      if ($state.feature -eq '-') {
        $slug = Get-FeatureFromText $tiText
        if ($slug) { $state.feature = $slug; $line = Format-Line $state.stage $state.feature 'skill' "feature $slug, from the first path that names one" }
      }
      if (-not $line) { $saveState = $true; $line = '' }   # state changed, nothing to print
    }
    'SubagentStart' {
      $shell = ([string](Get-Field $payload 'agent_type')) -replace '^.*:', ''
      $aid = [string](Get-Field $payload 'agent_id')
      $model = [string](Get-Field $payload 'model')
      $effort = ''; $fork = ''
      if ($state.pending) {
        $p = $state.pending -split '\|'
        if ($p.Count -ge 5 -and ($now - [int64]$p[4]) -lt 600) {
          if ((-not $shell -or $shell -in 'default', 'general-purpose') -and $p[0]) { $shell = $p[0] }
          if (-not $model -and $p[1]) { $model = $p[1] }
          $effort = $p[2]; $fork = $p[3]
        }
        $state.pending = ''
      }
      if (-not $shell) { $shell = 'agent' }
      $bits = @(); if ($model) { $bits += $model }; if ($effort) { $bits += $effort }; if ($fork) { $bits += 'forked context' }
      $what = 'started'; if ($bits.Count) { $what += " ({0})" -f ($bits -join ', ') }
      if ($aid) { $state.agents = @($state.agents | Where-Object { $_.id -ne $aid }) + (New-Agent $aid $shell $now) }
      $line = Format-Line $state.stage $state.feature $shell $what
    }
    'SubagentStop' {
      # an agent answered: in Codex a continued agent answers once per message, so the stop is a round, never an end
      $shell = ([string](Get-Field $payload 'agent_type')) -replace '^.*:', ''
      $aid = [string](Get-Field $payload 'agent_id')
      $a = Find-Agent $state $aid
      if (-not $a) {
        if (-not $shell -or $shell -in 'default', 'general-purpose') { $shell = 'agent' }
        $a = New-Agent $aid $shell $now
        if ($aid) { $state.agents += $a }
      }
      $a.round++
      $secs = $now - $a.last
      $a.last = $now
      $stats = Get-TranscriptStats ([string](Get-Field $payload 'agent_transcript_path'))
      $head = Get-Headline ([string](Get-Field $payload 'last_assistant_message'))
      if (-not $head -and $stats.ok) { $head = $stats.headline }
      if ($head) { $head = $head -replace ('(?i)' + [regex]::Escape($root.TrimEnd('\', '/')) + '[\\/]+'), '' }   # a path the agent names, relative to the repo
      $detail = "$secs s"
      if ($stats.ok) { $detail += ', ' + (Format-Usage $stats $a) }
      $what = "round $($a.round) ($detail)"
      if ($head) { $what += ": $head" }
      $line = Format-Line $state.stage $state.feature $a.shell $what
    }
    'SessionEnd' {
      $reason = [string](Get-Field $payload 'reason')
      if (-not $reason) { $reason = 'unknown' }
      $what = "ended ($reason)"
      $stats = Get-TranscriptStats ([string](Get-Field $payload 'transcript_path'))
      if ($stats.ok) {
        $callWord = if ($stats.calls -eq 1) { 'tool call' } else { 'tool calls' }
        $what += (': {0} {1}, {2} tokens, {3} cached, {4} out' -f $stats.calls, $callWord, (Format-Count $stats.tokens), (Format-Count $stats.cached), (Format-Count $stats.out))
      }
      if ($state.agents.Count) { $what += (', {0} agent{1} seen' -f $state.agents.Count, $(if ($state.agents.Count -eq 1) { '' } else { 's' })) }
      $line = Format-Line $state.stage $state.feature 'session' $what
      $saveState = $false
    }
    default { return }
  }

  if ($null -eq $line) { return }
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $selfIgnore = Join-Path (Split-Path -Parent $dir) '.gitignore'
  if (-not (Test-Path -LiteralPath $selfIgnore)) { Write-Retry $selfIgnore "*`n" $false }
  if ($line) { Write-Retry (Join-Path $dir $state.file) $line $true }
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
