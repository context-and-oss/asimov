---
type: discipline
name: "Handover to operations"
kind: phase
anchored-to: Operations
purpose: "Handing a solution to whoever will run it, in a state where they can actually run it."
---

# Handover to operations

*An **Operations** discipline, and the phase's gate.*

## Purpose

Transfer a solution to whoever operates it next — us, the customer, or another vendor — with everything they need to keep it running. It is the one part of Operations that is always ours, whatever happens afterwards, and it is where we define what "properly handed over" means.

## Why it matters

An incomplete handover comes back. It returns as questions nobody budgeted for, as support that was never scoped, and as a reputation for delivering things that cannot be maintained. The cost lands months later and is never attributed to the handover, which is why the handover keeps being under-resourced.

It is also the last impression. The delivery may have gone well for a year; if the operating team is left without access, contacts or documentation, that is the version of us they will describe to others.

And it is a commercial event. If we operate the solution afterwards, the handover is the boundary between project economics and service economics. If we do not, it is where our obligations end — and that boundary needs to be clear enough to point at.

## How it is done

**Plan support before you need it.** Who will run this, what they need, and what has to exist before they will accept it. That conversation belongs well before go-live.

**Produce the handover set.** The solution overview, closed after living through the whole project. The IT environment documentation: contacts, system documentation, access. The deployment procedure. And handover documentation proper — solution overview, a recorded walkthrough, and who was on the team.

**Record the walkthrough.** A recording of the handover session is worth more than the document it accompanies, because the questions asked in it are the ones the next person will also have.

**Hand over access properly.** Credentials, permissions, ownership of accounts and subscriptions. This is the part most often half-done, and it is the part that stops the receiving side dead.

**List what is still open**, with an owner against each. Anything unfinished becomes the operating team's problem by default, and they did not agree to that.

**Get acceptance.** Nothing counts as handed over until the receiving side says it is. That is a decision by a named person, not an absence of objection.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can produce the handover documentation and run the session, including access and contacts |
| **Show it** | You can plan the handover early enough that the receiving side helps shape it, and get real acceptance rather than a silence |
| **Build it** | You can design a delivery so handover is cheap — documentation current throughout, access modelled from the start, no heroic archaeology at the end |
| **Own it** | You can hand over a difficult solution to a reluctant receiving party and have it accepted. You set what a complete handover is here, and refuse to call an incomplete one done |

## How to get better

**Internally**

- The old delivery model's **Support planning** and **Handover** pages, and the handover documentation they specify.
- The **Business Continuity** arrangement in the Operations phase — talk to the people who receive handovers about which ones went badly and why. They are the best available source.
- The **specification** discipline: a solution overview maintained through the build is most of a handover already.

**Externally**

- The **Google SRE book**'s chapter on production readiness reviews — the most rigorous public treatment of "is this thing ready for someone else to run", and directly transferable.
- **ITIL service transition** — heavier than we need, but its idea of an explicit acceptance criteria set for entering service is the right instinct.

## Common failure

**Documentation written at the end.** Assembled under time pressure by people already allocated elsewhere, and it shows.

**Access half-transferred.** Something still runs under an individual's account, and it is discovered when they leave.

**No acceptance.** The project declares handover complete; the receiving side never agreed, and finds out when the first problem lands.

**Open items with no owners.** Everything unfinished silently becomes support's.

**No recording.** The one session where everything was explained exists only in the memory of whoever attended.

**Handover as an event rather than a process.** A single meeting cannot transfer a year of context; the meeting is the end of the handover, not the whole of it.

## Artefacts

Handover documentation — solution overview, recorded walkthrough, team overview · the IT environment documentation with contacts and access · the deployment procedure · the closed solution overview · the list of open items with owners · the acceptance record.

## How it varies by approach

Scrum and Analysis-driven builds hand over once, at the end, usually straight after hyper care. Use-case delivery hands over continuously — each use case enters operation as it completes — which spreads the work but makes it easy to never do properly. Kanban and Business Continuity often *are* the receiving side, in which case the handover is internal and the temptation to skip the documentation is strongest.

**Traditional vs agentic.** Documentation generated from the codebase and kept current turns handover from an archaeology project into a summary. That is a real gain and it should be spent on the parts that cannot be generated: the access model, the open items, and the conversation with the people taking it on.
