# Diagram templates

Four recognised standard notations, drawn in the Asimov skin. A D101 picks one per
diagram — it does not invent a fifth.

## Pick the type from the question, not from the section

**Pick the type from what the reader must understand, not from which § the diagram
sits in.** One D101 section may carry a sequence diagram; another may carry a state
machine. The section number tells you nothing about the notation.

| The reader must understand… | Diagram type | Template |
|---|---|---|
| Who does what, when — two or more actors exchanging messages | UML sequence | `sequence-template.svg` |
| Which actor owns each step of an ordered process | UML activity with swimlanes | `activity-swimlane-template.svg` |
| The states a thing moves through, and which transitions are legal | UML state machine | `state-machine-template.svg` |
| An ordered run of steps with one actor, including branches | Flowchart (ISO 5807) | `flowchart-template.svg` |
| None of the above | — | Write prose. Do not invent a diagram type. |

## Only recognised notations live here

A diagram a reviewer cannot name by its standard does not belong in a D101. That is
the whole point of this folder: the reviewer says "this is a state machine" and
points at the standard, instead of arguing about boxes.

ER diagrams and C4 container diagrams are deliberately absent. Add them when a D101
actually needs a data model or a system-boundary view, not before.

## How to use a template

1. Open the template and read its leading XML comment — it is the contract: when to
   use the type, the nearest wrong choice, the budget, the notation elements, the
   geometry a re-draw must preserve, and the anti-patterns.
2. Copy the `<svg>` body into the D101. Replace every `{{placeholder}}`.
3. Obey the budget in that file's leading comment.
4. Wrap the `<svg>` in `<div class="flow-wrap">`.
5. Add a `<div class="flow-legend">` below it naming **only the colours actually
   used** in your diagram — not the full palette.
6. Keep the detailed numbered step list below the legend in `<ol class="principles">`.
   The diagram carries the shape; the list carries the detail. The list is
   finer-grained than the diagram by design — a step can be compressed into one
   arrow or land inside a combined fragment — so never number sequence messages to
   match it (a flowchart is the one exception: its zero-padded step numbers are
   meant to line up with the list).
7. Keep every `id` unique across the whole page. The marker ids here are already
   prefixed per type (`seq-arr`, `act-arr`, `sm-arr`, `fc-arr`); if a page embeds two
   diagrams from the same template, suffix them. `url(#id)` resolves to the first
   match in document order, so a duplicate id silently borrows the wrong arrowhead.

Each template's first child is a background rect filling the viewBox with `#14253f`
(`--bg-card`). Inside `.flow-wrap` it is invisible; opened standalone in a browser it
is what makes the white text readable. Keep it.

## Shared colour semantics

No diagram introduces a colour outside the token set.

| Meaning | Token |
|---|---|
| Entry / gating / start | `--green` `#66bb6a` |
| Read or write to a data store | `--cyan` `#4fc3f7` |
| Transform / decode / work in progress | `--amber` `#ffb74d` |
| Destructive or terminal | `--coral` `#ef5350` |
| Delegated downstream / out of scope | dashed border + `#122039` fill |

Fills use the token at low alpha with the token as stroke, e.g.
`fill="#66bb6a22" stroke="#66bb6a"`.

## Over budget

Every template carries a hard node/edge ceiling. When a diagram exceeds it, **split
into an overview diagram (the main path) plus a detail diagram** — never grow one
diagram past its ceiling. A diagram nobody can read is worse than two diagrams.
