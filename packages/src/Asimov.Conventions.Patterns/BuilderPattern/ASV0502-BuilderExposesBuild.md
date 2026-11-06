# ASV0502 — Builders expose Build()

| | |
|---|---|
| Status | Checked |
| Analyzer | `BuilderExposesBuildAnalyzer.cs` |
| Options | none |

## Rule

Expose a `Build()` method that returns the final object, and name the class with the `Builder` suffix. This check covers the forward direction: a class that carries the suffix has the method.

## Why

`Build()` is the signal at the call site that the stages are over and the object is produced. A class called `*Builder` with no `Build()` is one of two other things — a static factory or a mapper — and the suffix then lies about how it is used.

## Checks

**Reports** a non-abstract class whose name ends with `Builder` that declares no public instance method named `Build`. A static class has no instance methods and is therefore reported.

**Does not report**

- abstract classes
- a class that inherits `Build` from its base class
- the framework's own builders — `WebApplicationBuilder`, `IHostApplicationBuilder`, `StringBuilder` are referenced, not declared

## Example

Reported:

```csharp
public static class OrderEventBuilder                               // error ASV0502
{
    public static OrderEvent BuildOrderEvent(...) { ... }
}

public class SearchQueryBuilder                                     // error ASV0502
{
    public SearchQueryBuilder FromTable(string tableName) { ... }
    public string ToQueryString() { ... }
}
```

Not reported:

```csharp
public class OrderSummaryBuilder
{
    public OrderSummaryBuilder WithLines(IReadOnlyList<OrderLine> lines) { ... }
    public OrderSummary Build() { ... }
}
```

## Fix

If the class accumulates state across calls, rename the terminal method `Build`. If it transforms in one pass, it is a mapper: make it static and name it `*Mapper`.

## Related

- [README.md](README.md) — all checks for this pattern
