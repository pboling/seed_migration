require "seed_migration/version"
require "seed_migration/engine"

module SeedMigration
  autoload :Migrator, "seed_migration/migrator" # Is it needed ?
  autoload :Migration, "seed_migration/migration" # Is it needed ?
end
