# Research — what an architecture must contain before a feature is planned

> **Provenance.** Online research conducted 2026-11-17 to ground `plugins/asimov-plugin/contracts/architecture.md`, the contract between the architecture of a product and the Spec stage that plans features into it. Performed in the session that wrote the contract, with WebSearch over the primary pages named in §5; the arc42, C4, Nygard and GitHub pages were read where reachable, ISO/IEC/IEEE 42010 and the SEI book from their published outlines and excerpts. Companion to [`design-contract-research.md`](design-contract-research.md) (what a feature design must hand over) and [`specification-contract-research.md`](specification-contract-research.md) (what a plan and its tasks must hand over).
>
> **What it informed.** The members of `contracts/architecture.md`, and the mapping table that says how a D100 (`artifacts/documentation/d100-architecture/d100-architecture-definition.md` §3.1) provides them.

---

## 1. Question

The Home Bar run of 2026-11-17 planned and built a feature whose design said "two application projects" and nothing about how they start together. No artifact in the chain carried that answer: the feature design is per feature and says what the product does; the conventions say how code is written; the plan said who builds what. The Foundation phase built two projects that each ran their tests and could not be started as one product. What must an architecture contain, per product, so that a feature design can lean on it and a plan's Foundation can realise it, according to models others have already argued for?

## 2. Sources read

Ten traditions, plus the templates in §5:

| # | Source | What it prescribes (short) |
|---|---|---|
| 1 | arc42 (Starke, Hruschka) | Twelve sections: introduction and goals (with the top quality goals), constraints, context and scope, solution strategy, building block view, runtime view, deployment view, cross-cutting concepts, architecture decisions, quality requirements, risks and technical debt, glossary. "Stick to level 1" of the building block view |
| 2 | C4 model (Brown) | System context, container ("a separately runnable or deployable unit"), component, code; a deployment diagram per environment showing container instances on deployment nodes; "most teams only need the first two levels" |
| 3 | Brown, *A minimal approach to software architecture documentation* | The minimal set: a system context diagram, a container diagram, one or more deployment diagrams |
| 4 | ISO/IEC/IEEE 42010:2022 | Stakeholders and concerns, viewpoints and views, correspondence between views, architecture decisions and their rationale recorded (6.10) |
| 5 | Kruchten, *The 4+1 View Model* (1995) | Logical, process, development (the programmer's organisation of the software: packages, components), physical (software on hardware), plus scenarios |
| 6 | SEI, *Documenting Software Architectures: Views and Beyond* (Clements et al., 2nd ed.) | A view packet: primary presentation, element catalog, context diagram, variability guide, rationale with rejected alternatives; "include the sections, marked none" |
| 7 | Nygard, *Documenting Architecture Decisions* (2011); MADR 4 | Title, status, context, decision, consequences, kept in the repository with the code; MADR adds drivers, options with pros and cons, confirmation; a decision is superseded, never deleted |
| 8 | The Twelve-Factor App (Wiggins) | Build, release, run as separate stages; a developer's machine is a deploy of the app; dev/prod parity; one codebase, many deploys |
| 9 | GitHub, *Scripts to Rule Them All*; Spolsky, *The Joel Test* | Standard entry points in every repository: bootstrap, setup, server, test, cibuild; "can you make a build in one step?" |
| 10 | Google design docs (Ubl; *Software Engineering at Google* ch. 10) | Context and scope with a system-context diagram, goals and non-goals, the design, alternatives considered, cross-cutting concerns |

## 3. Cross-source count

How many of the ten traditions name the member as required, with the sources that carry the strongest wording:

| Candidate member | Count | Strongest anchors |
|---|---|---|
| The parts: runnable or deployable units and what each owns | 8 | C4 container, arc42 §5 level 1, 4+1 development view, SEI module and component-and-connector views, Google, 42010, Brown's minimal set, 12-factor "one codebase per app" |
| Context: the people and systems outside, and the boundary | 7 | C4 system context, arc42 §3, SEI context diagram, Google system-context diagram, Brown's minimal set, 4+1 scenarios, 42010 stakeholders |
| How the parts run: on what, where, per environment | 7 | arc42 §7 deployment view, C4 deployment diagram per environment, 4+1 physical view, 12-factor run stage and dev/prod parity, Brown's minimal set, SEI allocation views, Scripts to Rule Them All `script/server` |
| Decisions with context, rationale and consequences | 7 | Nygard, MADR, arc42 §9, 42010 6.10, SEI rationale, Google alternatives, Brown ("a decision log") |
| Where the parts live in the repository | 5 | 4+1 development view, arc42 §5 (building blocks are "abstractions of source code"), SEI implementation view, 12-factor codebase, Scripts to Rule Them All (one layout a contributor recognises) |
| Connections between parts: direction and protocol | 5 | C4 relationships, arc42 §5 interfaces and §6 runtime view, SEI component-and-connector views, 4+1 process view, Google APIs |
| Constraints the architecture must obey | 4 | arc42 §2, 42010 concerns, SEI variability guide, Google |
| Quality goals that shaped the decisions | 4 | arc42 §1.2 and §10 ("the top three to five quality goals"), 42010 concerns, SEI rationale, Google cross-cutting concerns |
| A command that runs it from a clean clone | 3 | Scripts to Rule Them All (`script/setup`, `script/server`), the Joel Test ("one step"), 12-factor (a developer's machine is a deploy) |
| Risks and technical debt | 2 | arc42 §11, SEI rationale |
| Glossary | 2 | arc42 §12, SEI |
| Solution strategy | 1 | arc42 §4 |

Nothing is literally universal: the ADR tradition carries only decisions, the Twelve-Factor App only the run stage. Among the view-based traditions (arc42, C4, 4+1, SEI, 42010) parts, context, run and decisions are everywhere; layout and connections are the majority; constraints and qualities are a sizeable minority; the rest are arc42's alone.

## 4. Decisions for the contract (2026-11-17)

| Decision | Choice | Why |
|---|---|---|
| **Parts is a required member, at C4's container level** | Required | 8 of 10. The one abstraction every view tradition shares: the unit that runs or deploys separately. A feature design names the part it changes; a plan's Foundation creates the part that does not exist yet. Components and code are not members: "most teams only need the first two levels" (C4), "stick to level 1" (arc42) |
| **Context required** | Required | 7 of 10, and the three minimal sets (Brown, arc42, Google) all start with it. The boundary says which calls leave the product; the Home Bar design carried it in §6.1 because nothing else did |
| **Run is required, and must name how the product is started locally as a command or an IDE action, and the environments it is deployed to** | Required | 7 of 10 for the deployment view; the local start is the Twelve-Factor "developer's machine is a deploy", GitHub's `script/server` and the Joel Test's one step. The Home Bar run failed on exactly this member: two parts with test runners and no way to start the product. The deployed environments are named here and detailed in an environment document where one exists |
| **Layout required** | Required | 5 of 10, and the plan's Foundation needs it: the solution or workspace file, the root of each part, the test projects. Without it the Spec stage asked in chat (the bootstrap question of 2026-11-17) and the answer lived nowhere |
| **Decisions required, as a numbered log that is superseded, never edited** | Required | 7 of 10. Nygard's form (context, decision, consequences, status) is the common core; MADR's options are welcome and not required. 42010 makes rationale a normative part of an architecture description |
| **Connections: required when they exist, "none" said explicitly** | Required when present | 5 of 10; a one-part product has none. Direction and protocol are what a feature design's interfaces hang on |
| **Constraints: required when they exist** | Required when present | arc42 §2 and 42010 concerns; a product with no imposed constraint says so |
| **Qualities: optional** | Optional | arc42 insists on the top quality goals; the other traditions fold them into decisions. A feature design carries its non-functional requirements with measures; the architecture names the qualities its decisions traded on |
| **Risks and technical debt, glossary: optional** | Optional | arc42's alone among the ten |
| **Solution strategy: not a member** | Excluded | arc42's alone, and its content is the decisions and the parts seen together |
| **Components and code: not members** | Excluded | C4 and arc42 both advise against documenting below the container level by default; the feature design's §6 and the plan's task sections carry what a feature needs |
| **Ids: a stable name on every part, a stable number on every decision (`AD<n>`)** | Required | 42010 correspondence between views and 29148's identification rule, as the design contract applies it; a feature design and a plan trace to parts by name and to decisions by number |
| **Reference required** | Required | As the design contract: version or read time, enough to open the same text later |
| **One architecture per product, the stage reads it through its members** | Rule | The site taxonomy already has the place (Architecture: one D100 per area); a product with an architecture in another form (ADRs with a context page, an arc42 document) meets the contract through a mapping table the way a Jira ticket meets the design contract |

## 5. Sources

Primary pages read (fetched 2026-11-17 unless noted):

- arc42 overview and the twelve sections — https://arc42.org/overview · https://docs.arc42.org/home/ · https://examples.arc42.org/sections/
- arc42 runtime view and deployment view — https://docs.arc42.org/section-6/ · https://docs.arc42.org/section-7/
- C4 model: containers and deployment diagrams — https://c4model.com/abstractions/container · https://c4model.com/diagrams/deployment
- Simon Brown, A minimal approach to software architecture documentation — https://dev.to/simonbrown/a-minimal-approach-to-software-architecture-documentation-4k6k
- ISO/IEC/IEEE 42010:2022 (outline and preview) — https://www.iso.org/standard/74393.html
- Philippe Kruchten, Architectural Blueprints: The "4+1" View Model of Software Architecture, IEEE Software 12(6), 1995 — https://www.cs.ubc.ca/~gregor/teaching/papers/4+1view-architecture.pdf
- Clements, Bachmann, Bass et al., Documenting Software Architectures: Views and Beyond, 2nd ed. (outline and excerpts) — https://www.pearson.com/en-us/subject-catalog/p/Clements-Documenting-Software-Architectures-Views-and-Beyond-2nd-Edition/P200000000186/
- Michael Nygard, Documenting Architecture Decisions — https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- MADR — https://adr.github.io/madr/
- The Twelve-Factor App — https://12factor.net/ (build-release-run, dev/prod parity, codebase)
- GitHub, Scripts to Rule Them All — https://github.blog/engineering/engineering-principles/scripts-to-rule-them-all/
- Joel Spolsky, The Joel Test — https://www.joelonsoftware.com/2000/08/09/the-joel-test-12-steps-to-better-code/
- Malte Ubl, Design Docs at Google — https://www.industrialempathy.com/posts/design-docs-at-google/
- Software Engineering at Google, ch. 10 Documentation — https://abseil.io/resources/swe-book/html/ch10.html

Not fetched, cited for completeness: Michael Keeling, *Design It!* (the architecture haiku, a one-page architecture description); Microsoft Azure Architecture Center (architecture decision records guidance); the Open Group TOGAF Architecture Definition Document.
