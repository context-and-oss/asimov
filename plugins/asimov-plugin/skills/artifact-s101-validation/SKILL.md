---
name: artifact-s101-validation
description: Validate an S101 implementation plan against its bar, dispatch-ready, in one of two modes — graph-only on the S101 alone (frontmatter parses as the phase tree, no cycle, tester before builder in every slice, every slice task after the Foundation, contracts table consistent, coverage both ways against the design), used at the cut before any S102 exists; or full with every S102 in the folder (the graph checks again, then disjoint owned sets and interface closure from the S102 headers, no contradicted constraint, every S102 header equal to its task line) — then the ten checks of the S101 definition §8, one row each, Pass / Flag / Fail / Warn / not yet with one sentence. Use when asked to "validate this plan", "run the graph checks on the cut", "is this S101 dispatch-ready", or inside asimov-spec (steps 03 and 07) and asimov-spec-validate. Runs read-only in a fresh subagent; it edits nothing, proposes no fix, moves no status.
---

# S101 validation

The check of the plan: does it clear its bar, and does it agree with itself and with its task specs. Its checks are cross-file and mechanical, not a blind property, so it needs every file open and reads them all from disk. It is meant to be loaded by a fresh subagent all the same, so that its reading and its rows stay out of the caller's conversation; the caller turns each row into one line for the person. The verdict stays the author's; this skill answers rows.

## Modes

| Mode | When | Reads |
|---|---|---|
| **graph-only** | At the cut: the S101 exists and no S102 does. Also what a cut gets from asimov-spec-validate. | The S101 and the design. |
| **full** | Every task in the tree has its S102 on disk. | The S101, every S102 in the folder, the design. |

The design is what the S101 header's `design` line names: a repo file at `design.ref` (a D101), or the normalised cache at `design.cache` (`documentation/specs/<slug>/design.md`, in the shape the S101 definition §9 fixes). Read `${CLAUDE_PLUGIN_ROOT}/contracts/design.md` first; you check the design through its members.

The caller states the mode; absent that, the folder decides: no `S102-*.md` → graph-only; every task's file present (`S102-<slug>-<NNN>-*.md`, NNN the task's number) → full; some present, some not → graph-only, and G9 names the missing ones. In graph-only mode a check that needs the S102s is reported **not yet**, never Pass.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-validation` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 cannot be read either way, stop and report the path.

1. **The S101 definition** — the bar (§2), the contract mapping (§3.2), the graph rules (§4.3), the phases (§4.4), the checks (§8), the thresholds (§8.1):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

2. **The S101 template** — the frontmatter keys and the body sections a conforming plan has:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

3. **The specification contract**, `${CLAUDE_PLUGIN_ROOT}/contracts/specification.md`: the plan members check 1 looks for.

4. **The target S101**, whole: parse the frontmatter as YAML before anything else. **The design** it names: a D101's every R, NF and AC id in §3 and §8 and its §6 numbers, or the cache's every R, NF, AC and OOS item. **In full mode**, every S102 in the folder, whole; their headers carry `owns`, `consumes` and `produces`. **The repo**, for paths the contracts table links.

## Graph checklist

Run first, in this order, every time, from the frontmatter alone plus the design's id lists. Each row is answered by enumeration (list the ids, list the pairs, compare the sets), not by judgement, so two runs on an unchanged plan agree. Keep the enumeration to yourself; report the row.

| # | Item | Result rule |
|---|---|---|
| G1 | Frontmatter | Parses as YAML; every template key present (`spec`, `slug`, `title`, `design` with `ref` and `version` for a repo file or `read` + `cache` for a normalised design, `status`, `approved` (`none`, or `by`, `date` and `fingerprint`), `version`, `author`, `date`, `execution_mode`, `phases[]`); every phase carries `id`, `name`, `checkpoint`, `tasks[]`, and every slice carries `traces` (absent or empty on `P0` and on a close phase); every task carries `id`, `title`, `role`, `tier`, `after`, `traces`; `role` and `tier` hold one of the values the template's leading comment lists; task ids are `T001..` in order of appearance with no gap. A task carrying `owns`, `produces`, `consumes`, `file` or `phase` → **Flag** (the field belongs to the S102 header). Otherwise **Fail**. |
| G2 | No cycle | Follow `after` from every task; a task that reaches itself → **Fail**, naming the cycle. Every `after` id exists → else **Fail**. |
| G3 | Phases | `P0` is first and named `Foundation`; every phase holds at least one task; every phase after `P0` whose `traces` is non-empty (a slice) holds one tester task and at least one builder task, every builder task in it comes after the tester task (directly or transitively), and every task in it comes after a `P0` task; a phase after the last slice with empty `traces` (the close) holds at least one task that comes after a slice task. A builder beside or ahead of its tester, a slice with no tester, a slice task with no path from `P0` → **Fail**, naming it; a slice whose tester is a builder task that a §6 Assumptions row names as the slice's tester (no tester role for its stack) → **Flag**. |
| G4 | Parallel = disjoint | Full mode: for every pair of tasks where neither comes after the other, directly or transitively, the unions of their S102 `owns` lists intersect → **Fail**, naming the pair and the file. Graph-only: **not yet**, with the pairs that may run together listed in the sentence so the author can see them. |
| G5 | Contracts table | §1 has the template's four columns; every *Produced by* is a task id in the tree or *existing code* with a path that exists; every *Consumed by* is a task id in the tree; a task named as producer comes before every task named as consumer (the consumer's `after` reaches the producer). Otherwise **Fail**, naming the row. |
| G6 | Coverage both ways | Every requirement and criterion of the design (a D101's R, NF and AC in §3 and §8; a normalised design's R, NF and AC items; never OOS, which is a trace target only) appears in §3 with task ids or a stated reason (*verified by review*, *out of scope here, per OOSn*); every id in the map exists in the design; every task's `traces` is non-empty and each id exists in the design; every task id appears in the map; every phase's `traces` ids exist; for a normalised design, every map row has a non-empty *Says*. A miss → **Fail**, naming the id. |
| G7 | Sizes | Full mode: per task, count the S102's `owns.create` + `owns.modify`; above definition §8.1 → **Warn** with the task and the count. Graph-only: **not yet**. Never Fail. |
| G8 | Body | The body has §1–§6 in the template's order; every task id and phase id mentioned in the body exists in the tree; §6 Assumptions is present and non-empty; no code fence, no numbered step list, no test body; no paragraph that retells the tree (a phase described in prose, a task's dependencies or files listed) → **Flag**; a signature outside §1 → **Flag**; a §2 line that restates a convention rather than a departure from it → **Flag**. A missing section → **Fail**. |
| G9 | S102 files on disk | For every task, exactly one `S102-<slug>-<NNN>-*.md` with its number exists in the folder, and no `S102-*.md` in the folder carries a number outside the tree. In graph-only mode a missing file is expected: the row reads **not yet** and lists them. In full mode a missing file → **Fail**. In either mode an extra or a duplicate file → **Fail**, naming it (a leftover from a rewrite). |

## Cross-file checklist (full mode only)

| # | Item | Result rule |
|---|---|---|
| F2 | Header equals task line | Per S102: `task`, `title`, `role`, `tier`, `after`, `traces` equal its line in the tree (lists compared as sets). A difference → **Fail**, naming the task and the field. |
| F3 | Interface closure across headers | Every name in an S102's `consumes` is a row of §1 whose *Consumed by* names that task and whose *Produced by* is a task this one comes after or *existing code*; every name in an S102's `produces` is a row of §1 whose *Produced by* names that task. Otherwise **Fail**, naming the task and the name. |
| F4 | Constraints | No S102 §4 line contradicts a line of the S101 §2; no S102 §4 line restates one. A contradiction → **Fail**; a restatement → **Flag**. |
| F5 | S102 bars | Every S102 the tree names carries `status: validated` with a date in `validated` → **Pass**; one still `draft` → **Fail** naming the tasks (its blind check has not cleared, or a rewrite reset it). The mark is asimov-spec's record of the clean blind report; this skill never re-runs that check. |

**Name the source of a Fail.** When a plan defect cannot be fixed in the plan because the design does not settle it (a criterion with no observable outcome, so no checkpoint can name a test; a requirement no task can serve because the D101 or the ticket never says what would satisfy it), begin the sentence with `design:`. Everything else is the plan's or a task's. The caller stops on `design:` and routes the rest.

**Template findings.** A place where the plan visibly worked around a rule of the template or of this checklist (a task listed twice to satisfy a row, a phase named to pass G3 rather than to mean something, a field the template has no home for) is reported as one line under `template findings:` after the report, never as a Fail. The caller writes them to the sidecar for the maintainer.

## The ten checks

Then S101 definition §8, rows 1–10, one row each, in that order. Severities as in the S102 validation (Pass / Flag / Fail / Warn), plus **not yet** for a row that needs the S102s in graph-only mode.

| # | Row | Answered from | Graph-only |
|---|---|---|---|
| 1 | Completeness | Every plan member of `contracts/specification.md` present per definition §3.2 (Reference, Order, Coverage, Escalation; Contracts, Constraints, Assumptions present or an explicit *none*); plus G9 + F5 | partial: members yes, S102s not yet |
| 2 | Coverage both ways | G6 | yes |
| 3 | Graph validity | G2 + G3 + G4 | partial: G4 not yet |
| 4 | Stoppable phases | Each `checkpoint` names something a reviewer runs or sees without reading code (a test class by name, a build command, a command and its result); a checkpoint that reads "code exists" or "implemented" → Fail | yes |
| 5 | Interface closure | G5, and F3 in full mode | partial |
| 6 | Constraint consistency | §2 lines each carry a source and are the design's or a departure; F4 in full mode | partial |
| 7 | Review focus | Each §5 line names a condition, an expected behaviour and a task id that exists; an empty section is Pass with the sentence "stated as checked" | yes |
| 8 | Escalation | §4 names a route, the plan's own stops and the four human-always cases | yes |
| 9 | Separation | G8's code, step, test-body and narration parts; no `passes`, `claimed`, checkbox or fix note | yes |
| 10 | Model choice | Every `tier` is one of the template's values and follows definition §5: `low` only where the task is Foundation or a change the names and the check determine, `high` only where the body or the design names the judgement or integration it covers. The tier → model mapping is the toolkit's (`model-choice.md`), not the plan's, and is not checked here | yes |

## Report

Return exactly this, nothing before or after it (the template findings, when any, follow the block):

```
## Validation report
target: <S101 path>
bar: dispatch-ready
mode: graph-only | full
blind: false
| # | Check | Result | Reason |
|---|---|---|---|
| G1 | Frontmatter | Pass | … |
| … | … | … | … |
| G9 | S102 files on disk | not yet | No S102 exists; graph-only mode. |
| F2 | Header equals task line | Pass | … |          ← full mode only
| … | … | … | … |
| 1 | Completeness | not yet | Members present; no S102 exists. |
| … | … | … | … |
| 10 | Model choice | Pass | … |
```

One sentence per reason, naming the task, pair, file or id it is about, so the caller can route it (a G4 or F2 row goes to the tasks it names; a G6 row to the plan; a `design:` row stops the run) and print it as one line in words. No summary, no verdict, no fix. The caller keeps the rows for the sidecar; a person never reads the table.

## Never

- **Edit** or **propose a fix**. The caller routes a finding to the affected tasks (asimov-spec, R13) or prints it (asimov-spec-validate).
- **Judge whether the phases are sensible**, the cut too fine or too coarse, or the review focus the right five. That is the author's, at the cut.
- **Run inside the caller's conversation** when a subagent is available; the caller spawns you fresh and you read every file from disk. Your checks are not blind, but your output is not for the person.
- **Mark a row Pass in graph-only mode when it needs the S102s.** *not yet* is the honest value.
- **Re-run the S102 validation.** F5 reads the `validated` marks; it never produces them.
- **Render the plan** for a person; artifact-s101-view does.
- **Move a status**, or write the sidecar; the asimov-skills write `S101-<slug>.review.md`, you return text.

## Used by

- asimov-spec, step 03 (graph-only, before the cut is shown; a Fail is re-cut unseen) and step 07 (full, once every task is validated), each in a fresh validator subagent.
- asimov-spec-validate, in the mode the folder allows, after the per-S102 blind calls.
- By hand, on an S101 someone edited, before running asimov-spec-validate.
