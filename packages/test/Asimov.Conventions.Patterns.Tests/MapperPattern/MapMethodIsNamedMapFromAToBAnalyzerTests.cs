using Asimov.Conventions.Patterns.MapperPattern;

namespace Asimov.Conventions.Patterns.Tests.MapperPattern;

public class MapMethodIsNamedMapFromAToBAnalyzerTests
{
    private const string PublicMapWithoutShape = """
        public class Order { }
        public class OrderSummary { }

        public static class OrderToOrderSummaryMapper
        {
            public static OrderSummary {|ASV0403:Map|}(Order order) => new OrderSummary();

            public static OrderSummary {|ASV0403:MapFailedOrder|}(Order order) => new OrderSummary();

            public static OrderSummary {|ASV0403:MapFromOrder|}(Order order) => new OrderSummary();

            public static OrderSummary {|ASV0403:MapFrom|}(Order order) => new OrderSummary();

            public static OrderSummary {|ASV0403:MapFromTo|}(Order order) => new OrderSummary();
        }
        """;

    [Fact]
    public async Task ReportsPublicMapMethodsWithoutTheShape()
    {
        var test = PatternAnalyzerTest.Create<MapMethodIsNamedMapFromAToBAnalyzer>("ASV0403", enabled: true, PublicMapWithoutShape);

        await test.RunAsync();
    }

    [Fact]
    public async Task IgnoresShapedNamesPrivateMethodsAndNonMappers()
    {
        const string source = """
            public class Order { }
            public class OrderSummary { }
            public class Customer { }

            public static class OrderToOrderSummaryMapper
            {
                public static OrderSummary MapFromOrderToOrderSummary(Order order) => new OrderSummary();

                public static OrderSummary MapFromOrderAndCustomerToOrderSummary(Order order, Customer customer) => new OrderSummary();

                private static OrderSummary MapLegacyOrder(Order order) => new OrderSummary();

                internal static OrderSummary MapInternal(Order order) => new OrderSummary();
            }

            public class OrderService
            {
                public OrderSummary Map(Order order) => new OrderSummary();
            }
            """;
        var test = PatternAnalyzerTest.Create<MapMethodIsNamedMapFromAToBAnalyzer>("ASV0403", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task UsesTheProductsPrefixAndInfixWhenConfigured()
    {
        const string source = """
            public class Order { }
            public class OrderSummary { }

            public static class OrderToOrderSummaryMapper
            {
                public static OrderSummary ToSummaryFromOrder(Order order) => new OrderSummary();

                public static OrderSummary {|ASV0403:MapFromOrderToOrderSummary|}(Order order) => new OrderSummary();
            }
            """;
        var test = PatternAnalyzerTest.Create<MapMethodIsNamedMapFromAToBAnalyzer>("ASV0403", enabled: true, source);
        test.TestState.AnalyzerConfigFiles.Add(("/options.globalconfig", "is_global = true\nasimov_patterns.map_method_prefix = To\nasimov_patterns.map_method_infix = From"));

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsNothingWhenDisabled()
    {
        var source = PublicMapWithoutShape
            .Replace("{|ASV0403:Map|}", "Map")
            .Replace("{|ASV0403:MapFailedOrder|}", "MapFailedOrder")
            .Replace("{|ASV0403:MapFromOrder|}", "MapFromOrder")
            .Replace("{|ASV0403:MapFrom|}", "MapFrom")
            .Replace("{|ASV0403:MapFromTo|}", "MapFromTo");
        var test = PatternAnalyzerTest.Create<MapMethodIsNamedMapFromAToBAnalyzer>("ASV0403", enabled: false, source);

        await test.RunAsync();
    }
}
