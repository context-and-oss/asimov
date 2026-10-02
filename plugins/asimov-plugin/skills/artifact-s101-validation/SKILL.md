---
name: artifact-s101-validation
description: Validate an S101 implementation plan against its bar, dispatch-ready, in one of two modes — graph-only on the S101 alone (frontmatter parses, no cycle, no orphan, parallel tasks own disjoint files, every consumed name produced, coverage both ways against the D101, sizes), used at the cut before any S102 exists; or full with every S102 in the folder (the graph checks again, then interface closure across the task bodies, no contradicted global constraint, every S102 header equal to its graph entry) — then the ten checks of the S101 definition §8, one row each, Pass / Flag / Fail / Warn / not yet with one sentence. Use when asked to "validate this plan", "run the graph checks on the cut", "is this S101 dispatch-ready", or inside asimov-spec (steps 03 and 07) and asimov-spec-validate. Runs inline and read-only; it edits nothing, proposes no fix, moves no status.
---

# S101 validation

The check of the plan: does it clear its bar, and does it agree with itself and with its task specs. It runs inline, not in a subagent: its checks are cross-file and mechanical, not a blind property, and it needs every file open. The verdict stays the reviewer's; this skill answers rows.

## Modes

| Mode | When | Reads |
|---|---|---|
| **graph-only** | At the cut: the S101 exists and no S102 does. Also what a cut gets from asimov-spec-validate. | The S101 and the design. |
| **full** | Every task in the graph has its S102 on disk. | The S101, every S102 in the folder, the design. |

The design is what the S101 header's `design` block names: a repo file at `design.ref` (a D101), or the normalised cache at `design.cache` (`documentation/specs/<slug>/design.md`, in the shape the S101 definition §9 fixes). Read `${CLAUDE_PLUGIN_ROOT}/contracts/design.md` first; you check the design through its members.

The caller states the mode; absent that, the folder decides: no `S102-*.md` → graph-only; every `tasks[].file` present → full; some present, some not → graph-only, and G9 names the missing files. In graph-only mode a check that needs the S102s is reported **not yet**, never Pass.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-validation` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 cannot be read either way, stop and report the path.

1. **The S101 definition** — the bar (§2), the graph rules (§4.3), phase = slice (§4.4), the checks (§8), the thresholds (§8.1):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

2. **The S101 template** — the frontmatter keys and the body sections a conforming plan has:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

3. **The target S101**, whole: parse the frontmatter as YAML before anything else. **The design** it names: a D101's every R, NF and AC id in §3 and §8 and its §6 numbers, or the cache's every R, NF, AC and OOS item. **In full mode**, every S102 the graph names, whole. **The repo**, for paths the interfaces section links.

## Graph checklist

Run first, in this order, every time, from the frontmatter alone plus the design's id lists. Each row is answered by enumeration (list the ids, list the pairs, compare the sets), not by judgement, so two runs on an unchanged plan agree. Keep the enumeration to yourself; report the row.

| # | Item | Result rule |
|---|---|---|
| G1 | Frontmatter | Parses as YAML; every template key present (`spec`, `slug`, `title`, `design.ref` with `version` for a repo file or `read` + `cache` for a normalised design, `status`, `version`, `author`, `date`, `execution_mode`, `phases[]`, `tasks[]`); every phase carries `id`, `name`, `traces`, `checkpoint`; every task carries `id`, `file`, `title`, `role`, `tier`, `phase`, `depends_on`, `owns` (a map with `create`, `modify`, `test` lists), `produces`, `consumes`, `traces`; `role` and `tier` hold one of the values the template's leading comment lists; `file` matches `S102-<slug>-<NNN>-*.md` with NNN = the id's number. Otherwise **Fail**. |
| G2 | No cycle | Follow `depends_on` from every task; a task that reaches itself → **Fail**, naming the cycle. |
| G3 | No orphan | Every `depends_on` id exists; every task's `phase` exists; every phase has at least one task; `P0` is named `Foundation` and holds one task per stack the plan touches; every slice phase (`P1..`) holds at least one builder task and one tester task, and every task in it depends on a `P0` task. A missing id or phase, or a slice phase with no tester task → **Fail**, naming it; a slice phase whose tester is a builder task that a §7 Assumptions row names as the slice's tester (no tester role for its stack), or a `P0` without a stack's skeleton → **Flag**. |
| G4 | Parallel = disjoint | For every pair of tasks where neither depends on the other, directly or transitively: the unions of their `owns` lists intersect → **Fail**, naming the pair and the file. |
| G5 | Consumed names produced | Every name in a task's `consumes` is in the `produces` of a task it depends on (directly or transitively), or is linked by path in the body's §3 to a file that exists. Otherwise **Fail**, naming it. |
| G6 | Coverage both ways | Every requirement and criterion of the design (a D101's R, NF and AC in §3 and §8; a normalised design's R, NF and AC items; never OOS, which is a trace target only) appears in the body's §6 coverage map with task ids or *verified by review*; every id in the map exists in the design; every task's `traces` is non-empty and each id exists in the design; every task id appears in the map; for a normalised design, every map row has a non-empty *Says*. A miss → **Fail**, naming the id. |
| G7 | Sizes | Per task, count `owns.create` + `owns.modify`; above definition §8.1 → **Warn** with the task and the count. Never Fail. |
| G8 | Body by id | The body has §1–§7 in the template's order; every task id and phase id mentioned in the body exists in the frontmatter; §7 Assumptions is present and non-empty; no body section repeats a frontmatter field as a list (owned files, dependencies). Otherwise **Fail** or, for a repeated field, **Flag**. |
| G9 | S102 files on disk | Every `tasks[].file` exists in the folder, and no `S102-*.md` in the folder is outside the graph. In graph-only mode a missing file is expected: the row reads **not yet** and lists them. In full mode a missing file → **Fail**. In either mode an extra file → **Fail**, naming it (a leftover from a rewrite). |

## Cross-file checklist (full mode only)

| # | Item | Result rule |
|---|---|---|
| F2 | Header equals graph | Per S102: `task`, `role`, `tier`, `depends_on`, `traces` equal its graph entry (lists compared as sets); its §2 Create, Modify and Test lists equal `owns.create`, `owns.modify` and `owns.test`. A difference → **Fail**, naming the task and the field. |
| F3 | Interface closure across bodies | Every name under an S102's §3 Consumes appears under the §3 Produces of an S102 it depends on, with the same signature, or is linked by path to code that exists. Otherwise **Fail**, naming the task and the name. |
| F4 | Constraints | No S102 §5 line contradicts a line of the S101 §1; no S102 §5 line restates one. A contradiction → **Fail**; a restatement → **Flag**. |
| F5 | S102 bars | If the caller passed the S102 validation reports, every report has no Fail row → **Pass**, else **Fail** naming the tasks. If none were passed, the row reads **not yet** with the sentence that asimov-spec-validate produces them. |

**Name the source of a Fail.** When a plan defect cannot be fixed in the plan because the design does not settle it (a criterion with no observable outcome, so no checkpoint can name a test; a requirement no task can serve because the D101 or the ticket never says what would satisfy it), begin the sentence with `design:`. Everything else is the plan's or a task's. The caller stops on `design:` and routes the rest.

## The ten checks

Then S101 definition §8, rows 1–10, one row each, in that order. Severities as in the S102 validation (Pass / Flag / Fail / Warn), plus **not yet** for a row that needs the S102s in graph-only mode.

| # | Row | Answered from | Graph-only |
|---|---|---|---|
| 1 | Completeness | G9 + F5 | not yet |
| 2 | Coverage both ways | G6 | yes |
| 3 | Graph validity | G2 + G4 | yes |
| 4 | Stoppable phases | Each `phases[].checkpoint` names something a reviewer runs or sees without reading code (a test by name, a build, a page); a checkpoint that reads "code exists" or "implemented" → Fail | yes |
| 5 | Interface closure | G5, and F3 in full mode | partial: G5 only, say so |
| 6 | Constraint consistency | §1 lines each carry a source; F4 in full mode | partial |
| 7 | Review focus | Each §4 line names a condition, an expected behaviour and a task id that exists; an empty section is Pass with the sentence "stated as checked" | yes |
| 8 | Escalation | §5 names a route and the four human-always cases | yes |
| 9 | Separation | No code fence, no numbered step list, no test body in the S101; no `passes`, `claimed`, checkbox or fix note | yes |
| 10 | Model choice | Every `tier` is one of the template's values and follows the rule in definition §5: `low` only where the task is a skeleton or the body calls it transcription, `high` only where the body names the judgement or integration it covers. The tier → model mapping is the toolkit's (`model-choice.md`), not the plan's, and is not checked here | yes |

## Report

Return exactly this, nothing before or after it:

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
| G8 | Body by id | Pass | … |
| G9 | S102 files on disk | not yet | No S102 exists; graph-only mode. |
| F2 | Header equals graph | Pass | … |          ← full mode only
| … | … | … | … |
| 1 | Completeness | not yet | No S102 exists; graph-only mode. |
| … | … | … | … |
| 10 | Model choice | Pass | … |
```

One sentence per reason, naming the task, pair, file or id it is about, so the caller can route it (a G4 or F2 row goes to the tasks it names; a G6 row to the plan; a `design:` row stops the run). No summary, no verdict, no fix. The caller counts the rows and prints them as the graph checks under the cut.

## Never

- **Edit** or **propose a fix**. The caller routes a finding to the affected tasks (asimov-spec, R13) or prints it (asimov-spec-validate).
- **Judge whether the phases are sensible**, the cut too fine or too coarse, or the review focus the right five. That is the reviewer's.
- **Run in a subagent.** It needs every file open and its checks are not a blind property.
- **Mark a row Pass in graph-only mode when it needs the S102s.** *not yet* is the honest value.
- **Re-run the S102 validation.** F5 consumes reports; it never produces them.
- **Move a status**, or write the sidecar; the asimov-skills write `S101-<slug>.review.md`, you return text.

## Used by

- asimov-spec, step 03 (graph-only, under the cut) and step 07 (full, once every task exists).
- asimov-spec-validate, in the mode the folder allows, after the per-S102 blind calls.
- By hand, on an S101 someone edited, before asking a reviewer.
