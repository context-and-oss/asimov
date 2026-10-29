<!--
  conventions/<stack>/README.md template — the load-bearing read-list the Asimov setup
  (/asimov-init, codex-asimov-init) scaffolds for each DETECTED stack (D101-asimov-init R7).
  The build subagents read this file to load the active repo's convention overlay (D100 §7.2.1).

  HOW THE SETUP USES THIS FILE
  - Read at run-time (the file in the plugin is the source of truth — D100 §7.4).
  - Substitute placeholders:
      {{STACK}}       the stack slug, e.g. dotnet / angular / test
      {{REPO-NAME}}   the active repo name
  - Written whole to documentation/conventions/{{STACK}}/README.md when ABSENT.
  - When the file already EXISTS, only the region between the asimov:start / asimov:end
    markers is regenerated (the "managed region" — D101 R8 / NF7). Everything outside the
    markers is the team's and is never written again.
  - TWO OWNERS, ONE SPLIT (issue #3): the managed region is tool-owned — the heading and the
    explanation of what the file is. The read-list is user-owned — it sits BELOW the end
    marker, seeded once from the example lines here, never touched by a re-run. A read-list
    inside the markers would be wiped by the next refresh; the markers must never move
    below it.
  - This is a SKELETON read-list, not real rules. Asimov never invents coding conventions
    (D101 OOS2) — the team fills in the referenced files and the link list.
-->
<!-- asimov:start — managed by Asimov's setup. This region is regenerated on every re-run; your read-list and notes live below the end marker and are never touched. -->

# {{STACK}} conventions — {{REPO-NAME}}

How we write {{STACK}} code in this repo. The build subagent for this stack reads **this
file** to discover which convention files to load — it is a read-list, not prose. The Read
tool does **not** auto-expand `@`-imports, so a convention file that is not listed under
*Convention files* below is invisible to the subagent. List every file you want enforced,
one `@`-reference per line.

> **Until the listed files exist, the overlay is structurally present but empty.** The
> subagent proceeds on base competence and flags any uncovered choice (D100 §7.2.1
> "flag, don't guess").

<!-- asimov:end -->

## Convention files (read-list)

One `@`-reference per convention file in this stack. These example lines were seeded once by
Asimov's setup — replace them with the real files; a re-run never touches this list.

- `@documentation/conventions/{{STACK}}/naming.md` — naming rules
- `@documentation/conventions/{{STACK}}/structure.md` — project / folder layout
- `@documentation/conventions/{{STACK}}/patterns.md` — preferred patterns and idioms
- `@documentation/conventions/{{STACK}}/testing.md` — what/how to test

## Notes

Anything outside the markers is yours. Use this section for context the read-list above
doesn't capture.
