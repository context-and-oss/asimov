---
name: artifact-s101-ledger
description: Read and write the run state of one build — the ledger documentation/specs/<slug>/S101-<slug>.ledger.md beside a ready S101 — so a run can start, record every attempt, report and ruling, resume where it stopped, and refuse when the plan changed. Use inside asimov-build for every ledger operation (start, position, record, discard, close), and by hand when asked "where did the build stop", "what did Powell say about P1", "resume the build". The only writer of the ledger; never writes a spec, never runs an agent, never commits.
---

# S101 ledger

The method for the one file that holds a build's run state. It reads the definition and the template at run time and applies them; `asimov-build` calls it and never touches the ledger itself. It writes the ledger and nothing else.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-ledger` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-ledger-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2).

1. **The definition** — the bar, the keys, the statuses, the rules and the checks:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-ledger/s101-ledger-definition.md
   ```

2. **The template** — the frontmatter and body shape you render:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-ledger/s101-ledger-template.md
   ```

3. **The S101** at `documentation/specs/<slug>/S101-<slug>.md`, whole, parsed as YAML frontmatter: its tree and its `approved` line.

If 1 or 2 cannot be read, stop and report the path; never write a ledger from memory of the shape.

## Operations

The caller names one operation and its inputs. Every operation returns one line, in words, for the chat, and nothing else unless the table says so.

| Operation | Inputs | Does | Returns |
|---|---|---|---|
| `start` | `slug`, `by` | Refuses if a ledger exists. Computes the S101's fingerprint (the S101 definition §6's: `awk '/^phases:/{p=1} p&&/^---$/{p=0} /^## /{s=0} /^## (2\|3\|6)\./{s=1} p\|\|s' <s101> \| sha256sum \| cut -c1-12`, never printed; no `$`-token in it, because the harness substitutes `$0`, `$1`… in a skill's text), refuses if it differs from the one in the S101's `approved` line or that line is `none`. Renders the template: every phase `pending`, every task `pending`, `attempts: 0`. Writes the file. | `ledger  S101-<slug>.ledger.md created` |
| `position` | `slug` | Runs the checks L1–L5 of the definition §6. A Fail is returned as a refusal naming the check in words. Otherwise returns the position: the committed phases, the phase in progress with each task's status and attempts, the last ruling if any. | A refusal line, or the position as a short block the caller prints |
| `task` | `slug`, `task`, `status`, and for `running`: `agent`, `model` | Moves one task's status; `running` increments `attempts` and sets `agent` and `model`; opens the phase's `##` heading in the body when it is the phase's first `running` and sets the phase `building`. | `ledger  T<nnn> <status>` |
| `attempt` | `slug`, `task`, `summary` | Appends `### T<nnn> · attempt <k> · <agent> · <model>` with the builder's summary verbatim; sets the task `built`. | `ledger  T<nnn> built · attempt <k>` |
| `review` | `slug`, `phase`, `report` | Appends `### review` with the report verbatim. | `ledger  P<n> review recorded` |
| `verify` | `slug`, `phase`, `report`, `passed` (bool), `failed_tasks` | Appends `### verify` with the report verbatim; sets the phase `passed` and its tasks `done` when `passed`; else sets each task in `failed_tasks` to `failed`. | `ledger  P<n> <passed \| failed: T…>` |
| `fail` | `slug`, `task` | Sets a task `failed` from a review Fail (Baley's *Against the spec* Fail names the task). | `ledger  T<nnn> failed` |
| `stop` | `slug`, `task` | Sets the task `stopped`. | `ledger  T<nnn> stopped` |
| `ruling` | `slug`, `phase`, `by`, `choice` (`resume` \| `discard` \| `stop`), `note` | Appends `### ruling · <date> · <by>` with the choice and note; `resume` sets the stopped task `pending` with `attempts: 0`; `discard` sets the phase `discarded` and every task of it `pending`, `attempts: 0`. The caller resets the files; this skill does not touch them. | `ledger  ruling by <by> · <choice>` |
| `commit` | `slug`, `phase`, `by`, `hash`, `files` | Appends `### commit · <hash>` with the go, by and date, and the file count; sets the phase `committed` with `commit` and `go`. | `ledger  P<n> committed · <hash>` |
| `close` | `slug` | Checks that every phase is `committed` or `discarded`; returns whether the run is complete, so the caller can set the S101 `done`. | `ledger  complete` or `ledger  <n> phases not committed` |

Every write is a read of the whole file, one change, and a write of the whole file; two changes are two operations. The frontmatter is rewritten with the statuses moved; the body is only appended to (definition §4).

## Never

- **Write** any file but the ledger; never the S101, an S102, or a source file.
- **Spawn** an agent, run a test, or commit; the caller does, and tells you the result.
- **Summarise** a report. What the caller gives you goes into the body verbatim.
- **Invent** a position. If the checks fail, say which and stop; the person decides.
- **Name a product entity** in your own text; the ledger's content is the repo's, your lines are generic.

## Used by

- `asimov-build`, every step (start, position, task, attempt, review, verify, fail, stop, ruling, commit, close).
- By hand: "where did the build of `<slug>` stop", "show me P1's verify report".
