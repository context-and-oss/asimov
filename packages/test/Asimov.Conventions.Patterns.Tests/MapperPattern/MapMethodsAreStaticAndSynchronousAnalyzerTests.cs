using Asimov.Conventions.Patterns.MapperPattern;

namespace Asimov.Conventions.Patterns.Tests.MapperPattern;

public class MapMethodsAreStaticAndSynchronousAnalyzerTests
{
    private const string InstanceAndAsyncMapMethods = """
        using System.Threading.Tasks;

        public class OrderTelemetry { }
        public class Order { }

        public class OrderFormatService
        {
            public void {|ASV0401:MapLocationToOrderTelemetry|}(OrderTelemetry telemetry, Order order)
            {
            }

            private static Task {|ASV0401:MapFromOrderAndSendToQueue|}(Order order)
            {
                return Task.CompletedTask;
            }
        }
        """;

    [Fact]
    public async Task ReportsInstanceAndAsyncMapMethods()
    {
        var test = PatternAnalyzerTest.Create<MapMethodsAreStaticAndSynchronousAnalyzer>("ASV0401", enabled: true, InstanceAndAsyncMapMethods);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsInstanceAsyncMethodTwice()
    {
        const string source = """
            using System.Threading.Tasks;

            public class Order { }

            public class OrderMapper
            {
                public Task<Order> {|ASV0401:{|ASV0401:MapFromRowToOrder|}|}(object row) => Task.FromResult(new Order());
            }
            """;
        var test = PatternAnalyzerTest.Create<MapMethodsAreStaticAndSynchronousAnalyzer>("ASV0401", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task IgnoresStaticSynchronousMapMethodsAndEndpointRegistrations()
    {
        const string source = """
            using System.Collections.Generic;

            public class OrderLatest { }
            public class OrderSummary { }

            public static class OrderSummaryMapper
            {
                public static OrderSummary? MapFromOrderLatestToOrderSummary(OrderLatest latest) => null;
            }

            public class OrderService
            {
                private static List<OrderSummary> MapFromOrderLatestsToOrderSummaries(List<OrderLatest> latests) => new();
            }

            public interface IEndpointRouteBuilder { }
            public sealed class RouteGroupBuilder : IEndpointRouteBuilder { }

            public static class OrderEndpoints
            {
                public static IEndpointRouteBuilder MapOrderEndpoints(this IEndpointRouteBuilder app) => app;
            }

            public class OrderGroupEndpoints
            {
                public void MapOrderEndpoints(RouteGroupBuilder group)
                {
                }
            }

            public class CommandEndpoints
            {
                public void Register(IEndpointRouteBuilder endpoints) => this.MapGetEndpoint(endpoints);

                private void MapGetEndpoint(IEndpointRouteBuilder app)
                {
                }
            }
            """;
        var test = PatternAnalyzerTest.Create<MapMethodsAreStaticAndSynchronousAnalyzer>("ASV0401", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsNothingWhenDisabled()
    {
        var source = InstanceAndAsyncMapMethods
            .Replace("{|ASV0401:MapLocationToOrderTelemetry|}", "MapLocationToOrderTelemetry")
            .Replace("{|ASV0401:MapFromOrderAndSendToQueue|}", "MapFromOrderAndSendToQueue");
        var test = PatternAnalyzerTest.Create<MapMethodsAreStaticAndSynchronousAnalyzer>("ASV0401", enabled: false, source);

        await test.RunAsync();
    }
}
