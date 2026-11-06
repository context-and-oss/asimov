using Asimov.Conventions.Patterns.BuilderPattern;

namespace Asimov.Conventions.Patterns.Tests.BuilderPattern;

public class BuilderHasNoDependenciesAnalyzerTests
{
    private const string BuilderHoldingRepository = """
        public interface IOrderRepository { }
        public class OrderSummary { }

        public class OrderSummaryBuilder
        {
            private readonly IOrderRepository {|ASV0501:orderRepository|};

            public OrderSummaryBuilder(IOrderRepository {|ASV0501:orderRepository|})
            {
                this.orderRepository = orderRepository;
            }

            public OrderSummary Build() => new OrderSummary();
        }
        """;

    [Fact]
    public async Task ReportsRepositoryFieldAndConstructorParameter()
    {
        var test = PatternAnalyzerTest.Create<BuilderHasNoDependenciesAnalyzer>("ASV0501", enabled: true, BuilderHoldingRepository);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsServiceLocalAndGatewayParameterInWithMethod()
    {
        const string source = """
            public interface IOrderService { }
            public interface IOrderTableGateway { }
            public class OrderService : IOrderService { }
            public class OrderSummary { }

            public class OrderSummaryBuilder
            {
                public OrderSummaryBuilder WithLatest(IOrderTableGateway {|ASV0501:gateway|})
                {
                    var {|ASV0501:service = new OrderService()|};
                    return this;
                }

                public OrderSummary Build() => new OrderSummary();
            }
            """;
        var test = PatternAnalyzerTest.Create<BuilderHasNoDependenciesAnalyzer>("ASV0501", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task IgnoresDataObjectsLoggersAndNonBuilders()
    {
        const string source = """
            public interface ILogger { }
            public interface IOrderRepository { }
            public class OrderLines { }
            public class OrderSummary { public OrderLines? Lines { get; set; } }

            public class OrderSummaryBuilder
            {
                private readonly OrderSummary summary = new();
                private readonly ILogger logger;

                public OrderSummaryBuilder(ILogger logger)
                {
                    this.logger = logger;
                }

                public OrderSummaryBuilder WithLines(OrderLines lines)
                {
                    this.summary.Lines = lines;
                    return this;
                }

                public OrderSummary Build() => this.summary;
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
        var test = PatternAnalyzerTest.Create<BuilderHasNoDependenciesAnalyzer>("ASV0501", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task UsesTheProductsSuffixesWhenConfigured()
    {
        const string source = """
            public interface IOrderStore { }
            public interface IOrderRepository { }
            public class OrderSummary { }

            public class OrderSummaryBuilder
            {
                private readonly IOrderStore {|ASV0501:store|};
                private readonly IOrderRepository repository;

                public OrderSummaryBuilder(IOrderStore {|ASV0501:store|}, IOrderRepository repository)
                {
                    this.store = store;
                    this.repository = repository;
                }

                public OrderSummary Build() => new OrderSummary();
            }
            """;
        var test = PatternAnalyzerTest.Create<BuilderHasNoDependenciesAnalyzer>("ASV0501", enabled: true, source);
        test.TestState.AnalyzerConfigFiles.Add(("/options.globalconfig", "is_global = true\nasimov_patterns.data_access_suffixes = Store"));

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsNothingWhenDisabled()
    {
        var source = BuilderHoldingRepository.Replace("{|ASV0501:orderRepository|}", "orderRepository");
        var test = PatternAnalyzerTest.Create<BuilderHasNoDependenciesAnalyzer>("ASV0501", enabled: false, source);

        await test.RunAsync();
    }
}
