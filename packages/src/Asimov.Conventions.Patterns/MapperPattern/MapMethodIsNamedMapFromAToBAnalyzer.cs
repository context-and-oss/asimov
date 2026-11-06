using System;
using System.Collections.Immutable;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Diagnostics;

namespace Asimov.Conventions.Patterns.MapperPattern;

[DiagnosticAnalyzer(LanguageNames.CSharp)]
public sealed class MapMethodIsNamedMapFromAToBAnalyzer : DiagnosticAnalyzer
{
    public const string DiagnosticId = "ASV0403";

    private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(
        id: DiagnosticId,
        title: "Public map methods are named MapFromAToB",
        messageFormat: "'{0}' is a public method on a mapper; name it {1}{{Input}}{2}{{Output}} so the call site reads as a transformation",
        category: "mapper-pattern",
        defaultSeverity: DiagnosticSeverity.Error,
        isEnabledByDefault: false,
        helpLinkUri: "https://github.com/context-and-oss/asimov/blob/main/packages/src/Asimov.Conventions.Patterns/MapperPattern/ASV0403-MapMethodIsNamedMapFromAToB.md");

    public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get; } = ImmutableArray.Create(Rule);

    public override void Initialize(AnalysisContext context)
    {
        context.EnableConcurrentExecution();
        context.ConfigureGeneratedCodeAnalysis(GeneratedCodeAnalysisFlags.None);
        context.RegisterSymbolAction(AnalyzeMethod, SymbolKind.Method);
    }

    /// <summary>The prefix, then at least one character of A, then the infix; the bare prefix has no A and no B.</summary>
    private static bool HasShape(string name, string prefix, string infix)
    {
        return name.Length > prefix.Length + 1
            && name.StartsWith(prefix, StringComparison.Ordinal)
            && name.IndexOf(infix, prefix.Length + 1, StringComparison.Ordinal) > 0;
    }

    private static void AnalyzeMethod(SymbolAnalysisContext context)
    {
        var method = (IMethodSymbol)context.Symbol;

        if (method.MethodKind != MethodKind.Ordinary
            || method.DeclaredAccessibility != Accessibility.Public
            || method.ContainingType.TypeKind != TypeKind.Class
            || !method.ContainingType.Name.EndsWith("Mapper", StringComparison.Ordinal))
        {
            return;
        }

        var options = PatternOptions.From(context.Options);
        if (HasShape(method.Name, options.MapMethodPrefix, options.MapMethodInfix))
        {
            return;
        }

        context.ReportDiagnostic(Diagnostic.Create(Rule, method.Locations[0], method.Name, options.MapMethodPrefix, options.MapMethodInfix));
    }
}
