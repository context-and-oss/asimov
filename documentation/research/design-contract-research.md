# Research — what a design must contain before planning

> **Provenance.** Online research conducted 2026-10-02 to ground `plugins/asimov-plugin/contracts/design.md`, the contract between the Design and Spec stages. Performed by a general-purpose subagent using WebSearch / WebFetch; primary pages were read where reachable, and ISO/IEC/IEEE 29148:2018 was read from the standard's text. Companion to [`industry-design-doc-standards.md`](industry-design-doc-standards.md) (2026-05-21), which asked what makes a D101 gap-free; this note asks what *any* design must hand over, whether it is a D101 or an approved ticket thread.
>
> **What it informed.** The members of `contracts/design.md`, and the mapping tables that say how a D101 (`d101-feature-design-definition.md` §3.1) and a normalised design (`s101-implementation-plan-definition.md` §3.1, §9) provide them.

---

## 1. Question

The Spec stage cuts a plan from a design. Until 2026-10-02 the only design it could read was a D101, so "what a design contains" was the D101 definition. A bug fix that needs no D101 still has a design, in a ticket thread, and the next form will have another home. What must every design contain, according to models others have already argued for?

## 2. Sources read

Twelve traditions, plus the templates in §5:

| # | Source | What it prescribes (short) |
|---|---|---|
| 1 | Scrum Definition of Ready (Scrum Alliance, Scrum.org, Pichler, Agile Alliance) | Clear, feasible, testable; acceptance criteria defined and testable; dependencies identified; "all necessary stakeholders have approved the PBI" |
| 2 | INVEST (Wake, 2003) | Independent, Negotiable, Valuable, Estimable, Small, Testable ("I could write a test for it") |
| 3 | BDD, Gherkin, Specification by Example, Example Mapping (North, Cucumber, Adzic, Wynne) | Rules illustrated by concrete examples and boundary cases; Given/When/Then; red question cards mean "not ready" |
| 4 | Shape Up (Singer) | Problem, appetite, solution, rabbit holes, no-gos; the betting table names the deciders |
| 5 | Google design docs (Ubl; *Software Engineering at Google* ch. 10) | Context and scope, goals and non-goals, the design with its trade-offs, APIs, alternatives considered, cross-cutting concerns; "most teams require an approved design document before starting work" |
| 6 | Rust RFC template and process | Summary, motivation, guide- and reference-level explanation, drawbacks, rationale and alternatives, prior art, unresolved questions, future possibilities; sub-team sign-off before final comment period |
| 7 | ADR (Nygard) and MADR 4 | Context, decision ("We will…"), status, consequences; MADR adds considered options, decision-makers, confirmation |
| 8 | ISO/IEC/IEEE 29148:2018 | Requirement characteristics (necessary, unambiguous, complete, singular, feasible, verifiable, correct); a complete set "does not contain any TBD, TBS, or TBR"; attributes: unique id never changed or reused, version, owner, rationale; SRS outline with external interfaces, assumptions and dependencies, design constraints, verification |
| 9 | EARS (Mavin) | Five sentence patterns for requirements |
| 10 | Kiro specs; GitHub Spec Kit | Kiro: requirements with EARS acceptance criteria, approval gates between requirements, design and tasks. Spec Kit: mandatory user scenarios with Given/When/Then, functional requirements, measurable success criteria, assumptions, out of scope; "no [NEEDS CLARIFICATION] markers remain" before planning |
| 11 | Amazon PR/FAQ | Problem, solution, assumptions that must be true, risks; leadership decides to invest |
| 12 | Volere, Cockburn use cases, Spolsky, PEP 12, Kubernetes KEP, Oxide RFD, arc42, Atlassian PRD, Cooper's technical spec | Fit criterion, originator and approver, open issues "awaiting decisions", nongoals, rejected ideas, approvers, state machines for a design's life |

## 3. Cross-source count

How many of the twelve traditions name the member as required (● in the subagent's full matrix), with the sources that carry the strongest wording:

| Candidate member | Count | Strongest anchors |
|---|---|---|
| Problem / motivation | 11 | Every document-level tradition: Shape Up *Problem*, Google *Context and scope*, Rust *Motivation*, ADR *Context*, 29148 *Purpose/Rationale*, PR/FAQ |
| Approval / decider named | 9 | Google ("approved design document before starting work"), Rust sign-off, MADR `status: accepted` + decision-makers, 29148 owner and approved signature, DoR "stakeholders have approved" |
| Acceptance criteria / verifiable outcomes | 7 | 29148 *Verifiable*, INVEST *Testable*, Volere *Fit criterion*, DoR, Spec Kit, Kiro |
| Decision / solution stated | 6 | Nygard ("We will…"), MADR *Decision Outcome*, Shape Up *Solution*, Google, Rust, PR/FAQ; the requirements lineage keeps *how* out |
| Goals / success criteria | 5 | Google, Rust, 29148, Spec Kit, SbE |
| Interfaces | 5 | 29148 *External interfaces*, Google *APIs*, Kiro, Spec Kit "contracts defined", Rust |
| Risks / rabbit holes / drawbacks | 5 | Shape Up, Rust *Drawbacks*, ADR *Consequences*, 29148 *Risk*, PR/FAQ |
| Appetite / size | 5 | Shape Up, DoR, INVEST, 29148 *Feasible*, PR/FAQ |
| Non-goals / out of scope | 4 | Shape Up *No-gos*, Google *Non-goals*, 29148, Spec Kit; also Spolsky, KEP, PRD |
| Rules with examples and counter-examples | 4 | Gherkin `Rule` + `Example`, Adzic's key examples, Rust guide-level, 29148 "responses to abnormal situations" |
| Non-functional requirements / constraints | 4 | 29148, Google cross-cutting concerns, DoR constraint cards, Spec Kit |
| Open questions with a named decider | 4 | 29148 "no TBD/TBS/TBR" + *Owner*, Rust *Unresolved questions*, Spec Kit clarification gate, Cockburn "awaiting decisions" |
| Reference / version / date | 4 | 29148 revision notice, Rust header, MADR date, Spec Kit header |
| Stable ids / traceability | 4 | 29148 identification "never changed, never reused", Volere, Rust, ADR |
| Assumptions | 3 | 29148 "shall be documented", Spec Kit, PR/FAQ |
| Alternatives considered | 3 | MADR *Considered Options*, Rust, Google: all three decision-record traditions |

Nothing is literally universal, because INVEST and EARS are sentence-level models with no sections. Among the ten document-level traditions, *problem* and *approval* are everywhere; *acceptance criteria* and *decision* are the majority; the rest are a sizeable minority each, and *appetite* is Shape Up's alone.

## 4. Decisions for the contract (2026-10-02)

| Decision | Choice | Why |
|---|---|---|
| **Problem is a required member** | Added; it was missing from the first draft | 11 of 12. A design without the why cannot be re-cut when a task fails; Rust: an RFC without "convincing motivation" is "poorly received" |
| **Approval is required, recorded by a named person with a date and a place** | Kept | 9 of 12. The sources split on *where* it lives (a field in the document, or a gate outside it); the contract asks only that it exists and can be found |
| **Decision is required, as what will be built, not how in code** | Kept | The design-doc lineage requires it; the requirements lineage excludes *how*. A ticket thread's decision is prose; a D101's is §4 and §6. Code-level how stays the Spec stage's (S102) |
| **Acceptance criteria required, observable, at least one** | Kept | 7 of 12, and the S101 cuts one slice per criterion |
| **Out of scope required, each with its reason** | Kept | Shape Up and Google make the strongest case; Spolsky, KEP and the PRD template agree |
| **Rules with counter-examples: required when any exist, "none" said explicitly** | Changed from always-required | Four traditions, but a small fix may have no business rule; an explicit "none" keeps the reader from guessing |
| **Open questions with a decider: required, "none" allowed** | Reinstated, under its proper name, after being dropped as unexplained "open items" | 29148's "no TBD" rule with the *Owner* attribute is the strongest standards anchor of the thin members; Rust and Spec Kit gate on it. A design with an unowned question is not ready |
| **Assumptions: required when any exist, "none" allowed** | Added | 29148: "all assumptions… shall be documented"; Spec Kit records defaults there; PR/FAQ asks what must be true |
| **Stable ids required** | Kept, with the never-renumber rule | 29148 identification: "never changed… nor reused"; the plan's traces hang on them |
| **Reference required** | Kept | Version or read time; 29148 revision notice, Rust header |
| **Interfaces, non-functional requirements, alternatives, risks: optional** | Interfaces and NFRs kept optional; alternatives and risks added as optional | Each is a minority member with a strong anchor in one lineage; a ticket rarely has them, a D101 always does (§6, §3 NF, §4.7, §4.5). The Spec stage uses interfaces for the skeleton and NFRs for constraints when present |
| **Goals / success criteria: folded into Problem and Acceptance criteria** | Not a separate member | The sources that require goals also require acceptance criteria; one member that says what is observable covers both for planning |
| **Appetite / estimate: not a member** | Excluded | Shape Up's alone as a solution-constraining budget; the estimate question is open in D100 Q7, and the S101 with its tiers is its natural neighbour |

## 5. Sources

Primary pages read by the subagent (fetched 2026-10-02 unless noted):

- Scrum Guide 2020 — https://scrumguides.org/scrum-guide.html
- Scrum Alliance, Definition of Ready vs. Definition of Done — https://resources.scrumalliance.org/Article/definition-vs-ready
- Scrum Alliance, Pros and Cons of a Definition of Ready — https://resources.scrumalliance.org/Article/pros-cons-definition-ready
- Scrum.org, Walking Through a Definition of Ready — https://www.scrum.org/resources/blog/walking-through-definition-ready
- Roman Pichler, The Definition of Ready — https://www.romanpichler.com/blog/the-definition-of-ready/
- Agile Alliance glossary, Definition of Ready — https://www.agilealliance.org/glossary/definition-of-ready/
- Bill Wake, INVEST in Good Stories, and SMART Tasks — https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/
- Dan North, Introducing BDD (via Agile Alliance; page blocked) — https://dannorth.net/introducing-bdd/
- Cucumber, Gherkin reference — https://cucumber.io/docs/gherkin/reference/
- Cucumber, BDD — https://cucumber.io/docs/bdd/
- Matt Wynne, Example Mapping — https://cucumber.io/blog/bdd/example-mapping-introduction/
- Gojko Adzic, Specification by Example (sample chapter) — https://gojko.net/books/specification-by-example/
- Gojko Adzic, Focus on key examples — https://gojko.net/2014/05/05/focus-on-key-examples/
- Shape Up, Write the Pitch — https://basecamp.com/shapeup/1.5-chapter-06
- Shape Up, The Betting Table — https://basecamp.com/shapeup/2.2-chapter-08
- Malte Ubl, Design Docs at Google — https://www.industrialempathy.com/posts/design-docs-at-google/
- Software Engineering at Google, ch. 10 Documentation — https://abseil.io/resources/swe-book/html/ch10.html
- Rust RFC template — https://github.com/rust-lang/rfcs/blob/master/0000-template.md
- Rust RFC process — https://github.com/rust-lang/rfcs/blob/master/README.md
- Michael Nygard, Documenting Architecture Decisions — https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- MADR — https://adr.github.io/madr/
- ISO/IEC/IEEE 29148:2018 (standard text; outline also at https://en.wikipedia.org/wiki/Software_requirements_specification)
- Alistair Mavin, EARS — https://alistairmavin.com/ears/
- Kiro, Specs — https://kiro.dev/docs/specs/ and https://kiro.dev/docs/specs/feature-specs/requirements-first/
- GitHub Spec Kit, spec template, specify command, methodology — https://github.com/github/spec-kit/blob/main/templates/spec-template.md · https://github.com/github/spec-kit/blob/main/templates/commands/specify.md · https://github.com/github/spec-kit/blob/main/spec-driven.md
- Working Backwards, PR/FAQ — https://workingbackwards.com/concepts/working-backwards-pr-faq-process/
- Kubernetes KEP template — https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md
- PEP 12 — https://peps.python.org/pep-0012/
- Oxide RFD 1 — https://rfd.shared.oxide.computer/rfd/0001
- Volere, Atomic Requirements and the template — https://www.volere.org/wp-content/uploads/2018/12/06-Atomic-Requirements.pdf · https://www.volere.org/templates/volere-requirements-specification-template/
- Alistair Cockburn, use case template — https://www.cs.otago.ac.nz/coursework/cosc461/uctempla.htm
- Joel Spolsky, Painless Functional Specifications, part 2 — https://www.joelonsoftware.com/2000/10/03/painless-functional-specifications-part-2-whats-a-spec/
- Zara Cooper, A practical guide to writing technical specs — https://stackoverflow.blog/2020/04/06/a-practical-guide-to-writing-technical-specs/
- Atlassian PRD template (page blocked; fields from Atlassian's PDF) — https://www.atlassian.com/software/confluence/templates/product-requirements
- arc42 — https://arc42.org/overview
- Marty Cagan, Assessing Product Opportunities — https://www.svpg.com/assessing-product-opportunities/

Not fetched, cited for completeness: Kano model, Jobs To Be Done (HBR 2016), Opportunity Solution Tree (Torres), Impact Mapping (Adzic), User Story Mapping (Patton), Use-Case 2.0 (Jacobson), C4 model (Brown), ISO/IEC/IEEE 42010.
