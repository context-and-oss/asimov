# Delivery Model: generated bundle

The Delivery Model: four fixed phases, a catalogue of approaches combined per engagement, and the
disciplines exercised underneath them. The `pm-advisor` skill reads these files at run time and
advises from them, so they are the contract for what the model says.

The model itself is described in `delivery-model-framework.md`, which owns the name. This page is
about the folder.

## This folder is generated, so do not edit it here

The material is authored in the Learn, Engineer, Deliver working vault and exported here. **An
edit made in this folder is lost at the next export, silently.** To change what a page says,
change it at the source and export again.

**The export rules have already been applied.** The vault mixes the delivery-model content with
working commentary: ownership, provenance, open questions, colleague names. That layer has been
removed from every file here. Nothing is missing by accident, and there is no fuller version to
go looking for.

## The vocabulary

Three levels, and they are not interchangeable:

| Term | Meaning |
|---|---|
| **Phase** | One of four fixed stages. The frame never changes: **Proposal → Scoping → Development → Operations**, looping from Operations back to Proposal for the next engagement. |
| **Approach** | A way of running the work — Scrum, Kanban, prototyping, use-case delivery, launch & hyper care. Combined per project. The phases are fixed; the approaches are chosen. |
| **Discipline** | A practice that must be under control on any engagement, and that a person can get better at. Independent of approach: the approach decides *when and how often* a discipline is exercised, not *whether*. |

There is no separate "agentic delivery model". Agentic delivery is an execution mode — the same
phases, approaches and artefacts, produced either by hand or by agents.

## Reading it

`delivery-model-framework.md` is the map: the one idea, the design principles, and what hangs off
them. Start there when the routing is unclear.

Every relative link resolves inside this folder, so a link is a path that can be opened. Every
page keeps its H1, which is the name to cite it by.

## Status

All 41 pages are drafts. The model is coherent and in use, but it is being actively
worked and is not a ratified standard, so say so when advising from it. The notice is stated
once here rather than in every page's frontmatter: a warning carried 41 times is one
readers learn to skip.

## Provenance

| | |
|---|---|
| Exported | 2026-09-22 12:47 |
| Source commit | `d8bf9cc` |
| Files | 41 |

## Refreshing

From the source vault:

```powershell
.\tools\export-delivery-model.ps1 -Target plugin
```

That writes a staging bundle. Copy it over this folder and commit the diff. To check first
whether this copy has fallen behind, add `-Compare <path to this folder>`.
