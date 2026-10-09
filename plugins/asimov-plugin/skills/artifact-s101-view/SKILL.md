---
name: artifact-s101-view
description: Render one S101 implementation plan (documentation/specs/<slug>/S101-<slug>.md) as the fixed plan view a person reads in chat — the phase tree with its checkpoints and one line per task, the coverage line, the assumptions line, the design gaps — in the language of the conversation. Use when a person must see a plan: the cut and the end of a run inside asimov-spec, the re-check of a ready plan, a run's position inside asimov-build, or when asked to "show me the plan", "what does the cut look like". Reads the S101 and, when present, the S102 headers; prints text; writes nothing and judges nothing.
---

# S101 view

The S101 file is written for agents; a person sees the plan through this view. One layout, every time, so a reader learns it once. The view says nothing about the plan that is not in the files, and it carries no verdict: the caller prints the validation rows under it if it has them.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-s101-view` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/s101-implementation-plan-template.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2).

1. **The S101 template** — the frontmatter keys and the body sections you read:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/s101-implementation-plan/s101-implementation-plan-template.md
   ```

2. **The target S101**, whole; parse the frontmatter as YAML. **The S102 headers** in the same folder, when any exist (`S102-<slug>-NNN-*.md`), for the task count that is written.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `s101` | Path of the plan. Required. |
| `heading` | One line printed above the view, the caller's framing: *The cut*, *The plan, as written*, *The plan, for review*. [none] |
| `language` | The language of the labels. [the language the conversation is in] |

## The view

Print exactly this layout, in a fenced block so the columns hold. Labels (*Plan for*, *phases*, *tasks*, *Constraints*, *Coverage*, *Assumptions*, *corrected at the cut*, *design gap*) in the caller's language; titles, names and checkpoint sentences as the file has them. The rule in the horizontal line is as wide as the widest line, never wider than 80 characters: a terminal wraps anything longer, and the view is read in ten seconds. The plan is written to fit (short titles, a one-sentence checkpoint, one-line constraints); a line that does not fit is printed as it is, not reworded, and is the plan's defect to report, not yours to hide.

```
<heading, when given>
Plan for <slug> · <title>
<design, short> · approved by <who> <date> · <n> phases, <m> tasks<, k task specs written, v validated> · <status> v<version> · <plan approved by <by> <date> | plan not approved>
──────────────────────────────────────────────────────────────────────
P0  <phase name>                                           <phase traces>
    ✓ <checkpoint>
    ├─ T001  <role>  <tier>  <title>
    ├─ T002  <role>  <tier>  <title>
    └─ T003  <role>  <tier>  <title>
──────────────────────────────────────────────────────────────────────
P1  <phase name>                                           <phase traces>
    ✓ <checkpoint>
    ├─ T004  <role>  <tier>  <title>
    └─ T005  <role>  <tier>  <title>
──────────────────────────────────────────────────────────────────────
Constraints  <each §2 line, verbatim, one per line; "none" when the section is empty>
Coverage     <what the coverage map says, one line>
Assumptions  <k>, of which <c> corrected at the cut
design gap   <the Taken cell of every assumption that begins design:, one line each; omit the line when none>
```

Rules of the rendering:

- **Task specs written** appears only when at least one `S102-<slug>-NNN-*.md` exists in the folder: `k` is the number of tasks in the tree with exactly one file, `v` the number of those whose header says `status: validated`.
- **Plan approved by** comes from the header's `approved` line: the name and date when it holds them, *plan not approved* when it is `none` or absent. The view does not check the fingerprint; the caller says whether the approval still holds.
- **Design, short.** For a repo file: the file name and version (`D101-permissions.html v0.11`). For a normalised design: the key or the last path segment of the url and the read time (`SEC-1733, read 2026-10-05`). *Approved by* comes from the body's first paragraph; omit it when the body does not name one. When the header's `design` line says `approval: unverified`, the approval reads `approved by <who> <date> (unverified: pasted text)`, so the person sees that nobody checked it.
- **Phases** in the order of the tree, each with its id, name and traces (phase `traces` as the file has them, right-aligned; nothing when empty). The `checkpoint` sentence on its own line under the name, prefixed `✓`, verbatim; never the `check` command, which is the verifier's. Tasks in the order of the tree with `├─` and `└─` on the last.
- **Role** is the role without its stack prefix (`builder`, `tester`, `human`) when every task of the plan is of one stack; with the stack (`dotnet builder`, `angular builder`) when the plan has more than one. Pad role and tier so the titles align.
- **Title** verbatim from the task line. Never add the dependencies, the files or the traces of a task: the order top to bottom is the order, and the rest is the agent's.
- **Constraints** prints every line of §2 as written, because the author approves them with the go: the approval's fingerprint covers the tree, §2, §3 and §6, and the view shows exactly those parts (definition §6). The first line carries the label; the rest are indented under it.
- **Coverage** is one line from §3: the acceptance criteria delivered (`AC1–AC5 delivered`), then every id whose *Delivered by* is not a task list, with its reason as written (`R1–R4 Frontend, per OOS1`, `AC6 verified by review`). Collapse consecutive ids into a range.
- **Assumptions** counts the rows of §6 and the ones whose *How* is `corrected at the cut`. Every row whose *Taken* begins `design:` is printed in full on its own `design gap` line, because the author must see it before saying go.
- **Nothing else.** No validation rows, no verdict, no file sizes, no commentary. The caller adds what it has under the block.

Return the block as chat text and nothing before or after it.

## Never

- **Write** a file, or change one.
- **Judge** the plan, mark a row, or add a finding. A gap in the tree (a phase without a task, an id that repeats) is printed as the file has it; the validation skill reports it.
- **Invent** a label or a column. The layout is fixed; a plan that does not fit it is a finding for the maintainer, not a reason to improvise.
- **Print the frontmatter** or any YAML. The person never reads the file's form.
- **Print a phase's `check`**, a file list, or the repo notes. The person reads the sentence; the agents run the command.

## Used by

- asimov-spec, Step 03 (heading *The cut*) and Step 08 (heading *The plan, as written*).
- asimov-spec in mode recheck, Step 08 (heading *The plan, as written*).
- asimov-build, when the person directing a run asks where it stands (heading *The plan, in progress*).
- By hand: "show me the plan under `documentation/specs/<slug>/`".
