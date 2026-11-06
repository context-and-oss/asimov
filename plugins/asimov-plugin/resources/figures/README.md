# Figures

The drawing language of an Asimov illustration: the glyphs, the seven patterns and the rules
that make a new figure about anything look like the ones before it. Not a gallery: a figure
drawn for one deck is that deck's; what ships here is the hand it was drawn with.

```
resources/figures/
├── README.md               ← this file: figure or diagram, the grammar, the routing table
├── glyphs.svg              ← the symbols: person, approving person, agent, document, stack, decision, result, bubble, diff, avatar, chip, window
├── scene-template.svg      ← two panels, before and after
├── track-template.svg      ← a row of steps with the decisions marked (and the timeline variant)
├── map-template.svg        ← the parts of a thing in lanes, with a key
├── grid-template.svg       ← columns by bands, a cell at every crossing
├── page-template.svg       ← one document as a schematic page, with callouts
├── roster-template.svg     ← who does what to what: an input, groups of actors, outcomes
└── terminal-template.svg   ← the tool in use: one exchange in a Claude Code window
```

## Figure or diagram

A **diagram** is a notation a reviewer can name by its standard: a sequence, a swimlane, a
state machine, a flowchart. It lives in `resources/diagrams/` and belongs in a D101, where
the argument must be checkable. A **figure** is an illustration: it shows a situation, a
change or a landscape so a listener gets it in three seconds. It belongs on a slide, on a
site page, in a D101's §2 where the purpose is shown before it is argued. Same skin, same
colour semantics, different job. When the reader must verify, draw a diagram; when the
reader must see, draw a figure.

## Pick the pattern from what the reader must see

| The reader must see… | Pattern | Template |
|---|---|---|
| Two states of the same thing, today and after | Scene | `scene-template.svg` |
| One thing travelling through steps, and where people decide | Track | `track-template.svg` |
| What a thing is made of, in lanes, and how the parts relate | Map | `map-template.svg` |
| How one thing varies across another: two named axes, a cell at each crossing | Grid | `grid-template.svg` |
| What is in one document, and who reads which part | Page | `page-template.svg` |
| Who the actors are, in groups, what they work on and what they produce | Roster | `roster-template.svg` |
| What it looks like to use: the command, what the agent read and asked | Terminal | `terminal-template.svg` |
| A plan of steps with nothing to show at each: dots on a line | Track, timeline variant | `track-template.svg`, VARIANT |
| A notation: who sends what, who owns which step, states, branches | — | `resources/diagrams/README.md` |
| None of these | — | No figure. The sentence on the slide is enough. |

## The grammar

Every figure, whichever pattern:

1. **Stroke, not fill.** Outlines at 1.5 (2.5 for a person), corners rounded; a fill is the
   stroke's colour at 10–18 % opacity, never a solid. This is why a figure survives a dark
   and a light theme.
2. **Colour is meaning.** Green: a person decides. Cyan or brand: the toolkit writes. Amber:
   the toolkit reads, reviews or builds. Violet: a method. Coral: a stop or an end. Text-dim:
   a person who only acts. A glyph takes the colour of what it means, never of what it is,
   and a figure uses no colour outside the token set. One literal is allowed, the harness's
   own orange dot in the terminal pattern, because it is the tool's colour and not ours.
3. **Tokens with fallbacks.** Every colour is a site token with its dark value as fallback,
   `var(--cyan, #4fc3f7)`, so one SVG works in a D101, on the site, in a deck in any theme
   (the deck template's alias block maps the names) and opened alone in a browser.
4. **Glyphs, not boxes.** A person is a person, a document a document, a decision a diamond.
   The glyphs are `glyphs.svg`'s, copied into the figure's `<defs>` and placed with `<use>`;
   a new glyph is added there first, drawn in `currentColor`, before any figure uses it.
5. **Text in two registers.** Labels in mono, upper case, letter-spaced, under or beside a
   glyph, one or two words. One caption per panel or per figure in the sans, one sentence.
   Nothing else: the slide's heading and lead carry the argument, the figure shows it.
6. **One figure, one point.** The budget is in each template's leading comment; over it,
   the figure is two figures. A figure the eye cannot take in at once is worse than none.
7. **Background rect first.** Each template's first child fills the viewBox with the card
   token; inside a card it is invisible, opened alone it makes the text readable. Keep it.
8. **Ids unique on the page.** The template ids are prefixed (`sc-`, `tr-`, `mp-`, `gr-`, `pg-`, `rs-`, `tm-`, `fg-`);
   a page holding two figures from one template suffixes them, because `url(#id)` resolves
   to the first match in document order.
9. **Every figure has an `aria-label`** that says in one sentence what it shows: the slide's
   screen reader, the PDF's alt text, and the next writer's summary.

## How to use a template

1. Read the template's leading comment: when, when not, the budget, the elements, the
   colours, the geometry, the anti-patterns.
2. Copy the `<svg>` whole. Replace every `{{placeholder}}`; delete a station, a panel's glyph,
   a column or a lane whole rather than leaving a placeholder or an empty box.
3. Keep the geometry the comment fixes; move a glyph on the grid it names.
4. In a deck, wrap it in `.figure` with a `.caption`; in a D101, in `.flow-wrap` with a
   `.flow-legend` naming only the colours used; on the site, as the page's figures are.
5. Render it and look before you ship it: a figure is checked by eye, not by a script.

## Adding a pattern

A pattern is added when the same new shape has been drawn twice by hand; the seven here
were. Its template follows them: a leading comment with the seven headings, a background
rect, the glyphs it uses copied into its `<defs>` with its own prefix, placeholders, every
coordinate even. The routing table above gains a row; `resources/diagrams/README.md` keeps
its own.
