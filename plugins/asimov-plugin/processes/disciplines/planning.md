---
type: discipline
name: "Planning"
kind: cross
purpose: "Keeping a plan that is worth having, at the right level of detail, revisited on purpose, and versioned so the change is visible."
---

# Planning

*A **cross discipline**. The plan exists at three levels and across all four phases.*

## Purpose

Coordinate the schedule so both sides can look ahead and allocate the right people to the right work at the right time. The plan is a coordination instrument, not a prediction — and its main value is the act of planning rather than the document that results.

> *"Plans are of little importance, but planning is essential."* — the quote the old delivery model chose for this page, and it is the right one.

## Why it matters

A plan lets the customer commit their own people. That alone justifies it: their testers, their product owner, their subject-matter experts all have other jobs, and a delivery that cannot say when it needs them will not get them.

It also makes deviation visible. Without a plan there is no such thing as being late — only a growing sense that things are taking longer than expected, arriving at the customer as a surprise.

And planning surfaces dependencies before they bite. Most schedule problems are not about how long work takes; they are about what has to happen first and who else has to do it.

## How it is done

**Work at three levels, and know which one you are in.**

| Level | Form | Use |
|---|---|---|
| **High-level** | A monthly overview | Where most engagements start. The version the steering committee sees |
| **Week or sprint** | A working plan | The team's coordination layer |
| **Daily** | A detailed plan | Often necessary around go-live, rarely worth it before |

Do not maintain a daily plan for a phase that does not need one. Detail costs upkeep, and an unmaintained detailed plan is worse than none.

**Use sprint themes.** Naming which features carry the emphasis in each sprint makes the plan legible at a glance and is directly useful in sprint planning.

**Revisit it regularly and deliberately** — the monthly plan review exists for this. Look at the remaining work from above: dependencies, challenges, risks. The output is an updated plan *and* an updated risk picture; the two move together.

**Discuss every update with the customer's project manager**, and consider whether the steering committee needs to be informed — or to approve it. A plan changed quietly is a plan the customer will discover has changed.

**Version it.** Save the plan before changing it: an archive folder, the date in the file name. Being able to show what the plan was three months ago is what turns a disagreement into a conversation.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can maintain a plan someone else set up, keep it current, and version it before changing it |
| **Show it** | You can build a plan at the right level of detail for the phase, with dependencies visible, and run the review that updates it. You raise a slip when it appears rather than when it lands |
| **Build it** | You can plan a delivery so the customer's own commitments are visible in it, sequence work around real dependencies, and choose deliberately how much detail is worth maintaining |
| **Own it** | You can replan a delivery in trouble and get both sides to accept the new plan. You can tell a customer their date is not achievable, early, and be believed |

## How to get better

**Internally**

- The old delivery model's **Project plan** page — the three levels, sprint themes, and the archive convention.
- The **project plan review** in the meeting structure: monthly, from a helicopter perspective, producing an updated plan and risk picture together.
- Look at a finished engagement's archived plans in sequence. How the plan moved, and when, is the most honest record of what actually happened.

**Externally**

- Steve McConnell, *Software Estimation* — the chapters on schedule, and specifically on why compressing a plan does not compress the work.
- Eliyahu Goldratt, *Critical Chain* — on buffers and on why every task expanding to fill its estimate is a structural problem rather than a discipline problem.
- Donald Reinertsen, *The Principles of Product Development Flow* — the economics of queues and batch size. Harder going, and the most useful thing available on why smaller and more frequent beats larger and better planned.

## Common failure

**Detail as reassurance.** A daily plan maintained for six months because it looks thorough. It will be wrong within a week and nobody will trust the rest of the plan either.

**The plan that is never updated.** It stops describing the work and becomes an artefact of the kick-off.

**Updating without telling anyone.** The dates move, the customer finds out later, and every future plan is read sceptically.

**No versions.** When the plan is disputed, there is nothing to show — only two recollections.

**Planning the work and not the customer's part.** Their testing, their decisions, their approvals are on the critical path and are the parts we do not control.

**Confusing the plan with the commitment.** A plan is how we intend to get there. What was committed is in the contract, and treating every plan revision as a broken promise makes replanning impossible.

## Artefacts

The plan at whichever levels the engagement warrants, with an archive of previous versions. Feeds the **status report** and the steering committee material. It moves together with the **risk log** — the monthly review updates both — and it is where the **estimate** becomes a schedule.

## Where it is exercised

| Phase | What it looks like |
|---|---|
| **Proposal** | Planning the scoping track: workshops booked, preparation time reserved |
| **Scoping** | The detailed project plan is one of the phase's three outputs, alongside the solution description and the estimate |
| **Development** | Maintained, reviewed monthly, tightened to daily around go-live |
| **Operations** | Becomes a service roadmap rather than a plan |

**By approach:** Scrum plans at sprint level with a high-level plan above it. Use-case delivery replaces the project plan with a **feature roadmap** — direction rather than dates. Kanban plans least of all: the Definition of Workflow and the Service Level Expectation carry what a plan would otherwise say. Launch and hyper care is the one stretch where a genuinely detailed, hour-level plan earns its keep.

**Traditional vs agentic.** Plans get shorter and change more often, because the build steps they used to sequence now take a fraction of the time. The parts that do not compress — the customer's decisions, their testing, their availability — become the plan's real content. Planning the human dependencies well is now most of the discipline.
