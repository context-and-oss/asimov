using System;
using System.Collections.Immutable;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Diagnostics;
using Microsoft.CodeAnalysis.Operations;

namespace Asimov.Conventions.Patterns.BuilderPattern;

[DiagnosticAnalyzer(LanguageNames.CSharp)]
public sealed class BuilderHasNoDependenciesAnalyzer : DiagnosticAnalyzer
{
    public const string DiagnosticId = "ASV0501";

    private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(
        id: DiagnosticId,
        title: "Builders have no dependencies",
        messageFormat: "'{0}' reaches '{1}'; a builder assembles from what it is given, the caller fetches and passes the result into a With* call",
        category: "builder-pattern",
        defaultSeverity: DiagnosticSeverity.Error,
        isEnabledByDefault: false,
        helpLinkUri: "https://github.com/context-and-oss/asimov/blob/main/packages/src/Asimov.Conventions.Patterns/BuilderPattern/ASV0501-BuilderHasNoDependencies.md");

    public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get; } = ImmutableArray.Create(Rule);

    public override void Initialize(AnalysisContext context)
    {
        context.EnableConcurrentExecution();
        context.ConfigureGeneratedCodeAnalysis(GeneratedCodeAnalysisFlags.None);
        context.RegisterSymbolAction(AnalyzeMembers, SymbolKind.NamedType);
        context.RegisterOperationAction(AnalyzeLocal, OperationKind.VariableDeclarator);
        context.RegisterOperationAction(AnalyzeObjectCreation, OperationKind.ObjectCreation);
    }

    private static void AnalyzeMembers(SymbolAnalysisContext context)
    {
        var type = (INamedTypeSymbol)context.Symbol;

        if (!IsBuilder(type))
        {
            return;
        }

        var options = PatternOptions.From(context.Options);
        HeldTypes.ForEachMember(type, held => DependencyTypes.IsServiceOrDataAccess(held, options), (location, held) =>
            context.ReportDiagnostic(Diagnostic.Create(Rule, location, type.Name, held.Name)));
    }

    private static void AnalyzeLocal(OperationAnalysisContext context)
    {
        var declarator = (IVariableDeclaratorOperation)context.Operation;
        var type = context.ContainingSymbol.ContainingType;

        if (type == null || !IsBuilder(type))
        {
            return;
        }

        var options = PatternOptions.From(context.Options);
        if (HeldTypes.HeldByLocal(declarator, held => DependencyTypes.ImplementsServiceOrDataAccess(held, options)) is { } held)
        {
            context.ReportDiagnostic(Diagnostic.Create(Rule, declarator.Syntax.GetLocation(), type.Name, held.Name));
        }
    }

    private static void AnalyzeObjectCreation(OperationAnalysisContext context)
    {
        var creation = (IObjectCreationOperation)context.Operation;
        var type = context.ContainingSymbol.ContainingType;

        if (type == null || !IsBuilder(type))
        {
            return;
        }

        var options = PatternOptions.From(context.Options);
        if (HeldTypes.CreatedByNew(creation, created => DependencyTypes.ImplementsServiceOrDataAccess(created, options)) is { } created)
        {
            context.ReportDiagnostic(Diagnostic.Create(Rule, creation.Syntax.GetLocation(), type.Name, created.Name));
        }
    }

    private static bool IsBuilder(INamedTypeSymbol type)
    {
        for (var current = type; current != null; current = current.ContainingType)
        {
            if (current.TypeKind == TypeKind.Class && current.Name.EndsWith("Builder", StringComparison.Ordinal))
            {
                return true;
            }
        }

        return false;
    }
}
