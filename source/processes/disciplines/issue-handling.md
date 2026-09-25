---
type: discipline
name: "Issue handling"
kind: cross
purpose: "A structured route for questions and clarifications, so progress does not stall on an unanswered question and the answer stays answered."
---

# Issue handling

*A **cross discipline**. Wherever a question needs an answer and a trace.*

## Purpose

Give questions and clarifications a common, regular process: raised, visible, chased, answered, and recorded. It does two jobs — it keeps work moving when an answer is missing, and it anchors decisions so the same question is not reopened three months later by someone who was not there.

## Why it matters

**Progress.** Unanswered questions are the most common reason work sits still. A question that lives in one person's inbox is invisible; on a list it can be chased, escalated or worked around.

**Decisions stay decided.** Clarifications get anchored — for both sides. Without a trace, the same question is asked again, answered differently, and the difference is discovered when something has been built on it.

**It is evidence.** The issue log shows whether clarifications arrived in time, and whether the customer's organisation could keep up with the cadence the plan assumed. When an overrun is caused by clarifications that never came, this is what makes that visible rather than arguable.

But the old model attaches a warning to all of that, and it is the most important line on the page: **issues are not a substitute for talking to people.** If a question is better asked directly, ask it directly. We are cultivating a working relationship, not building a case file.

## How it is done

**Ask first.** Put the question to the person who can answer it, in whatever way is fastest.

**Then apply the rule of thumb:** if a question asked directly is not answered within a short time, log it as an issue and use the log as the reminder. The log is the follow-up mechanism, not the first move.

**Record enough to be actionable:** what is being asked, why it matters, who is being asked, when it was raised, and when an answer is needed by. That last field is what makes an issue chaseable — an issue with no needed-by date will drift.

**Note the consequence of not answering.** *"Without this by Friday, feature X cannot start next sprint."* That converts a question into a decision for the customer.

**Review it in the progress meeting**, alongside risks and changes. Open issues, and how long they have been open, belong in the status report.

**Close it properly.** Record the answer, not just the fact of an answer. An issue closed with "resolved" has produced nothing durable.

**Watch the pattern.** Many open issues means the customer's organisation cannot keep the pace the plan assumes — which is a conversation about the plan, not a nag about the list.

## What you can do at each level

| Level | What you can do |
|---|---|
| **Do it** | You can raise an issue with enough detail to be actionable, keep it current, and record the answer when it arrives |
| **Show it** | You can judge when to ask directly and when to log — and you know that asking first is the default. You state the consequence of an unanswered question so it becomes a decision |
| **Build it** | You can set up issue handling on an engagement so it is light enough to be used and visible enough to matter, and you connect it to the plan: which issues are on the critical path |
| **Own it** | You can use the pattern in the log to have the harder conversation — that the customer's decision speed is the constraint — without it landing as blame. You keep the log from turning into a case file |

## How to get better

**Internally**

- The old delivery model's **Issue** page — short, well argued, and the source of both the rule of thumb and the warning against using issues instead of dialogue.
- The **status reporting** discipline, where open and closed issues appear, and the **planning** discipline, where a blocked issue becomes a schedule problem.
- Read a finished engagement's issue log next to its plan. The issues that sat open longest are usually where the delivery lost time.

**Externally**

- Little external literature treats this as its own discipline — it usually appears folded into project management or into support processes. The closest useful reading is **ITIL's** distinction between an incident, a problem and a request, which is the same instinct applied to operations: classify before you queue.
- Donald Reinertsen, *The Principles of Product Development Flow* — on queues and waiting time. An open issue is a queue with someone else's name on it, and the cost of the wait is usually larger than it looks.
- Karl Wiegers, *Software Requirements* — the chapters on requirements clarification, for the discipline of turning a vague question into an answerable one.

## Common failure

**Logging instead of asking.** The log becomes the first move rather than the follow-up, the relationship cools, and answers get slower — which produces more issues.

**A log that is a case file.** Every unanswered question recorded with an eye on the eventual argument. The customer notices, and it changes the relationship permanently.

**No needed-by date.** Everything is open, nothing is urgent, and nothing gets chased.

**Closing without the answer.** The issue is marked resolved; what was decided is not written anywhere.

**Never looking at the pattern.** Forty open issues is not forty problems — it is one problem about how fast the customer can decide.

## Artefacts

The issue log, held where the engagement lives, reviewed weekly. It appears in the **status report** as open and closed items, feeds the **risk log** when an unanswered question becomes a threat to the schedule, and feeds the **specification** when the answer changes what is being built.

## Where it is exercised

| Phase | What it looks like |
|---|---|
| **Proposal** | Informal — clarifications before an offer |
| **Scoping** | Heaviest use. A workshop track generates questions faster than any other activity, and the log is what stops them being lost between sessions |
| **Development** | Continuous. Blocked items usually have an issue behind them |
| **Operations** | Becomes the support and request process |

**By approach:** Kanban makes this most visible — a blocked item *is* an open issue, and work item age measures exactly what the issue log is trying to show. Scrum surfaces them at refinement and stand-up. Use-case delivery risks accumulating them quietly, because there is no release deadline to force resolution. Prototyping converts them: a question that would have sat in a log for two weeks is often answered faster by building something.

**Traditional vs agentic.** The discipline is unchanged, and it gets more load-bearing. When building is fast, the unanswered question is what the delivery is actually waiting on — so the issue log stops being administration and becomes the clearest picture of where the work is stuck.
