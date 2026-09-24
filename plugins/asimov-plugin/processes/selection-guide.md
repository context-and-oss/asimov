---
type: guide
name: "Selection guide"
purpose: "Which approach to choose in each phase, what decides it, and which combinations carry risk."
---

# Selection guide

Four phases are fixed. In each, you choose an approach. This guide says what decides the choice — and warns about the combinations that used to be impossible and now are not.

## How to use it

1. **In Proposal**, agree the zone, the autonomy level and whether the customer can carry the change. These are preconditions, not results.
2. **In Proposal**, choose the Scoping approach. It goes in the agreement.
3. **In Scoping**, choose the Development approaches — and write down what each requires of the customer.
4. **In Scoping**, agree the Operations arrangement. Who operates it afterwards changes what we must produce.
5. **Check the combination** against the warnings at the bottom before anyone signs anything.

Record the choices where the engagement is set up. An approach nobody wrote down becomes whatever the team is used to.

## What actually decides it

The old model had one table with nine criteria that chose a whole delivery model in a single move. Two of those criteria — fixed price and fixed scope — were doing most of the work, and they are **contract** questions, not delivery questions. Separating them is the point of this guide.

| Question | Decides |
|---|---|
| How well is the need understood? | The **Scoping** approach |
| Must the scope be locked? | The **Scoping** approach, and the contract |
| Is the work a stream or a coherent release? | The **Development** approach |
| How fast can the customer decide? | The **Development** approach — and whether any of this works |
| Is the team stable and dedicated? | The **Development** approach |
| Who operates it afterwards? | The **Operations** arrangement, and what we must hand over |
| What may agents access? | Zone — set once, in Proposal |

Engagement size, hours and technology — three of the old criteria — turned out to decide almost nothing about *how* to work. They belong in the commercial conversation.

## Choosing the Scoping approach

| If… | Choose |
|---|---|
| The need is understood, and the customer needs a basis for deciding what to buy | **Scoping & Planning** |
| The direction is clear but the scope should stay open, and trust is high | **Discovery** |
| The scope must be locked so a fixed price can be set | **Analysis** |
| We are taking over something that already exists | **Onboarding/handover** |
| Nobody can say what should be built until they see something | **Prototyping first** — then one of the above |

**The estimation unit follows the approach, and it must fit the contract.** Hours bind to time-and-materials and fixed price; effort points bind to subscription; a Service Level Expectation is a third kind of promise again. Choosing Discovery and then asking for a fixed price is choosing two incompatible things.

## Choosing the Development approach

| If… | Choose |
|---|---|
| The scope is known, a plan will be followed, and the customer wants a fixed rhythm | **Scrum** |
| Work arrives as an unpredictable stream and priorities change faster than a sprint | **Kanban** |
| The engagement is standing, value lands use case by use case, and scope must be able to change | **Use-case delivery** |
| An open question blocks the work, or the idea itself needs proving | **Prototyping** — as a cycle inside whichever approach is running |
| A coherent set of functionality goes live at once | **Launch / hyper care** as the closing stretch |

More than one can apply in sequence: a prototyping cycle inside a Scrum build is normal, and a Scrum build ending in launch and hyper care is the common shape.

## Choosing the Operations arrangement

| If… | Then |
|---|---|
| We operate it | **Business Continuity** — working cadence is Kanban |
| The customer operates it | We define what they must receive; the handover bar is ours either way |
| Another vendor operates it | As above, plus a named technical contact on their side before go-live |

The handover itself is never optional and never someone else's job.

## Combinations that carry risk

Bundles used to prevent these by making them unbuildable. A catalogue has to name them instead. None is forbidden — each needs a deliberate answer.

| Combination | The problem | What to do instead |
|---|---|---|
| **Discovery + fixed price** | The price is locked, the scope is not. The classic trap | Run an Analysis after Discovery before setting the price, or let the fixed price cover only a bounded MVP |
| **Analysis + use-case delivery** | The customer paid to lock a scope, then runs a way of working built to change it | Use Scrum, or bind use-case delivery to a named set of use cases |
| **Kanban + fixed price** | Kanban commits to a flow, not a scope | Bound it to a defined set of items and treat the rest separately |
| **Use-case delivery + launch/hyper care** | Use cases go live one at a time; there is no single go-live to plan | Put the deployment elements inside each use-case cycle instead |
| **Scrum + Discovery** | Scrum wants a backlog; Discovery deliberately leaves scope open | Expect the first sprints to do the scoping that was skipped, and say so up front |
| **Prototyping without a written boundary** | A working prototype looks finished, and agentic execution makes it look more finished, faster | Align expectations verbally *and* in writing before the first showing |
| **Any approach + a customer who cannot decide quickly** | The binding constraint on every approach, and the one nobody checks | State the required decision speed in Scoping. If it cannot be met, choose a slower cadence deliberately rather than discovering it in month three |

## The contract is a separate axis

Contract type is chosen with Commercial, not here. But it constrains what can be chosen, and the constraint runs both ways:

| Contract | Fits | Fights |
|---|---|---|
| **Fixed price** | Analysis → Scrum → launch | Discovery, Kanban, use-case delivery |
| **Time & materials** | Scoping & Planning → Scrum | Nothing strongly |
| **Subscription / TaaS** | Discovery → use-case delivery | Analysis, fixed-scope thinking |
| **Business Continuity** | Onboarding/handover → Kanban | Anything assuming a release |
