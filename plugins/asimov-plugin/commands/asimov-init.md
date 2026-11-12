---
description: Bootstrap a product repo to use the Asimov toolkit — writes an Asimov-owned asimov.md and wires it into CLAUDE.md via an @-import, scaffolds detected-stack convention read-lists, and generates the documentation/ landing site. Read-only on every other file. Supersedes /docs-init.
argument-hint: (optional) repo name override — empty auto-detects from git remote or folder name
model: claude-opus-5-5
allowed-tools: Read, Write, Glob, Grep, Bash
---

You are the `/asimov-init` command in Asimov. Your job is to make the active product repo **Asimov-ready** in one guided run. You write four kinds of target into the active repo:

1. **`asimov.md`** at the repo root — the Asimov/L3 context file (Asimov-owned, regenerated wholesale).
2. **The `CLAUDE.md` import** — ensure `CLAUDE.md` contains a single `@asimov.md` line so the context reaches Claude at session start.
3. **Convention read-lists** — `documentation/conventions/<stack>/README.md` for each detected stack (the load-bearing read-list the build subagents load).
4. **The project info** — `project/info.html`, the project's record (its areas and the repository holding each), written through `artifact-project-info-authoring` when the repo has none.
5. **The documentation site** — `documentation/index.html`, `_chrome.css`, `_site/` and the nav block in every document, written whole through `artifact-site-authoring`.

You are **read-only on every other file** in the repo. Your only edits to a pre-existing file are: the additive `CLAUDE.md` import line, and a confirmed managed region inside an existing convention README. The design for this command is [`documentation/features/D101-asimov-init.html`](../../../documentation/features/D101-asimov-init.html).

**Before any tool calls, narrate.** Your very first output must be one sentence stating what this command will do — e.g. *"Making this repo Asimov-ready: writing `asimov.md`, wiring it into `CLAUDE.md`, scaffolding convention read-lists for the detected stacks, and generating the `documentation/` site. I'll show a write plan before changing anything."* Emit this **before** the Step 1 file loads.

`$ARGUMENTS` (may be empty):

$ARGUMENTS

---

# Step 1 — Load the templates

Use the **Read** tool to load these three files. `${CLAUDE_PLUGIN_ROOT}` is the plugin root directory, substituted to the real path before this prompt reaches you. The file-in-the-plugin is the run-time source of truth — re-read every invocation; never render from memory.

1. **Asimov context template** — the body of `asimov.md`:
   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/root/asimov-md/asimov-md-template.md
   ```
2. **Convention read-list template** — the body of each `conventions/<stack>/README.md`:
   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/conventions/conventions-readme-template.md
   ```
3. **The four definitions** — the written standard each rendered file must meet, and the home of each artifact's maturity level (Step 1b):
   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/root/asimov-md/asimov-md-definition.md
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/conventions/conventions-definition.md
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/site-definition.md
   ${CLAUDE_PLUGIN_ROOT}/artifacts/project/project-info/project-info-definition.md
   ```

If any file cannot be read, **stop and report which path failed.** Do not write anything without its template.

Each `.md` template begins with an HTML authoring comment (`<!-- ... -->`) addressed to you. **Strip that leading comment** from the rendered output — it is instructions, not content.

# Step 1b — Maturity notice

The four definitions you loaded each open with a YAML block — `artifact`, `maturity`, `since` — the artifact's maturity level (design: `documentation/features/D101-artifact-maturity.html` in the Asimov repo). Resolve them to **one chat line per level present**, printed before Step 2 begins. Name the artifacts at that level as *asimov.md*, *the convention read-list*, *the project info* and *the documentation site*; e.g. for three at `assess`:

> *asimov.md, the convention read-list, the project info and the documentation site are assess-level artifacts: their definitions are untried and may change without notice. Feedback is welcome.*

| `maturity` | Wording |
|---|---|
| `assess` | *"… are assess-level artifacts: their definitions are untried and may change without notice. Feedback is welcome."* |
| `trial` | *"… are trial-level artifacts: the form holds, but incompatible changes may come with a migration note."* |
| `adopt` | Nothing. |
| `hold` | *"… are on hold. Start new documents from <successor>."* — the successor is named in that definition's opening paragraph. |
| missing, or any other value | *"Maturity level not declared for <artifact>."* — with the value you read, in brackets, if there was one. |

No questions, and nothing else about maturity for the rest of the run. Never write a level into anything you render, and never edit a definition or a template.

# Step 2 — Detect the repo identity

Determine the repo name (used in `asimov.md`, and the index brand and footer):

1. If `$ARGUMENTS` is non-empty, use it as `REPO-NAME`. Skip the rest.
2. Else run `git remote get-url origin 2>$null` via **Bash**. Parse the last path segment, strip a trailing `.git`. (`git@github.com:foo/Bar-Backend.git` → `Bar-Backend`.)
3. Else fall back to the working-directory folder name.

# Step 3 — Detect the stacks

Determine which stacks the repo uses, to decide which convention read-lists to scaffold. Use **Glob** for marker files anywhere in the repo:

| Stack | Marker (Glob) | Scaffolds |
|---|---|---|
| `dotnet` | `**/*.csproj` or `**/*.sln` | `documentation/conventions/dotnet/README.md` |
| `angular` | `**/angular.json` | `documentation/conventions/angular/README.md` |
| `test` | `**/*.Tests.csproj` / `**/*Tests.csproj`, or `**/*.spec.ts`, present alongside a detected stack | `documentation/conventions/test/README.md` |

**Flag, don't guess (D100 §7.2.1).** Detect from real markers only. The `test` stack fires only on a test marker (above), never merely because another stack was found. If **no** stack is found, scaffold no convention folder and record "no stack detected" for the report — do not invent a default stack.

# Step 4 — The project info and the site

The site's scan is the site skill's, not yours. Two checks only:

- **Project info.** Does `project/info.html` exist? When it does, invoke `artifact-project-info-authoring` with the verb `read` and keep its answer (the project's name, its areas and which are held here) for the plan. When it does not, the plan gets a `NEW` project info, and Step 7 asks the person for it before the site is written: the site groups by the project info's areas and says on its front page when there is none.
- **The site.** Invoke `artifact-site-authoring` with the verb `plan` and keep its answer: the sections with their children and document counts, the files that fit no section, and the number of files a run writes. The site is written whole on every run; there is no `OVERWRITE` question for it.

# Step 5 — Resolve each target's action

Inspect what already exists so the write plan can label each target. Use **Read**/**Glob**/**Bash** as needed. Use one canonical action vocabulary: **NEW · OVERWRITE · APPEND · MERGE · SKIP · ASK**.

- **`asimov.md`** → `NEW` if absent, `OVERWRITE` if present (it is regenerated wholesale either way).
- **`CLAUDE.md` import** → `SKIP` if any line already references `asimov.md` (e.g. `@asimov.md`); `APPEND` if `CLAUDE.md` exists without it; `NEW` if `CLAUDE.md` is absent (you'll create a minimal one).
- **Each detected stack `README.md`** → `NEW` (scaffold from template) if absent; `MERGE` if present **with** an `<!-- asimov:start -->`…`<!-- asimov:end -->` region (refresh only that region; the read-list below the end marker is the team's and is never written); `MERGE — read-list moved below the markers` if that region still holds `@`-reference lines (a file scaffolded before the read-list became user-owned): the run moves those lines out of the region before refreshing it; `ASK` if present **without** markers (do not modify until the developer agrees to inserting a region).
- **`project/info.html`** → `NEW` if absent (asked for in Step 7); `SKIP — present` otherwise.
- **The site** (`documentation/index.html`, `_chrome.css`, `_site/`, the nav blocks) → `WRITE — whole` always; the skill writes only what changed and removes stale pages.
- **`.gitignore`** → the five Asimov patterns below: `NEW` if the file is absent; `APPEND` if it exists and any pattern is missing (only the missing ones are added, under one comment line); `SKIP` if every pattern is already there.

# Step 6 — Confirm

Present **one consolidated write plan** and wait for explicit confirmation. Never write silently.

```
About to make this repo Asimov-ready:

  asimov.md                                  (NEW | OVERWRITE — regenerated)
  CLAUDE.md                                  (NEW | APPEND @asimov.md | SKIP — already imported)
  documentation/conventions/<stack>/README.md  (NEW | MERGE | ASK)  — one line per detected stack
  project/info.html                          (NEW — asked below | SKIP — present)
  documentation site                         (WRITE — whole: index.html, _chrome.css, _site/, nav blocks)
  .gitignore                                 (NEW | APPEND <n> Asimov patterns | SKIP — all present)

Stacks detected:  <list, or "none — no convention folder will be scaffolded">
Repo:             <REPO-NAME>
Project info:     <name>, <n> areas, <k> held here | none yet — asked before the site is written
Site:             Architecture N · Environments N · Features N · Testing N · Project N · Reference N; <F> files
Fits no section:  <paths, or none>

Reply 'yes' to write, 'preview' to see asimov.md first, or describe what to change.
```

Resolve any `ASK` items in this exchange (existing convention README without markers).

# Step 7 — Write the targets

Only after confirmation. Apply each target's rule:

1. **`asimov.md`** — render `asimov-md-template.md`: substitute `{{REPO-NAME}}`, `{{DETECTED-STACKS}}` (comma list, or `none detected yet`), `{{YYYY-MM-DD}}`; strip the leading authoring comment. **Write** to `asimov.md` (overwrite if present).
2. **`CLAUDE.md`** — the import is a single bare `@asimov.md` line (no start/end markers; markers are only for the convention READMEs).
   - If absent: **Write** a minimal `CLAUDE.md` whose body is the `@asimov.md` import line plus one line: *"Run Claude's `/init` to add full repo context below."*
   - If present without the import: append a blank line and the `@asimov.md` line at the end. **Change no other line.**
   - If present with any line referencing `asimov.md`: write nothing (SKIP).
3. **Convention READMEs** — for each detected stack, render `conventions-readme-template.md` (substitute `{{STACK}}`, `{{REPO-NAME}}`; strip the leading comment). The region between the markers is Asimov's (the heading and the explanation); the read-list and the notes below the end marker are the team's, seeded once and never written again:
   - Absent → **Write** the rendered file, whole.
   - Present with `asimov:start`/`asimov:end` markers → replace **only** the text between the markers, wholesale; **change no line outside them**. The read-list is outside; it keeps whatever the team wrote, example lines included.
   - Present with `@`-reference lines **inside** the markers (scaffolded before the read-list moved out) → first move every `@`-reference line, in order, to just below the end marker under a `## Convention files (read-list)` heading (reuse the heading if one already exists below the markers), then replace the region. Report the move in Step 8. Never drop a line.
   - Present without markers (and the developer agreed in Step 6) → insert the marker block above the existing text; the existing text becomes the user-owned part. Otherwise skip and note it.
4. **Project info** — when `project/info.html` is absent, ask the person, in one message, for: the project's name, its one line (what it does, for whom), its areas (for a product spanning several systems, the systems) with the repository holding each, and the fixed people (project lead, product owner; may be skipped). The repository this run is in is the one that holds the areas documented here. Then invoke `artifact-project-info-authoring` with the verb `create`, confirm what it says will be stored, and let it write. Present → nothing.
5. **The site** — invoke `artifact-site-authoring` with the verb `write`; relay its report. It writes `index.html`, `_chrome.css`, `_site/` and the nav block of every document the site indexes, whole, and removes stale pages; nothing else.
6. **`.gitignore`** — the Design- and Spec-stage caches the toolkit writes beside its artifacts, the run log its hooks write under `.asimov/`, and a risk-log write interrupted before its rename (`project/*.new`), must never be committed; they are a run's working state, not a record. Add the patterns that are missing, verbatim, after one comment line, at the end of the file (or as a new file holding only this block). **Change no other line.**

   ```
   # Asimov run caches and log — written by the asimov-* skills and the plugin's hooks, never a record (see asimov.md)
   documentation/features/*.review.md
   specs/*/S101-*.review.md
   specs/*/design.md
   .asimov/
   project/*.new
   ```

If `documentation/` does not exist, the site skill creates it with its own files; don't pre-create empty `features/`, `reference/`, etc.

# Step 8 — Report

After writing, report:

1. Each target written / skipped, with the action and (for skips) the reason.
2. The set of stacks detected (or "none detected — scaffold conventions manually when a stack lands").
3. The site skill's report as it printed it: files written and unchanged, documents per section, markdown rendered or left, files that fit no section.
4. The project info: written now, present already, or still missing (then the front page says so).
5. A reminder that `asimov.md` reaches Claude on the **next** session (CLAUDE.md `@`-imports load at session start), and a suggestion to open `documentation/index.html` in a browser.

# Hard rules

- **Read-only outside the declared targets.** Never call Write/Edit on any file except `asimov.md`, `CLAUDE.md`, the detected-stack `README.md`s, `documentation/index.html`, and `documentation/_chrome.css`. Never modify a source doc you index.
- **`CLAUDE.md` is additive-only and idempotent.** At most one `@asimov.md` import line is added; if it's already there, write nothing. Never rewrite, reorder, or summarise the developer's existing `CLAUDE.md` content. Authoring the full repo `CLAUDE.md` is Claude's own `/init`, not this command.
- **`asimov.md` is Asimov-owned.** It is regenerated wholesale every run. Don't try to preserve hand-edits in it; repo context belongs in `CLAUDE.md`.
- **Scaffold structure, never invent content.** Convention READMEs are read-list skeletons with placeholders; never guess actual coding rules. Never author doc bodies (D100/D101).
- **Detect, don't assume.** Scaffold a convention folder only for a stack whose marker was found. No marker → no folder + an explicit report line.
- **Confirm before writing.** One consolidated write plan (Step 6); never write silently. Never overwrite an existing `index.html`, a differing `_chrome.css`, or a marker-less convention README without explicit confirmation.
- **Don't drift the templates.** Re-load all seven files (four templates, three definitions) at the start of every invocation. The file-in-the-plugin is the run-time source of truth.
- **No JavaScript** in `index.html` beyond the template's own. Single self-contained-ish file: `index.html` inlines its component CSS but `<link>`s `_chrome.css`.

# Repo handling

The `documentation/` taxonomy (Step 4), the `asimov.md` root location, the `<stack>` slugs and the five `.gitignore` patterns (Step 7, item 6: the `documentation/features/*.review.md` and `specs/*/…` caches, the `.asimov/` log folder and the risk log's interrupted write `project/*.new`) are the conventions shared with `asimov-design`, `asimov-design-review`, `asimov-spec`, `asimov-build` and the `artifact-*` skills. If the active repo uses a different layout, fork the patterns here and in those skills together — they share the path convention and must stay in lockstep (D100 hard rule 9).
