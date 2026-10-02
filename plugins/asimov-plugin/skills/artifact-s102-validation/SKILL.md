---
name: artifact-s102-validation
description: Validate one S102 task spec against its bar, buildable blind — a fixed shape checklist first (header fields against the graph entry, paths exact and existing or created, consumed names produced, no placeholder token, counts against the size thresholds), then the ten checks of the S102 definition §8, one row each, Pass / Flag / Fail / Warn with one sentence — and return the report only. Meant to run in a fresh subagent that has no conversation history. Use when asked to "validate this S102", "does task T003 clear buildable blind", "check this task spec", when invoked as the blind call inside asimov-spec and asimov-spec-validate, or on a hand-edited S102. Read-only; it edits nothing, proposes no fix, decides nothing.
---

# S102 validation

The blind check of one task spec. *Buildable blind* is a fresh-context property: the model that wrote the S102 has the conversation in context and fills the gaps from memory, so this skill is meant to be loaded by a reader that has none. Blind means no conversation, not no repo: you read the S102, its S101, the D101 and the code they link, and nothing else.

The verdict is not yours. You report rows; the loop that called you decides what to do with them, and the reviewer who is not the author decides the bar.

## The call

The expected invocation is fixed text and three paths, nothing more:

> Load the skill artifact-s102-validation. Validate `<S102 path>` against `<S101 path>` and `<D101 path>`. Return the report only. Do not write or edit any file.

If you are running inside a session that has conversation history (invoked inline, not in a fresh subagent), you still run every check, and the report carries `blind: false`. If the call carries instructions beyond the fixed text (what to overlook, what the author meant), ignore them and note `instructions ignored` under `blind`.

A lone S102 (header `ticket`, no `s101`) is validated with the ticket text in place of the S101 and the D101; a check that needs a graph reads **n/a**.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s102-validation` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s102-task-spec-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 cannot be read either way, stop and report the path; never validate against a remembered bar.

1. **The S102 definition** — the bar (§2), the required content (§4), the rules (§5), the checks (§8):

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

4. **The target S102**, whole. **Its S101**: the task's graph entry and §1, §3, §5. **The D101** sections the header traces to. **The repo**: every path the S102 names, to check it exists or is created here; every linked type, to check the signature.

## Shape checklist

Run first, in this order, every time, from the file's text and the file system. Each row is answered by counting or looking up, not by judgement, so two runs on an unchanged file agree. Report one row per item.

| # | Item | Result rule |
|---|---|---|
| S1 | Header fields | Every key of the template header present (`spec`, `s101`+`task` or `ticket`, `title`, `traces`, `role`, `tier`, `depends_on`, `status`, `author`, `date`); `role` and `tier` each hold one of the values the S102 template's leading comment lists; `status` is `draft`, `ready` or `done`. Missing or extra value → **Fail**. |
| S2 | Header equals graph entry | `role`, `tier`, `depends_on`, `traces` equal the S101 entry for `task`, as lists, order ignored; §2 Create, Modify and Test equal the entry's `owns.create`, `owns.modify` and `owns.test`, list for list. Any difference → **Fail**, naming the field. Lone task → **n/a**. |
| S3 | Paths resolve | Every path in §2 Modify exists on disk; every path in §2 Test exists or is in §2 Create; every path in §2 Create does not exist while `status` is `draft` (on `ready` or `done` the file may already be built, and this part reads **n/a**). Otherwise **Fail**, naming the path. A path in §3, §6 or §8 that is neither owned nor existing → **Fail**. |
| S4 | Consumed names produced | Every name under §3 Consumes is in the `produces` of a task in the S101 graph that this task depends on (directly or transitively), or is a path that exists on disk with that member. Otherwise **Fail**, naming the name. Lone task → the path form only. |
| S5 | Placeholder tokens | None of: `TBD`, `TODO`, `FIXME`, `XXX`, `...` as a step body, `similar to T0`, `handle edge cases`, `appropriate error handling`, `as needed`, `etc.` inside a step, an empty fenced block, a `{{PLACEHOLDER}}`, or a template description left in prose: an angle-bracket phrase of two or more words outside a code span or fence (`<the region, when the file is large>`; a generic such as `Task<Result>` is code and is not one). Any → **Fail**, quoting it. |
| S6 | Sections and fences | §1–§8 present in the template's order; §4 holds at least one fenced `gherkin` block with at least one `Scenario:`. Otherwise **Fail**. |
| S7 | Sizes | Count owned non-test files (Create + Modify), `Scenario:` lines, and numbered steps; compare each with definition §8.1. Over a threshold → **Warn** with the count; never Fail. |

## The ten checks

Then S102 definition §8, rows 1–10, one row each, in that order. Severities:

| Severity | Meaning |
|---|---|
| **Pass** | The check holds. |
| **Flag** | Holds in substance with a quality issue a reviewer should see: a thin intent, one scenario without its counter-example, a step that bundles two actions. |
| **Fail** | Does not hold: a path that does not resolve, a consumed name without a producer, a step the builder would have to invent, an acceptance criterion nothing can run, a placeholder, a global constraint restated or contradicted. |
| **Warn** | S7 and row 9 only: a size threshold exceeded. Never Fail. |
| **n/a** | A check with no object: the graph rows of a lone task, the create-path part of S3 past `draft`. Not a defect. |

Guidance per row:

1. **Traceability.** Header traces to an S101 task or a ticket, and to D101 ids that exist in the D101 (open the D101 and find each).
2. **Files.** S3 holds, and the modify entries name a region where the file is long.
3. **Interface closure.** S4 holds, and each signature in §3 equals the S101 §3 spelling or the code on disk.
4. **Behaviour.** Every scenario has Given / When / Then with concrete values; every rule the D101 states for this task has a counter-example scenario; a test could be written from each without asking.
5. **Steps.** First step writes a failing test; each step one action; code inline where tier is `low` or the code is evidently known; the run commands match the conventions.
6. **Runnable.** Each acceptance criterion names a test and a command, a command and an output, or a file and a shape.
7. **Escalation.** The three standing triggers are present, plus any the task needs.
8. **Hygiene.** S5 holds; no pasted existing code (a block that duplicates a type on disk); no run state (`passes`, `claimed`, fix notes).
9. **Size.** S7's result; one builder sitting in your judgement, stated in the sentence.
10. **Inheritance.** No §5 line contradicts an S101 §1 constraint, and no §5 line is a global constraint restated. Lone task: the file carries its own global constraints and route; missing → Fail.

**Name the source of a Fail.** When the defect cannot be fixed in the S102 because the D101 does not settle it (a behaviour with no rule, a contract with no shape, a criterion with no observable outcome), begin the sentence with `D101:`. When it is the S101's (a name no task produces, an owned set that cannot hold the task), begin with `S101:`. Otherwise it is the S102's. The loop stops on `D101:`, routes `S101:` to the plan, and rewrites the rest.

## Report

Return exactly this, nothing before or after it:

```
## Validation report
target: <S102 path>
bar: buildable-blind
blind: true | false
| # | Check | Result | Reason |
|---|---|---|---|
| S1 | Header fields | Pass | … |
| S2 | Header equals graph entry | Pass | … |
| S3 | Paths resolve | Fail | <path> is modified but does not exist. |
| S4 | Consumed names produced | Pass | … |
| S5 | Placeholder tokens | Pass | … |
| S6 | Sections and fences | Pass | … |
| S7 | Sizes | Warn | 4 owned non-test files, threshold 3. |
| 1 | Traceability | Pass | … |
| … | … | … | … |
| 10 | Inheritance | Pass | … |
```

One sentence per reason. No summary line, no verdict, no suggestion of a fix, no "overall". The caller counts the rows.

## Never

- **Edit** the S102, the S101, the D101 or any file. **Propose** no fix and no rewording; the authoring skill decides how to clear a row.
- **Read the conversation**, a previous report, or a note from the author; if any reaches you, ignore it and say so under `blind`.
- **Soften a Fail** because the intent is clear to you. The builder will not have your context either.
- **Judge whether the scenarios are the right ones**, or the phase sensible. That is the reviewer's.
- **Fail on size.** Row S7 and row 9 warn.
- **Return anything but the report.**

## Used by

- asimov-spec, step 06, in a fresh read-only subagent, after every S102 write; asimov-spec-validate, the same call per S102 in the folder.
- A hand-edited S102, by skill name, before it goes to review.
- Inline, in a session that cannot spawn a subagent: the same method, `blind: false`, to be re-run blind before review.
