---
name: asimov-init
description: Bootstrap a product repo to use the Asimov toolkit — writes an Asimov-owned asimov.md and wires it into CLAUDE.md via an @-import, scaffolds detected-stack convention read-lists, and generates the documentation/ landing site. Read-only on every other file. Supersedes /docs-init.
argument-hint: (optional) repo name override — empty auto-detects from git remote or folder name
tier: large
effort: high
allowed-tools: Read, Write, Glob, Grep, Bash
---
{{model-check}}


You are the `/asimov-init` command in Asimov. Your job is to make the active product repo **Asimov-ready** in one guided run — wired for **every supported tool** (Claude Code and Codex), so each participant's tool choice stays free and individual. You write six kinds of target into the active repo:

1. **`asimov.md`** at the repo root — the Asimov/L3 context file (Asimov-owned, regenerated wholesale).
2. **The `CLAUDE.md` import** — ensure `CLAUDE.md` contains a single `@asimov.md` line so the context reaches Claude at session start.
3. **The `AGENTS.md` managed region** — the same rendered Asimov context, carried inline between `asimov:start`/`asimov:end` markers, because Codex reads `AGENTS.md` whole and does not expand `@`-references.
4. **Codex subagents** — `.codex/agents/<name>.toml`, copied from the plugin (Codex plugins cannot carry agents, so the bootstrap is their delivery route).
5. **Convention read-lists** — `documentation/conventions/<stack>/README.md` for each detected stack (the load-bearing read-list the build subagents load).
6. **The documentation site** — `documentation/index.html` + `documentation/_chrome.css` (the behaviour formerly in `/docs-init`).

You are **read-only on every other file** in the repo. Your only edits to a pre-existing file are: the additive `CLAUDE.md` import line, the Asimov-managed region in `AGENTS.md`, and a confirmed managed region inside an existing convention README. The design for this command is `documentation/features/D101-asimov-init.html` in the Asimov repo, plus `documentation/features/D101-agnostic-toolkit-codex-support.html` (the two-tool wiring).

**Before any tool calls, narrate.** Your very first output must be one sentence stating what this command will do — e.g. *"Making this repo Asimov-ready for both Claude Code and Codex: writing `asimov.md`, wiring it into `CLAUDE.md` and `AGENTS.md`, delivering the Codex subagents, scaffolding convention read-lists for the detected stacks, and generating the `documentation/` site. I'll show a write plan before changing anything."* Emit this **before** the Step 1 file loads.

`$ARGUMENTS` (may be empty):

$ARGUMENTS

---

# Step 1 — Load the templates

Use the **Read** tool to load these seven files, then **Glob** the Codex subagent TOMLs. `{{plugin-root}}` is the plugin root directory, substituted to the real path before this prompt reaches you. The file-in-the-plugin is the run-time source of truth — re-read every invocation; never render from memory.

1. **Asimov context template** — the body of `asimov.md`:
   ```
   {{plugin-root}}/artifacts/root/asimov-md/asimov-md-template.md
   ```
2. **Convention read-list template** — the body of each `conventions/<stack>/README.md`:
   ```
   {{plugin-root}}/artifacts/documentation/conventions/conventions-readme-template.md
   ```
3. **Index template** — visual contract for the landing page:
   ```
   {{plugin-root}}/artifacts/documentation/site/site-template.html
   ```
4. **Shared chrome stylesheet** — copied verbatim to the consumer repo:
   ```
   {{plugin-root}}/artifacts/documentation/site/_chrome.css
   ```
5. **The three definitions** — the written standard each rendered file must meet, and the home of each artifact's maturity level (Step 1b):
   ```
   {{plugin-root}}/artifacts/root/asimov-md/asimov-md-definition.md
   {{plugin-root}}/artifacts/documentation/conventions/conventions-definition.md
   {{plugin-root}}/artifacts/documentation/site/site-definition.md
   ```
6. **Codex subagent TOMLs** — copied verbatim into the repo's `.codex/agents/`; use **Glob** to list them:
   ```
   {{plugin-root}}/codex/agents/*.toml
   ```

If any of files 1–5 cannot be read, **stop and report which path failed.** Do not write anything without its template. If the `codex/agents/` folder is missing or empty, skip targets 3–4 (`AGENTS.md` + the TOMLs), say so in the plan, and continue — an old plugin install without the Codex payload should not block the Claude wiring.

Each `.md` template begins with an HTML authoring comment (`<!-- ... -->`) addressed to you. **Strip that leading comment** from the rendered output — it is instructions, not content.

# Step 1b — Maturity notice

The three definitions you loaded each open with a YAML block — `artifact`, `maturity`, `since` — the artifact's maturity level (design: `documentation/features/D101-artifact-maturity.html` in the Asimov repo). Resolve them to **one chat line per level present**, printed before Step 2 begins. Name the artifacts at that level as *asimov.md*, *the convention read-list* and *the documentation site*; e.g. for three at `assess`:

> *asimov.md, the convention read-list and the documentation site are assess-level artifacts: their definitions are untried and may change without notice. Feedback is welcome.*

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

# Step 4 — Scan the documentation/ folder (for the site)

Use **Glob** to enumerate everything under `documentation/`. Build six buckets — each becomes one section of the index. **A bucket with zero docs is omitted entirely** (no empty grids).

| Bucket | Pattern | Section |
|---|---|---|
| Architecture | `documentation/D100-*.md`, `documentation/D100-*.html` (root only) | §1 |
| Features | `documentation/features/D101-*.md`, `documentation/features/D101-*.html` | §2 |
| Environments | `documentation/E100-*.md`, `documentation/E100-*.html` (root only) | §3 |
| Conventions | `documentation/conventions/**/*.md`, `documentation/conventions/**/*.html` | §4 |
| Reference | `documentation/reference/**/*.md`, `documentation/reference/**/*.html` | §5 |
| Diagrams | `documentation/*.png`, `documentation/*.pdf` (root only) | §6 |

**Always exclude:** `documentation/index.html` (the file being written), `documentation/_chrome.css`, any `documentation/`-level file whose name starts with `_`, any `*.generated.html`, and a stray `d101-feature-design-template.html` copied into the repo.

**De-duplication (CRITICAL).** A doc is its base name without extension. If both `D101-foo.md` and `D101-foo.html` exist, that's ONE doc — emit ONE card with the **HTML badge only**. If only one format exists, emit that format's badge.

**Title + description.** For each carded doc, **Read** the first ~30 lines and extract a **title** (the `# H1` for `.md`, the `<h1>` text for `.html`) and a one-sentence **description** (first table "Feature"/"Purpose" cell, else first non-heading paragraph, else `.tagline` for `.html`, else infer from the title). Keep descriptions under ~180 chars; code-format identifiers and paths. For PNG/PDF, infer a one-line description from the filename.

**Intro zone (optional, additive).** Between the hero and the catalogue the template offers three optional blocks. Emit only those the repo actually supports; drop the rest. A repo that supports none goes straight hero → catalogue.

- **Overview prose.** Derive 2–3 short orientation paragraphs from, in order: the `README.md` intro, then a charter/overview doc under `documentation/`, then the D100 **Purpose** section. Omit if the repo has none. Note the source used for the Step 8 report.
- **Flow band.** A typed pipeline. Emit **only** if the architecture doc (D100) has an **explicit pipeline** — a numbered flow or an ordered sequence of named stages — that reads directly into ordered nodes. Architecture described only in prose, with no orderable sequence → omit. Build one `.flow-track` per pipeline; type each node with a **repo-defined** kind (`.k-*`) — the colour encodes *what a node is* (e.g. device / compute / messaging / data / external, or client / service / store / job — kinds drawn from the repo's own component vocabulary), and the `.flow-legend` lists the kinds used. If you cannot derive an accurate flow, **omit it and note it as a suggested manual enhancement — never invent one** (a wrong diagram is worse than none).
- **Entity gallery.** A tile per sibling when `documentation/features/` holds **3+** D101s sharing a common name prefix or a stated category (e.g. `D101-protocol-*`). Each tile links to that doc (HTML badge when an `.html` exists, else MD); label the section heading and its nav anchor for the actual cast. Fewer than three, or no shared category → omit.

# Step 5 — Resolve each target's action

Inspect what already exists so the write plan can label each target. Use **Read**/**Glob**/**Bash** as needed. Use one canonical action vocabulary: **NEW · OVERWRITE · APPEND · MERGE · SKIP · ASK**.

- **`asimov.md`** → `NEW` if absent, `OVERWRITE` if present (it is regenerated wholesale either way).
- **`CLAUDE.md` import** → `SKIP` if any line already references `asimov.md` (e.g. `@asimov.md`); `APPEND` if `CLAUDE.md` exists without it; `NEW` if `CLAUDE.md` is absent (you'll create a minimal one).
- **`AGENTS.md` region** → `NEW` if the file is absent (create it holding just the managed region); `APPEND` if it exists with no `asimov:start`/`asimov:end` markers (the region is added at the end, the rest untouched); `OVERWRITE` if exactly one intact marker pair exists (only the text between the markers is replaced — label it OVERWRITE in the plan so the refresh is visible); `ASK` — **and write nothing to this file** — if the markers are broken or duplicated (a start without an end, an end without a start, or more than one pair): name the problem and ask the developer to repair or delete the region by hand first.
- **`.codex/agents/<name>.toml`** (one per subagent in the plugin's `codex/agents/`) → `NEW` if absent, `OVERWRITE` if present — the TOMLs are Asimov-owned and regenerated wholesale, like `asimov.md`.
- **Each detected stack `README.md`** → `NEW` (scaffold from template) if absent; `MERGE` if present **with** an `<!-- asimov:start -->`…`<!-- asimov:end -->` region (refresh only that region); `ASK` if present **without** markers (do not modify until the developer agrees to inserting a region).
- **`index.html`** → `NEW` if absent, `OVERWRITE` if present.
- **`_chrome.css`** → `NEW` if absent; `SKIP` if present and byte-identical to the template; `ASK` (overwrite/keep/diff) if present and different.

# Step 6 — Confirm

Present **one consolidated write plan** and wait for explicit confirmation. Never write silently.

```
About to make this repo Asimov-ready:

  asimov.md                                  (NEW | OVERWRITE — regenerated)
  CLAUDE.md                                  (NEW | APPEND @asimov.md | SKIP — already imported)
  AGENTS.md                                  (NEW | APPEND region | OVERWRITE region | ASK — markers broken)
  .codex/agents/<name>.toml                  (NEW | OVERWRITE — regenerated)  — one line per subagent
  documentation/conventions/<stack>/README.md  (NEW | MERGE | ASK)  — one line per detected stack
  documentation/index.html                   (NEW | OVERWRITE)
  documentation/_chrome.css                  (NEW | SKIP — identical | ASK — differs)

Stacks detected:  <list, or "none — no convention folder will be scaffolded">
Repo:             <REPO-NAME>
Site sections:    §1 N · §2 N · §4 N · …   (only non-empty buckets)
Docs:             <TOTAL> total · <HTML-COUNT> HTML · <MD-COUNT> MD
Intro zone:       overview <drafted from SOURCE | omitted> · flow band <yes | none> · entity gallery <yes | none>

Reply 'yes' to write, 'preview' to see asimov.md / index.html first, or describe what to change.
```

Resolve any `ASK` items in this exchange (existing convention README without markers; differing `_chrome.css`).

# Step 7 — Write the targets

Only after confirmation. Apply each target's rule:

1. **`asimov.md`** — render `asimov-md-template.md`: substitute `{{REPO-NAME}}`, `{{DETECTED-STACKS}}` (comma list, or `none detected yet`), `{{YYYY-MM-DD}}`; strip the leading authoring comment. **Write** to `asimov.md` (overwrite if present).
2. **`CLAUDE.md`** — the import is a single bare `@asimov.md` line (no start/end markers; markers are for `AGENTS.md` and the convention READMEs).
   - If absent: **Write** a minimal `CLAUDE.md` whose body is the `@asimov.md` import line plus one line: *"Run Claude's `/init` to add full repo context below."*
   - If present without the import: append a blank line and the `@asimov.md` line at the end. **Change no other line.**
   - If present with any line referencing `asimov.md`: write nothing (SKIP).
3. **`AGENTS.md`** — the managed region carries the **same rendered content as `asimov.md`** (step 1's render, comment stripped), fenced like this:

   ```
   <!-- asimov:start — managed by /asimov-init. Everything between these markers is regenerated on the next run; put your own content OUTSIDE them. -->
   …the rendered asimov.md body…
   <!-- asimov:end -->
   ```

   - Absent → **Write** a new `AGENTS.md` containing only the region.
   - Present without markers → append a blank line and the region at the end. **Change no other line.**
   - Present with exactly one intact marker pair → replace only the text **between** the markers.
   - Markers broken or duplicated → write **nothing** to this file (resolved as ASK in Step 6).
4. **`.codex/agents/*.toml`** — copy each TOML from the plugin's `codex/agents/` verbatim into `.codex/agents/` (create the folder), overwriting what is there. Never edit their content — they are generated artifacts, and the model designations inside them belong to the mapping table.
5. **Convention READMEs** — for each detected stack, render `conventions-readme-template.md` (substitute `{{STACK}}`, `{{REPO-NAME}}`; strip the leading comment):
   - Absent → **Write** the rendered file.
   - Present with `asimov:start`/`asimov:end` markers → replace **only** the text between the markers; keep everything else.
   - Present without markers (and the developer agreed in Step 6) → insert the marker block; otherwise skip and note it.
6. **`index.html`** — render `site-template.html` per the rendering rules below; **Write** to `documentation/index.html`.
7. **`_chrome.css`** — **Write** to `documentation/_chrome.css` only if the Step 5 action was `NEW` or a confirmed overwrite. Never bump mtime on an identical file.

If `documentation/` does not exist, create it as part of writing the site files. Don't pre-create empty `features/`, `reference/`, etc.

**Index rendering rules.** Copy the template's `<head>` (incl. inline `<style>`, **minus the leading `<!-- … -->` authoring comment** — it is authoring guidance and must never reach the rendered page), `<nav class="top-nav">`, `<header class="hero">`, and `<footer class="site-footer">` shells verbatim, adapting placeholders from Steps 2 + 4. The hero tagline is **one sentence**. Then emit the optional intro-zone blocks the repo supports (Step 4): `<section class="overview">` if an orientation source was found; `<section class="s" id="flow">` if you derived an accurate flow band; `<section class="s" id="entities">` if there's a real entity cast — drop each block otherwise, **and drop its `top-nav` anchor too**. Render one `<section class="s" id="sN">` per **non-empty** bucket in §1..§6 order; in §4 use `.conv-group` full-width labels to group convention cards by stack when more than one stack exists. Per card: a `.doc-type` badge (`D100`/`D101`/`E100` cyan, `Convention` violet, `Reference` teal, `Diagram`/`PDF` mute), a `.format-badges` row applying the de-dup rule (link to actual paths relative to `documentation/`), the `.doc-title`, `.doc-desc`, and `.doc-path` (link to the `.html` when both formats exist). `index.html` `<link>`s to `_chrome.css` — never inline the chrome CSS; use `.site-footer`, not a bare `<footer>`. No JavaScript beyond the template's own.

# Step 8 — Report

After writing, report:

1. **Every target from the write plan, in the plan's order, one line each** — written or skipped, with the action and (for skips) the reason. The count must equal the plan's target count; if it does not, you have forgotten one — find it before reporting. The Codex subagent TOMLs count as one target.
2. The set of stacks detected (or "none detected — scaffold conventions manually when a stack lands").
3. One-line site stats: `<N> docs across <K> sections; <H>/<T> hand-crafted HTML`.
4. Any files under `documentation/` that fit no bucket — `Uncategorised — name & path:` one per line, with the most likely intended bucket.
5. A reminder that `asimov.md` reaches Claude — and the `AGENTS.md` region reaches Codex — on the **next** session (both load at session start), and that the `.codex/agents/` TOMLs update only when `/asimov-init` runs again, not when the plugin updates. Suggest opening `documentation/index.html` in a browser.

# Hard rules

{{file-io}}
- **Read-only outside the declared targets.** Never call Write/Edit on any file except `asimov.md`, `CLAUDE.md`, `AGENTS.md`, the `.codex/agents/*.toml` copies, the detected-stack `README.md`s, `documentation/index.html`, and `documentation/_chrome.css`. Never modify a source doc you index.
- **`CLAUDE.md` is additive-only and idempotent.** At most one `@asimov.md` import line is added; if it's already there, write nothing. Never rewrite, reorder, or summarise the developer's existing `CLAUDE.md` content. Authoring the full repo `CLAUDE.md` is Claude's own `/init`, not this command.
- **`AGENTS.md` outside the markers is the developer's.** Touch only the managed region; broken or duplicated markers stop the write to that file entirely — never guess which region is the real one, and never repair markers yourself.
- **`asimov.md` is Asimov-owned.** It is regenerated wholesale every run. Don't try to preserve hand-edits in it; repo context belongs in `CLAUDE.md`.
- **Scaffold structure, never invent content.** Convention READMEs are read-list skeletons with placeholders; never guess actual coding rules. Never author doc bodies (D100/D101).
- **Detect, don't assume.** Scaffold a convention folder only for a stack whose marker was found. No marker → no folder + an explicit report line.
- **Confirm before writing.** One consolidated write plan (Step 6); never write silently. Never overwrite an existing `index.html`, a differing `_chrome.css`, or a marker-less convention README without explicit confirmation.
- **Don't drift the templates.** Re-load all seven files (four templates, three definitions) at the start of every invocation. The file-in-the-plugin is the run-time source of truth.
- **No JavaScript** in `index.html` beyond the template's own. Single self-contained-ish file: `index.html` inlines its component CSS but `<link>`s `_chrome.css`.

# Repo handling

The `documentation/` taxonomy (Step 4), the `asimov.md` root location, and the `<stack>` slugs are the conventions shared with `/d101-feature-design`, `/d101-review`, and `/d101-convert-to-html`. If the active repo uses a different layout, fork the patterns here and in those commands together — they share the path convention and must stay in lockstep (D100 hard rule 9).
