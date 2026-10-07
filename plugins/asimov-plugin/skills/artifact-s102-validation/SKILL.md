---
name: artifact-s102-validation
description: Validate one S102 task spec against its bar, buildable blind — a fixed shape checklist first (header fields against the task line in the S101 tree, owned paths exact and existing or created upstream, consumed and produced names in the S101 contracts, no placeholder, no code block but Gherkin, no done-when that greps the source, counts against the size thresholds), then the ten checks of the S102 definition §8, one row each, Pass / Flag / Fail / Warn with one sentence — and return the report only. Meant to run in a fresh subagent that has no conversation history. Use when asked to "validate this S102", "does task T003 clear buildable blind", "check this task spec", when invoked as the blind call inside asimov-spec (after every write, and on every task spec in a re-check), or on a hand-edited S102. Read-only; it edits nothing, proposes no fix, decides nothing.
---

# S102 validation

The blind check of one task spec. *Buildable blind* is a fresh-context property: the model that wrote the S102 has the conversation in context and fills the gaps from memory, so this skill is meant to be loaded by a reader that has none. Blind means no conversation, not no repo: you read the S102, its S101, the design (the D101, or the design cache), the headers of the neighbouring S102s and the code they link, and nothing else.

The verdict is not yours to print. You report rows; the loop that called you decides what to do with them, and a report with no Fail row is what it records as the task spec's approval (`validated`). Your rows are the only check a task spec gets; no person reads them.

## The call

The expected invocation is fixed text and three paths, nothing more:

> Load the skill `artifact-s102-validation`. Validate `<S102 path>` against `<S101 path>` and `<design path>`. Return the report only. Do not write or edit any file.

The design path is the D101 (`documentation/features/D101-<slug>.html`) or the normalised design (`documentation/specs/<slug>/design.md`, in the shape the S101 definition §9 fixes; its members are `${CLAUDE_PLUGIN_ROOT}/contracts/design.md`); the S101 header's `design` line says which: `ref` for a repo file, `cache` for a normalised one.

If you are running inside a session that has conversation history (invoked inline, not in a fresh subagent), you still run every check, and the report carries `blind: false`. If the call carries instructions beyond the fixed text (what to overlook, what the author meant), ignore them and note `instructions ignored` under `blind`.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s102-validation` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s102-task-spec-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 cannot be read either way, stop and report the path; never validate against a remembered bar.

1. **The S102 definition** — the bar (§2), the contract mapping (§3.2), the required content (§4), the rules (§5), the checks (§8):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-definition.md
   ```

2. **The S101 definition §8.1** — the size thresholds:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

3. **The S102 template** — the header keys and the section order a conforming file has:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s102-task-spec/s102-task-spec-template.md
   ```

4. **The two contracts**, `${CLAUDE_PLUGIN_ROOT}/contracts/specification.md` (the task members and the rules) and `${CLAUDE_PLUGIN_ROOT}/contracts/design.md` (the members the traces point into).

5. **The target S102**, whole. **Its S101**: the task's line in the tree, §1 Contracts, §2 Constraints, §4 Escalation, §3 Coverage. **The design** items the header traces to: the D101's sections by id, or the cache's R, NF, AC and OOS items. **The headers of the other S102s in the folder**: their `owns.create` for S3, their `owns` for the pairs that may run beside this task. **The repo**: every path the S102 names, to check it exists or is created upstream; every contract the header names, to check the code on disk where it is existing code.

## Shape checklist

Run first, in this order, every time, from the file's text and the file system. Each row is answered by counting or looking up, not by judgement, so two runs on an unchanged file agree. Report one row per item.

| # | Item | Result rule |
|---|---|---|
| S1 | Header fields | Every key of the template header present (`spec`, `s101`, `task`, `title`, `role`, `tier`, `after`, `traces`, `owns` with `create`, `modify`, `test` lists, `consumes`, `produces`, `status`, `validated`, `author`, `date`); `role` and `tier` each hold one of the values the S101 template's leading comment lists; `status` is `draft`, `validated` or `done`, and `validated` is `none` or a date (a date with `status: draft` is a leftover and → **Flag**). Missing or extra value → **Fail**. |
| S2 | Header equals task line | `title`, `role`, `tier`, `after`, `traces` equal the S101 tree's line for `task`, lists as sets. Any difference → **Fail**, naming the field. |
| S3 | Paths resolve | Every path in `owns.modify` exists on disk, or is in the `owns.create` of an S102 whose task this one comes after (directly or transitively); every path in `owns.test` exists, or is new (a test file may be created under `test` alone); every path in `owns.create` does not exist while `status` is `draft` or `validated` (on `done` the file may already be built, and this part reads **n/a**); no path appears in two of the three lists. Otherwise **Fail**, naming the path. A path in the body that is neither owned nor existing → **Fail**. |
| S4 | Names in the contracts | Every name in `consumes` is a row of the S101 §1 whose *Consumed by* names this task and whose *Produced by* is a task this one comes after or *existing code* with a path that exists; every name in `produces` is a row whose *Produced by* names this task. Otherwise **Fail**, naming the name. |
| S5 | Placeholders | None of: `TBD`, `TODO`, `FIXME`, `XXX`, `similar to T0`, `handle edge cases`, `appropriate error handling`, `as needed`, `to be decided`, an empty fenced block, a `{{PLACEHOLDER}}`, or a template description left in prose: an angle-bracket phrase of two or more words outside a code span or fence (a generic such as `Task<Result>` is code and is not one). Any → **Fail**, quoting it. |
| S6 | Sections | §1–§5 present in the template's order; §2 holds at least one fenced `gherkin` block with at least one `Scenario:`, or one line beginning `none:` that names the check; §3 holds at least one numbered item; no section opens with a sentence of the template's. Otherwise **Fail** (a template sentence → **Flag**). |
| S7 | Boundary tokens | No fenced block whose language is anything but `gherkin`; no numbered or bulleted list under a heading that reads *Steps*; no `Scenario:` that names a path or a name not in the S101 §1 or the design; no §3 item whose command is `grep`, `Select-String`, `findstr`, `rg` or a search of an owned source path. Any → **Fail**, quoting the line. |
| S8 | Sizes | Count owned non-test files (`owns.create` + `owns.modify`) and `Scenario:` lines; compare each with definition §8.1. Over a threshold → **Warn** with the count; never Fail. |

## The ten checks

Then S102 definition §8, rows 1–10, one row each, in that order. Severities:

| Severity | Meaning |
|---|---|
| **Pass** | The check holds. |
| **Flag** | Holds in substance with a quality issue a reviewer should see: a thin intent, one scenario without its failing case, a must that leans toward how. |
| **Fail** | Does not hold: a path that does not resolve, a name without a contract row, a scenario a test cannot be written from, a done-when nothing can run, a placeholder, a body or a test in a code block, a constraint restated or contradicted. |
| **Warn** | S8 and row 9 only: a size threshold exceeded. Never Fail. |
| **n/a** | A check with no object: the create-path part of S3 past `draft`; row 4 for a task that states *none*. Not a defect. |

Guidance per row:

1. **Traceability.** S2 holds, and every id in `traces` exists in the design: open the D101 and find each, or find each item in the cache's lists.
2. **Scope.** S3 holds.
3. **Interface closure.** S4 holds, and where a name is existing code, the member exists on disk under that name.
4. **Behaviour.** Every scenario has Given / When / Then with concrete values; every rule the design states for this task has a failing-case scenario; a test could be written from each without asking; no private name. For a *none* line: the task is of a kind that adds no behaviour (Foundation, wiring, a reference, a release) and the named check is a build or a command.
5. **Done-when.** Each item names a test class and a command with its expected state, a build and its exit, or a command and its output; the commands match the conventions; S7's grep part holds.
6. **Stops.** The stops are this task's own; none of the generic three is repeated; a task whose §4 has no *Stops* line has none to state (Pass with that sentence).
7. **Boundary.** S7 holds; no must names a private method, an algorithm or a loop; no signature is restated.
8. **Hygiene.** S5 and S6 hold; no pasted existing code; no copied S101 constraint or routing; no run state (`passes`, `claimed`, fix notes).
9. **Size.** S8's result; one builder sitting in your judgement, stated in the sentence.
10. **Inheritance.** No §4 line contradicts an S101 §2 constraint, and no §4 line is a global constraint restated.

**Name the source of a Fail.** When the defect cannot be fixed in the S102 because the design does not settle it (a behaviour with no rule, a contract with no shape, a criterion with no observable outcome, in the D101 or in the ticket), begin the sentence with `design:`. When it is the S101's (a name no contract row carries, a producer this task does not come after, two parallel tasks that cannot own disjoint files), begin with `S101:`. Otherwise it is the S102's. The loop stops on `design:`, routes `S101:` to the plan, and rewrites the rest.

**Template findings.** A place where the S102 visibly worked around a rule of the template or of this checklist is reported as one line under `template findings:` after the report, never as a Fail. The caller writes them to the sidecar for the maintainer.

## Report

Return exactly this, nothing before or after it (the template findings, when any, follow the block):

```
## Validation report
target: <S102 path>
bar: buildable-blind
blind: true | false
| # | Check | Result | Reason |
|---|---|---|---|
| S1 | Header fields | Pass | … |
| S2 | Header equals task line | Pass | … |
| S3 | Paths resolve | Pass | <path> is created by T003 upstream. |
| S4 | Names in the contracts | Pass | … |
| S5 | Placeholders | Pass | … |
| S6 | Sections | Pass | … |
| S7 | Boundary tokens | Pass | … |
| S8 | Sizes | Warn | 4 owned non-test files, threshold 3. |
| 1 | Traceability | Pass | … |
| … | … | … | … |
| 10 | Inheritance | Pass | … |
```

One sentence per reason. No summary line, no verdict, no suggestion of a fix, no "overall". The caller counts the rows.

## Never

- **Edit** the S102, the S101, the design or any file. **Propose** no fix and no rewording; the authoring skill decides how to clear a row.
- **Read the conversation**, a previous report, or a note from the author; if any reaches you, ignore it and say so under `blind`.
- **Soften a Fail** because the intent is clear to you. The builder will not have your context either.
- **Fail a task for not carrying the code.** The body is the builder's; a spec that carries it fails S7.
- **Judge whether the scenarios are the right ones**, or the phase sensible. That is the author's, at the cut.
- **Fail on size.** Row S8 and row 9 warn.
- **Return anything but the report** and the template findings.

## Used by

- asimov-spec, step 06, in a fresh read-only subagent, after every S102 write; asimov-spec in mode recheck, the same call per S102 in the folder.
- A hand-edited S102, by skill name, before it goes to review.
- Inline, in a session that cannot spawn a subagent: the same method, `blind: false`, to be re-run blind before review.
