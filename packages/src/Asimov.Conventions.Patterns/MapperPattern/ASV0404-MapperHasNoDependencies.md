# ASV0404 — Mappers have no dependencies

| | |
|---|---|
| Status | Checked |
| Analyzer | `MapperHasNoDependenciesAnalyzer.cs` |
| Options | `asimov_patterns.data_access_suffixes`, `asimov_patterns.service_suffixes`, `asimov_patterns.unit_of_work_interface` |

## Rule

No repository access. No service access. No DI. Mappers take input, return output.

## Why

A mapper that fetches is a query, and a query belongs in a service where the reader expects I/O. A mapper that takes a repository as a parameter hides the fetch behind a name that promises a pure transformation.

## Checks

A *dependency type* is a type derived from `Microsoft.EntityFrameworkCore.DbContext`, the unit-of-work interface, `IServiceProvider`, or an interface whose name starts with `I` and ends with a data-access suffix or a service suffix (defaults: `Repository`, `TableGateway`, `Service`).

**Reports** every parameter, field, property and local variable inside a class whose name ends with `Mapper` when its type is a dependency type, and every `new` of a dependency type's implementation inside such a class.

**Does not report**

- `ILogger` — not a data source, left to review
- a mapper that takes a second data object as a parameter — that is the answer to "data the input doesn't carry"

## Example

Reported:

```csharp
public static class OrderEventMapper
{
    public static async Task<OrderEventSummary> MapFromOrderEventToOrderEventSummary(
        OrderEvent e,
        IOrderRepository orderRepository)                                    // error ASV0404
    {
        var order = await orderRepository.GetByOrderId(e.OrderId);
        ...
    }
}
```

Not reported:

```csharp
public static class OrderEventMapper
{
    public static OrderEventSummary MapFromOrderEventAndOrderToOrderEventSummary(
        OrderEvent e,
        Order order)
    {
        ...
    }
}
```

## Fix

Let the caller do the lookup and pass the result in as a parameter. If the construction has stages, use a builder.

## Related

- [README.md](README.md) — all checks for this pattern
- [ASV0501](../BuilderPattern/ASV0501-BuilderHasNoDependencies.md) — the same check for builders
