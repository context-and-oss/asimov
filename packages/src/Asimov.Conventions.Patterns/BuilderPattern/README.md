# Builder Pattern — checks

## Purpose

The compiler checks for the builder pattern: a class with the `Builder` suffix accumulates state across `With*` calls and produces the final object in `Build()`. One check is one diagnostic id, one markdown file describing it, and one analyzer class.

## Rules

| Id | Rule | Status |
|---|---|---|
| — | Single-use. A builder instance produces one object and is discarded. | Review; a second `Build()` call on the same instance is a run-time fact |
| [ASV0501](ASV0501-BuilderHasNoDependencies.md) | No repository access. No service access. No DI. | Checked |
| — | Fluent interface preferred — methods return `this` so calls chain. | Candidate; preferred, not always |
| [ASV0502](ASV0502-BuilderExposesBuild.md) | Expose a `Build()` method that returns the final object. | Checked |
| — | Name with the `Builder` suffix. | Review for the reverse direction: a builder-shaped class under another name. The forward direction is ASV0502 |

Status values: **Checked** — analyzer built, tests green. **Planned** — the markdown describes the check; the analyzer is not written yet. **Candidate** — a later generation. **Review** — not mechanisable; stays with code review.

## Why

ASV0502 is what makes the suffix mean one thing: a class called `*Builder` with no `Build()` is a static factory or a mapper wearing the wrong name. ASV0501 keeps the assembly testable without a database.

## Enable

In the product's convention globalconfig:

```ini
dotnet_diagnostic.ASV0501.severity = error
dotnet_diagnostic.ASV0502.severity = error
```

ASV0501 reads `asimov_patterns.data_access_suffixes`, `asimov_patterns.service_suffixes` and `asimov_patterns.unit_of_work_interface` (see the [package README](../README.md)).

## Related

- [Package README](../README.md) — options, the no-suppression rule
