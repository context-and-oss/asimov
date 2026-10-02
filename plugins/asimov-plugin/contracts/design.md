# Contract: design

What a design must contain before anything downstream plans or builds from it. A design is what the Design stage hands over, in whatever form it takes. This contract says what must be in it; not how it is written, where it lives, or who reads it. The members and their weight come from the models surveyed in `documentation/research/design-contract-research.md`.

## Required members

| Member | Must say | Grounded in |
|---|---|---|
| **Reference** | Where the design lives and which version of it: enough for a reader to open the same text later. | 29148 revision notice; Rust RFC header |
| **Approval** | That it may be built: a named person, a date, and where that is recorded. | Google design docs; Rust sign-off; MADR status; 29148 owner; Definition of Ready |
| **Problem** | Why this is wanted: the situation or use case that motivates it, in the author's words. | Shape Up *Problem*; Rust *Motivation*; ADR *Context*; 29148 *Purpose* |
| **Decision** | What will be built, in prose. The shape of the solution, not the symptom, and not the code. | Nygard "We will…"; MADR *Decision outcome*; Shape Up *Solution* |
| **Acceptance criteria** | Observable outcomes, each checkable without reading code. At least one. | 29148 *Verifiable*; INVEST *Testable*; Volere *Fit criterion* |
| **Out of scope** | What a reader might reasonably think belongs, and does not, with the reason. | Shape Up *No-gos*; Google *Non-goals* |
| **Ids** | A stable id on every rule (`R<n>`), acceptance criterion (`AC<n>`) and out-of-scope item (`OOS<n>`). | 29148 identification: never changed, never reused |

## Members that are required when they exist

Each is stated, or the design says *none*. Silence is a gap.

| Member | Must say | Grounded in |
|---|---|---|
| **Rules** | Each business rule the build must respect, with the case it does not cover. | Gherkin `Rule` + `Example`; Specification by Example; 29148 abnormal responses |
| **Open questions** | Each decision the design leaves open, with the person who decides it. | 29148 "no TBD" + *Owner*; Rust *Unresolved questions*; Spec Kit clarification gate |
| **Assumptions** | What is taken to be true without being checked, so a reader can check it. | 29148 "shall be documented"; Spec Kit; PR/FAQ |

## Optional members

| Member | Must say, when present | Grounded in |
|---|---|---|
| **Interfaces** | Named agreements between parts (an event, an endpoint, a type), each with its shape or a stable number (`§<n>`). | 29148 *External interfaces*; Google *APIs* |
| **Non-functional requirements** | Each with a stable id (`NF<n>`) and a measure. | 29148; Google cross-cutting concerns |
| **Alternatives** | The options considered and why they were not chosen. | MADR; Rust; Google |
| **Risks** | What could go wrong in the build, and what is done about it. | Shape Up *Rabbit holes*; Rust *Drawbacks*; ADR *Consequences* |

## Rules

- **Complete, or not a design.** A missing required member means nothing is planned or built from it. The gap is fixed in the design, never in a copy of it.
- **The author's words.** Whoever quotes a member quotes it verbatim; sorting and numbering is allowed, improving is not.
- **Ids are given once.** They are never renumbered while anything traces to them; a new item takes the next free number.
- **What, not how.** A design says what will be true; file paths, signatures and steps belong to the specification that follows.
