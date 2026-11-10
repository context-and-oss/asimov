---
artifact: site
maturity: assess
since: 2026-11-10
---

# Definition of the documentation site

The site a product repo's `documentation/` folder opens with: the front page `index.html`, the shared chrome `_chrome.css`, one page per section and per group under `_site/`, a rendering of every markdown document under `_site/doc/`, and the nav block every document carries. Written whole by `artifact-site-authoring` through its script from the templates in this folder; `asimov-init` calls the skill for its site target, and a person calls it alone to refresh the site after adding a document. The site indexes; it never authors.

Spiked by hand in a product repo on 2026-10-29 and 2026-11-10 (that repo's `documentation/analysis/2026-10-29-site-spike/`); redefined from the spike on 2026-11-10, replacing the one-page catalogue this definition described since 2026-09-10.

## 1. What it is for

- **One way in.** A newcomer opens one page, learns what the project is and which areas this repository holds, and finds every document by what it is for, two clicks away.
- **Never stale.** Every page the site owns is derived from the folder and written again on every run. Nothing on the site is typed into the site.
- **Whole from the first run.** Every section exists from the first run; an empty one says what belongs there and how it comes to be.

## 2. The bar: current

> **A site is current when a run of the script changes no file, every document the taxonomy places has a card and carries the nav block, every section has a page, and the front page's areas equal the project info's.**

## 3. Required content

### 3.1 The taxonomy

Fixed, in this order, every one a page: **Home**, **Architecture**, **Environments**, **Features**, **Testing**, **Project**, **Reference**. Two levels of navigation on every page: the sections, and the active section's children. No anchors in either.

| Section | Children, in order | Source |
|---|---|---|
| Home | none | the project info and the taxonomy |
| Architecture | *System landscape* (the `D100` naming no area) · one `D100` per area · *Code structure* (the drawings at the root) · *Conventions* (one group per stack under `conventions/`, the read-list first) | `documentation/D100-*`, `*.png`, `conventions/` |
| Environments | one page per area, the section-3 tables of its `E100` rendered (Name · dev · test · prod) · *Naming & rules* (the `E100` naming no area) | `documentation/E100-*` |
| Features | one group per area; a `D101` goes to the area its file name names, else to the first area this repository holds; a `*-template.md` is listed as a template | `documentation/features/D101-*` |
| Testing | *Strategy* (`T100`) · *<Area> test plan* (`T101`) | `documentation/T100-*`, `T101-*` |
| Project | *Project info* · *Risk log* (when written) · *Releases* (newest first) | `project/info.html`, `project/risk-log.html`, `documentation/releases/` |
| Reference | *Analyses* (`analysis/`) · *Research* (files directly under `reference/`) · *External* (folders under `reference/`) | `documentation/analysis/`, `documentation/reference/` |

### 3.2 The front page

Two sentences and two tables, nothing else: the project's one line and which areas this repository holds (from the project info); the areas table (Area · what its architecture document opens with · where it lives: *this repository*, the repository's name, or *not decided*); the what-is-where table, one fixed line per section plus *Readme* for the repository's readme when it has one. Without project info, the areas table is replaced by a note saying so and how it is written.

### 3.3 A card

One per document: its type (the family code or Convention, Index, Template, Release, Analysis, Note, Reference, Contract, Group), its title (the document's `h1`, a leading family code removed), its one line (the tagline, lede or first paragraph), the phase and status chips of a `D101`, and a format badge only for a file that is not a page. A group card counts its documents.

### 3.4 The nav block

Every page the site indexes carries the same block between `<!-- asimov-nav:start -->` and `<!-- asimov-nav:end -->`: the top nav (Home and the sections, nothing else), the sub-nav (Overview, the active section's children, the page's chips at the right), the sub-nav's styles inline for pages that do not link the chrome. Paths are relative to the page. The site rewrites the block on every run and touches nothing outside it. A page with neither the markers nor a `<nav class="top-nav">` is left alone and reported.

### 3.5 Rendered markdown

A markdown document gets a page under `_site/doc/` at its own relative path, from `document-template.html`: the frame, an *On this page* list from its `h2`s, a link to the source, links to rendered siblings pointed at the renderings. The markdown stays the record; the rendering is never edited. Rendering needs PowerShell 7 (`ConvertFrom-Markdown`); on Windows PowerShell 5.1 the cards link the `.md` and the report says how many were left.

## 4. Rules

- **S1 · The site is derived, never typed.** Every title, line and chip comes from a document or the project info; a wrong one is fixed there.
- **S2 · Areas are the axis.** Architecture, Environments, Features and Testing group by the project info's areas; the match to a file name is case-insensitive and ignores spaces and hyphens.
- **S3 · Every section is a page.** An empty section renders the `empty` block with the fixed lines for that section; nothing is dropped.
- **S4 · One card per document.** An `.md` beside an `.html` is one document, the `.html`; a `.pdf` beside either is its print.
- **S5 · The site owns its files and only them**: `index.html`, `_chrome.css` (a verbatim copy of the plugin's), `_site/**`, and the nav block in indexed pages. A page under `_site/` the model no longer produces is removed.
- **S6 · Wholesale and idempotent.** Every owned file is rendered every run; a second run writes nothing; `-Check` says whether a run would.
- **S7 · Static.** HTML and CSS only; no JavaScript, no inlined chrome on generated pages.
- **S8 · Excluded**: `_site/`, `index.html`, `_chrome.css`, any name starting with `_`, `README.md`, `specs/`, `decks/`, `images/`, `mockups/`, `_raw/`, `*.review.md`, `*.generated.html`. A file the taxonomy does not place is reported, never silently listed.

## 5. Relationship

| File | Role |
|---|---|
| `nav-template.html` | The nav block; its leading comment is the block's contract |
| `home-template.html` | The front page |
| `section-template.html` | A section or group page, with the blocks it is built from (card, grid, figure, table, empty) |
| `document-template.html` | The page a markdown document renders into |
| `_chrome.css` | The chrome every generated page links, copied verbatim to `documentation/_chrome.css` |
| `skills/artifact-site-authoring/SKILL.md` and `scripts/site.ps1` | The only writer |
| `artifacts/project/project-info/` | The project info the site reads for its areas and front page |
| `artifacts/documentation/d101-feature-design/d101-feature-design-template.html` | Authors the minimal nav block between the markers; the site rewrites it |
| `documentation/features/D101-asimov-init.html` | The command whose site target calls the skill |
