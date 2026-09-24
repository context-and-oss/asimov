---
type: approach
name: "Scrum"
anchored-to: Development
purpose: "The Scrum approach. Sprint-based delivery against a known scope, with project management running alongside the ceremonies."
---

# Scrum

*An approach in the **Development** phase.*

## 1. Purpose

Deliver a known scope in fixed intervals, so the customer sees working software at a predictable rhythm and can correct course at each boundary. Sprints of 2–4 weeks, each aiming at a potentially shippable increment.

The point that is easy to miss: **Scrum here runs alongside a project-management discipline, not instead of it.** The Scrum meetings are about development. The management meetings are about scope, time and budget. They answer different questions, and dropping the second is how projects surprise customers.

## 2. When to choose it — and when not

**Choose it when**

- Scope is known well enough to fill a backlog, and a plan exists that someone will be held to.
- The customer wants progress at fixed intervals and has people who can attend a demo.
- The engagement is large enough that a rhythm is worth its overhead.
- The contract is time-and-materials or fixed price — both assume a plan.

**Do not choose it when**

- Work arrives as an unpredictable stream. Sprint commitments become fiction and the team learns to ignore them.
- The team is shared across several customers, so nobody can commit a sprint's capacity.
- The real question is *"when is my item done?"* rather than *"what lands this quarter?"* — that is Kanban's question.

## 3. What it locks

**The rhythm and the sprint's content.** Scope stays negotiable between sprints and is fixed within one. The plan is locked in the sense that changing it is a visible, priced event rather than a quiet drift.

## 4. Activities

**At the start**

- **Kick-off** with the customer's team and ours: goal and success criteria, participant introductions, the solution in outline, the high-level plan, and the first version of the risk list.
- **Onboard the team** — the internal equivalent. Needs more time and continuing feedback if the people running delivery were not in Scoping.
- **Onboard the customer** — our meeting structure, the document model and what our agile approach means for them, how changes are handled, how issues are logged, and the tools they will touch.
- **Decide how the project is managed** — agreed with the customer's project manager, not announced to them.
- *Disciplines:* Kick-off · Onboarding the team · Onboarding the customer · Cadence and meeting structure · Risk management.

**Every sprint**

| Ceremony | Frequency | Produces |
|---|---|---|
| Refinement | Weekly | Items ready to build: acceptance criteria written, spec checked in |
| Sprint planning | Per sprint | A sprint goal and a committed set of items |
| Daily stand-up | Daily, 15 min | Blockers surfaced and owned the same day |
| Demo | Per sprint | Customer sees working software and reacts |
| Retrospective | Per sprint | One or two changes the team will actually make |
| Test | Continuous, hardening before release | Acceptance against the specification |

- *Disciplines:* Specification · Testing · Issue handling.

**Alongside, on a management cadence**

- **Weekly progress meeting** — scope, time and budget; risks reviewed; the time report read.
- **Monthly steering committee** — the same picture at sponsor level, so the customer can make internal corrections.
- **Monthly plan review** — a project rarely runs to plan; review it, update it, and discuss consequences rather than absorbing them silently.
- **Weekly update to the customer on time, budget and scope** — mandatory, by email or a documented meeting. A project can succeed over budget if the contact stayed close and honest. It cannot survive a surprise.
- *Disciplines:* Status reporting · Steering · Change handling · Risk management · Planning.

## 5. Output and artefacts

| Artefact | Note |
|---|---|
| **D101** | Feature design per feature, approved before build |
| **D100** | Opened early, maintained across sprints, closed at handover |
| **E200** | Deployment procedure, exercised at release |
| Sprint demo material | Per sprint |
| Progress report | Weekly — time, budget, scope |
| Risk log, change log, issue log | Living throughout |

## 6. Who does what

| Responsibility | Default owner |
|---|---|
| Facilitating the ceremonies | Project Owner |
| Sprint goal and backlog order | Customer's product owner, with FDE |
| Writing D101 | ASWE |
| Approving agent output against the spec | ASWE |
| Accepting a feature towards the customer | Customer's product owner |
| Weekly progress meeting and the update on time/budget/scope | Project Owner |
| Steering committee | Customer Owner, with Project Owner presenting delivery |
| Deciding a change is a change | Project Owner, priced with ASWE |

## 7. What it requires of the customer

| Requirement | Concrete |
|---|---|
| A product owner | Available for refinement weekly and for the demo every sprint |
| Acceptance decisions | Within the sprint, not after it |
| Steering participation | A sponsor at the monthly committee |
| One route for changes | Changes come through the agreed channel, not the corridor |
| Attendance at kick-off | Their team, not only their project manager |

## 8. Execution — traditional and agentic

| | Traditional | Agentic |
|---|---|---|
| Refinement | Discussion; acceptance criteria written afterwards, if at all | The spec is the output of refinement. An item is not ready until it is machine-buildable |
| Build | Developer builds from D101 | Agent implements against the spec; the ASWE directs and judges |
| Review | Line-by-line code review | Human approval gate plus outcome-based verification against the spec |
| Demo | Shows what the sprint produced | Unchanged — but there is more to show, which raises the demand on the customer's attention |
| The ceremonies | — | **Unchanged.** Agentic execution does not remove them; it changes what happens between them |

**Where the strain shows.** When a sprint's worth of building takes days rather than weeks, refinement becomes the bottleneck: the team runs out of ready work before the sprint ends. The fix is not shorter sprints but earlier specification — which is the paradox the AI-First material names, that more upfront human work is what lets agents do more.

## 9. Combines well with — and watch out for

**Combines well with**

- **Scoping & Planning** or **Analysis** in Scoping. Both produce the backlog Scrum needs.
- **Launch / hyper care** as the closing stretch. Scrum builds towards a coherent release, which is exactly what a launch assumes.

**Watch out for**

- **Scrum + Discovery.** Discovery deliberately leaves scope open; Scrum wants a backlog. Runnable, but the first sprints will be spent doing the scoping that was skipped.
- **Ceremonies without the management cadence.** The old model is emphatic about this: Scrum meetings do not tell the customer whether the budget holds. Keeping only the ceremonies is the most common way this approach fails.
- **The retrospective that changes nothing.** Two improvements actually made beat ten recorded.
