---
name: tool-deck-authoring
description: How to write a slide deck as one self-contained HTML file from the plugin's deck resource (resources/deck/) — presented in a browser, speaker notes under N, a PDF under Ctrl+P, styled by one theme file. Use whenever someone asks for a presentation, a deck, slides, a pitch, a talk, a session, a briefing, "slides for Monday", "a short deck for the leadership group", a new version of an existing deck, or a deck in another brand's theme. Not for an A100 or any artifact with its own template; those build on the resource through their own skill.
---

# Deck authoring

The method for writing a deck from `resources/deck/`. The resource owns the form (the
mechanics, the components, the token contract, the themes); this skill owns how a deck gets
from a request to a file: what to find out, the outline, the write, the check.

## Read first

In Claude Code `${CLAUDE_PLUGIN_ROOT}` is the plugin root and is substituted for you. In Codex
the variable stays literal and a `..` path resolves from the working directory, so derive the
root once: take this skill's file path as Codex shows it, strip everything from
`skills/tool-deck-authoring` onward, and use what remains as `<plugin-root>` in every path
below, absolute. Verify it by reading file 1; if that fails, Glob
`<home>/.codex/plugins/cache/**/deck-template.html`, take the match whose path shares the
longest prefix with the skill path, and if nothing matches stop and report the path you
derived and the search you ran (the method of `D101-codex-support.html` §6.2).

1. **The template** — its leading comment is normative: the ground rules, the component
   catalogue, the token contract and the placeholders. Its body is what you copy.

   ```
   ${CLAUDE_PLUGIN_ROOT}/resources/deck/deck-template.html
   ```

2. **The README** — how a deck is built, where a theme is found, what a theme is.

   ```
   ${CLAUDE_PLUGIN_ROOT}/resources/deck/README.md
   ```

3. **The theme**, once chosen, found in the README's order (a path in the message, the
   product repo's `documentation/decks/themes/<slug>.css`, the plugin's
   `resources/deck/themes/<slug>.css`). Default `asimov`. Not found is a stop.

4. **The figures README**, before drawing anything:

   ```
   ${CLAUDE_PLUGIN_ROOT}/resources/figures/README.md
   ```

5. **The previous version**, when the request names an existing deck: read the whole file.
   Its header comment is the deck's memory; the new version is written from it.

Never write from a remembered copy of the template; the file in the plugin is the source.

## What you need before the outline

From the message, or asked in one message with defaults, at most five questions:

| Need | Default when unsaid |
|---|---|
| Audience and occasion (who is in the room, what for) | none: ask |
| Length in minutes | ten; the slide count follows ground rule 2 (five for five minutes, seven for ten) |
| The line of the deck, one sentence the listener should repeat | drafted from the message and shown in the outline |
| Theme: a slug, a path, or words ("light", "in our colours") matched per the README | `asimov` |
| Who presents: name, role, contact | the git user's name and email; the role is asked |

The brand word (ground rule 9) is not a question: a brand theme's header says it; with a
shipped theme it is the organisation or product the deck speaks for, from the message or the
repo's name. The slides speak the language of the message; the header comment is English.

Where the deck lands is not a question: `documentation/decks/<slug>.html` in the current repo,
`<slug>` the occasion in kebab-case (`aalborg-ai-session`) or the topic when no occasion is
named (`specs-move`), or the path the message names.
A new version of an existing deck overwrites it and moves the old file to
`old/<slug>-v<N>.html` beside it, `<N>` the version its header comment carried.

## Method

1. **Outline first.** Print the slide list in chat: one line per slide, the message as the
   sentence the slide will carry, the component it uses in brackets, the line of the deck
   above the list. Wait for the go. An outline is cheap to change; a written deck is not.
2. **Write.** Copy the template, paste the theme whole at `{{THEME}}`, write the header
   comment (ground rule 4: file, audience, occasion, length, the line, the slide list, the
   version log), replace every placeholder, one section per slide, one `<aside class="notes">`
   in each. The script and the print block stay as they are. A figure is inline SVG with
   ids unique across the page, drawn from `${CLAUDE_PLUGIN_ROOT}/resources/figures/`: its
   README routes what the reader must see to a pattern (a scene, a track, a map) and the
   glyphs; a notation the reader must check (a sequence, a swimlane, a state machine, a
   flowchart) comes from `${CLAUDE_PLUGIN_ROOT}/resources/diagrams/` instead. A figure from a D101 or the repo's
   documentation site may be borrowed when it shows the thing already.
3. **Check.** Render before reporting: one screenshot of the `?pages` view, tall enough for
   every slide, and the PDF, with the commands below or the harness's browser; look at the
   screenshot and count the PDF's pages against the slides. Fix what overflows a page before
   the person sees it; a slide that fits the screen and not the page is the failure this
   step exists for. The check files go to the scratch folder, never beside the deck. Edge
   prints `ERROR` lines about a fallback task provider; they are noise, not a failure.
4. **Report.** The path, the slide count, the theme, the three keys (`→` slides, `N` notes,
   `Ctrl+P` PDF) and any default the person did not give. Nothing else: the deck is the
   deliverable.

```
# Windows, Edge: every slide at page size in one image (height 740 × slides), then the PDF
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --headless --disable-gpu --window-size=1180,3700 --screenshot="<scratch>\<slug>-pages.png" "file:///<path>.html?pages"
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="<scratch>\<slug>.pdf" "file:///<path>.html"
```

## Boundaries

- One message per slide; a slide that needs two is two slides. The h2 is a sentence.
- No colour outside the theme: a tint is `color-mix()` of a token, a new shade is a change
  to the theme file, which this skill never makes on its own. A theme is asked for, found or
  stopped on, never invented.
- No external script, no framework, no image file. The theme's fonts are the file's one
  fetch.
- Speaker notes on every slide, saying what to say. A slide without notes is unfinished.
- Brand words come from a brand theme's header (`brand:`), else from the message or the
  repo; never from the template, which carries none, and never a shipped theme's name.
- Never an A100 or another artifact's template: an artifact that is a deck has its own
  skill, which reads the same resource.
