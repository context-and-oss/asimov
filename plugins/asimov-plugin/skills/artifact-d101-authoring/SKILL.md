---
name: artifact-d101-authoring
description: How to write or change a D101 feature-design file (documentation/features/D101-*.html and its mockups under documentation/features/mockups/d101-*/) so it still meets the D101 contract — the definition's bars and the HTML template's structure. Use whenever you create, render, edit, or fix any part of a D101, whether or not a slash command is running — "update §4.4 of this D101", "add a decision row", "render this as a D101", "fix the side-nav" — and inside /d101-feature-design and /d101-convert-to-html when they draft. Carries the rendering procedure and the authoring invariants; the contract itself is read from the plugin at run-time.
---

# D101 authoring

The method for producing or modifying a D101. It is the layer between the **contract** (the definition and the template, read from disk) and the **conversation** (a slash command's interview, phases and stops). This skill owns neither: it tells you what to read, how to render, and which invariants hold whenever a D101 changes — by a command or by hand.

## Read first

Load these with the file-read tool before touching a D101. Paths that start with `../../` are relative to this skill's own folder (`skills/<this-skill>/`), which the tool names when it loads the skill (Claude Code: the *Base directory for this skill* line; Codex: the skill's path in its listing). Resolve them from there, never from the working directory. If 1 or 2 cannot be read, stop and report the path — never author from memory; the file in the plugin is the run-time source of truth and drafting from a remembered copy is how the bars and the visual language drift.

1. **The definition** — the two bars (§2.1 business-complete, §2.2 gap-free), the phase/status axes (§2.3), requirement quality (§5), verification (§6), anti-patterns (§7), the checks (§8), the open-§6 block (§4.6), §6-vs-§7 (§4.8), accepted deviations (§4.9), review notes (§4.10):

   ```
   ../../artifacts/documentation/d101-feature-design/d101-feature-design-definition.md
   ```

2. **The HTML template** — its leading comment is normative: authoring ground rules 1–14, the archetypes, the N/A policy (N/A / OPEN / PENDING / ACCEPTED / conditional-omit), the component selection principles, the component catalogue, the non-canonical section types, and the hard style rules. Its body holds the structural shells you copy:

   ```
   ../../artifacts/documentation/d101-feature-design/d101-feature-design-template.html
   ```

3. **Best effort — the diagram templates**, read when you draw: the routing table at `../../resources/diagrams/README.md` and the notation template it points you at. If unreadable, draw a plain flowchart, say so in chat, and carry on — never stop over a diagram template.

4. **The repo's `CLAUDE.md`**, if present — repo-specific layout or naming you should respect. Absent is not an error.

**When editing an existing D101**, read the whole file too. Its phase chip, status chip, meta-strip date and side-nav are state you must keep consistent with what you change.

## What lives where

Do not restate the template's leading comment here or in a command — it is read at run-time. This skill adds only what the template does not say: the rendering procedure, the mockup rules, and the invariants.

| Question | Answer lives in |
|---|---|
| Which class renders which section? One cell = one sentence? Flows as SVG? | Template comment: *component selection principles* + *component catalogue* |
| What does N/A, open §6, pending §7, an accepted deviation look like? | Template comment: *N/A policy*; definition §4.6, §4.8, §4.9 |
| What must §2/§4 sound like? What is a good requirement, rule, AC, open question? | Template comment: *ground rules*; definition §5–§7 |
| Which sections may be omitted, which are stubbed? | Template comment: *N/A policy* exception |
| Bullets, symbols, badges, scripts, external refs? | Template comment: *hard style rules* |
| How do I assemble the page, the chips, the side-nav, the mockups? What may I never do? | **This skill** |

## Paths

- The D101: `documentation/features/D101-<slug>.html` (kebab-case slug, no `D101-` repeated). A legacy `.md` sibling is left alone.
- Its mockups: `documentation/features/mockups/d101-<slug>/<surface>.html`, parallel to `documentation/features/images/<doc-slug>/` for screenshots.
- Its review notes, when `/d101-review` has run: `documentation/features/D101-<slug>.review.md`. Read-only for you; the command that consumes them deletes them (definition §4.10).

## Rendering procedure

**Verbatim shells** — copy from the template, substituting placeholder text only: `<!DOCTYPE html>` + `<head>` (including the full `<style>` block); `<nav class="top-nav">` with **both** chips; `<div class="layout-doc">` + `<aside class="side-nav">` + `<article class="content">`; `<header class="hero">` (kicker, h1, tagline); `<div class="meta-strip">` (6 cells from §1); `<div class="doc-scope">`; `<footer class="site-footer">`. No `<script>` anywhere in the D101 page.

**Top-level substitutions:**

- `<title>` → `D101 — {feature name} — {repo} docs`. `.brand a` href stays `../index.html`.
- `.phase-chip` → `Business design`, or `Full design` with the `.full` class (ground rule 12).
- `.status-chip` → class per §1 Status (`.draft` for Draft; default for Approved); text is the Status value plus the version, e.g. `Draft v0.1`. **Every write bumps the minor version.** `Draft` stays `Draft` — approval is the business approver's move, never recorded by an author or a tool.
- Hero `.kicker` → `D101 · Feature design · {scope}`; `<h1>` → the feature name (a `<br>` for a natural two-line break is fine); `.tagline` → a one-paragraph paraphrase of §2 Purpose.
- `.meta-strip` → Owner, business approver, two derived fields from §1 (e.g. surfaces touched, schema change), Last updated (`YYYY-MM-DD`, today on every write), wire-compat or status indicator.
- `.doc-scope` → the §1 Scope row. At `Business design`, end it with one sentence naming what is settled and what is not (*"§2–§5 are the business agreement; §6 is open — see §6."*).
- Footer → `D101 · {feature} · {scope} · {status} · {YYYY-MM-DD}` plus the `← Documentation home` link.

**Side-nav** — one `<li>` per section the document carries. Nest §4.x under §4, §6.x under §6, §7.x under §7; §5 is a flat top-level entry. Anchor IDs match the section IDs (`#s2`, `#s3`, `#c4`, `#s4-1`, …, `#s5`, `#c6`, `#s6-1`, …, `#c7`, `#s7-1`, …). Omit N/A-stubbed sections from the side-nav **except** §5 UI Design and §7 Implementation, which stay listed even as stubs (top-level sections a reader must find). At `Business design`, §6 is a single flat `<li><a href="#s6-open">§6 Still to write</a></li>` and §7 a single flat `<li><a href="#s7-pending">§7 Implementation</a></li>`.

**Sections** — emit `<section class="s" id="sN">` per section, each `<h2 class="section-title">` opening with `<span class="sec-ref">§N.M</span>`; pick the component from the template catalogue after applying its selection principles. Chapter bands (`.chapter-band`, `id="cN"`) only for chapters with subsections (§4, §6, §7 when populated), each with the numeral and a one-sentence summary of what follows. Non-canonical sections render per the template's list; a section with no fit is plain prose (h2 + paragraphs), reported to the developer so the catalogue can grow — never an invented class.

**The two phase shapes.** The template's N/A policy defines OPEN and PENDING; these are the assembly consequences:

- *Business design*: §6 is the single `#s6-open` section (`.callout.warn` + the outstanding list, each item named by the consequence of not knowing it — *"how a total is counted independently of the rows returned, so a search cannot report three when the truth is three hundred"*, never *"§6.4 data shapes"*); no `#c6`, no §6.1–§6.8. §7 is the single `#s7-pending` stub with **no list**; no `#c7`, no §7.1+. §10 may be thin.
- *Full design*: `#s6-open` removed, `#c6` + §6.1–§6.8 emitted; `#s7-pending` removed, `#c7` + §7.1+ emitted or the §7 N/A stub for a pure-reuse build; side-nav flat entries replaced by the nested lists; phase chip flipped with `.full`; version bumped.

Moving from one shape to the other is the author's move (the phase axis). Never flip the chip without changing the body, and never change the body without the chip — a `Full design` chip above a `#s6-open` block is a finding on the next review.

**Diagrams.** §6.2 always carries an inline `<svg>` in `.flow-wrap` with `.flow-legend`; any other section may, when the notation fits. Type from the diagram README by reader intent, geometry and node budget from that template's leading comment; over-budget content splits into overview + detail. The numbered steps render below in `.principles`.

## UI mockups (§5, user-facing features only)

§5 is business design — *what the user sees* — so mockups are authored with §2–§5, before the phase stops. Backend-only: no mockup, §5 keeps its heading with the N/A stub.

- **Where.** One self-contained file per surface under `documentation/features/mockups/d101-<slug>/`, named for the surface (`main-grid.html`, `settings-panel.html`), not the slug. Create the folder if absent.
- **Self-contained.** All CSS and JS inline, no framework, no build step, no `<script src>` to a CDN; a single Google-Fonts `@import` is the only external reference. It opens by double-click.
- **Style source** — the developer's call, never a guess: a described style → apply it; a pointed-to project/component/file → **read those files first** and mirror their tokens, colours and control shapes; a screenshot → match its layout and palette; no preference → a neutral light app UI. In every case the mockup approximates the **real product UI, not the D101's dark chrome** — it is a design artifact of the feature, not a page of the doc site.
- **Interactivity bar.** The primary interactions the feature introduces actually work (toggle, filter, sort, open a panel, switch a tab — what a screenshot cannot convey); peripheral controls may be visually present but stubbed. A handful of representative sample rows, never lorem ipsum.
- **One or several.** One combined file when the surfaces share a live screen and the interactions flow into each other (a grid with its filter dropdown and slide-in panel); separate files when the user reaches surface B by *leaving* surface A (route change, wizard step, different view mode).
- **Embed.** In §5, per surface: a `.subhead` naming it, then `<iframe class="mockup-frame" src="mockups/d101-<slug>/<surface>.html" style="height:560px" title="<surface> interactive mockup" loading="lazy"></iframe>` (520–640px typical), then `ul.bullets` for layout notes and states.
- **Record the style basis** in one phrase in §5's intro `.section-desc` (*"styled after the existing order-list grid"*) so a review can check the mockup against it.
- **Portability.** The iframe path is relative: the D101 renders from the repo tree and breaks if mailed without `mockups/` — same as relative `<img>` screenshots.

**Converting** an existing document never authors a mockup: embed one only if the source already references it.

## Invariants

These hold on every change to a D101, by any route.

- **UTF-8 in, UTF-8 out.** Every file you read or write — the definition, the template, the D101 and its mockups — is UTF-8 without BOM, and they contain characters outside ASCII (dashes, arrows, section signs). When a file tool is available, use it. When you go through a shell instead, force the encoding on both ends: in PowerShell `Get-Content -Raw -Encoding utf8` and `Set-Content -Encoding utf8` (or `[IO.File]::ReadAllText` / `WriteAllText` with `[Text.UTF8Encoding]::new($false)`), never the shell's default code page. Before you report done, spot-check the written file for mojibake (`â€`, `Ã`) — finding any means re-write, not report.
- **Don't fabricate.** No guesses dressed as decisions. When the author doesn't know, write `TBD — verify` with a named decider (definition §4.3) — or, for mechanism at `Business design`, add it to the open-§6 list.
- **Don't invent mechanism to fill §6.** A §6 subsection you can only write by guessing belongs in the open-§6 list (definition §7 *Mechanism invented ahead of the business shape*).
- **Don't drift the template.** Section order, names and CSS classes as written; no new component classes, no reordering, no non-template sections beyond the non-canonical list.
- **Don't drift the definition.** When you want to skip one of its rules, ask the developer; if they decide to live with it, record it as an accepted deviation — a `.accepted` block inside the element it excuses, naming the rule, the one-sentence reason, the accepter and the date (definition §4.9, ground rule 14). Never against a whole §8 check, never in a side file, never proposed unasked: the fix is the default, the deviation is the exception someone puts their name to.
- **Never move the status axis.** `Draft` → `Approved` is the business approver's. You may move the phase (with the body); you never record an approval (definition §2.3).
- **Stop at Design.** No file paths, signatures, libraries or implementation approaches in §2–§6 beyond what §6 explicitly invites; the code-grounded recipe is §7 (definition §4.8), the deeper detail is an S102.
- **No verdict.** You may preview the applicable bar's checks (definition §8) to surface weak sections; you never declare the document business-complete or gap-free. §8a is the author's call, §8b the human reviewer's (≠ author).
- **Bump on write.** Every write advances the version in the status chip and sets *Last updated* to today. This is also what lets a stale `.review.md` be detected (definition §4.10).
- **Never write a maturity level into the D101.** The artifact's maturity is a chat notice from the producing command, not document content.
- **Re-read at run-time.** Load the definition and the template at the start of every session that changes a D101 — they may have moved since last time.
- **Renumbering or superseding leaves no stale pointer.** When a write renames a D101, supersedes another, or changes an R/NF/AC number, grep the repo for the old file name and the old numbers, fix the references you own, and list every remaining hit in the summary. Other documents, the definitions and the repo's own guidance point into a D101 by number.
