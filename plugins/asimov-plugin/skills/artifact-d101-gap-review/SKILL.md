---
name: artifact-d101-gap-review
description: The gap review of a D101 feature design — walk every section against the HTML template and the definition's quality rules, then run the checks of the bar the document's phase calls for (§8a business-complete while §6 is open, §8b gap-free once written), and report findings in two tables with no verdict. Use when asked to "gap-review this D101", "check this D101 against the bar", "does it pass §8a / §8b", "run the section walk", or when previewing a draft before a human review; also the method asimov-design-review delegates to for its gap review. Read-only, verdict-free: it surfaces evidence, never edits, never approves, never proposes an accepted deviation.
---

# D101 gap review

The method for judging one D101 against its contract. It answers *is the contract complete for the phase the document stands in?* — never *is it approved?* The bar verdicts belong to people: §8a to the author, §8b to a human reviewer who is not the author (definition §2). Automating either would collapse the reviewer-not-author gate, so this skill previews; it never decides.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-d101-gap-review` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/d101-feature-design-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran (the method of `D101-codex-support.html` §6.2). If 1 or 2 cannot be read either way, stop and report the path — never review against a remembered bar.

1. **The definition** — §2 (the bars and the two axes), §4.6 (open §6), §4.8 (§6 vs §7), §4.9 (accepted deviations), §5 (requirement quality), §6 (verification), §7 (anti-patterns), §8 (the ten checks and their bars):

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md
   ```

2. **The HTML template** — the leading comment's ground rules, N/A policy, selection principles, catalogue and style rules are what a section is judged against; the body is the canonical layout:

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/d101-feature-design/d101-feature-design-template.html
   ```

3. **The target D101** — the whole file, never a snippet: a review covers every section.

## Read the target

**Section recognition.** HTML: `<section class="s" id="sN">` / `id="sN-M"`, chapter bands `<div class="chapter-band" id="cN">`, the label in `<span class="sec-ref">§N</span>`; the substantive material sits in the components (`.data-table`, `.req-list`, `.ac-table`, …). Legacy markdown: `## N.` / `## N.M` headings, inline lists and tables.

**Archetype.** A non-empty §11 *Changes from source* means reverse-engineered; without §11, greenfield. The section walk has a §11 row only when the target has §11.

**Resolve the phase** before judging anything — it decides which bar runs (template ground rule 12):

| Signal in the target | Phase |
|---|---|
| `.phase-chip` reads `Business design`, or a `#s6-open` *Still to write* section is present | **Business design** → §8a |
| `.phase-chip` reads `Full design`, or §6.1+ are populated with no open block | **Full design** → §8b |
| Legacy `.md`, or `.html` with neither marker | **Full design** — say so in one sentence; the document predates the phase axis, so §8b is the fair bar |

If the signals disagree — a `Full design` chip above a `#s6-open` block, or a `Business design` chip above populated §6.1–§6.8 — that is itself a finding: report the phase the *body* shows and mark the §6 row **Fail** naming the contradiction.

**Read the status** (`.status-chip`: `Draft` / `Approved`, with its version). Show it as context; never change it.

**N/A handling.** A section holding only `N/A — <reason>` is a deliberate omission with a reason: **Pass** unless the reason is suspicious (an N/A on §3 Requirements is almost always wrong). §5 carrying `N/A — backend-only feature` is the expected shape for a backend-only feature: **Pass**.

**Open ≠ N/A.** An open §6 gives a *list*; an N/A gives a *reason* (definition §4.6). A §6 carrying an N/A stub instead of an outstanding list is **Fail**.

## Section walk

Walk §1 through §10 (plus §11 when present). Judge each against the template's section requirements and the definition's quality rules (§5, §6, §7). One of five severities per row:

| Severity | Meaning |
|---|---|
| **Pass** | Satisfies the template and the definition's rules. |
| **Open** | Deliberately unwritten at this phase, and says so properly. Only §6 (and §7 as *pending*) in a `Business design` document. Not a defect. |
| **Accepted** | Carries a finding the team decided to live with, recorded as a valid `.accepted` block. Report it, name the accepter, never re-argue it. |
| **Flag** | Structurally present with a quality issue — thin justification, one missing counter-example, a single decider-less TBD in a non-load-bearing row. Reviewable, not blocking. |
| **Fail** | Missing, structurally broken, or violating a load-bearing rule — anonymous TBD on a load-bearing decision, compound requirement, code-paraphrase as design, business design at code altitude, AC with no backward link, missing non-goal rationale. Address before human review. |

**§6 rule (phase-dependent).** `Business design`: §6.1–§6.8 are *supposed* to be absent. Collapse them into **one** row, `§6 Technical design`, judged only on the open block against definition §4.6: present, states the document is not gap-free, lists items named by the consequence of not knowing them ⇒ **Open**; a bare `TBD`, *"technical design to follow"*, or a restatement of the §6.x headings ⇒ **Fail** (check 9); no open block, or an N/A stub ⇒ **Fail** (check 9); subsections partially populated *and* an open block ⇒ **Fail**, naming the contradiction. **Never emit eight §6.x rows of Fail against a `Business design` document** — that misreading is the main thing this review must not do. `Full design`: judge §6.1–§6.8 individually; a leftover `#s6-open` ⇒ **Fail** (check 10).

**§7 rule (outside the bars).** §7 sits outside §8a and §8b (definition §4.8): its findings are template-conformance only and never change the bar. Judge presence and phase-shape, never depth. `Business design`: the `#s7-pending` stub ⇒ **Open**; a populated §7.1+ ⇒ **Flag** (recipe ahead of the contract); §7 absent ⇒ **Fail**. `Full design`: build notes or the `N/A — pure reuse` stub ⇒ **Pass**; a leftover `#s7-pending` ⇒ **Fail**; §7 absent ⇒ **Fail**. Never Fail §7 for being thin.

**Name anti-patterns** from definition §7 in the reason cell — *"compound requirement (§7)"*, *"code-paraphrase as design (§7)"*, *"business design at code altitude (§7)"*, *"anonymous TBD (§7)"*. They are not confined to §3/§4: an anonymous TBD belongs to the §9 row, a missing non-goal reason to §3, a code-paraphrase to §4.

**Business altitude, §2 and §4.** Read them as a product/business reviewer who does not know the codebase. Litmus (definition §7): strip every code identifier — interface/class/method names, framework calls, file paths — and if the narrative collapses, the row is **Fail**. Occasional parenthetical anchors are fine; a narrative that *depends* on them is not. This is the per-section form of check 7; a persona review is its reader-in-the-loop counterpart, and the two are complementary.

**Readability and §2 framing (conformance, not bar).** **Flag** a `.data-table` cell, bullet or `.subhead` rule line that runs to a paragraph (one cell = one sentence; the fix is prose under a `.subhead`), and a §2 `.section-desc` that front-loads history, analysis or numbers, or compounds several goals into one run-on, instead of one crisp *why-now* sentence. Never changes the bar.

**Blueprint discipline, §6.** §6 is a declarative build instruction; rationale lives in a decisions block (definition §4.7, anti-pattern *Rationale woven into the build spec*). Litmus per subsection: strip every *because / we chose / rather than / the reason is* clause — if the instruction still stands, those clauses belong in Decisions (**Flag**, pointing them there); if it collapses, the section hid spec inside prose and must be restated. When an implementer cannot act on §6 without extracting the instruction from the argument, that is a **gap-free (§8b) concern**, not a tidy-up.

**Accepted deviations (definition §4.9).** A `.accepted` block is **valid** when it names one rule instance, gives a one-sentence reason, names a person and carries a date. Then: the element's row is **Accepted** (accepter and reason in the cell), the §8 check that instance belongs to reads **Accepted** rather than Pass with the same reason, and `Accepted` never becomes `Pass` — the reviewer who owns §8b has to see what they are signing. Judge everything else in the element normally. It is **invalid**, and the finding stands at its normal severity, when it names no person or date (also **Flag** the suppression: *deviation without an accepter*); is written against a whole §8 check (**Fail**: *a deviation that swallows a check*); names several rules in one block (covers none — say the record was not honoured because it spans more than one instance); sits on no element (a general claim, not an instance); or annotates text since rewritten so the reason no longer describes it.

**TBD rule.** Flag any TBD or open question without a named decider (definition §4.3, §7). Do **not** flag a bare `TBD` for lacking the `— verify` suffix — that is asimov-design's output style, not a definition requirement.

**§5 UI Design (top-level, always present).** Infer from §2/§3 whether the feature is user-facing. Backend-only: the `N/A — backend-only feature` stub ⇒ **Pass**; §5 absent ⇒ **Fail** (a top-level section dropped). User-facing: follow each `<iframe class="mockup-frame">` `src` and read the mockup file(s) under `mockups/d101-<slug>/`, then judge — **presence/linkage** (§5 absent, no embedded mockup, or an `src` resolving to no file ⇒ **Fail**, check 8, at *both* phases); **one-vs-several** (mockup count vs the surfaces §5 describes: navigable screens crammed into one file, or one screen needlessly split ⇒ **Flag**); **styling fit** (reads as the product UI, not the D101 dark chrome, and is self-contained — dark doc tokens or a CDN `<script src>` ⇒ **Flag**; consistent with any recorded style basis); **interactivity** (primary interactions wired, not a static screenshot-in-HTML ⇒ otherwise **Flag**).

**Structural divergence is a Fail, not a guess.** Sections out of the template's order, renamed, using an invented component class, or omitted without an N/A reason ⇒ **Fail** with a one-sentence structural reason. Exception: no `#c6` and no §6.1–§6.8 in a `Business design` document is the template's own phase shape. Do not reinterpret what the author meant.

**One sentence per reason.** The author opens the file for more.

## Run the bar the phase calls for

Definition §8 is **one canonical numbered list** of ten checks; the numbers never shift. Run only the checks in the bar the phase resolved to, same severities, same one-sentence discipline, including **Accepted** for a check whose only outstanding instance carries a valid `.accepted` block.

| # | Check | Bar |
|---|---|---|
| 1 | Could two engineers implement this differently and both claim to follow the design? | both |
| 2 | For every observable behaviour named, is there a check that proves it works? | both |
| 3 | For every business rule, do I know what it does *not* cover? | both |
| 4 | For every open question, do I know who decides? | both |
| 5 | For every "out of scope", do I know why it's out? | both |
| 6 | Could one or more S102s be written from this without going back to the business? | §8b only |
| 7 | Could a product / business reviewer who doesn't know the codebase understand §2 and §4 — or does the narrative depend on named types, methods, framework calls, or any code-level mechanism? | both |
| 8 | *(User-facing only)* Is the UI specified concretely enough to build, with an interactive mockup demonstrating the primary surface(s)? | both |
| 9 | Is §6 declared open with a named list of what is outstanding? | §8a only |
| 10 | Is the phase `Full design` — §6 populated, no *still to write* block left? | §8b only |

- **`Business design` → §8a:** checks 1, 2, 3, 4, 5, 7, (8), **9**. Never run check 6 — a business-complete document deliberately cannot become an S102 yet; failing it for that inverts the bar.
- **`Full design` → §8b:** checks 1, 2, 3, 4, 5, **6**, 7, (8), **10**. Check 9 no longer applies.
- Check 8 only for user-facing features; backend-only **omits the row** rather than failing it. §7 is never part of either bar.

## Report

Emit in this order, to chat:

1. A `Phase:` line naming the resolved phase and its bar — `Phase: Business design — reviewed against §8a (business-complete)`; for a legacy `.md` or chip-less `.html`, `Phase: none recorded — treated as Full design, reviewed against §8b (gap-free)`.

2. `## Gap review — section walk` — a `| Section | Severity | Reason |` table, one row per section: §1 … §5, **one** `§6 Technical design` row at `Business design` (§6.1–§6.8 rows only at `Full design`), `§7 Implementation`, §8, §9, §10, and §11 only when present.

3. `## §8a — business-complete check` or `## §8b — gap-free check`, matching the phase — a `| # | Check | Severity | Reason |` table with the canonical numbers; omit the rows that do not belong to the bar rather than renumbering.

**No verdict.** No top-line "ready / not ready", no aggregated score, no "X of N checks passed". Findings tables only: §8a is the author's call, §8b the human reviewer's.

## Invariants

- **Read-only.** Never edit the D101, never write a file. If asked to "just fix it", decline and point at `asimov-design` (or the `artifact-d101-authoring` skill for a hand edit).
- **Resolve the phase before judging.** Never review a `Business design` document against §8b; an open §6 is **Open**, never Fail.
- **Never move either axis.** You set neither phase nor status; you may show the status, never change it (definition §2.3).
- **Never author or propose an acceptance.** Honour a valid `.accepted` block; never write one, never suggest a finding be accepted rather than fixed — a reviewer that offers the waiver excuses itself. If the author says a finding is settled, point them at `asimov-design` to record it.
- **No invented findings.** Report only sections and checks read from disk; a structurally damaged file gets **Fail** rows with structural reasons, not guesses.
- **Don't drift the bar.** Re-load the definition and the template at the start of every review.
- **Name anti-patterns explicitly**, and **one sentence per reason**.
