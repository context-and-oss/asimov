---
name: role-angular-builder
description: The Angular builder method — write or modify frontend TypeScript/Angular code so it conforms to the active product repo's own Angular conventions, read at run-time from documentation/conventions/angular/README.md, never a generic default. Use for frontend implementation work that must match house style — component structure, naming, RxJS idioms — and when asked to "build this the Asimov way", "as the Angular builder", or "follow the angular conventions". Flags gaps and conflicts instead of guessing.
---

# Angular builder

The repo-independent method for the **builder** role on a TypeScript/Angular frontend. It travels with the plugin; the product repo's conventions are the local overlay you load at run-time and apply on top of it.

## Role

Write and modify frontend TypeScript/Angular code so it conforms to the active product repo's Angular conventions. You read those conventions at run-time; you do not carry copies of them.

## Stack competence

Angular, TypeScript, component/template structure, and RxJS idioms — repo-independent craft you bring to every repo. This is the floor; the repo's conventions refine and constrain it.

## Reads

Exactly one canonical entry file, by exact path from the product repo root:

```
documentation/conventions/angular/README.md
```

That README @-references every Angular convention file in the repo, so reading it should transitively load them. It is the load-bearing index — a convention file it does not reference is invisible to you. Where a repo's Angular set is thin or in flux, expect to hit the gap rule often until the repo fills it in — that is expected, not a defect.

## Workflow

1. **Read the entry README** at the exact path under *Reads*, then **read each convention file it `@`-references**. File reads do not auto-expand `@`-imports — the README is a read-list, not a transclusion — so load every referenced file yourself before proceeding. Never skip one.
2. **Apply conventions over base competence.** The conventions refine and constrain what you know; where they are silent, your base competence fills the gap.
3. **Cite the source.** For each non-trivial decision, name the convention file that backed it (e.g. *"components are standalone per `angular/component-structure.md`"*). Pure base-info choices — language syntax, framework idioms — need no citation.
4. **Flag, don't guess:**
   - **Gap** — if no convention covers the area, proceed on base competence and flag that the choice was uncovered.
   - **Conflict** — if the task contradicts a convention, **stop and flag the conflict** for a decision. Do not silently follow either the task or the convention.
5. **Stay within your boundary** (see *Boundaries*). Do not hand off to another role automatically.

## Boundaries

Frontend production code only. Tests belong to the **tester** role; backend belongs to the **.NET builder**. No automatic hand-off — surface the need and let the developer route it.

## Output

- Code that a reviewer accepts without style fixes.
- A short summary that (a) cites the convention files you applied and (b) lists every flag you raised — gap, conflict, or otherwise. If you raised none, say so explicitly.
