using Asimov.Conventions.Patterns.BuilderPattern;

namespace Asimov.Conventions.Patterns.Tests.BuilderPattern;

public class BuilderExposesBuildAnalyzerTests
{
    private const string BuildersWithoutBuild = """
        public class OrderEvent { }

        public static class {|ASV0502:OrderEventBuilder|}
        {
            public static OrderEvent BuildOrderEvent() => new OrderEvent();
        }

        public class {|ASV0502:SearchQueryBuilder|}
        {
            public SearchQueryBuilder FromTable(string tableName) => this;

            public string ToQueryString() => string.Empty;
        }

        public class {|ASV0502:PrivateBuildBuilder|}
        {
            private OrderEvent Build() => new OrderEvent();
        }
        """;

    [Fact]
    public async Task ReportsStaticFactoryFluentWithoutBuildAndPrivateBuild()
    {
        var test = PatternAnalyzerTest.Create<BuilderExposesBuildAnalyzer>("ASV0502", enabled: true, BuildersWithoutBuild);

        await test.RunAsync();
    }

    [Fact]
    public async Task IgnoresBuildersWithBuildDeclaredOrInherited()
    {
        const string source = """
            public class OrderSummary { }

            public class OrderSummaryBuilder
            {
                public OrderSummaryBuilder WithSection(string section) => this;

                public OrderSummary Build() => new OrderSummary();
            }

            public abstract class QueryBuilderBase
            {
                public abstract string Build();
            }

            public class SearchQueryBuilder : QueryBuilderBase
            {
                public override string Build() => string.Empty;
            }

            public class CountQueryBuilder : SearchQueryBuilder
            {
            }

            public abstract class AbstractBuilder
            {
            }

            public class BuilderRegistry
            {
            }
            """;
        var test = PatternAnalyzerTest.Create<BuilderExposesBuildAnalyzer>("ASV0502", enabled: true, source);

        await test.RunAsync();
    }

    [Fact]
    public async Task ReportsNothingWhenDisabled()
    {
        var source = BuildersWithoutBuild
            .Replace("{|ASV0502:OrderEventBuilder|}", "OrderEventBuilder")
            .Replace("{|ASV0502:SearchQueryBuilder|}", "SearchQueryBuilder")
            .Replace("{|ASV0502:PrivateBuildBuilder|}", "PrivateBuildBuilder");
        var test = PatternAnalyzerTest.Create<BuilderExposesBuildAnalyzer>("ASV0502", enabled: false, source);

        await test.RunAsync();
    }
}
