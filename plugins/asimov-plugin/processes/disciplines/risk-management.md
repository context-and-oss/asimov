---
type: discipline
name: "Risk management"
kind: cross
purpose: "Finding what could derail the work early enough to do something about it, and being able to say it out loud."
---

# Risk management

*A **cross discipline**. A risk register is opened in Proposal and closed at handover.*

## Purpose

Identify the uncertain events that could affect the work, judge how likely and how damaging each would be, and act before they become certain. A risk is *any uncertain event or condition that, if it occurs, could have an impact on the project's objectives* — and it can hit **scope, schedule, resource availability, cost or quality**.

Half of this discipline is analysis. The other half, and the harder half, is telling someone about it.

## Why it matters

- **It reduces losses.** Addressing something early is cheaper than reacting to it late, every time.
- **It improves decisions.** Knowing what is uncertain lets you prioritise and allocate deliberately rather than by reflex.
- **It improves outcomes.** Problems handled proactively cost less than the same problems handled at the moment they land.
- **It builds confidence.** A customer who sees a maintained risk log believes the rest of the delivery is managed too. One who is told about a risk after it materialised will assume — correctly — that nobody was looking.
- **It is sometimes required.** Regulated customers mandate it.
- **It compounds.** Risks that recur across engagements are the fastest route to improving how we work.

## How it is done

**Open the register early.** The first version of the risk list belongs in the kick-off, not in the first crisis. A project that has never written a risk down has not looked.

**For each risk, record six things** — the template's fields, and they are the right ones:

| Field | Note |
|---|---|
| **Description** | What could happen, stated as an event rather than a worry |
| **Area** | Scope · schedule · resources · cost · quality |
| **Likelihood** | Judged, not calculated |
| **Impact** | If it happens, what does it cost |
| **Score** | Likelihood × impact — derived, so the ranking is consistent |
| **Mitigation plan** | What we will do, and who does it |

Add a comment field for the history, because how a risk developed is often more useful than its current score.

**Choose a response deliberately: avoid, reduce or accept.** Accepting is a legitimate answer when it is a decision. It stops being legitimate when it is what happens because nobody chose.

**Review it weekly**, in the progress meeting, sorted by score. A register reviewed monthly is a document; reviewed weekly it is a tool.

**Take the difficult conversation properly.** This is where the discipline is won or lost:

- **Be transparent and honest.** Explain the risk, the potential impact, and what is being done. Honesty builds credibility, and credibility is what you will need later.
- **Be empathetic.** Acknowledge the concern. The person hearing it may have staked something on this.
- **Tailor the message.** A sponsor, a project manager and an operations lead need different levels of detail.
- **Focus on solutions.** Present the mitigation alongside the risk, so the conversation is about a plan rather than about a problem.
- **Update regularly.** Silence after a risk has been raised is read as either "it went away" or "they stopped looking".

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can identify risks on your own work, write them up with likelihood, impact and a mitigation, and keep the register current |
| **Show it** | You can spot the risk nobody has named — including the ones about people and dependencies rather than technology — and get it into the log before it is urgent. You run the weekly review so it changes something |
| **Build it** | You can set up risk management on an engagement so it is proportionate: enough to catch what matters, light enough that people actually maintain it. You connect risks to the estimate and the plan rather than keeping them in a parallel document |
| **Own it** | You can tell a customer something they do not want to hear, early, and have them thank you for it. You carry risk patterns across engagements so the same surprise does not happen twice |

## How to get better

**Internally**

- The **teaching deck** *How we (should) deliver* — its risk section, the P500 template fields, and the five principles for the difficult conversation.
- The old delivery model's **Risks** page: probability × consequence, reviewed in progress meetings, mitigated before it turns critical.
- Read the risk log of a finished engagement against what actually went wrong. The gap between the two — what was on the log and never happened, what happened and was never on it — is the fastest way to calibrate.

**Externally**

- Tom DeMarco and Timothy Lister, *Waltzing with Bears: Managing Risk on Software Projects* — the standard work for this industry, and specifically good on the argument that a project with no risks recorded is a project nobody has thought about.
- Douglas Hubbard, *The Failure of Risk Management* — on why scoring schemes give false comfort, which is worth reading before trusting any likelihood × impact number too far.
- **Reference-class forecasting** (Bent Flyvbjerg) — comparing this project with the distribution of similar past projects, rather than reasoning from the inside. The cure for the planning fallacy, and directly useful to estimation as well.

## Common failure

**The register that is written once.** Created at kick-off, never reopened, discovered at closure. It is worse than none, because it created the impression of management.

**Only technical risks.** The risks that actually derail engagements are usually about people, decisions and dependencies — a sponsor leaving, a customer who cannot clarify, a third party who will not commit.

**Scores as an answer.** A number ranks risks against each other. It does not tell you what to do, and treating it as though it does is Hubbard's whole argument.

**Mitigations with no owner.** A plan nobody is doing is a description of what we would do if we were doing something.

**Raising it too late to act.** The most common failure and the one this discipline exists to prevent. A risk raised after it materialised is a report, not a risk.

**Accepting by default.** Nobody decided to accept it; nobody decided anything.

## Artefacts

The risk log, held where the engagement lives and reviewed weekly *(P500 in the old numbering)*. Feeds the **status report**, where it appears sorted by score, and the **estimate**, where uncertainty should be visible rather than padded silently. Significant risks appear in the steering committee. The register closes at handover, and what is left open transfers with the solution.

## Where it is exercised

| Phase | What it looks like |
|---|---|
| **Proposal** | The commercial risks: change readiness, zone constraints, whether the customer can decide fast enough. These shape the offer |
| **Scoping** | The risks that make the estimate uncertain — and saying so, rather than padding |
| **Development** | The weekly review. The main home |
| **Operations** | Risk becomes operational: dependencies, end-of-life, knowledge concentration |

**By approach:** Scrum reviews it in the weekly progress meeting. Kanban treats a blocked item as a risk made visible, and work item age as an early warning. Use-case delivery carries the risk that no single use case is large enough to force the conversation, so the register needs its own slot. Prototyping is itself a risk-reduction technique — it buys certainty about the thing nobody could otherwise judge.

**Traditional vs agentic.** The analysis is human. Two things shift: agentic delivery removes some classic risks (throughput, rework, documentation debt) and adds others — specification quality becomes a first-order risk, because an agent building precisely from a wrong spec is faster at being wrong. And the **zone decision is a risk decision**: what agents may access, and what follows if that access is refused or later withdrawn.
