using System;
using System.Collections.Immutable;
using System.Linq;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Diagnostics;

namespace Asimov.Conventions.Patterns.BuilderPattern;

[DiagnosticAnalyzer(LanguageNames.CSharp)]
public sealed class BuilderExposesBuildAnalyzer : DiagnosticAnalyzer
{
    public const string DiagnosticId = "ASV0502";

    private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(
        id: DiagnosticId,
        title: "Builders expose Build()",
        messageFormat: "'{0}' has no public instance Build() method; a class with the Builder suffix accumulates state across With* calls and produces the object in Build()",
        category: "builder-pattern",
        defaultSeverity: DiagnosticSeverity.Error,
        isEnabledByDefault: false,
        helpLinkUri: "https://github.com/context-and-oss/asimov/blob/main/packages/src/Asimov.Conventions.Patterns/BuilderPattern/ASV0502-BuilderExposesBuild.md");

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

        if (type.TypeKind != TypeKind.Class || type.IsAbstract || !type.Name.EndsWith("Builder", StringComparison.Ordinal))
        {
            return;
        }

        for (var current = type; current != null; current = current.BaseType)
        {
            if (current.GetMembers("Build").OfType<IMethodSymbol>().Any(m => m.MethodKind == MethodKind.Ordinary && !m.IsStatic && m.DeclaredAccessibility == Accessibility.Public))
            {
                return;
            }
        }

        context.ReportDiagnostic(Diagnostic.Create(Rule, type.Locations[0], type.Name));
    }
}
