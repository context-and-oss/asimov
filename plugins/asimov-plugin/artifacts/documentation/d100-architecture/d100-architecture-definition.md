---
artifact: d100-architecture
maturity: assess
since: 2026-11-17
---

# Definition of D100

The written standard a D100 (architecture document) must meet before a feature is planned into the product it describes. A product carries one D100 per area; a feature design (D101) names the parts it changes and the decisions it leans on, and the Spec stage's Foundation realises what the D100 says about how the product runs and where its parts live. This document defines the bar, **current**, and the checks that show whether a D100 clears it (§6).

Read by humans (the architecture's owner, reviewers) and by the `asimov-design` asimov-skill (its architecture path) at run-time, through the authoring file beside it (`d100-architecture-authoring.md`).

---

## 1. What a D100 is for

A D100 answers the questions a feature design should never have to: what the product's parts are, how they talk, how the whole thing starts, where each part lives in the repository, and which decisions were taken on the way. It is written once per product and changed when the product changes shape; a feature changes a part, not the architecture, unless its design says so and the D100 gains a decision.

Two readers depend on it:

1. **The author of a feature design** names the parts the feature touches and the decisions it rests on, instead of describing the product again in §6.1 of every D101.
2. **The Spec stage** plans the feature into the parts, and for a part that does not exist yet cuts a Foundation that realises the D100's Run and Layout: the solution, the roots, the one command or IDE action that starts the product.

## 2. The bar

A D100 is **current** when every member of `contracts/architecture.md` is provided (§3.1) and its Run member is true: a person who clones the repository and follows §5.1 has the product running. Nothing is planned into a part the D100 does not name, and nothing is scaffolded in a layout the D100 does not state.

### 2.1 Status

The status chip carries `Draft` → `Approved`, the owner named in §1's call, with a version that moves on every write. The Spec stage plans from a D100 that clears the bar, whatever its status; the status says whether the owner has signed the shape, as the D101's says whether the business has.

## 3. Relationship to other documents

| Doc | What it answers |
|---|---|
| **D100** | What are the parts, how do they talk, how does the product start, where does each part live, what was decided? One per area |
| D101 | What feature, with what scope, what rules, what verifiable outcomes? Names D100 parts and decisions; never restates them |
| E100 | The environments the product is deployed to, by name, with their addresses and rules. The D100's §5.2 names them and points here |
| Conventions | How code is written in each stack. The D100 says which stacks; the conventions say how |
| Plan (S101 + S102) | In what order, by whom, with what check. Its Foundation realises §5 and §6 for a part that does not exist |

### 3.1 How a D100 meets `contracts/architecture.md`

| Member | Where in the D100 |
|---|---|
| Reference | The file path and the version in the status chip |
| Context | §2: the outside systems and people, and the boundary callout |
| Parts | §3: one row per part, its name in a `part-id` span, what it owns, its stack |
| Run | §5.1 the local start, as the command or the IDE action in a code span, with its prerequisites; §5.2 the environments by name, each with its document |
| Layout | §6: the solution or workspace file, and per part its root and its tests |
| Decisions | §8: one record per decision with context, decision, consequences and status |
| Ids | The `part-id` spans in §3 and the `ad-id` spans in §8 (`AD<n>`) |
| Connections | §4, or *none* |
| Constraints | §7, or *none* |
| Qualities | §9, when present |
| Risks | §10, when present |
| Glossary | §11, when present |

## 4. Required content

- **§2 Context.** Every system outside the product that a part calls or is called by, every kind of person that uses it, and the boundary: which calls leave the product and which never do. A context diagram in the C4 notation when the product has more than one outside party.
- **§3 Parts.** One row per unit that runs or deploys on its own: its name (stable; the id a D101 and a plan trace to), what it owns in one sentence, the stack it is built in. Never a component, a namespace or a class.
- **§4 Connections.** One row per pair of parts that talk: from, to, protocol, why. *none* for a one-part product.
- **§5.1 Locally.** The one command or the one IDE action that starts every part from a clean clone, in a code span; the prerequisites a developer installs once, each with the command that checks it. A sentence that describes the start without naming it fails check D3.
- **§5.2 Environments.** The deployed environments by name, each with what runs where in one line and the E100 that holds the detail, or *none yet* for a product not deployed.
- **§6 Layout.** The solution or workspace file at the root; per part its root folder and its test project or folder. The Foundation scaffolds exactly this.
- **§7 Constraints.** Each with its source. *none* when nothing is imposed.
- **§8 Decisions.** `AD<n>`, a title, then context, decision, consequences and status (`accepted`, `superseded by AD<m>`). A decision is never edited: a change is a new record. The first decision of a greenfield product is normally the stacks and the layout.
- **§9–§11** when present; omitted entirely otherwise, since they close the document.
- **§12 References.** The E100s, the conventions, the D101s that changed the shape.

## 5. Quality rules

- **Container altitude.** A part is something that starts, deploys or stores on its own. If two things always start together and share a process, they are one part.
- **What is true, not what is planned.** A D100 describes the product as it runs today; a part that does not exist yet is marked `planned` in its row and the Foundation that realises it removes the mark.
- **Run is testable.** The §5.1 line is the Foundation's checkpoint and the first thing a reviewer tries.
- **No feature content.** Rules, criteria and flows belong in a D101. A D100 names parts and decisions.
- **One decision, one record.** A superseded decision keeps its number and gains its successor's.

## 6. The checks

Run by the authoring file's preview before a write, and by a reviewer. One row each, Pass or Fail with one sentence.

| # | Check |
|---|---|
| D1 | §2 names every outside system a part calls or is called by, and the boundary callout says which calls leave the product. |
| D2 | §3 has at least one part; every part has a `part-id` span, one sentence on what it owns and a stack; no row names a component, namespace or class. |
| D3 | §5.1 carries one command or one IDE action in a code span, and every prerequisite has a check command. |
| D4 | §5.2 names every deployed environment with its document, or says *none yet*. |
| D5 | §6 names the solution or workspace file and, per part, a root and a test location; every part of §3 has a row. |
| D6 | §4 and §7 are each a table or an explicit *none*. |
| D7 | Every §8 record has `AD<n>` in an `ad-id` span, a context, a decision, consequences and a status; numbers are unique and never reused. |
| D8 | Every D101 in `documentation/features/` that names a part names one §3 has (by `part-id`), and every `AD<n>` a D101 cites exists in §8. |

## 7. Placement and naming

`documentation/D100-<area>.html`, the area as the project info names it (kebab-case), so the site lists it under *Architecture* as that area's document; a repository holding one area and no project info uses the repository's name. The D100 naming no area is the system landscape (site definition §3.1). Review notes, when a review writes them, sit beside it as `documentation/D100-<area>.review.md`, gitignored.
