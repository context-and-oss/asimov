---
type: discipline
name: "Hyper care"
kind: phase
anchored-to: Development
purpose: "The intensive period after go-live, staffed deliberately, run to a standard, and ended on a defined condition."
---

# Hyper care

## Purpose

Carry a solution through the weeks after go-live, when problems surface fastest and the people using it are least practised. It is elevated support with a named team, an agreed response time, and — crucially — **an agreed end**.

## Why it matters

Hyper care is where goodwill is either earned or spent. The solution is new, the users are uncertain, and everything that arrives feels urgent to the person reporting it. Handled well, this is the period a customer remembers as the reason they trust us. Handled badly, it undoes a delivery that was otherwise good.

It is also where an engagement's economics change without anyone deciding that they should. Hyper care without a defined end becomes open-ended support, and because each individual request is small, nobody notices until what was set aside for the period is spent, or exceeded. The old delivery model draws the box and leaves the page empty, which is a fair description of how it is usually planned.

The commercial stake is higher under outcome pricing. If the price was set against a business outcome, the weeks where adoption is decided are the weeks that determine whether we delivered it.

## How it is done

**Staff it before go-live, by name.** Who is available, at what hours, reachable how. "The project team" is not an answer — they are already being allocated elsewhere.

**Agree a response time and mean it.** One working day is a common commitment. What matters is that it is stated and that the customer's users know how to reach it.

**Triage every incoming item into three buckets, and be strict about it.**

| Bucket | What it is | Who pays |
|---|---|---|
| **Defect** | It does not do what the specification says | Us |
| **Change** | It does what was specified; the specification was not what they wanted | Change handling |
| **Training or expectation** | It works and the user did not know how, or expected something else | Adoption |

**Most of what arrives is the third bucket.** That is normal, and it is why adoption work belongs in this period rather than after it. Misclassifying training as defect is how hyper care turns into development nobody scoped or agreed.

**Review daily at first, then weekly.** What came in, how it was classified, what it changed. The pattern is the useful part: five reports of the same confusion is a training gap, not five incidents.

**Agree exit criteria before go-live.** A volume of incidents below a threshold, or a period without a severity-one issue, or a fixed number of weeks with a review. Anything defined. Hyper care must end on a condition, not on someone losing interest.

**Hand over deliberately.** Hyper care ends into whoever operates the solution — us, the customer, or another vendor — and that transition is the handover discipline, not a fading out.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can take hyper care shifts, respond within the agreed time, and classify what arrives into defect, change or training |
| **Show it** | You can triage accurately under pressure, spot the pattern behind five similar reports, and turn it into a training or documentation fix instead of five fixes |
| **Build it** | You can design the hyper care period before go-live: staffing by name, response commitment, exit criteria, and the adoption work that reduces its volume. You price it as real work rather than absorbing it |
| **Own it** | You can hold the line on scope during hyper care without damaging the relationship — say "that is a change" in a way the customer accepts. You decide when hyper care is over and make it stick |

## How to get better

**Internally**

- The **Adoption** material in the old delivery model — most of what arrives during hyper care is an adoption problem, so this is the discipline that reduces the workload.
- The **Change handling** discipline, which is where the second triage bucket goes and where each of those items is priced and agreed before it is built.
- Read a finished engagement's hyper care log if one exists. The classification split is the most instructive number in it.

**Externally**

- The **Google SRE book**, chapters on incident response and on postmortems — free online, and the best available material on staying calm and learning from what arrives.
- **ITIL's service transition** guidance on early life support. Dated in style, but hyper care is a named practice there with decades of experience behind it, including the exit-criteria discipline we keep skipping.
- Site Reliability Engineering's *error budget* idea, as a way to think about when a system is stable enough to hand over.

## Common failure

**No exit criteria.** The single most common failure and the most expensive. Without them, hyper care ends when someone stops asking, which may be never.

**Treating it as a defect budget.** The assumption that everything arriving is a bug leads to fixing things that were never broken, and to never addressing the training gap that caused them.

**Staffing it with whoever is left.** The people who built it are the people who can triage it. Allocating them elsewhere on day one and keeping hyper care as a side duty guarantees slow responses.

**Fixing everything because fixing is cheap.** Agentic execution makes a fix fast to produce, which is a poor reason to make one. A change is still a change even when it takes ten minutes.

## Artefacts

A hyper care log — what came in, how it was classified, what it changed. Feeds the **Adoption** work, the **Change handling** log where items are reclassified, and the eventual **Evaluation**. Its end is recorded, with the criteria that were met.

## How it varies by approach

- **Scrum** and **Analysis**-driven builds end in a coherent go-live, so hyper care is a distinct, planned stretch. This is its home.
- **Use-case delivery** has no single go-live. Each use case carries a small hyper care of its own — days rather than weeks — and the discipline still applies at that scale.
- **Kanban** does not have a hyper care period, because it never has a launch. Its equivalent is a Service Level Expectation that holds continuously.

**Traditional vs agentic.** The work is human either way. What changes is speed of fix, which raises the value of triage discipline rather than lowering it — and one boundary: **investigating a production problem with agent help is a Zone 3 question.** Production logs contain real data. If agents are to touch them during hyper care, that is agreed per customer and in advance.
