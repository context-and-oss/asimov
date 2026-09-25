---
type: phase
name: "Development"
order: 3
purpose: "Phase 3 of the Delivery Model. Building and putting into operation, and the five development approaches that differ in cadence."
---

# Phase 3. Development

**Purpose:** build, implement and put into operation. This is where the approaches genuinely differ — not in *what* gets built, but in the **cadence**: how often the customer sees something, how work is prioritised, and what you count.

| Approach | Cadence | Prioritisation | Unit | Chosen when |
|---|---|---|---|---|
| **Prototyping** | Loop: prototype → review → refine | The next open question | Time to an answer | The idea needs validating, or requirements cannot be written down yet |
| **Scrum** | Sprints of 2–4 weeks | Product and sprint backlog | Hours on PBI/task | Known scope, a plan to follow, a customer who wants progress at fixed intervals |
| **Use-case delivery** | Continuous, use case by use case | Feature roadmap | **Effort points** on PBI | Long-running collaboration, high trust, scope must be able to change |
| **Kanban** | Continuous flow, no sprints | Pull on capacity; replenishment | Throughput and cycle time; **SLE** replaces the estimate | A stream of unpredictable work, or a team for whom sprints are artificial |
| **Launch / hyper care** | Closing, time-boxed | Deployment and cut-over plan | — | A coherent set of functionality goes live at once |

## Prototyping

Loop: **prototype → review → refine**, repeated. Fidelity ladder: wireframe → Figma → agent-built code prototype. Choose fidelity by the question you are answering; do not build a code prototype to answer a question a sketch could have answered.

Agentic execution changes the economics here more than anywhere else in the model. A working code prototype used to be too expensive to use as a scoping instrument, so we drew wireframes. A code prototype is now roughly as fast to produce, and it is a far better basis for a decision than a document. **This is the point where agentic execution changes the most for the customer** — not in Development, where we simply build faster.

## Scrum

Sprints of 2–4 weeks, refinement, sprint planning, daily stand-up, demo, retrospective, test, UAT. Facilitation of the ceremonies is a line in the responsibility checklist with **Project Owner** as default owner.

## Use-case delivery

A pilot use case validates at small scale, then further use cases scale. Value-led. Estimation in effort points on PBI, prioritisation via a feature roadmap, sprint demo and quarterly business demo.

**Launch/hyper care does not apply.** Each use case goes into operation as it completes, so the deployment elements live inside each use-case cycle: test and approval procedure, E200, cut-over check. Only the elements that presuppose a single coordinated go-live — the hyper care period, the coordinated handover to operations — fall away.

## Kanban

Kanban is a strategy for optimising the flow of value through a process. It requires a **Definition of Workflow**: what a work item is, when it counts as started and finished, the defined states, a mechanism limiting work in progress, explicit policies for how items move between states, and a **Service Level Expectation** — a probabilistic forecast such as "85% of items finish within eight days". Four mandatory flow metrics: work in progress, throughput, **work item age**, cycle time.

Four properties make it a good fit for us specifically:

1. **The Service Level Expectation replaces the estimate.** Kanban does not estimate per item; it forecasts probabilistically from historical cycle time. That is a different shape of promise to a customer than a range of hours, and it is the only credible answer we have to "when will this be done?" in a stream of unpredictable work.
2. **Work item age is the metric agentic delivery needs.** When agents build fast, the bottleneck moves to the customer's approval speed. Work item age measures exactly that: items sitting and waiting for a human decision.
3. **The human approval gate is a state with a WIP limit.** Agentic execution fits Kanban structurally — spec → agent builds → *awaiting approval* → deploy. Limiting the approval state stops agents outrunning people.
4. **"Start with what you do now"** is the principle governing existing projects: they stay where they are and adopt the guide from there.

Kanban is not new here — the old decision-criteria table already prescribed "Kanban + task roadmap" for business continuity. One description, used in both Development and Operations.

## Launch / hyper care

Not optional where it applies — it is how the other approaches end. It holds the **E200** deployment procedure, the test and approval procedure, cut-over, and the intensive period after go-live. It is routinely omitted from planning and is a classic source of budget overruns.

## Artefacts in this phase

**D100 is started early and lives throughout.** It is opened before the individual feature designs, maintained for the life of the project, closed near the end, and handed to Operations as the basis for maintenance. It is the only artefact spanning Development and Operations.

Around it: **D101** feature design per feature → customer approval → build; **E100** IT environment; **E200** deployment procedure at release. The chain is the same regardless of approach and regardless of carrier.

## Traditional vs agentic

| | Traditional | Agentic |
|---|---|---|
| Spec | D101 written by hand | Spec generated wholly or partly by AI, edited and approved by a person, version-controlled beside the code |
| Build | A developer builds from the document | An agent implements and tests against the spec |
| Control | Line-by-line code review | **Human approval gate** plus outcome-based verification against the spec, with fixed escalation triggers: ambiguous requirement, security-sensitive change, breaking API change, budget exceeded, contradiction in the spec |
| Pipeline | Manual gates | Deterministic CI/CD |

**Customer cadence is a requirement, not a courtesy.** The old weekly cadence existed because we needed a week to produce something. When agents produce something approvable several times a week and the customer still looks on Fridays, we have gained nothing. Every approach therefore states what it **requires of the customer** in cadence, and that requirement is agreed in Scoping rather than discovered in month four.

---

Previous: [Phase 2. Scoping](scoping.md) · Next: [Phase 4. Operations](operations.md) · Back to [the framework](../delivery-model-framework.md)
