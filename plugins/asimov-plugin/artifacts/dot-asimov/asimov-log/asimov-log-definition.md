---
artifact: asimov-log
maturity: assess
since: 2026-10-22
---

# Definition of the Asimov run log

One text line per harness event, written into the product repo by the plugin's hooks and by nothing else. It exists so that what Asimov did during a run can be read afterwards without reconstructing it from transcripts.

Written by: `hooks/asimov-log.ps1`, fired by `hooks/hooks.json` in both harnesses. Read by: a person, by eye, after a run. No skill, no agent and no model writes a line (D101 R5); the *why* of a run lives in the ledger (`s101-ledger-definition.md`), never here.

Design: `documentation/features/D101-asimov-log.html`.

---

## 1. The file

`.asimov/log/<YYYY-MM-DD>-<id8>.log` under the repo root the hook payload names (`cwd`, so a worktree logs into itself). One file per session, named by the date of its first line and the first eight characters of the session id; append only; UTF-8; gitignored as `.asimov/`. Two sessions in one repo write two files. A session past midnight keeps its file.

Beside it, `.asimov/log/.<id8>.state` holds the session's current stage and feature, its log file name, and one line per running agent (id, start time, shell). It is the hook's own memory and is deleted at session end; one a session end could not delete (the harness gives SessionEnd hooks 1.5 s) is swept by the next session start once it is twelve hours old.

With `ASIMOV_LOG_RAW=1` in the environment the hook also appends every payload, verbatim, to `.asimov/log/raw-<id8>.jsonl`: the way to read what a harness hands over. Off by default, since a payload carries prompt text the log never may.

## 2. The line

```
YYYY-MM-DD HH:MM  <stage>  <feature>  <who>  <sentence>
```

| Field | Value |
|---|---|
| time | Local clock, minute resolution |
| stage | `session`, `init`, `design`, `spec` or `build`: the last asimov-skill invoked in the session; `session` before any |
| feature | The first word after the asimov-skill's name at its invocation; `-` before any invocation; unchanged when the input was more than one word |
| who | `session`, `skill`, or the agent's shell name (`giskard-the-dotnet-developer`) |
| sentence | English, one line, from the table in §3; never prompt, code or diff text (D101 R4) |

Fields are separated by two or more spaces, so `awk` and a reader split them the same way.

## 3. The events

The list is closed: only a harness event makes a line.

| Event | who | Sentence |
|---|---|---|
| `SessionStart` | session | `started (<harness>)`, `claude-code` or `codex`; `started (<harness>, <source>)` on a resume, clear or compact |
| A typed `/asimov-*` (`UserPromptExpansion`) or a Skill call of one (`PreToolUse`) | skill | `<skill> invoked: <word>`; input of more than one word → `(text, <n> chars)` |
| `SubagentStart` | shell | `started` |
| `SubagentStop` | shell | `stopped after <s> s`; `stopped` when no start was seen |
| `SessionEnd` | session | `ended (<reason>)` |

An invocation sets stage and feature for the rest of the session. Seconds are the hook's own clock between an agent's start and stop; an agent still running at session end gets no stop line.

## 4. The rules

- A hook always exits 0 and prints nothing: a failing hook never blocks a run and never reaches the chat (D101 R6). A missing folder is created; a read-only one loses the session's lines.
- Hooks run in parallel: the state file is read, changed and written under a named mutex per session, so a batch of agents starting at once loses no start.
- The folder is created only when a line is written: an event that makes no line touches nothing, and a repo never initialised for Asimov gets no folder from a Skill call outside `asimov-*`.
- The hook command is a `pwsh … || powershell …` chain: the hook shell must be Git Bash or PowerShell 7, and a typed `/asimov-*` reaches the hook as a `UserPromptExpansion` event, a Skill call as `PreToolUse`.
- A missing state file is recreated from the event at hand: stage and feature read `-`, a stop carries no seconds.
- The log is working state, never a record: it is not committed, not rotated and not read by any skill (D101 OOS3, OOS4).
