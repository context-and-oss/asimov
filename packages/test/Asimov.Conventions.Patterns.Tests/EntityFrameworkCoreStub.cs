namespace Asimov.Conventions.Patterns.Tests;

/// <summary>The few EF Core types the rules recognise by name, so a test needs no package reference.</summary>
internal static class EntityFrameworkCoreStub
{
    public const string Source = """
        namespace Microsoft.EntityFrameworkCore
        {
            public class DbContext
            {
                public virtual int SaveChanges() => 0;

                public virtual int SaveChanges(bool acceptAllChangesOnSuccess) => 0;

                public virtual System.Threading.Tasks.Task<int> SaveChangesAsync(System.Threading.CancellationToken cancellationToken = default)
                {
                    return System.Threading.Tasks.Task.FromResult(0);
                }

                public virtual System.Threading.Tasks.Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, System.Threading.CancellationToken cancellationToken = default)
                {
                    return System.Threading.Tasks.Task.FromResult(0);
                }
            }

            public class DbSet<TEntity> where TEntity : class
            {
            }

            public interface IDbContextFactory<TContext> where TContext : DbContext
            {
                TContext CreateDbContext();
            }
        }
        """;
}
