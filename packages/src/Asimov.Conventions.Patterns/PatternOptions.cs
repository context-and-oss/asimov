using System;
using Microsoft.CodeAnalysis.Diagnostics;

namespace Asimov.Conventions.Patterns;

/// <summary>
/// The names a product gives its layers, read from global analyzer options so the rules stay generic.
/// Every key has a default; a product whose names match the defaults sets nothing. Set them in the
/// product's convention globalconfig, for example <c>asimov_patterns.data_access_suffixes = Repository;TableGateway</c>.
/// </summary>
internal sealed class PatternOptions
{
    public const string DataAccessSuffixesKey = "asimov_patterns.data_access_suffixes";
    public const string ServiceSuffixesKey = "asimov_patterns.service_suffixes";
    public const string UnitOfWorkInterfaceKey = "asimov_patterns.unit_of_work_interface";
    public const string MapMethodPrefixKey = "asimov_patterns.map_method_prefix";
    public const string MapMethodInfixKey = "asimov_patterns.map_method_infix";

    private static readonly string[] DefaultDataAccessSuffixes = ["Repository", "TableGateway"];
    private static readonly string[] DefaultServiceSuffixes = ["Service"];
    private const string DefaultUnitOfWorkInterface = "IUnitOfWork";
    private const string DefaultMapMethodPrefix = "MapFrom";
    private const string DefaultMapMethodInfix = "To";

    private PatternOptions(string[] dataAccessSuffixes, string[] serviceSuffixes, string unitOfWorkInterface, string mapMethodPrefix, string mapMethodInfix)
    {
        DataAccessSuffixes = dataAccessSuffixes;
        ServiceSuffixes = serviceSuffixes;
        UnitOfWorkInterface = unitOfWorkInterface;
        MapMethodPrefix = mapMethodPrefix;
        MapMethodInfix = mapMethodInfix;
    }

    /// <summary>What a public map method's name starts with: <c>MapFrom</c> in <c>MapFromOrderToOrderSummary</c>.</summary>
    public string MapMethodPrefix { get; }

    /// <summary>What separates input from output in a public map method's name: <c>To</c> in <c>MapFromOrderToOrderSummary</c>.</summary>
    public string MapMethodInfix { get; }

    /// <summary>Suffixes of the interfaces that are data access: <c>IOrderRepository</c>, <c>IOrderTableGateway</c>.</summary>
    public string[] DataAccessSuffixes { get; }

    /// <summary>Suffixes of the interfaces that are services: <c>IOrderService</c>.</summary>
    public string[] ServiceSuffixes { get; }

    /// <summary>The interface that owns the transaction boundary.</summary>
    public string UnitOfWorkInterface { get; }

    public static PatternOptions From(AnalyzerOptions options)
    {
        var global = options.AnalyzerConfigOptionsProvider.GlobalOptions;

        return new PatternOptions(
            List(global, DataAccessSuffixesKey, DefaultDataAccessSuffixes),
            List(global, ServiceSuffixesKey, DefaultServiceSuffixes),
            Single(global, UnitOfWorkInterfaceKey, DefaultUnitOfWorkInterface),
            Single(global, MapMethodPrefixKey, DefaultMapMethodPrefix),
            Single(global, MapMethodInfixKey, DefaultMapMethodInfix));
    }

    private static string[] List(AnalyzerConfigOptions global, string key, string[] fallback)
    {
        if (!global.TryGetValue(key, out var value) || string.IsNullOrWhiteSpace(value))
        {
            return fallback;
        }

        var parts = value.Split([';', ','], StringSplitOptions.RemoveEmptyEntries);
        for (var i = 0; i < parts.Length; i++)
        {
            parts[i] = parts[i].Trim();
        }

        return parts;
    }

    private static string Single(AnalyzerConfigOptions global, string key, string fallback)
    {
        return global.TryGetValue(key, out var value) && !string.IsNullOrWhiteSpace(value) ? value.Trim() : fallback;
    }
}
