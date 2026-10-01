---
name: codex-asimov-init
description: Bootstrap a product repo to use the Asimov toolkit from Codex — writes the Asimov context into an AGENTS.md managed region, delivers the Codex subagent shells to .codex/agents/, scaffolds detected-stack convention read-lists, and generates the documentation/ landing site. Read-only on every other file. Codex counterpart of /asimov-init.
argument-hint: (optional) repo name override — empty auto-detects from git remote or folder name
allowed-tools: Read, Write, Glob, Grep, Bash
disable-model-invocation: true
user-invocable: false
---

You are `$asimov-plugin:codex-asimov-init`, the Codex counterpart of Asimov's `/asimov-init` command. Your job is to make the active product repo **Asimov-ready for Codex** in one guided run. You write four kinds of target into the active repo:

1. **The `AGENTS.md` managed region** — the rendered Asimov/L3 context (Asimov-owned, regenerated wholesale), carried inline between `<!-- asimov:start -->` and `<!-- asimov:end -->` markers, because Codex reads `AGENTS.md` whole and does not expand `@`-references. This is Codex's counterpart of the `asimov.md` file and the `@asimov.md` import that `/asimov-init` writes for Claude Code — you write neither of those.
2. **Codex subagent shells** — `.codex/agents/<name>.toml`, copied verbatim from the plugin's `agents/` folder. Codex loads custom agents only from `~/.codex/agents/` or a trusted repo's `.codex/agents/`, never from a plugin, so this run is how the shells reach the repo.
3. **Convention read-lists** — `documentation/conventions/<stack>/README.md` for each detected stack (the load-bearing read-list the build subagents load).
4. **The documentation site** — `documentation/index.html` + `documentation/_chrome.css` (the behaviour formerly in `/docs-init`).

You are **read-only on every other file** in the repo. Your only edits to a pre-existing file are: the Asimov-managed region in `AGENTS.md`, the Asimov-owned `.codex/agents/*.toml` copies, and a confirmed managed region inside an existing convention README. You never touch `asimov.md` or `CLAUDE.md`. The design for this command is [`documentation/features/D101-asimov-init.html`](../../../../documentation/features/D101-asimov-init.html).

**Before any tool calls, narrate.** Your very first output must be one sentence stating what this command will do — e.g. *"Making this repo Asimov-ready for Codex: writing the Asimov context into `AGENTS.md`, delivering the Codex subagent shells, scaffolding convention read-lists for the detected stacks, and generating the `documentation/` site. I'll show a write plan before changing anything."* Emit this **before** the Step 1 file loads.

**Input.** Whatever the developer wrote after the invocation is the input — a repo name override, or nothing. It may be empty.

---

# Step 1 — Resolve the plugin root, then load the templates

**Where you are is not where the plugin is.** Your working directory is the product repo. This skill and the templates it needs live in Codex's plugin cache under your home directory, `<home>/.codex/plugins/cache/<marketplace>/<plugin>/<version>/`. Never read a plugin file by a relative path: a relative path is resolved from the working directory and misses. Codex substitutes no plugin-root variable in a skill's text, so you resolve the root yourself, **once**:

1. Take this skill's file path as Codex shows it in its skill list.
2. Strip everything from `skills/codex-asimov-init` onward — the plugin root is two levels above the skill folder.
3. Write the result down as `<plugin-root>` and build every path below from it, absolute. Never pass `..` to a tool, and never resolve from the working directory.

**Verify before you load.** Read file 1. If it does not exist, the root you resolved is wrong — do not guess; **search** for the file instead, with `<home>` as your home directory (what `~` expands to, on every platform):

```
Glob  <home>/.codex/plugins/cache/**/artifacts/root/asimov-md/asimov-md-template.md
```

Take the match and set `<plugin-root>` to the folder that holds its `artifacts/`. If several match (older versions are still cached), take the one whose path shares the longest prefix with the skill path you were given. If nothing matches, **stop and report the path you derived and the search you ran** — the plugin is not installed where Codex documents it.

**Load the templates.** With `<plugin-root>` verified, use **Read** on these seven files, then **Glob** the Codex subagent shells (item 6). The file-in-the-plugin is the run-time source of truth — re-read every invocation; never render from memory.

1. **Asimov context template** — the body of the `AGENTS.md` managed region:
   ```
   <plugin-root>/artifacts/root/asimov-md/asimov-md-template.md
   ```
2. **Convention read-list template** — the body of each `conventions/<stack>/README.md`:
   ```
   <plugin-root>/artifacts/documentation/conventions/conventions-readme-template.md
   ```
3. **Index template** — visual contract for the landing page:
   ```
   <plugin-root>/artifacts/documentation/site/site-template.html
   ```
4. **Shared chrome stylesheet** — copied verbatim to the consumer repo:
   ```
   <plugin-root>/artifacts/documentation/site/_chrome.css
   ```
5. **The three definitions** — the written standard each rendered file must meet, and the home of each artifact's maturity level (Step 1b):
   ```
   <plugin-root>/artifacts/root/asimov-md/asimov-md-definition.md
   <plugin-root>/artifacts/documentation/conventions/conventions-definition.md
   <plugin-root>/artifacts/documentation/site/site-definition.md
   ```
6. **Codex subagent shells** — copied verbatim into the repo's `.codex/agents/`; use **Glob** to list them, never read-and-rewrite them:
   ```
   <plugin-root>/agents/*.toml
   ```

If any of files 1–5 cannot be read, **stop and report which absolute path failed.** Do not write anything without its template. If the `agents/` folder holds no `.toml`, skip target 4 (the shells), say so in the plan, and continue.

Each `.md` template begins with an HTML authoring comment (`<!-- ... -->`) addressed to you. **Strip that leading comment** from the rendered output — it is instructions, not content.

# Step 1b — Maturity notice

The three definitions you loaded each open with a YAML block — `artifact`, `maturity`, `since` — the artifact's maturity level (design: `documentation/features/D101-artifact-maturity.html` in the Asimov repo). Resolve them to **one chat line per level present**, printed before Step 2 begins. Name the artifacts at that level as *the Asimov context*, *the convention read-list* and *the documentation site*; e.g. for three at `assess`:

> *The Asimov context, the convention read-list and the documentation site are assess-level artifacts: their definitions are untried and may change without notice. Feedback is welcome.*

| `maturity` | Wording |
|---|---|
| `assess` | *"… are assess-level artifacts: their definitions are untried and may change without notice. Feedback is welcome."* |
| `trial` | *"… are trial-level artifacts: the form holds, but incompatible changes may come with a migration note."* |
| `adopt` | Nothing. |
| `hold` | *"… are on hold. Start new documents from <successor>."* — the successor is named in that definition's opening paragraph. |
| missing, or any other value | *"Maturity level not declared for <artifact>."* — with the value you read, in brackets, if there was one. |

No questions, and nothing else about maturity for the rest of the run. Never write a level into anything you render, and never edit a definition or a template.

# Step 2 — Detect the repo identity

Determine the repo name (used in the Asimov context, and the index brand and footer):

1. If the input is non-empty, use it as `REPO-NAME`. Skip the rest.
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

- **`AGENTS.md` region** → `NEW` if the file is absent (create it holding just the managed region); `APPEND` if it exists with no `asimov:start`/`asimov:end` markers (the region is added at the end, the rest untouched); `OVERWRITE` if exactly one intact marker pair exists (only the text between the markers is replaced — label it OVERWRITE so the refresh is visible); `ASK` — **and write nothing to this file** — if the markers are broken or duplicated (a start without an end, an end without a start, or more than one pair): name the problem and ask the developer to repair or delete the region by hand first.
- **`.codex/agents/<name>.toml`** (one per shell in the plugin's `agents/`) → `NEW` if absent, `OVERWRITE` if present — the shells are Asimov-owned and regenerated wholesale, like the `AGENTS.md` region. This write needs the developer's approval: the sandbox protects `.codex/`, so Codex asks before allowing it.
- **Each detected stack `README.md`** → `NEW` (scaffold from template) if absent; `MERGE` if present **with** an `<!-- asimov:start -->`…`<!-- asimov:end -->` region (refresh only that region); `ASK` if present **without** markers (do not modify until the developer agrees to inserting a region).
- **`index.html`** → `NEW` if absent, `OVERWRITE` if present.
- **`_chrome.css`** → `NEW` if absent; `SKIP` if present and byte-identical to the template; `ASK` (overwrite/keep/diff) if present and different.

# Step 6 — Confirm

Present **one consolidated write plan** and wait for explicit confirmation. Never write silently.

```
About to make this repo Asimov-ready for Codex:

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

Reply 'yes' to write, 'preview' to see the AGENTS.md region / index.html first, or describe what to change.
```

Resolve any `ASK` items in this exchange (existing convention README without markers; differing `_chrome.css`; broken `AGENTS.md` markers).

# Step 7 — Write the targets

Only after confirmation. Apply each target's rule:

1. **`AGENTS.md`** — render `asimov-md-template.md`: substitute `{{REPO-NAME}}`, `{{DETECTED-STACKS}}` (comma list, or `none detected yet`), `{{YYYY-MM-DD}}`; strip the leading authoring comment. The managed region carries that rendered text, fenced like this:

   ```
   <!-- asimov:start — managed by codex-asimov-init. Everything between these markers is regenerated on the next run; put your own content OUTSIDE them. -->
   …the rendered Asimov context…
   <!-- asimov:end -->
   ```

   - Absent → **Write** a new `AGENTS.md` containing only the region.
   - Present without markers → append a blank line and the region at the end. **Change no other line.**
   - Present with exactly one intact marker pair → replace only the text **between** the markers.
   - Markers broken or duplicated → write **nothing** to this file (resolved as ASK in Step 6).
2. **`.codex/agents/*.toml`** — copy each shell from the plugin's `agents/` folder **byte for byte** into `.codex/agents/` (create the folder), overwriting what is there: use a file copy (`Copy-Item` / `cp` via **Bash**), never a read-and-rewrite that could change encoding or line endings. Never edit their content — they are Asimov-owned and point at the role skills in the plugin. **In Codex the sandbox refuses this write until the developer approves it** — when Codex asks, that is the prompt to approve. In a run that cannot ask, do not retry another way: report the shells as `SKIP — Codex needs your approval to write into .codex/agents/` and say how to finish (approve the write in an interactive Codex session and re-run).
3. **Convention READMEs** — for each detected stack, render `conventions-readme-template.md` (substitute `{{STACK}}`, `{{REPO-NAME}}`; strip the leading comment):
   - Absent → **Write** the rendered file.
   - Present with `asimov:start`/`asimov:end` markers → replace **only** the text between the markers; keep everything else.
   - Present without markers (and the developer agreed in Step 6) → insert the marker block; otherwise skip and note it.
4. **`index.html`** — render `site-template.html` per the rendering rules below; **Write** to `documentation/index.html`.
5. **`_chrome.css`** — **Write** to `documentation/_chrome.css` only if the Step 5 action was `NEW` or a confirmed overwrite. Never bump mtime on an identical file.

If `documentation/` does not exist, create it as part of writing the site files. Don't pre-create empty `features/`, `reference/`, etc.

**Index rendering rules.** Copy the template's `<head>` (incl. inline `<style>`, **minus the leading `<!-- … -->` authoring comment** — it is authoring guidance and must never reach the rendered page), `<nav class="top-nav">`, `<header class="hero">`, and `<footer class="site-footer">` shells verbatim, adapting placeholders from Steps 2 + 4. The hero tagline is **one sentence**. Then emit the optional intro-zone blocks the repo supports (Step 4): `<section class="overview">` if an orientation source was found; `<section class="s" id="flow">` if you derived an accurate flow band; `<section class="s" id="entities">` if there's a real entity cast — drop each block otherwise, **and drop its `top-nav` anchor too**. Render one `<section class="s" id="sN">` per **non-empty** bucket in §1..§6 order; in §4 use `.conv-group` full-width labels to group convention cards by stack when more than one stack exists. Per card: a `.doc-type` badge (`D100`/`D101`/`E100` cyan, `Convention` violet, `Reference` teal, `Diagram`/`PDF` mute), a `.format-badges` row applying the de-dup rule (link to actual paths relative to `documentation/`), the `.doc-title`, `.doc-desc`, and `.doc-path` (link to the `.html` when both formats exist). `index.html` `<link>`s to `_chrome.css` — never inline the chrome CSS; use `.site-footer`, not a bare `<footer>`. No JavaScript beyond the template's own.

# Step 8 — Report

After writing, report:

1. Each target written / skipped, with the action and (for skips) the reason. The Codex subagent shells count as one target; if they were skipped because Codex could not get approval to write them, say that first, with how to finish.
2. The set of stacks detected (or "none detected — scaffold conventions manually when a stack lands").
3. One-line site stats: `<N> docs across <K> sections; <H>/<T> hand-crafted HTML`.
4. Any files under `documentation/` that fit no bucket — `Uncategorised — name & path:` one per line, with the most likely intended bucket.
5. A reminder that the `AGENTS.md` region reaches Codex on the **next** session (it loads at session start); that Codex loads the `.codex/agents/` shells only in a repo the developer has marked **trusted**, and only from the next session; and that the shells update when this skill runs again, not when the plugin updates. If the repo is also used with Claude Code, `/asimov-init` there writes `asimov.md` and the `CLAUDE.md` import; this skill does not. Suggest opening `documentation/index.html` in a browser.

# Hard rules

- **Read-only outside the declared targets.** Never call Write/Edit on any file except `AGENTS.md`, the `.codex/agents/*.toml` copies, the detected-stack `README.md`s, `documentation/index.html`, and `documentation/_chrome.css`. Never touch `asimov.md` or `CLAUDE.md` — they belong to `/asimov-init` in Claude Code. Never modify a source doc you index.
- **`AGENTS.md` outside the markers is the developer's.** Touch only the managed region; broken or duplicated markers stop the write to that file entirely — never guess which region is the real one, and never repair markers yourself.
- **The `AGENTS.md` region is Asimov-owned.** It is regenerated wholesale every run. Don't try to preserve hand-edits inside it; the developer's own context belongs outside the markers.
- **Scaffold structure, never invent content.** Convention READMEs are read-list skeletons with placeholders; never guess actual coding rules. Never author doc bodies (D100/D101).
- **Detect, don't assume.** Scaffold a convention folder only for a stack whose marker was found. No marker → no folder + an explicit report line.
- **Confirm before writing.** One consolidated write plan (Step 6); never write silently. Never overwrite an existing `index.html`, a differing `_chrome.css`, or a marker-less convention README without explicit confirmation.
- **Don't drift the templates.** Re-load all seven files (four templates, three definitions) and re-list the shells at the start of every invocation. The file-in-the-plugin is the run-time source of truth.
- **No JavaScript** in `index.html` beyond the template's own. Single self-contained-ish file: `index.html` inlines its component CSS but `<link>`s `_chrome.css`.

# Repo handling

The `documentation/` taxonomy (Step 4), the `AGENTS.md` managed-region markers, the `.codex/agents/` delivery folder, and the `<stack>` slugs are the conventions shared with `/d101-feature-design`, `/d101-review`, and `/d101-convert-to-html`. If the active repo uses a different layout, fork the patterns here and in those commands together — they share the path convention and must stay in lockstep (D100 hard rule 9).
