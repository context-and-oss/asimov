# ASV0403 — Public map methods are named MapFromAToB

| | |
|---|---|
| Status | Checked |
| Analyzer | `MapMethodIsNamedMapFromAToBAnalyzer.cs` |
| Options | `asimov_patterns.map_method_prefix` (default `MapFrom`), `asimov_patterns.map_method_infix` (default `To`) |

## Rule

Method name: `MapFromAToB` where `A` is the input type, `B` is the output type. This check covers the shape of the name; that `A` and `B` match the parameter and return types is a candidate for a later generation.

## Why

The call site reads as a transformation chain: `MapFromOrderToOrderSummary(order)` says what goes in and what comes out without opening the file. A method called `Map` says neither.

## Checks

**Reports** a public method declared on a class whose name ends with `Mapper` when the method's name does not start with the prefix or does not contain the infix after at least one character of input name.

**Does not report**

- private and internal methods — a private helper may be named for what it does
- map methods outside `*Mapper` classes — a private static mapping inside a service is not the public surface the name is for

## Example

Reported:

```csharp
public static class OrderToOrderSummaryMapper
{
    public static OrderSummary Map(Order order) { ... }                    // error ASV0403
}
```

Not reported:

```csharp
public static class OrderToOrderSummaryMapper
{
    public static OrderSummary MapFromOrderToOrderSummary(Order order) { ... }
}
```

## Fix

Rename to `MapFrom{Input}To{Output}`. Two inputs are joined with `And`, as in `MapFromOrderAndCustomerToOrderSummary`.

## Related

- [README.md](README.md) — all checks for this pattern
