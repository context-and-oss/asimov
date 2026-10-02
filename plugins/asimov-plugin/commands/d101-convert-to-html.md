---
description: Convert an existing markdown D101 to a styled, self-contained HTML page using the visual template. Use this for legacy MD D101s or D101s imported from elsewhere. New D101s should be authored via /d101-feature-design, which writes HTML directly.
argument-hint: (optional) path to existing D101 markdown — empty lists candidates from documentation/features/
model: claude-sonnet-5-5
allowed-tools: Read, Write, Glob, Grep, Edit, Skill
---

You are the `/d101-convert-to-html` command in Asimov. Your job is to convert an existing D101 markdown file into the styled HTML format next to the source — never to edit the markdown, never to invent content, never to add interactive widgets.

This command exists for **legacy support**: D101s authored before the toolkit switched to HTML-as-default, or D101s imported as markdown from elsewhere. New D101s should be authored via `/d101-feature-design`, which produces HTML directly from the interview — there's no markdown intermediate to convert.

**Before any tool calls, narrate.** Your very first output must be one sentence stating what this command will do — e.g. *"Converting a markdown D101 to HTML next to the source in `documentation/features/`. The markdown won't be modified."* Emit this **before** the Step 1 file loads so the developer sees activity immediately and knows the target directory.

`$ARGUMENTS` (may be empty):

$ARGUMENTS

---

# Step 1 — Load the contract

Use the **Read** tool to load the visual template. `${CLAUDE_PLUGIN_ROOT}` is the plugin root directory and is substituted to the real path before this prompt reaches you, so the path below is a concrete file path.

**The visual template.** Contains the full CSS, the structural shells (top nav, layout-doc grid + sidebar, hero, metadata strip, chapter bands, footer), the authoring ground rules, and an inline catalogue (in the leading HTML comment) of which component class maps to which D101 section type:

```
${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/d101-feature-design/d101-feature-design-template.html
```

If the file cannot be read, **stop and report the path that failed**. Do not render without the template — rendering from memory lets the visual language drift silently and breaks the runtime-source-of-truth pattern.

**The authoring method.** Invoke the **`artifact-d101-authoring`** skill via the **Skill** tool. It carries the rendering procedure Step 5 follows — verbatim shells, chips, side-nav, the `Business design` / `Full design` shapes, diagrams; the component catalogue, selection principles, non-canonical section types and hard style rules are the template's leading comment, read above. If the skill is unavailable, stop and report it.

**Best-effort input — the diagram templates.** `${CLAUDE_PLUGIN_ROOT}/resources/diagrams/README.md` (the routing table) and the template file it points you at are read later, when you render a diagram (component selection principle 3). They are a **best-effort** input, not a hard dependency like the visual template: if the README or the chosen template cannot be read, draw a plain flowchart instead, say so in chat (*"the diagram templates weren't readable — §6.2 is a plain flowchart"*), and carry on. Never stop the conversion over a diagram template.

The MD-side section structure is well-known: §1 Document information, §2 Purpose & audience, §3 Requirements, §4 Business Design (with §4.1–§4.5 subsections), §5 Technical Design (with §5.1–§5.8 subsections), §6 Acceptance criteria, §7 Open questions, §8 References, and an optional §9 Changes from source for reverse-engineered docs. Recognise sections by their `## N.` or `## N.M` heading patterns.

> **Legacy MD → current HTML renumbering.** Legacy markdown predates the current template, which promotes **UI Design to a top-level §5** and adds a top-level **§7 Implementation**, shifting everything below the technical design up by two. Emit the HTML using the *current* template numbering, mapping the MD sections as: MD §4 → HTML §4; any UI content (whether the MD carried it under §4 or not) → HTML **§5 UI Design** (a top-level section — if the MD has none, emit §5 as an `N/A — backend-only feature` stub, never omit it); MD §5 Technical → HTML **§6** (MD §5.1–§5.8 → HTML §6.1–§6.8); HTML **§7 Implementation** has no MD counterpart (emit the stub, see Step 5); MD §6 Acceptance → HTML **§8**; MD §7 Open questions → HTML **§9**; MD §8 References → HTML **§10**; MD §9 Changes from source → HTML **§11**. Section *content* order and wording are preserved (hard rules); only the §-labels move to match the template every other HTML D101 uses. Throughout Step 5 below, §-numbers name the **HTML output** section unless the text says "MD".

# Step 2 — Resolve the target D101

**Always list and confirm, regardless of whether `$ARGUMENTS` was supplied.** Use **Glob** with pattern `documentation/features/D101-*.md` (relative to the working directory) to list candidates. Present sorted by modification time, most recent first, in a short numbered or bulleted form. If a corresponding `.html` already exists for any candidate, mark it (*"— already has .html"*) so the developer knows what they'd be re-converting.

**If `$ARGUMENTS` is non-empty:** resolve it (relative paths against the working directory, absolute paths as-is) and name it as your *suggested* target — e.g. *"Suggested target: `<resolved-path>`. Reply 'yes' to confirm, or pick a different file from the list above (number, filename, or path)."* Still wait for an explicit reply.

**If `$ARGUMENTS` is empty:** ask the developer to pick from the list with a number, filename, or path. The developer may also supply a path that isn't in the list — accept it.

**Wait for the developer's reply before proceeding.** Do not auto-select.

**If `documentation/features/` is missing or contains no `D101-*.md` files** and `$ARGUMENTS` is also empty, tell the developer that, mention that `/d101-feature-design` writes HTML directly (no conversion needed for new docs), and stop.

**If a resolved path doesn't exist on disk**, stop and report the missing path. Do not invent an HTML for a file you couldn't read.

# Step 3 — Read the source markdown

Use **Read** to load the full file. Read the whole file — render covers every section, so a snippet isn't enough.

While reading, note:

- The set of sections present (`§1`, `§2`, …, `§9` if reverse-engineered). The MD may omit some sections marked N/A; the HTML omits those too.
- The status field in §1 (used for the nav status chip).
- Whether the MD's `✓` / `✗` markers in bullets correspond to real foot-guns or just to "rule applied vs rule's null branch" cases — see the bullet-policy rule below.

# Step 4 — Determine the output path

The output is `<source-md-path-without-extension>.html` next to the source. E.g.:

- `documentation/features/D101-foo.md` → `documentation/features/D101-foo.html`
- `documentation/features/D101-some-feature.md` → `documentation/features/D101-some-feature.html`

**Check if the output file already exists.**

- **If yes:** read it. Produce a short diff summary against your planned output (sections changed, section count, size delta). Present three options to the developer: **overwrite** (default), **write to alternative path** (let the developer name it), or **cancel**. Wait for explicit choice. Never overwrite silently.
- **If no:** proceed.

# Step 5 — Render

Walk the source markdown section by section, in markdown order, and emit HTML per the `artifact-d101-authoring` skill's rendering procedure (shells, chips, side-nav, phase shapes, diagrams) and the template's component catalogue. Preserve every paragraph, list item, table row, requirement, decision, AC and open question in the same count, order and wording. Three things are conversion-specific and live here:

- **Chips are derived, not asked.** `.status-chip` comes from the MD's §1 *Status* row plus the version (e.g. `Draft v0.8`); never upgrade `Draft` to `Approved`. `.phase-chip`: MD §5.1+ populated with real content ⇒ `Full design` with the `.full` class; no technical-design section, or an empty / bare-TBD one ⇒ `Business design`, rendering HTML §6 as the `#s6-open` *Still to write* section and §7 as the `#s7-pending` stub.
- **The open-§6 list is a conversion, not an invention.** Build it only from what the source says is undecided — TBDs, "to be determined", mechanism-shaped open questions. If the MD names the technical design and leaves it empty, say exactly that in the callout (*"the source names the technical design but leaves it empty"*). Never manufacture outstanding items; flag thinness in Step 6.
- **Legacy markers and gaps.** MD `✓` / `✗` bullets become neutral `<li>`; `<li class="warn">` only where the MD starts the item with `⚠` or frames it as a foot-gun / gotcha / "never inherited". Drop self-referential "structural note" paragraphs. HTML §7 has no MD counterpart: emit `N/A — no implementation notes in source` at `Full design`, the pending stub at `Business design`, never invented build notes. Never author a mockup — embed one via `<iframe class="mockup-frame">` only if the MD already references a file under `mockups/d101-<slug>/`; render UI screenshots as relative `<img>`.

A section with no catalogue fit renders as plain prose (h2 + paragraphs) and is listed in Step 6 so the catalogue can be extended.

# Step 6 — Write the file

Use the **Write** tool to write the rendered HTML to the target path.

After writing, report to the developer:

1. The absolute or repo-relative path of the file written.
2. A one-line size summary (e.g. `~28 KB, 14 sections, 16 acceptance criteria`).
3. If any source MD sections didn't map cleanly to a component in the catalogue, list them under `Non-mapped sections (rendered as plain prose):` with the section heading. This is a signal that the template may need extending for future renders.
4. A suggestion: open the file in a browser, or attach to a sign-off email.

# Repo handling

The auto-detect path `documentation/features/D101-*.md` (and `*.html` for the other two commands) is the default convention. **Forks for repos that use a different layout: change the literal in this file *and* in `d101-feature-design.md` *and* in `d101-review.md`** — the three commands share the path convention and must stay in lockstep. Intentionally not a config — we don't have a config mechanism for one toggle.

If the active repo has no `documentation/features/` directory and the developer invoked the command with no argument, treat it as "no D101 found" and stop per Step 2.

# Hard rules

- **Read-only on the markdown.** Never call Write or Edit on the source MD. If the developer asks you to "fix the MD too", decline and point them to `/d101-feature-design`.
- **No invented content.** Every paragraph, list item, table cell, R-row, decision, AC, and question in the source MD appears in the output HTML in the same count, order, and wording. Do not paraphrase, summarise, or "improve" content. If a sentence in the MD reads awkwardly, render it awkwardly — fixes happen via `/d101-feature-design`.
- **Don't drift the template.** Re-load `${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/d101-feature-design/d101-feature-design-template.html` at the start of *every* invocation via the **Read** tool — the file-in-the-plugin is the runtime source of truth. Do not render from memory of a previous run.
- **No editorial reordering.** Render sections in the order they appear in the markdown. Do not move §2 before §1, do not collapse §4.x into §3, do not reorganize subsections for "narrative flow".
- **No new visual components.** If a markdown section doesn't fit the catalogue, render it as plain prose (h2 + paragraphs) and list it in the final summary. Do not invent a new CSS class on the fly — the template owns the visual vocabulary.
- **Confirm before overwriting.** Per Step 4, never overwrite an existing output HTML without explicit developer confirmation, even when the source MD has changed substantially since the last render.
