namespace :seed do
  desc "Run new data migrations."
  task :migrate => :environment do
    filename = ENV["MIGRATION"]
    if filename.blank?
      # Run any outstanding migrations
      SeedMigration::Migrator.run_new_migrations
    else
      path = SeedMigration::Migrator.migration_path(filename)
      SeedMigration::Migrator.new(path).up
    end
  end

  desc "Revert last data migration."
  task :rollback => :environment do
    filename = ENV["MIGRATION"]
    if filename.blank?
      steps = ENV["STEP"] || 1
      SeedMigration::Migrator.rollback_migrations(steps)
    else
      path = SeedMigration::Migrator.migration_path(filename)
      SeedMigration::Migrator.new(path).down
    end
  end
end
