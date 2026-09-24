---
type: discipline
name: "Estimation"
kind: cross
purpose: "Saying what something will take, with honest uncertainty, and including the work that is not building."
---

# Estimation

*A **cross discipline**. Scoping estimates a delivery, Development re-estimates a feature, Operations sizes a request.*

## Purpose

Give the customer a usable indication of what a delivery will cost, and give ourselves a basis for planning and for noticing when reality has diverged. An estimate is a statement about uncertainty, not a promise — and the discipline is mostly about making the uncertainty visible rather than hiding it.

## Why it matters

Most of the commercial trouble a project runs into can be traced back to its estimate. Under fixed price it *is* the commercial position. Under time and materials it sets the expectation everything is later judged against, whether or not anyone called it a commitment.

Two failures dominate, and they pull in opposite directions. **False precision** — "807.5 hours" — tells the customer we know something we do not, and every later deviation is then our error rather than the nature of the work. **Silent padding** hides the uncertainty in a number nobody can question, which means the conversation about what is actually unknown never happens.

There is a third, quieter failure: estimating only the building. Clarification, documentation, training and handover are real work, and leaving them out is how a delivery that hit its build estimate still lands over budget.

## How it is done

**Break down before estimating.** Not to be precise, but to understand the scope. The act of decomposition is where most of the value is; the number is a by-product.

**Estimate the non-build work explicitly.** Clarification, documentation, training, handover. If they are not on the estimate, they will not be planned, and they will still happen.

**Estimate at feature level, then at item or task level, and mix the two freely.** Less complex work can be estimated directly as an item; anything uncertain is broken down fully and estimated at task level.

**Use whole numbers or ranges — never false precision.** Estimate in 10 / 25 / 50 / 100 depending on the size of the project, or give a range: *100–150 hours for this feature*. Both say something true about confidence. "807.5" says something false.

**Estimate the scoping itself.** The time to prepare and document a scoping track is routinely underestimated. It gets its own estimate, not a rounding.

**Re-estimate at the feature design.** The estimate made at the end of scoping covers analysis and delivery per feature. A sharper number becomes possible when the feature is actually designed — and that is the moment to say so, not to quietly absorb the difference.

**Show uncertainty rather than absorbing it.** A three-point estimate, a range, or an explicit assumption list. Padding that nobody can see is a decision taken on the customer's behalf without telling them.

**Connect it to risk.** The things that make an estimate uncertain are usually already on the risk log. If they are not, one of the two documents is wrong.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can break down a piece of work and estimate it in whole numbers or a range, including the clarification and documentation around it |
| **Show it** | You can estimate a feature you have not built before and be explicit about what makes it uncertain. You defend a range instead of collapsing it to a single number when asked |
| **Build it** | You can estimate a whole delivery, connect the uncertainty to the risk log, and shape the estimate so it supports the contract type being proposed. You calibrate from what past estimates actually cost |
| **Own it** | You can stand behind an estimate in a commercial negotiation, explain the uncertainty without losing the deal, and say no to a number someone wants you to reach. You improve how the organisation estimates by feeding actuals back |

## How to get better

**Internally**

- The old delivery model's **Estimation** page — one of its best-written, and the source of the whole-numbers-and-ranges rule. Read it in the original.
- The estimation template and its three-point sheet, including the separate sheet for estimating a scoping track.
- **Compare your own past estimates with what the work actually cost.** Nothing else calibrates as fast, and almost nobody does it.

**Externally**

- Steve McConnell, *Software Estimation: Demystifying the Black Art* — the standard work, and specifically good on the difference between an estimate, a target and a commitment.
- **Reference-class forecasting** (Bent Flyvbjerg) — estimate by comparing with the distribution of similar past projects rather than by reasoning from inside this one. The strongest available cure for optimism.
- Daniel Kahneman, *Thinking, Fast and Slow* — the planning fallacy chapter. Worth reading once, because knowing the bias by name makes it easier to spot in a room.

## Common failure

**False precision.** A decimal point in an estimate is a claim about knowledge nobody has.

**Estimating only the build.** The classic overrun, and entirely predictable.

**Padding invisibly.** It protects the estimator and removes the customer's ability to make a trade-off they might have wanted to make.

**Never revisiting.** The scoping estimate carried unchanged through a delivery whose understanding has completely changed.

**Estimating to a wanted answer.** The number is worked backwards from what the customer will accept. It will still be wrong; it will just be wrong later and more expensively.

**No feedback loop.** Estimates never compared with actuals, so the organisation's calibration never improves.

## Artefacts

The estimate itself, broken to feature and item level *(the D200 sheet in the old numbering, including its three-point option)*. Feeds the offer, the plan, and the contract. Connected to the **risk log** — uncertainty should appear in both — and revisited when a feature design is written.

## Where it is exercised

| Phase | What it looks like |
|---|---|
| **Proposal** | Estimating the scoping track itself, and a rough order of magnitude for the delivery |
| **Scoping** | The main estimate: per feature, covering analysis and delivery. Its home |
| **Development** | Re-estimation at feature design; capacity and sprint-level sizing |
| **Operations** | Sizing individual requests, or replaced by a service level |

**By approach:** Scoping & Planning and Analysis estimate in hours at feature and item level. Use-case delivery estimates in **effort points** on items — comparative, not predictive. Kanban largely replaces estimation with a **Service Level Expectation** forecast from historical cycle time, which is a different instrument answering the same question. Prototyping does not estimate the prototype; it estimates the time to an answer.

**Traditional vs agentic.** This is the discipline agentic delivery disturbs most, and honestly the model does not yet have the answer. Build time falls, so the proportions shift: clarification, specification and approval become the dominant costs, and estimates built on old ratios will be wrong in a new direction. Two consequences worth acting on now — **historical data loses value after a step change in throughput**, so recalibrate rather than inherit; and **specification effort should be estimated explicitly**, because it is now a larger share of the work than the building it replaces.
