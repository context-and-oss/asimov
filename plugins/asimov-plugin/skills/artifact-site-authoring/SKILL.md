---
name: artifact-site-authoring
description: Use when asked to refresh, rebuild or check the documentation site, after a document is added, renamed or removed, and inside asimov-init. Runs the site script, the only writer of documentation/index.html, _site/ and the nav blocks; never authors a document or edits one beyond its nav block.
---

# Documentation site authoring

You run the script and relay what it says. The site is a rendering of the folder: the script derives the same model from the same documents every run and writes every page it owns again, so there is nothing for you to decide about content. You are the only writer of the site's files; nothing else writes `index.html`, `_chrome.css`, `_site/` or the nav blocks.

## Read first

Load with the file-read tool. In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex the variable stays literal and a `..` path resolves from the working directory, so derive the root once: take this skill's file path as Codex shows it, strip everything from `skills/artifact-site-authoring` onward, and use what remains as `<plugin-root>` in every path below, absolute. Verify it by reading file 1; if that fails, Glob `<home>/.codex/plugins/cache/**/site-definition.md`, take the match whose path shares the longest prefix with the skill path, and if nothing matches stop and report the path you derived and the search you ran.

1. **The definition**: what the site is, the taxonomy, where documents go, the rules.

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/site-definition.md
   ```

2. **The templates**, only where no PowerShell runs (the fallback below): each one's leading comment says how it is filled.

   ```
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/nav-template.html
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/home-template.html
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/section-template.html
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/document-template.html
   ${CLAUDE_PLUGIN_ROOT}/artifacts/documentation/site/_chrome.css
   ```

## The script

```
pwsh -NoProfile -File "${CLAUDE_PLUGIN_ROOT}/skills/artifact-site-authoring/scripts/site.ps1" [-Root documentation] [-Repo <name>] [-Plan | -Check]
```

(`powershell -NoProfile -ExecutionPolicy Bypass -File …` with only Windows PowerShell; in Codex `<plugin-root>` replaces the variable.) Run from the repo root. No switch writes the site and prints the report; `-Plan` prints the model and the files a run would write, as JSON, and writes nothing; `-Check` compares a run with the disk and exits 1 when the site is out of date, listing the files. Exit codes: 0 done, 1 (`-Check`) out of date, 2 an input could not be read. Relay the report as printed; never reword a refusal into a success.

## Inputs from the caller

| Input | Meaning |
|---|---|
| `verb` | `write` (the default), `plan`, or `check`. |
| `repo` | The repository's name when the git remote does not say it. [none: the script derives it] |

## The method

1. **Plan**, when the verb is `plan`: run `-Plan`, return the model's sections with one line per child (its kind, label and document count), the uncategorised files, whether project info was found, and the number of files a run writes. Stop.
2. **Check**, when the verb is `check`: run `-Check`, return its line (up to date, or the files that would change). Stop.
3. **Write**: run the script with no switch. Return the report as printed: files written and unchanged, documents per section, markdown rendered or left unrendered (Windows PowerShell 5.1 cannot render markdown; the cards then link the `.md`), pages where no nav block could be placed, files that fit no section, and whether project info was found.
4. **Say what to do about the report**, one line each, only for what the report lists: a file that fits no section goes under `documentation/analysis/`, `reference/` or `features/` or is removed; a page with no nav block gets `<nav class="top-nav"></nav>` once, after which the site keeps it; no project info means the front page says so until `asimov-project project info` writes it.

## The rules the script implements

The script is the method; these are its specification and the fallback where it cannot run.

- **The taxonomy is fixed**: Home, Architecture, Environments, Features, Testing, Project, Reference. Every section is a page; an empty one says what belongs there and how it comes to be. Nothing is hidden.
- **Areas come from `project/info.html`** (the project info): Architecture holds the landscape `D100` (the one naming no area) then one `D100` per area; Environments one page per area from the `E100` naming it, with its section-3 tables rendered, then the landscape `E100` as *Naming & rules*; Features one group per area, a `D101` placed by the area named in its file name and otherwise with the first area this repository holds; Testing the `T100` as *Strategy* and each `T101` as *<Area> test plan*. Without project info, the documents are listed by their own titles and the front page says the project info is missing.
- **Conventions** are a child of Architecture, one group per stack folder under `conventions/`, the read-list `README.md` first. **Code structure** is the drawings at the root of `documentation/`.
- **Project** lists `project/info.html` and `project/risk-log.html` when they exist, then the releases (`releases/`), newest first.
- **Reference** has three groups: analyses (`analysis/`), research (files directly under `reference/`) and external (folders under `reference/`).
- **One card per document**: an `.md` beside an `.html` is the `.html`; a `.pdf` beside either is its print and gets no card. A card carries the document's own title (its `h1`, with a leading family code removed), its one line (its tagline, lede or first paragraph), and for a `D101` its phase and status chips.
- **Markdown is rendered** into `_site/doc/<path>.html` from `document-template.html` with the frame and an *On this page* list, links to rendered siblings pointed at the renderings; the markdown stays the record and the rendering is never edited. Only on PowerShell 7.
- **The nav block** between `<!-- asimov-nav:start -->` and `<!-- asimov-nav:end -->` is written into every page the site indexes and every page under `project/`, the paths relative to each page, the section and child of the page active, the phase and status chips moved into the sub-nav. A page with neither markers nor a `<nav class="top-nav">` is left alone and reported.
- **Wholesale and idempotent.** Every owned file is rendered every run; a second run writes nothing. A page under `_site/` the model no longer produces is removed.
- **Excluded**: `_site/`, `index.html`, `_chrome.css`, any name starting with `_`, `README.md`, `specs/`, `decks/`, `images/`, `mockups/`, `_raw/`, `*.review.md`, `*.generated.html`.

## Where no PowerShell runs

When neither `pwsh` nor `powershell` runs, say so in one line and apply the rules above yourself for the pages the person needs now: the front page, the section pages and the nav blocks, each built whole from its template, never patched. End your return with *No script ran; the site was written by the rules alone and should be rebuilt with the script.*

## Never

- **Author or edit a document**: a title, a line or a chip the site shows comes from the document; a wrong one is fixed in the document.
- **Write outside the owned files**: anything but `index.html`, `_chrome.css`, `_site/` and the nav blocks.
- **Call another skill**, or ask the person a question yourself: what the report lists goes back to the caller.
- **Name a product entity** in your own text; the site's content is the repo's.

## Used by

- `asimov-init`: the site target, after the project info and the convention read-lists.
- By hand: "refresh the site", "is the site up to date", after a document is added or renamed.
