---
name: artifact-s101-ledger
description: Read and write the run state of one build — the ledger specs/<slug>/S101-<slug>.ledger.md beside a ready S101 — so a run can start, record every attempt, report and ruling, resume where it stopped, and refuse when the plan changed. Use inside asimov-build for every ledger operation (start, position, record, discard, close), and by hand when asked "where did the build stop", "what did Powell say about P1", "resume the build". Its method is the script scripts/ledger.ps1 beside this file, run inline through Bash, one call per operation; the table here is the script's specification and the fallback where no PowerShell exists. The only writer of the ledger; never writes a spec, never runs an agent, never commits.
---

# S101 ledger

The method for the one file that holds a build's run state. `asimov-build` calls it and never touches the ledger itself; it writes the ledger and nothing else. The bar, the keys, the statuses and the five checks are the definition's (`${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-ledger/s101-ledger-definition.md`); the shape is the template's beside it.

**The method is a script.** Every operation below is implemented in `scripts/ledger.ps1`, and the caller runs it inline through Bash: no skill text to load, no definition to re-read, no whole-file rewrite in the conversation. The first build run did these eleven operations by hand, each one a read of the definition, the template, the S101 and the ledger and a write of the whole file; the script does the same in one call and the same way twice. The table stays here as the script's specification and as the fallback where no PowerShell exists.

## The call

```
pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/skills/artifact-s101-ledger/scripts/ledger.ps1" -Op <operation> -S101 specs/<slug>/S101-<slug>.md [the operation's inputs]
```

`pwsh` (PowerShell 7) or `powershell` (Windows PowerShell 5.1; add `-ExecutionPolicy Bypass`), whichever the machine has; the script runs on both. The ledger's path is derived from the S101's (`S101-<slug>.ledger.md` beside it) and the repo root from the folder above `specs/`, so the script runs from any working directory. In Codex, where `${CLAUDE_PLUGIN_ROOT}` is not substituted, derive the plugin root from this skill's own path (strip everything from `skills/artifact-s101-ledger` onward) and use it in the path; the script itself reads nothing of the plugin.

**Text goes in through a file or stdin, never as an argument.** A builder's summary or a report is multi-line: write it to a file and pass `-TextFile <path>`, or pipe it on stdin with a heredoc (`… -Op review -S101 … -Phase P1 <<'EOF'` … `EOF`). `-Text` is for a one-liner.

**Print what it prints**, and nothing else: one line per operation, a short block for `position`. Exit code 2 is a refusal or an unreadable input; the line says which, and nothing was written.

## Operations

| Operation | Inputs | Does | Returns |
|---|---|---|---|
| `start` | `-By <name>` | Refuses if a ledger exists. Computes the S101's fingerprint (the S101 definition §6's, byte for byte as its awk one-liner does), refuses if it differs from the one in the S101's `approved` line or that line is `none`. Writes the ledger: every phase `pending`, every task `pending`, `attempts: 0`. | `ledger  S101-<slug>.ledger.md created` |
| `position` | — | Runs the checks L1–L5 of the definition §6. A Fail is a refusal naming the check in words (exit 2). Otherwise the position: every phase with its status (and its short hash once committed), the open phase's tasks with status, attempts, agent and model, and the last ruling. | A refusal line, or a three-line block the caller prints |
| `task` | `-Task T<nnn> -Status <status>`; for `running` also `-Agent <shell> -Model <model>` | Moves one task's status; `running` increments `attempts` and sets `agent` and `model`, sets the phase `building`, and opens the phase's `##` heading in the body on its first `running`. | `ledger  T<nnn> <status>` |
| `attempt` | `-Task T<nnn>`, the summary as text | Appends `### T<nnn> · attempt <k> · <agent> · <model>` with the builder's summary verbatim; sets the task `built`, and the phase `built` once every task of it is. | `ledger  T<nnn> built · attempt <k>` |
| `review` | `-Phase P<n>`, the report as text | Appends `### review` with the report verbatim. | `ledger  P<n> review recorded` |
| `verify` | `-Phase P<n>`, the report as text, and `-Passed` or `-Failed T…,T…` | Appends `### verify` with the report verbatim; `-Passed` sets the phase `passed` and its tasks `done`, else each named task `failed`. | `ledger  P<n> passed` or `ledger  P<n> failed: T…` |
| `fail` | `-Task T<nnn>` | Sets a task `failed` from a review Fail. | `ledger  T<nnn> failed` |
| `stop` | `-Task T<nnn>` | Sets the task `stopped`. | `ledger  T<nnn> stopped` |
| `ruling` | `-Phase P<n> -By <name> -Choice resume\|discard\|stop [-Note <text>]` | Appends `### ruling · <date> · <by>` with the choice and note; `resume` sets the phase's stopped and failed tasks `pending` with `attempts: 0`; `discard` sets the phase `discarded` and every task of it `pending`, `attempts: 0`. The caller resets the files. | `ledger  ruling by <by> · <choice>` |
| `commit` | `-Phase P<n> -By <name> -Hash <hash> -Files <n>` | Appends `### commit · <hash>` with the go, by and date, and the file count; sets the phase `committed` with `commit` and `go`. | `ledger  P<n> committed · <hash>` |
| `close` | — | Says whether every phase is `committed` or `discarded`, so the caller can set the S101 `done`. | `ledger  complete` or `ledger  <n> phases not committed (P…)` |

Every operation is one call: the frontmatter is rewritten with the statuses moved, the body only appended to (definition §4). Two changes are two calls.

**Where no PowerShell is installed**, say so in one line, read the definition and the template, and do the one operation by hand with the file tools, to the letter of the table above: the same headings, the same lines, the frontmatter rewritten and the body appended. Say `engine: hand` in the ledger's first body line so the next resume knows.

## Never

- **Write** any file but the ledger; never the S101, an S102, or a source file.
- **Spawn** an agent, run a test, or commit; the caller does, and tells you the result.
- **Summarise** a report. What the caller gives you goes into the body verbatim.
- **Invent** a position. If the checks fail, say which and stop; the person decides.
- **Name a product entity** in your own text; the ledger's content is the repo's, your lines are generic.

## Used by

- `asimov-build`, every step (start, position, task, attempt, review, verify, fail, stop, ruling, commit, close), the script run inline through Bash.
- By hand: "where did the build of `<slug>` stop", "show me P1's verify report".
