# Research — industry standards for design-doc completeness

> **Provenance.** Online research conducted 2026-05-21 to inform `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md`. Performed by a general-purpose subagent using WebSearch / WebFetch. Sources are cited inline and listed at the end.
>
> **What it informed.** `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md` §5 (requirement quality rules — Testable / Unambiguous / Atomic / Solution-free / Complete are lifted from Kiro), §6 (verification mandate — measurability rule from Microsoft DoR; counter-examples for business rules; EARS / Given-When-Then patterns), §7 (anti-patterns — intent drift, missing non-goals, compound requirements, etc.).
>
> **Question driving the research.** What makes a feature design document "gap-free" — defensible against (a) business sign-off and (b) downstream verification?

---

## 1. Industry frameworks worth lifting from

**Definition of Ready (DoR) — Scrum / Microsoft Engineering Playbook.** A DoR is "a set of criteria that a user story... must meet before it can be considered for inclusion in a sprint" and serves as "a quality gate." Microsoft's example checklist asks: *"Does the user story have clear and complete acceptance criteria?"*, *"Can we measure the acceptance criteria?"*, *"Is the user story blocked?"* — every item is a yes/no gate.

**INVEST (Bill Wake).** User stories must be **I**ndependent, **N**egotiable, **V**aluable, **E**stimable, **S**mall, **T**estable. "Testable stories have clear acceptance criteria that make it easy to determine if the story meets the expected outcome." The criterion you most want for D101 is **T**: if you cannot state how to test it, it is not done.

**Rust RFC template (`0000-template.md`).** Required sections in order: Summary, Motivation, **Guide-level explanation**, **Reference-level explanation**, **Drawbacks**, **Rationale and alternatives**, **Prior art**, **Unresolved questions**, **Future possibilities**. The Rust process explicitly states: "RFCs that do not present convincing motivation, demonstrate lack of understanding of the design's impact, or are disingenuous about the drawbacks or alternatives tend to be poorly-received." The **Unresolved questions** section is mandatory — not having open questions surfaced is itself a smell.

**MADR (Markdown ADR).** Mandatory sections: **Title, Context and Problem Statement, Considered Options, Decision Outcome.** Tradeoff analysis (pros/cons of options) is "crucial for understanding the reasons for choosing a particular design."

**Google design docs (Industrial Empathy).** Demands an explicit **Non-Goals** list: "non-goals aren't negated goals like 'The system shouldn't crash', but rather things that could reasonably be goals, but are explicitly chosen not to be goals." Trade-offs are the *point* of the document: "The design doc is the place to write down the trade-offs."

**Spec-Driven Development (Augment, Thoughtworks, BCMS, Kiro — 2025/2026).** Augment names six elements every spec must contain: **"outcomes when the work is done, in-scope and explicitly out-of-scope boundaries, constraints and assumptions, decisions already made, task breakdown, verification criteria."** Augment's load-bearing warning: *"leaving any of these elements open means the agent will answer them for you, in ways you won't like."* BCMS adds: *"Use EARS for acceptance criteria — every time"*, *"Spec the negative space"*, *"Keep specs short — 1–3 pages."* Thoughtworks insists specs include *"input/output mappings, preconditions/postconditions, invariants, constraints, interface types, integration contracts and sequential logic/state machines."*

## 2. Concrete completeness rules

- Kiro's four requirement-bug classes (lift verbatim as anti-patterns):
  1. *"Wrong level of detail"* (thesis statement or implementation recipe rather than testable constraint).
  2. *"Ambiguity — the same sentence has two plausible interpretations, and two developers would implement it differently."*
  3. *"Inconsistency — two requirements, each sensible in isolation, cannot both hold at the same time."*
  4. *"Incompleteness — behavior unspecified for whole regions of the input space."*
- Kiro's five quality properties: **Testable, Solution-free, Unambiguous, Consistent, Complete.** Definition of *Unambiguous*: *"Two independent readers would formalize an unambiguous requirement in the same way."* Definition of *Complete*: *"System behavior must be specified under any input combination."*
- Atomicity rule from requirements-engineering literature: *"Sentences including the words 'and' or 'but' should be reviewed to see if they can be broken into atomic requirements."*

## 3. Verification shape

**Gherkin / Given-When-Then** is the canonical acceptance-criteria template: *"Given some context, When some action is carried out, Then the observable consequences should follow."* Scenarios "serve as clear acceptance criteria that define when a user story is complete" and are executable as tests.

**EARS (Mavin, Rolls-Royce)** — five patterns:
- Ubiquitous: *"The <system> shall <response>"*
- State-driven: *"While <precondition>, the <system> shall <response>"*
- Event-driven: *"When <trigger>, the <system> shall <response>"*
- Optional: *"Where <feature included>, the <system> shall <response>"*
- Unwanted: *"If <trigger>, then the <system> shall <response>"*

EARS pairs well with D101's verification mandate because each requirement is structurally testable.

## 4. Anti-patterns

From the sources: **intent drift** (BCMS: *"incomplete specs lead to 'intent drift' where AI agents fill gaps with 'reasonable defaults' that don't match actual requirements"*); **implementation recipes masquerading as requirements** (Kiro); **plain PRDs without domain language** (Thoughtworks: requires *"domain-oriented ubiquitous language"*); **missing non-goals** (Google); **absent or hidden trade-offs** (Google, MADR); **unresolved questions without named deciders** (implicit in Rust RFC + DoR practice); **"and/but" compound requirements** (atomicity literature); **acceptance criteria expressed as opinions rather than measurable observables** (Microsoft DoR: *"Can we measure the acceptance criteria?"*).

## 5. Drop-in phrasings

Lifted into `plugins/asimov-plugin/artifacts/documentation/d101-feature-design/d101-feature-design-definition.md`:

- *"Every requirement is expressed in EARS form or Given-When-Then form. Prose-only requirements are rejected."*
- *"Every requirement is atomic: no compound 'and'/'but'. If two behaviors, split into two requirements."*
- *"Every business rule is accompanied by at least one positive example and one counter-example."*
- *"Every open question names a decider and a resolution deadline. Unresolved-without-owner is a blocker."*
- *"Every doc lists explicit Non-Goals — 'things that could reasonably be goals, but are explicitly chosen not to be' (Google)."*
- *"Behavior is specified under any input combination (Kiro completeness rule)."*
- *"Two independent readers must formalize each requirement the same way (Kiro unambiguity rule)."*
- *"Requirements are solution-free: they describe observable behavior, not implementation mechanism."*
- *"Trade-offs and rejected alternatives are documented; absence is a defect, not a virtue."*
- *"The doc is the contract for both stakeholder sign-off and automated verification: if a criterion cannot be checked against the running system, it does not belong."*

## 6. Sources

- [Definition of Ready — Microsoft Engineering Playbook](https://microsoft.github.io/code-with-engineering-playbook/agile-development/team-agreements/definition-of-ready/)
- [Definition of Ready — Atlassian](https://www.atlassian.com/agile/project-management/definition-of-ready)
- [INVEST Criteria — LeanWisdom](https://www.leanwisdom.com/blog/crafting-high-quality-user-stories-with-the-invest-criteria-in-safe/)
- [Rust RFC process — rust-lang/rfcs](https://github.com/rust-lang/rfcs)
- [0002-rfc-process — Rust RFC Book](https://rust-lang.github.io/rfcs/0002-rfc-process.html)
- [Rust RFC 0000-template](https://github.com/rust-lang/rfcs/blob/master/0000-template.md)
- [MADR — adr.github.io/madr](https://adr.github.io/madr/)
- [MADR GitHub](https://github.com/adr/madr)
- [EARS — Alistair Mavin](https://alistairmavin.com/ears/)
- [Adopting EARS Notation — Jama Software](https://www.jamasoftware.com/requirements-management-guide/writing-requirements/adopting-the-ears-notation-to-improve-requirements-engineering/)
- [Given-When-Then Acceptance Criteria — ParallelHQ](https://www.parallelhq.com/blog/given-when-then-acceptance-criteria)
- [Gherkin Acceptance Criteria — TestQuality](https://testquality.com/how-to-write-effective-gherkin-acceptance-criteria/)
- [Spec-Driven Development guide — BCMS](https://thebcms.com/blog/spec-driven-development)
- [Spec-Driven Development 2025 — Thoughtworks](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [What is Spec-Driven Development — Augment Code](https://www.augmentcode.com/guides/what-is-spec-driven-development)
- [Deep Spec Analysis — Kiro](https://kiro.dev/blog/deep-spec-analysis/)
- [Design Docs at Google — Industrial Empathy](https://www.industrialempathy.com/posts/design-docs-at-google/)
- [Requirements Testability via Smells — arXiv 2403.17479](https://arxiv.org/html/2403.17479v1)
- [A Practical Checklist for Testable Requirements — dev.to](https://dev.to/r_abhimaan/a-practical-checklist-for-writing-testable-requirements-1o85)
