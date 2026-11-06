using System;
using System.Collections.Immutable;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Diagnostics;
using Microsoft.CodeAnalysis.Operations;

namespace Asimov.Conventions.Patterns.MapperPattern;

[DiagnosticAnalyzer(LanguageNames.CSharp)]
public sealed class MapperHasNoDependenciesAnalyzer : DiagnosticAnalyzer
{
    public const string DiagnosticId = "ASV0404";

    private static readonly DiagnosticDescriptor Rule = new DiagnosticDescriptor(
        id: DiagnosticId,
        title: "Mappers have no dependencies",
        messageFormat: "'{0}' reaches '{1}'; a mapper takes input and returns output, the caller does the lookup and passes the result in",
        category: "mapper-pattern",
        defaultSeverity: DiagnosticSeverity.Error,
        isEnabledByDefault: false,
        helpLinkUri: "https://github.com/context-and-oss/asimov/blob/main/packages/src/Asimov.Conventions.Patterns/MapperPattern/ASV0404-MapperHasNoDependencies.md");

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

        if (!IsMapper(type))
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

        if (type == null || !IsMapper(type))
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

        if (type == null || !IsMapper(type))
        {
            return;
        }

        var options = PatternOptions.From(context.Options);
        if (HeldTypes.CreatedByNew(creation, created => DependencyTypes.ImplementsServiceOrDataAccess(created, options)) is { } created)
        {
            context.ReportDiagnostic(Diagnostic.Create(Rule, creation.Syntax.GetLocation(), type.Name, created.Name));
        }
    }

    private static bool IsMapper(INamedTypeSymbol type)
    {
        for (var current = type; current != null; current = current.ContainingType)
        {
            if (current.TypeKind == TypeKind.Class && current.Name.EndsWith("Mapper", StringComparison.Ordinal))
            {
                return true;
            }
        }

        return false;
    }
}
