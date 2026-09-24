---
type: discipline
name: "Deployment"
kind: phase
anchored-to: Development
purpose: "Getting work into production predictably, with a way back."
---

# Deployment

## Purpose

Move what has been built into production so that it works, the people affected know it is happening, and there is a decided route back if it does not. Covers the deployment plan, the test and approval procedure, cut-over, and the decision to proceed.

## Why it matters

Deployment is where a project's optimism meets its data. Most of what goes wrong at go-live was knowable beforehand — an integration nobody tested against real volumes, a migration that takes eleven hours in a four-hour window, an approval nobody had authority to give at seven in the morning.

It is also the moment with the least slack. Everything else in a delivery can absorb a bad day. A cut-over cannot: it has an audience, a date, and usually a business that has stopped doing something the old way.

And it is the classic budget overrun. The old delivery model draws it as its own box precisely because it is real work that gets planned as a milestone.

## How it is done

**Write the deployment plan before it is needed.** What is deployed, in what order, with what dependencies. Who does each step and how long it takes — measured, not guessed, because a migration timed once on test data is the only honest number available.

**Decide the rollback path.** Not "we could roll back" — the actual steps, the actual owner, and the time by which the decision must be taken. If there is genuinely no way back, that is a decision to make consciously and price, not a fact to discover.

**Agree the test and approval procedure.** Who signs off, against what, and by when. Approval is a named person, not a department.

**Plan the cut-over as a sequence with a clock.** What happens to data. What runs in parallel and for how long. When the old thing stops. Who tells the users.

**Name the go/no-go decision and its owner in advance.** The decision to proceed at cut-over should never be taken by a committee at two in the morning. One named person, with the technical judgement in front of them.

**Record deviations as they happen.** A cut-over log written afterwards is fiction with good intentions.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can execute a deployment plan someone else wrote, follow the procedure, and record deviations as they happen rather than afterwards |
| **Show it** | You can write the plan yourself, with timings measured rather than guessed and a rollback path that has been tested. You run a rehearsal and change the plan based on what it showed |
| **Build it** | You can design deployment so most of it is automated and repeatable — the pipeline does the work, the humans decide. You shape releases so cut-overs are small and frequent rather than large and rare |
| **Own it** | You can hold a go/no-go decision under pressure with incomplete information, and be the person others want holding it. You set the standard the rest deploy against |

## How to get better

**Internally**

- The **Engineer track's** CI/CD and pipeline material — deterministic pipelines, quality gates, the pre-commit/PR/post-commit stages. Deployment discipline and the pipeline are the same subject from two directions.
- **E200** on a live engagement, read against what actually happened at that release.
- Volunteer for a cut-over before you have to run one. This is not a discipline to learn on your own first go-live.

**Externally**

- Jez Humble and David Farley, *Continuous Delivery* — the foundational text, and still the clearest on why deployment should be boring.
- Nicole Forsgren, Jez Humble and Gene Kim, *Accelerate* — the evidence behind small, frequent releases, and the DORA metrics we already measure against.
- The **Google SRE book**, chapter on release engineering — free online, and good on rollback as a designed capability rather than a hope.

## Common failure

**Planning it as a milestone.** A date in a plan is not a deployment plan. The work has activities, owners and a cost, and none of them appear if it is a diamond on a chart.

**No rehearsal.** The first time a migration runs at full volume should not be the time it matters.

**A rollback that exists only in principle.** It has never been tested, so nobody knows whether it takes twenty minutes or two days — which means it will not be used, which means there is no rollback.

**Approval by absence.** Nobody objected, so it proceeded. That is not a sign-off, and it will not be remembered as one.

## Artefacts

**Deployment plan** including the rollback path · **E200** deployment procedure — test and approval, technical deployment · **E100** IT environment: access, contacts, system documentation · a cut-over log.

## How it varies by approach

- **Scrum** and **Analysis**-driven builds converge on a release, so deployment is a distinct, planned stretch — usually inside **Launch / hyper care**.
- **Use-case delivery** deploys per use case. The same procedure applies but at smaller scale and higher frequency, which makes automation worth more.
- **Kanban** deploys per item. Here deployment must be boring by design: if each item's release needs a plan, the flow stops.

**Traditional vs agentic.** Traditionally the pipeline has manual gates and the deployment is an event. With deterministic CI/CD the pipeline has no manual gates — the human decision moves to the go/no-go, which is where judgement actually belongs. One boundary matters: **deploying is not the same as agents having production access.** Fixing forward in production during a deployment is a Zone 3 question, agreed per customer and in advance, not decided at cut-over.
