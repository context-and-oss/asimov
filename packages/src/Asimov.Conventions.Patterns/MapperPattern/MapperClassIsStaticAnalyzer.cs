using System;
using System.Collections.Immutable;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Diagnostics;

namespace Asimov.Conventions.Patterns.MapperPattern;

[DiagnosticAnalyzer(LanguageNames.CSharp)]
public sealed class MapperClassIsStaticAnalyzer : DiagnosticAnalyzer
{
    public const string DiagnosticId = "ASV0402";

    private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(
        id: DiagnosticId,
        title: "Mapper classes are static",
        messageFormat: "'{0}' is not static; a mapper has no constructor, no state and no DI",
        category: "mapper-pattern",
        defaultSeverity: DiagnosticSeverity.Error,
        isEnabledByDefault: false,
        helpLinkUri: "https://github.com/context-and-oss/asimov/blob/main/packages/src/Asimov.Conventions.Patterns/MapperPattern/ASV0402-MapperClassIsStatic.md");

    public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get; } = ImmutableArray.Create(Rule);

    public override void Initialize(AnalysisContext context)
    {
        context.EnableConcurrentExecution();
        context.ConfigureGeneratedCodeAnalysis(GeneratedCodeAnalysisFlags.None);
        context.RegisterSymbolAction(AnalyzeType, SymbolKind.NamedType);
    }

    private static void AnalyzeType(SymbolAnalysisContext context)
    {
        var type = (INamedTypeSymbol)context.Symbol;

        if (type.TypeKind == TypeKind.Class && !type.IsRecord && !type.IsStatic && type.Name.EndsWith("Mapper", StringComparison.Ordinal))
        {
            context.ReportDiagnostic(Diagnostic.Create(Rule, type.Locations[0], type.Name));
        }
    }
}
