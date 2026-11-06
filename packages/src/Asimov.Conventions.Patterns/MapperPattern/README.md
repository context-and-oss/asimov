# Mapper Pattern — checks

## Purpose

The compiler checks for the mapper pattern: a transformation from one type to another is a pure function, `static` and synchronous, named so the call site reads as a transformation, and complex ones live in a `static` class with the `Mapper` suffix. One check is one diagnostic id, one markdown file describing it, and one analyzer class.

## Rules

| Id | Rule | Status |
|---|---|---|
| [ASV0401](ASV0401-MapMethodsAreStaticAndSynchronous.md) | Map methods are `static` and synchronous. Always. They are pure functions. | Checked |
| — | Simple mappings can live as a private `static` method inside the class that uses them. | Review |
| [ASV0402](ASV0402-MapperClassIsStatic.md) | Complex mappings are moved to their own `static` class with the `Mapper` suffix. The class itself is `static`. | Checked |
| [ASV0403](ASV0403-MapMethodIsNamedMapFromAToB.md) | Method name: `MapFromAToB` where `A` is the input type, `B` is the output type — the shape | Checked |
| — | `A` and `B` match the parameter and return type names | Candidate; products join two inputs with `And` and name an output by meaning, so the match needs rules of its own |
| [ASV0404](ASV0404-MapperHasNoDependencies.md) | No repository access. No service access. No DI. Mappers take input, return output. | Checked |
| — | Null in → null out, where the signature allows it. | Review; nullable annotations carry it |
| — | When to extract into a `Mapper` class; when to use a builder instead. | Review |

Status values: **Checked** — analyzer built, tests green. **Candidate** — a later generation. **Review** — not mechanisable; stays with code review.

## Why

All four checks are structure: a mapper that is an instance, or async, or takes a repository, is a service under another name, and the point of the checks is to keep the two apart.

## Enable

In the product's convention globalconfig:

```ini
dotnet_diagnostic.ASV0401.severity = error
dotnet_diagnostic.ASV0402.severity = error
dotnet_diagnostic.ASV0403.severity = error
dotnet_diagnostic.ASV0404.severity = error
```

ASV0403 reads `asimov_patterns.map_method_prefix` (default `MapFrom`) and `asimov_patterns.map_method_infix` (default `To`). ASV0404 reads the layer-name options (see the [package README](../README.md)).

## Related

- [Package README](../README.md) — options, the no-suppression rule
- [BuilderPattern](../BuilderPattern/README.md) — the multi-stage counterpart
