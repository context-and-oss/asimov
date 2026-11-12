---
artifact: project-info
maturity: assess
since: 2026-11-10
---

# Definition of the project info

The project's record: what the project is and for whom, its number, customer, language and the people in its fixed roles, and its **areas** with the repository that holds each. One page, `project/info.html`, beside `documentation/` and `specs/`, kept in the repository that holds the landscape architecture document; every other repository of the project carries a copy. It is the second artifact of the Project frame (D100 §3), after the risk log, and the first thing the documentation site reads.

Read by agents: `asimov-project` through `artifact-project-info-authoring`, the only writer; `artifact-site-authoring`, which reads the areas and the one line for the front page and groups the site by area; `artifact-risk-log-authoring`, which takes the project language from it and offers its areas for a risk's area. Read by people: anyone opening the site, where it is the first page of the Project section.

Design: spiked in a product repo on 2026-11-10 (its `documentation/analysis/2026-10-29-site-spike/`); the D101 is `documentation/features/D101-project-management-info.html` when written.

---

## 1. What the project info is for

- **Say what the project is, once.** One name, one line, one set of facts, the same whichever repository a reader opens.
- **Name the areas.** The project is split into areas (for a product that spans several systems, its systems; for others, its products, domains or teams), each held by one repository. The site groups by them; the risk log files risks under them; `asimov-init` learns from them what this repository holds.
- **Change rarely.** Project info is metadata, not a log: no history, no dates, no state. It changes when the project does.

## 2. The bar: current

> **The project info is current when its one page reads back in full, every area names a repository or says the repository is not decided, at least one area is marked as held by this repository, and the copies in the other repositories equal the page in the repository that holds the landscape architecture.**

## 3. Required content

### 3.1 Identity

| Field | Required | What it holds |
|---|---|---|
| Name | yes | The project's name, the page's heading |
| One line | yes | What the project does and for whom, in one sentence a customer would recognise |
| Project number | no | The engagement's number in the organisation's books; "not set" when none |
| Customer | no | Who the work is for; "not set" when none |
| Language | yes | The project language as a BCP 47 tag; the risk log writes in it |
| People | no | The fixed roles, one row each (project lead, product owner, …), with a person's name or "not set" |

### 3.2 Areas

| Column | What it holds |
|---|---|
| Area | The area's name, as people say it. For a system, the system's name as its architecture document says it |
| Repository | The repository that holds the area; marked *this repository* when it is the one the page is in; "not decided" when none yet |

One row per area, in the order the project lists them. An area held in this repository is one whose documentation the site in this repository renders: its architecture document (`D100-<Area>-*`), its environments (`E100-*-<Area>-*`), its feature designs and its test plan.

A **shared** line under the table names what is shared across areas (a common library, a shared platform), free text, optional.

## 4. Rules

- **PI1 · One page, no source beside it.** The page is the record. Nothing else holds the data, so nothing can drift from it.
- **PI2 · Canonical in one repository.** The repository that holds the landscape architecture document holds the project info; the other repositories carry a byte-equal copy with their own `this repository` marks resolved. A copy is refreshed by copying, never edited.
- **PI3 · Areas are the key.** The area's name on this page is the name every other artifact uses: the site's groups, a risk's area, the `D100-<Area>` scope in a file name. The match is case-insensitive and ignores spaces and hyphens.
- **PI4 · The areas held here are derived, never typed.** An area is held in this repository when its repository cell is this repository's name; the mark is rendered from that, not stored apart from it.
- **PI5 · No status, no dates.** The page carries no state, no history and no last-updated date. What changes, changes in git.
- **PI6 · Tables, not cards.** The page is two tables and three lines; the rendering adds links and marks and nothing else.

## 5. Relationship

| File | Role |
|---|---|
| `project-info-template.html` | The page the script renders and reads back; its leading comment names every element read |
| `skills/artifact-project-info-authoring/SKILL.md` and `scripts/project-info.ps1` | The only writer: turns the answers to its questions into the page, re-renders a page in the current template |
| `artifacts/documentation/site/` | The site reads the page for the front page's lede and areas table and to group the sections by area |
| `artifacts/project/risk-log/risk-log-definition.md` | The risk log takes the project language (its Q2) and offers the areas (RL13) from this page when it exists |
