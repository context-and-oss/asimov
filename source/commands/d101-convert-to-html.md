---
name: d101-convert-to-html
description: Convert an existing markdown D101 to a styled, self-contained HTML page using the visual template. Use this for legacy MD D101s or D101s imported from elsewhere. New D101s should be authored via /d101-feature-design, which writes HTML directly.
argument-hint: (optional) path to existing D101 markdown — empty lists candidates from documentation/features/
tier: medium
effort: medium
allowed-tools: Read, Write, Glob, Grep, Edit
---
{{model-check}}


You are the `/d101-convert-to-html` command in Asimov. Your job is to convert an existing D101 markdown file into the styled HTML format next to the source — never to edit the markdown, never to invent content, never to add interactive widgets.

This command exists for **legacy support**: D101s authored before the toolkit switched to HTML-as-default, or D101s imported as markdown from elsewhere. New D101s should be authored via `/d101-feature-design`, which produces HTML directly from the interview — there's no markdown intermediate to convert.

**Before any tool calls, narrate.** Your very first output must be one sentence stating what this command will do — e.g. *"Converting a markdown D101 to HTML next to the source in `documentation/features/`. The markdown won't be modified."* Emit this **before** the Step 1 file loads so the developer sees activity immediately and knows the target directory.

`$ARGUMENTS` (may be empty):

$ARGUMENTS

---

# Step 1 — Load the contract

Use the **Read** tool to load the visual template. `{{plugin-root}}` is the plugin root directory and is substituted to the real path before this prompt reaches you, so the path below is a concrete file path.

**The visual template.** Contains the full CSS, the structural shells (top nav, layout-doc grid + sidebar, hero, metadata strip, chapter bands, footer), the authoring ground rules, and an inline catalogue (in the leading HTML comment) of which component class maps to which D101 section type:

```
{{plugin-root}}/artifacts/documentation/d101-feature-design/d101-feature-design-template.html
```

If the file cannot be read, **stop and report the path that failed**. Do not render without the template — rendering from memory lets the visual language drift silently and breaks the runtime-source-of-truth pattern.

**Best-effort input — the diagram templates.** `{{plugin-root}}/resources/diagrams/README.md` (the routing table) and the template file it points you at are read later, when you render a diagram (component selection principle 3). They are a **best-effort** input, not a hard dependency like the visual template: if the README or the chosen template cannot be read, draw a plain flowchart instead, say so in chat (*"the diagram templates weren't readable — §6.2 is a plain flowchart"*), and carry on. Never stop the conversion over a diagram template.

The MD-side section structure is well-known: §1 Document information, §2 Purpose & audience, §3 Requirements, §4 Business Design (with §4.1–§4.5 subsections), §5 Technical Design (with §5.1–§5.8 subsections), §6 Acceptance criteria, §7 Open questions, §8 References, and an optional §9 Changes from source for reverse-engineered docs. Recognise sections by their `## N.` or `## N.M` heading patterns.

> **Legacy MD → current HTML renumbering.** Legacy markdown predates the current template, which promotes **UI Design to a top-level §5** and adds a top-level **§7 Implementation**, shifting everything below the technical design up by two. Emit the HTML using the *current* template numbering, mapping the MD sections as: MD §4 → HTML §4; any UI content (whether the MD carried it under §4 or not) → HTML **§5 UI Design** (a top-level section — if the MD has none, emit §5 as an `N/A — backend-only feature` stub, never omit it); MD §5 Technical → HTML **§6** (MD §5.1–§5.8 → HTML §6.1–§6.8); HTML **§7 Implementation** has no MD counterpart (emit the stub, see the Step 5 table); MD §6 Acceptance → HTML **§8**; MD §7 Open questions → HTML **§9**; MD §8 References → HTML **§10**; MD §9 Changes from source → HTML **§11**. Section *content* order and wording are preserved (hard rules); only the §-labels move to match the template every other HTML D101 uses. Throughout Step 5 below, §-numbers name the **HTML output** section unless the text says "MD".

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

Walk the source markdown section by section, in markdown order, and emit HTML that:

- Copies the template's `<!DOCTYPE html>`, `<head>` (including the full `<style>` block), top-nav shell, **`.layout-doc` grid wrapper + `.side-nav` (per-page TOC) + `<article class="content">` shells**, hero shell, metadata-strip shell, and `<footer class="site-footer">` verbatim. Adapt the placeholder text inside the shells to the source MD's content. The template carries no `<script>` — the output is fully static.
- **Populate `.side-nav` from the emitted output sections.** The sidebar lists the §-sections this HTML actually emits, at their HTML output numbers. Use nested `<ul>` for §4.x and §6.x subsections; §5 UI Design is a flat top-level entry (listed even when it carries an N/A stub), and a business-design output carries the single flat `§6 Still to write` entry instead of §6.x children. Anchor IDs (`#s2`, `#s3`, `#c4`, `#s4-1`, `#s5`, `#c6`, `#s6-1`, …) match the section IDs on the `<section class="s">` blocks below.
- **Top-nav is site-wide.** The brand and section links go to `../index.html` and `../index.html#s1..#s6` — they do NOT carry per-page anchors. The per-page anchors used to live in top-nav; they now live in `.side-nav`. Do not regress to per-page anchors in the top-nav.
- **Emits BOTH top-bar chips** (template ground rule 12 — two independent axes, `d101-feature-design-definition.md` §2.3):
    - `.status-chip` — from the source MD's §1 *Status* row, plus the version, as today (e.g. `Draft v0.8`). Never upgrade `Draft` to `Approved`; approval is the business approver's move.
    - `.phase-chip` — **derived from the source MD**, not asked for. A technical-design section with real content (MD §5.1+ populated) ⇒ `Full design`, with the `.full` class. A source with no technical-design section, or one that is empty / a bare TBD ⇒ `Business design`, and then the HTML technical design renders as the `#s6-open` *Still to write* section instead of §6.1–§6.8.
    - **Deriving the open-§6 list is a conversion, not an invention.** Build the outstanding list only from what the source MD actually says is undecided (TBDs, "to be determined", open questions pointing at mechanism). If the source has a technical-design heading and nothing under it, say exactly that in the callout — *"the source names the technical design but leaves it empty"* — and put the source's own mechanism-shaped open questions in the list. Never manufacture outstanding items the source doesn't support; flag the thinness in Step 6 instead.
- Adds a `.chapter-band` block before chapters with multiple subsections (HTML `§4` and `§6`; also `§7` when it carries build notes — but a converted legacy doc's `§7` is an N/A or pending stub, so no band). Singleton sections (`§2`, `§3`, `§5`, `§7` stub, `§8`, `§9`, `§10`) get no chapter band — just a regular `<section class="s">`.
- Maps each markdown section to the matching HTML component per the catalogue in `d101-feature-design-template.html` (in the leading HTML comment) and the table below.
- Substitutes content from the markdown into the components. Preserves all paragraphs, list items, tables, requirements, decisions, ACs, and open questions in the same count, order, and wording as the source MD.

## Component selection principles

These three principles bias the mapping toward HTML-native visual hierarchy. Apply them BEFORE consulting the mapping table — they override row-by-row defaults when a section's content shape fits a richer pattern.

1. **Tables, bullets, and prose — not content cards.** The four content-card families (`.problem-grid`/`.problem-card`, `.concept-row`/`.concept` pills, `.fields-grid`/`.field-card`, `.history-grid`/`.hist-card`) were removed from the template. Structured content now renders as `.data-table`, `<ul class="bullets">`, and prose under `.subhead`s. The only card-shaped components still in the template are `.q-card` (§9 open questions) and `.refs-block` (§10 references) — this converter never emits any of the removed families.

2. **One cell / one bullet = one sentence.** A table cell or a bullet carries a single sentence. An entry that needs a paragraph becomes prose under a `.subhead` instead of being crammed into a cell. Use `.data-table` for genuinely tabular reference material (term → meaning, setting → default → justification, enum values); use `<ul class="bullets">` for lists of facts or examples; use `.subhead` + a one-line rule + bullets when items each need their own small block.

3. **Flows are SVG, always.** §6.2 Data flow (or any "Data flow" / "Pipeline" / numbered processing-step section) renders as an inline `<svg>` in `.flow-wrap` whether or not the source MD has ASCII art. **Placement:** §6.2 always carries a diagram; any other section may carry one when the notation fits that section's content. Pick the diagram type from `{{plugin-root}}/resources/diagrams/README.md` by what the reader must understand — the type follows reader intent, not the section number — then follow that template file's leading comment for notation, node budget and geometry. Content over the type's node budget splits into an overview diagram plus a detail diagram; it never grows one diagram. The numbered list stays below as detailed step-by-step references — the SVG is the at-a-glance pipeline shape.

## Section → component mapping (canonical reference)

| MD section | HTML component(s) |
|---|---|
| §1 Document information | Hero kicker (`D101 · Feature design · {scope}`), gradient h1, tagline (paraphrase §2 Purpose in one sentence). `.meta-strip` cells (Owner, Approver, key derived values, Last updated). `.doc-scope` line below strip for Scope. **Both** chips in nav — `.status-chip` from the Status row, `.phase-chip` derived from whether §6 (technical design) has content (see Step 5). |
| §2 Purpose & audience | One crisp *why-now* `.section-desc` sentence, then `<ul class="bullets">` of the concrete production symptoms extracted from the Purpose paragraph (one `<li>` each — `<strong>lead</strong>` + one sentence). `.callout` summarising Primary audience. Drop §2 audience subsections that say "N/A". |
| §3 Requirements | Three `.subhead` groups (Functional / Non-functional / Out of scope), each a flat `.req-list` of `.req` rows — ALL visible, no tabs, no script. Functional requirements are `.req` rows with mono `.id` and prose `.body`; the non-functional list gets `.req-list.nf`; out-of-scope items are `.req.oos` rows. |
| §4 chapter heading | `.chapter-band` with numeral `4`, `.ch-name = "Business design"` (or the MD's own chapter title), and a one-sentence summary listing the subsections that follow. |
| §4.1 Principles | `.principles` numbered list. |
| §4.2 Concepts / Model | `.data-table` with two columns (Concept | What it means), one row per term. |
| §4.3 (per-field / per-item sub-blocks) | `.subhead` per item, then a one-line rule (`<p class="section-desc" style="margin-bottom:0.4rem">`), then `<ul class="bullets">` with concrete examples. |
| §4.4 (named rules) | `.subhead` per rule + a one-sentence statement + positive/counter-example `<ul class="bullets">`. Simple one-line rules with no examples collapse to a `.data-table` (Rule | What it means). |
| §4.5 Decisions | `.decisions` 3-column matrix (Decided / Alternative considered / Why rejected). |
| **§5 UI Design** (HTML top-level; from MD UI content, else N/A) | Plain `<section class="s" id="s5">` (h2 + §5 badge, no chapter band). If the MD carried UI content (surfaces, screenshots, mockup references), render it here as `.subhead` per surface + `ul.bullets` (embed an existing `mockups/…` file via `<iframe class="mockup-frame">` only if the MD already references one — never author a new mockup). If the MD has no UI content, emit a `.callout` reading `N/A — backend-only feature, no user-facing surface`. Never omit the section (it would leave a §4 → §6 gap). |
| **§6** (HTML) — source MD has no technical design, or an empty one | The `#s6-open` *Still to write* section instead of the chapter band and §6.1–§6.8: `.callout.warn` + `<ul class="bullets">` of outstanding items taken from the source's own TBDs and mechanism-shaped open questions. Sets `.phase-chip` to `Business design` and puts a single flat `§6 Still to write` entry in the side-nav. See Step 5. |
| **§6** chapter heading (HTML) — MD §5 populated | `.chapter-band` with numeral `6`. Sets `.phase-chip` to `Full design` with the `.full` class. |
| §6.1 Platform (MD §5.1) | Short prose paragraph + `.callout.warn` for any escalation gate the MD flags. |
| §6.2 Data flow (MD §5.2) | Inline `<svg>` in `.flow-wrap` — **whether the source MD has ASCII art or a numbered prose flow.** Any other section may carry a diagram too when the notation fits its content, but §6.2 is the only one that always does. Diagram type comes from `{{plugin-root}}/resources/diagrams/README.md`; that template file's leading comment governs notation, node budget and geometry. Palette: green = entry/gating, cyan = read or write to data store, amber = transform/decode, coral = destructive cleanup, dashed border + bg2 fill for stages delegated downstream. Add `.flow-legend` below. The detailed numbered list still renders below in `.principles`. |
| §6.3 Code map (MD §5.3) | `.codemap` rows. |
| §6.4 Shapes / Data model (MD §5.4) | `.subhead` per sub-block. Entity/field tables → `.data-table cols-2`. Path lists → `<ul class="gps-paths">`. |
| §6.5 APIs / contracts (MD §5.5) | `.callout` with the text (often "N/A — additive only"). |
| §6.6 Configuration & secrets (MD §5.6) | `.data-table cols-3` (Setting | Default | Justification), one row per setting. Wrap any unit suffix on the default in `<code>`. Flag security-sensitive settings in the Justification cell. |
| §6.7 Failure handling (MD §5.7) | `.failures` with `.sev` chips — infer severity from context (default Low when the MD doesn't flag it). This is the only rendering; there is no card-grid alternative. |
| §6.8 Known constraints & gotchas (MD §5.8) | One `.callout` per item (`.callout.warn` for hard surprises). A long list collapses to a single `<ul class="bullets">`. |
| **§7 Implementation** (HTML top-level; no MD counterpart) | Legacy MD D101s carry no implementation section, so there is nothing to convert. Emit the top-level §7 heading with a stub — an `N/A — no implementation notes in source` `.callout` when the derived phase is `Full design`, or the `#s7-pending` one-line stub when it is `Business design`. Keep it in the side-nav (a top-level section, like §5); never invent build notes. Outside the two bars (`d101-feature-design-definition.md` §4.8). |
| §8 Acceptance criteria (MD §6) | `.ac-table` rows with `.verify-chip` chips parsed from the MD's Verifies column. Each chip is one requirement ID or `§`-reference. |
| §9 Open questions (MD §7) | `.q-grid` of `.q-card` (`.q-id` chip + `.q-decider` chip + `.q-body`). |
| §10 References (MD §8) | `.refs` blocks per category. Use the MD's bold headings (Code: / Docs: / Diagrams: / Historical:) as the `<h4>` labels. |
| §11 Changes from source (MD §9, reverse-engineered only) | Same shape as §4.5 `.decisions` — a 3-col matrix (Area / Source said / Code does). |

## Non-canonical section types

Reverse-engineered / per-protocol D101s often have section types outside the canonical §1–§11 template. Render the common ones as:

| MD section pattern | Component |
|---|---|
| "Contract at a glance" / "Spec sheet" / key-value summary | `.data-table` (Field | Value), or `<ul class="bullets">` when the pairs are short |
| "Special flows" with sub-blocks | `.subhead` per sub-block + prose or `ul.bullets` per block |
| "Quirks and gotchas" | One `.callout` per item (`.callout.warn` for hard surprises), or `<ul class="bullets">` for a long list |
| "Testing" / test catalogue (Responsibility → Class) | `.codemap` with a `head` row |
| Single-dominant-fact section ("Algorithm: X, with N supporting properties") | A short `.callout`, or a `.subhead` + `<ul class="bullets">` for the supporting facts |

When a section truly has no fit, render as plain prose (h2 + paragraphs) and list it under "Non-mapped sections" in the final summary so the developer can extend the catalogue.

## Hard style rules

- **Use neutral `→` bullets by default.** Add `class="warn"` (which renders as `⚠`) only for `<li>` items that match one of: (a) the source MD bullet starts with `⚠`; (b) the MD explicitly frames the item as a "watch out", "foot-gun", "gotcha", or "never inherited"; (c) the item describes an outcome that would surprise a reviewer reading the rule.
- **Never emit `✓` or `✗` symbols in the output**, even when the source MD uses them. These symbols overstate contrast that often isn't there. Convert MD `✓` bullets to neutral `<li>`. Convert MD `✗` bullets to either neutral `<li>` (if the bullet describes the rule working in a different case) or `<li class="warn">` (if the bullet describes a real foot-gun per the rule above).
- **`§-numbers go inline.** Each `<h2 class="section-title">` starts with `<span class="sec-ref">§N.M</span>` before the topic name. Never put the §-reference on its own line.
- **Drop self-referential structural notes.** If the source MD has an italic paragraph explaining why §4.x uses a particular structure (e.g. "Structural note: §4.3 uses field-organised structure rather than..."), omit it from the HTML — the visual structure makes the choice self-evident.
- **Content fidelity: bodies trace to MD, titles may derive.** Headings (`.subhead` labels, `.data-table` header cells) and the hero tagline may paraphrase the MD's lead-in or key phrase. Body content — table cells, `.section-desc` rules, and bullet text — must trace to the source MD. Never invent a summary sentence that combines multiple MD bullets into one.
- **No interactive widgets, and no JavaScript at all.** No `<input type="range">`, no calculators, no fade-in animations, no scroll-triggered behaviour, no `<script>`. The output is a fully static page.
- **Never synthesize UI mockups.** This command does not create the §5 interactive mockups that `/d101-feature-design` produces; that would be inventing content. Render any UI section's screenshots as relative `<img>` tags per the existing image handling. If the source MD already references an existing mockup HTML file (under `mockups/d101-<slug>/`), you may embed it with the same `<iframe class="mockup-frame" src="...">` pattern the template defines, but do not author a new one.
- **Single self-contained file.** All CSS inline (from the template). No `<script src="...">` to a CDN. Google Fonts via `@import url(...)` is the only external dependency.

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

{{file-io}}
- **Read-only on the markdown.** Never call Write or Edit on the source MD. If the developer asks you to "fix the MD too", decline and point them to `/d101-feature-design`.
- **No invented content.** Every paragraph, list item, table cell, R-row, decision, AC, and question in the source MD appears in the output HTML in the same count, order, and wording. Do not paraphrase, summarise, or "improve" content. If a sentence in the MD reads awkwardly, render it awkwardly — fixes happen via `/d101-feature-design`.
- **Don't drift the template.** Re-load `{{plugin-root}}/artifacts/documentation/d101-feature-design/d101-feature-design-template.html` at the start of *every* invocation via the **Read** tool — the file-in-the-plugin is the runtime source of truth. Do not render from memory of a previous run.
- **No editorial reordering.** Render sections in the order they appear in the markdown. Do not move §2 before §1, do not collapse §4.x into §3, do not reorganize subsections for "narrative flow".
- **No new visual components.** If a markdown section doesn't fit the catalogue, render it as plain prose (h2 + paragraphs) and list it in the final summary. Do not invent a new CSS class on the fly — the template owns the visual vocabulary.
- **Confirm before overwriting.** Per Step 4, never overwrite an existing output HTML without explicit developer confirmation, even when the source MD has changed substantially since the last render.
