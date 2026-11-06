# Asimov.Conventions

Owns the code analyzers a .NET product uses and their complete configuration. A product repo carries one package reference and one mode property instead of analyzer references and severity lines.

## Consume it

```xml
<!-- src/Directory.Build.props: production code -->
<ItemGroup>
  <PackageReference Include="Asimov.Conventions" Version="4.0.0" PrivateAssets="All" />
</ItemGroup>
<PropertyGroup>
  <AsimovAnalysisMode>Minimum</AsimovAnalysisMode>
</PropertyGroup>
```

A product that has its own convention package (for example `Contoso.Conventions`) references that instead; it brings Asimov.Conventions along. Test projects reference `Asimov.TestConventions` (or the product's test-convention package).

The feed is GitHub Packages under `context-and-oss`; a consumer adds the source to its `nuget.config` and, from another organisation, a read-only token. The package version is the Asimov release version: one release, one number.

Then paste the managed block from `config/Asimov.Formatting.editorconfig` into the repo's `.editorconfig`. `dotnet format` only honours severities from `.editorconfig` ([dotnet/sdk#53750](https://github.com/dotnet/sdk/issues/53750)); the compiler takes them from the package. The block is seven lines and the build checks that it matches.

## The knob

| Property | Values | Default |
|---|---|---|
| `AsimovAnalysisMode` | `None`, `Minimum`, `Recommended`, `All` | `None` — the package changes nothing |
| `AsimovAnalysisLevel` | `latest`, `1`, `2`, … | `latest` — applies to contributors (below) |

`Minimum` is what a build must not ship without: rules a tool fixes for free (`Formatting`) and code that is wrong at run time (`Async`, `Correctness`, `Resources`, `Security`). `Recommended` adds the rules that need a human decision (`Culture`, `Readability`). `All` adds `Extended`.

## What it does to your build

When the mode is not `None`: `AnalysisMode=Recommended`, `AnalysisLevel=latest`, `EnableNETAnalyzers`, `EnforceCodeStyleInBuild`, `TreatWarningsAsErrors` and `GenerateDocumentationFile` are forced on. A rule is `error` or off; nothing sits at `warning` to be ignored. The analyzers come with the package: the SDK's CA and IDE rules, `SonarAnalyzer.CSharp`, `Meziantou.Analyzer` and `Asimov.Conventions.Patterns`.

## The config files

Every file answers one question an agent asks. Each rule line carries a one-line reason.

| File | Purpose |
|---|---|
| `Asimov.Baseline` | Every analyzer rule off unless a file below names it. The SDK's Recommended CA set survives (it is named rule by rule by the SDK). |
| `Asimov.Style` | Layout options and naming rules, no severities. |
| `Asimov.Formatting` | Rules with a reliable code fix. Always `error`; `dotnet format` applies them. |
| `Asimov.Async` | What goes wrong around `Task` and threading. |
| `Asimov.Correctness` | Code that compiles and does not do what it reads as doing. |
| `Asimov.Rejected` | Rules we have decided against, with the reason. |

Precedence: Asimov files are `global_level` 100, a contributor's Legacy file 150, a contributor's mode file 200, and the repo's `.editorconfig` wins over all of them.

## Repo exceptions

A deliberate exception is one line in the repo's `.editorconfig`, marked so it can be found:

```ini
dotnet_diagnostic.IDE0130.severity = none   # exception: 192 hits, the namespace is the published contract (jd, 2026-01-15)
```

`grep -rn '# exception:'` across the repos is the complete list of local deviations. Agents never add one: no `#pragma warning disable`, no `[SuppressMessage]`, no `.editorconfig` line, no change to the mode. A suppression is a human commit with a reason.

## Write a contributor

A product-convention package registers itself from its own `buildTransitive/<Package>.props`:

```xml
<ItemGroup>
  <AsimovConventionsContributor Include="Contoso.Conventions"
      ConfigDirectory="$(MSBuildThisFileDirectory)../config/"
      LatestLevel="1" />
</ItemGroup>
```

and ships `config/<Name>.<level>-<mode>.globalconfig` for every mode it supports, at `global_level = 200`. An optional `config/<Name>.Legacy.globalconfig` at `global_level = 150` carries the rules the product's code is not ready for yet: every line is debt, removing it turns the rule on, and it is injected in every mode but `None`. It takes `Asimov.Conventions` as a dependency with `PrivateAssets="none"`, so the consumer gets both with one reference. Its config turns on the generic pattern rules the product uses (`ASV*`, see Asimov.Conventions.Patterns) beside its own.

## Errors

| Code | Meaning |
|---|---|
| `ASV0001` | Unknown `AsimovAnalysisMode`, or a contributor has no config for the mode and level. The message names the expected file. |
| `ASV0002` | A severity line in `.editorconfig` without the `# exception:` marker, or a managed block that differs from the package's copy. (Planned.) |

## Verify locally

`dotnet test packages/Asimov.Packages.slnx` runs the analyzer tests. Repacking the same version into the local NuGet cache needs the cache entry removed and `dotnet build-server shutdown`; long-lived MSBuild nodes otherwise run the old targets.
