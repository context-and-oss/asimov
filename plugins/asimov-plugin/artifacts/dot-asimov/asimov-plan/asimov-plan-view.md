# Plan view

*The view of the plan artifact, beside its definition and template. `asimov-spec` and `asimov-build` read it by path whenever a person must see the plan and render the view it fixes. A file, not a skill: nothing is substituted in it, so a sibling is named by its file name and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

The plan file is written for agents; a person sees the plan through this view. One layout, every time, so a reader learns it once. The view says nothing about the plan that is not in the file, and it carries no verdict: the caller prints the validation lines under it if it has them.

## Read first

Load with the file-read tool. File 1 sits beside this file; never a relative path in a tool call, since the working directory is the product repo. If it cannot be read, stop and report the path.

1. **The plan template**, `asimov-plan-template.md`, for the frontmatter keys and the plan sections you read.
2. **The target**, whole; parse the frontmatter as YAML. Either the plan (`.asimov/plans/<slug>.md`) or, when the caller names it, the rendered S101 (`.asimov/specs/<slug>/S101-<slug>.md`): both carry the same header, tree and six sections, and the view reads only those.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `plan` | Path of the plan or the S101. Required. |
| `heading` | One line printed above the view, the caller's framing: *The cut*, *The plan, ready*, *The plan, in progress*. [none] |
| `language` | The language of the labels. [the language the conversation is in] |

## The view

Print exactly this layout, in a fenced block so the columns hold. Labels (*Plan for*, *phases*, *tasks*, *Constraints*, *Coverage*, *Assumptions*, *corrected at the cut*, *behaviour*, *design gap*) in the caller's language; titles, names and checkpoint sentences as the file has them. The rule in the horizontal line is as wide as the widest line, never wider than 80 characters: a terminal wraps anything longer, and the view is read in ten seconds. A line that does not fit is printed as it is, not reworded, and is the plan's defect to report, not yours to hide.

```
<heading, when given>
Plan for <slug> · <title>
<design, short> · approved by <who> <date> · <n> phases, <m> tasks · <status> v<version> · <plan approved by <by> <date> | plan not approved>
──────────────────────────────────────────────────────────────────────
P0  <phase name>                                           <phase traces>
    <delivers>
    ✓ <checkpoint>
    ├─ T001  <role>  <tier>  <title>
    └─ T002  <role>  <tier>  <title>
──────────────────────────────────────────────────────────────────────
P1  <phase name>                                           <phase traces>
    <delivers>
    ✓ <checkpoint>
    ├─ T003  <role>  <tier>  <title>
    └─ T004  <role>  <tier>  <title>
──────────────────────────────────────────────────────────────────────
Constraints  <each §2 line, verbatim, one per line; "none" when the section is empty>
Coverage     <what the coverage map says, one line>
Assumptions  <k>, of which <c> corrected at the cut
behaviour    <id> · <the Taken cell of every §6 row whose How carries "behaviour", one line each; omit when none>
design gap   <the Taken cell of every assumption that begins design:, one line each; omit the line when none>
```

Rules of the rendering:

- **Plan approved by** comes from the header's `approved` line: the name and date when it holds them, *plan not approved* when it is `none` or absent. The view does not check the fingerprint; the caller says whether the approval still holds.
- **Design, short.** For a repo file: the file name and version (`D101-permissions.html v0.11`). For a normalised design: the key or the last path segment of the url and the read time (`PROJ-123, read 2026-10-05`). *Approved by* comes from the body's first paragraph; omit it when the body does not name one. When the header's `design` line says `approval: unverified`, the approval reads `approved by <who> <date> (unverified: pasted text)`.
- **Phases** in the order of the tree, each with its id, name and traces (right-aligned; nothing when empty). The `delivers` sentence on its own line directly under the name, verbatim and unprefixed. Then the `checkpoint` sentence, prefixed `✓`, verbatim; never the `check` command. Tasks in the order of the tree with `├─` and `└─` on the last.
- **Role** is the role without its stack prefix (`builder`, `tester`, `human`) when every task of the plan is of one stack; with the stack (`dotnet builder`, `angular builder`) when the plan has more than one. Pad role and tier so the titles align.
- **Title** verbatim from the task line. Never add the dependencies, the files or the traces of a task.
- **Constraints** prints every line of §2 as written, because the author approves them with the go: the approval's fingerprint covers the tree, §2, §3 and §6, and the view shows exactly those parts. The first line carries the label; the rest are indented under it.
- **Coverage** is one line from §3: the acceptance criteria delivered (`AC1–AC5 delivered`), then every id whose *Delivered by* is not a task list, with its reason as written. Collapse consecutive ids into a range.
- **Assumptions** counts the rows of §6 and the ones whose *How* begins `corrected at the cut`. Every row whose *How* carries `behaviour` is printed on its own `behaviour` line, id and *Taken* cell. Every row whose *Taken* begins `design:` is printed in full on its own `design gap` line.
- **Nothing else.** No validation rows, no verdict, no task sections, no file sizes, no commentary. The caller adds what it has under the block.

Return the block as chat text and nothing before or after it.

## Never

- **Write** a file, or change one.
- **Judge** the plan, mark a row, or add a finding. The validation script, `scripts/validate-plan.ps1` beside this file, reports defects.
- **Invent** a label or a column. The layout is fixed.
- **Print the frontmatter**, any YAML, a task section, a phase's `check` or a file list. The person reads the sentences; the agents read the rest.

## Used by

- asimov-spec, at the cut (heading *The cut*, *The cut, as edited* after a hand edit) and at the end (heading *The plan, ready*, or *The plan, as written* when the approval must be renewed).
- asimov-build, when the person directing a run asks where it stands (heading *The plan, in progress*, on the S101).
- By hand: "show me the plan for `<slug>`".
