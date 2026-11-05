# ASV0402 — Mapper classes are static

| | |
|---|---|
| Status | Checked |
| Analyzer | `MapperClassIsStaticAnalyzer.cs` |
| Options | none |

## Rule

Complex mappings are moved to their own `static` class with the `Mapper` suffix. The class itself is `static`.

## Why

A static class has no constructor, so it cannot take a repository or a service, cannot be registered in DI, and cannot hold state between calls. The `static` keyword on the class is what makes the other mapper rules hold without a check per method.

## Checks

**Reports** a non-static class whose name ends with `Mapper`.

**Does not report**

- a static class named `*MapperService` — the suffix is wrong, and a service rule reports a static service
- interfaces and records — a type named `*Mapper` that is not a class is a different mistake and is left to review

## Example

Reported:

```csharp
public class OrderEventMapper                            // error ASV0402
{
    public OrderEventSummary? MapFromOrderEventToOrderEventSummary(OrderEvent e) { ... }
}
```

Not reported:

```csharp
public static class OrderEventMapper
{
    public static OrderEventSummary? MapFromOrderEventToOrderEventSummary(OrderEvent e) { ... }
}
```

## Fix

Add `static` to the class and to each map method. If the class needs a constructor argument, that argument is data the caller should pass to the map method instead.

## Related

- [README.md](README.md) — all checks for this pattern
