using Asimov.Conventions.Patterns.MapperPattern;

namespace Asimov.Conventions.Patterns.Tests.MapperPattern;

public class MapperClassIsStaticAnalyzerTests
{
    private const string InstanceMapper = """
        public class OrderEvent { }
        public class OrderEventSummary { }

        public class {|ASV0402:OrderEventMapper|}
        {
            public OrderEventSummary? MapFromOrderEventToOrderEventSummary(OrderEvent e) => null;
        }
        """;

    [Fact]
    public async Task ReportsInstanceMapperClass()
    {
        var test = PatternAnalyzerTest.Create<MapperClassIsStaticAnalyzer>("ASV0402", enabled: true, InstanceMapper);

        await test.RunAsync();
    }

    [Fact]
    public async Task IgnoresStaticMappersInterfacesRecordsAndOtherNames()
    {
        const string source = """
            public class OrderEvent { }
            public class OrderEventSummary { }

            public static class OrderEventMapper
            {
                public static OrderEventSummary? MapFromOrderEventToOrderEventSummary(OrderEvent e) => null;
            }

            public interface IColumnMapper { }

            public record ColumnMapper(string Name);

            public static class OrderEventMapperService { }

            public class OrderService { }
            """;
        var test = PatternAnalyzerTest.Create<MapperClassIsStaticAnalyzer>("ASV0402", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsNothingWhenDisabled()
    {
        var source = InstanceMapper.Replace("{|ASV0402:OrderEventMapper|}", "OrderEventMapper");
        var test = PatternAnalyzerTest.Create<MapperClassIsStaticAnalyzer>("ASV0402", enabled: false, source);

        await test.RunAsync();
    }
}
