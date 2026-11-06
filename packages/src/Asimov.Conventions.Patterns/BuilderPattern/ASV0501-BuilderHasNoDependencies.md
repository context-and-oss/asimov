# ASV0501 — Builders have no dependencies

| | |
|---|---|
| Status | Checked |
| Analyzer | `BuilderHasNoDependenciesAnalyzer.cs` |
| Options | `asimov_patterns.data_access_suffixes`, `asimov_patterns.service_suffixes`, `asimov_patterns.unit_of_work_interface` |

## Rule

No repository access. No service access. No DI. A builder assembles from what it is given.

## Why

A builder that fetches blurs into a service: the caller can no longer tell which `With*` call did I/O, and a unit test of the assembly needs a database. Pass data in; assemble from what you are given.

## Checks

A *dependency type* is a type derived from `Microsoft.EntityFrameworkCore.DbContext`, the unit-of-work interface, `IServiceProvider`, or an interface whose name starts with `I` and ends with a data-access suffix or a service suffix (defaults: `Repository`, `TableGateway`, `Service`).

**Reports** every constructor parameter, method parameter, field, property and local variable inside a class whose name ends with `Builder` when its type is a dependency type, and every `new` of a dependency type's implementation inside such a class.

**Does not report**

- `ILogger` — not a data source, left to review
- the data objects the builder assembles from — entities, rows, view models

## Example

Reported:

```csharp
public class OrderSummaryBuilder
{
    private readonly IOrderRepository orderRepository;          // error ASV0501

    public OrderSummaryBuilder(IOrderRepository orderRepository) // error ASV0501
    {
        this.orderRepository = orderRepository;
    }
}
```

Not reported:

```csharp
public class OrderSummaryBuilder
{
    private readonly OrderSummary summary = new();

    public OrderSummaryBuilder WithLines(IReadOnlyList<OrderLine> lines)
    {
        this.summary.Lines = lines;
        return this;
    }

    public OrderSummary Build() => this.summary;
}
```

## Fix

Let the caller fetch and pass the result into the matching `With*` call.

## Related

- [README.md](README.md) — all checks for this pattern
