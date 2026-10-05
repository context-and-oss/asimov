# Contract: design

What a design must contain before anything downstream plans or builds from it. A design is what the Design stage hands over, in whatever form it takes. This contract says what must be in it; not how it is written, where it lives, or who reads it. The members and their weight come from the models surveyed in `documentation/research/design-contract-research.md`; the *Grounded in* column names the models, the note holds what each of them says.

## Required members

| Member | Must say | Grounded in |
|---|---|---|
| **Reference** | Where the design lives and which version of it: enough for a reader to open the same text later. | ISO 29148, Rust RFC |
| **Approval** | That it may be built: a named person, a date, and where that is recorded. | Google design docs, Rust RFC, MADR, ISO 29148, Definition of Ready |
| **Problem** | Why this is wanted: the situation or use case that motivates it, in the author's words. | Shape Up, Rust RFC, ADR, ISO 29148 |
| **Decision** | What will be built, in prose. The shape of the solution, not the symptom, and not the code. | ADR, MADR, Shape Up |
| **Acceptance criteria** | Observable outcomes, each checkable without reading code. At least one. | ISO 29148, INVEST, Volere |
| **Out of scope** | What a reader might reasonably think belongs, and does not, with the reason. | Shape Up, Google design docs |
| **Ids** | A stable id on every rule (`R<n>`), acceptance criterion (`AC<n>`) and out-of-scope item (`OOS<n>`). | ISO 29148 |

## Members that are required when they exist

Each is stated, or the design says *none*. Silence is a gap.

| Member | Must say | Grounded in |
|---|---|---|
| **Rules** | Each business rule the build must respect, with the case it does not cover. | Gherkin, Specification by Example, ISO 29148 |
| **Open questions** | Each decision the design leaves open, with the person who decides it. | ISO 29148, Rust RFC, Spec Kit |
| **Assumptions** | What is taken to be true without being checked, so a reader can check it. | ISO 29148, Spec Kit, PR/FAQ |

## Optional members

| Member | Must say, when present | Grounded in |
|---|---|---|
| **Interfaces** | Named agreements between parts (an event, an endpoint, a type), each with its shape or a stable number (`§<n>`). | ISO 29148, Google design docs |
| **Non-functional requirements** | Each with a stable id (`NF<n>`) and a measure. | ISO 29148, Google design docs |
| **Alternatives** | The options considered and why they were not chosen. | MADR, Rust RFC, Google design docs |
| **Risks** | What could go wrong in the build, and what is done about it. | Shape Up, Rust RFC, ADR |

## Rules

- **Complete, or not a design.** A missing required member means nothing is planned or built from it. The gap is fixed in the design, never in a copy of it.
- **The author's words.** Whoever quotes a member quotes it verbatim; sorting and numbering is allowed, improving is not.
- **Ids are given once.** They are never renumbered while anything traces to them; a new item takes the next free number.
- **What, not how.** A design says what will be true; file paths, signatures and steps belong to the specification that follows.
