---
name: artifact-s101-validation
description: Validate an S101 implementation plan against its bar, dispatch-ready, in one of two modes — graph-only on the S101 alone (frontmatter parses as the phase tree, no cycle, tester before builder in every slice, every slice task after the Foundation where the plan has one, contracts table consistent, coverage both ways against the design), used at the cut before any S102 exists; or full with every S102 in the folder (the graph checks again, then disjoint owned sets and interface closure from the S102 headers, no contradicted constraint, every S102 header equal to its task line) — then the ten checks of the S101 definition §8, one row each, Pass / Flag / Fail / Warn / not yet with one sentence. Use when asked to "validate this plan", "run the graph checks on the cut", "is this S101 dispatch-ready", or inside asimov-spec (steps 03 and 07, and the re-check of a ready plan). Its method is the script scripts/validate-s101.ps1, run inline through Bash; the checklist here is the script's specification and the fallback where no PowerShell exists. It edits nothing, proposes no fix, moves no status.
---

# S101 validation

The check of the plan: does it clear its bar, and does it agree with itself and with its task specs. Its checks are cross-file and mechanical, a schema check across several files: every row is answered by enumeration (list the ids, list the pairs, compare the sets), never by judgement. The verdict stays the author's; this skill answers rows. **It runs nothing**: no build, no test; it looks a thing up (an id in the design, a path on disk, a package in a project file, a file in the folder). **It opens nothing the plan or a task spec does not name.**

**The check is a script.** Every row below is implemented, row for row, in `scripts/validate-s101.ps1`, and the caller runs it inline through Bash; no subagent is spawned for it. The checklist stays here as the script's specification and as the fallback where no PowerShell exists. Two LLM validators per run on Opus cost a developer's two-task run 120k tokens and gave different answers on unchanged text; the script answers in a second and the same way twice.

## The call

```
pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/scripts/validate-s101.ps1" -S101 <S101 path> [-Mode graph-only | full] [-Design <design path>]
```

`pwsh` (PowerShell 7) or `powershell` (Windows PowerShell 5.1; add `-ExecutionPolicy Bypass`), whichever the machine has; the script runs on both. The working directory is the product repo root; `-PluginRoot <plugin-root>` in Codex, where the variable is not substituted. Without `-Mode` the folder decides (full when every task's S102 is on disk). Without `-Design` the script reads the S101's `design` line: the cache when there is one, else the ref when it is a file in the repo.

**Return the script's output verbatim** and nothing else. Exit code 2 means an input could not be read; the one line it prints says which, and that line is the report. **Never** "correct" a row, add a row, or soften one.

**Where no PowerShell is installed**, say so in one line, then answer the checklist below by hand in a fresh read-only subagent on the validation model (`model-choice.md` §1.2), on the same closed read list, and return the report with `engine: llm` in place of `engine: script`; the caller records the run as one to re-check from a machine with the script.

## Modes

| Mode | When | Reads |
|---|---|---|
| **graph-only** | At the cut: the S101 exists and no S102 does. Also what a cut gets on a re-check. | The S101 and the design. |
| **full** | Every task in the tree has its S102 on disk. | The S101, every S102 in the folder, the design. |

The design is what the S101 header's `design` line names: a repo file at `design.ref` (a D101), or the normalised cache at `design.cache` (`documentation/specs/<slug>/design.md`, in the shape the S101 definition §9 fixes). Read `${CLAUDE_PLUGIN_ROOT}/contracts/design.md` first; you check the design through its members.

The caller states the mode; absent that, the folder decides: no `S102-*.md` → graph-only; every task's file present (`S102-<slug>-<NNN>-*.md`, NNN the task's number) → full; some present, some not → graph-only, and G9 names the missing ones. In graph-only mode a check that needs the S102s is reported **not yet**, never Pass.

**Full mode re-answers every graph row.** The script costs a second, so nothing is carried from the graph-only pass and no `graph_passed` input exists any more; a report is always the whole table against the files as they are.

## Read first (the fallback; the script reads the same and nothing else)

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-validation` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 cannot be read either way, stop and report the path.

1. **The S101 definition, §8.1 only** — the thresholds block (search for `thresholds:`); the rest of the definition is rationale this checklist already carries:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-definition.md
   ```

2. **The S101 template** — the frontmatter keys, the role and tier values in its leading comment, and the body sections a conforming plan has (the template is the schema):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

3. **The target S101**, whole: parse the frontmatter as YAML before anything else. **The design** it names: a D101's every R, NF and AC id in §3 and §8 and its §6 numbers, or the cache's every R, NF, AC and OOS item. **In full mode**, every S102 in the folder, whole; their headers carry `owns`, `consumes` and `produces`. **The repo**, for paths the contracts table links. **`repo-notes.md`** beside the S101, when present, only as a map of where a name or a package reference lives; every row is answered against the code on disk.

## Graph checklist

Run first, in this order, every time, from the frontmatter alone plus the design's id lists. Each row is answered by enumeration (list the ids, list the pairs, compare the sets), not by judgement, so two runs on an unchanged plan agree. Keep the enumeration to yourself; report the row.

| # | Item | Result rule |
|---|---|---|
| G1 | Frontmatter | Parses as YAML; every template key present (`spec`, `slug`, `title`, `design` with `ref` and `version` for a repo file or `read` + `cache` + `approval` (`verified` or `unverified`) for a normalised design, `status`, `approved` (`none`, or `by`, `date` and `fingerprint`), `version`, `author`, `date`, `phases[]`); every phase carries `id`, `name`, `checkpoint`, `check`, `tasks[]`, and every slice carries `traces` (absent or empty on `P0` and on a close phase); every task carries `id`, `title`, `role`, `tier`, `after`, `traces`; `role` and `tier` hold one of the values the template's leading comment lists; task ids are `T001..` in order of appearance with no gap. A task carrying `owns`, `produces`, `consumes`, `file` or `phase` → **Flag** (the field belongs to the S102 header); a `title` longer than 60 characters, or a phase `name` longer than 40 → **Flag**, naming it (the view is read at a glance; the sentence belongs in the S102's intent); a normalised design's line without `approval` → **Flag**. Otherwise **Fail**. |
| G2 | No cycle | Follow `after` from every task; a task that reaches itself → **Fail**, naming the cycle. Every `after` id exists → else **Fail**. |
| G3 | Phases | `P0`, when present, is first and named `Foundation`; a plan whose first phase is a slice has no `P0`, and that is not a defect (definition §4.4: the Foundation exists when the plan needs one; whether it was needed is the author's judgement, not this row's). Every phase holds at least one task; every phase whose `traces` is non-empty (a slice) holds one tester task and at least one builder task, every builder task in it comes after the tester task (directly or transitively), and, when `P0` exists, every task in it comes after a `P0` task; a phase after the last slice with empty `traces` (the close) holds at least one task that comes after a slice task. A builder beside or ahead of its tester, a slice with no tester, a slice task with no path from an existing `P0` → **Fail**, naming it; a slice whose tester is a builder task that a §6 Assumptions row names as the slice's tester (no tester role for its stack) → **Flag**; a slice's tester that comes after an earlier slice's builder is a sequencing the plan chose: **Pass** when a §6 row names the shared file, **Flag** naming the pair when none does. |
| G4 | Parallel = disjoint | Full mode: for every pair of tasks where neither comes after the other, directly or transitively, the unions of their S102 `owns.create`, `owns.modify` and `owns.test` lists intersect (a glob is expanded against the repo, or matched pattern to pattern where both are globs) → **Flag**, naming the pair and the file: the Build stage serialises the pair, so parallelism is lost and nothing is wrong; `owns.regenerates` takes no part (two tasks may regenerate the same lock file). Graph-only: **not yet**, with the pairs that may run together listed in the sentence so the author can see them. |
| G5 | Contracts table | §1 has the template's three columns (Name, Shape, Produced by), or reads *none*; every *Produced by* is a task id in the tree. Otherwise **Fail**, naming the row. A fourth *Consumed by* column → **Flag** naming it (the column is no longer read; the S102 headers are the home of consumption) and is otherwise ignored. A row whose *Produced by* reads *existing code* → **Flag**, naming it: existing code belongs in the S102 header, never in §1, and the plan stays valid. A row whose *Shape* is a test name → **Flag**: a test name is not a contract. |
| G6 | Coverage both ways | Every requirement and criterion of the design (a D101's R, NF and AC in §3 and §8; a normalised design's R, NF and AC items; never OOS, which is a trace target only) appears in §3 with task ids or a stated reason (*verified by review*, *out of scope here, per OOSn*); every id in the map exists in the design; every task's `traces` is non-empty and each id exists in the design; every task id appears in the map; every phase's `traces` ids exist; for a normalised design, every map row has a non-empty *Says*. A miss → **Fail**, naming the id. |
| G7 | Sizes | Full mode: per task, count the S102's `owns.create` + `owns.modify` (`owns.regenerates` never counts); above definition §8.1 → **Warn** with the task and the count. Graph-only: **not yet**. Never Fail. |
| G8 | Body | The body has §1–§6 in the template's order; every task id and phase id mentioned in the body exists in the tree; §6 Assumptions is present and non-empty; no code fence, no numbered step list, no test body; no paragraph that retells the tree (a phase described in prose, a task's dependencies or files listed) → **Flag**; a signature outside §1 → **Flag**; a §2 line that restates a convention rather than a departure from it → **Flag**. A missing section → **Fail**. |
| G9 | S102 files on disk | For every task, exactly one `S102-<slug>-<NNN>-*.md` with its number exists in the folder, and no `S102-*.md` in the folder carries a number outside the tree. In graph-only mode a missing file is expected: the row reads **not yet** and lists them. In full mode a missing file → **Fail**. In either mode an extra or a duplicate file → **Fail**, naming it (a leftover from a rewrite). |

## Cross-file checklist (full mode only)

| # | Item | Result rule |
|---|---|---|
| F2 | Header equals task line | Per S102: `task`, `title`, `role`, `tier`, `after`, `traces` equal its line in the tree (lists compared as sets). A difference → **Fail**, naming the task and the field. |
| F3 | Interface closure across headers | Every entry in an S102's `consumes` is one of three: a row of §1 whose *Produced by* is a task this one comes after (no column records the consumer; the header is the record); existing code in the form `<Name> (<repo-relative path>)` whose path exists on disk (the blind check verified the member; here the path suffices); or a package type in the form `<Name> (package <PackageId>)` where **any** project file in the repo references that package (a `PackageReference` or `PackageVersion` with that id, or a `package.json` entry); the owned project need not reference it directly, since a test project reaches most packages through a project reference, and this is the lookup `scripts/validate-s102.ps1` makes. Every name in an S102's `produces` is a row of §1 whose *Produced by* names that task. Otherwise **Fail**, naming the task and the name. |
| F4 | Constraints | Line against line, on subject and value, as the S102 validation's row 10: an S102 §4 line that requires what an S101 §2 line forbids on the same subject (the same abstraction, layer, dependency, value or file), or the reverse → **Fail**, quoting both; a §4 line whose subject and value are a §2 line's with nothing added for the task → **Flag**, quoting both; a line that narrows a §2 line to its task, or that shares words but not subject and value → no finding. |
| F5 | S102 bars | Every S102 the tree names carries `status: validated` with a date in `validated` → **Pass**; one still `draft` → **Fail** naming the tasks (its blind check has not cleared, or a rewrite reset it). The mark is asimov-spec's record of the clean blind report; this skill never re-runs that check. |

**Name the source of a Fail.** When a plan defect cannot be fixed in the plan because the design does not settle it (a criterion with no observable outcome, so no checkpoint can name a test; a requirement no task can serve because the D101 or the ticket never says what would satisfy it), begin the sentence with `design:`. Everything else is the plan's or a task's. The caller stops on `design:` and routes the rest.

**Template findings.** A place where the plan visibly worked around a rule of the template or of this checklist (a task listed twice to satisfy a row, a phase named to pass G3 rather than to mean something, a field the template has no home for) is reported as one line under `template findings:` after the report, never as a Fail. The caller writes them to the sidecar for the maintainer.

## The ten checks

Then S101 definition §8, rows 1–10, one row each, in that order. Severities as in the S102 validation (Pass / Flag / Fail / Warn), plus **not yet** for a row that needs the S102s in graph-only mode.

| # | Row | Answered from | Graph-only |
|---|---|---|---|
| 1 | Completeness | Every plan member present as definition §3.2 maps it (the `design` line and first paragraph; the tree with `after`, `checkpoint`, `check`; §3; §4; §1, §2 and §6 present or an explicit *none*); plus G9 + F5 | partial: members yes, S102s not yet |
| 2 | Coverage both ways | G6 | yes |
| 3 | Graph validity | G2 + G3 + G4 | partial: G4 not yet |
| 4 | Stoppable phases | Each phase's `checkpoint` is one sentence a person reads (what is true when the phase is done) that carries no command token: no backtick, no `dotnet`, `npm`, `ng`, `--` or a path; and its `check` names something a reviewer runs without reading code (a test command filtered to a class, a build command, a command and its expected result) and is not a search of the source (`grep`, `rg`, `Select-String`, `findstr`), the same rule as a done-when. A `check` with no runnable form or that searches the source, or a `checkpoint` that reads "code exists" or "implemented" → Fail; a command inside `checkpoint` → Flag (it belongs in `check`; the builder is not stopped by it) | yes |
| 5 | Interface closure | G5, and F3 in full mode | partial |
| 6 | Constraint consistency | §2 lines each carry a source and are the design's or a departure; F4 in full mode | partial |
| 7 | Review focus | Each §5 line names a condition, an expected behaviour (`condition → behaviour`) and a task id that exists; a line pinned to a slice's builder while the slice has a tester → Flag (the tester carries the scenario, definition §4.6); an empty section is Pass with the sentence "stated as checked" | yes |
| 8 | Escalation | §4 names a route, the plan's own stops and the four human-always cases | yes |
| 9 | Separation | G8's code, step, test-body and narration parts; no `passes`, `claimed`, checkbox or fix note. A header field an S102 copies from its task line (title, role, tier, after, traces) is the form, never a restatement | yes |
| 10 | Model choice | Every `tier` is one of the template's three values; a `low` tier on a task whose S102 §2 holds a `Scenario:` (behaviour in prose is `mid` by definition §5) → Flag in full mode. Whether a tier is the right call is the author's; the tier → model mapping is the toolkit's (`model-choice.md`), not the plan's, and is not checked here | yes |

## Report

Return exactly this, nothing before or after it (the template findings, when any, follow the block):

```
## Validation report
target: <S101 path>
bar: dispatch-ready
mode: graph-only | full
blind: false
engine: script (validate-s101.ps1) | llm
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

- **Run anything that executes code**, or **open a file the plan or a task spec does not name**. A build is the verifier's; the code's logic is the reviewer's.
- **Edit** or **propose a fix**. The caller routes a finding to the affected tasks (asimov-spec, R13) or prints it (the re-check).
- **Judge whether the phases are sensible**, whether a Foundation was needed or missed, the cut too fine or too coarse, or the review focus the right five. That is the author's, at the cut.
- **Flag an impression.** A Flag names what would change; a sentence with nothing to change is a Pass with that sentence. Flags go to the sidecar, not to a person.
- **Answer the checklist by hand when the script can run.** The script is the method; the checklist is its specification and the fallback. An LLM reading of these rows is recorded as `engine: llm` and re-checked from a machine with PowerShell.
- **Mark a row Pass in graph-only mode when it needs the S102s.** *not yet* is the honest value.
- **Fail what would stop no builder.** A long title, a command inside a checkpoint sentence, a restated constraint are Flags.
- **Re-run the S102 validation.** F5 reads the `validated` marks; it never produces them.
- **Render the plan** for a person; artifact-s101-view does.
- **Move a status**, or write the sidecar; the asimov-skills write `S101-<slug>.review.md`, you return text.

## Used by

- asimov-spec, step 03 (graph-only, before the cut is shown; a Fail is re-cut unseen) and step 07 (full, once every task is validated), the script run inline through Bash.
- asimov-spec in mode recheck, after the per-S102 script calls.
- By hand, on an S101 someone edited, before running asimov-spec again.
