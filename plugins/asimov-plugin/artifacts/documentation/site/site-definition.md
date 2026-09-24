---
artifact: site
maturity: assess
since: 2026-09-10
---

# Definition of the documentation site

The landing page a product repo's `documentation/` folder opens with: `documentation/index.html` plus the shared stylesheet `documentation/_chrome.css`. Rendered by `/asimov-init` from `site-template.html` and `_chrome.css` in this folder. Design: `documentation/features/D101-asimov-init.html`.

## 1. What it is for

A newcomer opens one page and finds every document the repo has, sorted by kind, with a link to the polished version of each. The site indexes; it never authors.

## 2. Required content

- **Top nav and hero.** Repo name, a one-sentence tagline, anchors only to the sections actually rendered.
- **One chapter per non-empty bucket**, in this order: §1 Architecture (D100), §2 Features (D101), §3 Environments (E100), §4 Conventions, §5 Reference, §6 Diagrams. An empty bucket is dropped, never shown empty.
- **One card per documented concept.** A doc that exists as both `.md` and `.html` gets one card, linking the `.html`. Each card carries a type badge, format badges, title, one-line description and path.
- **Conventions grouped by stack** when more than one stack has conventions.

## 3. Optional content

An intro zone between hero and catalogue — an overview, a typed flow band, an entity gallery — only when the repo has a source for it: an architecture doc naming a pipeline, or three or more sibling docs of one kind. Never invented. An omitted flow band is reported as a suggestion, not drawn.

## 4. Rules

- Static HTML and CSS only. No JavaScript.
- `index.html` links `_chrome.css` and never inlines it. `_chrome.css` is a verbatim copy of the plugin's.
- The template's leading authoring comment never reaches the rendered page.
- Non-documents are excluded: anything starting with `_`, `*.generated.html`, a stray template copy.
- Re-rendering replaces `index.html` wholesale. It is Asimov-owned.

## 5. Relationship

| File | Role |
|---|---|
| `site-template.html` | Visual and structural contract; its leading comment is the component catalogue |
| `_chrome.css` | The site chrome `index.html` links to; D101 pages inline their own CSS and never link it |
| `documentation/features/D101-asimov-init.html` | The command that renders the site (R10–R12, R17–R19, NF3) |
