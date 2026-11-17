# D100 authoring

*The method file of the D100 artifact, beside its definition and template. `asimov-design` reads it by path on its architecture path and follows it as written. A file, not a skill: nothing is substituted in it, so a sibling is named and anything else is `<plugin-root>/…`, the plugin root three folders above this file.*

The method for writing or changing a D100. It sits between the **contract** (the definition and the template, read from disk) and the **conversation** (the asimov-design interview and its stop). It tells you what to read, what to find out before you write, how to render, and which invariants hold whenever a D100 changes, by a skill or by hand.

## Read first

1. **The definition**, beside this file: the bar (§2), the mapping to the contract (§3.1), the required content (§4), the quality rules (§5), the checks (§6), the placement (§7):

   ```
   d100-architecture-definition.md — beside this file
   ```

2. **The HTML template**, beside this file. Its leading comment is normative for what a D100 does differently; for the component catalogue, the selection principles, the N/A policy and the hard style rules it defers to the D101 template's leading comment, `<plugin-root>/artifacts/documentation/d101-feature-design/d101-feature-design-template.html`, which you read once for those parts:

   ```
   d100-architecture-template.html — beside this file
   ```

3. **The contract** the document provides: `<plugin-root>/contracts/architecture.md`. Every member is a section; the definition §3.1 says which.

4. **The figure and diagram templates**, best effort, when you draw the §2 context: `<plugin-root>/resources/figures/README.md` and its map pattern.

5. **The repo**, in one message as parallel tool calls, before any question: `project/info.html` (the areas and the repository), `documentation/D100-*.html` (an existing D100), every `documentation/features/D101-*.html` (the parts and decisions they name, their §6.1 and §7.2), `documentation/conventions/*/README.md` (the stacks and their commands), the solution and project files (`**/*.sln*`, `**/*.csproj`, `**/angular.json`, `**/package.json` outside `node_modules`), `**/launchSettings.json` and `**/Properties/launchSettings.json`, the root `README.md`. What exists answers Parts, Layout, Run and the stacks before anyone is asked; what does not is a question.

## Paths

- The D100: `documentation/D100-<area>.html`, the area from the project info in kebab-case; the repository's name when it holds one area and has no project info. The D100 naming no area is the system landscape and is not what a feature plans into.
- Review notes, when a review writes them: `documentation/D100-<area>.review.md`, gitignored.

## What to find out, and from whom

The repo answers most members for a product that exists. For a product that does not yet (no project file for a stack the D101s name), the defaults below are stated to the owner in one message and taken with one word; the D100 then records them as the first decisions.

| Member | From the repo | Else the default stated |
|---|---|---|
| Parts | one per project that runs or deploys: a web or console project, an Angular workspace, a database the repo migrates | one per runnable thing the D101s name |
| Stacks | the project files | the D101s' §6.1 |
| Run, locally | `launchSettings.json`, `package.json` scripts, a `script/` folder, the README | `.NET`: F5 on the solution in Visual Studio and `dotnet run --project <api>` from a terminal, the UI served through the API's SPA proxy in development; a single stack: its template's run command |
| Run, environments | the E100s, the pipelines under `.github/` or `.azure/` | *none yet* |
| Layout | the solution file, the folders | `src/<Part>/`, `test/<Part>.Tests/`, `<Product>.slnx` at the root with every project, an Angular part under `src/<Part>/` and in the solution through the API's project file |
| Decisions | an existing D100, `docs/adr/`, `documentation/decisions/` | AD1 the stacks and the layout, AD2 how the product starts; each as the owner confirmed them |
| Context, Connections, Constraints | the D101s' §6.1 and §6.5, the README | asked, one question each, only when nothing names them |

## Rendering procedure

**Verbatim shells** from the template, substituting placeholder text only: `<!DOCTYPE html>` + `<head>` with the full `<style>` blocks; the nav block between `<!-- asimov-nav:start -->` and `<!-- asimov-nav:end -->` with its one chip (the site rewrites it on every site run; never add links); `<div class="layout-doc">` + `<aside class="side-nav">` + `<article class="content">`; `<header class="hero">`; `.meta-strip`; `.doc-scope`; the sections; `<footer class="site-footer">`.

**Substitutions:**

- `<title>` → `D100 — {product or area} — {repo} docs`. `.brand a` and every site link are relative to `documentation/`, where the D100 sits: `index.html`, `_site/architecture.html`.
- `.status-chip` → `Draft v0.1` on the first write; **every write bumps the minor version**. `Draft` → `Approved` is the owner's move, never yours.
- Hero `.kicker` → `D100 · Architecture · {area}`; `<h1>` the product or area name; `.tagline` the one paragraph the site shows on the Architecture page: what the product is, in how many parts, started how.
- `.meta-strip` → Owner, the part count, the stacks, the start in short (`F5 · HomeBar.slnx`), Last updated (today on every write), the decision range (`AD1–AD3`).
- `.doc-scope` → what this D100 covers and what it leaves to another D100 or to the D101s.
- Footer → `D100 · {name} · {repo} · {status} · {date}` with the `← Documentation home` link.

**Sections.** §2–§8 and §12 always; §9–§11 only when they have content, omitted entirely otherwise, and the side-nav lists only the sections present. Each `.data-table` is the div form of the template (`.row.head.cols-N`, `.row.cols-N`, the first cell `.label-cell`); one cell, one sentence. A part's name is a `<span class="part-id">` in §3 and plain text elsewhere; a decision's number a `<span class="ad-id">` in §8 and plain `AD<n>` elsewhere.

**Run.** §5.1's `.callout` carries the start as one `<code>` span: the command or the IDE action, exactly as a person would type or do it. Prerequisites each with their check command. A part that is `planned` in §3 still gets its line in §5.1 and §6: the Foundation builds what the D100 says.

**The context diagram.** When §2 has more than one outside party, an inline `<svg>` in `.flow-wrap`: the product's parts in the middle, the outside parties around, one arrow per relationship labelled with the protocol, drawn with the map pattern. One outside party or none: the table alone.

## Preview the checks

Before every write, answer the definition §6's eight checks on the rendered text, one line each, and fix a Fail before writing. D8 reads every D101 in the repo: a part a D101 names that §3 lacks is a Fail of the D100, never of the D101.

## Invariants

- **Don't invent a part.** A part exists because something runs or deploys on its own, or because a D101 at Full design says it will. A `planned` chip marks the second kind until the Foundation removes it.
- **Don't invent a start.** §5.1 names a start that works today, or the default the owner took for a planned part, marked as taken in AD2. Never a sentence instead of a command.
- **Don't drift the template.** Section order, names and classes as written; the CSS is the D101's and changes only there.
- **Decisions are appended.** A changed decision is a new `AD<n>` whose context names the one it supersedes, and the old record's status reads `superseded by AD<n>`.
- **Never move the status axis.** `Draft` → `Approved` is the owner's.
- **No feature content.** A rule, a criterion, a flow or a data shape that arrives in the interview goes to the D101 it belongs to, named back to the author.
- **Bump on write.** The version in the status chip and *Last updated* move on every write.
- **Renaming a part leaves no stale pointer.** Grep `documentation/` and `.asimov/plans/` for the old name, fix what you own, and list every remaining hit in the summary.
- **Report** the path, the part count, the start line and the decisions written, and every check's line.
