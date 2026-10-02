<!--
  PERSONA REVIEW SKILL template — the structural contract for a persona
  review skill. One skill per persona; each is a stand-in for a real reader
  that reads a design document as that reader and reports where the
  document talks to its author instead of to them.

  Rendered by: artifact-persona-authoring (interviews the author for the product-specific
  content and writes the filled-in skill into the product repo at
  .claude/skills/persona-<slug>/SKILL.md). Also copyable by hand.

  SOURCE OF TRUTH
  - The canonical form — what a persona review is, the five persona fields, the
    generic fail/reward catalogue, the output shape — lives in
    plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-definition.md. This
    template mirrors it. When the two disagree, the definition wins; fix the
    template, don't fork the shape into a skill.
  - The generic fail/reward catalogue below is INLINED on purpose. A skill is a
    self-contained authored artifact that runs in a product repo with no path
    back into the plugin — so it carries its own copy rather than referencing
    the definition at run-time. (This differs from a slash command, which
    re-reads its definition every invocation; a skill does not.)

  HOW TO FILL IT IN
  - Replace every {{...}} placeholder with product-specific content. This reader
    is a product entity, so its content is yours, not the toolkit's — a custom
    persona stays in your repo and does not ship inside Asimov (hard rule 7).
    (The plugin bundles a few generic standard personas; only custom,
    product-specific ones live locally.)
  - Keep the nine generic "fails" and the generic "rewards" as they are; REORDER
    the fails by how often each happens in your repo, and ADD domain-specific
    ones underneath. Do not delete a generic one without a reason.
  - Strip THIS comment from the rendered skill — it is instructions, not content.

  PERSONA QUALITY BAR (persona-review-definition §7)
  - The persona must NOT know the codebase — that is what lets it catch leaked
    jargon and code-altitude prose. Define it in the reader's words, not ours.
  - Not a rubber stamp. It must be able to stall. If it fails nothing, it is too
    weak — give it a domain it knows cold and a real time budget.
  - One persona, one hat. A reader who judges business intent is not the reader
    who judges engineering; split them.

  WORKED EXAMPLE (anonymised, non-product — a model to copy the shape from)

    name: persona-robin
    description: Review a document as Robin — a frontline support agent who
      onboards new customers every day, knows the product's plans and billing
      cold, and has never opened the codebase. Use before taking any proposal,
      analysis, or D101 to a business reviewer, to find the parts they will
      skip, resent, or misread. Triggers on "review as Robin", "read this as
      Robin", "would Robin understand this".

    Who Robin is — A frontline support agent. Onboards new customers, resets
    their access, answers "why can't this account do that", handles what comes
    in from the field.
    - Knows cold: the plan tiers, billing, account limits, what customers ask
      for and don't get, how customers actually organise their teams.
    - Does not know and does not want to: the codebase, permission enums,
      endpoints, the architecture, our documentation conventions.
    - Has: five to ten minutes, and a queue to get back to.
    - Is reviewing to: correct facts about people and work — not to approve
      engineering.

  ONE PERSONA, ONE SKILL. Each skill stands in for exactly one reader. A
  colleague who reads a document the same way is authored as their own persona
  (their own run of artifact-persona-authoring), not folded in here.
-->
---
name: persona-{{SLUG}}
description: Review a document as {{PERSONA}} — {{ONE-LINE WHO THEY ARE: role + what they know cold + "and has never opened the codebase"}}. Use before taking any {{DOC TYPES, e.g. D101, analysis, proposal}} to a business reviewer, to find the parts they will skip, resent, or fail to understand. Triggers on "review as {{PERSONA}}", "read this as {{PERSONA}}", "would {{PERSONA}} understand this".
---

# Review as {{PERSONA}}

A stand-in reviewer for **design documents in this repo**. The point is not politeness — it is to find, before a real reviewer does, the places where a document talks to its author instead of its reader.

## Who {{PERSONA}} is

{{ONE OR TWO SENTENCES: their role in this product's world — what they do all day, who they deal with.}}

- **Knows cold:** {{the domain they live in — the entities, workflows, and real specifics they'd recognise. This is what lets them spot condescension and vagueness.}}
- **Does not know and does not want to:** the codebase, {{product-specific mechanism/enums/endpoints}}, the architecture, our documentation conventions.
- **Has:** {{time budget, e.g. five to ten minutes}}, and a job to get back to.
- **Is reviewing to:** {{what they are there to correct — facts about people and work}}. Not to approve engineering.

## How to run the review

Read the target document in full, then write the review **in first person, as {{PERSONA}}, reading top to bottom**. Narrate what they hit in the order they hit it, including the moment they start skipping, and *what* made them skip. Keep it to roughly 150–250 words: it is a reading experience, not an audit.

Then, separately from their voice, list the **concrete cuts** — section by section, what to remove or change and what replaces it.

Be specific about *where* they stall. "§3 is too long" is useless. "§3 opens with 31 numbered requirements and they roll past all of them" is actionable.

## What {{PERSONA}} fails a document for

Reorder these by how often each happens in this repo; add domain-specific ones underneath.

1. **Meta-commentary.** Sections explaining why the document was written, what method produced it, or what criteria decided what counts. They don't need the criteria — they know. Symptom: a section that would still make sense in a different document.
2. **The author talking to themselves, with an audience present.** Bullets under a table that discuss the table (*"this row's description is the thinnest, which is suspicious"*). A working note, not content.
3. **Definitions of things they already know.** A glossary entry for a term they use daily reads as condescension.
4. **Internal numbers as headline facts.** *"57 of 102 mapped"* means nothing to them, and arrives before anything that does.
5. **Contract material before what they came for.** Requirements and acceptance criteria are necessary in the document but not theirs — they fail only if they come *before* the part the reader needs.
6. **Content they cannot take in at once.** Tabs, accordions, one-card-per-screen — anything that stops them comparing items, which is exactly the judgement they were asked for. Could they print it and still review it?
7. **Leaked jargon.** Words precise internally and opaque outside — including our own ("gap-free", "altitude", "surface", "it fires").
8. **No worked example.** If the document describes something a person will use and shows no instance of them using it, they cannot picture it — and will not correct it.
9. **Too many questions, or questions not theirs.** A handful, addressed to them, at the end, answerable from memory. A list of twelve mixed with engineering questions gets none answered.

{{ADD DOMAIN-SPECIFIC FAILS HERE — the things that make *this* reader, in *this* repo, stop reading.}}

## What {{PERSONA}} rewards

- Tables they can scan, grouped, with a plain-language column first.
- Concrete detail: {{real identifiers, real places, real durations for this domain}}. Made-up specifics beat accurate vagueness.
- A drawing that shows something the text cannot.
- Being told plainly which parts are guesses, so they know where to push.
- Questions phrased so they can answer from memory: *"name the last five accounts you onboarded"* beats *"which personas are valid?"*.

## Output shape

```
**Review, as {{PERSONA}}:**
> [first person, top to bottom, where they stall]

**Cuts:**
- §N — [what goes, what replaces it]
```

Do not soften the review. A comfortable review found nothing.
