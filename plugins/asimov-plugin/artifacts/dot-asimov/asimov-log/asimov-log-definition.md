---
artifact: asimov-log
maturity: assess
since: 2026-10-22
---

# Definition of the Asimov run log

One text line per harness event, written into the product repo by the plugin's hooks and by nothing else. It exists so that what Asimov did during a run — which stage and feature, which agents, how long each round took, what it cost in tool calls and tokens, and what each agent answered — can be read afterwards without opening a transcript.

Written by: `hooks/scripts/asimov-log.ps1`, fired by `hooks/hooks.json` in Claude Code and by `hooks/hooks-codex.json` in Codex (since 2026-11-13; verified on the first logged Codex run, 2026-11-16). Read by: a person, by eye, after a run. No skill, no agent and no model writes a line (D101 R5); the *why* of a run lives in the ledger (`s101-ledger-definition.md`), never here. The counts and the headline of a stop line are read by the hook from the agent's own transcript, which the payload names; no model is asked (D101 Q1, resolved 2026-11-16).

Design: `documentation/features/D101-asimov-log.html`.

---

## 1. The file

`.asimov/log/<YYYY-MM-DD>-<id8>.log` under the repo root the hook payload names (`cwd`, so a worktree logs into itself). One file per session, named by the date of its first line and the **last** eight characters of the session id (since 2026-11-16: a Codex session id is a UUIDv7, whose first eight characters are a timestamp that two sessions started in the same hour share, so the first eight put two sessions in one file); append only; UTF-8; gitignored as `.asimov/`, and `.asimov/.gitignore` holds `*`, so git never lists the folder in a repo whose own `.gitignore` predates it. Two sessions in one repo write two files. A session past midnight keeps its file.

`.asimov/log/` holds the log files and nothing else. `.asimov/state/<id8>.state` holds the session's current stage and feature, its log file name, the last skill invoked, a pending spawn (name, model, effort, fork, time) and one line per agent seen (id, name, start time, time of the last message to it, round, and its cumulative tokens, cached tokens, output tokens and tool calls). It is the hook's own memory and is deleted at session end; one a session end could not delete (the harness gives SessionEnd hooks 1.5 s) is swept by the next session start once it is twelve hours old.

With `ASIMOV_LOG_RAW=1` in the environment the hook also appends every payload, verbatim, to `.asimov/raw/<id8>.jsonl`: the way to read what a harness hands over. Off by default, since a payload carries prompt text the log never may.

## 2. The line

```
YYYY-MM-DD HH:MM  <stage>  <feature>  <who>  <sentence>
```

| Field | Value |
|---|---|
| time | Local clock, minute resolution |
| stage | `session`, `init`, `design`, `spec` or `build`: the last asimov-skill invoked in the session; `session` before any |
| feature | The first word after the asimov-skill's name at its invocation; in Codex, where those words never reach the hook, the slug of the first `.asimov/plans/<slug>.md`, `.asimov/specs/<slug>/` or `D101-<slug>.html` (`.md`) path a tool input names after the invocation; `-` before either; unchanged when the input was more than one word |
| who | `session`, `skill`, or the agent's name: its shell (`giskard-the-dotnet-developer`) where the harness names one; else the name its spawn message opens with (`You are Giskard, …` → `giskard`, `Act as the S101 plan writer for …` → `s101-plan-writer`); else `agent` |
| sentence | English, one line, from the table in §3. Never prompt, code or diff text (D101 R4); the one piece of model text is a round's headline, the first line of the agent's answer, markdown stripped, cut at 80 characters, a path under the repo made relative |

Fields are separated by two or more spaces, so `awk` and a reader split them the same way; stage, feature and who are padded to 7, 12 and 16 characters, and a longer name pushes the rest of its line.

## 3. The events

The list is closed: only a harness event makes a line.

| Event | who | Sentence |
|---|---|---|
| `SessionStart` | session | `started (<harness>[, <model>][, <source>])`: `claude-code` or `codex`; the model where the payload carries one; the source on a resume, clear or compact |
| A typed `/asimov-*` (`UserPromptExpansion`) or a Skill call of one (`PreToolUse`) | skill | `<skill> invoked: <word>`; input of more than one word → `(text, <n> chars)` |
| In Codex, which has no Skill tool: the first read of `skills/asimov-<x>/SKILL.md` by any tool (`PreToolUse`) | skill | `<skill> invoked: -`; a re-read in the same stage adds no line |
| The first tool input naming a feature while the feature is `-` (`PreToolUse`, after an invocation) | skill | `feature <slug>, from the first path that names one` |
| A spawn (`Agent` or `Task` in Claude Code, `spawn_agent` in Codex; `PreToolUse`) | — | No line; the name, model, effort and fork are kept for the start that follows |
| `SubagentStart` | name | `started (<model>, <effort>, forked context)`, each part where known |
| A message to a running agent (`SendMessage` in Claude Code, `multi_agent_v1send_input` in Codex; `PreToolUse`) | — | No line; it starts the agent's next round. With `interrupt`: `interrupted` |
| `SubagentStop` | name | `round <n> (<s> s, <calls> tool calls, <tokens> tokens, <cached> cached, <out> out): <headline>`; the counts are left out where the transcript could not be read, the headline where the answer is empty |
| `SessionEnd` | session | `ended (<reason>)[: <calls> tool calls, <tokens> tokens, <cached> cached, <out> out][, <n> agents seen]`: the session's own transcript, cumulative |

An invocation sets stage and feature for the rest of the session. A **round** is one answer: an agent answers once per message it is sent, and in Codex a continued agent stops once per answer, so a stop is a round and never an end; seconds are the hook's own clock from the agent's start, or the last message to it, to the stop. A stop with no start seen is round 1 of an agent named by its type or `agent`. Counts print as `k` and `M`, one decimal below ten, a decimal point whatever the machine's culture.

The counts come from the transcript the payload names (`agent_transcript_path` on a stop, `transcript_path` at session end), read as a file, never summed by a model:

| Harness | Where | Counted |
|---|---|---|
| Codex | the last `token_count` event of the rollout, cumulative | `total_tokens`, `cached_input_tokens`, `output_tokens`; a `function_call` row is a tool call |
| Claude Code | `usage` of every assistant line, once per message id (a message is written once per content block) | input + cache creation + cache read + output as the total, cache read as cached, output; a `tool_use` block is a tool call |

A round's figures are the transcript's cumulative ones less what the state file already holds for the agent. The transcript is opened with every share, since the harness holds it open while it writes; one over 40 MB is not read, and the line carries the seconds alone.

## 4. The rules

- A hook always exits 0 and prints nothing: a failing hook never blocks a run and never reaches the chat (D101 R6); the hook command itself ends in `exit 0`, so a machine without PowerShell gets an empty log and no hook notice. A read-only folder loses the session's lines.
- Hooks run in parallel: the state file is read, changed and written under a named mutex per session, so a batch of agents starting at once loses no start.
- Only an `asimov-*` invocation creates the folder, and with it `.asimov/.gitignore`; every other event writes a line only where the folder exists. A repo Asimov never ran in gets no folder, and a repo's first session logs from its first invocation.
- The payload is read as UTF-8 bytes, never through the console's code page, so an agent's answer keeps its characters.
- In Claude Code the hook command is a `pwsh … || powershell …` chain, so the hook shell must be Git Bash or PowerShell 7; a typed `/asimov-*` reaches it as a `UserPromptExpansion` event, a Skill, Agent or SendMessage call as `PreToolUse`. Codex on Windows runs hooks through PowerShell, so `hooks-codex.json` carries a `commandWindows` straight onto the script, and its `PreToolUse` registration has no matcher, since Codex has neither a `UserPromptExpansion` nor a Skill tool: the model starts a skill by reading its `SKILL.md`, and that read is the invocation.
- A missing state file is recreated from the event at hand: stage and feature read `-`, a stop is round 1 with the seconds since the event itself.
- The log is working state, never a record: it is not committed, not rotated and not read by any skill (D101 OOS3, OOS4).
