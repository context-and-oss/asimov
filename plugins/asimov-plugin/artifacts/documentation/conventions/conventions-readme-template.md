<!--
  conventions/<stack>/README.md template — the load-bearing read-list /asimov-init
  scaffolds for each DETECTED stack (D101-asimov-init R7). The build subagents read this
  file to load the active repo's convention overlay (D100 §7.2.1).

  HOW /asimov-init USES THIS FILE
  - Read at run-time (the file in the plugin is the source of truth — D100 §7.4).
  - Substitute placeholders:
      {{STACK}}       the stack slug, e.g. dotnet / angular / test
      {{REPO-NAME}}   the active repo name
  - Written to documentation/conventions/{{STACK}}/README.md when ABSENT.
  - When the file already EXISTS, only the region between the asimov:start / asimov:end
    markers below is refreshed (a "managed region" — D101 R8 / NF7); any content the team
    added outside the markers is preserved.
  - This is a SKELETON read-list, not real rules. Asimov never invents coding conventions
    (D101 OOS2) — the team fills in the referenced files and the link list.
-->
# {{STACK}} conventions — {{REPO-NAME}}

How we write {{STACK}} code in this repo. The build subagent for this stack reads **this
file** to discover which convention files to load — it is a read-list, not prose. The Read
tool does **not** auto-expand `@`-imports, so a convention file that is not listed below is
invisible to the subagent. List every file you want enforced.

<!-- asimov:start — managed by Asimov's setup; edit the link list, keep the markers -->

## Convention files (read-list)

Add one `@`-reference per convention file in this stack. Examples — replace with the real files:

- `@documentation/conventions/{{STACK}}/naming.md` — naming rules
- `@documentation/conventions/{{STACK}}/structure.md` — project / folder layout
- `@documentation/conventions/{{STACK}}/patterns.md` — preferred patterns and idioms
- `@documentation/conventions/{{STACK}}/testing.md` — what/how to test

> **Until these files exist and are listed, the overlay is structurally present but empty.**
> The subagent will proceed on base competence and flag any uncovered choice (D100 §7.2.1
> "flag, don't guess").

<!-- asimov:end -->

## Notes (not managed — yours to keep)

Anything below the marker is preserved across `/asimov-init` re-runs. Use it for context the
read-list above doesn't capture.
