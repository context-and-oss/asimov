# ASV0401 — Map methods are static and synchronous

| | |
|---|---|
| Status | Checked |
| Analyzer | `MapMethodsAreStaticAndSynchronousAnalyzer.cs` |
| Options | none |

## Rule

Map methods are `static` and synchronous. Always. They are pure functions.

## Why

A mapper is a pure function: input in, output out. An instance method invites state, and a `Task` return invites I/O. Either one turns a transformation into something the caller has to reason about, and the next reader can no longer trust the name.

## Checks

A *map method* is any method declaration whose name starts with `Map`.

**Reports** a map method that is not `static`, and a map method whose return type is `Task`, `Task<T>`, `ValueTask`, `ValueTask<T>` or `IAsyncEnumerable<T>`.

**Does not report**

- ASP.NET Core route registrations — a method that takes or returns a route builder (`IEndpointRouteBuilder`, `RouteGroupBuilder`, `WebApplication`) maps a URL, not a type, whether it is a static extension or an instance method on an endpoint class
- invocations — only declarations are looked at; `app.MapGet(...)` is a call, not a map method
- private static map methods inside a service — the "simple mapping" case

## Example

Reported:

```csharp
public class OrderService : IOrderService
{
    public void MapLocationToOrderTelemetry(OrderTelemetry telemetry, Order order)   // error ASV0401
    {
        ...
    }

    private Task MapFromOrderAndSendToQueue(Order order)                             // error ASV0401
    {
        ...
    }
}
```

Not reported:

```csharp
public static class OrderSummaryMapper
{
    public static OrderSummary? MapFromOrderToOrderSummary(Order order)
    {
        ...
    }
}
```

## Fix

Make the method `static`. If it also sends, saves or fetches, split it: the pure transformation keeps the `Map` name, and the method that calls it gets a name for what it does.

## Related

- [README.md](README.md) — all checks for this pattern
- [ASV0403](ASV0403-MapMethodIsNamedMapFromAToB.md) — the name of a public map method
