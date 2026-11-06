# Asimov.TestConventions

The test layer on top of Asimov.Conventions, which it brings along. A test project references this package (or a product's test-convention package that depends on it) and runs at the same `AsimovAnalysisMode` as the rest of the repo.

```xml
<!-- tests/Directory.Build.props -->
<ItemGroup>
  <PackageReference Include="Asimov.TestConventions" Version="4.0.0" PrivateAssets="All" />
</ItemGroup>
```

One file, `config/Asimov.Test.globalconfig` at `global_level` 110, adjusts the generic rules for test code:

- **Off, with the reason in the file:** CA1707 (underscores in test names), CA1062 (null checks on arguments), CA1515 (make types internal), CA1822 (mark members static), MA0051 (method too long).
- **On:** S2699 (a test has an assertion) and the xunit.analyzers rules that the Baseline would otherwise silence.

Mocking-library analyzers are not here: a product that uses NSubstitute or Moq adds that analyzer in its own test-convention package.

See the [Asimov.Conventions README](../Asimov.Conventions/README.md) for the knob, the files, repo exceptions and how a contributor registers.
