# Deck

The skeleton a slide deck is written from: one HTML file that presents in a browser, shows
speaker notes under `N` and prints to a PDF with one landscape page per slide under
`Ctrl+P`. The form is a resource, not an artifact: a pitch, a session or a briefing is a
deck; an artifact that *is* a deck (the A100 scoping report, when it lands) builds its
template on this one and adds its own definition.

```
resources/deck/
├── deck-template.html    ← the skeleton: mechanics, components, the token contract, four example slides
├── themes/
│   ├── asimov.css        ← dark, the site's palette; the default
│   └── light.css         ← neutral light; the starting point for a brand theme
└── README.md             ← this file
```

The skill that writes a deck from it is `skills/tool-deck-authoring`.

## How a deck is built

1. Copy `deck-template.html`. Its leading comment is the contract: the ground rules, the
   component catalogue and the token contract. Read it before writing.
2. Paste one theme file whole where the template says `{{THEME}}`, at the top of the
   `<style>`. The theme's `@import` must be the first rule in the stylesheet; comments may
   precede it, no rule may.
3. Replace every `{{placeholder}}`; keep the script and the print block unchanged.
4. One `<section class="slide">` per slide, one `<aside class="notes">` in each.
5. Check it: open the file with `?pages` after its name and every slide shows at page size,
   one under the other; a screenshot of that view at 1180 × (740 × slides) shows what
   overflows. The screenshot and the PDF are check output: they go to a scratch folder,
   never beside the deck. `old/` beside the deck holds the previous versions and is kept.

## Themes

A theme is one CSS file: a header comment naming the theme and its brand word (`brand:`,
`none` in a shipped theme, which has no brand to speak for), the font `@import`, and one
`:root` block that defines every token of the contract. Nothing else.
The template's alias block maps the names the site's figures use (`--cyan`, `--bg-card`,
`--border-2`, …) onto the contract, so a theme never defines those and a figure pasted from
the site or a D101 takes the theme as it is.

| Token | What it colours |
|---|---|
| `--bg` `--bg-alt` `--surface` | the page, the alternate band (`.slide.alt`), cards and figures |
| `--border` `--border-strong` | hairlines, emphasised lines and `kbd` |
| `--text` `--text-dim` `--text-mute` | headings, body, captions |
| `--brand` `--brand-2` | kickers, emphasis, the counter, the first accent of a figure; its companion |
| `--ok` `--warn` `--bad` `--extra` | the semantic accents: green-ish, amber-ish, red-ish, one more |
| `--sans` `--mono` | the two font stacks; the `@import` above the block fetches them |
| `--nav-bg` | the translucent top bar |
| `--on-brand` | text set on a brand-coloured fill |

**Where a theme is found**, in this order, by its slug:

1. A path named in the message.
2. The product repo: `documentation/decks/themes/<slug>.css`. Brand themes live here, never
   in the plugin: a company's, a customer's. The plugin is public; a brand is not.
3. The plugin: `resources/deck/themes/<slug>.css`. Two ship: `asimov` and `light`.

No slug named means `asimov`. A theme described in words ("light", "dark", "bright room") is
matched to a shipped slug; a brand named in words ("in our colours", a company's name) is a
slug looked up in the product repo. A slug found nowhere is a stop, not a guess.

**Writing a brand theme:** copy `light.css` (or `asimov.css` for a dark brand) to the product
repo, set `brand:` in the header, `--brand`, `--brand-2` and the fonts, then adjust the rest
only where the brand's guide says so. Check it by writing the template's four example slides
with it and opening the file; every component should read, and nothing should be the same
colour as its background.

## Building an artifact template on the deck

An artifact that is presented rather than read (a scoping report, a closure report) takes
this template as its base: same mechanics, same contract, same themes. Its own template
fixes what the skeleton leaves open: the slide list, what each slide must say, which
components it uses, its header comment's extra lines. It carries no CSS of its own beyond
the components its slides need, and it never redefines a token. The definition beside it
states the bar; the deck README is not a definition and states none.
