---
type: approach
name: "Kanban"
anchored-to: Development
also-used-in: Operations
purpose: "The Kanban approach. Continuous flow without sprints, committing to a probabilistic forecast instead of a per-item estimate."
---

# Kanban

*An approach in the **Development** phase. Also the working cadence of Business Continuity in Operations.*

## 1. Purpose

Optimise the flow of value through the work, rather than the utilisation of the people doing it. Work is pulled when there is capacity, not pushed into a sprint. The commitment to the customer is a **Service Level Expectation** — a probabilistic forecast such as *"85% of items finish within eight days"* — instead of an estimate per item.

## 2. When to choose it — and when not

**Choose it when**

- The work arrives as a stream of items whose size and urgency cannot be known in advance: maintenance, support, continuous improvement, platform work.
- Priorities change faster than a sprint boundary. Waiting two weeks to re-prioritise costs more than it protects.
- The team is small, or shared across several customers, so a sprint commitment would be fiction.
- The customer's real question is *"when will my item be done?"*, not *"what will you deliver this quarter?"*

**Do not choose it when**

- The customer needs a date for a coherent release. Kanban forecasts individual items well and coordinated go-lives badly.
- Scope is fixed and priced up front. A fixed-price engagement wants a plan, not a queue.
- Nobody on the customer side can decide what comes next at the replenishment cadence. Kanban without an active prioritiser degenerates into first-in-first-out.

## 3. What it locks

**Nothing about scope, and nothing about dates for a given item.** It locks the *shape of the flow*: how much is in progress at once, which states work passes through, and the service level the customer can expect. That is a real commitment — just a different kind from a plan.

## 4. Activities

The approach exercises these disciplines. Each is described once in the discipline catalogue; here is when it happens and what is specific to Kanban.

**Once, at the start (or in Scoping)**

- **Define the workflow.** The single artefact this approach cannot run without. It must state: what counts as a work item · when an item is *started* and when it is *finished* · the states between them · the mechanism that limits work in progress · explicit policies for moving between states · the Service Level Expectation.
- *Disciplines:* Planning · Cadence and meeting structure · Onboarding the customer.

**Weekly — replenishment**

- Refill the ready queue. Only decide what comes next; do not re-plan everything.
- The customer's prioritiser must attend. This is the meeting Kanban cannot run without.
- *Disciplines:* Change handling · Issue handling.

**Daily — flow check (15 minutes)**

- Walk the board **right to left**: finish what is nearly done before starting anything new.
- Look at **work item age**, not at people. The question is "what is stuck?", never "what are you working on?".
- Unblock, or escalate the blocker the same day.
- *Disciplines:* Risk management · Issue handling.

**Continuously**

- Respect the WIP limit. When it is full, help finish something rather than start something.
- Pull only when there is a clear signal of capacity.
- *Disciplines:* Testing · Deployment (each item ships on its own).

**Monthly — service delivery review with the customer**

- Did we meet the SLE? Show throughput and cycle time, not effort.
- Agree changes to policies, WIP limits or the SLE itself.
- *Disciplines:* Status reporting · Expectation matching · Evaluation.

## 5. Output and artefacts

| Artefact | Note |
|---|---|
| **Definition of Workflow** | New to this approach. Not part of the old document chain — it needs a home and a code |
| **D100** | Maintained continuously, as in every approach |
| **D101** | Per item where the item warrants a design |
| **E200** | Deployment procedure — exercised per item, not per release |
| **Flow report** | WIP · throughput · work item age · cycle time. Replaces the status report's hour count |

## 6. Who does what

| Responsibility | Default owner |
|---|---|
| Definition of Workflow — written and kept current | Project Owner with ASWE |
| Facilitating replenishment | Project Owner |
| Facilitating the daily flow check | ASWE |
| Service delivery review with the customer | Project Owner, with Customer Owner present |
| Deciding what is pulled next | The customer's prioritiser, inside the agreed policies |
| Holding the WIP limit | ASWE — the one who must say no |
| Reporting flow metrics | Project Owner |

## 7. What it requires of the customer

State these in Scoping. Without them the approach does not work, and it is better to say so before signing than to discover it in month three.

| Requirement | Concrete |
|---|---|
| A prioritiser | One named person who can decide what comes next, present at every replenishment |
| Replenishment attendance | Weekly, 30 minutes |
| Response on blocked items | Within one working day |
| Acceptance of a probabilistic promise | The commitment is an SLE, not a date per item |
| Review participation | Monthly, one hour |

## 8. Execution — traditional and agentic

| | Traditional | Agentic |
|---|---|---|
| The board | A board and WIP limits. Nothing here needs AI | Unchanged — the mechanics are the same |
| The approval gate | A review column a human moves work out of | **A state with a WIP limit.** Limiting it is what stops agents outrunning the people who must approve their output |
| Work item age | Measured, sometimes | The metric that matters most. When agents build in hours, almost all elapsed time is waiting on a human decision, and this is the only measure that shows it |
| Forecasting | SLE from historical cycle time | Unchanged in method — but the history is worth less after a step change in throughput. Rebuild the SLE after the first agentic month rather than inheriting the old one |

## 9. Combines well with — and watch out for

**Combines well with**

- **Onboarding/handover** in Scoping. Taking over an existing solution produces exactly the kind of unpredictable stream Kanban handles well.
- **Business Continuity** in Operations. It is the same approach either side of the handover, which makes the handover cheaper.
- **Discovery** in Scoping, where the scope is deliberately left open.

**Watch out for**

- **Kanban + fixed price.** A fixed price wants a fixed scope; Kanban is built to let scope change. If the contract is fixed-price, bound it to a defined set of items and treat the rest as a separate agreement.
- **Kanban + Launch / hyper care.** Kanban ships items one at a time. A coordinated go-live needs a plan, so a project that must launch as a whole should use a different approach for that stretch.
- **An SLE nobody has agreed.** A forecast the customer has not accepted is not a commitment; it is a number we will be held to anyway.
