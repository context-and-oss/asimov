using System;
using Microsoft.CodeAnalysis;

namespace Asimov.Conventions.Patterns;

/// <summary>
/// The types a class must not hold when a pattern says it has no dependencies or no data access:
/// the layer interfaces by suffix, the unit-of-work interface, <c>IServiceProvider</c>, and anything derived from <c>DbContext</c>.
/// Which suffixes and which unit-of-work interface come from <see cref="PatternOptions"/>.
/// </summary>
internal static class DependencyTypes
{
    private const string DbContextMetadataName = "Microsoft.EntityFrameworkCore.DbContext";

    /// <summary>Repositories, gateways, the unit of work and the context: what an entrypoint must not hold.</summary>
    public static bool IsDataAccess(ITypeSymbol type, PatternOptions options)
    {
        return HasAnySuffix(type, options.DataAccessSuffixes)
            || IsNamedInterface(type, options.UnitOfWorkInterface)
            || DerivesFromDbContext(type);
    }

    /// <summary>Data access plus services and the service provider: what a mapper or a builder must not hold.</summary>
    public static bool IsServiceOrDataAccess(ITypeSymbol type, PatternOptions options)
    {
        return IsDataAccess(type, options)
            || HasAnySuffix(type, options.ServiceSuffixes)
            || IsNamedInterface(type, "IServiceProvider");
    }

    /// <summary>A concrete type that is, or implements, one of the service-or-data-access types.</summary>
    public static bool ImplementsServiceOrDataAccess(ITypeSymbol type, PatternOptions options)
    {
        if (IsServiceOrDataAccess(type, options))
        {
            return true;
        }

        foreach (var contract in type.AllInterfaces)
        {
            if (IsServiceOrDataAccess(contract, options))
            {
                return true;
            }
        }

        return false;
    }

    public static bool DerivesFromDbContext(ITypeSymbol type)
    {
        for (var current = type as INamedTypeSymbol; current != null; current = current.BaseType)
        {
            if (current.ToDisplayString() == DbContextMetadataName)
            {
                return true;
            }
        }

        return false;
    }

    private static bool HasAnySuffix(ITypeSymbol type, string[] suffixes)
    {
        foreach (var suffix in suffixes)
        {
            if (IsInterfaceWithSuffix(type, suffix))
            {
                return true;
            }
        }

        return false;
    }

    private static bool IsInterfaceWithSuffix(ITypeSymbol type, string suffix)
    {
        return type.TypeKind == TypeKind.Interface
            && type.Name.Length > suffix.Length + 1
            && type.Name[0] == 'I'
            && type.Name.EndsWith(suffix, StringComparison.Ordinal);
    }

    private static bool IsNamedInterface(ITypeSymbol type, string name)
    {
        return type.TypeKind == TypeKind.Interface && type.Name == name;
    }
}
