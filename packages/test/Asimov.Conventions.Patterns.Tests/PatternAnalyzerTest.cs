using Microsoft.CodeAnalysis.CSharp.Testing;
using Microsoft.CodeAnalysis.Diagnostics;
using Microsoft.CodeAnalysis.Testing;

namespace Asimov.Conventions.Patterns.Tests;

/// <summary>
/// Builds the analyzer test every pattern test uses: .NET 8 reference assemblies, the shared stubs,
/// the case source, and a globalconfig that either enables the one diagnostic or leaves it at its
/// disabled default. Options for a rule are added by the test with a second AnalyzerConfigFiles entry.
/// </summary>
internal static class PatternAnalyzerTest
{
    public static CSharpAnalyzerTest<TAnalyzer, DefaultVerifier> Create<TAnalyzer>(string diagnosticId, bool enabled, params string[] sources)
        where TAnalyzer : DiagnosticAnalyzer, new()
    {
        var test = new CSharpAnalyzerTest<TAnalyzer, DefaultVerifier>
        {
            ReferenceAssemblies = ReferenceAssemblies.Net.Net80,
        };

        test.TestState.Sources.Add(EntityFrameworkCoreStub.Source);

        foreach (var source in sources)
        {
            test.TestState.Sources.Add(source);
        }

        // The harness force-enables every descriptor; "default" restores the descriptor default (disabled).
        var severity = enabled ? "error" : "default";
        test.TestState.AnalyzerConfigFiles.Add(("/.globalconfig", $"is_global = true\ndotnet_diagnostic.{diagnosticId}.severity = {severity}"));

        return test;
    }
}
