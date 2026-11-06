using System;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.Operations;

namespace Asimov.Conventions.Patterns;

/// <summary>
/// Walks what a class holds — fields, properties, constructor and method parameters — and what a method
/// declares or creates, so a check can say "this class must not hold a type like that" once.
/// </summary>
internal static class HeldTypes
{
    public static void ForEachMember(INamedTypeSymbol type, Func<ITypeSymbol, bool> matches, Action<Location, ITypeSymbol> report)
    {
        foreach (var member in type.GetMembers())
        {
            if (member.IsImplicitlyDeclared)
            {
                continue;
            }

            switch (member)
            {
                case IFieldSymbol field when matches(field.Type):
                    report(field.Locations[0], field.Type);
                    break;
                case IPropertySymbol property when matches(property.Type):
                    report(property.Locations[0], property.Type);
                    break;
                case IMethodSymbol { MethodKind: MethodKind.Ordinary or MethodKind.Constructor } method:
                    foreach (var parameter in method.Parameters)
                    {
                        if (matches(parameter.Type))
                        {
                            report(parameter.Locations[0], parameter.Type);
                        }
                    }

                    break;
            }
        }
    }

    /// <summary>The type a local holds, when it matches; the local is reported once even when it is initialised with a <c>new</c>.</summary>
    public static ITypeSymbol? HeldByLocal(IVariableDeclaratorOperation declarator, Func<ITypeSymbol, bool> matches)
    {
        return matches(declarator.Symbol.Type) ? declarator.Symbol.Type : null;
    }

    /// <summary>The type a <c>new</c> creates, when it matches and the creation is not the initialiser of a local that is reported on its own.</summary>
    public static ITypeSymbol? CreatedByNew(IObjectCreationOperation creation, Func<ITypeSymbol, bool> matches)
    {
        if (creation.Type == null || creation.Parent is IVariableInitializerOperation || !matches(creation.Type))
        {
            return null;
        }

        return creation.Type;
    }
}
