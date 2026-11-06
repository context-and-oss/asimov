using System;
using System.Collections.Immutable;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Diagnostics;

namespace Asimov.Conventions.Patterns.MapperPattern;

[DiagnosticAnalyzer(LanguageNames.CSharp)]
public sealed class MapMethodsAreStaticAndSynchronousAnalyzer : DiagnosticAnalyzer
{
    public const string DiagnosticId = "ASV0401";

    private static readonly ImmutableHashSet<string> AsyncReturnTypes = ImmutableHashSet.Create(
        StringComparer.Ordinal, "Task", "ValueTask", "IAsyncEnumerable");

    private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(
        id: DiagnosticId,
        title: "Map methods are static and synchronous",
        messageFormat: "Map method '{0}' {1}; a mapper is a pure function, static and synchronous",
        category: "mapper-pattern",
        defaultSeverity: DiagnosticSeverity.Error,
        isEnabledByDefault: false,
        helpLinkUri: "https://github.com/context-and-oss/asimov/blob/main/packages/src/Asimov.Conventions.Patterns/MapperPattern/ASV0401-MapMethodsAreStaticAndSynchronous.md");

    public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get; } = ImmutableArray.Create(Rule);

    public override void Initialize(AnalysisContext context)
    {
        context.EnableConcurrentExecution();
        context.ConfigureGeneratedCodeAnalysis(GeneratedCodeAnalysisFlags.None);
        context.RegisterSymbolAction(AnalyzeMethod, SymbolKind.Method);
    }

    /// <summary>An ASP.NET Core route registration: it takes or returns a route builder, and maps a URL, not a type.</summary>
    private static bool RegistersEndpoints(IMethodSymbol method)
    {
        return IsRouteBuilder(method.ReturnType) || method.Parameters.Any(p => IsRouteBuilder(p.Type));
    }

    private static bool IsRouteBuilder(ITypeSymbol type)
    {
        return type.Name.EndsWith("RouteBuilder", StringComparison.Ordinal)
            || type.Name.EndsWith("ConventionBuilder", StringComparison.Ordinal)
            || type.Name == "RouteGroupBuilder"
            || type.Name == "WebApplication"
            || type.Name == "IApplicationBuilder";
    }

    private static void AnalyzeMethod(SymbolAnalysisContext context)
    {
        var method = (IMethodSymbol)context.Symbol;

        if (method.MethodKind != MethodKind.Ordinary || !method.Name.StartsWith("Map", StringComparison.Ordinal) || RegistersEndpoints(method))
        {
            return;
        }

        if (!method.IsStatic)
        {
            context.ReportDiagnostic(Diagnostic.Create(Rule, method.Locations[0], method.Name, "is not static"));
        }

        if (method.ReturnType is INamedTypeSymbol returned && AsyncReturnTypes.Contains(returned.Name))
        {
            context.ReportDiagnostic(Diagnostic.Create(Rule, method.Locations[0], method.Name, $"returns {returned.Name}"));
        }
    }
}
