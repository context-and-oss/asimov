---
name: artifact-s101-validation
description: Validate an S101 implementation plan against its bar, dispatch-ready, in one of two modes — graph-only on the S101 alone (frontmatter parses, no cycle, no orphan, parallel tasks own disjoint files, every consumed name produced, coverage both ways against the D101, sizes), used at the cut before any S102 exists; or full with every S102 in the folder (the graph checks again, then interface closure across the task bodies, no contradicted global constraint, every S102 header equal to its graph entry) — then the ten checks of the S101 definition §8, one row each, Pass / Flag / Fail / Warn / not yet with one sentence. Use when asked to "validate this plan", "run the graph checks on the cut", "is this S101 dispatch-ready", or inside asimov-spec (steps 03 and 07) and asimov-spec-validate. Runs inline and read-only; it edits nothing, proposes no fix, moves no status.
---

# S101 validation

The check of the plan: does it clear its bar, and does it agree with itself and with its task specs. It runs inline, not in a subagent: its checks are cross-file and mechanical, not a blind property, and it needs every file open. The verdict stays the reviewer's; this skill answers rows.

## Modes

| Mode | When | Reads |
|---|---|---|
| **graph-only** | At the cut: the S101 exists and no S102 does. Also what a cut gets from asimov-spec-validate. | The S101 and the D101. |
| **full** | Every task in the graph has its S102 on disk. | The S101, every S102 in the folder, the D101. |

The caller states the mode; absent that, the folder decides: no `S102-*.md` → graph-only; every `tasks[].file` present → full; some present, some not → graph-only, with a row naming the missing files. In graph-only mode a check that needs the S102s is reported **not yet**, never Pass.

## Read first

Load with the file-read tool. `${CLAUDE_PLUGIN_ROOT}` is the plugin root; where the harness does not set it, resolve the same paths relative to this skill's folder (`../../artifacts/...`). If 1 cannot be read, stop and report the path.

1. **The S101 definition** — the bar (§2), the graph rules (§4.3), phase = slice (§4.4), the checks (§8), the thresholds (§8.1):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

2. **The S101 template** — the frontmatter keys and the body sections a conforming plan has:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

3. **The target S101**, whole: parse the frontmatter as YAML before anything else. **The D101** it names: every R, NF and AC id in §3 and §8, and the §6 numbers. **In full mode**, every S102 the graph names, whole. **The repo**, for paths the interfaces section links.

## Graph checklist

Run first, in this order, every time, from the frontmatter alone plus the D101's id lists. Each row is answered by enumeration (list the ids, list the pairs, compare the sets), not by judgement, so two runs on an unchanged plan agree. Keep the enumeration to yourself; report the row.

| # | Item | Result rule |
|---|---|---|
| G1 | Frontmatter | Parses as YAML; every template key present (`spec`, `slug`, `title`, `d101.path`, `d101.version`, `status`, `version`, `author`, `date`, `execution_mode`, `phases[]`, `tasks[]`); every task carries `id`, `file`, `title`, `role`, `tier`, `phase`, `depends_on`, `owns`, `produces`, `consumes`, `traces`; `role` and `tier` hold allowed values; `file` matches `S102-<slug>-<NNN>-*.md` with NNN = the id's number. Otherwise **Fail**. |
| G2 | No cycle | Follow `depends_on` from every task; a task that reaches itself → **Fail**, naming the cycle. |
| G3 | No orphan | Every `depends_on` id exists; every task's `phase` exists; every phase has at least one task; `P0` is named `Foundation` and holds one task per stack the plan touches; every slice phase (`P1..`) holds at least one builder task and one tester task, and every task in it depends on a `P0` task. A miss → **Fail** (missing id or phase) or **Flag** (a slice phase without a tester task, a `P0` without a stack's skeleton), naming it. |
| G4 | Parallel = disjoint | For every pair of tasks where neither depends on the other, directly or transitively: `owns` sets intersect → **Fail**, naming the pair and the file. |
| G5 | Consumed names produced | Every name in a task's `consumes` is in the `produces` of a task it depends on (directly or transitively), or is linked by path in the body's §3 to a file that exists. Otherwise **Fail**, naming it. |
| G6 | Coverage both ways | Every R, NF and AC id in the D101's §3 and §8 appears in the body's §6 coverage map with task ids or *verified by review*; every id in the map exists in the D101; every task's `traces` is non-empty and each id exists in the D101; every task id appears in the map. A miss → **Fail**, naming the id. |
| G7 | Sizes | Per task, count `owns` entries that are not test files; above definition §8.1 → **Warn** with the task and the count. Never Fail. |
| G8 | Body by id | The body has §1–§7 in the template's order; every task id and phase id mentioned in the body exists in the frontmatter; §7 Assumptions is present and non-empty; no body section repeats a frontmatter field as a list (owned files, dependencies). Otherwise **Fail** or, for a repeated field, **Flag**. |

## Cross-file checklist (full mode only)

| # | Item | Result rule |
|---|---|---|
| F1 | Every S102 present | Every `tasks[].file` exists in the folder; no `S102-*.md` in the folder is outside the graph. A missing file → **Fail**; an extra file → **Fail**, naming it (an orphan from a rewrite the caller did not delete). |
| F2 | Header equals graph | Per S102: `task`, `role`, `tier`, `depends_on`, `traces` equal its graph entry (lists compared as sets); its §2 paths equal `owns`. A difference → **Fail**, naming the task and the field. |
| F3 | Interface closure across bodies | Every name under an S102's §3 Consumes appears under the §3 Produces of an S102 it depends on, with the same signature, or is linked by path to code that exists. Otherwise **Fail**, naming the task and the name. |
| F4 | Constraints | No S102 §5 line contradicts a line of the S101 §1; no S102 §5 line restates one. A contradiction → **Fail**; a restatement → **Flag**. |
| F5 | S102 bars | If the caller passed the S102 validation reports, every report has no Fail row → **Pass**, else **Fail** naming the tasks. If none were passed, the row reads **not checked here** and names asimov-spec-validate as the way to get them. |

## The ten checks

Then S101 definition §8, rows 1–10, one row each, in that order. Severities as in the S102 validation (Pass / Flag / Fail / Warn), plus **not yet** for a row that needs the S102s in graph-only mode.

| # | Row | Answered from | Graph-only |
|---|---|---|---|
| 1 | Completeness | F1 + F5 | not yet |
| 2 | Coverage both ways | G6 | yes |
| 3 | Graph validity | G2 + G4 | yes |
| 4 | Stoppable phases | Each `phases[].checkpoint` names something a reviewer runs or sees without reading code (a test by name, a build, a page); a checkpoint that reads "code exists" or "implemented" → Fail | yes |
| 5 | Interface closure | G5, and F3 in full mode | partial: G5 only, say so |
| 6 | Constraint consistency | §1 lines each carry a source; F4 in full mode | partial |
| 7 | Review focus | Each §4 line names a condition, an expected behaviour and a task id that exists; an empty section is Pass with the sentence "stated as checked" | yes |
| 8 | Escalation | §5 names a route and the four human-always cases | yes |
| 9 | Separation | No code fence, no numbered step list, no test body in the S101; no `passes`, `claimed`, checkbox or fix note | yes |
| 10 | Model choice | Every `tier` is an allowed value and `low` is used only where the task is a skeleton or the body calls it transcription; `model-choice.md` in the plugin's documentation maps the tiers | yes |

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
| F1 | Every S102 present | Pass | … |          ← full mode only
| … | … | … | … |
| 1 | Completeness | not yet | No S102 exists; graph-only mode. |
| … | … | … | … |
| 10 | Model choice | Pass | … |
```

One sentence per reason, naming the task, pair, file or id it is about, so the caller can route it (a G4 or F2 row goes to the two tasks it names; a G6 row to the plan). No summary, no verdict, no fix. The caller counts the rows and prints them as the graph checks under the cut.

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
