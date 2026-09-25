---
artifact: persona-review
maturity: assess
since: 2026-09-10
---

# Definition of persona review

The written standard for a **persona review** — a review that reads a document *as one of its intended readers* and reports where the document talks to its author instead of to that reader.

A persona review is delivered as a Claude Code **skill**, one per persona. Personas come in two kinds, both following the form in §3:

- **Standard** — generic reader archetypes carrying no product-specific content, curated once and shipped with the toolkit as plugin skills so a repo has readers on day one. The v1 set is three, one per orthogonal stake: an operational-reality reader, a technical-feasibility reader, and a cost/ROI reader (shipped under Greek-god handles — Poseidon, Athena, Hermes).
- **Custom** — the product-specific readers only the team knows (an MCI service employee, a named ops lead), authored locally from `plugins/asimov-plugin/artifacts/skills/persona-review/persona-review-template.md` into the product repo's `.claude/skills/`.

Every persona skill — standard or custom — is named **`persona-<slug>`** (e.g. `persona-lauren`, `persona-support-agent`). The `persona-` prefix is the namespace: it marks a skill as a persona review, groups the set, and is how a lister tells persona skills apart from other skills (real grouping subfolders are not an option — skill discovery is flat). This document is the canonical form those skills are written from and reviewed against. It is read by humans (persona authors, reviewers of a persona skill) and is the source of truth the template mirrors.

---

## 1. What a persona review is for

A design document has two failure modes. The first is being *wrong* — the business shape is settled at the wrong altitude, a rule has no counter-example, an acceptance criterion isn't checkable. The second is being *unread* — the document is correct but so tuned to its author that the reader it was written for skips it, resents it, or misunderstands it, and so never corrects the thing only they could correct.

`/d101-review` and Baley catch the first mode. **A persona review catches the second.** It answers one question:

> *When the actual reader this document was written for opens it, with the time and knowledge they really have, do they read it — or do they stall, skip, and hand back a rubber stamp?*

The point is not politeness. A business reviewer who skims and approves has told you nothing, and the feature ships on an assumption nobody checked. A persona review finds — before the real reviewer does — the places where the document forfeits its own review.

## 2. Where it sits among the reviewers

| Reviewer | Reads | Judges against | Verdict axis |
|---|---|---|---|
| `/d101-review` | a D101 | the two bars (`d101-feature-design-definition.md` §8a/§8b) | is the *contract* complete? |
| Baley | a code diff | the repo's conventions + correctness | is the *code* conforming and safe? |
| **A persona review** | any design document (business or technical) | **a reader** — a named target audience | will the *reader* actually read and correct it? |

A persona review is the concrete form of `/d101-review` **check 7** (*"Could a product or business reviewer who doesn't know the codebase understand §2 and §4?"*). Check 7 asks the question in the abstract; a persona review answers it by putting a specific reader in front of the document and narrating what they hit. Where check 7 is a proxy, the persona is the thing itself.

It reviews **design documents** — a D101's business sections (§2/§4) for most readers, plus its technical design (§6) for a feasibility reader like the standard *Athena* — and analyses, proposals, anything taken to a stakeholder. It does **not** review code (that is Baley), and it does **not** replace the bar check (`/d101-review`): a document can pass every persona and still fail §8b, and vice versa. Run both.

## 3. The persona — the reusable form

A persona is a **stand-in for a real reader**, defined tightly enough that the review can predict where that reader stalls. Every persona names all five:

- **Identity** — who they are, in one line. A real role in the product's world, not "a business user".
- **Knows cold** — the domain they live in. This is what lets them spot condescension (a definition of something they already know) and vagueness (a made-up specific where they know the real one).
- **Does not know, and does not want to** — explicitly the codebase, the architecture, the framework, the internal vocabulary, the toolkit's own jargon. This is what lets them spot leaked mechanism and jargon.
- **Has** — a time budget (minutes, not an afternoon) and a job to get back to. This is what makes *ordering* matter: material placed after the point they stop reading is material they never see.
- **Is reviewing to** — what they are actually there to correct (facts about people, work, the domain), and, as sharply, what they are **not** there to do (approve engineering). A persona asked to approve engineering isn't a stand-in for a business reader anymore.

**One persona stands in for one reader.** Distinct readers who stall differently get distinct personas — and, since each persona ships as its own skill, distinct skills. A reader who happens to fail a document the same way as another is still authored as their own persona; the toolkit does not fold two readers into one review.

The **form** above is product-independent and travels with the toolkit. The **content** of each field — who the reader is, what they know cold, their real vocabulary — is inherently product-specific and is supplied by the product repo (this is the convention-overlay boundary, D100 §7.2.1; and it is why a persona never ships inside the toolkit — a concrete reader is a product entity, hard rule 7).

## 4. What a persona review fails a document for

These are the generic reader-hostility patterns. They are product-independent — they belong in every persona skill written for a **business reader** — and a persona author reorders them by how often each occurs in their repo and adds domain-specific ones on top. The one carve-out is the **feasibility reader** (the standard *Athena*, §7): because she deliberately knows the mechanism, the fails that depend on *not* knowing it — leaked jargon (7), definitions of the known (3) — aren't hers to catch, so she carries only the subset that survives that knowledge, plus her own feasibility fails.

1. **Meta-commentary.** Sections that explain *why* the document was written, *what method* produced it, or *what criteria* decided what counts. The reader doesn't need the criteria — they know the domain. Symptom: a section that would still make sense pasted into a different document.
2. **The author talking to themselves, with an audience present.** Bullets under a table that *discuss the table* (*"this row's description is the thinnest, which is suspicious"*). That is a working note, not content for the reader.
3. **Definitions of things the reader already knows.** A glossary entry for a term the audience uses daily reads as condescension.
4. **Internal numbers as headline facts.** *"57 of 102 mapped"* means nothing to the reader and, worse, arrives before anything that does.
5. **Contract material placed before what the reader needs.** Requirements and acceptance criteria are necessary in a D101 but are not the reader's — they fail *only* when they come before the part the reader came for.
6. **Content the reader cannot take in at once.** Tabs, accordions, one-card-per-screen — anything that stops the reader comparing items side by side, which is exactly the judgement they were asked for. A good test: could they print it and still do the review?
7. **Leaked jargon.** Words precise internally and opaque outside — including *the toolkit's own vocabulary* ("gap-free", "altitude", "surface", "it fires"). A persona is a jargon detector only if the persona itself is defined without that jargon.
8. **No worked example.** If the document describes something a person will *use*, and shows no instance of them using it, the reader cannot picture it — and cannot correct what they cannot picture.
9. **Too many questions, or questions that aren't theirs.** A handful of questions, addressed to this reader, at the end, answerable from memory. A list of twelve mixed with engineering questions gets none of them answered.

## 5. What a persona review rewards

The inverse, named so the review can say what to do, not only what to cut:

- Tables the reader can scan — grouped, with a plain-language column first.
- Concrete detail — real identifiers, real places, real durations. Made-up specifics beat accurate vagueness, because a specific the reader recognises as wrong is a specific they will *correct*.
- A drawing that shows what the prose cannot.
- Being told plainly which parts are guesses, so the reader knows where to push.
- Questions phrased to be answered from memory (*"name the last five people you set up"* beats *"which personas are valid?"*).

## 6. How a persona review is run

Read the target document **in full**, then produce two parts:

1. **The read-through, in first person, as the persona, top to bottom.** Narrate what they hit in the order they hit it — including the moment they start skipping, and *what* made them skip. Roughly 150–250 words: it is a reading experience, not an audit. Be specific about *where* they stall — *"§3 opens with 31 numbered requirements and they roll past all of them"*, never *"§3 is too long"*.
2. **The concrete cuts, in your own voice, section by section** — what to remove or change, and what replaces it.

Output shape:

```
**Review, as <Persona>:**
> [first person, top to bottom, where they stall]

**Cuts:**
- §N — [what goes, what replaces it]
```

**The feasibility reader is the exception to this shape.** A reader who knows the mechanism (the standard *Athena*, §7) does not read top to bottom — she jumps to where the design load-bears on the technology — and lists **`Concerns:`** (section, the assumption, what must be true for it to hold) in place of **`Cuts:`**. Both parts and the no-softening rule below still hold; only the reading order and the second part's heading change.

**Do not soften the review. A comfortable review found nothing** — if the read-through hits no friction, either the document is genuinely reader-ready or the persona is too weak to stall, and the second is the more common cause.

## 7. Anti-patterns — in the *persona*, not the document

A persona skill in any of these states cannot do its job:

- **A persona that has read the codebase.** The moment a persona knows the mechanism, it stops standing in for the reader who doesn't, and it silently accepts leaked jargon and code-altitude prose — the exact things it exists to catch. **The one exception is the feasibility reader** (the standard *Athena*): one persona per set is *meant* to know the mechanism — it reads §6 for whether the approach holds, and its output shape differs to match (§6 of this definition). This guard is for **business** personas; every *other* persona that has read the codebase is malformed, and a feasibility reader that *hasn't* can't do its job either.
- **A rubber-stamp persona.** One written to be reassured. It rewards everything and fails nothing; a comfortable review found nothing.
- **A persona defined in the toolkit's own jargon.** It cannot flag leaked jargon it uses itself. Define the persona in the reader's words.
- **A persona too generic to stall.** *"A business user"* with no domain they know cold cannot tell condescension from necessity, or a wrong specific from a right one. Specificity is what makes the review actionable.
- **One persona wearing two hats.** A single read asked to judge business intent *and* engineering. Split it into two personas; each fails different things.
- **Trigger phrases that don't name the persona.** The skill's `description` must carry the phrases that invoke it (*"review as <name>"*), or the reader-in-the-loop never reaches for it.
