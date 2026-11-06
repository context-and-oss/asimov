using Asimov.Conventions.Patterns.MapperPattern;

namespace Asimov.Conventions.Patterns.Tests.MapperPattern;

public class MapperHasNoDependenciesAnalyzerTests
{
    private const string MapperTakingRepository = """
        using System.Threading.Tasks;

        public class OrderEvent { }
        public class OrderEventSummary { }
        public interface IOrderRepository { }

        public static class OrderEventMapper
        {
            public static OrderEventSummary MapFromOrderEventToOrderEventSummary(
                OrderEvent e,
                IOrderRepository {|ASV0404:orderRepository|})
            {
                return new OrderEventSummary();
            }
        }
        """;

    [Fact]
    public async Task ReportsRepositoryParameterOnMapper()
    {
        var test = PatternAnalyzerTest.Create<MapperHasNoDependenciesAnalyzer>("ASV0404", enabled: true, MapperTakingRepository);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsFieldsLocalsAndCreationsOfEveryDependencyKind()
    {
        const string source = """
            using System;
            using Microsoft.EntityFrameworkCore;

            public interface IOrderService { }
            public interface IOrderTableGateway { }
            public interface IUnitOfWork { }
            public class OrderService : IOrderService { }
            public class ShopDbContext : DbContext { }

            public class OrderMapper
            {
                private readonly IOrderService {|ASV0404:orderService|};
                private readonly IUnitOfWork {|ASV0404:unitOfWork|};
                public IServiceProvider {|ASV0404:Provider|} { get; set; }

                public OrderMapper(IOrderService {|ASV0404:orderService|}, IUnitOfWork {|ASV0404:unitOfWork|}, IServiceProvider {|ASV0404:provider|})
                {
                    this.orderService = orderService;
                    this.unitOfWork = unitOfWork;
                    this.Provider = provider;
                }

                public static void MapFromAToB(IOrderTableGateway {|ASV0404:gateway|})
                {
                    var {|ASV0404:service = new OrderService()|};
                    var {|ASV0404:context = new ShopDbContext()|};
                    Use({|ASV0404:new OrderService()|});
                }

                private static void Use(object o) { }
            }
            """;
        var test = PatternAnalyzerTest.Create<MapperHasNoDependenciesAnalyzer>("ASV0404", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task IgnoresDataParametersLoggersAndNonMappers()
    {
        const string source = """
            public class OrderEvent { }
            public class Order { }
            public class OrderEventSummary { }
            public interface ILogger { }
            public interface IOrderRepository { }

            public static class OrderEventMapper
            {
                public static OrderEventSummary MapFromOrderEventAndOrderToOrderEventSummary(
                    OrderEvent e,
                    Order order,
                    ILogger logger)
                {
                    return new OrderEventSummary();
                }
            }

            public class OrderService
            {
                private readonly IOrderRepository orderRepository;

                public OrderService(IOrderRepository orderRepository)
                {
                    this.orderRepository = orderRepository;
                }
            }
            """;
        var test = PatternAnalyzerTest.Create<MapperHasNoDependenciesAnalyzer>("ASV0404", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsNothingWhenDisabled()
    {
        var source = MapperTakingRepository.Replace("{|ASV0404:orderRepository|}", "orderRepository");
        var test = PatternAnalyzerTest.Create<MapperHasNoDependenciesAnalyzer>("ASV0404", enabled: false, source);

        await test.RunAsync();
    }
}
