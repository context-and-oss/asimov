# Contract: architecture

What an architecture must contain before a feature is planned into the product it describes. An architecture is what a product carries once, for all its features, in whatever form it takes. This contract says what must be in it; not how it is written, where it lives, or who reads it. The members and their weight come from the models surveyed in `documentation/research/architecture-contract-research.md`; the *Grounded in* column names the models, the note holds what each of them says.

## Required members

| Member | Must say | Grounded in |
|---|---|---|
| **Reference** | Where the architecture lives and which version of it: enough for a reader to open the same text later. | ISO 42010, ISO 29148 |
| **Context** | The people and the systems outside the product that its parts talk to, and the boundary: which calls leave the product and which never do. | C4 system context, arc42 §3, SEI context diagram, Google design docs |
| **Parts** | Each unit that runs or deploys on its own, by a stable name, with what it owns and the stack it is built in. Nothing below that level. | C4 container, arc42 §5, Kruchten 4+1, SEI, ISO 42010 |
| **Run** | How the product is started: locally, as one command or one IDE action from a clean clone that brings every part up together; and deployed, the environments by name, with the detail in the environment document where one exists. | arc42 §7, C4 deployment, Twelve-Factor App, Scripts to Rule Them All, Joel Test |
| **Layout** | Where each part lives in the repository: the solution or workspace file, the root of each part, the tests of each part. | Kruchten 4+1 development view, arc42 §5, SEI, Twelve-Factor App |
| **Decisions** | Each architectural decision as a numbered record: the context, the decision, its consequences, its status. A decision is superseded, never edited or removed. | Nygard ADR, MADR, arc42 §9, ISO 42010 |
| **Ids** | A stable name on every part and a stable number on every decision (`AD<n>`). | ISO 42010, ISO 29148 |

## Members that are required when they exist

Each is stated, or the architecture says *none*. Silence is a gap.

| Member | Must say | Grounded in |
|---|---|---|
| **Connections** | For each pair of parts that talk: the direction and the protocol. | C4, arc42 §5 and §6, SEI, Kruchten 4+1 |
| **Constraints** | Each technical or organisational constraint the architecture must obey, and where it comes from. | arc42 §2, ISO 42010 |

## Optional members

| Member | Must say, when present | Grounded in |
|---|---|---|
| **Qualities** | The quality goals the decisions traded on, each with a measure. | arc42 §1 and §10, ISO 42010 |
| **Risks** | What could go wrong in the architecture and the technical debt carried, with what is done about each. | arc42 §11, SEI |
| **Glossary** | The terms the parts and the decisions use, each defined once. | arc42 §12, SEI |

## Rules

- **Complete, or not an architecture.** A missing required member means no feature is planned into the product from it. The gap is fixed in the architecture, never in a feature design or a plan.
- **Run is a command, not a description.** The local start names what a person types or clicks; a sentence that says the parts "are started together" does not meet the member.
- **The author's words.** Whoever quotes a member quotes it verbatim; sorting and numbering is allowed, improving is not.
- **Ids are given once.** A part keeps its name and a decision its number while anything traces to them; a changed decision is a new record that supersedes the old.
- **One architecture per product.** A feature design names the parts it changes and the decisions it leans on; it never restates them. A plan's Foundation realises Run and Layout for a part that does not exist yet; it never decides them.
