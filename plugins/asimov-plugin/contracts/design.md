# Contract: design

What a design must contain for the Spec stage to plan from it. A design skill produces this; a spec skill consumes it. Neither side needs to know what the other is, as long as both keep to this contract. It names no particular form of design: an artifact's own definition says how that artifact meets it, and anything else is normalised into the file form in §3 by whoever plans from it.

Read at run-time by the skills that plan and validate (`asimov-spec`, `asimov-spec-validate`, `artifact-s101-authoring`, `artifact-s101-validation`, `artifact-s102-authoring`, `artifact-s102-validation`). A design artifact's definition points here; the S101 definition points here for its bar on the design (`s101-implementation-plan-definition.md` §3.1). Design: `documentation/features/D101-spec-stage.html`.

---

## 1. Why a contract

The Spec stage cuts a plan from a design. Before this contract, the only design it could read was a D101, and the plan's requirements, slices and traces were spelled in D101 terms. A bug fix that needs no D101 still has a design, in a ticket thread, and the next form of design will have another home. A plan should not care. This file is the interface: the members every design provides, and the form a design takes when it is not already a file in the repo.

## 2. Members

A design provides these, each findable by a reader who did not write it.

| Member | What it is | Why Spec needs it |
|---|---|---|
| **Reference** | Where the design lives and which version of it: a repo path and a version, or a url and the time it was read. | The plan links it; a re-run compares against it. |
| **Approval** | That the design may be built, by a named person on a date, and where that is recorded. | Nothing is planned from an unapproved design; the plan records who said go to the design. |
| **Decision** | What will be built, in prose: the shape of the solution, not the symptom. | The slices, the stacks and the interfaces are read from it. |
| **Rules** | The business rules the build must respect, each with the case it does not cover. | Each becomes a scenario with its counter-example in a task spec. |
| **Acceptance criteria** | Observable outcomes, each checkable without reading code. At least one. | One slice per criterion a builder can make pass; the slice's checkpoint is the criterion met. |
| **Out of scope** | What a builder might reasonably think belongs and does not. | The task specs' out-of-scope lines; the coverage map's edge. |
| **Ids** | A stable id on every rule, criterion and out-of-scope item, in the forms `R<n>`, `AC<n>`, `OOS<n>`; optionally `NF<n>` for non-functional requirements and `§<n>` for numbered contracts. | Traces and the coverage map hang on them; a re-run compares them. |

Optional members, used when present:

| Member | What it is |
|---|---|
| **Interfaces** | Named contracts between parts (an event, an endpoint, a type), with their shape or a stable number. The skeleton phase is cut from these. |
| **Open items** | Decisions the design leaves open, each with a decider. The Spec stage asks about those that change the breakdown, and no others. |

A design that lacks a required member is not planned. The gap is named and fixed in the design, never in a copy of it.

## 3. The file form

A design that is a file in the repo (a D101) is read where it is; its definition says which section provides which member. A design that is not (a ticket thread, a page elsewhere) is normalised into one gitignored file beside the plan it feeds:

```
documentation/specs/<slug>/design.md
```

```markdown
# Design — <title>

Reference: <url or path> · read <YYYY-MM-DD HH:MM>
Approval: <who> · <YYYY-MM-DD> · <where: a comment, a status, a signature>

## Decision
<the solution in prose, quoted from the source; several paragraphs are fine>

## Rules
- R1 · <the rule, quoted> — does not cover: <the counter-example, quoted or "none stated">
- R2 · …

## Acceptance criteria
- AC1 · <the observable outcome, quoted>
- AC2 · …

## Out of scope
- OOS1 · <quoted>

## Interfaces
- <name> · <shape or number>   (omit the section when the source names none)

## Open items
- <item> · decider: <who>   (omit when none)

## Source
<the description and every comment, verbatim, with author and date, so a reader can check the quotes above>
```

Rules for the file form:

- **Quoted, not rewritten.** Every member is the source's words. Normalising means sorting them under the right heading and numbering them, not improving them.
- **Ids are assigned once**, in reading order, and never renumbered while a plan traces to them. A new item takes the next free number.
- **Written by the skill that plans**, from a fetch or from pasted text; rewritten by the next run; rebuilt by a validation run that finds it missing. Never edited by hand: a correction goes into the source, and the next run reads it.
- **A cache, never a record.** It is gitignored. The source stays where it is; the plan links it and carries each id with its wording, so the plan and the link are all a reviewer needs. The file exists for the blind reader, who has no conversation and may have no way to reach the source.
- **Nothing beyond the source.** No assumptions, no decisions, no plan content. Those belong in the S101.

## 4. Who writes, who reads

| Side | Does |
|---|---|
| A design skill (`/d101-feature-design` today) | Produces an artifact whose definition states how it meets §2. |
| A person, in whatever tool holds the design | Supplies the members in the thread or page: the approval, the decision, the rules, the criteria, the exclusions. |
| `asimov-spec` | Reads the words of the message to find the design; reads it where it is, or fetches it and writes §3; checks §2 and refuses with what is missing; plans from it. |
| `asimov-spec-validate` | Reads the design the plan references; rebuilds §3 when it is missing and the source is reachable. |
| The artifact skills of the Spec stage | Read the design through its members only: a D101 by its definition's mapping, anything else through §3. They never read a source directly. |

## 5. Relationship to other contracts

A plan is to Build what a design is to Spec: the next contract is `contracts/specification.md`, what a spec must contain for the Build stage to run from it (the task graph machine-readable, every acceptance criterion runnable). Not written yet; the S101 and S102 definitions carry its content today.
