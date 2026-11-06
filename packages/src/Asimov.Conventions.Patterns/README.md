# Asimov.Conventions.Patterns

Roslyn analyzers for the architectural patterns a .NET product opts into. One pattern is one folder: a README with the rule table, one markdown file per rule, one analyzer class per rule.

Every rule is **disabled by default**. A product's convention package turns on the patterns it uses from its globalconfig, exactly as Asimov.Conventions turns on Sonar and Meziantou rules from its category files:

```ini
dotnet_diagnostic.ASV0501.severity = error
dotnet_diagnostic.ASV0502.severity = error
```

Product-specific names are analyzer options with defaults, set in the same globalconfig when the defaults do not fit:

| Option | Default | Used by |
|---|---|---|
| `asimov_patterns.data_access_suffixes` | `Repository;TableGateway` | every "no data access" rule |
| `asimov_patterns.service_suffixes` | `Service` | every "no dependencies" rule |
| `asimov_patterns.unit_of_work_interface` | `IUnitOfWork` | every "no data access" rule |
| `asimov_patterns.map_method_prefix` | `MapFrom` | ASV0403 |
| `asimov_patterns.map_method_infix` | `To` | ASV0403 |

## Patterns

| Folder | Rules |
|---|---|
| [MapperPattern](MapperPattern/README.md) | ASV0401, ASV0402, ASV0403, ASV0404 |
| [BuilderPattern](BuilderPattern/README.md) | ASV0501, ASV0502 |

Agents never suppress a rule: no `#pragma warning disable ASV*`, no `[SuppressMessage]`, no `.editorconfig` line. A suppression is a human commit with a reason.
